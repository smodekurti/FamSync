import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:fam_sync/domain/models/family_invite.dart';
import 'package:fam_sync/domain/models/pending_member.dart';
import 'package:fam_sync/domain/models/invite_validation_result.dart';
import 'package:fam_sync/domain/models/family.dart' as models;
import 'package:fam_sync/data/auth/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

/// Repository for managing family invitations
/// Handles invite generation, validation, acceptance, and lifecycle management
class InviteRepository {
  InviteRepository({
    FirebaseFirestore? firestore,
    Uuid? uuid,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _uuid = uuid ?? const Uuid();

  final FirebaseFirestore _firestore;
  final Uuid _uuid;

  /// Generates a new invite code for a family
  /// Creates a secure, unique code that can be shared with potential members
  String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    final code = StringBuffer();
    
    // Generate 8-character code
    for (int i = 0; i < 8; i++) {
      code.write(chars[random.nextInt(chars.length)]);
    }
    
    return code.toString();
  }

  /// Creates a new family invitation
  /// Returns the created invite with a unique code
  Future<FamilyInvite> createInvite({
    required String familyId,
    required String createdByUid,
    String role = 'child',
    int maxUses = 1,
    int daysUntilExpiry = 7,
  }) async {
    print('🔍 [DEBUG] createInvite called with:');
    print('   - familyId: $familyId');
    print('   - createdByUid: $createdByUid');
    print('   - role: $role');
    print('   - maxUses: $maxUses');
    print('   - daysUntilExpiry: $daysUntilExpiry');
    
    try {
      print('🔍 [DEBUG] Step 1: Validating user permissions...');
      
      // First, validate that the user can create invites for this family
      print('🔍 [DEBUG] Attempting to read family document: families/$familyId');
      final familyDoc = await _firestore.collection('families').doc(familyId).get();
      
      print('🔍 [DEBUG] Family document read result:');
      print('   - exists: ${familyDoc.exists}');
      print('   - has data: ${familyDoc.data() != null}');
      
      if (!familyDoc.exists) {
        print('❌ [DEBUG] Family document does not exist');
        throw Exception('Family not found');
      }
      
      print('🔍 [DEBUG] Step 2: Parsing family data...');
      final family = models.Family.fromJson(familyDoc.data()!);
      print('🔍 [DEBUG] Family parsed successfully:');
      print('   - name: ${family.name}');
      print('   - memberUids: ${family.memberUids}');
      print('   - roles: ${family.roles}');
      print('   - ownerUid: ${family.ownerUid}');
      print('   - allowInvites: ${family.allowInvites}');
      print('   - maxMembers: ${family.maxMembers}');
      
      print('🔍 [DEBUG] Step 3: Checking if user can create invites...');
      final canCreate = family.canCreateInvites(createdByUid);
      print('🔍 [DEBUG] canCreateInvites($createdByUid) = $canCreate');
      
      if (!canCreate) {
        print('❌ [DEBUG] User does not have permission to create invites');
        print('   - user is owner: ${family.isOwner(createdByUid)}');
        print('   - user is parent: ${family.isParent(createdByUid)}');
        throw Exception('You do not have permission to create invites for this family');
      }
      
      print('🔍 [DEBUG] Step 4: Checking if family can accept new members...');
      final canAccept = family.canAcceptMembers;
      print('🔍 [DEBUG] canAcceptMembers = $canAccept');
      
      if (!canAccept) {
        print('❌ [DEBUG] Family cannot accept new members');
        print('   - member count: ${family.memberUids.length}');
        print('   - max members: ${family.maxMembers}');
        print('   - allow invites: ${family.allowInvites}');
        
        if (family.memberUids.length >= family.maxMembers) {
          throw Exception('Family has reached its maximum member limit (${family.maxMembers})');
        } else if (!family.allowInvites) {
          throw Exception('Family has disabled new member invitations');
        } else {
          throw Exception('Family cannot accept new members at this time');
        }
      }
      
      print('🔍 [DEBUG] Step 5: Generating unique invite code...');
      
      // Generate unique invite code
      String inviteCode;
      bool isUnique = false;
      int attempts = 0;
      
      // Ensure invite code is unique
      do {
        attempts++;
        inviteCode = _generateInviteCode();
        print('🔍 [DEBUG] Generated invite code attempt $attempts: $inviteCode');
        
        print('🔍 [DEBUG] Checking for duplicate invite codes...');
        final existingInvite = await _firestore
            .collection('invites')
            .where('inviteCode', isEqualTo: inviteCode)
            .where('status', isEqualTo: InviteStatus.active.name)
            .get();
        
        isUnique = existingInvite.docs.isEmpty;
        print('🔍 [DEBUG] Duplicate check result: isUnique = $isUnique');
        
        if (!isUnique) {
          print('🔍 [DEBUG] Code $inviteCode already exists, generating new one...');
        }
      } while (!isUnique && attempts < 10); // Prevent infinite loops
      
      if (!isUnique) {
        print('❌ [DEBUG] Failed to generate unique invite code after $attempts attempts');
        throw Exception('Failed to generate unique invite code');
      }
      
      print('🔍 [DEBUG] Unique invite code generated: $inviteCode');
      
      print('🔍 [DEBUG] Step 6: Creating invite document...');
      
      // Create invite document
      final doc = _firestore.collection('invites').doc();
      print('🔍 [DEBUG] Created document reference: invites/${doc.id}');
      
      final invite = FamilyInvite.create(
        id: doc.id,
        familyId: familyId,
        inviteCode: inviteCode,
        createdByUid: createdByUid,
        role: role,
        maxUses: maxUses,
        daysUntilExpiry: daysUntilExpiry,
      );
      
      print('🔍 [DEBUG] Invite object created successfully:');
      print('   - id: ${invite.id}');
      print('   - familyId: ${invite.familyId}');
      print('🔍 [DEBUG] Invite data to be written:');
      print('   - JSON: ${invite.toJson()}');
      
      print('🔍 [DEBUG] Step 7: Writing invite to Firestore...');
      print('🔍 [DEBUG] This is where the permission error likely occurs...');
      
      try {
        await doc.set(invite.toJson());
        print('✅ [DEBUG] Invite document written successfully to Firestore!');
      } catch (e) {
        print('❌ [DEBUG] ERROR writing invite to Firestore:');
        print('   - Error type: ${e.runtimeType}');
        print('   - Error message: $e');
        print('   - Error toString: ${e.toString()}');
        
        // Re-throw with additional context
        throw Exception('Failed to write invite to Firestore: $e');
      }
      
      print('🔍 [DEBUG] Step 8: Returning created invite...');
      print('✅ [DEBUG] createInvite completed successfully!');
      return invite;
      
    } catch (e) {
      print('❌ [DEBUG] ERROR in createInvite:');
      print('   - Error type: ${e.runtimeType}');
      print('   - Error message: $e');
      print('   - Error toString: ${e.toString()}');
      
      // Re-throw the error
      rethrow;
    }
  }

  /// Validates an invite code and returns detailed information
  /// This is the core method for invite validation
  Future<InviteValidationResult> validateInviteCode(String inviteCode) async {
    print('🔍 [DEBUG] ===== INVITE VALIDATION START =====');
    print('🔍 [DEBUG] Invite code to validate: "$inviteCode"');
    print('🔍 [DEBUG] Current user UID: ${fb.FirebaseAuth.instance.currentUser?.uid}');
    print('🔍 [DEBUG] Current user email: ${fb.FirebaseAuth.instance.currentUser?.email}');
    print('🔍 [DEBUG] Is user signed in: ${fb.FirebaseAuth.instance.currentUser != null}');
    
    try {
      print('🔍 [DEBUG] Step 1: Querying invites collection for code "$inviteCode"');
      print('🔍 [DEBUG] Collection path: invites');
      print('🔍 [DEBUG] Query: where("inviteCode", isEqualTo: "$inviteCode")');
      
      // Find invite by code
      final inviteQuery = await _firestore
          .collection('invites')
          .where('inviteCode', isEqualTo: inviteCode)
          .limit(1)
          .get();

      print('✅ [DEBUG] Invite query completed successfully!');
      print('🔍 [DEBUG] Query result: ${inviteQuery.docs.length} documents found');
      
      if (inviteQuery.docs.isEmpty) {
        print('❌ [DEBUG] No invites found with code "$inviteCode"');
        return InviteValidationResult.failure(
          errorMessage: 'Invalid invite code',
          errorType: InviteValidationError.invalidCode,
        );
      }

      final inviteDoc = inviteQuery.docs.first;
      print('✅ [DEBUG] Found invite document: ${inviteDoc.id}');
      print('🔍 [DEBUG] Invite document data: ${inviteDoc.data()}');
      
      final invite = FamilyInvite.fromJson(inviteDoc.data());
      print('✅ [DEBUG] Successfully parsed invite object');
      print('🔍 [DEBUG] Parsed invite details:');
      print('   - ID: ${invite.id}');
      print('   - Family ID: ${invite.familyId}');
      print('   - Status: ${invite.status}');
      print('   - Expires at: ${invite.expiresAt}');
      print('   - Use count: ${invite.useCount}/${invite.maxUses}');

      // Check if invite is active
      print('🔍 [DEBUG] Step 2: Checking invite status');
      if (invite.status != InviteStatus.active) {
        print('❌ [DEBUG] Invite is not active. Status: ${invite.status}');
        if (invite.status == InviteStatus.revoked) {
          return InviteValidationResult.failure(
            errorMessage: 'Invite has been revoked',
            errorType: InviteValidationError.revoked,
            inviteId: invite.id,
          );
        }
        if (invite.status == InviteStatus.accepted) {
          return InviteValidationResult.failure(
            errorMessage: 'Invite has already been used',
            errorType: InviteValidationError.alreadyUsed,
            inviteId: invite.id,
          );
        }
        if (invite.status == InviteStatus.expired) {
          return InviteValidationResult.failure(
            errorMessage: 'Invite has expired',
            errorType: InviteValidationError.expired,
            inviteId: invite.id,
          );
        }
      }

      // Check if invite has expired
      print('🔍 [DEBUG] Step 3: Checking if invite has expired');
      if (invite.isExpired) {
        print('❌ [DEBUG] Invite has expired. Expires at: ${invite.expiresAt}');
        return InviteValidationResult.failure(
          errorMessage: 'Invite has expired',
          errorType: InviteValidationError.expired,
          inviteId: invite.id,
        );
      }

      // Check if invite has been used up
      print('🔍 [DEBUG] Step 4: Checking invite usage count');
      if (invite.useCount >= invite.maxUses) {
        print('❌ [DEBUG] Invite has been used up. Use count: ${invite.useCount}/${invite.maxUses}');
        return InviteValidationResult.failure(
          errorMessage: 'Invite has already been used',
          errorType: InviteValidationError.alreadyUsed,
          inviteId: invite.id,
        );
      }

      // Get family information
      print('🔍 [DEBUG] Step 5: Fetching family information');
      print('🔍 [DEBUG] Family document path: families/${invite.familyId}');
      
      final familyDoc = await _firestore
          .collection('families')
          .doc(invite.familyId)
          .get();

      print('✅ [DEBUG] Family document fetch completed successfully!');
      print('🔍 [DEBUG] Family document exists: ${familyDoc.exists}');
      
      if (!familyDoc.exists) {
        print('❌ [DEBUG] Family document does not exist');
        return InviteValidationResult.failure(
          errorMessage: 'Family not found',
          errorType: InviteValidationError.familyNotFound,
          inviteId: invite.id,
        );
      }

      print('🔍 [DEBUG] Family document data: ${familyDoc.data()}');
      final family = models.Family.fromJson(familyDoc.data()!);
      print('✅ [DEBUG] Successfully parsed family object');
      print('🔍 [DEBUG] Parsed family details:');
      print('   - ID: ${family.id}');
      print('   - Name: ${family.name}');
      print('   - Member count: ${family.memberUids.length}');
      print('   - Max members: ${family.maxMembers}');
      print('   - Can accept members: ${family.canAcceptMembers}');

      // Check if family is full
      print('🔍 [DEBUG] Step 6: Checking if family can accept new members');
      if (!family.canAcceptMembers) {
        print('❌ [DEBUG] Family cannot accept new members');
        print('   - Member count: ${family.memberUids.length}');
        print('   - Max members: ${family.maxMembers}');
        print('   - Allow invites: ${family.allowInvites}');
        return InviteValidationResult.failure(
          errorMessage: 'Family has reached its member limit',
          errorType: InviteValidationError.familyFull,
          family: family,
          inviteId: invite.id,
        );
      }

      // Check if current user is already a member
      print('🔍 [DEBUG] Step 7: Checking if current user is already a member');
      final currentUser = await _getCurrentUser();
      print('🔍 [DEBUG] Current user data: ${currentUser?.toJson()}');
      
      if (currentUser != null && family.memberUids.contains(currentUser.uid)) {
        print('❌ [DEBUG] User is already a member of this family');
        return InviteValidationResult.failure(
          errorMessage: 'You are already a member of this family',
          errorType: InviteValidationError.alreadyMember,
          family: family,
          inviteId: invite.id,
          isAlreadyMember: true,
        );
      }

      print('✅ [DEBUG] ===== INVITE VALIDATION SUCCESS =====');
      print('🔍 [DEBUG] Returning successful validation result');
      
      // Return successful validation
      return InviteValidationResult.success(
        family: family,
        inviteId: invite.id,
      );
      
    } catch (e, stackTrace) {
      print('❌ [DEBUG] ===== INVITE VALIDATION ERROR =====');
      print('❌ [DEBUG] Error type: ${e.runtimeType}');
      print('❌ [DEBUG] Error message: $e');
      print('❌ [DEBUG] Error toString: $e');
      print('❌ [DEBUG] Stack trace: $stackTrace');
      
      // Check if it's a Firebase exception
      if (e is fb.FirebaseException) {
        print('🔍 [DEBUG] Firebase exception details:');
        print('   - Code: ${e.code}');
        print('   - Message: ${e.message}');
      }
      
      // Check if it's a Firestore exception
      if (e is fb.FirebaseException && e.code == 'permission-denied') {
        print('🚨 [DEBUG] PERMISSION DENIED ERROR DETECTED!');
        print('🚨 [DEBUG] This suggests a security rules issue');
        print('🚨 [DEBUG] Current user: ${fb.FirebaseAuth.instance.currentUser?.uid}');
        print('🚨 [DEBUG] User email: ${fb.FirebaseAuth.instance.currentUser?.email}');
        print('🚨 [DEBUG] User signed in: ${fb.FirebaseAuth.instance.currentUser != null}');
      }
      
      return InviteValidationResult.failure(
        errorMessage: 'Error validating invite: $e',
        errorType: InviteValidationError.unknown,
      );
    }
  }

  /// Accepts an invite and adds the user to the family
  /// This is the method called when a user wants to join a family
  Future<void> acceptInvite({
    required String inviteId,
    required String uid,
    required String displayName,
    required String email,
  }) async {
    await _firestore.runTransaction((tx) async {
      // Get the invite
      final inviteRef = _firestore.collection('invites').doc(inviteId);
      final inviteDoc = await tx.get(inviteRef);
      
      if (!inviteDoc.exists) {
        throw Exception('Invite not found');
      }

      final invite = FamilyInvite.fromJson(inviteDoc.data()!);

      // Validate invite can still be used
      if (!invite.canBeUsed) {
        throw Exception('Invite cannot be used');
      }

      // Get family reference
      final familyRef = _firestore.collection('families').doc(invite.familyId);
      final familyDoc = await tx.get(familyRef);
      
      if (!familyDoc.exists) {
        throw Exception('Family not found');
      }

      final family = models.Family.fromJson(familyDoc.data()!);

      // Check if family can accept new members
      if (!family.canAcceptMembers) {
        throw Exception('Family cannot accept new members');
      }

      // Update invite status
      final updatedInvite = invite.copyWith(
        status: InviteStatus.accepted,
        acceptedByUid: uid,
        acceptedAt: DateTime.now(),
        useCount: invite.useCount + 1,
      );
      tx.update(inviteRef, updatedInvite.toJson());

      // Add user to family
      final updatedMemberUids = List<String>.from(family.memberUids)..add(uid);
      final updatedRoles = Map<String, String>.from(family.roles)..[uid] = invite.role;
      
      tx.update(familyRef, {
        'memberUids': updatedMemberUids,
        'roles': updatedRoles,
      });

      // Update user profile with family ID and mark as onboarded
      final userRef = _firestore.collection('users').doc(uid);
      print('🔍 [DEBUG] Updating user profile: users/$uid');
      print('🔍 [DEBUG] Setting user data:');
      print('   - familyId: ${invite.familyId}');
      print('   - role: ${invite.role}');
      print('   - onboarded: true');
      print('   - displayName: $displayName');
      print('   - email: $email');
      
      tx.set(userRef, {
        'familyId': invite.familyId,
        'role': invite.role,
        'onboarded': true,
        'displayName': displayName,
        'email': email,
        'updatedAt': DateTime.now(),
      }, SetOptions(merge: true));
      
      print('✅ [DEBUG] User profile update transaction queued');

      // Remove any existing pending member records for this user
      // Since they're now an active family member, they're no longer "pending"
      print('🔍 [DEBUG] Removing existing pending member records for user: $uid');
      final pendingMembersQuery = _firestore.collection('pendingMembers')
          .where('email', isEqualTo: email)
          .where('familyId', isEqualTo: invite.familyId)
          .get();
      
      final pendingMembersSnapshot = await pendingMembersQuery;
      for (final doc in pendingMembersSnapshot.docs) {
        print('🔍 [DEBUG] Deleting pending member record: ${doc.id}');
        tx.delete(doc.reference);
      }
      
      print('✅ [DEBUG] Pending member cleanup completed');
    });
  }

  /// Revokes an invite (only family owners/parents can do this)
  Future<void> revokeInvite({
    required String inviteId,
    required String revokedByUid,
  }) async {
    await _firestore.runTransaction((tx) async {
      // Get the invite
      final inviteRef = _firestore.collection('invites').doc(inviteId);
      final inviteDoc = await tx.get(inviteRef);
      
      if (!inviteDoc.exists) {
        throw Exception('Invite not found');
      }

      final invite = FamilyInvite.fromJson(inviteDoc.data()!);

      // Get family to check permissions
      final familyRef = _firestore.collection('families').doc(invite.familyId);
      final familyDoc = await tx.get(familyRef);
      
      if (!familyDoc.exists) {
        throw Exception('Family not found');
      }

      final family = models.Family.fromJson(familyDoc.data()!);

      // Check if user can revoke invites
      if (!family.canCreateInvites(revokedByUid)) {
        throw Exception('You do not have permission to revoke invites');
      }

      // Update invite status
      final updatedInvite = invite.copyWith(
        status: InviteStatus.revoked,
      );
      tx.update(inviteRef, updatedInvite.toJson());
    });
  }

  /// Gets all active invites for a family
  Stream<List<FamilyInvite>> watchFamilyInvites(String familyId) {
    return _firestore
        .collection('invites')
        .where('familyId', isEqualTo: familyId)
        .where('status', isEqualTo: InviteStatus.active.name)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => FamilyInvite.fromJson(doc.data()))
            .where((invite) => invite.canBeUsed) // Filter out expired invites
            .toList());
  }

  /// Gets all pending members for a family
  Stream<List<PendingMember>> watchPendingMembers(String familyId) {
    return _firestore
        .collection('pendingMembers')
        .where('familyId', isEqualTo: familyId)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => PendingMember.fromJson(doc.data()))
            .toList());
  }

  /// Sends a reminder for a pending member
  Future<void> sendReminder(String pendingMemberId) async {
    final pendingMemberRef = _firestore.collection('pendingMembers').doc(pendingMemberId);
    
    await _firestore.runTransaction((tx) async {
      final doc = await tx.get(pendingMemberRef);
      if (!doc.exists) return;

      final pendingMember = PendingMember.fromJson(doc.data()!);
      final updatedMember = pendingMember.copyWith(
        reminderSent: true,
        lastReminderSentAt: DateTime.now(),
        reminderCount: pendingMember.reminderCount + 1,
      );

      tx.update(pendingMemberRef, updatedMember.toJson());
    });
  }

  /// Gets the current authenticated user
  Future<dynamic?> _getCurrentUser() async {
    // This would need to be implemented based on your auth system
    // For now, returning null - you'll need to integrate with your auth repository
    return null;
  }
}

/// Provider for the invite repository
final inviteRepositoryProvider = Provider<InviteRepository>((ref) {
  return InviteRepository();
});

/// Provider for watching family invites
final familyInvitesProvider = StreamProvider.family<List<FamilyInvite>, String>((ref, familyId) {
  ref.watch(authStateProvider);
  final repo = ref.watch(inviteRepositoryProvider);
  return repo.watchFamilyInvites(familyId);
});

/// Provider for watching pending members
final pendingMembersProvider = StreamProvider.family<List<PendingMember>, String>((ref, familyId) {
  ref.watch(authStateProvider);
  final repo = ref.watch(inviteRepositoryProvider);
  return repo.watchPendingMembers(familyId);
});

/// Provider for invite validation
final inviteValidationProvider = FutureProvider.family<InviteValidationResult, String>((ref, inviteCode) {
  final repo = ref.watch(inviteRepositoryProvider);
  return repo.validateInviteCode(inviteCode);
});

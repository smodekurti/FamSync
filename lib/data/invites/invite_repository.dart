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
    // First, validate that the user can create invites for this family
    final familyDoc = await _firestore.collection('families').doc(familyId).get();
    if (!familyDoc.exists) {
      throw Exception('Family not found');
    }
    
    final family = models.Family.fromJson(familyDoc.data()!);
    if (!family.canCreateInvites(createdByUid)) {
      throw Exception('You do not have permission to create invites for this family');
    }
    
    // Check if family can accept new members
    if (!family.canAcceptMembers) {
      if (family.memberUids.length >= family.maxMembers) {
        throw Exception('Family has reached its maximum member limit (${family.maxMembers})');
      } else if (!family.allowInvites) {
        throw Exception('Family has disabled new member invitations');
      } else {
        throw Exception('Family cannot accept new members at this time');
      }
    }

    // Generate unique invite code
    String inviteCode;
    bool isUnique = false;
    
    // Ensure invite code is unique
    do {
      inviteCode = _generateInviteCode();
      final existingInvite = await _firestore
          .collection('invites')
          .where('inviteCode', isEqualTo: inviteCode)
          .where('status', isEqualTo: InviteStatus.active.name)
          .get();
      isUnique = existingInvite.docs.isEmpty;
    } while (!isUnique);

    // Create invite document
    final doc = _firestore.collection('invites').doc();
    final invite = FamilyInvite.create(
      id: doc.id,
      familyId: familyId,
      inviteCode: inviteCode,
      createdByUid: createdByUid,
      role: role,
      maxUses: maxUses,
      daysUntilExpiry: daysUntilExpiry,
    );

    await doc.set(invite.toJson());
    return invite;
  }

  /// Validates an invite code and returns detailed information
  /// This is the core method for invite validation
  Future<InviteValidationResult> validateInviteCode(String inviteCode) async {
    try {
      // Find invite by code
      final inviteQuery = await _firestore
          .collection('invites')
          .where('inviteCode', isEqualTo: inviteCode)
          .limit(1)
          .get();

      if (inviteQuery.docs.isEmpty) {
        return InviteValidationResult.failure(
          errorMessage: 'Invalid invite code',
          errorType: InviteValidationError.invalidCode,
        );
      }

      final inviteDoc = inviteQuery.docs.first;
      final invite = FamilyInvite.fromJson(inviteDoc.data());

      // Check if invite is active
      if (invite.status != InviteStatus.active) {
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
      if (invite.isExpired) {
        return InviteValidationResult.failure(
          errorMessage: 'Invite has expired',
          errorType: InviteValidationError.expired,
          inviteId: invite.id,
        );
      }

      // Check if invite has been used up
      if (invite.useCount >= invite.maxUses) {
        return InviteValidationResult.failure(
          errorMessage: 'Invite has already been used',
          errorType: InviteValidationError.alreadyUsed,
          inviteId: invite.id,
        );
      }

      // Get family information
      final familyDoc = await _firestore
          .collection('families')
          .doc(invite.familyId)
          .get();

      if (!familyDoc.exists) {
        return InviteValidationResult.failure(
          errorMessage: 'Family not found',
          errorType: InviteValidationError.familyNotFound,
          inviteId: invite.id,
        );
      }

      final family = models.Family.fromJson(familyDoc.data()!);

      // Check if family is full
      if (!family.canAcceptMembers) {
        return InviteValidationResult.failure(
          errorMessage: 'Family has reached its member limit',
          errorType: InviteValidationError.familyFull,
          family: family,
          inviteId: invite.id,
        );
      }

      // Check if current user is already a member
      final currentUser = await _getCurrentUser();
      if (currentUser != null && family.memberUids.contains(currentUser.uid)) {
        return InviteValidationResult.failure(
          errorMessage: 'You are already a member of this family',
          errorType: InviteValidationError.alreadyMember,
          family: family,
          inviteId: invite.id,
          isAlreadyMember: true,
        );
      }

      // Success - invite is valid
      return InviteValidationResult.success(
        family: family,
        inviteId: invite.id,
      );
    } catch (e) {
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

      // Create pending member record for tracking
      final pendingMemberRef = _firestore.collection('pendingMembers').doc();
      final pendingMember = PendingMember.fromInvite(
        id: pendingMemberRef.id,
        inviteId: inviteId,
        email: email,
        displayName: displayName,
        familyId: invite.familyId,
        invitedByUid: invite.createdByUid,
        role: invite.role,
      );
      tx.set(pendingMemberRef, pendingMember.toJson());
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

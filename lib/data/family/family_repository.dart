import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fam_sync/domain/models/family.dart' as models;
import 'package:fam_sync/data/auth/auth_repository.dart';

/// Custom exception for family creation validation errors
class FamilyValidationException implements Exception {
  final String message;
  final FamilyValidationError errorType;

  const FamilyValidationException(this.message, this.errorType);

  @override
  String toString() => message;
}

/// Enum for different types of validation errors
enum FamilyValidationError {
  nameTooShort,
  nameTooLong,
  nameContainsInvalidChars,
  nameAlreadyExists,
  invalidOwnerUid,
}

class FamilyRepository {
  FamilyRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  // Constants for validation
  static const int _minNameLength = 2;
  static const int _maxNameLength = 50;
  static final RegExp _validNamePattern = RegExp(r'^[a-zA-Z0-9\s\-_\.]+$');

  Stream<models.Family?> watchFamily(String? familyId) async* {
    if (familyId == null || familyId.isEmpty) {
      yield null;
      return;
    }
    yield* _firestore.collection('families').doc(familyId).snapshots().map((doc) {
      final data = doc.data();
      return doc.exists && data != null ? models.Family.fromJson(data) : null;
    });
  }

  /// Creates a new family with comprehensive validation
  /// 
  /// This method performs the following validations:
  /// - Name length (2-50 characters)
  /// - Name format (alphanumeric, spaces, hyphens, underscores, dots only)
  /// - Duplicate checking (case-insensitive)
  /// - Owner UID validation
  Future<String> createFamily({required String name, required String ownerUid}) async {
    // Validate input parameters
    if (ownerUid.isEmpty) {
      throw const FamilyValidationException(
        'Owner UID cannot be empty',
        FamilyValidationError.invalidOwnerUid,
      );
    }

    // Validate and normalize the family name
    final normalizedName = _validateAndNormalizeName(name);

    // Check for duplicate names (case-insensitive)
    await _checkForDuplicateName(normalizedName);

    // Create the family document
    final doc = _firestore.collection('families').doc();
    final family = models.Family.create(
      id: doc.id,
      name: normalizedName,
      ownerUid: ownerUid,
    );

    // Save to Firestore
    await doc.set(family.toJson());
    return doc.id;
  }

  /// Validates and normalizes the family name
  /// 
  /// Performs the following checks:
  /// - Length validation (2-50 characters)
  /// - Character validation (alphanumeric, spaces, hyphens, underscores, dots)
  /// - Trims whitespace and normalizes spacing
  String _validateAndNormalizeName(String name) {
    // Trim whitespace and normalize spacing
    final trimmedName = name.trim();
    
    // Check minimum length
    if (trimmedName.length < _minNameLength) {
      throw const FamilyValidationException(
        'Family name must be at least $_minNameLength characters long',
        FamilyValidationError.nameTooShort,
      );
    }

    // Check maximum length
    if (trimmedName.length > _maxNameLength) {
      throw const FamilyValidationException(
        'Family name cannot exceed $_maxNameLength characters',
        FamilyValidationError.nameTooLong,
      );
    }

    // Check for valid characters
    if (!_validNamePattern.hasMatch(trimmedName)) {
      throw const FamilyValidationException(
        'Family name can only contain letters, numbers, spaces, hyphens, underscores, and dots',
        FamilyValidationError.nameContainsInvalidChars,
      );
    }

    // Normalize spacing (replace multiple spaces with single space)
    final normalizedName = trimmedName.replaceAll(RegExp(r'\s+'), ' ');

    return normalizedName;
  }

  /// Checks for duplicate family names (case-insensitive)
  /// 
  /// This method queries Firestore to ensure no family with the same
  /// normalized name already exists. The check is case-insensitive
  /// to prevent confusion between similar names.
  Future<void> _checkForDuplicateName(String normalizedName) async {
    try {
      // Query for families with the same normalized name (case-insensitive)
      final querySnapshot = await _firestore
          .collection('families')
          .where('nameNormalized', isEqualTo: normalizedName.toLowerCase())
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        throw FamilyValidationException(
          'A family with the name "$normalizedName" already exists. Please choose a different name.',
          FamilyValidationError.nameAlreadyExists,
        );
      }
    } catch (e) {
      // If the query fails due to missing index or other issues,
      // fall back to a more comprehensive check
      if (e is! FamilyValidationException) {
        await _fallbackDuplicateCheck(normalizedName);
      } else {
        rethrow;
      }
    }
  }

  /// Fallback duplicate checking method
  /// 
  /// This method is used when the indexed query fails. It performs
  /// a more comprehensive check by fetching all families and comparing
  /// names locally. This is less efficient but provides a backup
  /// validation method.
  Future<void> _fallbackDuplicateCheck(String normalizedName) async {
    try {
      final querySnapshot = await _firestore
          .collection('families')
          .get();

      for (final doc in querySnapshot.docs) {
        final familyName = doc.data()['name'] as String?;
        if (familyName != null && 
            familyName.toLowerCase() == normalizedName.toLowerCase()) {
          throw FamilyValidationException(
            'A family with the name "$normalizedName" already exists. Please choose a different name.',
            FamilyValidationError.nameAlreadyExists,
          );
        }
      }
    } catch (e) {
      if (e is FamilyValidationException) {
        rethrow;
      }
      // If fallback check also fails, log the error but allow creation
      // This prevents blocking family creation due to technical issues
      print('Warning: Could not perform duplicate name check: $e');
    }
  }

  /// Updates the family name with validation
  /// 
  /// This method allows updating an existing family's name while
  /// maintaining the same validation rules as creation.
  Future<void> updateFamilyName({
    required String familyId,
    required String newName,
    required String requesterUid,
  }) async {
    // Validate the new name
    final normalizedName = _validateAndNormalizeName(newName);

    // Check for duplicates (excluding the current family)
    await _checkForDuplicateNameExcluding(familyId, normalizedName);

    // Update the family name
    await _firestore.collection('families').doc(familyId).update({
      'name': normalizedName,
      'nameNormalized': normalizedName.toLowerCase(), // For case-insensitive queries
    });
  }

  /// Checks for duplicate names excluding a specific family ID
  /// 
  /// This method is used when updating family names to ensure
  /// the new name doesn't conflict with other families.
  Future<void> _checkForDuplicateNameExcluding(String excludeFamilyId, String normalizedName) async {
    try {
      final querySnapshot = await _firestore
          .collection('families')
          .where('nameNormalized', isEqualTo: normalizedName.toLowerCase())
          .get();

      for (final doc in querySnapshot.docs) {
        if (doc.id != excludeFamilyId) {
          throw FamilyValidationException(
            'A family with the name "$normalizedName" already exists. Please choose a different name.',
            FamilyValidationError.nameAlreadyExists,
          );
        }
      }
    } catch (e) {
      if (e is FamilyValidationException) {
        rethrow;
      }
      // If query fails, perform fallback check
      await _fallbackDuplicateCheckExcluding(excludeFamilyId, normalizedName);
    }
  }

  /// Fallback duplicate check excluding specific family ID
  Future<void> _fallbackDuplicateCheckExcluding(String excludeFamilyId, String normalizedName) async {
    try {
      final querySnapshot = await _firestore
          .collection('families')
          .get();

      for (final doc in querySnapshot.docs) {
        if (doc.id != excludeFamilyId) {
          final familyName = doc.data()['name'] as String?;
          if (familyName != null && 
              familyName.toLowerCase() == normalizedName.toLowerCase()) {
            throw FamilyValidationException(
              'A family with the name "$normalizedName" already exists. Please choose a different name.',
              FamilyValidationError.nameAlreadyExists,
            );
          }
        }
      }
    } catch (e) {
      if (e is FamilyValidationException) {
        rethrow;
      }
      print('Warning: Could not perform duplicate name check: $e');
    }
  }

  Future<void> joinFamily({required String familyId, required String uid, required String role}) async {
    final ref = _firestore.collection('families').doc(familyId);
    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final data = snap.data() ?? <String, dynamic>{};
      final memberUids = List<String>.from((data['memberUids'] as List?) ?? const <String>[]);
      final roles = Map<String, String>.from((data['roles'] as Map?) ?? const <String, String>{});
      if (!memberUids.contains(uid)) memberUids.add(uid);
      roles[uid] = role;
      tx.update(ref, {'memberUids': memberUids, 'roles': roles});
    });
  }
}

final familyRepositoryProvider = Provider<FamilyRepository>((ref) => FamilyRepository());

final familyStreamProvider = StreamProvider.family<models.Family?, String>((ref, familyId) {
  // Watch auth state to ensure this provider gets invalidated when auth changes
  ref.watch(authStateProvider);
  final repo = ref.watch(familyRepositoryProvider);
  return repo.watchFamily(familyId);
});



import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fam_sync/domain/models/user_profile.dart';
import 'package:fam_sync/data/auth/auth_repository.dart';

class UsersRepository {
  UsersRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<UserProfile>> watchFamilyUsers(String familyId) {
    return _firestore
        .collection('users')
        .where('familyId', isEqualTo: familyId)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => UserProfile.fromJson(d.data()))
            .toList());
  }
}

final usersRepositoryProvider = Provider<UsersRepository>((ref) {
  return UsersRepository();
});

final familyUsersProvider =
    StreamProvider.family<List<UserProfile>, String>((ref, familyId) {
  // Watch auth state to ensure this provider gets invalidated when auth changes
  ref.watch(authStateProvider);
  final repo = ref.watch(usersRepositoryProvider);
  return repo.watchFamilyUsers(familyId);
});



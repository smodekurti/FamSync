import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fam_sync/domain/models/family.dart' as models;
import 'package:fam_sync/data/auth/auth_repository.dart';

class FamilyRepository {
  FamilyRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

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

  Future<String> createFamily({required String name, required String ownerUid}) async {
    final doc = _firestore.collection('families').doc();
    final family = models.Family(
      id: doc.id,
      name: name,
      memberUids: [ownerUid],
      roles: {ownerUid: 'parent'},
    );
    await doc.set(family.toJson());
    return doc.id;
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



import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fam_sync/domain/models/message.dart';
import 'package:fam_sync/data/auth/auth_repository.dart';

class MessagesRepository {
  MessagesRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _collection(String familyId) =>
      _firestore.collection('families').doc(familyId).collection('messages');

  Stream<List<Message>> watchMessages(String familyId, {int? limit}) {
    Query<Map<String, dynamic>> query = _collection(familyId)
        .orderBy('createdAt', descending: true);
    if (limit != null) query = query.limit(limit);
    return query.snapshots().map((snap) =>
        snap.docs.map((d) => Message.fromJson({...d.data(), 'id': d.id})).toList());
  }

  Future<void> addMessage({
    required String familyId,
    required String text,
    required String authorUid,
    required String authorName,
    String? authorPhotoUrl,
  }) async {
    final now = DateTime.now();
    await _collection(familyId).add({
      'text': text,
      'authorUid': authorUid,
      'authorName': authorName,
      if (authorPhotoUrl != null) 'authorPhotoUrl': authorPhotoUrl,
      'createdAt': Timestamp.fromDate(now),
    });
  }

  Future<void> deleteMessage({required String familyId, required String id}) async {
    await _collection(familyId).doc(id).delete();
  }
}

final messagesRepositoryProvider = Provider<MessagesRepository>((ref) {
  return MessagesRepository();
});

final messagesStreamProvider = StreamProvider.family<List<Message>, String>((ref, familyId) {
  // Watch auth state to ensure this provider gets invalidated when auth changes
  ref.watch(authStateProvider);
  final repo = ref.watch(messagesRepositoryProvider);
  return repo.watchMessages(familyId);
});



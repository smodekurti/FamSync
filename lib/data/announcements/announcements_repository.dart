import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fam_sync/data/auth/auth_repository.dart';
import 'package:fam_sync/domain/models/announcement.dart';

class AnnouncementsRepository {
  AnnouncementsRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _collection(String familyId) =>
      _firestore
          .collection('families')
          .doc(familyId)
          .collection('announcements');

  Stream<List<Announcement>> watchAnnouncements(String familyId, {int? limit}) {
    Query<Map<String, dynamic>> query = _collection(
      familyId,
    ).orderBy('createdAt', descending: true);
    if (limit != null) query = query.limit(limit);
    return query.snapshots().map(
      (snap) => snap.docs
          .map((d) => Announcement.fromJson({...d.data(), 'id': d.id}))
          .toList(),
    );
  }

  Future<void> addAnnouncement({
    required String familyId,
    required String text,
    required String authorUid,
    required String authorName,
  }) async {
    final now = DateTime.now();
    await _collection(familyId).add({
      'text': text,
      'authorUid': authorUid,
      'authorName': authorName,
      'createdAt': Timestamp.fromDate(now),
    });
  }

  Future<void> deleteAnnouncement({
    required String familyId,
    required String id,
  }) async {
    await _collection(familyId).doc(id).delete();
  }
}

final announcementsRepositoryProvider = Provider<AnnouncementsRepository>((
  ref,
) {
  return AnnouncementsRepository();
});

/// Current user's profile; use to resolve familyId and author info
final currentUserProfileProvider = userProfileStreamProvider;

final announcementsStreamProvider =
    StreamProvider.family<List<Announcement>, String>((ref, familyId) {
      final repo = ref.watch(announcementsRepositoryProvider);
      return repo.watchAnnouncements(familyId);
    });

final recentAnnouncementsProvider =
    StreamProvider.family<List<Announcement>, String>((ref, familyId) {
      final repo = ref.watch(announcementsRepositoryProvider);
      return repo.watchAnnouncements(familyId, limit: 50);
    });

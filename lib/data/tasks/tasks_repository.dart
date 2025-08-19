import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fam_sync/domain/models/task.dart';

class TasksRepository {
  TasksRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _collection(String familyId) =>
      _firestore.collection('families').doc(familyId).collection('tasks');

  Stream<List<Task>> watchTasks(String familyId) {
    final query = _collection(familyId)
        .orderBy('completed')
        .orderBy('priority', descending: true)
        .orderBy('dueDate')
        .orderBy('createdAt', descending: true);
    return query.snapshots().map((snap) => snap.docs
        .map((d) => Task.fromJson({...d.data(), 'id': d.id}))
        .toList());
  }

  Future<void> addTask({
    required String familyId,
    required String title,
    String notes = '',
    List<String> assignedUids = const [],
    TaskPriority priority = TaskPriority.medium,
    DateTime? dueDate,
  }) async {
    final now = DateTime.now();
    await _collection(familyId).add({
      'title': title,
      'notes': notes,
      'assignedUids': assignedUids,
      'priority': priority.name,
      'dueDate': dueDate == null ? null : Timestamp.fromDate(dueDate),
      'completed': false,
      'createdAt': Timestamp.fromDate(now),
    });
  }

  Future<void> toggleCompleted({
    required String familyId,
    required String id,
    required bool completed,
  }) async {
    await _collection(familyId).doc(id).update({'completed': completed});
  }

  Future<void> deleteTask({required String familyId, required String id}) async {
    await _collection(familyId).doc(id).delete();
  }
}

final tasksRepositoryProvider = Provider<TasksRepository>((ref) {
  return TasksRepository();
});

final tasksStreamProvider = StreamProvider.family<List<Task>, String>((ref, familyId) {
  final repo = ref.watch(tasksRepositoryProvider);
  return repo.watchTasks(familyId);
});



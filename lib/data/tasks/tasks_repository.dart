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
    // To avoid composite index requirements, fetch by createdAt only and sort client-side.
    final query = _collection(familyId).orderBy('createdAt', descending: true);
    return query.snapshots().map((snap) {
      final items = snap.docs
          .map((d) => Task.fromJson({...d.data(), 'id': d.id}))
          .toList();
      int weight(TaskPriority p) {
        switch (p) {
          case TaskPriority.high:
            return 3;
          case TaskPriority.medium:
            return 2;
          case TaskPriority.low:
            return 1;
        }
      }
      items.sort((a, b) {
        // Incomplete first
        if (a.completed != b.completed) return a.completed ? 1 : -1;
        // Priority high -> low
        final pw = weight(b.priority).compareTo(weight(a.priority));
        if (pw != 0) return pw;
        // Due date earliest first; nulls last
        if (a.dueDate == null && b.dueDate != null) return 1;
        if (a.dueDate != null && b.dueDate == null) return -1;
        if (a.dueDate != null && b.dueDate != null) {
          final dd = a.dueDate!.compareTo(b.dueDate!);
          if (dd != 0) return dd;
        }
        // Newest created first
        return b.createdAt.compareTo(a.createdAt);
      });
      return items;
    });
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



import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fam_sync/domain/models/task.dart';
import 'package:fam_sync/data/auth/auth_repository.dart';

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
      final List<Task> items = [];
      for (final d in snap.docs) {
        try {
          final data = d.data();
          final title = (data['title'] as String?)?.trim() ?? '';
          if (title.isEmpty) {
            // Skip legacy/invalid docs without a title
            continue;
          }
          // Backwards compatibility: if 'notes' missing, map 'description'
          final mapped = {
            ...data,
            if ((data['notes'] == null ||
                    (data['notes'] as String?)?.isEmpty == true) &&
                data['description'] is String)
              'notes': data['description'],
            'id': d.id,
          };
          items.add(Task.fromJson(mapped));
        } catch (_) {
          // Skip malformed docs
          continue;
        }
      }
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
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) {
      throw ArgumentError('Task title must not be empty');
    }
    await _collection(familyId).add({
      'title': trimmedTitle,
      'notes': notes,
      'description': notes, // duplicate for explicit description column
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

  Future<void> deleteTask({
    required String familyId,
    required String id,
  }) async {
    await _collection(familyId).doc(id).delete();
  }

  Future<void> seedSampleTasks({
    required String familyId,
    List<String> assignTo = const <String>[],
  }) async {
    final now = DateTime.now();
    final List<Future<void>> writes = [];
    writes.add(
      addTask(
        familyId: familyId,
        title: 'Bring groceries from store',
        notes: 'Milk, eggs, bread, bananas',
        assignedUids: assignTo,
        priority: TaskPriority.medium,
        dueDate: now.add(const Duration(hours: 2)),
      ),
    );
    writes.add(
      addTask(
        familyId: familyId,
        title: 'Soccer practice drop-off',
        notes: 'Cleats, water bottle, jersey',
        assignedUids: assignTo,
        priority: TaskPriority.high,
        dueDate: DateTime(now.year, now.month, now.day, 18, 0),
      ),
    );
    writes.add(
      addTask(
        familyId: familyId,
        title: 'Morning standup',
        notes: 'Quick sync with team',
        assignedUids: assignTo,
        priority: TaskPriority.low,
        dueDate: DateTime(now.year, now.month, now.day, 9, 15),
      ),
    );
    await Future.wait(writes);
  }
}

final tasksRepositoryProvider = Provider<TasksRepository>((ref) {
  return TasksRepository();
});

final tasksStreamProvider = StreamProvider.family<List<Task>, String>((
  ref,
  familyId,
) {
  // Watch auth state to ensure this provider gets invalidated when auth changes
  ref.watch(authStateProvider);
  final repo = ref.watch(tasksRepositoryProvider);
  return repo.watchTasks(familyId);
});

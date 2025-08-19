import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fam_sync/theme/app_theme.dart';
import 'package:fam_sync/data/auth/auth_repository.dart';
import 'package:fam_sync/data/tasks/tasks_repository.dart';
import 'package:fam_sync/domain/models/task.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  final TextEditingController _title = TextEditingController();
  TaskPriority _priority = TaskPriority.medium;

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spaces = context.spaces;
    final profileAsync = ref.watch(userProfileStreamProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Tasks & Chores')),
      body: profileAsync.when(
        data: (profile) {
          final familyId = profile?.familyId;
          if (familyId == null) {
            return const Center(child: Text('No family context.'));
          }
          final tasksAsync = ref.watch(tasksStreamProvider(familyId));
          return tasksAsync.when(
            data: (items) => ListView.separated(
              padding: EdgeInsets.all(spaces.md),
              separatorBuilder: (_, __) => const Divider(),
              itemCount: items.length,
              itemBuilder: (_, i) {
                final t = items[i];
                return CheckboxListTile(
                  value: t.completed,
                  onChanged: (v) => ref.read(tasksRepositoryProvider).toggleCompleted(
                        familyId: familyId,
                        id: t.id,
                        completed: v ?? false,
                      ),
                  title: Text(t.title),
                  subtitle: Text(_subtitleForTask(t)),
                  secondary: _priorityIcon(t.priority),
                );
              },
            ),
            error: (e, _) => Center(child: Text('Error: $e')),
            loading: () => const Center(child: CircularProgressIndicator()),
          );
        },
        error: (e, _) => Center(child: Text('Error: $e')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskSheet(context),
        child: const Icon(Icons.add_task),
      ),
    );
  }

  String _subtitleForTask(Task t) {
    final parts = <String>[];
    if (t.dueDate != null) parts.add('Due: ${t.dueDate}');
    if (t.assignedUids.isNotEmpty) parts.add('Assigned: ${t.assignedUids.length}');
    return parts.isEmpty ? 'No details' : parts.join(' • ');
  }

  Icon _priorityIcon(TaskPriority p) {
    switch (p) {
      case TaskPriority.low:
        return const Icon(Icons.flag_outlined, color: Colors.green);
      case TaskPriority.medium:
        return const Icon(Icons.flag_outlined, color: Colors.orange);
      case TaskPriority.high:
        return const Icon(Icons.flag, color: Colors.red);
    }
  }

  Future<void> _showAddTaskSheet(BuildContext context) async {
    _title.clear();
    _priority = TaskPriority.medium;
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (ctx) {
        final spaces = ctx.spaces;
        return Padding(
          padding: EdgeInsets.fromLTRB(spaces.md, spaces.md, spaces.md, MediaQuery.of(ctx).viewInsets.bottom + spaces.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('New Task', style: Theme.of(ctx).textTheme.titleMedium),
              SizedBox(height: spaces.sm),
              TextField(
                controller: _title,
                decoration: const InputDecoration(labelText: 'Title'),
                onChanged: (_) => setState(() {}),
              ),
              SizedBox(height: spaces.sm),
              SegmentedButton<TaskPriority>(
                segments: const [
                  ButtonSegment(value: TaskPriority.low, label: Text('Low'), icon: Icon(Icons.arrow_downward)),
                  ButtonSegment(value: TaskPriority.medium, label: Text('Med'), icon: Icon(Icons.drag_handle)),
                  ButtonSegment(value: TaskPriority.high, label: Text('High'), icon: Icon(Icons.arrow_upward)),
                ],
                selected: {_priority},
                onSelectionChanged: (s) => setState(() => _priority = s.first),
              ),
              SizedBox(height: spaces.md),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _title.text.trim().isEmpty ? null : () async {
                        final profile = ref.read(userProfileStreamProvider).value;
                        final fid = profile?.familyId;
                        if (fid == null) return;
                        await ref.read(tasksRepositoryProvider).addTask(
                              familyId: fid,
                              title: _title.text.trim(),
                              priority: _priority,
                            );
                        if (mounted) Navigator.pop(ctx);
                      },
                      child: const Text('Add Task'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}



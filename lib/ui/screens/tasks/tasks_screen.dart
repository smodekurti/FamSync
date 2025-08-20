import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fam_sync/theme/app_theme.dart';
import 'package:fam_sync/data/auth/auth_repository.dart';
import 'package:fam_sync/data/tasks/tasks_repository.dart';
import 'package:fam_sync/domain/models/task.dart';
import 'package:fam_sync/data/users/users_repository.dart';
import 'package:fam_sync/domain/models/user_profile.dart';
import 'package:fam_sync/core/utils/time.dart';
import 'package:fam_sync/ui/widgets/family_app_bar_title.dart';
import 'package:fam_sync/ui/appbar/fam_app_bar_scaffold.dart';
import 'package:fam_sync/ui/strings.dart';
import 'package:fam_sync/ui/icons.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  final TextEditingController _title = TextEditingController();
  TaskPriority _priority = TaskPriority.medium;
  String? _assigneeUid;
  DateTime? _dueDate;
  TaskPriority? _filterPriority; // null = All

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spaces = context.spaces;
    final profileAsync = ref.watch(userProfileStreamProvider);
    return FamAppBarScaffold(
      title: const FamilyAppBarTitle(fallback: AppStrings.tasksTitle),
      fixedActions: const [
        Icon(AppIcons.reminder),
        SizedBox(width: 8),
        Icon(AppIcons.add),
        SizedBox(width: 8),
        Icon(AppIcons.profile),
      ],
      extraActions: const [],
      headerBuilder: (context, controller) => _PriorityFilterBar(
        selected: _filterPriority,
        onChanged: (p) => setState(() => _filterPriority = p),
      ),
      body: profileAsync.when(
        data: (profile) {
          final familyId = profile?.familyId;
          if (familyId == null) {
            return const Center(child: Text('No family context.'));
          }
          final tasksAsync = ref.watch(tasksStreamProvider(familyId));
          final usersAsync = ref.watch(familyUsersProvider(familyId));
          return usersAsync.when(
            data: (users) {
              final uidToName = <String, String>{
                for (final u in users) u.uid: u.displayName,
              };
              final currentUid = profile?.uid;
              return tasksAsync.when(
                data: (items) {
                  final filtered = _filterPriority == null
                      ? items
                      : items
                            .where((t) => t.priority == _filterPriority)
                            .toList();
                  return ListView.separated(
                    shrinkWrap: true,
                    primary: false,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.only(
                      left: spaces.md,
                      right: spaces.md,
                      top: spaces.sm,
                      bottom: spaces.md,
                    ),
                    separatorBuilder: (_, __) => const Divider(),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final t = filtered[i];
                      final assigneeChips = _assigneeChips(
                        t.assignedUids,
                        uidToName,
                        currentUid,
                      );
                      return CheckboxListTile(
                        value: t.completed,
                        onChanged: (v) => ref
                            .read(tasksRepositoryProvider)
                            .toggleCompleted(
                              familyId: familyId,
                              id: t.id,
                              completed: v ?? false,
                            ),
                        title: Text(t.title),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_subtitleForTask(t, uidToName, currentUid)),
                            if (assigneeChips.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 6,
                                runSpacing: -8,
                                children: assigneeChips,
                              ),
                            ],
                          ],
                        ),
                        secondary: _priorityIcon(t.priority),
                      );
                    },
                  );
                },
                error: (e, _) => Center(child: Text('Error: $e')),
                loading: () => const Center(child: CircularProgressIndicator()),
              );
            },
            error: (e, _) => Center(child: Text('Members error: $e')),
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

  String _subtitleForTask(
    Task t,
    Map<String, String> uidToName,
    String? currentUid,
  ) {
    final parts = <String>[];
    if (t.dueDate != null) parts.add('Due: ${formatDateTime(t.dueDate!)}');
    if (t.assignedUids.isNotEmpty) {
      final firstUid = t.assignedUids.first;
      final firstName = firstUid == currentUid
          ? 'You'
          : (uidToName[firstUid] ?? 'Member');
      final extra = t.assignedUids.length - 1;
      parts.add('Assigned: ${extra > 0 ? '$firstName +$extra' : firstName}');
    }
    return parts.isEmpty ? 'No details' : parts.join(' • ');
  }

  List<Widget> _assigneeChips(
    List<String> uids,
    Map<String, String> uidToName,
    String? currentUid,
  ) {
    return uids.map((uid) {
      final name = uid == currentUid ? 'You' : (uidToName[uid] ?? 'Member');
      final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
      return Chip(
        visualDensity: VisualDensity.compact,
        avatar: CircleAvatar(
          radius: 10,
          child: Text(initial, style: const TextStyle(fontSize: 11)),
        ),
        label: Text(name),
      );
    }).toList();
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
    _assigneeUid = null;
    _dueDate = null;
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (ctx) {
        final spaces = ctx.spaces;
        final familyId = ref.read(userProfileStreamProvider).value?.familyId;
        final AsyncValue<List<UserProfile>> usersAsync = familyId == null
            ? const AsyncValue<List<UserProfile>>.data(<UserProfile>[]) // empty
            : ref.watch(familyUsersProvider(familyId));
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                spaces.md,
                spaces.md,
                spaces.md,
                MediaQuery.of(ctx).viewInsets.bottom + spaces.md,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('New Task', style: Theme.of(ctx).textTheme.titleMedium),
                  SizedBox(height: spaces.sm),
                  TextField(
                    controller: _title,
                    decoration: const InputDecoration(labelText: 'Title'),
                    onChanged: (_) => setModalState(() {}),
                  ),
                  SizedBox(height: spaces.sm),
                  usersAsync.when(
                    data: (users) => DropdownButtonFormField<String?>(
                      value: _assigneeUid,
                      isExpanded: true,
                      hint: const Text('Assign to (optional)'),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Unassigned'),
                        ),
                        ...users.map(
                          (u) => DropdownMenuItem<String?>(
                            value: u.uid,
                            child: Text(u.displayName),
                          ),
                        ),
                      ],
                      onChanged: (String? val) =>
                          setModalState(() => _assigneeUid = val),
                    ),
                    error: (e, _) => Text('Members error: $e'),
                    loading: () => const LinearProgressIndicator(minHeight: 2),
                  ),
                  SizedBox(height: spaces.sm),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final now = DateTime.now();
                            final picked = await showDatePicker(
                              context: ctx,
                              initialDate: _dueDate ?? now,
                              firstDate: now.subtract(const Duration(days: 1)),
                              lastDate: now.add(const Duration(days: 365 * 3)),
                            );
                            if (picked != null)
                              setModalState(() => _dueDate = picked);
                          },
                          icon: const Icon(Icons.event),
                          label: Text(
                            _dueDate == null
                                ? 'Pick due date'
                                : 'Due: ${formatDate(_dueDate!)}',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _dueDate == null
                              ? null
                              : () async {
                                  final now = TimeOfDay.now();
                                  final picked = await showTimePicker(
                                    context: ctx,
                                    initialTime: now,
                                  );
                                  if (picked != null && _dueDate != null) {
                                    final d = _dueDate!;
                                    setModalState(
                                      () => _dueDate = DateTime(
                                        d.year,
                                        d.month,
                                        d.day,
                                        picked.hour,
                                        picked.minute,
                                      ),
                                    );
                                  }
                                },
                          icon: const Icon(Icons.schedule),
                          label: Text(
                            _dueDate == null ? 'Pick time' : 'Time set',
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: spaces.sm),
                  SegmentedButton<TaskPriority>(
                    segments: const [
                      ButtonSegment(
                        value: TaskPriority.low,
                        label: Text('Low'),
                        icon: Icon(Icons.arrow_downward),
                      ),
                      ButtonSegment(
                        value: TaskPriority.medium,
                        label: Text('Med'),
                        icon: Icon(Icons.drag_handle),
                      ),
                      ButtonSegment(
                        value: TaskPriority.high,
                        label: Text('High'),
                        icon: Icon(Icons.arrow_upward),
                      ),
                    ],
                    selected: {_priority},
                    onSelectionChanged: (s) =>
                        setModalState(() => _priority = s.first),
                  ),
                  SizedBox(height: spaces.md),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _title.text.trim().isEmpty
                              ? null
                              : () async {
                                  final profile = ref
                                      .read(userProfileStreamProvider)
                                      .value;
                                  final fid = profile?.familyId;
                                  if (fid == null) return;
                                  await ref
                                      .read(tasksRepositoryProvider)
                                      .addTask(
                                        familyId: fid,
                                        title: _title.text.trim(),
                                        priority: _priority,
                                        assignedUids: _assigneeUid == null
                                            ? const []
                                            : <String>[_assigneeUid!],
                                        dueDate: _dueDate,
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
      },
    );
  }
}

class _PriorityFilterBar extends StatelessWidget {
  const _PriorityFilterBar({required this.selected, required this.onChanged});
  final TaskPriority? selected;
  final ValueChanged<TaskPriority?> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          FilterChip(
            label: const Text(AppStrings.filterAll),
            selected: selected == null,
            onSelected: (_) => onChanged(null),
          ),
          const SizedBox(width: 8),
          FilterChip(
            avatar: const Icon(AppIcons.priorityHigh, size: 16),
            label: const Text(AppStrings.filterHigh),
            selected: selected == TaskPriority.high,
            onSelected: (_) => onChanged(TaskPriority.high),
          ),
          const SizedBox(width: 8),
          FilterChip(
            avatar: const Icon(AppIcons.priorityMedium, size: 16),
            label: const Text(AppStrings.filterMedium),
            selected: selected == TaskPriority.medium,
            onSelected: (_) => onChanged(TaskPriority.medium),
          ),
          const SizedBox(width: 8),
          FilterChip(
            avatar: const Icon(AppIcons.priorityLow, size: 16),
            label: const Text(AppStrings.filterLow),
            selected: selected == TaskPriority.low,
            onSelected: (_) => onChanged(TaskPriority.low),
          ),
        ],
      ),
    );
  }
}

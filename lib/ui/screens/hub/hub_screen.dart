import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fam_sync/theme/app_theme.dart';
// tokens not directly used here; styling via theme/context extensions
import 'package:fam_sync/data/auth/auth_repository.dart';
import 'package:fam_sync/data/announcements/announcements_repository.dart';
import 'package:fam_sync/data/messages/messages_repository.dart';
import 'package:fam_sync/data/tasks/tasks_repository.dart';
import 'package:fam_sync/domain/models/task.dart';
import 'package:fam_sync/core/utils/time.dart';
import 'package:fam_sync/data/users/users_repository.dart';
import 'package:fam_sync/ui/appbar/fam_app_bar_scaffold.dart';
import 'package:fam_sync/ui/widgets/family_app_bar_title.dart';
import 'package:fam_sync/ui/strings.dart';
import 'package:fam_sync/ui/icons.dart';

class HubScreen extends ConsumerWidget {
  const HubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spaces = context.spaces;
    final layout = context.layout; // reserved for future responsive tweaks
    return FamAppBarScaffold(
      title: const FamilyAppBarTitle(fallback: 'Family'),
      expandedHeight: 240,
      fixedActions: const [
        Icon(AppIcons.reminder),
        SizedBox(width: 16),
        Icon(AppIcons.add),
        SizedBox(width: 16),
        Icon(AppIcons.profile),
        SizedBox(width: 8),
      ],
      headerBuilder: (context, controller) => _TopStrip(),
      body: LayoutBuilder(
      builder: (context, constraints) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _TodayTimelineCard(),
              SizedBox(height: spaces.md),
              _ActionablesCard(),
              SizedBox(height: spaces.md),
              _AnnouncementsMessagesRow(),
              SizedBox(height: spaces.md),
              _LogisticsRow(),
              SizedBox(height: spaces.lg),
              _ShortcutsDock(),
            ],
          );
        },
      ),
    );
  }
}

// Old generic card no longer used after redesign; keeping UI-specific cards below

// Replaces bespoke SliverAppBar; header content now supplied via FamAppBarScaffold

// Header content replaced with _TopStrip in FamAppBarScaffold

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });
  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      color: colors.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.outlineVariant),
      ),
      elevation: 1,
      clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: EdgeInsets.all(context.spaces.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: colors.primary),
                SizedBox(width: context.spaces.sm),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: colors.onSurface),
                  ),
                ),
              ],
            ),
            SizedBox(height: context.spaces.md),
            SizedBox(height: context.spaces.sm),
            child,
          ],
        ),
      ),
    );
  }
}

class _AnnouncementsList extends ConsumerWidget {
  const _AnnouncementsList({required this.onOpen});
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileStreamProvider);
    return profileAsync.when(
      data: (profile) {
        final familyId = profile?.familyId;
        if (familyId == null) {
          return const Center(child: Text(AppStrings.joinFamilyToSeeAnnouncements));
        }
        final recent = ref.watch(recentAnnouncementsProvider(familyId));
        return recent.when(
          data: (items) => items.isEmpty
              ? const Center(child: Text(AppStrings.noAnnouncementsYet))
              : Column(
                  children: [
                    for (final a in items.take(3))
                      Padding(
                        padding: EdgeInsets.only(bottom: context.spaces.sm),
                        child: ListTile(
                          tileColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          title: Text(
                            '${a.authorName}: ${a.text}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(formatRelativeTime(a.createdAt)),
                          onTap: onOpen,
                        ),
                      ),
                  ],
                ),
          error: (e, _) => Text('Error: $e'),
          loading: () => const Center(child: CircularProgressIndicator()),
        );
      },
      error: (e, _) => Text('Error: $e'),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}

// Removed unused placeholders in favor of compact sections

class _TopStrip extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spaces = context.spaces;
    final dateStr = formatHeaderDate(DateTime.now());
    final profileAsync = ref.watch(userProfileStreamProvider);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                dateStr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                    ),
              ),
              const SizedBox(height: 1),
              Text(
                AppStrings.headerSubtitlePlaceholder,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                    ),
              ),
            ],
          ),
        ),
        SizedBox(width: spaces.md),
        // Make trailing avatars scrollable to avoid horizontal overflow
        profileAsync.when(
          data: (profile) {
            final familyId = profile?.familyId;
            if (familyId == null) return const SizedBox.shrink();
            final usersAsync = ref.watch(familyUsersProvider(familyId));
            return usersAsync.when(
              data: (users) => SizedBox(
                height: 32,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemBuilder: (_, i) {
                    final u = users[i];
                    final label = u.displayName.isNotEmpty ? u.displayName[0] : '?';
                    return CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.white24,
                      child: Text(label, style: const TextStyle(color: Colors.white)),
                    );
                  },
                  separatorBuilder: (_, __) => SizedBox(width: spaces.xs),
                  itemCount: users.length.clamp(0, 6),
                ),
              ),
              error: (_, __) => const SizedBox.shrink(),
              loading: () => const SizedBox.shrink(),
            );
          },
          error: (_, __) => const SizedBox.shrink(),
          loading: () => const SizedBox.shrink(),
        ),
      ],
    );
  }
}

// _TwoColumn previously used for split layouts; no longer needed in single column

class _TodayTimelineCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final spaces = context.spaces;
    final sizes = context.sizes;
    return Card(
      color: colors.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.outlineVariant),
      ),
      elevation: 1,
      child: Padding(
        padding: EdgeInsets.all(spaces.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.schedule),
                SizedBox(width: spaces.sm),
                Text(AppStrings.todayTitle, style: Theme.of(context).textTheme.titleLarge),
                const Spacer(),
                TextButton(onPressed: () {}, child: const Text(AppStrings.showAll)),
              ],
            ),
            SizedBox(height: spaces.md),
            _NowNextStrip(),
            SizedBox(height: spaces.md),
            _TasksTimelinePreview(),
          ],
        ),
      ),
    );
  }
}

class _NowNextStrip extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileStreamProvider);
    final spaces = context.spaces;
    final colors = Theme.of(context).colorScheme;
    Widget pill(String label, {Color? color}) => Container(
          padding: EdgeInsets.symmetric(horizontal: spaces.sm, vertical: spaces.xs),
          decoration: BoxDecoration(
            color: (color ?? colors.primary).withOpacity(0.12),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: color ?? colors.primary,
                ),
          ),
        );
    return profileAsync.when(
      data: (profile) {
        final familyId = profile?.familyId;
        if (familyId == null) return const SizedBox.shrink();
        final tasksAsync = ref.watch(tasksStreamProvider(familyId));
        return tasksAsync.when(
          data: (tasks) {
            final now = DateTime.now();
            final candidates = tasks
                .where((t) => !t.completed && t.dueDate != null)
                .toList()
              ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
            if (candidates.isEmpty) return const SizedBox.shrink();
            final overdue = candidates.where((t) => t.dueDate!.isBefore(now)).toList();
            final upcoming = candidates.where((t) => !t.dueDate!.isBefore(now)).toList();
            final nowTask = overdue.isNotEmpty ? overdue.last : (upcoming.isNotEmpty ? upcoming.first : null);
            Task? nextTask;
            if (nowTask != null) {
              final base = nowTask.dueDate!;
              nextTask = candidates.firstWhere(
                (t) => t.dueDate!.isAfter(base),
                orElse: () => nowTask,
              );
              if (identical(nextTask, nowTask)) nextTask = null;
            }
            return Row(
              children: [
                if (nowTask != null) ...[
                  pill(AppStrings.todayNow),
                  SizedBox(width: spaces.sm),
                  Expanded(
                    child: Text(
                      '${formatTime(nowTask.dueDate!)} • ${nowTask.title}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                if (nextTask != null) ...[
                  SizedBox(width: spaces.md),
                  pill(AppStrings.todayNext, color: colors.secondary),
                  SizedBox(width: spaces.sm),
                  Expanded(
                    child: Text(
                      '${formatTime(nextTask.dueDate!)} • ${nextTask.title}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            );
          },
          loading: () => const SizedBox(height: 24, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
          error: (e, _) => Text('Error: $e'),
        );
      },
      loading: () => const SizedBox(height: 24, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
      error: (e, _) => Text('Error: $e'),
    );
  }
}

class _TasksTimelinePreview extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileStreamProvider);
    final spaces = context.spaces;
    return profileAsync.when(
      data: (profile) {
        final familyId = profile?.familyId;
        if (familyId == null) {
          return const Text(AppStrings.noFamilyContext);
        }
        final tasksAsync = ref.watch(tasksStreamProvider(familyId));
        return tasksAsync.when(
          data: (tasks) {
            // Build a lightweight timeline from tasks due today or overdue
            final now = DateTime.now();
            bool isSameDay(DateTime a, DateTime b) =>
                a.year == b.year && a.month == b.month && a.day == b.day;
            final items = tasks
                .where((t) => !t.completed && t.dueDate != null)
                .where((t) => isSameDay(t.dueDate!, now) || t.dueDate!.isBefore(now))
                .toList()
              ..sort((a, b) {
                final ad = a.dueDate!;
                final bd = b.dueDate!;
                return ad.compareTo(bd);
              });
            if (items.isEmpty) {
              return const Text(AppStrings.todayTimelinePlaceholder);
            }
            return Column(
              children: [
                for (final t in items.take(4))
                  Padding(
                    padding: EdgeInsets.only(bottom: spaces.sm),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 68,
                          child: Text(
                            formatTime(t.dueDate!),
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(t.title,
                                  maxLines: 1, overflow: TextOverflow.ellipsis),
                              if (t.notes.isNotEmpty)
                                Text(
                                  t.notes,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
          loading: () => const SizedBox(height: 60, child: Center(child: CircularProgressIndicator())),
          error: (e, _) => Text('Error: $e'),
        );
      },
      loading: () => const SizedBox(height: 60, child: Center(child: CircularProgressIndicator())),
      error: (e, _) => Text('Error: $e'),
    );
  }
}

class _ActionablesCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileStreamProvider);
    final colors = Theme.of(context).colorScheme;
    final spaces = context.spaces;
    return Card(
      color: colors.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.outlineVariant),
      ),
      elevation: 1,
      child: Padding(
        padding: EdgeInsets.all(spaces.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.task_alt),
                SizedBox(width: spaces.sm),
                Text(AppStrings.actionablesTitle, style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            SizedBox(height: spaces.md),
            profileAsync.when(
              data: (profile) {
                final familyId = profile?.familyId;
                if (familyId == null) return const Text(AppStrings.noFamilyContext);
                final tasksAsync = ref.watch(tasksStreamProvider(familyId));
                return tasksAsync.when(
                  data: (tasks) {
                    final today = DateTime.now();
                    final todayTasks = tasks.where((t) =>
                        !t.completed && (t.dueDate == null ||
                            (t.dueDate!.year == today.year && t.dueDate!.month == today.month && t.dueDate!.day == today.day)))
                        .take(3)
                        .toList();
                    if (todayTasks.isEmpty) return const Text(AppStrings.noTasksYet);
                    return Column(
                      children: [
                        for (final t in todayTasks)
                          ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.check_box_outline_blank),
                            title: Text(t.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                            subtitle: t.dueDate != null ? Text(formatDateTime(t.dueDate!)) : null,
                          ),
                      ],
                    );
                  },
                  loading: () => const SizedBox(height: 48, child: Center(child: CircularProgressIndicator())),
                  error: (e, _) => Text('Error: $e'),
                );
              },
              loading: () => const SizedBox(height: 48, child: Center(child: CircularProgressIndicator())),
              error: (e, _) => Text('Error: $e'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnnouncementsMessagesRow extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spaces = context.spaces;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionCard(
          title: AppStrings.announcementsTitle,
          icon: Icons.campaign,
          child: _AnnouncementsList(onOpen: () => context.go('/announcements')),
        ),
        SizedBox(height: spaces.md),
        _SectionCard(
          title: AppStrings.messagesTitle,
          icon: Icons.message,
          child: _RecentMessages(onOpen: () => context.go('/messages')),
        ),
      ],
    );
  }
}

class _RecentMessages extends ConsumerWidget {
  const _RecentMessages({required this.onOpen});
  final VoidCallback onOpen;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileStreamProvider);
    return profileAsync.when(
      data: (profile) {
        final familyId = profile?.familyId;
        if (familyId == null) return const Center(child: Text(AppStrings.noFamilyContext));
        final stream = ref.watch(messagesStreamProvider(familyId));
        return stream.when(
          data: (messages) {
            if (messages.isEmpty) return const Center(child: Text(AppStrings.noMessagesYet));
            return Column(
              children: [
                for (final m in messages.take(3))
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(m.authorName, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(m.text, maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: Text(formatRelativeTime(m.createdAt)),
                    onTap: onOpen,
                  ),
              ],
            );
          },
          loading: () => const SizedBox(height: 48, child: Center(child: CircularProgressIndicator())),
          error: (e, _) => Text('Error: $e'),
        );
      },
      loading: () => const SizedBox(height: 48, child: Center(child: CircularProgressIndicator())),
      error: (e, _) => Text('Error: $e'),
    );
  }
}

class _LogisticsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final spaces = context.spaces;
    final isCompact = context.layout.isSmall;
    final children = <Widget>[
      Expanded(
        child: _MiniInfoCard(
          leading: const Icon(Icons.list_alt),
          title: AppStrings.shoppingShortTitle,
          subtitle: AppStrings.shoppingUrgentSummary,
          trailing: TextButton(
            onPressed: () {},
            child: const Text(AppStrings.showAll),
          ),
        ),
      ),
      SizedBox(width: spaces.md),
      Expanded(
        child: _MiniInfoCard(
          leading: const Icon(Icons.local_shipping_outlined),
          title: AppStrings.deliveriesShortTitle,
          subtitle: AppStrings.deliveriesNextSummary,
        ),
      ),
    ];
    if (isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [children[0]]),
          SizedBox(height: spaces.md),
          Row(children: [children[2]]),
        ],
      );
    }
    return Row(children: children);
  }
}

class _MiniInfoCard extends StatelessWidget {
  const _MiniInfoCard({
    required this.leading,
    required this.title,
    required this.subtitle,
    this.trailing,
  });
  final Widget leading;
  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final spaces = context.spaces;
    return Card(
      color: colors.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.outlineVariant),
      ),
      elevation: 1,
      child: Padding(
        padding: EdgeInsets.all(spaces.lg),
        child: Row(
          children: [
            leading,
            SizedBox(width: spaces.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: spaces.xs),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[
              SizedBox(width: spaces.sm),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

class _ShortcutsDock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final spaces = context.spaces;
    return Wrap(
      spacing: spaces.md,
      runSpacing: spaces.sm,
      children: const [
        _ShortcutChip(icon: Icons.directions_run, label: AppStrings.onMyWay),
        _ShortcutChip(icon: Icons.add_task, label: AppStrings.newTask),
        _ShortcutChip(icon: Icons.event, label: AppStrings.newEvent),
        _ShortcutChip(icon: Icons.playlist_add, label: AppStrings.addListItem),
      ],
    );
  }
}

class _ShortcutChip extends StatelessWidget {
  const _ShortcutChip({required this.icon, required this.label});
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: context.sizes.iconSm),
      label: Text(label),
      onPressed: () {},
    );
  }
}

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
          return const Center(
            child: Text(AppStrings.joinFamilyToSeeAnnouncements),
          );
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
                          tileColor: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
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
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 1),
              Text(
                AppStrings.headerSubtitlePlaceholder,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.white70),
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
                    final label = u.displayName.isNotEmpty
                        ? u.displayName[0]
                        : '?';
                    return CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.white24,
                      child: Text(
                        label,
                        style: const TextStyle(color: Colors.white),
                      ),
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
                Text(
                  AppStrings.todayTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {},
                  child: const Text(AppStrings.showAll),
                ),
              ],
            ),
            SizedBox(height: spaces.md),
            _TodayTimeline(),
          ],
        ),
      ),
    );
  }
}

class _TodayTimeline extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileStreamProvider);
    
    return profileAsync.when(
      data: (profile) {
        final familyId = profile?.familyId;
        if (familyId == null) {
          return const Text('No family context');
        }
        
        final tasksAsync = ref.watch(tasksStreamProvider(familyId));
        final usersAsync = ref.watch(familyUsersProvider(familyId));
        
        return tasksAsync.when(
          data: (tasks) {
            return usersAsync.when(
              data: (users) {
                // Filter tasks for today and upcoming
                final now = DateTime.now();
                final today = DateTime(now.year, now.month, now.day);
                final tomorrow = today.add(const Duration(days: 1));
                
                final todayTasks = tasks.where((task) => 
                  !task.completed && 
                  task.dueDate != null &&
                  task.dueDate!.isAfter(today.subtract(const Duration(days: 1))) &&
                  task.dueDate!.isBefore(tomorrow)
                ).toList();
                
                // Sort by due time
                todayTasks.sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
                
                if (todayTasks.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'No tasks scheduled for today',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  );
                }
                
                // Convert tasks to timeline events
                final events = todayTasks.take(6).map((task) {
                  final assignedUsers = users.where((user) => 
                    task.assignedUids.contains(user.uid)
                  ).toList();
                  
                  final participants = assignedUsers.map((user) {
                    final name = user.displayName.isNotEmpty 
                        ? user.displayName 
                        : 'Unknown';
                    return name.length > 2 ? name.substring(0, 2).toUpperCase() : name.toUpperCase();
                  }).toList();
                  
                  // Generate color based on position and priority for better visual variety
                  Color getTaskColor(int index) {
                    // Use specific colors for first few events to match the image
                    if (index == 0) return Colors.green; // First event: green
                    if (index == 1) return Colors.orange; // Second event: orange  
                    if (index == 2) return Colors.purple; // Third event: purple
                    
                    // For remaining events, use priority-based colors
                    switch (task.priority) {
                      case TaskPriority.high:
                        return Colors.red;
                      case TaskPriority.medium:
                        return Colors.orange;
                      case TaskPriority.low:
                        return Colors.green;
                      default:
                        return Colors.blue;
                    }
                  }
                  
                  // Calculate time until due
                  String? getTimeUntil() {
                    final diff = task.dueDate!.difference(now);
                    if (diff.isNegative) {
                      final mins = diff.inMinutes.abs();
                      if (mins < 60) return '${mins}m overdue';
                      final hrs = diff.inHours.abs();
                      return '${hrs}h overdue';
                    }
                    final mins = diff.inMinutes;
                    if (mins < 60) return 'in ${mins}m';
                    final hrs = diff.inHours;
                    if (hrs < 24) return 'in ${hrs}h';
                    return null;
                  }
                  
                  // Determine status
                  EventStatus getStatus() {
                    if (task.completed) return EventStatus.confirmed;
                    if (task.dueDate!.isBefore(now)) return EventStatus.pending;
                    return EventStatus.upcoming;
                  }
                  
                  return _TimelineEvent(
                    time: formatTime(task.dueDate!),
                    duration: _formatDuration(task.dueDate!),
                    title: task.title,
                    details: task.notes.isNotEmpty ? task.notes : 'No description',
                    color: getTaskColor(todayTasks.indexOf(task)),
                    participants: participants,
                    status: getStatus(),
                    timeUntil: getTimeUntil(),
                    isStriped: task.priority == TaskPriority.high,
                  );
                }).toList();
                
                // Make timeline scrollable if more than 3 items
                if (events.length <= 3) {
                  return Column(
                    children: [
                      for (int i = 0; i < events.length; i++)
                        _TimelineEventCard(
                          event: events[i],
                          isLast: i == events.length - 1,
                        ),
                    ],
                  );
                } else {
                  // Scrollable timeline for more than 3 items
                  return Container(
                    height: 320, // Fixed height for 3 items + some padding
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          for (int i = 0; i < events.length; i++)
                            _TimelineEventCard(
                              event: events[i],
                              isLast: i == events.length - 1,
                            ),
                        ],
                      ),
                    ),
                  );
                }
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => Text('Error loading users: $error'),
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stack) => Text('Error loading tasks: $error'),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Text('Error loading profile: $error'),
    );
  }
  
  String _formatDuration(DateTime dueDate) {
    // For now, return a placeholder duration
    // In a real app, you'd calculate this from start/end times
    return '1h';
  }
}

class _TimelineEvent {
  const _TimelineEvent({
    required this.time,
    required this.duration,
    required this.title,
    required this.details,
    required this.color,
    required this.participants,
    required this.status,
    this.timeUntil,
    this.isStriped = false,
  });

  final String time;
  final String duration;
  final String title;
  final String details;
  final Color color;
  final List<String> participants;
  final EventStatus status;
  final String? timeUntil;
  final bool isStriped;
}

enum EventStatus { upcoming, confirmed, pending }

class _TimelineEventCard extends StatelessWidget {
  const _TimelineEventCard({
    required this.event,
    required this.isLast,
  });

  final _TimelineEvent event;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final spaces = context.spaces;
    final colors = Theme.of(context).colorScheme;
    
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : spaces.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vertical colored bar
          Container(
            width: 4,
            height: 100, // Increased height for better proportions
            decoration: BoxDecoration(
              color: event.color,
              borderRadius: BorderRadius.circular(2),
            ),
            child: event.isStriped
                ? CustomPaint(
                    painter: _StripedPainter(color: event.color),
                  )
                : null,
          ),
          SizedBox(width: spaces.md),
          
          // Time and duration column with pill above
          SizedBox(
            width: 80, // Fixed width for consistent alignment
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (event.timeUntil != null) ...[
                  // Time until pill positioned above time
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: spaces.sm,
                      vertical: spaces.xs,
                    ),
                    decoration: BoxDecoration(
                      color: event.color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      event.timeUntil!,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: event.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: spaces.xs),
                ],
                // Time text
                Text(
                  event.time,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                ),
                SizedBox(height: spaces.xs),
                // Duration text
                Text(
                  event.duration,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: spaces.md),
          
          // Event content - no container, direct layout
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event title
                Text(
                  event.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                  ),
                ),
                SizedBox(height: spaces.xs),
                // Event details
                Text(
                  event.details,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: spaces.sm),
                
                // Bottom row with avatars and action button
                Row(
                  children: [
                    // Participant avatars
                    Expanded(
                      child: Row(
                        children: [
                          for (int i = 0; i < event.participants.length; i++)
                            Padding(
                              padding: EdgeInsets.only(left: i == 0 ? 0 : spaces.xs),
                              child: _ParticipantAvatar(
                                participant: event.participants[i],
                                status: event.status,
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Action button (plus icon)
                    Container(
                      width: 24,
                      height: 24,
                                              decoration: BoxDecoration(
                          color: Colors.pink.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                      child: const Icon(
                        Icons.add,
                        size: 16,
                        color: Colors.pink,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ParticipantAvatar extends StatelessWidget {
  const _ParticipantAvatar({
    required this.participant,
    required this.status,
  });

  final String participant;
  final EventStatus status;

  @override
  Widget build(BuildContext context) {
    // Generate consistent colors for initials
    final colorsList = [
      Colors.blue,
      Colors.red,
      Colors.teal,
      Colors.pink,
      Colors.orange,
      Colors.indigo,
    ];
    final colorIndex = participant.hashCode % colorsList.length;
    final backgroundColor = colorsList[colorIndex];
    
    return Stack(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: backgroundColor,
          child: Text(
            participant,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (status == EventStatus.confirmed)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: const Icon(
                Icons.check,
                size: 8,
                color: Colors.white,
              ),
            ),
          )
        else if (status == EventStatus.pending)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.grey,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: const Icon(
                Icons.question_mark,
                size: 8,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }
}

class _StripedPainter extends CustomPainter {
  const _StripedPainter({required this.color});
  
  final Color color;
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    
    final stripeWidth = 2.0;
    final stripeSpacing = 4.0;
    
    for (double y = 0; y < size.height; y += stripeSpacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(stripeWidth, y),
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant _StripedPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

IconData _iconForTask(TaskPriority p) {
  switch (p) {
    case TaskPriority.high:
      return Icons.priority_high_rounded;
    case TaskPriority.medium:
      return Icons.task_alt;
    case TaskPriority.low:
      return Icons.check_circle_outline;
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.timeText,
    required this.title,
    this.note,
    required this.assignees,
    required this.isLast,
    this.showDateCapsule = false,
    this.dotColor,
    this.leadingIcon,
  });
  final String timeText;
  final String title;
  final String? note;
  final List<dynamic>
  assignees; // List<UserProfile?>; kept dynamic to avoid extra imports here
  final bool isLast;
  final bool showDateCapsule;
  final Color? dotColor;
  final IconData? leadingIcon;

  @override
  Widget build(BuildContext context) {
    final spaces = context.spaces;
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : spaces.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showDateCapsule) ...[
            Container(
              width: 44,
              padding: EdgeInsets.symmetric(vertical: spaces.xs),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    formatMonthAbbrev(DateTime.now()),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  Text(
                    formatDayNumber(DateTime.now()),
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ],
              ),
            ),
            SizedBox(width: spaces.sm),
          ],
          // Rail + dot
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: dotColor ?? colors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: spaces.xxl,
                  color: (dotColor ?? colors.primary).withValues(alpha: 0.4),
                ),
            ],
          ),
          SizedBox(width: spaces.md),
          // Content card with neon-like outline
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: spaces.md,
                vertical: spaces.sm,
              ),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 16,
                    spreadRadius: 0,
                  ),
                ],
                border: Border.all(
                  color: colors.outlineVariant.withValues(alpha: 0.6),
                  width: 1.2,
                ),
              ),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Leading icon only, no decoration/container
                    Icon(leadingIcon ?? Icons.task_alt, size: 30),
                    SizedBox(width: spaces.sm),
                    // Two-line block: title on first, time + avatars on second
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                              ),
                              if (dotColor != null)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: spaces.sm,
                                    vertical: spaces.xs,
                                  ),
                                  decoration: BoxDecoration(
                                    color: (dotColor!).withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    dotColor == Colors.green
                                        ? AppStrings.todayNow
                                        : AppStrings.todayNext,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(color: dotColor),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: spaces.xs),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  timeText,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        color: colors.onSurfaceVariant,
                                      ),
                                ),
                              ),
                              if (assignees.isNotEmpty)
                                _AvatarRow(profiles: assignees),
                            ],
                          ),
                          if (note != null) ...[
                            SizedBox(height: spaces.xs),
                            Text(
                              note!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarRow extends StatelessWidget {
  const _AvatarRow({required this.profiles});
  final List<dynamic> profiles; // List<UserProfile?>
  @override
  Widget build(BuildContext context) {
    final spaces = context.spaces;
    final visible = profiles.take(3).toList();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < visible.length; i++)
          Padding(
            padding: EdgeInsets.only(left: i == 0 ? 0 : spaces.xs),
            child: _SmallAvatar(profile: visible[i]),
          ),
      ],
    );
  }
}

class _SmallAvatar extends StatelessWidget {
  const _SmallAvatar({this.profile});
  final dynamic profile; // UserProfile?
  @override
  Widget build(BuildContext context) {
    final String? photoUrl = profile?.photoUrl as String?;
    final String label = (profile?.displayName as String?)?.isNotEmpty == true
        ? (profile!.displayName as String).characters.first
        : '?';
    return CircleAvatar(
      radius: 10,
      backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
      child: photoUrl == null
          ? Text(label, style: const TextStyle(fontSize: 10))
          : null,
    );
  }
}

class _VerticalRailPainter extends CustomPainter {
  _VerticalRailPainter({required this.color, required this.strokeWidth});
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final start = Offset(0, 0);
    final end = Offset(0, size.height);
    canvas.drawLine(start, end, paint);
  }

  @override
  bool shouldRepaint(covariant _VerticalRailPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
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
                Text(
                  AppStrings.actionablesTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            SizedBox(height: spaces.md),
            profileAsync.when(
              data: (profile) {
                final familyId = profile?.familyId;
                if (familyId == null)
                  return const Text(AppStrings.noFamilyContext);
                final tasksAsync = ref.watch(tasksStreamProvider(familyId));
                return tasksAsync.when(
                  data: (tasks) {
                    final today = DateTime.now();
                    final todayTasks = tasks
                        .where(
                          (t) =>
                              !t.completed &&
                              (t.dueDate == null ||
                                  (t.dueDate!.year == today.year &&
                                      t.dueDate!.month == today.month &&
                                      t.dueDate!.day == today.day)),
                        )
                        .take(3)
                        .toList();
                    if (todayTasks.isEmpty)
                      return const Text(AppStrings.noTasksYet);
                    return Column(
                      children: [
                        for (final t in todayTasks)
                          ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.check_box_outline_blank),
                            title: Text(
                              t.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: t.dueDate != null
                                ? Text(formatDateTime(t.dueDate!))
                                : null,
                          ),
                      ],
                    );
                  },
                  loading: () => const SizedBox(
                    height: 48,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (e, _) => Text('Error: $e'),
                );
              },
              loading: () => const SizedBox(
                height: 48,
                child: Center(child: CircularProgressIndicator()),
              ),
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
        if (familyId == null)
          return const Center(child: Text(AppStrings.noFamilyContext));
        final stream = ref.watch(messagesStreamProvider(familyId));
        return stream.when(
          data: (messages) {
            if (messages.isEmpty)
              return const Center(child: Text(AppStrings.noMessagesYet));
            return Column(
              children: [
                for (final m in messages.take(3))
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(
                      m.authorName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      m.text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text(formatRelativeTime(m.createdAt)),
                    onTap: onOpen,
                  ),
              ],
            );
          },
          loading: () => const SizedBox(
            height: 48,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Text('Error: $e'),
        );
      },
      loading: () => const SizedBox(
        height: 48,
        child: Center(child: CircularProgressIndicator()),
      ),
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
            if (trailing != null) ...[SizedBox(width: spaces.sm), trailing!],
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

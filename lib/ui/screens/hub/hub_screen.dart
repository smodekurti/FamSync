import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fam_sync/theme/app_theme.dart';
import 'package:fam_sync/theme/tokens.dart';
import 'package:fam_sync/data/auth/auth_repository.dart';
import 'package:fam_sync/data/announcements/announcements_repository.dart';
import 'package:fam_sync/data/messages/messages_repository.dart';
import 'package:fam_sync/data/tasks/tasks_repository.dart';

import 'package:fam_sync/core/utils/time.dart';
import 'package:fam_sync/data/users/users_repository.dart';
import 'package:fam_sync/data/family/family_repository.dart';
import 'package:fam_sync/ui/appbar/seamless_app_bar_scaffold.dart';
import 'package:fam_sync/ui/widgets/hub_header_content.dart';
import 'package:fam_sync/ui/widgets/family_app_bar_title.dart';
import 'package:fam_sync/ui/strings.dart';
import 'package:fam_sync/ui/icons.dart';
import 'package:fam_sync/domain/models/announcement.dart';
import 'package:fam_sync/domain/models/task.dart';
import 'package:fam_sync/domain/models/user_profile.dart';

// Constants for responsive limits
const int maxDisplayUsers = 4;
const int maxRecentTasks = 5;
const int maxRecentAnnouncements = 3;
const int maxShortcutItems = 3;
const int maxAvatarDisplay = 6;

// Duration constants
const String durationLong = '1h';
const String durationMedium = '45m';
const String durationShort = '30m';
const String durationVeryShort = '15m';

class HubScreen extends ConsumerWidget {
  const HubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spaces = context.spaces;
    final profileAsync = ref.watch(userProfileStreamProvider);
    
    return SeamlessAppBarScaffold(
      title: const FamilyAppBarTitle(fallback: 'Family Hub'),
      expandedHeight: MediaQuery.of(context).size.height * 0.18, // Compact header height (~18% of screen)
      actions: [
        const Icon(AppIcons.reminder),
        SizedBox(width: spaces.sm),
      ],
      headerContent: HubHeaderContent(
        userName: profileAsync.when(
          data: (profile) => profile?.displayName,
          loading: () => null,
          error: (_, __) => null,
        ),
        showNotificationBadge: true,
        onNotificationTap: () {
          // TODO: Implement notification handling
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Notifications coming soon!')),
          );
        },
      ),
      gradientColors: AppGradients.hubSeamlessLight,
      contentOverlap: 40.0, // Reduced overlap for more natural integration
      body: Column(
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
      ),
    );
  }
}

class _TopStrip extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spaces = context.spaces;
    final layout = context.layout;
    final dateStr = formatHeaderDate(DateTime.now());
    final profileAsync = ref.watch(userProfileStreamProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top row with date and meaningful family info
        Row(
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
                                    SizedBox(height: spaces.xs / 4), // Reduced spacing to fit better
                  // Meaningful family information
                  profileAsync.when(
                    data: (profile) {
                      final familyId = profile?.familyId;
                      if (familyId == null) return const SizedBox.shrink();
                      
                      final familyAsync = ref.watch(familyStreamProvider(familyId));
                      final usersAsync = ref.watch(familyUsersProvider(familyId));
                      
                      return Row(
                        children: [
                          familyAsync.when(
                            data: (family) => Text(
                              family?.name ?? 'Family',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.white70,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            loading: () => Text(
                              'Loading...',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.white60,
                              ),
                            ),
                            error: (_, __) => const SizedBox.shrink(),
                          ),
                          SizedBox(width: spaces.sm),
                          // Member avatars placed right next to family name
                          usersAsync.when(
                            data: (users) => Row(
                              mainAxisSize: MainAxisSize.min,
                              children: users.take(maxAvatarDisplay).map((user) {
                                final label = user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : '?';
                                return Padding(
                                  padding: EdgeInsets.only(left: spaces.xs),
                                  child: CircleAvatar(
                                    radius: layout.isSmall ? spaces.md : spaces.lg, // Bigger avatars
                                    backgroundColor: Colors.white24,
                                    child: Text(
                                      label,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: layout.isSmall ? 14 : 16, // Bigger font sizes
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            loading: () => const SizedBox.shrink(),
                            error: (_, __) => const SizedBox.shrink(),
                          ),
                        ],
                      );
                    },
                    loading: () => Text(
                      'Loading family...',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white60,
                      ),
                    ),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ],
        ),
        

      ],
    );
  }
}

class _TodayTimelineCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final spaces = context.spaces;
    final profileAsync = ref.watch(userProfileStreamProvider);
    
    return Card(
      color: colors.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(spaces.lg),
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
                  onPressed: () => context.go('/calendar'),
                  child: const Text(AppStrings.showAll),
                ),
              ],
            ),
            SizedBox(height: spaces.md),
            profileAsync.when(
              data: (profile) {
                final familyId = profile?.familyId;
                if (familyId == null) {
                  return const Center(child: Text('No family context.'));
                }
                
                return _TimelineContent(familyId: familyId);
              },
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineContent extends ConsumerWidget {
  const _TimelineContent({required this.familyId});
  final String familyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentAnnouncementsAsync = ref.watch(recentAnnouncementsProvider(familyId));
    final tasksAsync = ref.watch(tasksStreamProvider(familyId));
    
    return Column(
      children: [
        // Today's Tasks with Timeline Design
        tasksAsync.when(
          data: (tasks) {
            final today = DateTime.now();
            final todayTasks = tasks.where((t) =>
                !t.completed && (t.dueDate == null ||
                    (t.dueDate!.year == today.year && t.dueDate!.month == today.month && t.dueDate!.day == today.day)))
                .take(maxRecentTasks)
                .toList();
            
            if (todayTasks.isEmpty) {
              return const SizedBox.shrink();
            }
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Today\'s Schedule',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: context.spaces.md),
                ...todayTasks.asMap().entries.map((entry) {
                  final index = entry.key;
                  final task = entry.value;
                  final isLast = index == todayTasks.length - 1;
                  return _TimelineTaskItem(
                    task: task,
                    isLast: isLast,
                    index: index,
                  );
                }),
              ],
            );
          },
          loading: () => const LinearProgressIndicator(),
          error: (e, _) => Text('Tasks error: $e'),
        ),
        
        // Recent Announcements
        recentAnnouncementsAsync.when(
          data: (announcements) {
            if (announcements.isEmpty) {
              return const SizedBox.shrink();
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: context.spaces.lg),
                Text(
                  'Recent Updates',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: context.spaces.sm),
                ...announcements.take(maxRecentAnnouncements).map((announcement) => _TimelineAnnouncementItem(announcement: announcement)),
              ],
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (e, _) => const SizedBox.shrink(),
        ),
        
        // Show message if no timeline items
        Builder(
          builder: (context) {
            final hasTasks = tasksAsync.value?.any((t) {
              final today = DateTime.now();
              return !t.completed && (t.dueDate == null ||
                  (t.dueDate!.year == today.year && t.dueDate!.month == today.month && t.dueDate!.day == today.day));
            }) ?? false;
            
            if (!hasTasks) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(context.spaces.lg),
                  child: Column(
                    children: [
                      Icon(
                        Icons.schedule_outlined,
                        size: context.spaces.xl * 2.4,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      SizedBox(height: context.spaces.sm),
                      Text(
                        'No activities for today',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}



class _TimelineAnnouncementItem extends StatelessWidget {
  const _TimelineAnnouncementItem({required this.announcement});
  final Announcement announcement;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final spaces = context.spaces;
    
    return Container(
      margin: EdgeInsets.only(bottom: spaces.sm),
      padding: EdgeInsets.all(spaces.sm),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(spaces.sm),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: spaces.xs,
            spreadRadius: spaces.xs / 8,
            offset: Offset(0, spaces.xs / 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Announcement icon with colored background
          Container(
            width: spaces.xl * 2,
            height: spaces.xl * 2,
            decoration: BoxDecoration(
              color: colors.secondary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(spaces.lg),
            ),
            child: Icon(
              Icons.announcement,
              color: colors.secondary,
              size: context.spaces.lg,
            ),
          ),
          
          SizedBox(width: spaces.md),
          
          // Announcement content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  announcement.text,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: spaces.xs),
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: context.spaces.md,
                      color: colors.onSurfaceVariant,
                    ),
                    SizedBox(width: spaces.xs),
                    Text(
                      announcement.authorName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: spaces.sm),
                    Icon(
                      Icons.access_time,
                      size: context.spaces.md,
                      color: colors.onSurfaceVariant,
                    ),
                    SizedBox(width: spaces.xs),
                    Text(
                      formatRelativeTime(announcement.createdAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
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

class _TimelineTaskItem extends StatelessWidget {
  const _TimelineTaskItem({
    required this.task,
    required this.isLast,
    required this.index,
  });
  
  final Task task;
  final bool isLast;
  final int index;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final spaces = context.spaces;
    
    // Generate consistent colors for different task types (matching the image)
    final timelineColors = [
      Colors.purple, // Purple for special meetings (like "Dan Putz/Vasu Weekly 1:1")
      Colors.green,  // Green for most events
      Colors.green,  // Green for most events
      Colors.green,  // Green for most events
      Colors.green,  // Green for most events
    ];
    final taskColor = timelineColors[index % timelineColors.length];
    
    // Calculate time and duration
    final now = DateTime.now();
    final dueTime = task.dueDate ?? now;
    final timeString = formatTime(dueTime);
    final durationString = _calculateDuration(task);
    
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : spaces.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time and Duration Column (Left) - clean and simple like the image
          SizedBox(
            width: context.layout.isSmall ? spaces.xl * 2.5 : spaces.xl * 3.5, // Adaptive width for different screen sizes
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  timeString,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                ),
                Text(
                  durationString,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(width: spaces.md),
          
          // Vertical Timeline Bar (Middle) - precise height to cover content
          Container(
            width: spaces.xs, // Responsive bar width
            height: _calculateDynamicBarHeight(task, context),
            decoration: BoxDecoration(
              color: taskColor,
              borderRadius: BorderRadius.circular(spaces.xs / 2),
            ),
          ),
          
          SizedBox(width: context.layout.isSmall ? spaces.md : spaces.lg),
          
          // Task Details (Right) - clean and simple like the image
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Task title - bold like in the image
                Text(
                  task.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                // Task details/notes - smaller text like location/type in image
                if (task.notes.isNotEmpty) ...[
                  SizedBox(height: spaces.xs),
                  Text(
                    task.notes,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                
                // Participant avatars below the description
                SizedBox(height: spaces.xs),
                _buildParticipants(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  String _calculateDuration(Task task) {
    // Calculate actual duration based on task data
    if (task.dueDate != null) {
      // If there's a due date, estimate duration based on task complexity
      if (task.notes.length > 100) return durationLong;
      if (task.notes.length > 50) return durationMedium;
      if (task.notes.length > 20) return durationShort;
      return durationVeryShort;
    }
    // Default duration for tasks without due dates
    return durationShort;
  }
  
  double _calculateDynamicBarHeight(Task task, BuildContext context) {
    // Calculate responsive bar height to cover content exactly like in the image
    final spaces = context.spaces;
    double baseHeight = spaces.lg * 2; // Responsive base height for title
    
    // Add height for notes if they exist
    if (task.notes.isNotEmpty) {
      if (task.notes.length > 50) {
        baseHeight += spaces.md; // Long notes
      } else if (task.notes.length > 20) {
        baseHeight += spaces.sm; // Medium notes
      } else {
        baseHeight += spaces.xs;  // Short notes
      }
    }
    
    // Add height for the participant avatars row
    baseHeight += spaces.lg; // Responsive space for avatars row
    
    return baseHeight;
  }
  

  
  Widget _buildParticipants() {
    // Show real participant information based on task data
    // Use task.assignedUids to show actual assignees
    return Consumer(
      builder: (context, ref, child) {
        // Get family members to show assignees
        final profileAsync = ref.watch(userProfileStreamProvider);
        return profileAsync.when(
          data: (profile) {
            final familyId = profile?.familyId;
            if (familyId == null) return const SizedBox.shrink();
            
            final usersAsync = ref.watch(familyUsersProvider(familyId));
            return usersAsync.when(
              data: (users) {
                if (users.isEmpty) return const SizedBox.shrink();
                
                // Filter users to only show assigned users (from task.assignedUids)
                final assignedUsers = users.where((user) => 
                    task.assignedUids.contains(user.uid)).toList();
                
                if (assignedUsers.isEmpty) return const SizedBox.shrink();
                
                // Show up to maxDisplayUsers assignee avatars with slight overlap
                final displayUsers = assignedUsers.take(maxDisplayUsers).toList();
                return SizedBox(
                  height: context.spaces.lg, // Responsive height for the Stack
                  child: Stack(
                    children: [
                      for (int i = 0; i < displayUsers.length; i++)
                        Positioned(
                          left: i * (context.layout.isSmall ? context.spaces.sm.toDouble() : context.spaces.md.toDouble()), // Adaptive overlap for different screen sizes
                          child: _buildFamilyMemberAvatar(displayUsers[i], context),
                        ),
                      // Show count of additional assignees if any
                      if (assignedUsers.length > maxDisplayUsers)
                        Positioned(
                          left: displayUsers.length * (context.layout.isSmall ? context.spaces.sm.toDouble() : context.spaces.md.toDouble()),
                          child: Container(
                            width: context.spaces.lg,
                            height: context.spaces.lg,
                            decoration: BoxDecoration(
                              color: Colors.grey.withValues(alpha: 0.3),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '+${assignedUsers.length - maxDisplayUsers}',
                                style: TextStyle(
                                  fontSize: context.spaces.sm,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        );
      },
    );
  }
  
  Widget _buildFamilyMemberAvatar(UserProfile user, BuildContext context) {
    // Generate consistent colors for family members
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
    ];
    final colorIndex = user.hashCode % colors.length;
    final avatarColor = colors[colorIndex];
    
    // Get initial from display name
    final initial = user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : '?';
    
    return Stack(
      children: [
        Container(
          width: context.spaces.lg,
          height: context.spaces.lg,
          decoration: BoxDecoration(
            color: avatarColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              initial,
              style: TextStyle(
                color: Colors.white,
                                            fontSize: context.spaces.sm,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        // Green checkmark overlay - responsive size
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
                                        width: context.spaces.sm,
                            height: context.spaces.sm,
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: context.spaces.xs / 4),
            ),
            child: Icon(
              Icons.check,
              size: context.spaces.xs,
              color: Colors.white,
            ),
          ),
        ),
      ],
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
        borderRadius: BorderRadius.circular(spaces.lg),
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
                  loading: () => SizedBox(height: context.spaces.xl * 1.5, child: const Center(child: CircularProgressIndicator())),
                  error: (e, _) => Text('Error: $e'),
                );
              },
              loading: () => SizedBox(height: context.spaces.xl * 1.5, child: const Center(child: CircularProgressIndicator())),
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
    return Row(
      children: [
        Expanded(
          child: _AnnouncementsCard(),
        ),
        SizedBox(width: spaces.md),
        Expanded(
          child: _MessagesCard(),
        ),
      ],
    );
  }
}

class _AnnouncementsCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final spaces = context.spaces;
    return Card(
      color: colors.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(spaces.lg),
        side: BorderSide(color: colors.outlineVariant),
      ),
      elevation: 1,
      child: InkWell(
        onTap: () => context.go('/announcements'),
        borderRadius: BorderRadius.circular(spaces.lg),
        child: Padding(
          padding: EdgeInsets.all(spaces.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.announcement),
                  SizedBox(width: spaces.sm),
                  Expanded(
                    child: Text(
                      AppStrings.announcementsTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: spaces.md),
              _AnnouncementsList(),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnnouncementsList extends ConsumerWidget {
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
                    for (final a in items.take(maxShortcutItems))
                      Padding(
                        padding: EdgeInsets.only(bottom: context.spaces.sm),
                        child: ListTile(
                          tileColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(context.spaces.sm),
                          ),
                          title: Text(
                            '${a.authorName}: ${a.text}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(formatRelativeTime(a.createdAt)),
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

class _MessagesCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final spaces = context.spaces;
    return Card(
      color: colors.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(spaces.lg),
        side: BorderSide(color: colors.outlineVariant),
      ),
      elevation: 1,
      child: InkWell(
        onTap: () => context.go('/messages'),
        borderRadius: BorderRadius.circular(spaces.lg),
        child: Padding(
          padding: EdgeInsets.all(spaces.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.message),
                  SizedBox(width: spaces.sm),
                  Expanded(
                    child: Text(
                      AppStrings.messagesTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: spaces.md),
              _MessagesList(),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessagesList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileStreamProvider);
    return profileAsync.when(
      data: (profile) {
        final familyId = profile?.familyId;
        if (familyId == null) {
          return const Center(child: Text(AppStrings.joinFamilyToSeeAnnouncements));
        }
        final recent = ref.watch(messagesStreamProvider(familyId));
        return recent.when(
          data: (items) => items.isEmpty
              ? const Center(child: Text(AppStrings.noMessagesYet))
              : Column(
                  children: [
                    for (final m in items.take(maxShortcutItems))
                      Padding(
                        padding: EdgeInsets.only(bottom: context.spaces.sm),
                        child: ListTile(
                          tileColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(context.spaces.sm),
                          ),
                          title: Text(
                            '${m.authorName}: ${m.text}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(formatRelativeTime(m.createdAt)),
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

class _LogisticsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final spaces = context.spaces;
    return Row(
      children: [
        Expanded(
          child: _ShoppingCard(),
        ),
        SizedBox(width: spaces.md),
        Expanded(
          child: _FinanceCard(),
        ),
      ],
    );
  }
}

class _ShoppingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final spaces = context.spaces;
    return Card(
      color: colors.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(spaces.lg),
        side: BorderSide(color: colors.outlineVariant),
      ),
      elevation: 1,
      child: InkWell(
        onTap: () => context.go('/shopping'),
        borderRadius: BorderRadius.circular(spaces.lg),
        child: Padding(
          padding: EdgeInsets.all(spaces.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.shopping_cart),
                  SizedBox(width: spaces.sm),
                  Expanded(
                    child: Text(
                      AppStrings.shoppingTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: spaces.md),
              const Text('Shopping list coming soon...'),
            ],
          ),
        ),
      ),
    );
  }
}

class _FinanceCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final spaces = context.spaces;
    return Card(
      color: colors.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(spaces.lg),
        side: BorderSide(color: colors.outlineVariant),
      ),
      elevation: 1,
      child: InkWell(
        onTap: () => context.go('/finance'),
        borderRadius: BorderRadius.circular(spaces.lg),
        child: Padding(
          padding: EdgeInsets.all(spaces.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.account_balance_wallet),
                  SizedBox(width: spaces.sm),
                  Expanded(
                    child: Text(
                      AppStrings.financeTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: spaces.md),
              const Text('Finance tracking coming soon...'),
            ],
          ),
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

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fam_sync/theme/app_theme.dart';
import 'package:fam_sync/theme/tokens.dart';
import 'package:fam_sync/data/auth/auth_repository.dart';
import 'package:fam_sync/data/announcements/announcements_repository.dart';
import 'package:fam_sync/core/utils/time.dart';
import 'package:fam_sync/data/users/users_repository.dart';
import 'package:fam_sync/ui/widgets/family_app_bar_title.dart';

class HubScreen extends ConsumerWidget {
  const HubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = context.layout.isSmall;
        final spaces = context.spaces;
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              _HubSliverAppBar(),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  spaces.md,
                  spaces.lg,
                  spaces.md,
                  spaces.md,
                ),
                sliver: SliverGrid.count(
                  crossAxisCount: isCompact ? 1 : 2,
                  crossAxisSpacing: spaces.md,
                  mainAxisSpacing: spaces.md,
                  children: [
                    _SectionCard(
                      title: 'Announcements',
                      icon: Icons.campaign,
                      child: _AnnouncementsList(
                        onOpen: () => context.go('/announcements'),
                      ),
                    ),
                    _SectionCard(
                      title: "Where's Everyone?",
                      icon: Icons.place,
                      child: _PresencePlaceholder(),
                    ),
                    _SectionCard(
                      title: 'Family Story',
                      icon: Icons.menu_book,
                      child: _FamilyStoryPlaceholder(),
                    ),
                    _SectionCard(
                      title: 'Messages',
                      icon: Icons.message,
                      child: _MessagesShortcut(
                        onOpen: () => context.go('/messages'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Old generic card no longer used after redesign; keeping UI-specific cards below

class _HubSliverAppBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final spaces = context.spaces;
    return SliverAppBar(
      pinned: true,
      floating: false,
      forceElevated: true,
      expandedHeight: 240,
      elevation: 0,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      scrolledUnderElevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      foregroundColor: Colors.white,
      actions: const [
        Icon(Icons.notifications_none, color: Colors.white),
        SizedBox(width: 16),
        Icon(Icons.add, color: Colors.white),
        SizedBox(width: 16),
        Icon(Icons.person_outline, color: Colors.white),
        SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        title: const FamilyAppBarTitle(fallback: 'Family'),
        titlePadding: const EdgeInsetsDirectional.only(start: 16, bottom: 12),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? AppGradients.hubHeaderDark
                  : AppGradients.hubHeaderLight,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x66000000),
                offset: Offset(0, 2),
                blurRadius: 12,
              ),
            ],
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              kToolbarHeight + spaces.md,
              16,
              spaces.lg,
            ),
            child: _HeaderBody(),
          ),
        ),
      ),
    );
  }
}

class _HeaderBody extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spaces = context.spaces;
    final dateStr = formatHeaderDate(DateTime.now());
    final profileAsync = ref.watch(userProfileStreamProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        profileAsync.when(
          data: (profile) {
            final familyId = profile?.familyId;
            if (familyId == null) return const SizedBox.shrink();
            final usersAsync = ref.watch(familyUsersProvider(familyId));
            return usersAsync.when(
              data: (users) => Row(
                children: users
                    .take(4)
                    .map(
                      (u) => Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.white24,
                          child: Text(
                            (u.displayName.isNotEmpty ? u.displayName[0] : '?'),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              error: (_, __) => const SizedBox.shrink(),
              loading: () => const SizedBox.shrink(),
            );
          },
          error: (_, __) => const SizedBox.shrink(),
          loading: () => const SizedBox.shrink(),
        ),
        SizedBox(height: spaces.lg),
        Text(
          dateStr,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 4),
        Text(
          "84°F | Dinner plan: Eating out 🍴",
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
        ),
        SizedBox(height: spaces.xl),
      ],
    );
  }
}

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
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: colors.onSurface),
                ),
              ],
            ),
            SizedBox(height: context.spaces.md),
            Expanded(child: child),
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
            child: Text('Join a family to see announcements.'),
          );
        }
        final recent = ref.watch(recentAnnouncementsProvider(familyId));
        return recent.when(
          data: (items) => items.isEmpty
              ? const Center(child: Text('No announcements yet'))
              : ListView.separated(
                  itemCount: items.length.clamp(0, 3),
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final a = items[i];
                    return ListTile(
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
                    );
                  },
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

class _PresencePlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Presence coming soon"));
  }
}

class _FamilyStoryPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Family Story coming soon"));
  }
}

class _MessagesShortcut extends StatelessWidget {
  const _MessagesShortcut({required this.onOpen});
  final VoidCallback onOpen;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: OutlinedButton.icon(
        onPressed: onOpen,
        icon: const Icon(Icons.message),
        label: const Text('Open Messages'),
      ),
    );
  }
}

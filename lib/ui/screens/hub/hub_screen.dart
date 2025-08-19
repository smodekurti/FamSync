import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fam_sync/theme/app_theme.dart';
import 'package:fam_sync/data/auth/auth_repository.dart';
import 'package:fam_sync/data/announcements/announcements_repository.dart';
import 'package:fam_sync/core/utils/time.dart';

class HubScreen extends ConsumerWidget {
  const HubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = context.layout.isSmall;
        final spaces = context.spaces;
        return Scaffold(
          appBar: AppBar(title: const Text('Family Hub')),
          body: Padding(
            padding: EdgeInsets.all(spaces.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: GridView.count(
                    crossAxisCount: isCompact ? 1 : 2,
                    mainAxisSpacing: spaces.md,
                    crossAxisSpacing: spaces.md,
                    children: [
                      _AnnouncementsCard(
                        onOpen: () => context.go('/announcements'),
                      ),
                      _HubCard(
                        title: 'Messages',
                        icon: Icons.message,
                        onTap: () => context.go('/messages'),
                      ),
                      const _HubCard(
                        title: 'Location',
                        icon: Icons.location_on,
                      ),
                      const _HubCard(title: 'Shortcuts', icon: Icons.flash_on),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HubCard extends StatelessWidget {
  const _HubCard({required this.title, required this.icon, this.onTap});

  final String title;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(context.spaces.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: context.sizes.iconLg),
              SizedBox(height: context.spaces.sm),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnnouncementsCard extends ConsumerWidget {
  const _AnnouncementsCard({required this.onOpen});
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spaces = context.spaces;
    final profileAsync = ref.watch(userProfileStreamProvider);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.all(context.spaces.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.campaign),
                    SizedBox(width: spaces.sm),
                    Text(
                      'Announcements',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                TextButton(onPressed: onOpen, child: const Text('Open')),
              ],
            ),
            SizedBox(height: spaces.sm),
            Expanded(
              child: profileAsync.when(
                data: (profile) {
                  final familyId = profile?.familyId;
                  if (familyId == null) {
                    return const Center(
                      child: Text('Join a family to see announcements.'),
                    );
                  }
                  final recent = ref.watch(
                    recentAnnouncementsProvider(familyId),
                  );
                  return recent.when(
                    data: (items) => items.isEmpty
                        ? const Center(child: Text('No announcements yet'))
                        : ListView.separated(
                            itemCount: items.length.clamp(0, 3),
                            separatorBuilder: (_, __) =>
                                const Divider(height: 16),
                            itemBuilder: (_, i) {
                              final a = items[i];
                              return ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                title: Text(
                                  a.text,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  '${a.authorName} • ${formatRelativeTime(a.createdAt)}',
                                ),
                              );
                            },
                          ),
                    error: (e, _) => Text('Error: $e'),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                  );
                },
                error: (e, _) => Text('Error: $e'),
                loading: () => const Center(child: CircularProgressIndicator()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

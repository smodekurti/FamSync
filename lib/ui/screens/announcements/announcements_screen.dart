import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fam_sync/data/announcements/announcements_repository.dart';
import 'package:fam_sync/data/auth/auth_repository.dart';
import 'package:fam_sync/domain/models/announcement.dart';
import 'package:fam_sync/theme/app_theme.dart';
import 'package:fam_sync/core/utils/time.dart';

class AnnouncementsScreen extends ConsumerStatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  ConsumerState<AnnouncementsScreen> createState() =>
      _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends ConsumerState<AnnouncementsScreen> {
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spaces = context.spaces;
    final profileAsync = ref.watch(userProfileStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Announcements')),
      body: profileAsync.when(
        data: (profile) {
          final familyId = profile?.familyId;
          if (familyId == null) {
            return const Center(child: Text('No family context.'));
          }
          final isParent = profile?.role.name == 'parent';
          final announcementsAsync = ref.watch(
            announcementsStreamProvider(familyId),
          );
          return Column(
            children: [
              if (isParent)
                Padding(
                  padding: EdgeInsets.all(spaces.md),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(
                            hintText: 'Share an announcement...',
                          ),
                        ),
                      ),
                      SizedBox(width: spaces.sm),
                      FilledButton.icon(
                        onPressed: _textController.text.trim().isEmpty
                            ? null
                            : () async {
                                final text = _textController.text.trim();
                                final user =
                                    fb.FirebaseAuth.instance.currentUser;
                                if (user == null) return;
                                try {
                                  await ref
                                      .read(announcementsRepositoryProvider)
                                      .addAnnouncement(
                                        familyId: familyId,
                                        text: text,
                                        authorUid: user.uid,
                                        authorName:
                                            profile?.displayName ?? 'User',
                                      );
                                } catch (e) {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Failed to post: $e'),
                                    ),
                                  );
                                }
                                _textController.clear();
                                setState(() {});
                              },
                        icon: const Icon(Icons.send),
                        label: const Text('Post'),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: announcementsAsync.when(
                  data: (items) => ListView.separated(
                    padding: EdgeInsets.all(spaces.md),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => SizedBox(height: spaces.sm),
                    itemBuilder: (_, i) => _AnnouncementTile(
                      announcement: items[i],
                      familyId: familyId,
                      canDelete: isParent,
                    ),
                  ),
                  error: (e, _) => Center(child: Text('Error: $e')),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                ),
              ),
            ],
          );
        },
        error: (e, _) => Center(child: Text('Error: $e')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _AnnouncementTile extends ConsumerWidget {
  const _AnnouncementTile({
    required this.announcement,
    required this.familyId,
    required this.canDelete,
  });
  final Announcement announcement;
  final String familyId;
  final bool canDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: ListTile(
        title: Text(announcement.text),
        subtitle: Text(
          '${announcement.authorName} • ${formatRelativeTime(announcement.createdAt)}',
        ),
        trailing: canDelete
            ? IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () async {
                  final confirm =
                      await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete announcement?'),
                          content: const Text('This cannot be undone.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      ) ??
                      false;
                  if (!confirm) return;
                  try {
                    await ref
                        .read(announcementsRepositoryProvider)
                        .deleteAnnouncement(
                          familyId: familyId,
                          id: announcement.id,
                        );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to delete: $e')),
                    );
                  }
                },
              )
            : null,
      ),
    );
  }
}

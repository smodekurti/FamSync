import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fam_sync/data/auth/auth_repository.dart';
import 'package:fam_sync/data/messages/messages_repository.dart';
import 'package:fam_sync/domain/models/message.dart';
import 'package:fam_sync/theme/app_theme.dart';
import 'package:fam_sync/core/utils/time.dart';
import 'package:fam_sync/ui/widgets/family_app_bar_title.dart';
import 'package:fam_sync/ui/appbar/fam_app_bar_scaffold.dart';
import 'package:fam_sync/ui/strings.dart';
import 'package:fam_sync/ui/icons.dart';

class MessagesScreen extends ConsumerStatefulWidget {
  const MessagesScreen({super.key});

  @override
  ConsumerState<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends ConsumerState<MessagesScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    // List is newest-first; keep view pinned to top after sending
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final spaces = context.spaces;
    final profileAsync = ref.watch(userProfileStreamProvider);

    return FamAppBarScaffold(
      title: const FamilyAppBarTitle(fallback: AppStrings.messagesTitle),
      fixedActions: const [
        Icon(AppIcons.reminder),
        SizedBox(width: 8),
        Icon(AppIcons.add),
        SizedBox(width: 8),
        Icon(AppIcons.profile),
      ],
      extraActions: const [],
      headerBuilder: (context, controller) => TextField(
        decoration: const InputDecoration(
          hintText: AppStrings.searchMessagesHint,
          prefixIcon: Icon(Icons.search),
          filled: true,
          isDense: true,
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
        onChanged: (_) {},
      ),
      body: profileAsync.when(
        data: (profile) {
          final familyId = profile?.familyId;
          if (familyId == null) {
            return const Center(child: Text('No family context.'));
          }
          final messagesAsync = ref.watch(messagesStreamProvider(familyId));
          return Column(
            children: [
              Expanded(
                child: messagesAsync.when(
                  data: (items) => ListView.separated(
                    controller: _scrollController,
                    reverse: false,
                    padding: EdgeInsets.all(spaces.md),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => SizedBox(height: spaces.sm),
                    itemBuilder: (_, i) => _MessageBubble(
                      message: items[i],
                      isMine:
                          items[i].authorUid ==
                          fb.FirebaseAuth.instance.currentUser?.uid,
                    ),
                  ),
                  error: (e, _) => Center(child: Text('Error: $e')),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    spaces.md,
                    spaces.sm,
                    spaces.md,
                    spaces.md,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(
                            hintText: 'Message your family...',
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
                                      .read(messagesRepositoryProvider)
                                      .addMessage(
                                        familyId: familyId,
                                        text: text,
                                        authorUid: user.uid,
                                        authorName:
                                            profile?.displayName ?? 'User',
                                        authorPhotoUrl: profile?.photoUrl,
                                      );
                                } catch (e) {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Failed to send: $e'),
                                    ),
                                  );
                                }
                                _textController.clear();
                                setState(() {});
                                _scrollToTop();
                              },
                        icon: const Icon(Icons.send),
                        label: const Text('Send'),
                      ),
                    ],
                  ),
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

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.isMine});
  final Message message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final bg = isMine
        ? colors.primaryContainer
        : colors.surfaceContainerHighest;
    final fg = isMine ? colors.onPrimaryContainer : colors.onSurface;
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMine)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: _Avatar(
                url: message.authorPhotoUrl,
                fallbackInitial: message.authorName.isNotEmpty
                    ? message.authorName[0]
                    : '?',
              ),
            ),
          Container(
            constraints: const BoxConstraints(maxWidth: 520),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.authorName,
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: fg.withOpacity(0.7)),
                ),
                const SizedBox(height: 2),
                Text(
                  message.text,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: fg),
                ),
                const SizedBox(height: 2),
                Text(
                  formatRelativeTime(message.createdAt),
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: fg.withOpacity(0.6)),
                ),
              ],
            ),
          ),
          if (isMine)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: _Avatar(
                url: message.authorPhotoUrl,
                fallbackInitial: message.authorName.isNotEmpty
                    ? message.authorName[0]
                    : '?',
              ),
            ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.url, required this.fallbackInitial});
  final String? url;
  final String fallbackInitial;

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).colorScheme.surfaceVariant;
    final fg = Theme.of(context).colorScheme.onSurfaceVariant;
    return CircleAvatar(
      radius: 14,
      backgroundColor: bg,
      backgroundImage: (url != null && url!.isNotEmpty)
          ? NetworkImage(url!)
          : null,
      child: (url == null || url!.isEmpty)
          ? Text(
              fallbackInitial.toUpperCase(),
              style: TextStyle(color: fg, fontSize: 12),
            )
          : null,
    );
  }
}

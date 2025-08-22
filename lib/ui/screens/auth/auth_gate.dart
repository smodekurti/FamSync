import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:fam_sync/data/auth/auth_repository.dart';
import 'package:fam_sync/theme/app_theme.dart';
import 'package:fam_sync/ui/screens/auth/login_screen.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileStreamProvider);
    return profileAsync.when(
      data: (profile) {
        if (profile == null) {
          return const LoginScreen();
        }
        if (!profile.onboarded || (profile.familyId == null)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) context.go('/onboarding');
          });
          return const SizedBox.shrink();
        }
        return child;
      },
      error: (e, _) => _ErrorRetryWidget(error: e.toString()),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}



class _ErrorRetryWidget extends ConsumerWidget {
  const _ErrorRetryWidget({required this.error});
  final String error;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(context.spaces.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Temporary issue', style: Theme.of(context).textTheme.headlineSmall),
              SizedBox(height: context.spaces.md),
              Text(error, textAlign: TextAlign.center),
              SizedBox(height: context.spaces.lg),
              FilledButton(
                onPressed: () => ref.refresh(userProfileStreamProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



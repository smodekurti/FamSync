import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:fam_sync/data/auth/auth_repository.dart';
import 'package:fam_sync/theme/app_theme.dart';
import 'package:fam_sync/ui/screens/auth/login_screen.dart';
import 'package:fam_sync/ui/widgets/responsive_error_widget.dart';
import 'package:fam_sync/ui/strings.dart';

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
      error: (e, _) => _ErrorRetryWidget(error: e),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorRetryWidget extends ConsumerWidget {
  const _ErrorRetryWidget({required this.error});
  final Object error;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Check if this is a sign-out related error
    final errorString = error.toString().toLowerCase();
    final isSignOutError = errorString.contains('permission-denied') || 
                           errorString.contains('permission_denied') ||
                           errorString.contains('sign-out') ||
                           errorString.contains('signout');
    
    if (isSignOutError) {
      // For sign-out errors, show a more specific message and redirect to login
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.go('/auth');
        }
      });
      return const LoginScreen();
    }
    
    // For other errors, show the responsive error widget
    return ResponsiveErrorWidget(
      error: error,
      onRetry: () => ref.refresh(userProfileStreamProvider),
      title: AppStrings.errorTitle,
      subtitle: AppStrings.errorSubtitle,
    );
  }
}



import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fam_sync/core/bootstrap/bootstrap.dart';
import 'package:fam_sync/router/app_router.dart';
import 'package:fam_sync/theme/app_theme.dart';
import 'package:fam_sync/data/auth/auth_repository.dart';

Future<void> main() async {
  final container = ProviderContainer();
  final bootstrapper = AppBootstrapper();
  await bootstrapper.initialize();
  runApp(UncontrolledProviderScope(
    container: container,
    child: const FamSyncApp(),
  ));
}

class FamSyncApp extends ConsumerWidget {
  const FamSyncApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize the user profile invalidator to watch for auth state changes
    ref.watch(userProfileInvalidatorProvider);
    
    final router = ref.watch(goRouterProvider);
    return MaterialApp.router(
      title: 'Family Sync',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:fam_sync/ui/shells/main_shell.dart';
import 'package:fam_sync/ui/screens/calendar/calendar_screen.dart';
import 'package:fam_sync/ui/screens/tasks/tasks_screen.dart';
import 'package:fam_sync/ui/screens/shopping/shopping_screen.dart';
import 'package:fam_sync/ui/screens/finance/finance_screen.dart';
import 'package:fam_sync/ui/screens/hub/hub_screen.dart';
import 'package:fam_sync/ui/screens/auth/auth_gate.dart';
import 'package:fam_sync/ui/screens/onboarding/onboarding_screen.dart';
import 'package:fam_sync/ui/screens/announcements/announcements_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/hub',
    routes: [
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: OnboardingScreen()),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AuthGate(child: MainShell(shell: navigationShell)),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/hub',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: HubScreen()),
              ),
              GoRoute(
                path: '/announcements',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: AnnouncementsScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/calendar',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: CalendarScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/tasks',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: TasksScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/shopping',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: ShoppingScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/finance',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: FinanceScreen()),
              ),
            ],
          ),
        ],
      ),
    ],
    errorPageBuilder: (context, state) => MaterialPage(
      child: Scaffold(
        body: Center(child: Text('Navigation error: \'${state.error}\'')),
      ),
    ),
  );
});

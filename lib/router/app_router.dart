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
import 'package:fam_sync/ui/screens/messages/messages_screen.dart';
import 'package:fam_sync/ui/screens/settings/settings_screen.dart';
import 'package:fam_sync/ui/screens/splash/splash_screen.dart';
import 'package:fam_sync/ui/screens/auth/login_screen.dart';
import 'package:fam_sync/ui/screens/auth/accept_invite_screen.dart';
import 'package:fam_sync/ui/screens/settings/invite_members_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: SplashScreen()),
      ),
      GoRoute(
        path: '/auth',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: LoginScreen()),
      ),
      GoRoute(
        path: '/accept-invite',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: AcceptInviteScreen()),
      ),
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
              GoRoute(
                path: '/messages',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: MessagesScreen()),
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
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: SettingsScreen()),
              ),
              GoRoute(
                path: '/settings/invite-members',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: InviteMembersScreen()),
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

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fam_sync/theme/app_theme.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  static const _routes = ['/hub', '/calendar', '/tasks', '/shopping', '/finance'];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = context.layout.isLarge || context.layout.isXLarge;
        final colors = Theme.of(context).colorScheme;
        return Scaffold(
          body: Row(
            children: [
              if (isTablet)
                NavigationRail(
                  selectedIndex: shell.currentIndex,
                  onDestinationSelected: (index) => _onTabSelected(context, index),
                  labelType: NavigationRailLabelType.all,
                  backgroundColor: colors.surface,
                  destinations: const [
                    NavigationRailDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: Text('Hub')),
                    NavigationRailDestination(icon: Icon(Icons.calendar_today_outlined), selectedIcon: Icon(Icons.calendar_month), label: Text('Calendar')),
                    NavigationRailDestination(icon: Icon(Icons.checklist_outlined), selectedIcon: Icon(Icons.checklist), label: Text('Tasks')),
                    NavigationRailDestination(icon: Icon(Icons.shopping_cart_outlined), selectedIcon: Icon(Icons.shopping_cart), label: Text('Shopping')),
                    NavigationRailDestination(icon: Icon(Icons.account_balance_wallet_outlined), selectedIcon: Icon(Icons.account_balance_wallet), label: Text('Finance')),
                  ],
                ),
              Expanded(child: shell),
            ],
          ),
          bottomNavigationBar: isTablet
              ? null
              : NavigationBar(
                  selectedIndex: shell.currentIndex,
                  onDestinationSelected: (index) => _onTabSelected(context, index),
                  destinations: const [
                    NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Hub'),
                    NavigationDestination(icon: Icon(Icons.calendar_today_outlined), selectedIcon: Icon(Icons.calendar_month), label: 'Calendar'),
                    NavigationDestination(icon: Icon(Icons.checklist_outlined), selectedIcon: Icon(Icons.checklist), label: 'Tasks'),
                    NavigationDestination(icon: Icon(Icons.shopping_cart_outlined), selectedIcon: Icon(Icons.shopping_cart), label: 'Shopping'),
                    NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), selectedIcon: Icon(Icons.account_balance_wallet), label: 'Finance'),
                  ],
                ),
        );
      },
    );
  }

  void _onTabSelected(BuildContext context, int index) {
    if (index == shell.currentIndex) return;
    shell.goBranch(index, initialLocation: index == shell.currentIndex);
    context.go(_routes[index]);
  }
}



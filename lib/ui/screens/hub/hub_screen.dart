import 'package:flutter/material.dart';
import 'package:fam_sync/theme/app_theme.dart';

class HubScreen extends StatelessWidget {
  const HubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = context.layout.isSmall;
        final spaces = context.spaces;
        return Scaffold(
          appBar: AppBar(title: const Text('Family Hub')),
          body: Padding(
            padding: EdgeInsets.all(spaces.md),
            child: GridView.count(
              crossAxisCount: isCompact ? 1 : 2,
              mainAxisSpacing: spaces.md,
              crossAxisSpacing: spaces.md,
              children: const [
                _HubCard(title: 'Announcements', icon: Icons.campaign),
                _HubCard(title: 'Messages', icon: Icons.message),
                _HubCard(title: 'Location', icon: Icons.location_on),
                _HubCard(title: 'Shortcuts', icon: Icons.flash_on),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HubCard extends StatelessWidget {
  const _HubCard({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {},
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




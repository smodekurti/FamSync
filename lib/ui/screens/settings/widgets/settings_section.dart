import 'package:flutter/material.dart';
import 'package:fam_sync/theme/app_theme.dart';

class SettingsSection extends StatelessWidget {
  const SettingsSection({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final spaces = context.spaces;
    final colors = context.colors;

    return Card(
      elevation: 0,
      color: colors.surfaceContainerHighest,
      child: Padding(
        padding: EdgeInsets.all(spaces.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            Row(
              children: [
                Icon(
                  icon,
                  color: colors.primary,
                  size: spaces.lg,
                ),
                SizedBox(width: spaces.sm),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                  ),
                ),
              ],
            ),
            SizedBox(height: spaces.md),
            
            // Section Content
            ...children,
          ],
        ),
      ),
    );
  }
}

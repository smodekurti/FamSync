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
    final layout = context.layout;

    return Card(
      elevation: 0,
      color: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.all(layout.isSmall ? spaces.sm : spaces.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            Row(
              children: [
                Icon(
                  icon,
                  color: colors.primary,
                  size: layout.isSmall ? spaces.md : spaces.lg,
                ),
                SizedBox(width: spaces.sm),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.onSurface,
                      fontSize: layout.isSmall 
                          ? Theme.of(context).textTheme.titleSmall?.fontSize
                          : Theme.of(context).textTheme.titleMedium?.fontSize,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: layout.isSmall ? spaces.sm : spaces.md),
            
            // Section Content
            ...children,
          ],
        ),
      ),
    );
  }
}

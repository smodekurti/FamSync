import 'package:flutter/material.dart';
import 'package:fam_sync/theme/app_theme.dart';

class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.trailing,
    this.showDivider = true,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final spaces = context.spaces;
    final colors = context.colors;
    final layout = context.layout;

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(spaces.sm),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: spaces.sm,
              vertical: layout.isSmall ? spaces.sm : spaces.md,
            ),
            child: Row(
              children: [
                // Icon
                Container(
                  padding: EdgeInsets.all(layout.isSmall ? spaces.xs : spaces.sm),
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(spaces.sm),
                  ),
                  child: Icon(
                    icon,
                    color: colors.onPrimaryContainer,
                    size: layout.isSmall ? spaces.sm : spaces.md,
                  ),
                ),
                SizedBox(width: spaces.md),
                
                // Title and Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colors.onSurface,
                          fontSize: layout.isSmall 
                              ? Theme.of(context).textTheme.labelLarge?.fontSize
                              : Theme.of(context).textTheme.titleSmall?.fontSize,
                        ),
                      ),
                      SizedBox(height: spaces.xs / 2),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                          fontSize: layout.isSmall 
                              ? Theme.of(context).textTheme.labelSmall?.fontSize
                              : Theme.of(context).textTheme.bodySmall?.fontSize,
                        ),
                        maxLines: layout.isSmall ? 1 : 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                // Trailing Widget (Switch, Arrow, etc.)
                if (trailing != null) ...[
                  SizedBox(width: spaces.sm),
                  trailing!,
                ] else if (onTap != null) ...[
                  SizedBox(width: spaces.sm),
                  Icon(
                    Icons.chevron_right,
                    color: colors.onSurfaceVariant,
                    size: layout.isSmall ? spaces.sm : spaces.md,
                  ),
                ],
              ],
            ),
          ),
        ),
        
        // Divider
        if (showDivider)
          Divider(
            height: 1,
            color: colors.outline.withValues(alpha: 0.1),
            indent: layout.isSmall ? spaces.lg : spaces.xl * 2,
          ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fam_sync/theme/app_theme.dart';
import 'package:fam_sync/ui/icons.dart';

/// Reusable header content component for the Hub Screen
/// This component displays the greeting, notification bell, and other header elements
/// in a format that works seamlessly with SeamlessAppBarScaffold
class HubHeaderContent extends ConsumerWidget {
  const HubHeaderContent({
    super.key,
    this.userName,
    this.showNotificationBadge = false,
    this.onNotificationTap,
  });

  /// The user's name to display in the greeting
  final String? userName;
  
  /// Whether to show a notification badge on the bell icon
  final bool showNotificationBadge;
  
  /// Callback when the notification bell is tapped
  final VoidCallback? onNotificationTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spaces = context.spaces;
    final colors = Theme.of(context).colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Top row: Greeting and notification bell
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
            // Greeting text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting based on time of day
                  Text(
                    _getGreeting(),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: colors.onPrimary,
                      fontWeight: FontWeight.w300,
                      fontSize: _getResponsiveFontSize(context, 20, 24, 28),
                    ),
                  ),
                  SizedBox(height: spaces.xs / 2),
                  // Personalized greeting with user's name
                  Text(
                    userName != null 
                        ? 'Welcome back, $userName!'
                        : 'Welcome to FamSync!',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: colors.onPrimary.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                      fontSize: _getResponsiveFontSize(context, 16, 18, 20),
                    ),
                  ),
                ],
              ),
            ),
            
            // Notification bell with optional badge
            GestureDetector(
              onTap: onNotificationTap,
              child: Container(
                padding: EdgeInsets.all(spaces.sm),
                decoration: BoxDecoration(
                  color: colors.onPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(spaces.md),
                ),
                child: Stack(
                  children: [
                    Icon(
                      AppIcons.reminder,
                      color: colors.onPrimary,
                      size: _getResponsiveIconSize(context, 20, 24, 28),
                    ),
                    // Notification badge
                    if (showNotificationBadge)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
        ),
        
        SizedBox(height: spaces.md),
        
        // Bottom row: Quick status or additional info
        Row(
          children: [
            Icon(
              Icons.family_restroom,
              color: colors.onPrimary.withOpacity(0.8),
              size: _getResponsiveIconSize(context, 16, 18, 20),
            ),
            SizedBox(width: spaces.xs),
            Text(
              'Family Hub',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colors.onPrimary.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Returns a greeting based on the current time of day
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  /// Returns responsive font size based on screen size
  double _getResponsiveFontSize(BuildContext context, double small, double medium, double large) {
    if (context.layout.isSmall) return small;
    if (context.layout.isMedium) return medium;
    return large;
  }

  /// Returns responsive icon size based on screen size
  double _getResponsiveIconSize(BuildContext context, double small, double medium, double large) {
    if (context.layout.isSmall) return small;
    if (context.layout.isMedium) return medium;
    return large;
  }
}

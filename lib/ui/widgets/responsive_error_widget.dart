import 'package:flutter/material.dart';
import 'package:fam_sync/theme/app_theme.dart';
import 'package:fam_sync/ui/strings.dart';

class ResponsiveErrorWidget extends StatelessWidget {
  const ResponsiveErrorWidget({
    super.key,
    required this.error,
    this.onRetry,
    this.showRetryButton = true,
    this.title,
    this.subtitle,
    this.icon,
    this.actions,
  });

  final Object error;
  final VoidCallback? onRetry;
  final bool showRetryButton;
  final String? title;
  final String? subtitle;
  final IconData? icon;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final spaces = context.spaces;
    final colors = context.colors;
    final layout = context.layout;

    // Determine error type and appropriate messaging
    final errorInfo = _getErrorInfo(error);
    
    return Center(
      child: Padding(
        padding: EdgeInsets.all(spaces.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error Icon
            Container(
              width: layout.isSmall ? spaces.xxl * 3 : spaces.xxl * 4,
              height: layout.isSmall ? spaces.xxl * 3 : spaces.xxl * 4,
              decoration: BoxDecoration(
                color: colors.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? errorInfo.icon,
                size: layout.isSmall ? spaces.xxl * 1.5 : spaces.xxl * 2,
                color: colors.error,
              ),
            ),
            
            SizedBox(height: spaces.lg),
            
            // Error Title
            Text(
              title ?? errorInfo.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: layout.isSmall 
                    ? Theme.of(context).textTheme.titleLarge?.fontSize
                    : Theme.of(context).textTheme.headlineSmall?.fontSize,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: spaces.md),
            
            // Error Subtitle
            Text(
              subtitle ?? errorInfo.subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
                fontSize: layout.isSmall 
                    ? Theme.of(context).textTheme.bodySmall?.fontSize
                    : Theme.of(context).textTheme.bodyMedium?.fontSize,
              ),
              textAlign: TextAlign.center,
              maxLines: layout.isSmall ? 2 : 3,
            ),
            
            SizedBox(height: spaces.xl),
            
            // Actions
            if (actions != null) ...[
              ...actions!,
              SizedBox(height: spaces.md),
            ],
            
            // Retry Button
            if (showRetryButton && onRetry != null) ...[
              SizedBox(
                width: layout.isSmall ? double.infinity : spaces.xxl * 12,
                height: spaces.xxl * 1.5,
                child: FilledButton(
                  onPressed: onRetry,
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(spaces.sm),
                    ),
                  ),
                  child: Text(
                    AppStrings.retryButton,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  ErrorInfo _getErrorInfo(Object error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('permission-denied') || 
        errorString.contains('permission_denied')) {
      return ErrorInfo(
        icon: Icons.lock_outline,
        title: AppStrings.errorTitle,
        subtitle: AppStrings.errorSignOutPermission,
      );
    } else if (errorString.contains('network') || 
               errorString.contains('timeout') ||
               errorString.contains('connection')) {
      return ErrorInfo(
        icon: Icons.wifi_off,
        title: AppStrings.errorTitle,
        subtitle: AppStrings.errorSignOutNetwork,
      );
    } else {
      return ErrorInfo(
        icon: Icons.error_outline,
        title: AppStrings.errorTitle,
        subtitle: AppStrings.errorSignOutUnknown,
      );
    }
  }
}

class ErrorInfo {
  const ErrorInfo({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;
}

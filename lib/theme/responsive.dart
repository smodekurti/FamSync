import 'package:flutter/material.dart';

class AppBreakpoints {
  const AppBreakpoints({
    this.small = 0,
    this.medium = 600,
    this.large = 900,
    this.xlarge = 1200,
  });

  final double small;
  final double medium;
  final double large;
  final double xlarge;
}

enum AppSizeClass { small, medium, large, xlarge }

class AppLayout {
  const AppLayout._(this.sizeClass, this.maxWidth);

  final AppSizeClass sizeClass;
  final double maxWidth;

  bool get isSmall => sizeClass == AppSizeClass.small;
  bool get isMedium => sizeClass == AppSizeClass.medium;
  bool get isLarge => sizeClass == AppSizeClass.large;
  bool get isXLarge => sizeClass == AppSizeClass.xlarge;

  static AppLayout of(BuildContext context, AppBreakpoints breakpoints) {
    final width = MediaQuery.sizeOf(context).width;
    final sizeClass = width < breakpoints.medium
        ? AppSizeClass.small
        : width < breakpoints.large
            ? AppSizeClass.medium
            : width < breakpoints.xlarge
                ? AppSizeClass.large
                : AppSizeClass.xlarge;
    return AppLayout._(sizeClass, width);
  }

  // Helper methods for responsive design
  bool get isMobile => isSmall;
  bool get isTablet => isMedium || isLarge;
  bool get isDesktop => isXLarge;
  
  // Responsive value helper
  T responsiveValue<T>({
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isMobile) return mobile;
    if (isTablet) return tablet ?? mobile;
    if (isDesktop) return desktop ?? tablet ?? mobile;
    return mobile;
  }
}

// Extension for easier responsive access
extension ResponsiveExtension on BuildContext {
  bool get isMobile => MediaQuery.sizeOf(this).width < 600;
  bool get isTablet => MediaQuery.sizeOf(this).width >= 600 && MediaQuery.sizeOf(this).width < 1200;
  bool get isDesktop => MediaQuery.sizeOf(this).width >= 1200;
  
  // Responsive padding helpers
  EdgeInsets get responsivePadding {
    if (isMobile) {
      return const EdgeInsets.all(16.0);
    } else if (isTablet) {
      return const EdgeInsets.all(24.0);
    } else {
      return const EdgeInsets.all(32.0);
    }
  }
  
  // Responsive margin helpers
  EdgeInsets get responsiveMargin {
    if (isMobile) {
      return const EdgeInsets.all(8.0);
    } else if (isTablet) {
      return const EdgeInsets.all(16.0);
    } else {
      return const EdgeInsets.all(24.0);
    }
  }
}



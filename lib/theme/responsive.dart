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
}



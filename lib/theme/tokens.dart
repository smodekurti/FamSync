import 'package:flutter/material.dart';
import 'package:fam_sync/theme/responsive.dart';

class AppColors {
  AppColors._();
  // Seed only here; rest through ColorScheme to avoid hardcoding
  static const seed = Color(0xFF6750FF); // Vibrant indigo seed for energetic palette
}

class AppRadii {
  AppRadii._();
  static const double small = 8;
  static const double medium = 12;
  static const double large = 16;
}

class AppElevations {
  AppElevations._();
  static const double level0 = 0;
  static const double level1 = 1;
  static const double level2 = 2;
  static const double level3 = 4;
}

class AppGradients {
  AppGradients._();
  // Vibrant, energizing header gradient
  static const List<Color> hubHeaderLight = [
    Color(0xFF6750FF), // Indigo
    Color(0xFFFF4D9D), // Hot pink
  ];
  static const List<Color> hubHeaderDark = [
    Color(0xFF4E3BFF), // Deeper indigo
    Color(0xFFFF3D7F), // Vivid magenta
  ];
}

class AppSpacing {
  AppSpacing(this.layout);
  final AppLayout layout;

  double get xs => layout.isSmall ? 4 : layout.isMedium ? 6 : 8;
  double get sm => layout.isSmall ? 8 : layout.isMedium ? 10 : 12;
  double get md => layout.isSmall ? 12 : layout.isMedium ? 16 : 20;
  double get lg => layout.isSmall ? 16 : layout.isMedium ? 20 : 24;
  double get xl => layout.isSmall ? 20 : layout.isMedium ? 24 : 32;
  double get xxl => layout.isSmall ? 24 : layout.isMedium ? 32 : 40;
}

class AppSizes {
  AppSizes(this.layout);
  final AppLayout layout;

  // Common component heights
  double get touchTarget => layout.isSmall ? 44 : 48;
  double get cardMinHeight => layout.isSmall ? 120 : 160;

  // Icon sizes
  double get iconSm => layout.isSmall ? 20 : layout.isMedium ? 22 : 24;
  double get iconMd => layout.isSmall ? 24 : layout.isMedium ? 28 : 32;
  double get iconLg => layout.isSmall ? 32 : layout.isMedium ? 36 : 40;

  // Component widths
  double get statCardWidth => layout.isSmall ? 160 : layout.isMedium ? 180 : 200;
}



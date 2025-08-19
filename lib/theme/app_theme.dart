import 'package:flutter/material.dart';

import 'package:fam_sync/theme/responsive.dart';
import 'package:fam_sync/theme/tokens.dart';

class AppTheme {
  AppTheme._();

  static const AppBreakpoints breakpoints = AppBreakpoints();

  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.seed,
      brightness: Brightness.light,
    );

    return base.copyWith(
      colorScheme: colorScheme,
      textTheme: _textTheme(base.textTheme),
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: false,
      ),
      // Subtle elevation separation for cards under vibrant header
      cardColor: colorScheme.surfaceContainerLow,
      navigationBarTheme: NavigationBarThemeData(
        elevation: AppElevations.level2,
        backgroundColor: colorScheme.surface,
      ),
      chipTheme: base.chipTheme.copyWith(
        side: BorderSide(color: colorScheme.outlineVariant),
        shape: StadiumBorder(side: BorderSide(color: colorScheme.outlineVariant)),
      ),
    );
  }

  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.seed,
      brightness: Brightness.dark,
    );

    return base.copyWith(
      colorScheme: colorScheme,
      textTheme: _textTheme(base.textTheme),
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: false,
      ),
      cardColor: colorScheme.surfaceContainerLow,
      navigationBarTheme: NavigationBarThemeData(
        elevation: AppElevations.level2,
        backgroundColor: colorScheme.surface,
      ),
      chipTheme: base.chipTheme.copyWith(
        side: BorderSide(color: colorScheme.outlineVariant),
        shape: StadiumBorder(side: BorderSide(color: colorScheme.outlineVariant)),
      ),
    );
  }

  static TextTheme _textTheme(TextTheme base) {
    // Scale slightly for readability; rely on Material baseline sizes
    return base.copyWith(
      titleLarge: base.titleLarge,
      titleMedium: base.titleMedium,
      titleSmall: base.titleSmall,
      bodyLarge: base.bodyLarge,
      bodyMedium: base.bodyMedium,
      bodySmall: base.bodySmall,
      labelLarge: base.labelLarge,
      labelMedium: base.labelMedium,
      labelSmall: base.labelSmall,
    );
  }
}

extension BuildContextThemeX on BuildContext {
  AppLayout get layout => AppLayout.of(this, AppTheme.breakpoints);
  AppSpacing get spaces => AppSpacing(layout);
  AppSizes get sizes => AppSizes(layout);
  TextTheme get textStyles => Theme.of(this).textTheme;
  ColorScheme get colors => Theme.of(this).colorScheme;
}



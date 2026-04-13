import 'package:flutter/material.dart';
import 'package:abdoul_express/core/theme/colors.dart';
import 'package:abdoul_express/core/theme/typography.dart';

class AppSpacing {
  // Spacing values
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // Edge insets shortcuts
  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);

  // Horizontal padding
  static const EdgeInsets horizontalXs = EdgeInsets.symmetric(horizontal: xs);
  static const EdgeInsets horizontalSm = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets horizontalMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets horizontalLg = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets horizontalXl = EdgeInsets.symmetric(horizontal: xl);

  // Vertical padding
  static const EdgeInsets verticalXs = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets verticalSm = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets verticalMd = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets verticalLg = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets verticalXl = EdgeInsets.symmetric(vertical: xl);
}

/// Border radius constants for consistent rounded corners
class AppRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
}

// =============================================================================
// THEMES
// =============================================================================

/// Light theme with Desert Marketplace aesthetic
ThemeData get lightTheme => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.light(
    primary: AppColors.primaryMain,
    onPrimary: Colors.white,
    primaryContainer: AppColors.primaryContainer,
    onPrimaryContainer: AppColors.onPrimaryContainer,
    secondary: AppColors.secondaryMain,
    onSecondary: Colors.white,
    secondaryContainer: AppColors.secondaryContainer,
    onSecondaryContainer: AppColors.onSecondaryContainer,
    tertiary: AppColors.tertiaryMain,
    onTertiary: Colors.white,
    tertiaryContainer: AppColors.tertiaryContainer,
    onTertiaryContainer: AppColors.onTertiaryContainer,
    error: AppColors.errorMain,
    onError: Colors.white,
    errorContainer: AppColors.errorContainer,
    onErrorContainer: AppColors.onErrorContainer,
    surface: AppColors.surfaceElevated,
    onSurface: AppColors.textPrimary,
    surfaceContainerHighest: AppColors.surfaceSecondary,
    onSurfaceVariant: AppColors.textSecondary,
    outline: AppColors.outlineLight,
    shadow: AppColors.shadowLight,
  ),
  brightness: Brightness.light,
  scaffoldBackgroundColor: AppColors.surfacePrimary,
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.transparent,
    foregroundColor: AppColors.textPrimary,
    elevation: 0,
    scrolledUnderElevation: 0,
    titleTextStyle: AppTypography.buildTextTheme(Brightness.light).titleLarge,
  ),
  cardTheme: CardThemeData(
    elevation: 0,
    color: AppColors.surfaceElevated,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(
        color: AppColors.outlineLight.withValues(alpha: 0.2),
        width: 1,
      ),
    ),
  ),
  textTheme: AppTypography.buildTextTheme(Brightness.light),
);

/// Dark theme with Desert Marketplace aesthetic
ThemeData get darkTheme => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.dark(
    primary: AppColors.primaryMain,
    onPrimary: Colors.white,
    primaryContainer: AppColors.primaryDark,
    onPrimaryContainer: AppColors.primaryLight,
    secondary: AppColors.secondaryMain,
    onSecondary: AppColors.textPrimary,
    secondaryContainer: AppColors.secondaryDark,
    onSecondaryContainer: AppColors.secondaryLight,
    tertiary: AppColors.tertiaryMain,
    onTertiary: Colors.white,
    tertiaryContainer: AppColors.tertiaryDark,
    onTertiaryContainer: AppColors.tertiaryLight,
    error: AppColors.errorLight,
    onError: AppColors.errorDark,
    errorContainer: AppColors.errorDark,
    onErrorContainer: AppColors.errorLight,
    surface: AppColors.surfaceElevatedDark,
    onSurface: AppColors.textPrimaryDark,
    surfaceContainerHighest: AppColors.surfaceSecondaryDark,
    onSurfaceVariant: AppColors.textSecondaryDark,
    outline: AppColors.outlineDark,
    shadow: AppColors.shadowDark,
  ),
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AppColors.surfacePrimaryDark,
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.transparent,
    foregroundColor: AppColors.textPrimaryDark,
    elevation: 0,
    scrolledUnderElevation: 0,
    titleTextStyle: AppTypography.buildTextTheme(Brightness.dark).titleLarge,
  ),
  cardTheme: CardThemeData(
    elevation: 0,
    color: AppColors.surfaceElevatedDark,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(
        color: AppColors.outlineDark.withValues(alpha: 0.2),
        width: 1,
      ),
    ),
  ),
  textTheme: AppTypography.buildTextTheme(Brightness.dark),
);


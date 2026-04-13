import 'package:flutter/material.dart';
import 'package:abdoul_express/core/theme/colors.dart';

/// Shadow presets for the app
/// Uses colored shadows for depth and visual interest
class AppShadows {
  AppShadows._();

  // ============================================================================
  // ELEVATION SHADOWS (Neutral)
  // ============================================================================

  /// No shadow
  static const List<BoxShadow> none = [];

  /// Subtle shadow for minimal elevation
  static List<BoxShadow> get subtle => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];

  /// Small shadow for cards and containers
  static List<BoxShadow> get small => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 8,
          offset: const Offset(0, 2),
          spreadRadius: -1,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ];

  /// Medium shadow for elevated elements
  static List<BoxShadow> get medium => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 12,
          offset: const Offset(0, 4),
          spreadRadius: -2,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ];

  /// Large shadow for modals and floating elements
  static List<BoxShadow> get large => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 20,
          offset: const Offset(0, 8),
          spreadRadius: -4,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];

  /// Extra large shadow for drawers and dialogs
  static List<BoxShadow> get extraLarge => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.12),
          blurRadius: 30,
          offset: const Offset(0, 12),
          spreadRadius: -6,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 15,
          offset: const Offset(0, 6),
        ),
      ];

  // ============================================================================
  // COLORED SHADOWS (Branded)
  // ============================================================================

  /// Primary colored shadow (terracotta)
  static List<BoxShadow> get primaryColored => [
        BoxShadow(
          color: AppColors.primaryMain.withValues(alpha: 0.2),
          blurRadius: 16,
          offset: const Offset(0, 6),
          spreadRadius: -2,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ];

  /// Secondary colored shadow (sand)
  static List<BoxShadow> get secondaryColored => [
        BoxShadow(
          color: AppColors.secondaryDark.withValues(alpha: 0.15),
          blurRadius: 14,
          offset: const Offset(0, 5),
          spreadRadius: -2,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 7,
          offset: const Offset(0, 2),
        ),
      ];

  /// Tertiary colored shadow (olive)
  static List<BoxShadow> get tertiaryColored => [
        BoxShadow(
          color: AppColors.tertiaryMain.withValues(alpha: 0.18),
          blurRadius: 14,
          offset: const Offset(0, 5),
          spreadRadius: -2,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 7,
          offset: const Offset(0, 2),
        ),
      ];

  /// Gold colored shadow (premium)
  static List<BoxShadow> get goldColored => [
        BoxShadow(
          color: AppColors.goldAccent.withValues(alpha: 0.25),
          blurRadius: 18,
          offset: const Offset(0, 7),
          spreadRadius: -2,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 9,
          offset: const Offset(0, 3),
        ),
      ];

  /// Success colored shadow (green)
  static List<BoxShadow> get successColored => [
        BoxShadow(
          color: AppColors.successMain.withValues(alpha: 0.18),
          blurRadius: 14,
          offset: const Offset(0, 5),
          spreadRadius: -2,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 7,
          offset: const Offset(0, 2),
        ),
      ];

  /// Error colored shadow (red)
  static List<BoxShadow> get errorColored => [
        BoxShadow(
          color: AppColors.errorMain.withValues(alpha: 0.18),
          blurRadius: 14,
          offset: const Offset(0, 5),
          spreadRadius: -2,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 7,
          offset: const Offset(0, 2),
        ),
      ];

  /// Warning colored shadow (amber)
  static List<BoxShadow> get warningColored => [
        BoxShadow(
          color: AppColors.warningMain.withValues(alpha: 0.18),
          blurRadius: 14,
          offset: const Offset(0, 5),
          spreadRadius: -2,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 7,
          offset: const Offset(0, 2),
        ),
      ];

  // ============================================================================
  // COMPONENT-SPECIFIC SHADOWS
  // ============================================================================

  /// Product card shadow
  static List<BoxShadow> get productCard => [
        BoxShadow(
          color: AppColors.primaryMain.withValues(alpha: 0.12),
          blurRadius: 16,
          offset: const Offset(0, 6),
          spreadRadius: -3,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ];

  /// Button shadow
  static List<BoxShadow> get button => [
        BoxShadow(
          color: AppColors.primaryMain.withValues(alpha: 0.3),
          blurRadius: 12,
          offset: const Offset(0, 4),
          spreadRadius: -2,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ];

  /// Button pressed shadow (reduced)
  static List<BoxShadow> get buttonPressed => [
        BoxShadow(
          color: AppColors.primaryMain.withValues(alpha: 0.2),
          blurRadius: 6,
          offset: const Offset(0, 2),
          spreadRadius: -1,
        ),
      ];

  /// Navigation bubble shadow
  static List<BoxShadow> get navBubble => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.12),
          blurRadius: 24,
          offset: const Offset(0, 10),
          spreadRadius: -4,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 12,
          offset: const Offset(0, 5),
        ),
      ];

  /// Floating action button shadow
  static List<BoxShadow> get fab => [
        BoxShadow(
          color: AppColors.primaryMain.withValues(alpha: 0.35),
          blurRadius: 16,
          offset: const Offset(0, 6),
          spreadRadius: -2,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ];

  /// Modal/dialog shadow
  static List<BoxShadow> get modal => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.15),
          blurRadius: 40,
          offset: const Offset(0, 16),
          spreadRadius: -8,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  /// Bottom sheet shadow
  static List<BoxShadow> get bottomSheet => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.12),
          blurRadius: 30,
          offset: const Offset(0, -10),
          spreadRadius: -5,
        ),
      ];

  /// Search field shadow
  static List<BoxShadow> get searchField => [
        BoxShadow(
          color: AppColors.primaryMain.withValues(alpha: 0.08),
          blurRadius: 10,
          offset: const Offset(0, 3),
          spreadRadius: -2,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 5,
          offset: const Offset(0, 1),
        ),
      ];

  // ============================================================================
  // HOVER/ACTIVE SHADOWS
  // ============================================================================

  /// Hover shadow (expanded)
  static List<BoxShadow> hoverShadow(List<BoxShadow> baseShadow) {
    return baseShadow.map((shadow) {
      return BoxShadow(
        color: shadow.color,
        blurRadius: shadow.blurRadius * 1.5,
        offset: Offset(shadow.offset.dx, shadow.offset.dy * 1.2),
        spreadRadius: shadow.spreadRadius,
      );
    }).toList();
  }

  /// Active/pressed shadow (reduced)
  static List<BoxShadow> activeShadow(List<BoxShadow> baseShadow) {
    return baseShadow.map((shadow) {
      return BoxShadow(
        color: shadow.color,
        blurRadius: shadow.blurRadius * 0.5,
        offset: Offset(shadow.offset.dx, shadow.offset.dy * 0.5),
        spreadRadius: shadow.spreadRadius,
      );
    }).toList();
  }

  // ============================================================================
  // CUSTOM SHADOW BUILDER
  // ============================================================================

  /// Create custom colored shadow
  static List<BoxShadow> createColoredShadow({
    required Color color,
    double opacity = 0.15,
    double blurRadius = 14,
    Offset offset = const Offset(0, 5),
    double spreadRadius = -2,
    bool includeNeutral = true,
  }) {
    final shadows = <BoxShadow>[
      BoxShadow(
        color: color.withValues(alpha: opacity),
        blurRadius: blurRadius,
        offset: offset,
        spreadRadius: spreadRadius,
      ),
    ];

    if (includeNeutral) {
      shadows.add(
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: blurRadius / 2,
          offset: Offset(offset.dx, offset.dy / 2),
        ),
      );
    }

    return shadows;
  }

  /// Create custom elevation shadow
  static List<BoxShadow> createElevationShadow({
    double elevation = 4,
    Color color = Colors.black,
    double opacity = 0.1,
  }) {
    return [
      BoxShadow(
        color: color.withValues(alpha: opacity),
        blurRadius: elevation * 2,
        offset: Offset(0, elevation / 2),
        spreadRadius: -(elevation / 4),
      ),
      BoxShadow(
        color: color.withValues(alpha: opacity / 2),
        blurRadius: elevation,
        offset: Offset(0, elevation / 4),
      ),
    ];
  }
}

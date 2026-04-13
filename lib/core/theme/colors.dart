import 'package:flutter/material.dart';

/// Desert Marketplace Color Palette
/// Warm, earthy tones that evoke trust, warmth, and local market authenticity
class AppColors {
  AppColors._();

  // ============================================================================
  // PRIMARY PALETTE - Warm Earth Tones
  // ============================================================================

  /// Primary: Terracotta (warm, inviting, energetic)
  static const Color primaryMain = Color(0xFFD45D42);
  static const Color primaryLight = Color(0xFFE88B75);
  static const Color primaryDark = Color(0xFFA83E2A);
  static const Color primaryContainer = Color(0xFFFFEDE9);
  static const Color onPrimaryContainer = Color(0xFF5C1A0D);

  /// Secondary: Desert Sand (neutral, sophisticated)
  static const Color secondaryMain = Color(0xFFDDC3A5);
  static const Color secondaryLight = Color(0xFFEFDFCC);
  static const Color secondaryDark = Color(0xFFC4A583);
  static const Color secondaryContainer = Color(0xFFF5EDE1);
  static const Color onSecondaryContainer = Color(0xFF3A2F23);

  /// Tertiary: Olive Green (natural, fresh)
  static const Color tertiaryMain = Color(0xFF6B7B5B);
  static const Color tertiaryLight = Color(0xFF9BAC89);
  static const Color tertiaryDark = Color(0xFF4A5940);
  static const Color tertiaryContainer = Color(0xFFEBF0E5);
  static const Color onTertiaryContainer = Color(0xFF1F2419);

  // ============================================================================
  // ACCENT & FUNCTIONAL COLORS
  // ============================================================================

  /// Success: Natural Green
  static const Color successMain = Color(0xFF4A7C59);
  static const Color successLight = Color(0xFF78A886);
  static const Color successDark = Color(0xFF2F5039);
  static const Color successContainer = Color(0xFFD8F3DC);
  static const Color onSuccessContainer = Color(0xFF0A1F12);

  /// Warning: Warm Amber
  static const Color warningMain = Color(0xFFE5A855);
  static const Color warningLight = Color(0xFFF0C27B);
  static const Color warningDark = Color(0xFFB88637);
  static const Color warningContainer = Color(0xFFFFF3D9);
  static const Color onWarningContainer = Color(0xFF2E1F0A);

  /// Error: Soft Red (less aggressive)
  static const Color errorMain = Color(0xFFD64545);
  static const Color errorLight = Color(0xFFE07373);
  static const Color errorDark = Color(0xFFA82E2E);
  static const Color errorContainer = Color(0xFFFFE5E5);
  static const Color onErrorContainer = Color(0xFF330A0A);

  /// Info: Soft Blue (minimal use)
  static const Color infoMain = Color(0xFF5B8DB8);
  static const Color infoLight = Color(0xFF87B3D6);
  static const Color infoDark = Color(0xFF3D5E7A);
  static const Color infoContainer = Color(0xFFE3F2FD);
  static const Color onInfoContainer = Color(0xFF0D1F2E);

  /// Special: Gold Accent (premium, promotions)
  static const Color goldAccent = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFE5CA6F);
  static const Color goldDark = Color(0xFFA68A1F);

  // ============================================================================
  // SURFACES & BACKGROUNDS - Light Mode
  // ============================================================================

  /// Light Mode Surfaces
  static const Color surfacePrimary = Color(0xFFFFFBF7); // Warm white (not stark)
  static const Color surfaceSecondary = Color(0xFFF7F3EE); // Soft beige
  static const Color surfaceElevated = Color(0xFFFFFFFF); // Pure white for cards
  static const Color backgroundLight = Color(0xFFFFFBF7);

  /// Light Mode Background Gradient Colors
  static const List<Color> backgroundGradientLight = [
    Color(0xFFFFFBF7),
    Color(0xFFFFF5EE),
  ];

  // ============================================================================
  // SURFACES & BACKGROUNDS - Dark Mode
  // ============================================================================

  /// Dark Mode Surfaces
  static const Color surfacePrimaryDark = Color(0xFF1C1917); // Warm charcoal
  static const Color surfaceSecondaryDark = Color(0xFF2C2523); // Lighter warm brown
  static const Color surfaceElevatedDark = Color(0xFF362F2D); // Elevated warm surface
  static const Color backgroundDark = Color(0xFF1C1917); // Deep warm black

  /// Dark Mode Background Gradient Colors
  static const List<Color> backgroundGradientDark = [
    Color(0xFF1C1917),
    Color(0xFF2C2523),
  ];

  // ============================================================================
  // TEXT COLORS - Light Mode
  // ============================================================================

  /// Light Mode Text
  static const Color textPrimary = Color(0xFF1C1917); // Warm black
  static const Color textSecondary = Color(0xFF78716C); // Warm gray
  static const Color textTertiary = Color(0xFFA8A29E); // Light warm gray
  static const Color textDisabled = Color(0xFFD6D3D1); // Very light gray

  // ============================================================================
  // TEXT COLORS - Dark Mode
  // ============================================================================

  /// Dark Mode Text
  static const Color textPrimaryDark = Color(0xFFFAFAF9); // Warm white
  static const Color textSecondaryDark = Color(0xFFD6D3D1); // Light warm gray
  static const Color textTertiaryDark = Color(0xFFA8A29E); // Medium gray
  static const Color textDisabledDark = Color(0xFF57534E); // Dark gray

  // ============================================================================
  // SEMANTIC COLORS
  // ============================================================================

  /// Outline colors
  static const Color outlineLight = Color(0xFFD6D3D1);
  static const Color outlineDark = Color(0xFF57534E);

  /// Shadow colors
  static const Color shadowLight = Color(0xFF000000);
  static const Color shadowDark = Color(0xFF000000);

  /// Divider colors
  static const Color dividerLight = Color(0xFFE7E5E4);
  static const Color dividerDark = Color(0xFF44403C);

  // ============================================================================
  // CATEGORY-SPECIFIC GRADIENTS
  // ============================================================================

  /// Electronics gradient
  static const List<Color> electronicsGradient = [
    Color(0xFF5B8DB8),
    Color(0xFF3D5E7A),
  ];

  /// Fashion gradient
  static const List<Color> fashionGradient = [
    Color(0xFFD45D42),
    Color(0xFFA83E2A),
  ];

  /// Food gradient
  static const List<Color> foodGradient = [
    Color(0xFF6B7B5B),
    Color(0xFF4A5940),
  ];

  /// Home & Garden gradient
  static const List<Color> homeGradient = [
    Color(0xFFDDC3A5),
    Color(0xFFC4A583),
  ];

  /// Beauty gradient
  static const List<Color> beautyGradient = [
    Color(0xFFE88B75),
    Color(0xFFD45D42),
  ];

  /// Sports gradient
  static const List<Color> sportsGradient = [
    Color(0xFF4A7C59),
    Color(0xFF2F5039),
  ];

  // ============================================================================
  // PAYMENT METHOD GRADIENTS
  // ============================================================================

  /// Wave payment gradient
  static const List<Color> waveGradient = [
    Color(0xFF00A8CC),
    Color(0xFF0077B6),
  ];

  /// Orange Money gradient
  static const List<Color> orangeMoneyGradient = [
    Color(0xFFFF6B35),
    Color(0xFFFF9F1C),
  ];

  /// Moov Money gradient
  static const List<Color> moovMoneyGradient = [
    Color(0xFF003566),
    Color(0xFF006D77),
  ];

  // ============================================================================
  // ORDER STATUS GRADIENTS
  // ============================================================================

  /// Pending order gradient
  static const List<Color> pendingGradient = [
    Color(0xFFE5A855),
    Color(0xFFB88637),
  ];

  /// Confirmed order gradient
  static const List<Color> confirmedGradient = [
    Color(0xFF5B8DB8),
    Color(0xFF3D5E7A),
  ];

  /// Processing order gradient
  static const List<Color> processingGradient = [
    Color(0xFF9B59B6),
    Color(0xFF6B3E8F),
  ];

  /// Shipped order gradient
  static const List<Color> shippedGradient = [
    Color(0xFFD45D42),
    Color(0xFFA83E2A),
  ];

  /// Delivered order gradient
  static const List<Color> deliveredGradient = [
    Color(0xFF4A7C59),
    Color(0xFF2F5039),
  ];

  /// Cancelled order gradient
  static const List<Color> cancelledGradient = [
    Color(0xFFD64545),
    Color(0xFFA82E2E),
  ];

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Create a LinearGradient from color list
  static LinearGradient createGradient(
    List<Color> colors, {
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) {
    return LinearGradient(
      colors: colors,
      begin: begin,
      end: end,
    );
  }

  /// Create a RadialGradient from color list
  static RadialGradient createRadialGradient(
    List<Color> colors, {
    AlignmentGeometry center = Alignment.center,
    double radius = 1.0,
  }) {
    return RadialGradient(
      colors: colors,
      center: center,
      radius: radius,
    );
  }

  /// Get category gradient by category name
  static List<Color> getCategoryGradient(String category) {
    switch (category.toLowerCase()) {
      case 'electronics':
      case 'électronique':
        return electronicsGradient;
      case 'fashion':
      case 'mode':
      case 'vêtements':
        return fashionGradient;
      case 'food':
      case 'alimentation':
      case 'nourriture':
        return foodGradient;
      case 'home':
      case 'maison':
      case 'jardin':
        return homeGradient;
      case 'beauty':
      case 'beauté':
      case 'cosmétiques':
        return beautyGradient;
      case 'sports':
      case 'sport':
        return sportsGradient;
      default:
        return [primaryMain, primaryDark];
    }
  }
}

/// Extension to easily access colors with opacity
extension ColorExtension on Color {
  /// Create a color with opacity (0.0 to 1.0)
  Color withOpacity(double opacity) => withValues(alpha: opacity);
}

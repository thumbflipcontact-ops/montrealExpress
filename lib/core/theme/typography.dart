import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography system for the app
/// Uses three distinctive fonts for character:
/// - Space Grotesk: Headers, titles, prices (geometric, modern, confident)
/// - DM Sans: Body text, labels, forms (clean, readable, warm)
/// - Sora: Badges, categories, special callouts (geometric with personality)
class AppTypography {
  AppTypography._();

  // ============================================================================
  // FONT FAMILIES
  // ============================================================================

  /// Primary font: Space Grotesk - For headers, titles, prices
  static String get primaryFont => 'Space Grotesk';

  /// Secondary font: DM Sans - For body text, descriptions
  static String get secondaryFont => 'DM Sans';

  /// Accent font: Sora - For badges, chips, special elements
  static String get accentFont => 'Sora';

  // ============================================================================
  // FONT SIZES
  // ============================================================================

  static const double displayLarge = 48.0;
  static const double displayMedium = 45.0;
  static const double displaySmall = 36.0;
  static const double headlineLarge = 32.0;
  static const double headlineMedium = 28.0;
  static const double headlineSmall = 24.0;
  static const double titleLarge = 20.0;
  static const double titleMedium = 16.0;
  static const double titleSmall = 14.0;
  static const double labelLarge = 14.0;
  static const double labelMedium = 12.0;
  static const double labelSmall = 11.0;
  static const double bodyLarge = 16.0;
  static const double bodyMedium = 14.0;
  static const double bodySmall = 12.0;

  // Special sizes
  static const double priceSize = 24.0;
  static const double badgeSize = 12.0;

  // ============================================================================
  // TEXT THEME BUILDER
  // ============================================================================

  /// Build text theme for the app
  static TextTheme buildTextTheme(Brightness brightness) {
    return TextTheme(
      // ========================================================================
      // DISPLAY STYLES - Space Grotesk
      // ========================================================================
      displayLarge: GoogleFonts.spaceGrotesk(
        fontSize: displayLarge,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.1,
      ),
      displayMedium: GoogleFonts.spaceGrotesk(
        fontSize: displayMedium,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.25,
        height: 1.15,
      ),
      displaySmall: GoogleFonts.spaceGrotesk(
        fontSize: displaySmall,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.2,
      ),

      // ========================================================================
      // HEADLINE STYLES - Space Grotesk
      // ========================================================================
      headlineLarge: GoogleFonts.spaceGrotesk(
        fontSize: headlineLarge,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.25,
      ),
      headlineMedium: GoogleFonts.spaceGrotesk(
        fontSize: headlineMedium,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.25,
        height: 1.3,
      ),
      headlineSmall: GoogleFonts.spaceGrotesk(
        fontSize: headlineSmall,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.35,
      ),

      // ========================================================================
      // TITLE STYLES - Space Grotesk
      // ========================================================================
      titleLarge: GoogleFonts.spaceGrotesk(
        fontSize: titleLarge,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.4,
      ),
      titleMedium: GoogleFonts.spaceGrotesk(
        fontSize: titleMedium,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 1.5,
      ),
      titleSmall: GoogleFonts.spaceGrotesk(
        fontSize: titleSmall,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 1.4,
      ),

      // ========================================================================
      // BODY STYLES - DM Sans
      // ========================================================================
      bodyLarge: GoogleFonts.dmSans(
        fontSize: bodyLarge,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.2,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.dmSans(
        fontSize: bodyMedium,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        height: 1.45,
      ),
      bodySmall: GoogleFonts.dmSans(
        fontSize: bodySmall,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        height: 1.4,
      ),

      // ========================================================================
      // LABEL STYLES - Sora
      // ========================================================================
      labelLarge: GoogleFonts.sora(
        fontSize: labelLarge,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        height: 1.4,
      ),
      labelMedium: GoogleFonts.sora(
        fontSize: labelMedium,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.0,
        height: 1.3,
      ),
      labelSmall: GoogleFonts.sora(
        fontSize: labelSmall,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.5,
        height: 1.3,
      ),
    );
  }

  // ============================================================================
  // SPECIAL TEXT STYLES
  // ============================================================================

  /// Price text style - Large, bold, Space Grotesk
  static TextStyle priceStyle({Color? color}) {
    return GoogleFonts.spaceGrotesk(
      fontSize: priceSize,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
      color: color,
      height: 1.2,
    );
  }

  /// Badge text style - Small, bold, Sora
  static TextStyle badgeStyle({Color? color}) {
    return GoogleFonts.sora(
      fontSize: badgeSize,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.0,
      color: color,
      height: 1.2,
    );
  }

  /// Button text style - Medium, bold, Sora
  static TextStyle buttonStyle({Color? color}) {
    return GoogleFonts.sora(
      fontSize: labelLarge,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
      color: color,
      height: 1.2,
    );
  }

  /// Category chip text style - Small, bold, Sora
  static TextStyle categoryChipStyle({Color? color}) {
    return GoogleFonts.sora(
      fontSize: labelMedium,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.8,
      color: color,
      height: 1.2,
    );
  }

  /// Input field text style - Medium, DM Sans
  static TextStyle inputStyle({Color? color}) {
    return GoogleFonts.dmSans(
      fontSize: bodyMedium,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      color: color,
      height: 1.5,
    );
  }

  /// Caption text style - Small, DM Sans
  static TextStyle captionStyle({Color? color}) {
    return GoogleFonts.dmSans(
      fontSize: bodySmall,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
      color: color,
      height: 1.4,
    );
  }
}

// ==============================================================================
// TEXT STYLE EXTENSIONS
// ==============================================================================

/// Extension to add text style utilities to BuildContext
extension TextStyleContext on BuildContext {
  /// Access theme text styles
  TextTheme get textStyles => Theme.of(this).textTheme;

  /// Access color scheme
  ColorScheme get colors => Theme.of(this).colorScheme;
}

/// Helper methods for common text style modifications
extension TextStyleExtensions on TextStyle {
  /// Make text bold (w700)
  TextStyle get bold => copyWith(fontWeight: FontWeight.w700);

  /// Make text semi-bold (w600)
  TextStyle get semiBold => copyWith(fontWeight: FontWeight.w600);

  /// Make text medium weight (w500)
  TextStyle get medium => copyWith(fontWeight: FontWeight.w500);

  /// Make text normal weight (w400)
  TextStyle get normal => copyWith(fontWeight: FontWeight.w400);

  /// Make text light (w300)
  TextStyle get light => copyWith(fontWeight: FontWeight.w300);

  /// Add custom color
  TextStyle withColor(Color color) => copyWith(color: color);

  /// Add custom size
  TextStyle withSize(double size) => copyWith(fontSize: size);

  /// Add custom letter spacing
  TextStyle withLetterSpacing(double spacing) =>
      copyWith(letterSpacing: spacing);

  /// Add custom height
  TextStyle withHeight(double height) => copyWith(height: height);

  /// Make text uppercase
  TextStyle get uppercase => copyWith(
        letterSpacing: (letterSpacing ?? 0) + 1.0,
      );

  /// Add custom font weight
  TextStyle withWeight(FontWeight weight) => copyWith(fontWeight: weight);
}


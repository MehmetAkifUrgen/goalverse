import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Centralized typography hierarchy for Goalverse:
/// - Sora (600, 700, 800): Display headings, page titles, hero areas, game mode names, brand wordmark
/// - Manrope (400, 500, 600, 700): Body text, card descriptions, buttons, menus, forms, bottom nav
/// - SpaceGrotesk (500, 600, 700 + tabularFigures): ELO, XP, Level, Score, Countdown, Rankings
class AppTypography {
  AppTypography._();

  static const String displayFamily = 'Sora';
  static const String bodyFamily = 'Manrope';
  static const String statsFamily = 'SpaceGrotesk';
  static const String numericFamily = 'SpaceGrotesk';

  static const List<String> fallbackFonts = [
    'Roboto',
    '.SF Pro Display',
    '.SF Pro Text',
    'Helvetica Neue',
  ];

  static const List<FontFeature> tabularFigures = [
    FontFeature.tabularFigures(),
  ];

  // ===========================================================================
  // NAMED DESIGN SYSTEM SCALE (Sora / Manrope / Space Grotesk)
  // ===========================================================================

  static TextStyle displayLarge({
    double fontSize = 32,
    Color color = AppColors.textPrimary,
    double letterSpacing = -0.5,
  }) => TextStyle(
    fontFamily: displayFamily,
    fontFamilyFallback: fallbackFonts,
    fontSize: fontSize,
    fontWeight: FontWeight.w800,
    letterSpacing: letterSpacing,
    height: 1.12,
    color: color,
  );

  static TextStyle displayMedium({
    double fontSize = 26,
    Color color = AppColors.textPrimary,
    double letterSpacing = -0.4,
  }) => TextStyle(
    fontFamily: displayFamily,
    fontFamilyFallback: fallbackFonts,
    fontSize: fontSize,
    fontWeight: FontWeight.w700,
    letterSpacing: letterSpacing,
    height: 1.15,
    color: color,
  );

  static TextStyle headlineLarge({
    double fontSize = 22,
    Color color = AppColors.textPrimary,
    double letterSpacing = -0.3,
  }) => TextStyle(
    fontFamily: displayFamily,
    fontFamilyFallback: fallbackFonts,
    fontSize: fontSize,
    fontWeight: FontWeight.w700,
    letterSpacing: letterSpacing,
    height: 1.2,
    color: color,
  );

  static TextStyle headlineMedium({
    double fontSize = 18,
    Color color = AppColors.textPrimary,
    double letterSpacing = -0.2,
  }) => TextStyle(
    fontFamily: displayFamily,
    fontFamilyFallback: fallbackFonts,
    fontSize: fontSize,
    fontWeight: FontWeight.w600,
    letterSpacing: letterSpacing,
    height: 1.22,
    color: color,
  );

  static TextStyle titleLarge({
    double fontSize = 17,
    Color color = AppColors.textPrimary,
  }) => TextStyle(
    fontFamily: displayFamily,
    fontFamilyFallback: fallbackFonts,
    fontSize: fontSize,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.25,
    color: color,
  );

  static TextStyle titleMedium({
    double fontSize = 15,
    Color color = AppColors.textPrimary,
  }) => TextStyle(
    fontFamily: bodyFamily,
    fontFamilyFallback: fallbackFonts,
    fontSize: fontSize,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.1,
    height: 1.3,
    color: color,
  );

  static TextStyle bodyLarge({
    double fontSize = 15,
    Color color = AppColors.textPrimary,
  }) => TextStyle(
    fontFamily: bodyFamily,
    fontFamilyFallback: fallbackFonts,
    fontSize: fontSize,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.0,
    height: 1.45,
    color: color,
  );

  static TextStyle bodyMedium({
    double fontSize = 13.5,
    Color color = AppColors.textSecondary,
  }) => TextStyle(
    fontFamily: bodyFamily,
    fontFamilyFallback: fallbackFonts,
    fontSize: fontSize,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.0,
    height: 1.42,
    color: color,
  );

  static TextStyle labelLarge({
    double fontSize = 14,
    Color color = AppColors.primaryText,
    double letterSpacing = 0.1,
  }) => TextStyle(
    fontFamily: bodyFamily,
    fontFamilyFallback: fallbackFonts,
    fontSize: fontSize,
    fontWeight: FontWeight.w700,
    letterSpacing: letterSpacing,
    height: 1.2,
    color: color,
  );

  static TextStyle numericLarge({
    double fontSize = 28,
    Color color = AppColors.textPrimary,
    double letterSpacing = -0.4,
  }) => TextStyle(
    fontFamily: statsFamily,
    fontFamilyFallback: fallbackFonts,
    fontSize: fontSize,
    fontWeight: FontWeight.w700,
    letterSpacing: letterSpacing,
    height: 1.05,
    fontFeatures: tabularFigures,
    color: color,
  );

  static TextStyle numericMedium({
    double fontSize = 17,
    Color color = AppColors.textPrimary,
    double letterSpacing = -0.2,
  }) => TextStyle(
    fontFamily: statsFamily,
    fontFamilyFallback: fallbackFonts,
    fontSize: fontSize,
    fontWeight: FontWeight.w700,
    letterSpacing: letterSpacing,
    height: 1.15,
    fontFeatures: tabularFigures,
    color: color,
  );

  // ===========================================================================
  // SEMANTIC HELPERS (Used across all screens and widgets)
  // ===========================================================================

  static TextStyle heroDisplay({
    double fontSize = 30,
    Color color = AppColors.textPrimary,
    double letterSpacing = -0.4,
  }) => displayLarge(
    fontSize: fontSize,
    color: color,
    letterSpacing: letterSpacing,
  );

  static TextStyle sectionTitle({
    double fontSize = 20,
    Color color = AppColors.textPrimary,
  }) => headlineLarge(fontSize: fontSize, color: color);

  static TextStyle modeTitle({
    double fontSize = 18,
    Color color = AppColors.textPrimary,
  }) => headlineMedium(fontSize: fontSize, color: color);

  static TextStyle scoreLarge({
    double fontSize = 28,
    Color color = AppColors.textPrimary,
  }) => numericLarge(fontSize: fontSize, color: color);

  static TextStyle statValue({
    double fontSize = 17,
    Color color = AppColors.textPrimary,
    double letterSpacing = -0.2,
  }) => numericMedium(
    fontSize: fontSize,
    color: color,
    letterSpacing: letterSpacing,
  );

  static TextStyle body({
    double fontSize = 14,
    Color color = AppColors.textPrimary,
  }) => bodyLarge(fontSize: fontSize, color: color);

  static TextStyle description({
    double fontSize = 13,
    Color color = AppColors.textSecondary,
  }) => TextStyle(
    fontFamily: bodyFamily,
    fontFamilyFallback: fallbackFonts,
    fontSize: fontSize,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.0,
    height: 1.4,
    color: color,
  );

  static TextStyle label({
    double fontSize = 11.5,
    Color color = AppColors.textSecondary,
    double letterSpacing = 0.2,
    bool tabular = false,
  }) => TextStyle(
    fontFamily: tabular ? statsFamily : bodyFamily,
    fontFamilyFallback: fallbackFonts,
    fontSize: fontSize,
    fontWeight: FontWeight.w600,
    letterSpacing: letterSpacing,
    fontFeatures: tabular ? tabularFigures : null,
    color: color,
  );

  static TextStyle button({
    double fontSize = 14.5,
    Color color = AppColors.primaryText,
  }) => labelLarge(fontSize: fontSize, color: color);

  static TextTheme buildTextTheme(Color primaryColor, Color secondaryColor) {
    return TextTheme(
      displayLarge: displayLarge(color: primaryColor),
      displayMedium: displayMedium(color: primaryColor),
      headlineLarge: headlineLarge(color: primaryColor),
      headlineMedium: headlineMedium(color: primaryColor),
      titleLarge: titleLarge(color: primaryColor),
      titleMedium: titleMedium(color: primaryColor),
      titleSmall: TextStyle(
        fontFamily: bodyFamily,
        fontFamilyFallback: fallbackFonts,
        fontSize: 13.5,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),
      bodyLarge: bodyLarge(color: primaryColor),
      bodyMedium: bodyMedium(color: primaryColor),
      bodySmall: description(fontSize: 12.5, color: secondaryColor),
      labelLarge: labelLarge(color: primaryColor),
    );
  }
}

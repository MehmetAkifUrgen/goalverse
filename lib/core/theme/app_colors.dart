import 'package:flutter/material.dart';

/// Centralized color tokens for Goalverse / Football SOS
/// (Layered Charcoal surfaces, high-contrast Neon Volt focal accents,
/// clean borders, and tactical pitch depth).
class AppColors {
  AppColors._();

  // Core Dark Surfaces (Layered Charcoal & Pitch Depth)
  static const Color backgroundDeep = Color(0xFF0B0D10);
  static const Color background = Color(0xFF101316); // #101316
  static const Color stadiumNight = background;
  static const Color surfaceSubtle = Color(0xFF15191E);
  static const Color surface = Color(0xFF191E23); // #191E23
  static const Color cardBackground = surface;
  static const Color surfaceSecondary = Color(0xFF1E252D);
  static const Color surfaceElevated = Color(0xFF222930); // #222930
  static const Color surfaceHigh = Color(0xFF2A323B);

  // Tactical Pitch Accents
  static const Color pitchGreen = Color(0xFF152219);
  static const Color deepForest = Color(0xFF1C2F23);
  static const Color turfGreen = Color(0xFF244030);

  // Brand & Semantic Tokens
  static const Color primary = Color(0xFFC9FD06); // Neon Volt — #C9FD06
  static const Color secondary = Color(0xFF38BDF8);
  static const Color electricLime = primary;
  static const Color electricCoral = primary;
  static const Color primaryText = Color(0xFF101316);
  static const Color foreground = Color(0xFFF5F7F8);
  static const Color warmWhite = foreground;
  static const Color textPrimary = foreground;
  static const Color muted = Color(0xFFA0A8AF);
  static const Color textSecondary = muted;
  static const Color mutedSubtle = Color(0xFF6E7781);
  static const Color textMuted = mutedSubtle;
  static const Color slateGray = mutedSubtle;

  // Borders & Dividers (Low-contrast, never neon green on ordinary cards)
  static const Color borderSubtle = Color(0xFF232B32);
  static const Color border = Color(0xFF303940); // #303940
  static const Color borderStrong = Color(0xFF3E4952);

  // Status & Game Mode Accents
  static const Color success = Color(0xFF45C486);
  static const Color error = Color(0xFFE34B5F);
  static const Color coralRed = error;
  static const Color warning = Color(0xFFF4C65E);
  static const Color trophyGold = warning;
  static const Color warmAmber = warning;
  static const Color info = Color(0xFF38BDF8);
  static const Color skyBlue = info;
  static const Color cyberCyan = info;
  static const Color aiAccent = Color(0xFF9279EB);
  static const Color softViolet = aiAccent;
  static const Color flameOrange = Color(0xFFFF7A2F);
  static const Color arcticMint = success;

  // Light Mode Counterparts
  static const Color lightBackground = Color(0xFFF3F5F7);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceElevated = Color(0xFFEAEFF3);
  static const Color lightBorder = Color(0xFFD5DCE2);
  static const Color lightForeground = Color(0xFF101316);
  static const Color lightMuted = Color(0xFF5C6670);
  static const Color lightTextPrimary = lightForeground;
  static const Color lightTextSecondary = lightMuted;

  // Controlled Gradients (Used selectively for hero & featured canvases)
  static const LinearGradient heroPitchGradient = LinearGradient(
    colors: [Color(0xFF1A2218), Color(0xFF14191F), Color(0xFF111519)],
    stops: [0.0, 0.55, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient surfaceDepthGradient = LinearGradient(
    colors: [Color(0xFF1E242B), Color(0xFF161B20)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient coralAccentGradient = LinearGradient(
    colors: [Color(0xFFC9FD06), Color(0xFFA4D005)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient mintAccentGradient = LinearGradient(
    colors: [Color(0xFF45C486), Color(0xFF2E9E67)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient violetAccentGradient = LinearGradient(
    colors: [Color(0xFF9279EB), Color(0xFF7052DE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

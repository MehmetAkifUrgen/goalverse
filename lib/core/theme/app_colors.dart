import 'package:flutter/material.dart';

/// Centralized football-themed color tokens for Goalverse / Football SOS
/// (Stadium Night, Pitch Green, Deep Forest, Turf Green, Electric Lime,
/// Warm White, Sky Blue, Trophy Gold, Coral Red, and Slate Gray).
class AppColors {
  AppColors._();

  // Primary Football Stadium & Pitch Surfaces
  static const Color backgroundDeep = Color(0xFF0B1311);
  static const Color stadiumNight = Color(0xFF101B18); // Primary Background
  static const Color background = stadiumNight; // #101B18
  static const Color cardBackground = Color(0xFF1A2922); // Card Surface
  static const Color surface = cardBackground; // #1A2922
  static const Color pitchGreen = Color(0xFF173D2B); // Pitch Base Surface
  static const Color surfaceSecondary = pitchGreen; // #173D2B
  static const Color surfaceSubtle = Color(0xFF15241D);
  static const Color deepForest = Color(0xFF20543A); // Elevated Pitch Surface
  static const Color surfaceElevated = deepForest; // #20543A
  static const Color turfGreen = Color(
    0xFF2D754B,
  ); // Active Turf / Cell Highlight
  static const Color surfaceHigh = turfGreen; // #2D754B

  // Football Brand & Accent Tokens
  static const Color electricLime = Color(0xFFC6F36B); // Primary Accent
  static const Color skyBlue = Color(0xFF72B7E8); // Opponent / Secondary Accent
  static const Color trophyGold = Color(0xFFF3C969); // Series / Trophy / Draw
  static const Color coralRed = Color(0xFFF07870); // Error / Wrong / Danger

  // Backwards-compatible aliases mapped to the football palette
  static const Color electricCoral = electricLime;
  static const Color arcticMint = turfGreen;
  static const Color softViolet = skyBlue;
  static const Color warmAmber = trophyGold;

  static const Color primary = electricLime; // #C6F36B
  static const Color secondary = skyBlue; // #72B7E8
  static const Color primaryText = stadiumNight; // #101B18 on Electric Lime

  // Typography Colors
  static const Color warmWhite = Color(0xFFF5F5ED); // Primary Text
  static const Color slateGray = Color(0xFF82918A); // Secondary / Muted Text
  static const Color textPrimary = warmWhite; // #F5F5ED
  static const Color textSecondary = Color(0xFFB8C7BF);
  static const Color textMuted = slateGray; // #82918A

  static const Color foreground = textPrimary;
  static const Color muted = textSecondary;
  static const Color mutedSubtle = textMuted;

  // Borders & Pitch Lines
  static const Color borderSubtle = Color(0xFF24382D);
  static const Color border = Color(0xFF30483A); // #30483A
  static const Color borderStrong = Color(0xFF426651);

  // Semantic Colors
  static const Color success = electricLime; // #C6F36B
  static const Color error = coralRed; // #F07870
  static const Color warning = trophyGold; // #F3C969
  static const Color info = skyBlue; // #72B7E8

  // Mode & Feature Accent Aliases
  static const Color aiAccent = skyBlue;
  static const Color cyberCyan = skyBlue;
  static const Color flameOrange = coralRed;

  // Light Mode Counterparts (Harmonized Warm Pitch Daylight & Stadium Slate)
  static const Color lightBackground = Color(0xFFF3F5EF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceElevated = Color(0xFFE6ECE8);
  static const Color lightBorder = Color(0xFFCBD8CF);
  static const Color lightForeground = Color(0xFF101B18);
  static const Color lightMuted = Color(0xFF4E6158);
  static const Color lightTextPrimary = lightForeground;
  static const Color lightTextSecondary = lightMuted;

  // Controlled Football Pitch Gradients
  static const LinearGradient heroPitchGradient = LinearGradient(
    colors: [Color(0xFF20543A), Color(0xFF173D2B), Color(0xFF101B18)],
    stops: [0.0, 0.55, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient coralAccentGradient = LinearGradient(
    colors: [Color(0xFFC6F36B), Color(0xFF9ED844)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient mintAccentGradient = LinearGradient(
    colors: [Color(0xFF2D754B), Color(0xFF20543A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient violetAccentGradient = LinearGradient(
    colors: [Color(0xFF72B7E8), Color(0xFF4D94C7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient surfaceDepthGradient = LinearGradient(
    colors: [Color(0xFF20543A), Color(0xFF1A2922)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

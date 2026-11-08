import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'app_colors.dart';
import 'app_radius.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

export 'app_colors.dart';
export 'app_motion.dart';
export 'app_radius.dart';
export 'app_shadows.dart';
export 'app_spacing.dart';
export 'app_typography.dart';

class AppTheme {
  // Core Tokens Bridged from AppColors (Midnight Indigo & Electric Coral)
  static const Color background = AppColors.background;
  static const Color surface = AppColors.surface;
  static const Color surfaceElevated = AppColors.surfaceElevated;
  static const Color surfaceSecondary = AppColors.surfaceSecondary;
  static const Color primary = AppColors.electricCoral;
  static const Color secondary = AppColors.arcticMint;
  static const Color primaryText = AppColors.primaryText;
  static const Color foreground = AppColors.textPrimary;
  static const Color muted = AppColors.textSecondary;
  static const Color border = AppColors.border;
  static const Color success = AppColors.success;
  static const Color error = AppColors.error;
  static const Color warning = AppColors.warning;
  static const Color info = AppColors.info;
  static const Color aiAccent = AppColors.softViolet;
  static const Color cyberCyan = AppColors.info;

  // Spacing & Radius Bridged Tokens
  static const double screenHorizontalPadding = AppSpacing.screenHorizontal;
  static const double cardPadding = AppSpacing.md;
  static const double cardRadius = AppRadius.md;
  static const double cardRadiusLarge = AppRadius.lg;
  static const double pillRadius = AppRadius.sm;

  // Light Mode Aliases
  static const Color lightBg = AppColors.lightBackground;
  static const Color lightSurface = AppColors.lightSurface;
  static const Color lightSurfaceElevated = AppColors.lightSurfaceElevated;
  static const Color lightBorder = AppColors.lightBorder;
  static const Color lightTextPrimary = AppColors.lightForeground;
  static const Color lightTextSecondary = AppColors.lightMuted;
  static const Color lightPrimaryAccent = AppColors.electricCoral;

  // Dark Mode Aliases
  static const Color darkBg = AppColors.background;
  static const Color darkSurface = AppColors.surface;
  static const Color darkSurfaceElevated = AppColors.surfaceElevated;
  static const Color darkBorder = AppColors.border;
  static const Color darkTextPrimary = AppColors.textPrimary;
  static const Color textPrimary = AppColors.textPrimary;
  static const Color darkTextSecondary = AppColors.textSecondary;

  // Semantic Aliases for Existing Game Modes
  static const Color primaryEmerald = AppColors.arcticMint;
  static const Color accentEmerald = AppColors.arcticMint;
  static const Color trophyGold = AppColors.warmAmber;
  static const Color electricViolet = AppColors.softViolet;
  static const Color crimsonStrike = AppColors.error;
  static const Color primaryGreen = AppColors.arcticMint;
  static const Color lightGreen = AppColors.arcticMint;
  static const Color accentGreen = AppColors.arcticMint;
  static const Color pitchGreen = AppColors.arcticMint;
  static const Color pitchEmerald = AppColors.arcticMint;
  static const Color goldTrophy = AppColors.warmAmber;
  static const Color crimsonAlert = AppColors.error;
  static const Color cardDark = AppColors.surface;
  static const Color white = Colors.white;
  static const Color black = Colors.black;

  // Controlled Brand Gradients
  static const LinearGradient stadiumHeroGradient = AppColors.heroPitchGradient;
  static const LinearGradient primaryVoltGradient =
      AppColors.coralAccentGradient;
  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFE6A85C), Color(0xFFD08B38)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient emeraldGradient = AppColors.mintAccentGradient;

  static const List<FontFeature> tabularFigures = AppTypography.tabularFigures;

  /// Helper for scoreboard numbers, timers, and ELO counters using SpaceGrotesk.
  static TextStyle scoreboardNumberStyle({
    double fontSize = 20,
    FontWeight fontWeight = FontWeight.w700,
    Color color = foreground,
    double letterSpacing = -0.3,
  }) {
    return TextStyle(
      fontFamily: AppTypography.statsFamily,
      fontFamilyFallback: AppTypography.fallbackFonts,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      fontFeatures: tabularFigures,
    );
  }

  static Color hexToColor(String? hex, [Color fallback = surfaceElevated]) {
    if (hex == null || hex.isEmpty) return fallback;
    try {
      final clean = hex.replaceAll('#', '');
      return Color(int.parse('FF$clean', radix: 16));
    } catch (_) {
      return fallback;
    }
  }

  static String nationalityFlag(String? code) {
    if (code == null || code.isEmpty) return '🌍';
    const map = {
      'BR': '🇧🇷',
      'FR': '🇫🇷',
      'ES': '🇪🇸',
      'DE': '🇩🇪',
      'EN': '🏴󠁧󠁢󠁥󠁮󠁧󠁿',
      'GB': '🇬🇧',
      'WAL': '🏴󠁧󠁢󠁷󠁬󠁳󠁿',
      'IT': '🇮🇹',
      'AR': '🇦🇷',
      'PT': '🇵🇹',
      'NL': '🇳🇱',
      'TR': '🇹🇷',
      'BE': '🇧🇪',
      'HR': '🇭🇷',
      'UY': '🇺🇾',
      'PL': '🇵🇱',
      'NO': '🇳🇴',
      'SE': '🇸🇪',
      'DK': '🇩🇰',
      'EG': '🇪🇬',
      'NG': '🇳🇬',
      'SN': '🇸🇳',
      'CI': '🇨🇮',
      'CM': '🇨🇲',
      'GH': '🇬🇭',
      'MA': '🇲🇦',
      'DZ': '🇩🇿',
      'CO': '🇨🇴',
      'CL': '🇨🇱',
      'RS': '🇷🇸',
      'BA': '🇧🇦',
      'UA': '🇺🇦',
      'RO': '🇷🇴',
      'CZ': '🇨🇿',
      'AT': '🇦🇹',
      'CH': '🇨🇭',
      'US': '🇺🇸',
      'JP': '🇯🇵',
      'KR': '🇰🇷',
      'CR': '🇨🇷',
      'GA': '🇬🇦',
      'AM': '🇦🇲',
      'AU': '🇦🇺',
      'IE': '🇮🇪',
      'ML': '🇲🇱',
      'LR': '🇱🇷',
      'TG': '🇹🇬',
      'BY': '🇧🇾',
      'PE': '🇵🇪',
      'MK': '🇲🇰',
      'GR': '🇬🇷',
    };
    return map[code.toUpperCase()] ?? '⚽';
  }

  static Color positionColor(String? position) {
    switch ((position ?? '').toUpperCase()) {
      case 'FW':
      case 'ST':
      case 'CF':
      case 'LW':
      case 'RW':
        return AppColors.electricCoral;
      case 'MF':
      case 'CM':
      case 'CAM':
      case 'CDM':
        return AppColors.arcticMint;
      case 'DF':
      case 'CB':
      case 'LB':
      case 'RB':
        return AppColors.info;
      case 'GK':
        return AppColors.warmAmber;
      default:
        return AppColors.softViolet;
    }
  }

  /// Safe club crest widget with fallback shield (never crashes on network/CORS error).
  static Widget clubCrestWidget({
    String? logoUrl,
    String? teamName,
    String? name,
    String? primaryColorHex,
    String? secondaryColorHex,
    double size = 40,
  }) {
    final resolvedName = teamName ?? name ?? 'FC';
    final color = hexToColor(primaryColorHex, surfaceElevated);
    final secColor = hexToColor(
      secondaryColorHex,
      Color.lerp(color, Colors.black, 0.35)!,
    );
    final initials = resolvedName
        .split(' ')
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();

    Widget fallbackShield() {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [color, secColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: AppColors.borderStrong, width: 1.2),
        ),
        alignment: Alignment.center,
        child: Text(
          initials.isEmpty ? 'FC' : initials,
          style: TextStyle(
            fontFamily: AppTypography.displayFamily,
            fontFamilyFallback: AppTypography.fallbackFonts,
            color: foreground,
            fontWeight: FontWeight.w700,
            fontSize: size * 0.36,
            letterSpacing: -0.2,
          ),
        ),
      );
    }

    if (logoUrl == null || logoUrl.isEmpty) {
      return fallbackShield();
    }

    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.11),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: AppColors.border, width: 1.2),
      ),
      child: Image.network(
        logoUrl,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => fallbackShield(),
      ),
    );
  }

  /// Footballer avatar badge with position indicator & OVR ring.
  static Widget playerAvatarWidget({
    required String name,
    int? overall,
    String? position,
    String? nationality,
    double size = 48,
  }) {
    final posColor = positionColor(position);
    final parts = name.trim().split(RegExp(r'\s+'));
    final initials = parts.length >= 2
        ? '${parts.first[0]}${parts.last[0]}'.toUpperCase()
        : (name.isNotEmpty ? name[0].toUpperCase() : '?');

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: surfaceElevated,
        border: Border.all(
          color: (overall ?? 0) >= 90 ? primary : posColor,
          width: (overall ?? 0) >= 90 ? 1.8 : 1.4,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          fontFamily: AppTypography.displayFamily,
          fontFamilyFallback: AppTypography.fallbackFonts,
          color: foreground,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.38,
          letterSpacing: -0.2,
        ),
      ),
    );
  }

  /// AppBar toggle button for switching between 1-Player (Solo) and 2-Player (Duel) mode.
  static Widget modeToggleButton({
    required bool isMultiplayer,
    required ValueChanged<bool> onChanged,
    BuildContext? context,
  }) {
    final l10n = context != null ? AppLocalizations.of(context) : null;
    final label = isMultiplayer
        ? (l10n?.duelMode2P ?? '2P Duel')
        : (l10n?.duelMode1P ?? '1P Solo');
    final activeColor = isMultiplayer ? primary : foreground;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(pillRadius),
        onTap: () => onChanged(!isMultiplayer),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: surfaceElevated,
            borderRadius: BorderRadius.circular(pillRadius),
            border: Border.all(
              color: isMultiplayer ? primary : AppColors.borderSubtle,
              width: 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isMultiplayer ? Icons.people_alt_rounded : Icons.person_rounded,
                size: 15,
                color: activeColor,
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: AppTypography.label(fontSize: 12, color: activeColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// AppBar button to open the Online Room / Matchmaking dialog for any mode.
  static Widget onlineRoomButton({
    required VoidCallback onTap,
    bool isOnlineActive = false,
    BuildContext? context,
  }) {
    final l10n = context != null ? AppLocalizations.of(context) : null;
    final label = isOnlineActive
        ? (l10n?.onlineRoomLive ?? 'Live Room')
        : (l10n?.onlineRoom ?? 'Online Room');
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(pillRadius),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isOnlineActive ? primary : surfaceElevated,
            borderRadius: BorderRadius.circular(pillRadius),
            border: Border.all(
              color: isOnlineActive ? primary : AppColors.borderSubtle,
              width: 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.wifi_tethering_rounded,
                size: 15,
                color: isOnlineActive ? primaryText : AppColors.softViolet,
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: AppTypography.label(
                  fontSize: 12,
                  color: isOnlineActive ? primaryText : foreground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Top scoreboard banner for 2-Player Head-to-Head Duel mode with tabular numbers.
  static Widget duelScoreboardBanner({
    required int p1Score,
    required int p2Score,
    required int currentPlayer, // 0 or 1
    required int currentTurn,
    required int maxTurns,
    BuildContext? context,
  }) {
    final p1Active = currentPlayer == 0;
    final l10n = context != null ? AppLocalizations.of(context) : null;
    final p1Label = l10n?.scoreboardPlayer1 ?? 'Player 1';
    final p2Label = l10n?.scoreboardPlayer2 ?? 'Player 2';
    final roundPrefix = l10n?.roundLabel ?? 'Round';
    final turnText = p1Active
        ? (l10n?.turnP1 ?? 'Turn: P1')
        : (l10n?.turnP2 ?? 'Turn: P2');
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(cardRadius),
        border: Border.all(color: AppColors.borderSubtle, width: 1.0),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: p1Active ? surfaceElevated : Colors.transparent,
                borderRadius: BorderRadius.circular(pillRadius),
                border: Border.all(
                  color: p1Active ? primary : AppColors.borderSubtle,
                  width: p1Active ? 1.4 : 1.0,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: p1Active ? primary : muted,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            p1Label,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.label(
                              fontSize: 12,
                              color: foreground,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '$p1Score',
                    style: scoreboardNumberStyle(
                      fontSize: 17,
                      color: p1Active ? primary : foreground,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$roundPrefix $currentTurn/$maxTurns',
                  style: scoreboardNumberStyle(fontSize: 11.5, color: warning),
                ),
                const SizedBox(height: 2),
                Text(
                  turnText,
                  style: AppTypography.label(
                    fontSize: 10.5,
                    color: p1Active ? primary : secondary,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: !p1Active ? surfaceElevated : Colors.transparent,
                borderRadius: BorderRadius.circular(pillRadius),
                border: Border.all(
                  color: !p1Active ? secondary : AppColors.borderSubtle,
                  width: !p1Active ? 1.4 : 1.0,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: !p1Active ? secondary : muted,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            p2Label,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.label(
                              fontSize: 12,
                              color: foreground,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '$p2Score',
                    style: scoreboardNumberStyle(
                      fontSize: 17,
                      color: !p1Active ? secondary : foreground,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static void showDuelSummaryDialog({
    required BuildContext context,
    required int p1Score,
    required int p2Score,
    required VoidCallback onRematch,
    required VoidCallback onExit,
  }) {
    final l10n = AppLocalizations.of(context);
    final isDraw = p1Score == p2Score;
    final p1Won = p1Score > p2Score;
    final title = isDraw
        ? (l10n?.duelDraw ?? 'Duel Draw')
        : (p1Won
            ? (l10n?.player1Won ?? 'Player 1 Won')
            : (l10n?.player2Won ?? 'Player 2 Won'));

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: AppTypography.sectionTitle(),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n?.twoPlayerDuelResult ?? '2-Player Duel Result',
              style: AppTypography.description(),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: surfaceElevated,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Text(
                'P1: $p1Score   —   P2: $p2Score',
                textAlign: TextAlign.center,
                style: scoreboardNumberStyle(fontSize: 20, color: primary),
              ),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          OutlinedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              onExit();
            },
            child: Text(l10n?.mainMenuButton ?? 'Main Menu'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(ctx).pop();
              onRematch();
            },
            icon: const Icon(Icons.replay_rounded, size: 18),
            label: Text(l10n?.playAgainButton ?? 'Play Again'),
          ),
        ],
      ),
    );
  }

  static ThemeData get lightTheme {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: lightPrimaryAccent,
      onPrimary: Colors.white,
      secondary: secondary,
      onSecondary: primaryText,
      tertiary: aiAccent,
      onTertiary: Colors.white,
      error: error,
      onError: Colors.white,
      surface: lightSurface,
      onSurface: lightTextPrimary,
      onSurfaceVariant: lightTextSecondary,
      surfaceContainerHighest: lightSurfaceElevated,
      outline: lightBorder,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: lightBg,
      fontFamily: AppTypography.bodyFamily,
      textTheme: AppTypography.buildTextTheme(
        lightTextPrimary,
        lightTextSecondary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: lightBg,
        foregroundColor: lightTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.sectionTitle(color: lightTextPrimary),
      ),
      cardTheme: CardThemeData(
        color: lightSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: const BorderSide(color: lightBorder, width: 1),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: lightSurface,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadiusLarge),
          side: const BorderSide(color: lightBorder, width: 1),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: lightSurface,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightSurfaceElevated,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: lightBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: lightBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: primaryText,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: AppTypography.button(color: primaryText),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: lightTextPrimary,
          side: const BorderSide(color: lightBorder, width: 1.2),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: AppTypography.button(color: lightTextPrimary),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: lightSurfaceElevated,
        selectedColor: primary.withValues(alpha: 0.22),
        side: const BorderSide(color: lightBorder, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(pillRadius),
        ),
        labelStyle: AppTypography.label(fontSize: 13, color: lightTextPrimary),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: primaryText,
        elevation: 2,
      ),
      dividerTheme: const DividerThemeData(
        color: lightBorder,
        thickness: 1,
        space: 1,
      ),
      dividerColor: lightBorder,
    );
  }

  static ThemeData get darkTheme {
    const scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: primary,
      onPrimary: primaryText,
      secondary: secondary,
      onSecondary: primaryText,
      tertiary: aiAccent,
      onTertiary: primaryText,
      error: error,
      onError: foreground,
      surface: surface,
      onSurface: foreground,
      onSurfaceVariant: muted,
      surfaceContainerHighest: surfaceElevated,
      outline: AppColors.border,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      fontFamily: AppTypography.bodyFamily,
      textTheme: AppTypography.buildTextTheme(foreground, muted),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: foreground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.sectionTitle(color: foreground),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: const BorderSide(color: AppColors.borderSubtle, width: 1),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadiusLarge),
          side: const BorderSide(color: border, width: 1.0),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceSecondary,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        labelStyle: AppTypography.label(
          fontSize: 13.5,
          color: AppColors.textSecondary,
        ),
        hintStyle: AppTypography.description(
          fontSize: 13.5,
          color: AppColors.textMuted,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: primary, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: error, width: 1.4),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: primaryText,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: AppTypography.button(color: primaryText),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: foreground,
          side: const BorderSide(color: border, width: 1.2),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: AppTypography.button(color: foreground),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceElevated,
        selectedColor: primary.withValues(alpha: 0.22),
        side: const BorderSide(color: AppColors.borderSubtle, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(pillRadius),
        ),
        labelStyle: AppTypography.label(fontSize: 13, color: foreground),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: primaryText,
        elevation: 2,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderSubtle,
        thickness: 1,
        space: 1,
      ),
      dividerColor: AppColors.borderSubtle,
    );
  }
}

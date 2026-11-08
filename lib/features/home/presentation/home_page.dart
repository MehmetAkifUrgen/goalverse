import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/monetization/ad_service.dart';
import '../../../core/monetization/monetization_l10n.dart';
import '../../../core/monetization/premium_service.dart';
import '../../../core/providers/auth_providers.dart';
import '../../../core/providers/leaderboard_provider.dart';
import '../../../core/providers/settings_and_stats_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/stadium_visuals.dart';
import '../../game/presentation/online_lobby_dialog.dart';
import '../../leaderboard/presentation/leaderboard_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  String _divisionName(int rating, AppLocalizations l10n) {
    if (rating >= 1400) return l10n.leagueLegend;
    if (rating >= 1200) return l10n.leagueElite;
    if (rating >= 1050) return l10n.leaguePro;
    return l10n.leagueStarter;
  }

  int _calculateLevel(int gamesPlayed, int wins) {
    final xp = (gamesPlayed * 40) + (wins * 80);
    return (xp ~/ 200) + 1;
  }

  double _calculateLevelProgress(int gamesPlayed, int wins) {
    final xp = (gamesPlayed * 40) + (wins * 80);
    return (xp % 200) / 200.0;
  }

  int _calculateCurrentXp(int gamesPlayed, int wins) {
    final xp = (gamesPlayed * 40) + (wins * 80);
    return xp % 200;
  }

  void _openOnlineLobby(
    BuildContext context, {
    String initialMode = 'sos',
    int initialTab = 0,
  }) {
    showDialog<void>(
      context: context,
      builder: (_) =>
          OnlineLobbyDialog(initialMode: initialMode, initialTab: initialTab),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(currentUserProvider);
    final authRepo = ref.watch(authRepositoryProvider);
    final stats = ref.watch(userStatsProvider);
    final topEntries = ref.watch(topThreeLeaderboardProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final displayName = (stats.customDisplayName?.isNotEmpty ?? false)
        ? stats.customDisplayName!
        : (user?.displayName?.isNotEmpty ?? false)
        ? user!.displayName!
        : (user?.email?.isNotEmpty ?? false)
        ? user!.email!.split('@').first
        : l10n.defaultCaptainName;

    final level = _calculateLevel(stats.gamesPlayed, stats.wins);
    final levelProgress = _calculateLevelProgress(
      stats.gamesPlayed,
      stats.wins,
    );
    final currentXp = _calculateCurrentXp(stats.gamesPlayed, stats.wins);
    final division = _divisionName(stats.rating, l10n);

    return Scaffold(
      extendBody: false,
      backgroundColor: isDark
          ? AppColors.background
          : AppColors.lightBackground,
      body: StadiumPitchBackground(
        child: SafeArea(
          bottom: false,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1040),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenHorizontal,
                  AppSpacing.s12,
                  AppSpacing.screenHorizontal,
                  AppSpacing.s32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // =========================================================
                    // 1. UNIFIED PLAYER COMMAND HEADER (Avatar, LVL, XP, ELO, Division, Streak, Settings)
                    // =========================================================
                    StaggeredEntrance(
                      index: 0,
                      child: _PlayerCommandHeader(
                        displayName: displayName,
                        photoUrl: user?.photoUrl,
                        level: level,
                        currentXp: currentXp,
                        levelProgress: levelProgress,
                        rating: stats.rating,
                        division: division,
                        streak: stats.currentStreak,
                        onProfileTap: () => context.push('/profile'),
                        onSettingsTap: () => context.push('/settings'),
                        onLogoutTap: () => authRepo.signOut(),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.s16),

                    // =========================================================
                    // 2. GOALVERSE HERO STAGE (Live Event, Solo, Online, Create/Join Room)
                    // =========================================================
                    StaggeredEntrance(
                      index: 1,
                      child: _GoalverseHeroStage(
                        onSoloPlay: () => context.push('/game/solo-ai'),
                        onOnlinePlay: () => _openOnlineLobby(
                          context,
                          initialMode: 'sos',
                          initialTab: 0,
                        ),
                        onCreateRoom: () => _openOnlineLobby(
                          context,
                          initialMode: 'sos',
                          initialTab: 1,
                        ),
                        onJoinRoom: () => _openOnlineLobby(
                          context,
                          initialMode: 'sos',
                          initialTab: 2,
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.s24),

                    // =========================================================
                    // 3. FEATURED GAME MODES (Football SOS & Rating Battle)
                    // =========================================================
                    StaggeredEntrance(
                      index: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _SectionHeader(
                            title: l10n.featuredModes,
                            subtitle: l10n.featuredModesSubtitle,
                            badgeText: l10n.badgePopular,
                            badgeColor: AppColors.electricCoral,
                          ),
                          const SizedBox(height: AppSpacing.s12),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final isCompact = constraints.maxWidth < 560;
                              final sosCard = FeaturedGameCard(
                                title: 'Football SOS',
                                subtitle: l10n.sosCardSubtitle,
                                durationLabel: l10n.thirtySeconds,
                                modeLabel: l10n.oneVsOneSoloOnline,
                                isPrimaryHighlight: true,
                                accentColor: AppColors.electricCoral,
                                graphic: const MiniSosGridGraphic(size: 72),
                                onPlayTap: () => context.push('/game/solo-ai'),
                                onOnlineTap: () => _openOnlineLobby(
                                  context,
                                  initialMode: 'sos',
                                ),
                              );
                              final ratingCard = FeaturedGameCard(
                                title: 'Rating Battle',
                                subtitle: l10n.ratingBattleSubtitle,
                                durationLabel: l10n.fifteenSeconds,
                                modeLabel: l10n.higherLower,
                                isPrimaryHighlight: false,
                                accentColor: AppColors.arcticMint,
                                graphic: const FutMiniCardGraphic(size: 72),
                                onPlayTap: () => context.push('/rating-battle'),
                                onOnlineTap: () => _openOnlineLobby(
                                  context,
                                  initialMode: 'rating_battle',
                                ),
                              );

                              if (isCompact) {
                                return Column(
                                  children: [
                                    sosCard,
                                    const SizedBox(height: AppSpacing.s12),
                                    ratingCard,
                                  ],
                                );
                              }
                              return Row(
                                children: [
                                  Expanded(child: sosCard),
                                  const SizedBox(width: AppSpacing.s12),
                                  Expanded(child: ratingCard),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.s24),

                    // =========================================================
                    // 4. ARCADE MODES (5 Distinct Modes)
                    // =========================================================
                    StaggeredEntrance(
                      index: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _SectionHeader(
                            title: l10n.arcadeModes,
                            subtitle: l10n.arcadeModesSubtitle,
                            badgeText: l10n.badgeModesCount,
                            badgeColor: AppColors.softViolet,
                          ),
                          const SizedBox(height: AppSpacing.s12),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final width = constraints.maxWidth;
                              final crossAxisCount = width >= 860
                                  ? 3
                                  : width >= 540
                                  ? 2
                                  : 1;

                              final modes = [
                                GameModeCard(
                                  title: l10n.twoTeamsTitle,
                                  subtitle: l10n.twoTeamsSubtitle,
                                  playerCountLabel: l10n.oneToTwoOnlineLabel,
                                  durationLabel: l10n.twentyFiveSeconds,
                                  statusLabel: l10n.twoTeamsStatus,
                                  accentColor: AppColors.info,
                                  illustration:
                                      const TwoTeamsBridgeIllustration(
                                        size: 56,
                                      ),
                                  onTap: () => context.push('/two-teams'),
                                  onOnlineTap: () => _openOnlineLobby(
                                    context,
                                    initialMode: 'two_teams',
                                  ),
                                ),
                                GameModeCard(
                                  title: l10n.whoAmITitle,
                                  subtitle: l10n.whoAmISubtitle,
                                  playerCountLabel: l10n.oneToTwoOnlineLabel,
                                  durationLabel: l10n.fiveClues,
                                  statusLabel: l10n.whoAmIStatus,
                                  accentColor: AppColors.warmAmber,
                                  illustration:
                                      const WhoAmISilhouetteIllustration(
                                        size: 56,
                                      ),
                                  onTap: () => context.push('/who-am-i'),
                                  onOnlineTap: () => _openOnlineLobby(
                                    context,
                                    initialMode: 'who_am_i',
                                  ),
                                ),
                                GameModeCard(
                                  title: l10n.imposterTitle,
                                  subtitle: l10n.imposterSubtitle,
                                  playerCountLabel: l10n.oneToTwoOnlineLabel,
                                  durationLabel: l10n.twentySeconds,
                                  statusLabel: l10n.imposterStatus,
                                  accentColor: AppColors.error,
                                  illustration: const ImposterRadarIllustration(
                                    size: 56,
                                  ),
                                  onTap: () => context.push('/imposter'),
                                  onOnlineTap: () => _openOnlineLobby(
                                    context,
                                    initialMode: 'imposter',
                                  ),
                                ),
                                GameModeCard(
                                  title: l10n.transferPathTitle,
                                  subtitle: l10n.transferPathSubtitle,
                                  playerCountLabel: l10n.oneToTwoOnlineLabel,
                                  durationLabel: l10n.threePlusClubs,
                                  statusLabel: l10n.transferPathStatus,
                                  accentColor: AppColors.softViolet,
                                  illustration:
                                      const TransferTimelineIllustration(
                                        size: 56,
                                      ),
                                  onTap: () => context.push('/transfer-path'),
                                  onOnlineTap: () => _openOnlineLobby(
                                    context,
                                    initialMode: 'transfer_path',
                                  ),
                                ),
                                GameModeCard(
                                  title: l10n.footballBombTitle,
                                  subtitle: l10n.footballBombSubtitle,
                                  playerCountLabel: l10n.partyModeLabel,
                                  durationLabel: l10n.eighteenSeconds,
                                  statusLabel: l10n.footballBombStatus,
                                  accentColor: AppColors.electricCoral,
                                  illustration: const BombCountdownIllustration(
                                    size: 56,
                                  ),
                                  onTap: () => context.push('/football-bomb'),
                                  onOnlineTap: () => _openOnlineLobby(
                                    context,
                                    initialMode: 'football_bomb',
                                  ),
                                ),
                              ];

                              if (crossAxisCount == 1) {
                                return Column(
                                  children: [
                                    for (var i = 0; i < modes.length; i++) ...[
                                      modes[i],
                                      if (i < modes.length - 1)
                                        const SizedBox(height: AppSpacing.s12),
                                    ],
                                  ],
                                );
                              }

                              final childWidth =
                                  (width - (crossAxisCount - 1) * 12) /
                                  crossAxisCount;
                              const targetHeight = 136.0;
                              final aspectRatio = (childWidth / targetHeight)
                                  .clamp(1.75, 2.95);

                              return GridView.count(
                                crossAxisCount: crossAxisCount,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                childAspectRatio: aspectRatio,
                                children: modes,
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.s24),

                    // =========================================================
                    // 5. DAILY CHALLENGE & LEADERBOARD SHOWCASE (Visually Distinct Cards)
                    // =========================================================
                    StaggeredEntrance(
                      index: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _SectionHeader(
                            title: l10n.dailyAndRanking,
                            subtitle: l10n.dailyAndRankingSubtitle,
                            badgeText: l10n.seasonOne,
                            badgeColor: AppColors.warmAmber,
                          ),
                          const SizedBox(height: AppSpacing.s12),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final isCompact = constraints.maxWidth < 580;
                              final dailyCard = ChallengeCard(
                                title: l10n.dailyChallenge,
                                subtitle: l10n.dailyChallengeSubtitle,
                                rewardLabel: '+150 XP • 1.5x ELO',
                                completedCount: stats.wins > 0 ? 1 : 0,
                                totalCount: 1,
                                onTap: () => context.push('/daily-challenge'),
                              );
                              final leaderboardCard = LeaderboardCard(
                                title: l10n.leaderboard,
                                userRating: stats.rating,
                                userDivision: division,
                                userName: displayName,
                                topEntries: topEntries,
                                onTap: () => context.push('/leaderboard'),
                              );

                              if (isCompact) {
                                return Column(
                                  children: [
                                    dailyCard,
                                    const SizedBox(height: AppSpacing.s12),
                                    leaderboardCard,
                                  ],
                                );
                              }
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: dailyCard),
                                  const SizedBox(width: AppSpacing.s12),
                                  Expanded(child: leaderboardCard),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.s20),

                    // =========================================================
                    // 6. FOOTBALL SOS PRO & COSMETIC STORE BAR + ADMOB BANNER
                    // =========================================================
                    _MonetizationQuickBar(
                      onProTap: () => context.push('/premium'),
                      onStoreTap: () => context.push('/store'),
                    ),
                    const SizedBox(height: AppSpacing.s12),
                    const AdBannerSlot(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: GoalverseBottomNav(
        isDark: isDark,
        activeIndex: 0,
        onArenaTap: () {},
        onOnlineTap: () => _openOnlineLobby(context, initialMode: 'sos'),
        onDailyTap: () => context.push('/daily-challenge'),
        onRankingTap: () => context.push('/leaderboard'),
        onProfileTap: () => context.push('/profile'),
      ),
    );
  }
}

// =============================================================================
// 1. UNIFIED PLAYER COMMAND HEADER
// =============================================================================
class _PlayerCommandHeader extends StatelessWidget {
  final String displayName;
  final String? photoUrl;
  final int level;
  final int currentXp;
  final double levelProgress;
  final int rating;
  final String division;
  final int streak;
  final VoidCallback onProfileTap;
  final VoidCallback onSettingsTap;
  final VoidCallback onLogoutTap;

  const _PlayerCommandHeader({
    required this.displayName,
    this.photoUrl,
    required this.level,
    required this.currentXp,
    required this.levelProgress,
    required this.rating,
    required this.division,
    required this.streak,
    required this.onProfileTap,
    required this.onSettingsTap,
    required this.onLogoutTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.s12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : AppColors.lightSurface,
        borderRadius: AppRadius.borderLg,
        border: Border.all(
          color: isDark ? AppColors.borderSubtle : AppColors.lightBorder,
        ),
        boxShadow: isDark ? AppShadows.cardSubtle : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // Avatar + Name + Level & XP Progress
              Expanded(
                child: PressableScale(
                  semanticLabel: l10n.profileSemanticLabel(displayName, level),
                  onTap: onProfileTap,
                  child: Row(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.surfaceElevated
                                  : AppColors.lightSurfaceElevated,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: AppColors.electricCoral.withValues(
                                  alpha: 0.75,
                                ),
                                width: 1.5,
                              ),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: (photoUrl != null && photoUrl!.isNotEmpty)
                                ? Image.network(
                                    photoUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => const Center(
                                      child: Icon(
                                        Icons.person_rounded,
                                        color: AppColors.electricCoral,
                                        size: 24,
                                      ),
                                    ),
                                  )
                                : const Center(
                                    child: Icon(
                                      Icons.sports_soccer_rounded,
                                      color: AppColors.electricCoral,
                                      size: 24,
                                    ),
                                  ),
                          ),
                          Positioned(
                            right: -4,
                            bottom: -4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.arcticMint,
                                borderRadius: AppRadius.pillBorder,
                                border: Border.all(
                                  color: AppColors.background,
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                'L$level',
                                style: AppTypography.numericMedium(
                                  fontSize: 10,
                                  color: AppColors.primaryText,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    displayName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.titleMedium(
                                      fontSize: 15.5,
                                      color: isDark
                                          ? AppColors.textPrimary
                                          : AppColors.lightTextPrimary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.warmAmber.withValues(
                                      alpha: 0.16,
                                    ),
                                    borderRadius: AppRadius.pillBorder,
                                  ),
                                  child: Text(
                                    division,
                                    style: AppTypography.label(
                                      fontSize: 10,
                                      color: AppColors.warmAmber,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Expanded(
                                  child: SmoothProgressBar(
                                    progress: levelProgress.clamp(0.12, 1.0),
                                    height: 6,
                                    color: AppColors.arcticMint,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '$currentXp/200 XP',
                                  style: AppTypography.label(
                                    fontSize: 10.5,
                                    color: isDark
                                        ? AppColors.textMuted
                                        : AppColors.lightTextSecondary,
                                    tabular: true,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconActionButton(
                icon: Icons.tune_rounded,
                tooltip: l10n.settings,
                size: 38,
                onTap: onSettingsTap,
              ),
              const SizedBox(width: 6),
              IconActionButton(
                icon: Icons.logout_rounded,
                tooltip: l10n.logout,
                size: 38,
                onTap: onLogoutTap,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.surfaceSecondary
                  : AppColors.lightSurfaceElevated,
              borderRadius: AppRadius.borderSm,
            ),
            child: Row(
              children: [
                Expanded(
                  child: _MetricInlinePill(
                    icon: Icons.workspace_premium_rounded,
                    iconColor: AppColors.electricCoral,
                    label: 'ELO',
                    value: '$rating',
                  ),
                ),
                Container(
                  width: 1,
                  height: 18,
                  color: isDark
                      ? AppColors.borderSubtle
                      : AppColors.lightBorder,
                ),
                Expanded(
                  child: _MetricInlinePill(
                    icon: Icons.shield_outlined,
                    iconColor: AppColors.softViolet,
                    label: l10n.leagueLabel,
                    value: division,
                    isNumeric: false,
                  ),
                ),
                Container(
                  width: 1,
                  height: 18,
                  color: isDark
                      ? AppColors.borderSubtle
                      : AppColors.lightBorder,
                ),
                Expanded(
                  child: _MetricInlinePill(
                    icon: Icons.local_fire_department_rounded,
                    iconColor: AppColors.warmAmber,
                    label: l10n.streakLabel,
                    value: l10n.streakMatchesCount(streak),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricInlinePill extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final bool isNumeric;

  const _MetricInlinePill({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.isNumeric = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 15, color: iconColor),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            '$label: ',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.label(
              fontSize: 11,
              color: isDark
                  ? AppColors.textMuted
                  : AppColors.lightTextSecondary,
            ),
          ),
        ),
        Flexible(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: isNumeric
                ? AppTypography.numericMedium(
                    fontSize: 12.5,
                    color: isDark
                        ? AppColors.textPrimary
                        : AppColors.lightTextPrimary,
                  )
                : AppTypography.label(
                    fontSize: 11.5,
                    color: isDark
                        ? AppColors.textPrimary
                        : AppColors.lightTextPrimary,
                  ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// 2. GOALVERSE HERO STAGE (Solo Play, Online Play, Create Room, Join Room)
// =============================================================================
class _GoalverseHeroStage extends StatelessWidget {
  final VoidCallback onSoloPlay;
  final VoidCallback onOnlinePlay;
  final VoidCallback onCreateRoom;
  final VoidCallback onJoinRoom;

  const _GoalverseHeroStage({
    required this.onSoloPlay,
    required this.onOnlinePlay,
    required this.onCreateRoom,
    required this.onJoinRoom,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: isDark ? AppColors.heroPitchGradient : null,
        color: isDark ? null : AppColors.lightSurface,
        borderRadius: AppRadius.heroBorder,
        border: Border.all(
          color: isDark ? AppColors.border : AppColors.lightBorder,
          width: 1.2,
        ),
        boxShadow: isDark ? AppShadows.hero : null,
      ),
      child: ClipRRect(
        borderRadius: AppRadius.heroBorder,
        child: Stack(
          children: [
            // Controlled Electric Coral & Soft Violet glow in top-right
            Positioned(
              right: -35,
              top: -45,
              child: IgnorePointer(
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.electricCoral.withValues(alpha: 0.16),
                        AppColors.softViolet.withValues(alpha: 0.06),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Tactical Pitch Geometry on right side
            Positioned(
              right: -10,
              bottom: -15,
              top: -15,
              width: 210,
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _HeroTacticalPitchPainter(
                    lineColor: AppColors.arcticMint.withValues(alpha: 0.10),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(AppSpacing.s20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Brand & Featured Live Event Badge
                  Row(
                    children: [
                      const GoalverseEmblem(size: 32, showGlow: false),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.electricCoral.withValues(
                              alpha: 0.15,
                            ),
                            borderRadius: AppRadius.pillBorder,
                            border: Border.all(
                              color: AppColors.electricCoral.withValues(
                                alpha: 0.4,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: AppColors.electricCoral,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  '${AppConstants.appBrandUpper} • ${l10n.seasonDerbyWeek}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.label(
                                    fontSize: 10.5,
                                    color: AppColors.electricCoral,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.s16),

                  // Sora ExtraBold Hero Headline
                  Text(
                    l10n.heroHeadline,
                    style: AppTypography.displayLarge(
                      fontSize: 30,
                      color: isDark
                          ? AppColors.textPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.s8),

                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Text(
                      l10n.heroSubtitle,
                      style: AppTypography.bodyMedium(
                        color: isDark
                            ? AppColors.textSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.s20),

                  // Primary & Secondary CTA Row (Solo Play + Online Play)
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isNarrow = constraints.maxWidth < 380;
                      if (isNarrow) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ArenaButton(
                              label: l10n.soloPlay,
                              icon: Icons.play_arrow_rounded,
                              onTap: onSoloPlay,
                              expand: true,
                            ),
                            const SizedBox(height: AppSpacing.s8),
                            SecondaryButton(
                              label: l10n.onlineMatch,
                              icon: Icons.wifi_tethering_rounded,
                              iconColor: AppColors.arcticMint,
                              onTap: onOnlinePlay,
                              expand: true,
                            ),
                          ],
                        );
                      }
                      return Row(
                        children: [
                          Expanded(
                            child: ArenaButton(
                              label: l10n.soloPlay,
                              icon: Icons.play_arrow_rounded,
                              onTap: onSoloPlay,
                              expand: true,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s12),
                          Expanded(
                            child: SecondaryButton(
                              label: l10n.onlineMatch,
                              icon: Icons.wifi_tethering_rounded,
                              iconColor: AppColors.arcticMint,
                              onTap: onOnlinePlay,
                              expand: true,
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: AppSpacing.s12),

                  // Quick Room Actions (Create Room / Join Room)
                  Row(
                    children: [
                      Expanded(
                        child: _HeroRoomActionPill(
                          icon: Icons.add_circle_outline_rounded,
                          label: l10n.createPrivateRoom,
                          accentColor: AppColors.softViolet,
                          onTap: onCreateRoom,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s8),
                      Expanded(
                        child: _HeroRoomActionPill(
                          icon: Icons.dialpad_rounded,
                          label: l10n.joinWithCode,
                          accentColor: AppColors.warmAmber,
                          onTap: onJoinRoom,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroRoomActionPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color accentColor;
  final VoidCallback onTap;

  const _HeroRoomActionPill({
    required this.icon,
    required this.label,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PressableScale(
      semanticLabel: label,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.surfaceSecondary.withValues(alpha: 0.85)
              : AppColors.lightSurfaceElevated,
          borderRadius: AppRadius.borderSm,
          border: Border.all(
            color: isDark ? AppColors.borderSubtle : AppColors.lightBorder,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: accentColor),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.label(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.textPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroTacticalPitchPainter extends CustomPainter {
  final Color lineColor;

  const _HeroTacticalPitchPainter({required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    final center = Offset(size.width * 0.62, size.height * 0.48);
    canvas.drawCircle(center, 54, paint);
    canvas.drawCircle(center, 22, paint);
    canvas.drawLine(
      Offset(center.dx, 0),
      Offset(center.dx, size.height),
      paint,
    );

    final boxRect = Rect.fromCenter(
      center: Offset(size.width * 0.85, size.height * 0.48),
      width: 68,
      height: 120,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(boxRect, const Radius.circular(8)),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _HeroTacticalPitchPainter oldDelegate) =>
      oldDelegate.lineColor != lineColor;
}

// =============================================================================
// 3. FEATURED SHOWCASE CARD (Football SOS & Rating Battle)
// =============================================================================
class FeaturedGameCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String durationLabel;
  final String modeLabel;
  final bool isPrimaryHighlight;
  final Color accentColor;
  final Widget graphic;
  final VoidCallback onPlayTap;
  final VoidCallback onOnlineTap;

  const FeaturedGameCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.durationLabel,
    required this.modeLabel,
    required this.isPrimaryHighlight,
    this.accentColor = AppColors.electricCoral,
    required this.graphic,
    required this.onPlayTap,
    required this.onOnlineTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PressableScale(
      semanticLabel: '$title: $subtitle',
      onTap: onPlayTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.s16),
        decoration: BoxDecoration(
          gradient: isDark ? AppColors.surfaceDepthGradient : null,
          color: isDark ? null : AppColors.lightSurface,
          borderRadius: AppRadius.largeCardBorder,
          border: Border.all(
            color: accentColor.withValues(
              alpha: isPrimaryHighlight ? 0.55 : 0.35,
            ),
            width: isPrimaryHighlight ? 1.4 : 1.1,
          ),
          boxShadow: isDark ? AppShadows.card : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                graphic,
                const SizedBox(width: AppSpacing.s16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          _CleanPill(text: modeLabel, textColor: accentColor),
                          _CleanPill(text: durationLabel, isTabular: true),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        title,
                        style: AppTypography.headlineLarge(
                          fontSize: 20,
                          color: isDark
                              ? AppColors.textPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.description(
                          fontSize: 12.5,
                          color: isDark
                              ? AppColors.textSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s16),
            Row(
              children: [
                Expanded(
                  child: PressableScale(
                    onTap: onPlayTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: AppRadius.borderSm,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.play_arrow_rounded,
                            size: 18,
                            color: AppColors.primaryText,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            l10n.playNow,
                            style: AppTypography.button(
                              fontSize: 13.5,
                              color: AppColors.primaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                PressableScale(
                  onTap: onOnlineTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.surfaceElevated
                          : AppColors.lightSurfaceElevated,
                      borderRadius: AppRadius.borderSm,
                      border: Border.all(
                        color: isDark
                            ? AppColors.border
                            : AppColors.lightBorder,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.wifi_tethering_rounded,
                          size: 16,
                          color: accentColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          l10n.liveOneVsOne,
                          style: AppTypography.label(
                            fontSize: 12.5,
                            color: isDark
                                ? AppColors.textPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// 4. ARCADE GAME MODE TILE (GameModeCard)
// =============================================================================
class GameModeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String playerCountLabel;
  final String durationLabel;
  final String statusLabel;
  final Color accentColor;
  final IconData? icon;
  final Widget? illustration;
  final VoidCallback onTap;
  final VoidCallback? onOnlineTap;

  const GameModeCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.playerCountLabel,
    required this.durationLabel,
    required this.statusLabel,
    required this.accentColor,
    this.icon,
    this.illustration,
    required this.onTap,
    this.onOnlineTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PressableScale(
      semanticLabel: '$title: $subtitle',
      duration: AppMotion.cardSelect,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surface : AppColors.lightSurface,
          borderRadius: AppRadius.cardBorder,
          border: Border.all(
            color: isDark ? AppColors.borderSubtle : AppColors.lightBorder,
          ),
          boxShadow: isDark ? AppShadows.cardSubtle : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            illustration ??
                ModeBadgeGraphic(
                  icon: icon ?? Icons.sports_soccer_rounded,
                  accentColor: accentColor,
                  badgeText: statusLabel,
                  size: 56,
                ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.modeTitle(
                            fontSize: 17,
                            color: isDark
                                ? AppColors.textPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      _CleanPill(
                        text: durationLabel,
                        textColor: accentColor,
                        isTabular: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.description(
                      fontSize: 12.5,
                      color: isDark
                          ? AppColors.textSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        playerCountLabel,
                        style: AppTypography.label(
                          fontSize: 11,
                          color: isDark
                              ? AppColors.textMuted
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (onOnlineTap != null) ...[
                            InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: onOnlineTap,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.wifi_tethering_rounded,
                                      size: 13,
                                      color: AppColors.softViolet,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      l10n.roomPlayAction,
                                      style: AppTypography.label(
                                        fontSize: 11.5,
                                        color: isDark
                                            ? AppColors.textPrimary
                                            : AppColors.lightTextPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                l10n.playAction,
                                style: AppTypography.label(
                                  fontSize: 12,
                                  color: accentColor,
                                ),
                              ),
                              const SizedBox(width: 2),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 15,
                                color: accentColor,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// 5. DAILY CHALLENGE CARD (Quest, Reward, Progress & Completion Status)
// =============================================================================
class ChallengeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String rewardLabel;
  final int completedCount;
  final int totalCount;
  final VoidCallback onTap;

  const ChallengeCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.rewardLabel,
    this.completedCount = 0,
    this.totalCount = 1,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDone = completedCount >= totalCount;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

    return PressableScale(
      semanticLabel: '$title: $subtitle',
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.s16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surface : AppColors.lightSurface,
          borderRadius: AppRadius.largeCardBorder,
          border: Border.all(
            color: isDone
                ? AppColors.arcticMint.withValues(alpha: 0.6)
                : AppColors.warmAmber.withValues(alpha: 0.45),
          ),
          boxShadow: isDark ? AppShadows.cardSubtle : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.warmAmber.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(
                    Icons.bolt_rounded,
                    color: AppColors.warmAmber,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.modeTitle(
                          fontSize: 18,
                          color: isDark
                              ? AppColors.textPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        rewardLabel,
                        style: AppTypography.label(
                          fontSize: 11.5,
                          color: AppColors.warmAmber,
                          tabular: true,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: isDone
                        ? AppColors.arcticMint.withValues(alpha: 0.18)
                        : AppColors.surfaceElevated,
                    borderRadius: AppRadius.pillBorder,
                  ),
                  child: Text(
                    isDone ? l10n.completedBadge : l10n.activeQuest,
                    style: AppTypography.label(
                      fontSize: 10.5,
                      color: isDone
                          ? AppColors.arcticMint
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: AppTypography.description(
                fontSize: 12.5,
                color: isDark
                    ? AppColors.textSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SmoothProgressBar(
                    progress: isDone ? 1.0 : progress.clamp(0.35, 1.0),
                    height: 7,
                    color: isDone ? AppColors.arcticMint : AppColors.warmAmber,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  isDone ? l10n.rewardClaimed : '${l10n.startQuest} →',
                  style: AppTypography.label(
                    fontSize: 11.5,
                    color: isDone ? AppColors.arcticMint : AppColors.warmAmber,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// 6. LEADERBOARD PREVIEW CARD (Top 3 Hierarchy + User's Current Rank)
// =============================================================================
class LeaderboardCard extends StatelessWidget {
  final String title;
  final int userRating;
  final String userDivision;
  final String userName;
  final List<LeaderboardEntry> topEntries;
  final VoidCallback onTap;

  const LeaderboardCard({
    super.key,
    required this.title,
    required this.userRating,
    required this.userDivision,
    required this.userName,
    this.topEntries = const [],
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final top1 = topEntries.isNotEmpty ? topEntries[0] : null;
    final top2 = topEntries.length > 1 ? topEntries[1] : null;
    final top3 = topEntries.length > 2 ? topEntries[2] : null;

    final rank1Name = top1 != null ? top1.name : userName;
    final rank1Elo = top1 != null ? '${top1.rating}' : '$userRating';

    final rank2Name = top2 != null ? top2.name : (topEntries.isEmpty ? '-' : l10n.rankCaptain);
    final rank2Elo = top2 != null ? '${top2.rating}' : '-';

    final rank3Name = top3 != null ? top3.name : (topEntries.isEmpty ? '-' : l10n.rankStar);
    final rank3Elo = top3 != null ? '${top3.rating}' : '-';

    return PressableScale(
      semanticLabel: l10n.leaderboardCardSemanticLabel(title, userRating),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.s16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surface : AppColors.lightSurface,
          borderRadius: AppRadius.largeCardBorder,
          border: Border.all(
            color: AppColors.arcticMint.withValues(alpha: 0.4),
          ),
          boxShadow: isDark ? AppShadows.cardSubtle : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.arcticMint.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(
                    Icons.emoji_events_rounded,
                    color: AppColors.arcticMint,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.modeTitle(
                          fontSize: 18,
                          color: isDark
                              ? AppColors.textPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.leaderboardSubtitle,
                        style: AppTypography.description(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.textSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.arcticMint,
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Mini Top 3 Podium Hierarchy
            Row(
              children: [
                Expanded(
                  child: _MiniPodiumBadge(
                    rank: 1,
                    label: '#1 $rank1Name',
                    elo: rank1Elo,
                    color: AppColors.warmAmber,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MiniPodiumBadge(
                    rank: 2,
                    label: '#2 $rank2Name',
                    elo: rank2Elo,
                    color: AppColors.info,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MiniPodiumBadge(
                    rank: 3,
                    label: '#3 $rank3Name',
                    elo: rank3Elo,
                    color: AppColors.softViolet,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // User's own standing bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.surfaceSecondary
                    : AppColors.lightSurfaceElevated,
                borderRadius: AppRadius.borderSm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      '${l10n.youPlayerPrefix}: $userName ($userDivision)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.label(
                        fontSize: 11.5,
                        color: isDark
                            ? AppColors.textPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                  ),
                  Text(
                    '$userRating ELO',
                    style: AppTypography.numericMedium(
                      fontSize: 13,
                      color: AppColors.arcticMint,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniPodiumBadge extends StatelessWidget {
  final int rank;
  final String label;
  final String elo;
  final Color color;

  const _MiniPodiumBadge({
    required this.rank,
    required this.label,
    required this.elo,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.label(
              fontSize: 10.5,
              color: isDark
                  ? AppColors.textPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$elo ELO',
            style: AppTypography.numericMedium(fontSize: 11, color: color),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// SECTION HEADER & CLEAN PILL HELPERS
// =============================================================================
class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? badgeText;
  final Color badgeColor;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    this.badgeText,
    this.badgeColor = AppColors.electricCoral,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.headlineLarge(
                  fontSize: 20,
                  color: isDark
                      ? AppColors.textPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.description(
                  fontSize: 12.5,
                  color: isDark
                      ? AppColors.textSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ),
        if (badgeText != null) ...[
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.14),
              borderRadius: AppRadius.pillBorder,
              border: Border.all(color: badgeColor.withValues(alpha: 0.4)),
            ),
            child: Text(
              badgeText!,
              style: AppTypography.label(
                fontSize: 10.5,
                color: badgeColor,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _CleanPill extends StatelessWidget {
  final String text;
  final Color? textColor;
  final bool isTabular;

  const _CleanPill({
    required this.text,
    this.textColor,
    this.isTabular = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceElevated
            : AppColors.lightSurfaceElevated,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: AppTypography.label(
          fontSize: 10.5,
          color:
              textColor ??
              (isDark ? AppColors.textSecondary : AppColors.lightTextSecondary),
          tabular: isTabular,
        ),
      ),
    );
  }
}

// =============================================================================
// 6. BOTTOM NAVIGATION BAR (FIXED AT SCREEN BOTTOM — NEVER FLOATS IN CENTER)
// =============================================================================
class GoalverseBottomNav extends StatelessWidget {
  final bool isDark;
  final int activeIndex;
  final VoidCallback onArenaTap;
  final VoidCallback onOnlineTap;
  final VoidCallback onDailyTap;
  final VoidCallback onRankingTap;
  final VoidCallback onProfileTap;

  const GoalverseBottomNav({
    super.key,
    required this.isDark,
    this.activeIndex = 0,
    required this.onArenaTap,
    required this.onOnlineTap,
    required this.onDailyTap,
    required this.onRankingTap,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final arenaLabel = l10n?.navArena ?? 'ARENA';
    final onlineLabel = l10n?.navOnline ?? 'ONLINE';
    final dailyLabel = l10n?.navDaily ?? 'DAILY';
    final rankingLabel = l10n?.navRanking ?? 'RANKING';
    final profileLabel = l10n?.navProfile ?? 'PROFILE';
    // Uses Column(mainAxisSize: MainAxisSize.min) inside DecoratedBox + SafeArea
    // so it strictly occupies only its intrinsic bottom height (never expanding
    // vertically into the middle of the screen).
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceSecondary : AppColors.lightSurface,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.borderSubtle : AppColors.lightBorder,
            width: 1.0,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: _NavTabItem(
                  icon: Icons.sports_soccer_rounded,
                  label: arenaLabel,
                  active: activeIndex == 0,
                  onTap: onArenaTap,
                ),
              ),
              Expanded(
                child: _NavTabItem(
                  icon: Icons.wifi_tethering_rounded,
                  label: onlineLabel,
                  active: activeIndex == 1,
                  onTap: onOnlineTap,
                ),
              ),
              Expanded(
                child: _NavTabItem(
                  icon: Icons.calendar_today_rounded,
                  label: dailyLabel,
                  active: activeIndex == 2,
                  onTap: onDailyTap,
                ),
              ),
              Expanded(
                child: _NavTabItem(
                  icon: Icons.emoji_events_rounded,
                  label: rankingLabel,
                  active: activeIndex == 3,
                  onTap: onRankingTap,
                ),
              ),
              Expanded(
                child: _NavTabItem(
                  icon: Icons.person_outline_rounded,
                  label: profileLabel,
                  active: activeIndex == 4,
                  onTap: onProfileTap,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavTabItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavTabItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.electricCoral : AppColors.textMuted;

    return PressableScale(
      semanticLabel: label,
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: AppMotion.fast,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
            decoration: BoxDecoration(
              color: active
                  ? AppColors.electricCoral.withValues(alpha: 0.16)
                  : Colors.transparent,
              borderRadius: AppRadius.pillBorder,
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.label(
              fontSize: 10,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _MonetizationQuickBar extends ConsumerWidget {
  final VoidCallback onProTap;
  final VoidCallback onStoreTap;

  const _MonetizationQuickBar({
    required this.onProTap,
    required this.onStoreTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPro = ref.watch(isPremiumActiveProvider);
    final mL10n = MonetizationL10n.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Expanded(
          child: PressableScale(
            onTap: onProTap,
            child: Container(
              key: const Key('home_pro_entry_card'),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surface : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.trophyGold.withValues(alpha: 0.55),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.workspace_premium_rounded,
                    color: AppColors.trophyGold,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isPro
                          ? mL10n.tr('pro_active_badge')
                          : mL10n.tr('pro_title'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.label(
                        fontSize: 12,
                        color: AppColors.trophyGold,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: AppColors.trophyGold,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: PressableScale(
            onTap: onStoreTap,
            child: Container(
              key: const Key('home_store_entry_card'),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surface : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.electricLime.withValues(alpha: 0.55),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.storefront_rounded,
                    color: AppColors.electricLime,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      mL10n.tr('store_title'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.label(
                        fontSize: 12,
                        color: AppColors.electricLime,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: AppColors.electricLime,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

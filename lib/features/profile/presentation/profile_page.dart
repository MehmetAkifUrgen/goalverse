import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/monetization/cosmetic_store_service.dart';
import '../../../core/monetization/monetization_l10n.dart';
import '../../../core/monetization/premium_service.dart';
import '../../../core/providers/auth_providers.dart';
import '../../../core/providers/settings_and_stats_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  static const _countries = <(String, String)>[
    ('TR', 'Türkiye'),
    ('BR', 'Brezilya'),
    ('FR', 'Fransa'),
    ('ES', 'İspanya'),
    ('DE', 'Almanya'),
    ('EN', 'İngiltere'),
    ('IT', 'İtalya'),
    ('AR', 'Arjantin'),
    ('PT', 'Portekiz'),
    ('NL', 'Hollanda'),
  ];

  void _showEditProfileDialog(
    BuildContext context,
    WidgetRef ref,
    String currentName,
    String currentCountry,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final nameCtrl = TextEditingController(text: currentName);
    String selectedCountry = currentCountry;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(l10n.editProfile),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: l10n.playerName,
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.countryFlag,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _countries.map((c) {
                  final code = c.$1;
                  final label = c.$2;
                  final flag = AppTheme.nationalityFlag(code);
                  final isSel = selectedCountry.toUpperCase() == code;
                  return ChoiceChip(
                    label: Text('$flag $label'),
                    selected: isSel,
                    onSelected: (_) {
                      setDialogState(() => selectedCountry = code);
                    },
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                final notifier = ref.read(userStatsProvider.notifier);
                await notifier.setCustomDisplayName(nameCtrl.text);
                await notifier.setCountry(selectedCountry);
                if (ctx.mounted) Navigator.of(ctx).pop();
              },
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final mL10n = MonetizationL10n.of(context);
    final user = ref.watch(currentUserProvider);
    final stats = ref.watch(userStatsProvider);
    final isPro = ref.watch(isPremiumActiveProvider);
    final entitlement = ref.watch(premiumServiceProvider);
    final cosmeticNotifier = ref.read(cosmeticStoreServiceProvider.notifier);
    final frameBorderColor = cosmeticNotifier.resolveProfileFrameColor(
      isProActive: isPro,
    );
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final displayName = (stats.customDisplayName?.isNotEmpty ?? false)
        ? stats.customDisplayName!
        : (user?.displayName?.isNotEmpty ?? false)
        ? user!.displayName!
        : (user?.email?.isNotEmpty ?? false)
        ? user!.email!.split('@').first
        : (l10n.playerDefault);

    final division = stats.rating >= 1600
        ? 'ELITE PRO'
        : stats.rating >= 1300
        ? 'CHAMPIONS'
        : stats.rating >= 1100
        ? 'PRO LEAGUE'
        : 'RISING STAR';

    final achievementsList =
        <({String id, String title, String howTo, IconData icon, Color color})>[
          (
            id: 'firstWin',
            title: l10n.firstWin,
            howTo: l10n.achievementFirstWinHowTo,
            icon: Icons.emoji_events_rounded,
            color: const Color(0xFFF59E0B),
          ),
          (
            id: 'wins10',
            title: l10n.wins10,
            howTo: l10n.achievementWins10HowTo,
            icon: Icons.military_tech_rounded,
            color: const Color(0xFF3B82F6),
          ),
          (
            id: 'wins100',
            title: l10n.wins100,
            howTo: l10n.achievementWins100HowTo,
            icon: Icons.workspace_premium_rounded,
            color: const Color(0xFF8B5CF6),
          ),
          (
            id: 'perfectGame',
            title: l10n.perfectGame,
            howTo: l10n.achievementPerfectGameHowTo,
            icon: Icons.auto_awesome_rounded,
            color: const Color(0xFF10B981),
          ),
          (
            id: 'rarePlayer',
            title: l10n.rarePlayer,
            howTo: l10n.achievementRarePlayerHowTo,
            icon: Icons.diamond_rounded,
            color: const Color(0xFF06B6D4),
          ),
          (
            id: 'comeback',
            title: l10n.comeback,
            howTo: l10n.achievementComebackHowTo,
            icon: Icons.bolt_rounded,
            color: const Color(0xFFF97316),
          ),
          (
            id: 'winStreak5',
            title: l10n.winStreak5,
            howTo: l10n.achievementStreak5HowTo,
            icon: Icons.local_fire_department_rounded,
            color: const Color(0xFFEF4444),
          ),
          (
            id: 'winStreak10',
            title: l10n.winStreak10,
            howTo: l10n.achievementStreak10HowTo,
            icon: Icons.whatshot_rounded,
            color: const Color(0xFFEC4899),
          ),
        ];

    final flag = AppTheme.nationalityFlag(stats.country);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profile),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 22),
            tooltip: 'Profili Düzenle',
            onPressed: () => _showEditProfileDialog(
              context,
              ref,
              displayName,
              stats.country,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, size: 22),
            tooltip: l10n.settings,
            onPressed: () => context.push('/settings'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 840),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // FUT Stadium Pro Hero User Card
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: AppTheme.stadiumHeroGradient,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: frameBorderColor.withValues(alpha: 0.7),
                        width: isPro ? 2.2 : 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: AppTheme.goldGradient,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '🏆 $division',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                if (isPro) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    key: const Key('profile_pro_badge'),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 9,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.electricLime,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      mL10n.tr('pro_badge'),
                                      style: const TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF101B18),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            TextButton.icon(
                              onPressed: () => _showEditProfileDialog(
                                context,
                                ref,
                                displayName,
                                stats.country,
                              ),
                              icon: const Icon(
                                Icons.edit_rounded,
                                size: 16,
                                color: AppTheme.accentEmerald,
                              ),
                              label: Text(
                                l10n.changeNameAndFlag,
                                style: const TextStyle(
                                  color: AppTheme.accentEmerald,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        AppTheme.playerAvatarWidget(
                          name: displayName,
                          overall: (stats.rating ~/ 15).clamp(75, 99),
                          position: 'PRO',
                          size: 76,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '$flag $displayName',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        if (user?.email != null && user!.email!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            user.email!,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.accentEmerald.withValues(
                              alpha: 0.16,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.accentEmerald),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.bolt_rounded,
                                color: AppTheme.accentEmerald,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                l10n.eloRatingBadge(stats.rating.toString()),
                                style: const TextStyle(
                                  color: AppTheme.accentEmerald,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (user != null && user.isAnonymous) ...[
                          const SizedBox(height: 14),
                          OutlinedButton.icon(
                            onPressed: () => context.push('/link-account'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white38),
                            ),
                            icon: const Icon(Icons.link_rounded, size: 18),
                            label: Text(l10n.linkAccount),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Statistics Grid
                  Text(
                    l10n.statisticsTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final cols = constraints.maxWidth > 560 ? 3 : 2;
                      return GridView.count(
                        crossAxisCount: cols,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.8,
                        children: [
                          _StatTile(
                            label: l10n.gamesPlayed,
                            value: '${stats.gamesPlayed}',
                            icon: Icons.sports_soccer_rounded,
                            color: const Color(0xFF3B82F6),
                          ),
                          _StatTile(
                            label: l10n.winRate,
                            value: '${stats.winRate.toStringAsFixed(1)}%',
                            icon: Icons.pie_chart_outline_rounded,
                            color: const Color(0xFF10B981),
                          ),
                          _StatTile(
                            label:
                                '${l10n.wins} / ${l10n.losses} / ${l10n.draws}',
                            value:
                                '${stats.wins}G · ${stats.losses}M · ${stats.draws}B',
                            icon: Icons.scoreboard_outlined,
                            color: const Color(0xFF06B6D4),
                          ),
                          _StatTile(
                            label: l10n.bestScore,
                            value: '${stats.bestScore}',
                            icon: Icons.emoji_events_outlined,
                            color: const Color(0xFFF59E0B),
                          ),
                          _StatTile(
                            label: l10n.currentStreak,
                            value: '🔥 ${stats.currentStreak}',
                            icon: Icons.local_fire_department_rounded,
                            color: const Color(0xFFF97316),
                          ),
                          _StatTile(
                            label: l10n.bestStreak,
                            value: '⚡ ${stats.bestStreak}',
                            icon: Icons.trending_up_rounded,
                            color: const Color(0xFF8B5CF6),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 28),

                  // Achievements Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.achievements.toUpperCase(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        '${stats.unlockedAchievements.length} / ${achievementsList.length}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: scheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final cols = constraints.maxWidth > 620 ? 4 : 2;
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: achievementsList.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: cols,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1.45,
                        ),
                        itemBuilder: (context, index) {
                          final ach = achievementsList[index];
                          final unlocked = stats.unlockedAchievements.contains(
                            ach.id,
                          );

                          return InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: Text(ach.title),
                                  content: Text(
                                    unlocked
                                        ? l10n.achievementUnlockedDesc(ach.howTo)
                                        : l10n.achievementLockedDesc(ach.howTo),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(ctx).pop(),
                                      child: Text(l10n.ok),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                                side: BorderSide(
                                  color: unlocked
                                      ? ach.color.withValues(alpha: 0.6)
                                      : theme.dividerColor,
                                  width: unlocked ? 1.8 : 1,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 38,
                                      height: 38,
                                      decoration: BoxDecoration(
                                        color: unlocked
                                            ? ach.color.withValues(alpha: 0.16)
                                            : scheme.surfaceContainerHighest,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        unlocked
                                            ? ach.icon
                                            : Icons.lock_outline_rounded,
                                        size: 20,
                                        color: unlocked
                                            ? ach.color
                                            : scheme.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      ach.title,
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.titleSmall
                                          ?.copyWith(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: unlocked
                                                ? null
                                                : scheme.onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 28),

                  // Football SOS Pro Detailed Analytics & Extended Match History
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          mL10n.tr('detailed_stats_title'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton.icon(
                            onPressed: () => context.push('/store'),
                            icon: const Icon(
                              Icons.storefront_rounded,
                              size: 16,
                            ),
                            label: Text(mL10n.tr('store_title')),
                          ),
                          if (!isPro)
                            TextButton.icon(
                              onPressed: () => context.push('/premium'),
                              icon: const Icon(
                                Icons.workspace_premium_rounded,
                                size: 16,
                                color: AppColors.trophyGold,
                              ),
                              label: Text(
                                mL10n.tr('pro_title'),
                                style: const TextStyle(
                                  color: AppColors.trophyGold,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (!isPro)
                    Card(
                      child: ListTile(
                        leading: const Icon(
                          Icons.lock_outline_rounded,
                          color: AppColors.trophyGold,
                        ),
                        title: Text(mL10n.tr('detailed_stats_locked')),
                        trailing: ElevatedButton(
                          onPressed: () => context.push('/premium'),
                          child: Text(mL10n.tr('pro_badge')),
                        ),
                      ),
                    )
                  else
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text(
                                  l10n.totalPassCount,
                                  style: const TextStyle(fontSize: 11.5),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${stats.recentMatches.fold<int>(0, (s, m) => s + m.passesUsed)}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.electricLime,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  l10n.drawAgreements,
                                  style: const TextStyle(fontSize: 11.5),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${stats.recentMatches.where((m) => m.endedByDrawOffer).length}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.skyBlue,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  l10n.matchHistoryCapacity,
                                  style: const TextStyle(fontSize: 11.5),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${stats.recentMatches.take(entitlement.maxMatchHistoryItems).length} / ${entitlement.maxMatchHistoryItems}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.trophyGold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

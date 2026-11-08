import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/auth_providers.dart';
import '../../../core/providers/settings_and_stats_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';

class LeaderboardEntry {
  final String uid;
  final String name;
  final String country;
  final int rating;
  final int wins;
  final int bestScore;
  final bool isCurrentUser;

  const LeaderboardEntry({
    required this.uid,
    required this.name,
    required this.country,
    required this.rating,
    required this.wins,
    required this.bestScore,
    this.isCurrentUser = false,
  });
}

class LeaderboardPage extends ConsumerStatefulWidget {
  const LeaderboardPage({super.key});

  @override
  ConsumerState<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends ConsumerState<LeaderboardPage> {
  String _selectedTab = 'global';
  bool _loading = true;
  List<LeaderboardEntry> _entries = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadLeaderboard());
  }

  Future<void> _loadLeaderboard() async {
    setState(() => _loading = true);

    final user = ref.read(currentUserProvider);
    final stats = ref.read(userStatsProvider);
    final myUid = user?.uid ?? 'local_user';
    final myName = (stats.customDisplayName?.isNotEmpty ?? false)
        ? stats.customDisplayName!
        : (user?.displayName?.isNotEmpty ?? false)
        ? user!.displayName!
        : (user?.email?.isNotEmpty ?? false)
        ? user!.email!.split('@').first
        : (stats.country == 'TR' ? 'Goalverse Oyuncusu' : 'Goalverse Player');

    final fetched = <LeaderboardEntry>[];

    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .orderBy('rating', descending: true)
          .limit(50)
          .get();

      for (final doc in snap.docs) {
        final data = doc.data();
        final uid = doc.id;
        final rawRating = data['rating'] ?? data['elo'];
        final rating = (rawRating as num?)?.toInt() ?? 1000;
        final wins = (data['wins'] as num?)?.toInt() ?? 0;
        final bestScore = (data['bestScore'] as num?)?.toInt() ?? 0;
        final name = (data['displayName'] as String?)?.trim();
        final country = (data['country'] as String?)?.toUpperCase() ?? 'TR';

        fetched.add(
          LeaderboardEntry(
            uid: uid,
            name: (name != null && name.isNotEmpty) ? name : 'Player',
            country: country,
            rating: rating,
            wins: wins,
            bestScore: bestScore,
            isCurrentUser: uid == myUid,
          ),
        );
      }
    } catch (_) {}

    final combined = <String, LeaderboardEntry>{
      for (final f in fetched) f.uid: f,
    };

    combined[myUid] = LeaderboardEntry(
      uid: myUid,
      name: myName,
      country: stats.country,
      rating: stats.rating,
      wins: stats.wins,
      bestScore: stats.bestScore,
      isCurrentUser: true,
    );

    final list = combined.values.toList()
      ..sort((a, b) => b.rating.compareTo(a.rating));

    if (!mounted) return;
    setState(() {
      _entries = list;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final stats = ref.watch(userStatsProvider);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final filtered = switch (_selectedTab) {
      'country' =>
        _entries
            .where(
              (e) => e.country.toUpperCase() == stats.country.toUpperCase(),
            )
            .toList(),
      'friends' => _entries.where((e) => e.isCurrentUser).toList(),
      _ => _entries,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.leaderboard),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 22),
            onPressed: _loadLeaderboard,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 840),
            child: Column(
              children: [
                // Filter Tabs
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  child: SegmentedButton<String>(
                    segments: [
                      ButtonSegment(
                        value: 'global',
                        icon: const Icon(Icons.public_rounded, size: 18),
                        label: Text(l10n.global),
                      ),
                      ButtonSegment(
                        value: 'country',
                        icon: const Icon(Icons.flag_outlined, size: 18),
                        label: Text('${l10n.country} (${stats.country})'),
                      ),
                      ButtonSegment(
                        value: 'friends',
                        icon: const Icon(
                          Icons.people_outline_rounded,
                          size: 18,
                        ),
                        label: Text(l10n.friends),
                      ),
                    ],
                    selected: {_selectedTab},
                    onSelectionChanged: (sel) {
                      setState(() => _selectedTab = sel.first);
                    },
                  ),
                ),

                if (_loading)
                  const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_selectedTab == 'friends' && filtered.length <= 1)
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.group_add_outlined,
                              size: 56,
                              color: scheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              l10n.noFriends,
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '${l10n.inviteFriend}: ${l10n.heroSubtitle}',
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.share_rounded, size: 18),
                              label: Text(l10n.inviteFriend),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else if (filtered.isEmpty)
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.emoji_events_outlined,
                              size: 56,
                              color: scheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              l10n.noRankingPlayersYet,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else ...[
                  // Stadium Pro Podium (1, 2, or 3 competitors)
                  if (filtered.length == 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      child: Center(
                        child: SizedBox(
                          width: 200,
                          child: _PodiumCard(
                            rank: 1,
                            entry: filtered[0],
                            flag: AppTheme.nationalityFlag(
                              filtered[0].country,
                            ),
                            accentColor: AppTheme.trophyGold,
                            isChampion: true,
                          ),
                        ),
                      ),
                    )
                  else if (filtered.length == 2)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: _PodiumCard(
                              rank: 1,
                              entry: filtered[0],
                              flag: AppTheme.nationalityFlag(
                                filtered[0].country,
                              ),
                              accentColor: AppTheme.trophyGold,
                              isChampion: true,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _PodiumCard(
                              rank: 2,
                              entry: filtered[1],
                              flag: AppTheme.nationalityFlag(
                                filtered[1].country,
                              ),
                              accentColor: const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (filtered.length >= 3)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: _PodiumCard(
                              rank: 2,
                              entry: filtered[1],
                              flag: AppTheme.nationalityFlag(
                                filtered[1].country,
                              ),
                              accentColor: const Color(0xFF94A3B8),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _PodiumCard(
                              rank: 1,
                              entry: filtered[0],
                              flag: AppTheme.nationalityFlag(
                                filtered[0].country,
                              ),
                              accentColor: AppTheme.trophyGold,
                              isChampion: true,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _PodiumCard(
                              rank: 3,
                              entry: filtered[2],
                              flag: AppTheme.nationalityFlag(
                                filtered[2].country,
                              ),
                              accentColor: const Color(0xFFD97706),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Ranked List
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        final rank = index + 1;
                        final flag = AppTheme.nationalityFlag(item.country);

                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: item.isCurrentUser
                                  ? AppTheme.accentEmerald
                                  : Theme.of(context).dividerColor,
                              width: item.isCurrentUser ? 2 : 1,
                            ),
                          ),
                          child: ListTile(
                            leading: Container(
                              width: 36,
                              height: 36,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: rank == 1
                                    ? AppTheme.trophyGold.withValues(
                                        alpha: 0.18,
                                      )
                                    : rank <= 3
                                    ? AppTheme.accentEmerald.withValues(
                                        alpha: 0.14,
                                      )
                                    : scheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '#$rank',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13,
                                  color: rank == 1
                                      ? AppTheme.trophyGold
                                      : rank <= 3
                                      ? AppTheme.accentEmerald
                                      : scheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                            title: Row(
                              children: [
                                Text(flag),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    item.name,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: item.isCurrentUser
                                          ? FontWeight.w900
                                          : FontWeight.w700,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Text(
                              '${l10n.wins}: ${item.wins} · ${l10n.bestScore}: ${item.bestScore}',
                              style: theme.textTheme.bodySmall,
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.accentEmerald.withValues(
                                  alpha: 0.14,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${item.rating} ELO',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                  color: AppTheme.accentEmerald,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PodiumCard extends StatelessWidget {
  final int rank;
  final LeaderboardEntry entry;
  final String flag;
  final Color accentColor;
  final bool isChampion;

  const _PodiumCard({
    required this.rank,
    required this.entry,
    required this.flag,
    required this.accentColor,
    this.isChampion = false,
  });

  @override
  Widget build(BuildContext context) {
    final medal = rank == 1
        ? '🥇'
        : rank == 2
        ? '🥈'
        : '🥉';

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isChampion ? 18 : 12,
        horizontal: 10,
      ),
      decoration: BoxDecoration(
        gradient: isChampion ? AppTheme.stadiumHeroGradient : null,
        color: isChampion ? null : Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: accentColor.withValues(alpha: isChampion ? 0.8 : 0.45),
          width: isChampion ? 2.2 : 1.4,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(medal, style: TextStyle(fontSize: isChampion ? 28 : 22)),
          const SizedBox(height: 6),
          AppTheme.playerAvatarWidget(
            name: entry.name,
            overall: (entry.rating ~/ 20).clamp(78, 96),
            position: 'PRO',
            size: isChampion ? 46 : 38,
          ),
          const SizedBox(height: 8),
          Text(
            '$flag ${entry.name}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: isChampion ? Colors.white : null,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${entry.rating} ELO',
              style: TextStyle(
                color: accentColor,
                fontWeight: FontWeight.w900,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

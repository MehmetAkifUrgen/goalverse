import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/leaderboard/presentation/leaderboard_page.dart';
import 'auth_providers.dart';
import 'settings_and_stats_provider.dart';

/// Fetches the top 50 real player profiles from Firestore ordered by rating.
final globalLeaderboardProvider =
    FutureProvider.autoDispose<List<LeaderboardEntry>>((ref) async {
  final user = ref.watch(currentUserProvider);
  final stats = ref.watch(userStatsProvider);
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
  } catch (_) {
    // If offline or Firestore error, fail gracefully to empty list
  }

  final combined = <String, LeaderboardEntry>{
    for (final f in fetched) f.uid: f,
  };

  // Always register current user's live stats
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

  return list;
});

/// Fetches top 3 players for the Home Page Leaderboard Mini Podium.
final topThreeLeaderboardProvider =
    Provider.autoDispose<List<LeaderboardEntry>>((ref) {
  final asyncVal = ref.watch(globalLeaderboardProvider);
  return asyncVal.when(
    data: (list) => list.take(3).toList(),
    loading: () => const [],
    error: (e, st) => const [],
  );
});

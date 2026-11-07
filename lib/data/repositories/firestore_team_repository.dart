import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/freezed/entity_models.dart';
import 'team_repository.dart';

class FirestoreTeamRepository implements TeamRepository {
  final FirebaseFirestore _firestore;
  final TeamRepository? _localFallback;
  List<Team>? _cachedTeams;

  FirestoreTeamRepository({
    FirebaseFirestore? firestore,
    TeamRepository? localFallback,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _localFallback = localFallback;

  @override
  Future<List<Team>> getAllTeams() async {
    if (_cachedTeams != null && _cachedTeams!.isNotEmpty) {
      return _cachedTeams!;
    }

    if (_localFallback != null) {
      final localTeams = await _localFallback.getAllTeams();
      if (localTeams.isNotEmpty) {
        _cachedTeams = localTeams;
        return localTeams;
      }
    }

    try {
      final snap = await _firestore.collection('teams').limit(500).get();
      if (snap.docs.isNotEmpty) {
        _cachedTeams = snap.docs.map(_mapDocToTeam).toList();
        return _cachedTeams!;
      }
    } catch (_) {}

    return _cachedTeams ?? [];
  }

  @override
  Future<Team?> getById(String teamId) async {
    if (_cachedTeams != null) {
      try {
        return _cachedTeams!.firstWhere((t) => t.id == teamId);
      } catch (_) {}
    }

    if (_localFallback != null) {
      final local = await _localFallback.getById(teamId);
      if (local != null) {
        _cachedTeams = [...?_cachedTeams, local];
        return local;
      }
    }

    try {
      final doc = await _firestore.collection('teams').doc(teamId).get();
      if (doc.exists) {
        final team = _mapDocToTeam(doc);
        _cachedTeams = [...?_cachedTeams, team];
        return team;
      }
    } catch (_) {}

    return null;
  }

  @override
  Future<List<Team>> getByIds(List<String> teamIds) async {
    final all = await getAllTeams();
    final set = teamIds.toSet();
    final result = all.where((t) => set.contains(t.id)).toList();
    if (result.length == teamIds.length) {
      return result;
    }

    // Fetch any missing teams individually
    final foundIds = result.map((t) => t.id).toSet();
    for (final id in teamIds) {
      if (!foundIds.contains(id)) {
        final missing = await getById(id);
        if (missing != null) {
          result.add(missing);
        }
      }
    }
    return result;
  }

  @override
  Future<List<Team>> searchTeams(String query, {int limit = 20}) async {
    final clean = query.trim().toLowerCase();
    if (clean.isEmpty) return [];

    final all = await getAllTeams();
    return all
        .where(
          (t) =>
              t.normalizedName.contains(clean) ||
              t.name.toLowerCase().contains(clean),
        )
        .take(limit)
        .toList();
  }

  @override
  Future<List<(Team a, Team b)>> getTeamPairsWithMinPlayers({
    int minPlayersPerPair = 3,
    int limit = 20,
    int? seed,
  }) async {
    if (_localFallback != null) {
      final pairs = await _localFallback.getTeamPairsWithMinPlayers(
        minPlayersPerPair: minPlayersPerPair,
        limit: limit,
        seed: seed,
      );
      if (pairs.isNotEmpty) {
        return pairs;
      }
    }

    final all = await getAllTeams();
    if (all.length < 2) return [];

    final pairs = <(Team a, Team b)>[];
    final sorted = List<Team>.from(all)..sort((a, b) => a.id.compareTo(b.id));
    if (seed != null) {
      sorted.shuffle();
    } else {
      sorted.shuffle();
    }
    for (int i = 0; i < sorted.length - 1; i += 2) {
      pairs.add((sorted[i], sorted[i + 1]));
      if (pairs.length >= limit) break;
    }
    return pairs;
  }

  Team _mapDocToTeam(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final id = doc.id;
    final numId = id.replaceAll('team_', '');
    final logo =
        data['logoUrl'] as String? ??
        'https://tmssl.akamaized.net/images/wappen/head/$numId.png';

    return Team(
      id: id,
      name: data['name'] as String? ?? 'Team',
      normalizedName: data['normalizedName'] as String? ?? '',
      country: data['country'] as String?,
      logoUrl: logo,
      verified: true,
    );
  }
}

import 'dart:math';

import 'package:isar/isar.dart';

import '../models/freezed/entity_models.dart';
import '../models/isar/answer_index_isar.dart';
import '../models/isar/team_isar.dart';
import 'team_repository.dart';

class IsarTeamRepository implements TeamRepository {
  final Isar isar;

  IsarTeamRepository(this.isar);

  @override
  Future<List<Team>> searchTeams(String query, {int limit = 20}) async {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return [];
    }

    final results = await isar.teamIsars
        .where()
        .filter()
        .normalizedNameContains(normalizedQuery)
        .or()
        .nameContains(query, caseSensitive: false)
        .or()
        .aliasesElementContains(query, caseSensitive: false)
        .sortByNormalizedName()
        .limit(limit)
        .findAll();

    return results.map(_mapToTeam).toList();
  }

  @override
  Future<Team?> getById(String teamId) async {
    final result = await isar.teamIsars
        .where()
        .teamIdEqualTo(teamId)
        .findFirst();
    return result == null ? null : _mapToTeam(result);
  }

  @override
  Future<List<Team>> getAllTeams() async {
    final results = await isar.teamIsars.where().findAll();
    return results.map(_mapToTeam).toList();
  }

  @override
  Future<List<Team>> getByIds(List<String> teamIds) async {
    if (teamIds.isEmpty) return [];
    final results = await isar.teamIsars
        .where()
        .anyOf<String, dynamic>(teamIds, (q, id) => q.teamIdEqualTo(id))
        .findAll();
    return results.map(_mapToTeam).toList();
  }

  @override
  Future<List<(Team a, Team b)>> getTeamPairsWithMinPlayers({
    int minPlayersPerPair = 3,
    int limit = 20,
    int? seed,
  }) async {
    final indexEntries = await isar.answerIndexIsars
        .where()
        .filter()
        .playerIdsElementGreaterThan('0')
        .findAll();
    indexEntries.sort((a, b) => a.teamPair.compareTo(b.teamPair));
    if (seed != null) {
      indexEntries.shuffle(Random(seed));
    }

    final Map<String, (Team a, Team b)> pairMap = {};
    for (final e in indexEntries) {
      if ((e.playerIds.length) < minPlayersPerPair) continue;
      final parts = e.teamPair.split('|');
      if (parts.length != 2) continue;
      final teamA = await getById(parts[0]);
      final teamB = await getById(parts[1]);
      if (teamA == null || teamB == null) continue;
      pairMap[e.teamPair] = (teamA, teamB);
      if (pairMap.length >= limit) break;
    }

    return pairMap.values.toList();
  }

  Team _mapToTeam(TeamIsar t) {
    final numId = t.teamId.replaceAll('team_', '');
    final logoUrl = 'https://tmssl.akamaized.net/images/wappen/head/$numId.png';
    return Team(
      id: t.teamId,
      name: t.name,
      normalizedName: t.normalizedName,
      aliases: t.aliases ?? const [],
      country: t.country,
      verified: t.verified,
      primaryColorHex: t.primaryColorHex,
      secondaryColorHex: t.secondaryColorHex,
      logoUrl: logoUrl,
      logoAssetPath: t.logoAssetPath,
      kitAssetPath: t.kitAssetPath,
    );
  }
}

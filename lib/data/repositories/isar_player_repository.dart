import 'dart:math';

import 'package:isar/isar.dart';

import '../models/freezed/entity_models.dart';
import '../models/isar/player_isar.dart';
import 'player_repository.dart';
import 'rating_category.dart';

class IsarPlayerRepository implements PlayerRepository {
  final Isar isar;

  IsarPlayerRepository(this.isar);

  String _normalizeQuery(String input) {
    final replaced = input
        .replaceAll('İ', 'i')
        .replaceAll('I', 'i')
        .replaceAll('ı', 'i')
        .toLowerCase()
        .replaceAll('ş', 's')
        .replaceAll('ğ', 'g')
        .replaceAll('ü', 'u')
        .replaceAll('ö', 'o')
        .replaceAll('ç', 'c')
        .replaceAll('á', 'a')
        .replaceAll('à', 'a')
        .replaceAll('â', 'a')
        .replaceAll('ã', 'a')
        .replaceAll('ä', 'a')
        .replaceAll('é', 'e')
        .replaceAll('è', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('ë', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ì', 'i')
        .replaceAll('î', 'i')
        .replaceAll('ï', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ò', 'o')
        .replaceAll('ô', 'o')
        .replaceAll('õ', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ù', 'u')
        .replaceAll('û', 'u')
        .replaceAll('ñ', 'n')
        .replaceAll('ć', 'c')
        .replaceAll('č', 'c')
        .replaceAll('š', 's')
        .replaceAll('ž', 'z')
        .replaceAll('ø', 'o')
        .replaceAll('ß', 'ss');
    return replaced
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  @override
  Future<List<Player>> searchPlayers(String query, {int limit = 20}) async {
    final normalizedQuery = _normalizeQuery(query);
    if (normalizedQuery.isEmpty) {
      return [];
    }
    final tokens = normalizedQuery
        .split(' ')
        .where((t) => t.isNotEmpty)
        .toList();
    final firstToken = tokens.first;

    final candidates = await isar.playerIsars
        .where()
        .filter()
        .normalizedNameContains(normalizedQuery)
        .or()
        .normalizedNameContains(firstToken)
        .or()
        .nameContains(query.trim(), caseSensitive: false)
        .or()
        .aliasesElementContains(firstToken, caseSensitive: false)
        .findAll();

    final seenNames = <String>{};
    final matches = <Player>[];

    for (final item in candidates) {
      final pNorm = _normalizeQuery(
        item.normalizedName.isNotEmpty ? item.normalizedName : item.name,
      );
      if (seenNames.contains(pNorm)) continue;

      final aliasesNorm = (item.aliases ?? const [])
          .map(_normalizeQuery)
          .join(' ');
      final searchable = '$pNorm $aliasesNorm';
      if (pNorm.contains(normalizedQuery) ||
          tokens.every((tok) => searchable.contains(tok))) {
        seenNames.add(pNorm);
        matches.add(_mapToPlayer(item));
      }
    }

    matches.sort((a, b) {
      final aNorm = _normalizeQuery(a.normalizedName);
      final bNorm = _normalizeQuery(b.normalizedName);
      final aStarts = aNorm.startsWith(normalizedQuery)
          ? 0
          : (aNorm.split(' ').any((w) => w.startsWith(firstToken)) ? 1 : 2);
      final bStarts = bNorm.startsWith(normalizedQuery)
          ? 0
          : (bNorm.split(' ').any((w) => w.startsWith(firstToken)) ? 1 : 2);
      if (aStarts != bStarts) return aStarts.compareTo(bStarts);
      return (b.eaFcOverall ?? 0).compareTo(a.eaFcOverall ?? 0);
    });

    return matches.take(limit).toList();
  }

  @override
  Future<Player?> getById(String playerId) async {
    final result = await isar.playerIsars
        .where()
        .playerIdEqualTo(playerId)
        .findFirst();
    return result == null ? null : _mapToPlayer(result);
  }

  @override
  Future<List<Player>> getByIds(List<String> playerIds) async {
    if (playerIds.isEmpty) return [];

    final results = await isar.playerIsars
        .where()
        .anyOf<String, dynamic>(playerIds, (q, id) => q.playerIdEqualTo(id))
        .findAll();

    return results.map(_mapToPlayer).toList();
  }

  @override
  Future<List<Player>> searchPlayersWithClues(String query, {int limit = 20}) {
    return searchPlayers(query, limit: limit);
  }

  @override
  Future<Player?> getRandomWhoAmI({int? seed}) async {
    final all = await isar.playerIsars
        .where()
        .filter()
        .cluesIsNotEmpty()
        .findAll();
    if (all.isEmpty) return null;
    all.sort((a, b) => a.playerId.compareTo(b.playerId));
    all.shuffle(seed != null ? Random(seed) : null);
    return _mapToPlayer(all.first);
  }

  @override
  Future<(Player a, Player b)> getRandomRatingPair({
    RatingCategory? category,
    int? seed,
  }) async {
    final rng = seed != null ? Random(seed) : null;
    final cat =
        category ??
        [
          RatingCategory.eaFcOverall,
          RatingCategory.marketValue,
          RatingCategory.age,
          RatingCategory.goalsCareer,
          RatingCategory.assistsCareer,
          RatingCategory.speed,
          RatingCategory.clGoals,
          RatingCategory.ageLOW,
        ][(seed ?? DateTime.now().microsecond).abs() % 8];

    final candidates = await isar.playerIsars
        .where()
        .filter()
        .optional(
          cat == RatingCategory.eaFcOverall,
          (q) => q.eaFcOverallIsNotNull(),
        )
        .optional(
          cat == RatingCategory.marketValue,
          (q) => q.marketValueEuroIsNotNull(),
        )
        .optional(
          cat == RatingCategory.age || cat == RatingCategory.ageLOW,
          (q) => q.ageIsNotNull(),
        )
        .optional(
          cat == RatingCategory.goalsCareer,
          (q) => q.goalsCareerIsNotNull(),
        )
        .optional(
          cat == RatingCategory.assistsCareer,
          (q) => q.assistsCareerIsNotNull(),
        )
        .optional(cat == RatingCategory.speed, (q) => q.speedRatingIsNotNull())
        .optional(cat == RatingCategory.clGoals, (q) => q.clGoalsIsNotNull())
        .findAll();

    final pool = candidates.isEmpty
        ? await isar.playerIsars.where().findAll()
        : candidates;

    pool.sort((a, b) => a.playerId.compareTo(b.playerId));
    pool.shuffle(rng);
    final a = _mapToPlayer(pool.first);
    final valA = cat.valueOf(a);
    final bIsar = pool.skip(1).firstWhere((x) {
      if (x.playerId == a.id) return false;
      final mapped = _mapToPlayer(x);
      final valB = cat.valueOf(mapped);
      return valB != null && valB != valA;
    }, orElse: () => pool.last);
    return (a, _mapToPlayer(bIsar));
  }

  Player _mapToPlayer(PlayerIsar p) {
    return Player(
      id: p.playerId,
      name: p.name,
      normalizedName: p.normalizedName,
      aliases: p.aliases ?? const [],
      nationality: p.nationality,
      position: p.position,
      verified: p.verified,
      eaFcOverall: p.eaFcOverall,
      marketValueEuro: p.marketValueEuro,
      age: p.age,
      goalsCareer: p.goalsCareer,
      assistsCareer: p.assistsCareer,
      speedRating: p.speedRating,
      clGoals: p.clGoals,
      clues: p.clues ?? const [],
      photoAssetPath: p.photoAssetPath,
    );
  }
}

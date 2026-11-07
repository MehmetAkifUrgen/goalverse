import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/freezed/entity_models.dart';
import 'answer_validator_repository.dart';
import 'player_repository.dart';
import 'rating_category.dart';
import 'team_repository.dart';

class TransferStop {
  final Team team;
  final int? seasonStart;
  final int? seasonEnd;

  const TransferStop({required this.team, this.seasonStart, this.seasonEnd});
}

class TransferPathPuzzle {
  final Player player;
  final List<TransferStop> path;
  final String difficulty;

  const TransferPathPuzzle({
    required this.player,
    required this.path,
    required this.difficulty,
  });
}

class ImposterOption {
  final Player player;
  final bool isImposter;

  const ImposterOption({required this.player, required this.isImposter});
}

class ImposterPuzzle {
  final Team targetTeam;
  final String ruleDescription;
  final List<ImposterOption> options;
  final String explanation;

  const ImposterPuzzle({
    required this.targetTeam,
    required this.ruleDescription,
    required this.options,
    required this.explanation,
  });
}

class BombChallenge {
  final String id;
  final String prompt;
  final Team? targetTeam;
  final String? targetNationality;
  final int initialTimerSeconds;
  final Set<String> validPlayerIds;

  const BombChallenge({
    required this.id,
    required this.prompt,
    this.targetTeam,
    this.targetNationality,
    required this.initialTimerSeconds,
    required this.validPlayerIds,
  });
}

class WebDataStore {
  static final WebDataStore instance = WebDataStore._internal();
  WebDataStore._internal();

  bool _initialized = false;
  Future<void>? _initFuture;

  final List<Team> _teams = [];
  final List<Player> _players = [];
  final List<PlayerTeamHistory> _history = [];
  final Map<String, List<String>> _answerIndex = {};
  final Map<String, Set<String>> _teamToPlayers = {};
  final Map<String, List<PlayerTeamHistory>> _playerToHistory = {};

  late final TeamRepository teamRepo = _WebTeamRepository(this);
  late final AnswerValidatorRepository answerRepo =
      _WebAnswerValidatorRepository(this);
  late final PlayerRepository playerRepo = _WebPlayerRepository(this);

  List<Team> get teams => List.unmodifiable(_teams);
  List<Player> get players => List.unmodifiable(_players);

  Future<void> init() {
    if (_initialized) return Future.value();
    _initFuture ??= _doInit();
    return _initFuture!;
  }

  Future<void> _doInit() async {
    try {
      final teamsRaw = await rootBundle.loadString('assets/dataset/teams.json');
      final teamsList = jsonDecode(teamsRaw) as List;
      _teams.clear();
      for (final t in teamsList) {
        _teams.add(Team.fromJson(t as Map<String, dynamic>));
      }

      final indexRaw = await rootBundle.loadString(
        'assets/dataset/answer_index.json',
      );
      final indexMap = jsonDecode(indexRaw) as Map<String, dynamic>;
      _answerIndex.clear();
      indexMap.forEach((key, val) {
        _answerIndex[key] = (val as List).cast<String>();
      });

      final historyRaw = await rootBundle.loadString(
        'assets/dataset/player_team_history.json',
      );
      final historyList = jsonDecode(historyRaw) as List;
      _history.clear();
      _teamToPlayers.clear();
      _playerToHistory.clear();
      for (final h in historyList) {
        final item = PlayerTeamHistory.fromJson(h as Map<String, dynamic>);
        _history.add(item);
        _teamToPlayers
            .putIfAbsent(item.teamId, () => <String>{})
            .add(item.playerId);
        _playerToHistory
            .putIfAbsent(item.playerId, () => <PlayerTeamHistory>[])
            .add(item);
      }

      final playersRaw = await rootBundle.loadString(
        'assets/dataset/players.json',
      );
      final playersList = jsonDecode(playersRaw) as List;
      _players.clear();
      final seenNormNames = <String>{};
      for (final p in playersList) {
        final parsed = Player.fromJson(p as Map<String, dynamic>);
        final normKey = parsed.normalizedName.trim().toLowerCase();
        if (normKey.isEmpty || seenNormNames.contains(normKey)) {
          continue;
        }
        seenNormNames.add(normKey);
        final playerClubs =
            _playerToHistory[parsed.id]
                ?.map((h) => h.teamId)
                .toSet()
                .toList() ??
            parsed.clubs;
        _players.add(
          Player(
            id: parsed.id,
            name: parsed.name,
            normalizedName: parsed.normalizedName,
            aliases: parsed.aliases,
            nationality: parsed.nationality,
            position: parsed.position,
            verified: parsed.verified,
            eaFcOverall: parsed.eaFcOverall,
            marketValueEuro: parsed.marketValueEuro,
            age: parsed.age,
            goalsCareer: parsed.goalsCareer,
            assistsCareer: parsed.assistsCareer,
            speedRating: parsed.speedRating,
            clGoals: parsed.clGoals,
            clues: parsed.clues,
            photoAssetPath: parsed.photoAssetPath,
            clubs: playerClubs,
          ),
        );
      }

      _initialized = true;
      debugPrint(
        'WebDataStore loaded: ${_teams.length} teams, ${_answerIndex.length} pairs, ${_players.length} players, ${_history.length} history entries',
      );
    } catch (e, stack) {
      debugPrint('Error loading WebDataStore: $e\n$stack');
      _initialized = true;
    }
  }

  /// Generates a Transfer Path puzzle from verified career history.
  Future<TransferPathPuzzle> getRandomTransferPathPuzzle({
    Random? random,
  }) async {
    await init();
    final rng = random ?? Random();
    final teamMap = {for (final t in _teams) t.id: t};
    final playerMap = {for (final p in _players) p.id: p};

    final candidates = <TransferPathPuzzle>[];
    _playerToHistory.forEach((playerId, histories) {
      final player = playerMap[playerId];
      if (player == null) return;

      final sorted = List<PlayerTeamHistory>.from(histories)
        ..sort((a, b) => (a.seasonStart ?? 0).compareTo(b.seasonStart ?? 0));

      final stops = <TransferStop>[];
      for (final h in sorted) {
        final team = teamMap[h.teamId];
        if (team != null) {
          if (stops.isEmpty || stops.last.team.id != team.id) {
            stops.add(
              TransferStop(
                team: team,
                seasonStart: h.seasonStart,
                seasonEnd: h.seasonEnd,
              ),
            );
          }
        }
      }

      if (stops.length >= 3) {
        final diff = (player.eaFcOverall ?? 75) >= 85
            ? 'EASY'
            : (player.eaFcOverall ?? 75) >= 78
            ? 'MEDIUM'
            : 'HARD';
        candidates.add(
          TransferPathPuzzle(player: player, path: stops, difficulty: diff),
        );
      }
    });

    if (candidates.isEmpty) {
      throw StateError('No players with 3+ transfer stops available.');
    }
    candidates.sort((a, b) => a.player.id.compareTo(b.player.id));
    return candidates[rng.nextInt(candidates.length)];
  }

  /// Generates an Imposter puzzle (3 players who played for targetTeam, 1 who never did).
  Future<ImposterPuzzle> getRandomImposterPuzzle({Random? random}) async {
    await init();
    final rng = random ?? Random();
    final playerMap = {for (final p in _players) p.id: p};

    final eligibleTeams = _teams.where((t) {
      final count = _teamToPlayers[t.id]?.length ?? 0;
      return count >= 5;
    }).toList()..sort((a, b) => a.id.compareTo(b.id));

    if (eligibleTeams.isEmpty) {
      throw StateError('Not enough team data for Imposter puzzle.');
    }

    final targetTeam = eligibleTeams[rng.nextInt(eligibleTeams.length)];
    final validIds = _teamToPlayers[targetTeam.id]!;

    final validPlayers =
        validIds.map((id) => playerMap[id]).whereType<Player>().toList()
          ..sort((a, b) => a.id.compareTo(b.id))
          ..shuffle(rng);

    final imposters = _players.where((p) => !validIds.contains(p.id)).toList()
      ..sort((a, b) => a.id.compareTo(b.id))
      ..shuffle(rng);

    final chosenValid = validPlayers.take(3).toList();
    final chosenImposter = imposters.first;

    final options = <ImposterOption>[
      for (final p in chosenValid) ImposterOption(player: p, isImposter: false),
      ImposterOption(player: chosenImposter, isImposter: true),
    ]..shuffle(rng);

    final otherClubs = chosenImposter.clubs
        .map((cid) => _teams.where((t) => t.id == cid).firstOrNull?.name)
        .whereType<String>()
        .take(3)
        .join(', ');

    final explanation = otherClubs.isNotEmpty
        ? '${chosenImposter.name} kariyerinde hiç ${targetTeam.name} forması giymedi (Oynadığı kulüpler: $otherClubs).'
        : '${chosenImposter.name} kariyerinde hiç ${targetTeam.name} forması giymedi.';

    return ImposterPuzzle(
      targetTeam: targetTeam,
      ruleDescription: 'Hangi futbolcu HİÇ ${targetTeam.name} forması giymedi?',
      options: options,
      explanation: explanation,
    );
  }

  /// Generates a Football Bomb challenge with 10+ valid candidates.
  Future<BombChallenge> getRandomBombChallenge({Random? random}) async {
    await init();
    final rng = random ?? Random();

    final eligibleTeams = _teams.where((t) {
      final count = _teamToPlayers[t.id]?.length ?? 0;
      return count >= 10;
    }).toList()..sort((a, b) => a.id.compareTo(b.id));

    final byNationality = <String, Set<String>>{};
    for (final p in _players) {
      final nat = p.nationality;
      if (nat != null && nat.isNotEmpty) {
        byNationality.putIfAbsent(nat, () => <String>{}).add(p.id);
      }
    }
    final eligibleNats =
        byNationality.entries.where((e) => e.value.length >= 12).toList()
          ..sort((a, b) => a.key.compareTo(b.key));

    final useTeam =
        eligibleTeams.isNotEmpty && (eligibleNats.isEmpty || rng.nextBool());

    if (useTeam) {
      final team = eligibleTeams[rng.nextInt(eligibleTeams.length)];
      final validIds = _teamToPlayers[team.id] ?? <String>{};
      return BombChallenge(
        id: 'bomb_team_${team.id}',
        prompt: '${team.name} forması giymiş bir futbolcu söyle!',
        targetTeam: team,
        initialTimerSeconds: 18,
        validPlayerIds: validIds,
      );
    } else if (eligibleNats.isNotEmpty) {
      final natEntry = eligibleNats[rng.nextInt(eligibleNats.length)];
      final natName = _nationalityDisplayName(natEntry.key);
      return BombChallenge(
        id: 'bomb_nat_${natEntry.key}',
        prompt: '$natName vatandaşı bir futbolcu söyle!',
        targetNationality: natEntry.key,
        initialTimerSeconds: 18,
        validPlayerIds: natEntry.value,
      );
    } else {
      final allIds = _players.map((p) => p.id).toSet();
      return BombChallenge(
        id: 'bomb_all',
        prompt: 'Veritabanındaki herhangi bir futbolcuyu söyle!',
        initialTimerSeconds: 18,
        validPlayerIds: allIds,
      );
    }
  }

  String _nationalityDisplayName(String code) {
    const map = {
      'BR': 'Brezilya 🇧🇷',
      'FR': 'Fransa 🇫🇷',
      'ES': 'İspanya 🇪🇸',
      'DE': 'Almanya 🇩🇪',
      'EN': 'İngiltere 🏴󠁧󠁢󠁥󠁮󠁧󠁿',
      'IT': 'İtalya 🇮🇹',
      'AR': 'Arjantin 🇦🇷',
      'PT': 'Portekiz 🇵🇹',
      'NL': 'Hollanda 🇳🇱',
      'TR': 'Türkiye 🇹🇷',
      'BE': 'Belçika 🇧🇪',
      'HR': 'Hırvatistan 🇭🇷',
      'UY': 'Uruguay 🇺🇾',
    };
    return map[code.toUpperCase()] ?? code;
  }
}

class _WebTeamRepository implements TeamRepository {
  final WebDataStore store;
  _WebTeamRepository(this.store);

  @override
  Future<List<Team>> getAllTeams() async {
    await store.init();
    return List.unmodifiable(store._teams);
  }

  @override
  Future<Team?> getById(String teamId) async {
    await store.init();
    try {
      return store._teams.firstWhere((t) => t.id == teamId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Team>> getByIds(List<String> teamIds) async {
    await store.init();
    final set = teamIds.toSet();
    return store._teams.where((t) => set.contains(t.id)).toList();
  }

  @override
  Future<List<Team>> searchTeams(String query, {int limit = 20}) async {
    await store.init();
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return [];
    return store._teams
        .where(
          (t) =>
              t.normalizedName.contains(q) ||
              t.name.toLowerCase().contains(q) ||
              t.aliases.any((a) => a.toLowerCase().contains(q)),
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
    await store.init();
    final pairs = <(Team a, Team b)>[];
    final teamMap = {for (final t in store._teams) t.id: t};

    final rng = seed != null ? Random(seed) : Random();
    final entries = store._answerIndex.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key))
      ..shuffle(rng);
    for (final entry in entries) {
      if (entry.value.length < minPlayersPerPair) continue;
      final parts = entry.key.split('|');
      if (parts.length != 2) continue;
      final tA = teamMap[parts[0]];
      final tB = teamMap[parts[1]];
      if (tA != null && tB != null) {
        pairs.add((tA, tB));
        if (pairs.length >= limit) break;
      }
    }
    return pairs;
  }
}

class _WebAnswerValidatorRepository implements AnswerValidatorRepository {
  final WebDataStore store;
  _WebAnswerValidatorRepository(this.store);

  String _normalizePair(String a, String b) {
    final sorted = [a, b]..sort();
    return '${sorted[0]}|${sorted[1]}';
  }

  @override
  Future<List<String>> getPlayersForTeamPair(
    String teamIdA,
    String teamIdB,
  ) async {
    await store.init();
    final key = _normalizePair(teamIdA, teamIdB);
    return store._answerIndex[key] ?? const [];
  }

  @override
  Future<bool> isPlayerInTeamPair(
    String playerId,
    String teamIdA,
    String teamIdB,
  ) async {
    await store.init();
    final key = _normalizePair(teamIdA, teamIdB);
    final players = store._answerIndex[key];
    if (players == null) return false;
    return players.contains(playerId);
  }
}

class _WebPlayerRepository implements PlayerRepository {
  final WebDataStore store;
  _WebPlayerRepository(this.store);

  @override
  Future<Player?> getById(String playerId) async {
    await store.init();
    try {
      return store._players.firstWhere((p) => p.id == playerId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Player>> getByIds(List<String> playerIds) async {
    await store.init();
    final set = playerIds.toSet();
    return store._players.where((p) => set.contains(p.id)).toList();
  }

  String _normalizeQuery(String input) {
    final replaced = input
        .replaceAll('İ', 'i')
        .replaceAll('I', 'i')
        .replaceAll('ı', 'i')
        .replaceAll('і', 'i')
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
    await store.init();
    final normQ = _normalizeQuery(query);
    if (normQ.isEmpty) return [];
    final tokens = normQ.split(' ').where((t) => t.isNotEmpty).toList();

    final matches = <Player>[];
    final seenNames = <String>{};

    for (final p in store._players) {
      final pNorm = _normalizeQuery(
        p.normalizedName.isNotEmpty ? p.normalizedName : p.name,
      );
      if (seenNames.contains(pNorm)) continue;

      final searchable = '$pNorm ${p.aliases.map(_normalizeQuery).join(' ')}';
      final isMatch =
          pNorm.contains(normQ) ||
          tokens.every((tok) => searchable.contains(tok));

      if (isMatch) {
        seenNames.add(pNorm);
        matches.add(p);
      }
    }

    matches.sort((a, b) {
      final aNorm = _normalizeQuery(a.normalizedName);
      final bNorm = _normalizeQuery(b.normalizedName);
      final aStarts = aNorm.startsWith(normQ)
          ? 0
          : (aNorm.split(' ').any((w) => w.startsWith(tokens.first)) ? 1 : 2);
      final bStarts = bNorm.startsWith(normQ)
          ? 0
          : (bNorm.split(' ').any((w) => w.startsWith(tokens.first)) ? 1 : 2);
      if (aStarts != bStarts) return aStarts.compareTo(bStarts);
      return (b.eaFcOverall ?? 0).compareTo(a.eaFcOverall ?? 0);
    });

    return matches.take(limit).toList();
  }

  @override
  Future<List<Player>> searchPlayersWithClues(String query, {int limit = 20}) {
    return searchPlayers(query, limit: limit);
  }

  @override
  Future<Player?> getRandomWhoAmI({int? seed}) async {
    await store.init();
    final rng = seed != null ? Random(seed) : Random();
    final withClues = store._players.where((p) => p.clues.isNotEmpty).toList()
      ..sort((a, b) => a.id.compareTo(b.id));
    if (withClues.isEmpty) {
      if (store._players.isEmpty) return null;
      final sorted = List<Player>.from(store._players)
        ..sort((a, b) => a.id.compareTo(b.id))
        ..shuffle(rng);
      return sorted.first;
    }
    withClues.shuffle(rng);
    return withClues.first;
  }

  @override
  Future<(Player a, Player b)> getRandomRatingPair({
    RatingCategory? category,
    int? seed,
  }) async {
    await store.init();
    if (store._players.length < 2) {
      throw StateError('Not enough players loaded');
    }
    final rng = seed != null ? Random(seed) : Random();
    final pool = List<Player>.from(store._players)
      ..sort((a, b) => a.id.compareTo(b.id))
      ..shuffle(rng);
    final a = pool.first;
    final cat = category ?? RatingCategory.eaFcOverall;
    final valA = cat.valueOf(a);

    // Ensure the two players NEVER have the exact same stat value in the active category
    final b = pool
        .skip(1)
        .firstWhere(
          (p) =>
              p.id != a.id && cat.valueOf(p) != null && cat.valueOf(p) != valA,
          orElse: () => pool[1],
        );
    return (a, b);
  }
}

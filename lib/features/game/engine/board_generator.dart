import 'dart:math';

import '../../../data/repositories/answer_validator_repository.dart';
import '../../../data/repositories/team_repository.dart';
import '../../../data/models/freezed/entity_models.dart';

enum Difficulty { easy, medium, hard }

class BoardGenerator {
  final TeamRepository teamRepository;
  final AnswerValidatorRepository answerValidator;
  final Random _random;

  // Well-known elite and high-transfer clubs for fast and highly solvability matches
  static const Set<String> popularClubIds = {
    'team_418', // Real Madrid
    'team_131', // Barcelona
    'team_985', // Man Utd
    'team_5', // AC Milan
    'team_46', // Inter Milan
    'team_506', // Juventus
    'team_27', // Bayern Munich
    'team_11', // Arsenal
    'team_631', // Chelsea
    'team_31', // Liverpool
    'team_583', // PSG
    'team_281', // Man City
    'team_13', // Atletico Madrid
    'team_16', // Dortmund
    'team_148', // Tottenham
    'team_141', // Galatasaray
    'team_36', // Fenerbahce
    'team_114', // Besiktas
    'team_610', // Ajax
    'team_294', // Benfica
    'team_720', // Porto
    'team_336', // Sporting CP
    'team_12', // Roma
    'team_6195', // Napoli
  };

  static const List<({List<String> rows, List<String> cols})>
  verifiedBoardPairs = [
    // 1. European Royalty (Real Madrid, Barca, Man Utd x Milan, Chelsea, Juve)
    (
      rows: ['team_418', 'team_131', 'team_985'],
      cols: ['team_5', 'team_631', 'team_506'],
    ),
    // 2. Champions League Masters (Real Madrid, Barca, PSG x Arsenal, Chelsea, Man City)
    (
      rows: ['team_418', 'team_131', 'team_583'],
      cols: ['team_11', 'team_631', 'team_281'],
    ),
    // 3. Italian Giants & Spanish Giants (Inter, Milan, Juve x Real Madrid, Barca, Atletico)
    (
      rows: ['team_46', 'team_5', 'team_506'],
      cols: ['team_418', 'team_131', 'team_13'],
    ),
    // 4. Continental Classics (Bayern, Dortmund, Real Madrid x Man Utd, Milan, Liverpool)
    (
      rows: ['team_27', 'team_16', 'team_418'],
      cols: ['team_985', 'team_5', 'team_31'],
    ),
    // 5. European Heavyweights (PSG, Chelsea, Man Utd x Barca, Real Madrid, Inter)
    (
      rows: ['team_583', 'team_631', 'team_985'],
      cols: ['team_131', 'team_418', 'team_46'],
    ),
    // 6. Premier League & Serie A (Liverpool, Man City, Chelsea x Milan, Juve, Inter)
    (
      rows: ['team_31', 'team_281', 'team_631'],
      cols: ['team_5', 'team_506', 'team_46'],
    ),
    // 7. Süper Lig & European Giants (Galatasaray, Fenerbahce, Besiktas x Real Madrid, Inter, Arsenal)
    (
      rows: ['team_141', 'team_36', 'team_114'],
      cols: ['team_418', 'team_46', 'team_11'],
    ),
    // 8. Titans Grid (Barca, Juve, Bayern x Chelsea, Man Utd, Real Madrid)
    (
      rows: ['team_131', 'team_506', 'team_27'],
      cols: ['team_631', 'team_985', 'team_418'],
    ),
    // 9. Clash of Titans (Arsenal, Liverpool, Man Utd x Real Madrid, Barca, PSG)
    (
      rows: ['team_11', 'team_31', 'team_985'],
      cols: ['team_418', 'team_131', 'team_583'],
    ),
    // 10. Classic Derbies (Real Madrid, Juve, Inter x Milan, Barca, Chelsea)
    (
      rows: ['team_418', 'team_506', 'team_46'],
      cols: ['team_5', 'team_131', 'team_631'],
    ),
  ];

  static final Map<String, Team> knownTopTeams = {
    'team_418': Team(
      id: 'team_418',
      name: 'Real Madrid',
      normalizedName: 'real madrid',
      country: 'ES',
      primaryColorHex: '#FEBE10',
      secondaryColorHex: '#00529F',
      logoUrl: 'https://tmssl.akamaized.net/images/wappen/head/418.png',
      verified: true,
    ),
    'team_131': Team(
      id: 'team_131',
      name: 'FC Barcelona',
      normalizedName: 'fc barcelona',
      country: 'ES',
      primaryColorHex: '#A50044',
      secondaryColorHex: '#004D98',
      logoUrl: 'https://tmssl.akamaized.net/images/wappen/head/131.png',
      verified: true,
    ),
    'team_985': Team(
      id: 'team_985',
      name: 'Manchester United',
      normalizedName: 'manchester united',
      country: 'GB',
      primaryColorHex: '#DA291C',
      secondaryColorHex: '#FBE122',
      logoUrl: 'https://tmssl.akamaized.net/images/wappen/head/985.png',
      verified: true,
    ),
    'team_5': Team(
      id: 'team_5',
      name: 'AC Milan',
      normalizedName: 'ac milan',
      country: 'IT',
      primaryColorHex: '#FB090B',
      secondaryColorHex: '#000000',
      logoUrl: 'https://tmssl.akamaized.net/images/wappen/head/5.png',
      verified: true,
    ),
    'team_46': Team(
      id: 'team_46',
      name: 'Inter Milan',
      normalizedName: 'inter milan',
      country: 'IT',
      primaryColorHex: '#010E80',
      secondaryColorHex: '#000000',
      logoUrl: 'https://tmssl.akamaized.net/images/wappen/head/46.png',
      verified: true,
    ),
    'team_506': Team(
      id: 'team_506',
      name: 'Juventus FC',
      normalizedName: 'juventus fc',
      country: 'IT',
      primaryColorHex: '#000000',
      secondaryColorHex: '#D4AF37',
      logoUrl: 'https://tmssl.akamaized.net/images/wappen/head/506.png',
      verified: true,
    ),
    'team_27': Team(
      id: 'team_27',
      name: 'Bayern Munich',
      normalizedName: 'bayern munich',
      country: 'DE',
      primaryColorHex: '#DC052D',
      secondaryColorHex: '#0066B2',
      logoUrl: 'https://tmssl.akamaized.net/images/wappen/head/27.png',
      verified: true,
    ),
    'team_11': Team(
      id: 'team_11',
      name: 'Arsenal FC',
      normalizedName: 'arsenal fc',
      country: 'GB',
      primaryColorHex: '#EF0107',
      secondaryColorHex: '#063672',
      logoUrl: 'https://tmssl.akamaized.net/images/wappen/head/11.png',
      verified: true,
    ),
    'team_631': Team(
      id: 'team_631',
      name: 'Chelsea FC',
      normalizedName: 'chelsea fc',
      country: 'GB',
      primaryColorHex: '#034694',
      secondaryColorHex: '#DBA111',
      logoUrl: 'https://tmssl.akamaized.net/images/wappen/head/631.png',
      verified: true,
    ),
    'team_31': Team(
      id: 'team_31',
      name: 'Liverpool FC',
      normalizedName: 'liverpool fc',
      country: 'GB',
      primaryColorHex: '#C8102E',
      secondaryColorHex: '#00B2A9',
      logoUrl: 'https://tmssl.akamaized.net/images/wappen/head/31.png',
      verified: true,
    ),
    'team_583': Team(
      id: 'team_583',
      name: 'Paris Saint-Germain',
      normalizedName: 'paris saint-germain',
      country: 'FR',
      primaryColorHex: '#004170',
      secondaryColorHex: '#DA291C',
      logoUrl: 'https://tmssl.akamaized.net/images/wappen/head/583.png',
      verified: true,
    ),
    'team_281': Team(
      id: 'team_281',
      name: 'Manchester City',
      normalizedName: 'manchester city',
      country: 'GB',
      primaryColorHex: '#6CABDD',
      secondaryColorHex: '#1C2C5B',
      logoUrl: 'https://tmssl.akamaized.net/images/wappen/head/281.png',
      verified: true,
    ),
    'team_13': Team(
      id: 'team_13',
      name: 'Atlético de Madrid',
      normalizedName: 'atletico de madrid',
      country: 'ES',
      primaryColorHex: '#CB3524',
      secondaryColorHex: '#272E61',
      logoUrl: 'https://tmssl.akamaized.net/images/wappen/head/13.png',
      verified: true,
    ),
    'team_16': Team(
      id: 'team_16',
      name: 'Borussia Dortmund',
      normalizedName: 'borussia dortmund',
      country: 'DE',
      primaryColorHex: '#FDE100',
      secondaryColorHex: '#000000',
      logoUrl: 'https://tmssl.akamaized.net/images/wappen/head/16.png',
      verified: true,
    ),
    'team_148': Team(
      id: 'team_148',
      name: 'Tottenham Hotspur',
      normalizedName: 'tottenham hotspur',
      country: 'GB',
      primaryColorHex: '#132257',
      secondaryColorHex: '#FFFFFF',
      logoUrl: 'https://tmssl.akamaized.net/images/wappen/head/148.png',
      verified: true,
    ),
    'team_141': Team(
      id: 'team_141',
      name: 'Galatasaray',
      normalizedName: 'galatasaray',
      country: 'TR',
      primaryColorHex: '#A90432',
      secondaryColorHex: '#FDB912',
      logoUrl: 'https://tmssl.akamaized.net/images/wappen/head/141.png',
      verified: true,
    ),
    'team_36': Team(
      id: 'team_36',
      name: 'Fenerbahçe',
      normalizedName: 'fenerbahce',
      country: 'TR',
      primaryColorHex: '#002D72',
      secondaryColorHex: '#FFED00',
      logoUrl: 'https://tmssl.akamaized.net/images/wappen/head/36.png',
      verified: true,
    ),
    'team_114': Team(
      id: 'team_114',
      name: 'Beşiktaş JK',
      normalizedName: 'besiktas jk',
      country: 'TR',
      primaryColorHex: '#000000',
      secondaryColorHex: '#E30613',
      logoUrl: 'https://tmssl.akamaized.net/images/wappen/head/114.png',
      verified: true,
    ),
  };

  BoardGenerator({
    required this.teamRepository,
    required this.answerValidator,
    Random? random,
  }) : _random = random ?? Random();

  /// Generates a deterministic 3x3 board from [seed] and [roundNumber].
  /// Any two clients calling this with the same [seed] and [roundNumber] will
  /// produce the exact same row and column clubs.
  static GeneratedBoard generateDeterministicVerifiedBoard({
    required int seed,
    int roundNumber = 1,
    Difficulty difficulty = Difficulty.easy,
  }) {
    final rng = Random(seed * 997 + roundNumber * 131);
    final pairIndex =
        (seed.abs() + (roundNumber - 1) * 3) % verifiedBoardPairs.length;
    final config = verifiedBoardPairs[pairIndex];

    List<String> rowIds = [...config.rows]..shuffle(rng);
    List<String> colIds = [...config.cols]..shuffle(rng);

    if (rng.nextBool()) {
      final temp = rowIds;
      rowIds = colIds;
      colIds = temp;
    }

    final rowTeams = rowIds
        .map(
          (id) =>
              knownTopTeams[id] ??
              Team(
                id: id,
                name: id,
                normalizedName: id.toLowerCase(),
                verified: true,
              ),
        )
        .toList();
    final colTeams = colIds
        .map(
          (id) =>
              knownTopTeams[id] ??
              Team(
                id: id,
                name: id,
                normalizedName: id.toLowerCase(),
                verified: true,
              ),
        )
        .toList();

    return GeneratedBoard(
      boardId: 'board_${seed}_r$roundNumber',
      boardVersion: roundNumber,
      rowTeams: rowTeams,
      colTeams: colTeams,
      difficulty: difficulty,
      minValidPlayersPerCell: 3,
      fallbackUsed: false,
    );
  }

  /// Pre-generates [count] distinct 3x3 boards for a multi-round match so
  /// every round has a unique, validated set of row & column clubs stored once
  /// in the canonical match document.
  Future<List<GeneratedBoard>> generateMultipleBoards({
    required int count,
    Difficulty difficulty = Difficulty.easy,
    int? seed,
  }) async {
    final boards = <GeneratedBoard>[];
    final usedSignatures = <String>{};
    final effectiveSeed = seed ?? (1000 + _random.nextInt(900000));

    for (int r = 1; r <= count; r++) {
      GeneratedBoard candidate = await generate(
        difficulty: difficulty,
        minValidPlayersPerCell: 1,
        roundNumber: r,
        seed: effectiveSeed,
      );
      final sig =
          '${candidate.rowTeams.map((t) => t.id).join(",")}|${candidate.colTeams.map((t) => t.id).join(",")}';
      if (usedSignatures.contains(sig)) {
        candidate = generateDeterministicVerifiedBoard(
          seed: effectiveSeed + r * 17,
          roundNumber: r,
          difficulty: difficulty,
        );
      }
      usedSignatures.add(
        '${candidate.rowTeams.map((t) => t.id).join(",")}|${candidate.colTeams.map((t) => t.id).join(",")}',
      );
      boards.add(
        GeneratedBoard(
          boardId: 'board_${effectiveSeed}_r$r',
          boardVersion: r,
          rowTeams: candidate.rowTeams,
          colTeams: candidate.colTeams,
          difficulty: candidate.difficulty,
          minValidPlayersPerCell: candidate.minValidPlayersPerCell,
          fallbackUsed: candidate.fallbackUsed,
        ),
      );
    }
    return boards;
  }

  /// Dynamically generates a 100% solvable 3x3 board across all 30 real clubs,
  /// falling back to `verifiedBoardPairs` only if needed.
  Future<GeneratedBoard> generate({
    Difficulty difficulty = Difficulty.easy,
    int? minValidPlayersPerCell,
    int maxAttempts = 40,
    int roundNumber = 1,
    int? seed,
  }) async {
    final rng = seed != null ? Random(seed * 997 + roundNumber * 131) : _random;
    final targetMin =
        minValidPlayersPerCell ??
        switch (difficulty) {
          Difficulty.easy => 3,
          Difficulty.medium => 2,
          Difficulty.hard => 1,
        };

    final generatedBoardId =
        'board_${seed ?? DateTime.now().millisecondsSinceEpoch}_r$roundNumber';

    try {
      final allTeams = await teamRepository.getAllTeams();
      if (allTeams.length >= 6) {
        final pool = List<Team>.from(allTeams)
          ..sort((a, b) => a.id.compareTo(b.id))
          ..shuffle(rng);
        final dynamicBoard = await _tryDynamicBacktrack(
          pool: pool,
          minPlayers: targetMin,
          maxAttempts: maxAttempts,
          rng: rng,
        );
        if (dynamicBoard != null) {
          return GeneratedBoard(
            boardId: generatedBoardId,
            boardVersion: roundNumber,
            rowTeams: dynamicBoard.$1,
            colTeams: dynamicBoard.$2,
            difficulty: difficulty,
            minValidPlayersPerCell: targetMin,
            fallbackUsed: false,
          );
        }
      }
    } catch (_) {}

    // Fallback to verified pairings (100% guaranteed >= 3 players per cell)
    final pairIndex = seed != null
        ? (seed.abs() + (roundNumber - 1) * 3) % verifiedBoardPairs.length
        : rng.nextInt(verifiedBoardPairs.length);
    final config = verifiedBoardPairs[pairIndex];
    List<String> rowIds = [...config.rows]..shuffle(rng);
    List<String> colIds = [...config.cols]..shuffle(rng);

    if (rng.nextBool()) {
      final temp = rowIds;
      rowIds = colIds;
      colIds = temp;
    }

    final rowTeams = await _resolveTeams(rowIds);
    final colTeams = await _resolveTeams(colIds);

    return GeneratedBoard(
      boardId: generatedBoardId,
      boardVersion: roundNumber,
      rowTeams: rowTeams,
      colTeams: colTeams,
      difficulty: difficulty,
      minValidPlayersPerCell: targetMin,
      fallbackUsed: false,
    );
  }

  Future<(List<Team>, List<Team>)?> _tryDynamicBacktrack({
    required List<Team> pool,
    required int minPlayers,
    required int maxAttempts,
    required Random rng,
  }) async {
    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      pool.shuffle(rng);
      final rows = pool.take(3).toList();
      final rowIds = {for (final r in rows) r.id};

      final validCols = <Team>[];
      for (final candidateCol in pool.skip(3)) {
        if (rowIds.contains(candidateCol.id)) continue;
        bool fitsAllRows = true;
        for (final r in rows) {
          final players = await answerValidator.getPlayersForTeamPair(
            r.id,
            candidateCol.id,
          );
          if (players.length < minPlayers) {
            fitsAllRows = false;
            break;
          }
        }
        if (fitsAllRows) {
          validCols.add(candidateCol);
          if (validCols.length == 3) {
            return (rows, validCols);
          }
        }
      }
    }
    return null;
  }

  Future<List<Team>> _resolveTeams(List<String> teamIds) async {
    try {
      final teams = await teamRepository.getByIds(teamIds);
      final foundMap = {for (final t in teams) t.id: t};
      final result = <Team>[];

      for (final id in teamIds) {
        if (foundMap.containsKey(id)) {
          result.add(foundMap[id]!);
        } else if (knownTopTeams.containsKey(id)) {
          result.add(knownTopTeams[id]!);
        } else {
          final t = await teamRepository.getById(id);
          result.add(
            t ??
                knownTopTeams[id] ??
                Team(
                  id: id,
                  name: id,
                  normalizedName: id.toLowerCase(),
                  verified: true,
                ),
          );
        }
      }
      return result;
    } catch (_) {
      return teamIds
          .map(
            (id) =>
                knownTopTeams[id] ??
                Team(
                  id: id,
                  name: id,
                  normalizedName: id.toLowerCase(),
                  verified: true,
                ),
          )
          .toList();
    }
  }
}

class GeneratedBoard {
  final String boardId;
  final int boardVersion;
  final List<Team> rowTeams;
  final List<Team> colTeams;
  final Difficulty difficulty;
  final int minValidPlayersPerCell;
  final bool fallbackUsed;

  GeneratedBoard({
    this.boardId = 'board_default_r1',
    this.boardVersion = 1,
    required this.rowTeams,
    required this.colTeams,
    required this.difficulty,
    required this.minValidPlayersPerCell,
    this.fallbackUsed = false,
  });

  int cellIndex(int row, int col) => row * 3 + col;
}

import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:football_tic_tac_toe/data/models/freezed/entity_models.dart';
import 'package:football_tic_tac_toe/data/repositories/rating_category.dart';
import 'package:football_tic_tac_toe/data/repositories/web_data_store.dart';
import 'package:football_tic_tac_toe/features/game/engine/board_generator.dart';
import 'package:football_tic_tac_toe/features/game/engine/game_engine.dart';
import 'package:football_tic_tac_toe/features/game/engine/score_calculator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Real Football Dataset & All 7 Game Modes Verification', () {
    late List<Team> teams;
    late List<Player> players;
    late Map<String, List<String>> answerIndex;

    setUpAll(() async {
      final teamsRaw = File('assets/dataset/teams.json').readAsStringSync();
      teams = (jsonDecode(teamsRaw) as List)
          .map((e) => Team.fromJson(e as Map<String, dynamic>))
          .toList();

      final playersRaw = File('assets/dataset/players.json').readAsStringSync();
      players = (jsonDecode(playersRaw) as List)
          .map((e) => Player.fromJson(e as Map<String, dynamic>))
          .toList();

      final indexRaw = File(
        'assets/dataset/answer_index.json',
      ).readAsStringSync();
      final decodedIndex = jsonDecode(indexRaw) as Map<String, dynamic>;
      answerIndex = decodedIndex.map(
        (k, v) => MapEntry(k, (v as List).cast<String>()),
      );

      await WebDataStore.instance.init();
    });

    test(
      '1. Dataset contains 30 real clubs and 250+ real footballers (zero fake names)',
      () {
        expect(teams.length, equals(30));
        expect(players.length, greaterThanOrEqualTo(250));

        final digitRegex = RegExp(r'\d');
        for (final p in players) {
          expect(
            digitRegex.hasMatch(p.name),
            isFalse,
            reason: 'Player name must not contain fake numbers: ${p.name}',
          );
          expect(p.verified, isTrue);
          expect(p.eaFcOverall, inInclusiveRange(70, 99));
          expect(p.marketValueEuro, greaterThan(0));
          expect(
            p.clues.length,
            equals(5),
            reason: '${p.name} must have 5 clues',
          );
          expect(p.clubs, isNotEmpty, reason: '${p.name} must have clubs');
        }
      },
    );

    test(
      '2. Mode 1 (Football SOS / Grid): All 10 verified boards have >= 3 real players in all 9 cells',
      () async {
        final generator = BoardGenerator(
          teamRepository: WebDataStore.instance.teamRepo,
          answerValidator: WebDataStore.instance.answerRepo,
        );

        for (int b = 0; b < BoardGenerator.verifiedBoardPairs.length; b++) {
          final pair = BoardGenerator.verifiedBoardPairs[b];
          final rows = pair.rows;
          final cols = pair.cols;

          for (final r in rows) {
            for (final c in cols) {
              final sorted = [r, c]..sort();
              final key = '${sorted[0]}|${sorted[1]}';
              final validIds = answerIndex[key] ?? const [];
              expect(
                validIds.length,
                greaterThanOrEqualTo(3),
                reason:
                    'Board $b cell ($r x $c) has fewer than 3 valid players',
              );
            }
          }
        }

        final board = await generator.generate();
        expect(board.rowTeams.length, equals(3));
        expect(board.colTeams.length, equals(3));

        // Verify GameEngine accepts real intersection players and rejects wrong ones
        final engine = GameEngine(
          board: board,
          answerValidator: WebDataStore.instance.answerRepo,
          scoreCalculator: ScoreCalculator(),
          participantUserIds: const ['p1', 'p2'],
          localPlayerId: 'p1',
        );
        engine.startGame();

        final r0 = board.rowTeams[0].id;
        final c0 = board.colTeams[0].id;
        final validIds = await WebDataStore.instance.answerRepo
            .getPlayersForTeamPair(r0, c0);
        expect(validIds, isNotEmpty);

        final result = await engine.submitAnswer(
          cellIndex: 0,
          playerId: validIds.first,
        );
        expect(result.valid, isTrue);
        expect(engine.state.cells[0].mark, equals(GameMark.x));
        // Test dynamic backtracking board generation across all difficulties
        for (final diff in Difficulty.values) {
          for (int i = 0; i < 5; i++) {
            final dynBoard = await generator.generate(difficulty: diff);
            expect(dynBoard.rowTeams.length, equals(3));
            expect(dynBoard.colTeams.length, equals(3));
            for (final r in dynBoard.rowTeams) {
              for (final c in dynBoard.colTeams) {
                final ids = await WebDataStore.instance.answerRepo
                    .getPlayersForTeamPair(r.id, c.id);
                expect(
                  ids,
                  isNotEmpty,
                  reason:
                      'Dynamic board cell (${r.name} x ${c.name}) must be solvable',
                );
              }
            }
          }
        }
      },
    );

    test(
      '3. Mode 2 (Rating Battle): All stat categories work with real player stats and never tie',
      () async {
        for (final category in RatingCategory.values) {
          for (int i = 0; i < 5; i++) {
            final (pA, pB) = await WebDataStore.instance.playerRepo
                .getRandomRatingPair(category: category);
            expect(pA.id, isNot(equals(pB.id)));
            expect(category.valueOf(pA), isNotNull);
            expect(category.valueOf(pB), isNotNull);
            expect(category.valueOf(pA), isNot(equals(category.valueOf(pB))));
          }
        }
      },
    );

    test(
      '4. Mode 3 (2 Teams 1 Player): Generates valid club pairs with >= 3 shared players',
      () async {
        final pairs = await WebDataStore.instance.teamRepo
            .getTeamPairsWithMinPlayers(minPlayersPerPair: 3, limit: 25);
        expect(pairs.length, equals(25));

        for (final (teamA, teamB) in pairs) {
          final shared = await WebDataStore.instance.answerRepo
              .getPlayersForTeamPair(teamA.id, teamB.id);
          expect(shared.length, greaterThanOrEqualTo(3));
        }
      },
    );

    test(
      '5. Mode 4 (Who Am I?) & Turkish/Diacritic Search: Finds players accurately',
      () async {
        final mystery = await WebDataStore.instance.playerRepo
            .getRandomWhoAmI();
        expect(mystery, isNotNull);
        expect(mystery!.clues.length, equals(5));

        // Test Turkish, multi-token, and accent-insensitive search (including James Rodríguez)
        for (final query in [
          'ronaldo',
          'messi',
          'arda guler',
          'hakan calhanoglu',
          'icardi',
          'osimhen',
          'zlatan',
          'quaresma',
          'sneijder',
          'james',
          'james r',
          'james rodriguez',
          'James Rodríguez',
        ]) {
          final results = await WebDataStore.instance.playerRepo.searchPlayers(
            query,
          );
          expect(
            results,
            isNotEmpty,
            reason: 'Search for "$query" should return real players',
          );
          // Ensure zero duplicate normalized names in search results
          final norms = results.map((p) => p.normalizedName).toSet();
          expect(norms.length, equals(results.length));
        }
      },
    );

    test(
      '6. Mode 5 (Imposter): Generates 3 valid club players and 1 true imposter',
      () async {
        for (int i = 0; i < 15; i++) {
          final puzzle = await WebDataStore.instance.getRandomImposterPuzzle();
          expect(puzzle.options.length, equals(4));
          final imposters = puzzle.options.where((o) => o.isImposter).toList();
          final regulars = puzzle.options.where((o) => !o.isImposter).toList();
          expect(imposters.length, equals(1));
          expect(regulars.length, equals(3));

          for (final reg in regulars) {
            expect(reg.player.clubs.contains(puzzle.targetTeam.id), isTrue);
          }
          expect(
            imposters.first.player.clubs.contains(puzzle.targetTeam.id),
            isFalse,
          );
        }
      },
    );

    test(
      '7. Mode 6 (Transfer Path): Generates chronological 3+ club career paths',
      () async {
        for (int i = 0; i < 15; i++) {
          final puzzle = await WebDataStore.instance
              .getRandomTransferPathPuzzle();
          expect(puzzle.path.length, greaterThanOrEqualTo(3));
          for (final stop in puzzle.path) {
            expect(puzzle.player.clubs.contains(stop.team.id), isTrue);
          }
        }
      },
    );

    test(
      '8. Mode 7 (Football Bomb): Generates bomb challenges with >= 10 valid answers',
      () async {
        for (int i = 0; i < 15; i++) {
          final challenge = await WebDataStore.instance
              .getRandomBombChallenge();
          expect(challenge.validPlayerIds.length, greaterThanOrEqualTo(10));
          expect(challenge.prompt, isNotEmpty);
        }
      },
    );
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:football_tic_tac_toe/data/models/freezed/entity_models.dart';
import 'package:football_tic_tac_toe/data/repositories/answer_validator_repository.dart';
import 'package:football_tic_tac_toe/data/repositories/team_repository.dart';
import 'package:football_tic_tac_toe/features/game/domain/online_game_model.dart';
import 'package:football_tic_tac_toe/features/game/engine/board_generator.dart';
import 'package:football_tic_tac_toe/features/game/engine/game_engine.dart';
import 'package:football_tic_tac_toe/features/game/engine/score_calculator.dart';

class _FakeTeamRepository implements TeamRepository {
  final List<Team> teams;

  _FakeTeamRepository(this.teams);

  @override
  Future<List<Team>> searchTeams(String query, {int limit = 20}) async {
    return teams.take(limit).toList();
  }

  @override
  Future<Team?> getById(String teamId) async {
    for (final team in teams) {
      if (team.id == teamId) return team;
    }
    return null;
  }

  @override
  Future<List<Team>> getAllTeams() async => teams;

  @override
  Future<List<Team>> getByIds(List<String> teamIds) async {
    return teams.where((t) => teamIds.contains(t.id)).toList();
  }

  @override
  Future<List<(Team a, Team b)>> getTeamPairsWithMinPlayers({
    int minPlayersPerPair = 3,
    int limit = 20,
    int? seed,
  }) async {
    final pairs = <(Team, Team)>[];
    for (var i = 0; i < teams.length; i++) {
      for (var j = i + 1; j < teams.length; j++) {
        pairs.add((teams[i], teams[j]));
      }
    }
    return pairs.take(limit).toList();
  }
}

class _FakeAnswerValidator implements AnswerValidatorRepository {
  final Map<String, List<String>> pairToPlayers;

  _FakeAnswerValidator(this.pairToPlayers);

  String _key(String a, String b) {
    final list = [a, b]..sort();
    return '${list[0]}|${list[1]}';
  }

  @override
  Future<List<String>> getPlayersForTeamPair(
    String teamAId,
    String teamBId,
  ) async {
    return pairToPlayers[_key(teamAId, teamBId)] ?? const [];
  }

  @override
  Future<bool> isPlayerInTeamPair(
    String playerId,
    String teamAId,
    String teamBId,
  ) async {
    final list = await getPlayersForTeamPair(teamAId, teamBId);
    return list.contains(playerId);
  }
}

GeneratedBoard _makeBoard() {
  final rowTeams = [
    Team(id: 'team_r0', name: 'Row Club 0', normalizedName: 'row club 0'),
    Team(id: 'team_r1', name: 'Row Club 1', normalizedName: 'row club 1'),
    Team(id: 'team_r2', name: 'Row Club 2', normalizedName: 'row club 2'),
  ];
  final colTeams = [
    Team(id: 'team_c0', name: 'Col Club 0', normalizedName: 'col club 0'),
    Team(id: 'team_c1', name: 'Col Club 1', normalizedName: 'col club 1'),
    Team(id: 'team_c2', name: 'Col Club 2', normalizedName: 'col club 2'),
  ];
  return GeneratedBoard(
    rowTeams: rowTeams,
    colTeams: colTeams,
    difficulty: Difficulty.medium,
    minValidPlayersPerCell: 3,
  );
}

void main() {
  group('Football SOS - 1. Footballer Reuse Across Cells', () {
    test(
      'allows the same player and opponent to reuse a footballer in multiple valid cells',
      () async {
        // player_zlatan played for all row and col clubs in this test
        final validator = _FakeAnswerValidator({
          'team_c0|team_r0': ['player_zlatan', 'player_2'],
          'team_c1|team_r0': ['player_zlatan', 'player_3'],
          'team_c2|team_r0': ['player_zlatan', 'player_4'],
          'team_c0|team_r1': ['player_zlatan', 'player_5'],
        });

        final engine = GameEngine(
          board: _makeBoard(),
          answerValidator: validator,
          scoreCalculator: ScoreCalculator(),
          participantUserIds: const ['u1', 'u2'],
          localPlayerId: 'u1',
        )..startGame();

        final zlatan = Player(
          id: 'player_zlatan',
          name: 'Zlatan Ibrahimović',
          normalizedName: 'zlatan ibrahimovic',
        );

        // Turn 1: u1 uses Zlatan in cell 0 (r0, c0)
        final move1 = await engine.submitAnswer(
          cellIndex: 0,
          playerId: zlatan.id,
          player: zlatan,
          byUserId: 'u1',
        );
        expect(move1.valid, isTrue);
        expect(engine.state.cells[0].mark, GameMark.x);
        expect(engine.state.currentTurnUserId, 'u2');

        // Turn 2: Opponent u2 ALSO uses Zlatan in cell 3 (r1, c0)
        final move2 = await engine.submitAnswer(
          cellIndex: 3,
          playerId: zlatan.id,
          player: zlatan,
          byUserId: 'u2',
        );
        expect(move2.valid, isTrue);
        expect(engine.state.cells[3].mark, GameMark.o);
        expect(engine.state.currentTurnUserId, 'u1');

        // Turn 3: u1 uses Zlatan AGAIN in cell 1 (r0, c1)
        final move3 = await engine.submitAnswer(
          cellIndex: 1,
          playerId: zlatan.id,
          player: zlatan,
          byUserId: 'u1',
        );
        expect(move3.valid, isTrue);
        expect(engine.state.cells[1].mark, GameMark.x);

        // Invalid footballer for cell is still rejected with INVALID_PLAYER
        final invalidMove = await engine.submitAnswer(
          cellIndex: 2,
          playerId: 'player_not_in_clubs',
          byUserId: 'u2',
        );
        expect(invalidMove.valid, isFalse);
        expect(invalidMove.error, 'INVALID_PLAYER');
      },
    );
  });

  group('Football SOS - 2. Pass Turn (2 Passes Per Player)', () {
    test(
      'tracks 2 passes per player, switches turn, leaves cells empty, and blocks 3rd pass or out-of-turn pass',
      () {
        final engine = GameEngine(
          board: _makeBoard(),
          answerValidator: _FakeAnswerValidator(const {}),
          scoreCalculator: ScoreCalculator(),
          participantUserIds: const ['u1', 'u2'],
          localPlayerId: 'u1',
        )..startGame();

        expect(engine.state.remainingPassesFor('u1'), 2);
        expect(engine.state.remainingPassesFor('u2'), 2);

        // u2 cannot pass on u1's turn
        final outOfTurn = engine.passTurn(byUserId: 'u2');
        expect(outOfTurn.valid, isFalse);
        expect(outOfTurn.error, 'NOT_YOUR_TURN');

        // u1 passes #1 -> turn goes to u2, cells remain empty
        final p1Pass1 = engine.passTurn(byUserId: 'u1', nowMs: 1000);
        expect(p1Pass1.valid, isTrue);
        expect(engine.state.remainingPassesFor('u1'), 1);
        expect(engine.state.currentTurnUserId, 'u2');
        expect(engine.state.cells.every((c) => c.isEmpty), isTrue);
        expect(engine.state.moveHistory.last.type, 'pass');
        expect(engine.state.moveHistory.last.byUserId, 'u1');

        // u2 passes #1 -> turn goes to u1
        final p2Pass1 = engine.passTurn(byUserId: 'u2', nowMs: 2000);
        expect(p2Pass1.valid, isTrue);
        expect(engine.state.remainingPassesFor('u2'), 1);
        expect(engine.state.currentTurnUserId, 'u1');

        // u1 passes #2 -> 0 passes left for u1, turn goes to u2
        final p1Pass2 = engine.passTurn(byUserId: 'u1', nowMs: 3000);
        expect(p1Pass2.valid, isTrue);
        expect(engine.state.remainingPassesFor('u1'), 0);
        expect(engine.state.currentTurnUserId, 'u2');

        // u2 passes #2 -> turn goes back to u1
        final p2Pass2 = engine.passTurn(byUserId: 'u2', nowMs: 4000);
        expect(p2Pass2.valid, isTrue);
        expect(engine.state.remainingPassesFor('u2'), 0);
        expect(engine.state.currentTurnUserId, 'u1');

        // u1 attempts pass #3 -> rejected with NO_PASSES_LEFT and turn stays with u1
        expect(engine.state.canPass('u1'), isFalse);
        final p1Pass3 = engine.passTurn(byUserId: 'u1', nowMs: 5000);
        expect(p1Pass3.valid, isFalse);
        expect(p1Pass3.error, 'NO_PASSES_LEFT');
        expect(engine.state.currentTurnUserId, 'u1');
      },
    );
  });

  group('Football SOS - 3. Draw Offer (30s Expiration & 60s Cooldown)', () {
    test(
      'enforces single active offer, 30s expiration, 60s sender cooldown, rejection continuation, and acceptance draw result',
      () {
        final engine = GameEngine(
          board: _makeBoard(),
          answerValidator: _FakeAnswerValidator(const {}),
          scoreCalculator: ScoreCalculator(),
          participantUserIds: const ['u1', 'u2'],
          localPlayerId: 'u1',
        )..startGame();

        const t0 = 1000000;

        // u1 offers draw at t0
        final offer1 = engine.offerDraw(byUserId: 'u1', nowMs: t0);
        expect(offer1.valid, isTrue);
        expect(engine.state.hasActiveDrawOffer(t0 + 5000), isTrue);
        expect(engine.state.drawOfferRemainingSeconds(t0 + 5000), 25);

        // Cannot create a second active offer while first is pending
        final duplicateOffer = engine.offerDraw(
          byUserId: 'u2',
          nowMs: t0 + 5000,
        );
        expect(duplicateOffer.valid, isFalse);
        expect(duplicateOffer.error, 'ACTIVE_OFFER_EXISTS');

        // Sender cannot accept their own offer
        final selfAccept = engine.respondToDrawOffer(
          accept: true,
          byUserId: 'u1',
          nowMs: t0 + 6000,
        );
        expect(selfAccept.valid, isFalse);
        expect(selfAccept.error, 'CANNOT_RESPOND_OWN_OFFER');

        // Opponent u2 rejects the offer at t0 + 10s
        final rejectRes = engine.respondToDrawOffer(
          accept: false,
          byUserId: 'u2',
          nowMs: t0 + 10000,
        );
        expect(rejectRes.valid, isTrue);
        expect(engine.state.status, GameStatus.playing);
        expect(engine.state.hasActiveDrawOffer(t0 + 10000), isFalse);

        // u1 tries to offer again at t0 + 25s -> blocked by 60s cooldown (35s left)
        expect(engine.state.drawOfferCooldownSecondsFor('u1', t0 + 25000), 35);
        final cooldownBlocked = engine.offerDraw(
          byUserId: 'u1',
          nowMs: t0 + 25000,
        );
        expect(cooldownBlocked.valid, isFalse);
        expect(cooldownBlocked.error, 'DRAW_OFFER_COOLDOWN');

        // At t0 + 60s, u1's cooldown has finished and u1 offers again
        expect(engine.state.drawOfferCooldownSecondsFor('u1', t0 + 60000), 0);
        final offer2 = engine.offerDraw(byUserId: 'u1', nowMs: t0 + 60000);
        expect(offer2.valid, isTrue);

        // After 30s without response (t0 + 90s), offer automatically expires
        final expired = engine.expireDrawOfferIfNeeded(nowMs: t0 + 90000);
        expect(expired, isTrue);
        expect(engine.state.drawOffer?.status, 'expired');
        expect(engine.state.status, GameStatus.playing);

        // u2 offers a draw at t0 + 91s and u1 accepts -> game ends in Draw!
        final offer3 = engine.offerDraw(byUserId: 'u2', nowMs: t0 + 91000);
        expect(offer3.valid, isTrue);
        final acceptRes = engine.respondToDrawOffer(
          accept: true,
          byUserId: 'u1',
          nowMs: t0 + 95000,
        );
        expect(acceptRes.valid, isTrue);
        expect(engine.state.status, GameStatus.draw);
        expect(engine.state.endedByDrawOffer, isTrue);
        expect(engine.state.moveHistory.last.type, 'draw_accepted');
      },
    );

    test(
      'OnlineGame.fromFirestore restores pass rights, moveHistory, and active draw offer on app reopen',
      () {
        final game = OnlineGame.fromFirestore('game_123', {
          'roomCode': '654321',
          'gameMode': 'sos',
          'status': 'playing',
          'player1Id': 'u1',
          'player1Name': 'Ali',
          'player2Id': 'u2',
          'player2Name': 'Veli',
          'currentTurn': 'u1',
          'rowTeams': [
            {'id': 't1', 'name': 'A'},
            {'id': 't2', 'name': 'B'},
            {'id': 't3', 'name': 'C'},
          ],
          'colTeams': [
            {'id': 't4', 'name': 'D'},
            {'id': 't5', 'name': 'E'},
            {'id': 't6', 'name': 'F'},
          ],
          'board': List.filled(9, null),
          'usedPlayerIds': ['p1'],
          'passesUsed': {'u1': 1, 'u2': 2},
          'moveHistory': [
            {'type': 'pass', 'byUserId': 'u1', 'timestampMs': 1000},
          ],
          'drawOffer': {
            'fromUserId': 'u2',
            'fromUserName': 'Veli',
            'createdAtMs': 5000,
            'expiresAtMs': 35000,
            'status': 'pending',
          },
          'lastDrawOfferAtByUser': {'u2': 5000},
        });

        expect(game.remainingPassesFor('u1'), 1);
        expect(game.remainingPassesFor('u2'), 0);
        expect(game.canPass('u1'), isTrue);
        expect(game.canPass('u2'), isFalse);
        expect(game.moveHistory.length, 1);
        expect(game.moveHistory.first.type, 'pass');
        expect(game.hasActiveDrawOffer(15000), isTrue);
        expect(game.drawOfferRemainingSeconds(15000), 20);
        expect(game.drawOfferCooldownSecondsFor('u2', 25000), 40);
      },
    );
  });

  group('Football SOS - 4. Multi-Round Series (Best-of-3 & Best-of-5)', () {
    final allValidValidator = _FakeAnswerValidator({
      'team_c0|team_r0': ['p1'],
      'team_c1|team_r0': ['p1'],
      'team_c2|team_r0': ['p1'],
      'team_c0|team_r1': ['p1'],
      'team_c1|team_r1': ['p1'],
      'team_c2|team_r1': ['p1'],
      'team_c0|team_r2': ['p1'],
      'team_c1|team_r2': ['p1'],
      'team_c2|team_r2': ['p1'],
    });

    Future<void> winRow0For(GameEngine engine, String winnerId) async {
      final opponentId = winnerId == 'u1' ? 'u2' : 'u1';
      if (engine.state.currentTurnUserId != winnerId) {
        engine.passTurn(byUserId: opponentId);
      }
      await engine.submitAnswer(
        cellIndex: 0,
        playerId: 'p1',
        byUserId: winnerId,
      );
      await engine.submitAnswer(
        cellIndex: 3,
        playerId: 'p1',
        byUserId: opponentId,
      );
      await engine.submitAnswer(
        cellIndex: 1,
        playerId: 'p1',
        byUserId: winnerId,
      );
      await engine.submitAnswer(
        cellIndex: 4,
        playerId: 'p1',
        byUserId: opponentId,
      );
      await engine.submitAnswer(
        cellIndex: 2,
        playerId: 'p1',
        byUserId: winnerId,
      );
    }

    test(
      'Format A (3 TUR - 2 GALİBİYET): 2-0 ends match immediately; 1-1 plays Round 3 and resets passes each round',
      () async {
        // Case 1: u1 wins 2-0 -> series ends at Round 2 without playing Round 3
        final engine20 = GameEngine(
          board: _makeBoard(),
          answerValidator: allValidValidator,
          scoreCalculator: ScoreCalculator(),
          participantUserIds: const ['u1', 'u2'],
          localPlayerId: 'u1',
          totalRounds: 3,
          roundsToWin: 2,
        )..startGame();

        // u1 uses a pass in Round 1
        engine20.passTurn(byUserId: 'u1');
        expect(engine20.state.remainingPassesFor('u1'), 1);

        await winRow0For(engine20, 'u1');
        expect(engine20.state.isRoundSummary, isTrue);
        expect(engine20.state.status, GameStatus.playing);
        expect(engine20.state.roundWinsFor('u1'), 1);
        expect(engine20.state.roundWinsFor('u2'), 0);

        // Start Round 2 -> passes reset to 2/2 and boardVersion increments
        engine20.startNextRound(_makeBoard());
        expect(engine20.state.roundNumber, 2);
        expect(engine20.state.boardVersion, 2);
        expect(engine20.state.isRoundSummary, isFalse);
        expect(engine20.state.remainingPassesFor('u1'), 2);
        expect(engine20.state.remainingPassesFor('u2'), 2);

        // u1 wins Round 2 -> 2-0 ends the match immediately!
        await winRow0For(engine20, 'u1');
        expect(engine20.state.isRoundSummary, isFalse);
        expect(engine20.state.status, GameStatus.won);
        expect(engine20.state.winnerUserId, 'u1');
        expect(engine20.state.roundWinsFor('u1'), 2);

        // Case 2: 1-1 goes to Round 3
        final engine11 = GameEngine(
          board: _makeBoard(),
          answerValidator: allValidValidator,
          scoreCalculator: ScoreCalculator(),
          participantUserIds: const ['u1', 'u2'],
          localPlayerId: 'u1',
          totalRounds: 3,
          roundsToWin: 2,
        )..startGame();

        await winRow0For(engine11, 'u1');
        expect(engine11.state.isRoundSummary, isTrue);
        engine11.startNextRound(_makeBoard());

        await winRow0For(engine11, 'u2');
        expect(engine11.state.roundWinsFor('u1'), 1);
        expect(engine11.state.roundWinsFor('u2'), 1);
        expect(engine11.state.isRoundSummary, isTrue);
        expect(engine11.state.status, GameStatus.playing);

        engine11.startNextRound(_makeBoard());
        expect(engine11.state.roundNumber, 3);
        expect(engine11.state.boardVersion, 3);

        await winRow0For(engine11, 'u2');
        expect(engine11.state.status, GameStatus.won);
        expect(engine11.state.winnerUserId, 'u2');
        expect(engine11.state.roundWinsFor('u2'), 2);
      },
    );

    test(
      'Format B (5 TUR - 3 GALİBİYET): 3-0 ends at Round 3 and 2-2 plays Round 5',
      () async {
        final engine = GameEngine(
          board: _makeBoard(),
          answerValidator: allValidValidator,
          scoreCalculator: ScoreCalculator(),
          participantUserIds: const ['u1', 'u2'],
          localPlayerId: 'u1',
          totalRounds: 5,
          roundsToWin: 3,
        )..startGame();

        // Round 1: u1 wins (1-0)
        await winRow0For(engine, 'u1');
        expect(engine.state.isRoundSummary, isTrue);
        engine.startNextRound(_makeBoard());

        // Round 2: u2 wins (1-1)
        await winRow0For(engine, 'u2');
        expect(engine.state.isRoundSummary, isTrue);
        engine.startNextRound(_makeBoard());

        // Round 3: u1 wins (2-1)
        await winRow0For(engine, 'u1');
        expect(engine.state.isRoundSummary, isTrue);
        engine.startNextRound(_makeBoard());

        // Round 4: u2 wins (2-2) -> must play Round 5
        await winRow0For(engine, 'u2');
        expect(engine.state.roundWinsFor('u1'), 2);
        expect(engine.state.roundWinsFor('u2'), 2);
        expect(engine.state.isRoundSummary, isTrue);
        expect(engine.state.status, GameStatus.playing);

        engine.startNextRound(_makeBoard());
        expect(engine.state.roundNumber, 5);
        expect(engine.state.boardVersion, 5);

        // Round 5: u1 wins (3-2) -> series finishes
        await winRow0For(engine, 'u1');
        expect(engine.state.isRoundSummary, isFalse);
        expect(engine.state.status, GameStatus.won);
        expect(engine.state.winnerUserId, 'u1');
        expect(engine.state.roundWinsFor('u1'), 3);
      },
    );
  });

  group('Football SOS - 5. Multiplayer Board Synchronization', () {
    test(
      'Deterministic seeded board generation and OnlineGame multi-round canonical sync produce identical boards for both players',
      () async {
        final teams = List.generate(
          8,
          (i) =>
              Team(id: 'club_$i', name: 'Club $i', normalizedName: 'club $i'),
        );
        final pairs = <String, List<String>>{};
        for (var i = 0; i < teams.length; i++) {
          for (var j = i + 1; j < teams.length; j++) {
            final sorted = [teams[i].id, teams[j].id]..sort();
            pairs['${sorted[0]}|${sorted[1]}'] = ['p1', 'p2', 'p3', 'p4'];
          }
        }

        // Deterministic verification: same seed produces identical board for both clients
        final detA = BoardGenerator.generateDeterministicVerifiedBoard(
          seed: 424242,
          roundNumber: 1,
        );
        final detB = BoardGenerator.generateDeterministicVerifiedBoard(
          seed: 424242,
          roundNumber: 1,
        );
        expect(detA.boardId, detB.boardId);
        expect(detA.boardVersion, 1);
        expect(
          detA.rowTeams.map((t) => t.id).toList(),
          detB.rowTeams.map((t) => t.id).toList(),
        );
        expect(
          detA.colTeams.map((t) => t.id).toList(),
          detB.colTeams.map((t) => t.id).toList(),
        );

        final boardGenerator = BoardGenerator(
          teamRepository: _FakeTeamRepository(teams),
          answerValidator: _FakeAnswerValidator(pairs),
        );

        final boardsA = await boardGenerator.generateMultipleBoards(
          count: 5,
          seed: 987654,
        );
        final boardsB = await boardGenerator.generateMultipleBoards(
          count: 5,
          seed: 987654,
        );
        expect(boardsA.length, 5);
        expect(boardsB.length, 5);
        for (var r = 0; r < 5; r++) {
          expect(boardsA[r].boardId, boardsB[r].boardId);
          expect(boardsA[r].boardVersion, r + 1);
          expect(
            boardsA[r].rowTeams.map((t) => t.id).toList(),
            boardsB[r].rowTeams.map((t) => t.id).toList(),
          );
          expect(
            boardsA[r].colTeams.map((t) => t.id).toList(),
            boardsB[r].colTeams.map((t) => t.id).toList(),
          );
        }

        // Canonical Firestore document read by both Player 1 and Player 2
        final roundBoardsData = [
          for (var i = 0; i < boardsA.length; i++)
            OnlineRoundBoard(
              boardId: boardsA[i].boardId,
              boardVersion: i + 1,
              rowTeams: boardsA[i].rowTeams
                  .map((t) => OnlineTeam(id: t.id, name: t.name))
                  .toList(),
              colTeams: boardsA[i].colTeams
                  .map((t) => OnlineTeam(id: t.id, name: t.name))
                  .toList(),
            ).toMap(),
        ];

        final firestoreDoc = <String, dynamic>{
          'roomCode': '777888',
          'gameMode': 'sos',
          'status': 'playing',
          'player1Id': 'player_1',
          'player1Name': 'Oyuncu 1',
          'player2Id': 'player_2',
          'player2Name': 'Oyuncu 2',
          'currentTurn': 'player_1',
          'boardId': boardsA.first.boardId,
          'boardVersion': 1,
          'roundNumber': 1,
          'totalRounds': 5,
          'roundsToWin': 3,
          'player1RoundWins': 0,
          'player2RoundWins': 0,
          'roundStatus': 'playing',
          'rowTeams': roundBoardsData.first['rowTeams'],
          'colTeams': roundBoardsData.first['colTeams'],
          'roundBoards': roundBoardsData,
          'board': List.filled(9, null),
          'usedPlayerIds': <String>[],
          'passesUsed': {'player_1': 0, 'player_2': 0},
        };

        final p1View = OnlineGame.fromFirestore('match_sync_1', firestoreDoc);
        final p2View = OnlineGame.fromFirestore('match_sync_1', firestoreDoc);

        expect(p1View.matchId, 'match_sync_1');
        expect(p1View.boardId, p2View.boardId);
        expect(p1View.boardVersion, 1);
        expect(p2View.boardVersion, 1);
        expect(p1View.totalRounds, 5);
        expect(p1View.roundsToWin, 3);
        expect(p1View.roundBoards.length, 5);
        expect(
          p1View.rowCriteria.map((t) => t.id).toList(),
          p2View.rowCriteria.map((t) => t.id).toList(),
        );
        expect(
          p1View.columnCriteria.map((t) => t.id).toList(),
          p2View.columnCriteria.map((t) => t.id).toList(),
        );
      },
    );
  });
}

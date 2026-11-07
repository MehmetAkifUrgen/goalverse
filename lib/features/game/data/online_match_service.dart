import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/freezed/entity_models.dart';
import '../../../data/repositories/answer_validator_repository.dart';
import '../domain/online_game_model.dart';
import '../engine/board_generator.dart';

final onlineMatchServiceProvider = Provider<OnlineMatchService>((ref) {
  return OnlineMatchService();
});

class OnlineMatchService {
  final FirebaseFirestore _firestore;
  final Random _random;

  OnlineMatchService({FirebaseFirestore? firestore, Random? random})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _random = random ?? Random();

  String _generateRoomCode() {
    return (100000 + _random.nextInt(900000)).toString();
  }

  static List<Map<String, dynamic>> _teamsToFirestoreList(List<Team> teams) {
    return teams.map((t) {
      final numId = t.id.replaceAll('team_', '');
      final logo =
          t.logoUrl ??
          (numId.isNotEmpty
              ? 'https://tmssl.akamaized.net/images/wappen/head/$numId.png'
              : null);
      return {
        'id': t.id,
        'name': t.name,
        'country': t.country,
        'colorHex': t.primaryColorHex,
        'logoUrl': logo,
      };
    }).toList();
  }

  Future<Map<String, String>> createRoom({
    required String userId,
    required String userName,
    BoardGenerator? boardGenerator,
    String gameMode = 'sos',
    bool isPublic = false,
    int turnDurationSeconds = 30,
    int totalRounds = 3,
  }) async {
    final normalizedTotalRounds = (totalRounds == 5 || totalRounds == 1)
        ? totalRounds
        : 3;
    final roundsToWin = (normalizedTotalRounds ~/ 2) + 1;
    final roomCode = _generateRoomCode();
    final seed = 1000 + _random.nextInt(900000);

    List<Map<String, dynamic>> rowTeamsData = [];
    List<Map<String, dynamic>> colTeamsData = [];
    List<Map<String, dynamic>> roundBoardsData = [];
    String initialBoardId = 'board_${seed}_r1';

    if (gameMode == 'sos') {
      final boardCount = max(normalizedTotalRounds + 3, 6);
      List<GeneratedBoard> generatedBoards;
      if (boardGenerator != null) {
        generatedBoards = await boardGenerator.generateMultipleBoards(
          count: boardCount,
          difficulty: Difficulty.easy,
          seed: seed,
        );
      } else {
        generatedBoards = List.generate(
          boardCount,
          (i) => BoardGenerator.generateDeterministicVerifiedBoard(
            seed: seed,
            roundNumber: i + 1,
          ),
        );
      }

      roundBoardsData = generatedBoards.map((b) {
        return {
          'boardId': b.boardId,
          'boardVersion': b.boardVersion,
          'rowTeams': _teamsToFirestoreList(b.rowTeams),
          'colTeams': _teamsToFirestoreList(b.colTeams),
        };
      }).toList();

      if (roundBoardsData.isNotEmpty) {
        final first = roundBoardsData.first;
        initialBoardId = first['boardId'] as String? ?? initialBoardId;
        rowTeamsData = List<Map<String, dynamic>>.from(
          first['rowTeams'] as List,
        );
        colTeamsData = List<Map<String, dynamic>>.from(
          first['colTeams'] as List,
        );
      }
    }

    final docRef = _firestore.collection('games').doc();
    final nowMs = DateTime.now().millisecondsSinceEpoch;

    await docRef.set({
      'roomCode': roomCode,
      'gameMode': gameMode,
      'isPublic': isPublic,
      'seed': seed,
      'boardId': initialBoardId,
      'boardVersion': 1,
      'roundNumber': 1,
      'totalRounds': normalizedTotalRounds,
      'roundsToWin': roundsToWin,
      'player1RoundWins': 0,
      'player2RoundWins': 0,
      'roundStatus': 'playing',
      'lastRoundWinnerId': null,
      'roundBoards': roundBoardsData,
      'player1Id': userId,
      'player1Name': userName,
      'player2Id': null,
      'player2Name': null,
      'player1Score': 0,
      'player2Score': 0,
      'player1Round': 1,
      'player2Round': 1,
      'player1Finished': false,
      'player2Finished': false,
      'status': 'waiting',
      'currentTurn': userId,
      'winnerId': null,
      'rowTeams': rowTeamsData,
      'colTeams': colTeamsData,
      'board': List.filled(9, null),
      'usedPlayerIds': [],
      'passesUsed': {userId: 0},
      'totalPassesByUser': {userId: 0},
      'totalCorrectByUser': {userId: 0},
      'totalWrongByUser': {userId: 0},
      'moveHistory': [],
      'drawOffer': null,
      'lastDrawOfferAtByUser': {},
      'turnDurationSeconds': turnDurationSeconds,
      'lastMoveTimestamp': nowMs,
      'matchStartedAtMs': nowMs,
      'feedbackMessage': null,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return {
      'gameId': docRef.id,
      'roomCode': roomCode,
      'gameMode': gameMode,
      'totalRounds': normalizedTotalRounds.toString(),
      'roundsToWin': roundsToWin.toString(),
    };
  }

  /// Quick Matchmaking: finds an existing open public room for [gameMode]
  /// (and matching [totalRounds] for SOS), or creates a new public waiting room.
  /// Joining player NEVER generates a new board; it reads the room's canonical board.
  Future<Map<String, String>> findOrCreateQuickMatch({
    required String userId,
    required String userName,
    required String gameMode,
    BoardGenerator? boardGenerator,
    int turnDurationSeconds = 30,
    int totalRounds = 3,
  }) async {
    final normalizedTotalRounds = (totalRounds == 5 || totalRounds == 1)
        ? totalRounds
        : 3;

    final waitingQuery = await _firestore
        .collection('games')
        .where('status', isEqualTo: 'waiting')
        .limit(30)
        .get();

    final nowMs = DateTime.now().millisecondsSinceEpoch;

    for (final doc in waitingQuery.docs) {
      final data = doc.data();
      final docMode = data['gameMode'] as String? ?? 'sos';
      final isPublic = data['isPublic'] as bool? ?? false;
      final p1Id = data['player1Id'] as String? ?? '';
      final p2Id = data['player2Id'] as String?;
      final docTotalRounds = (data['totalRounds'] as num?)?.toInt() ?? 3;
      final lastMove = (data['lastMoveTimestamp'] as num?)?.toInt() ?? 0;
      final isRecent = (nowMs - lastMove) < 15 * 60 * 1000; // within 15 mins

      final formatMatches =
          gameMode != 'sos' || docTotalRounds == normalizedTotalRounds;

      if (isPublic &&
          docMode == gameMode &&
          formatMatches &&
          p1Id != userId &&
          p2Id == null &&
          isRecent) {
        final existingPasses = Map<String, dynamic>.from(
          data['passesUsed'] as Map? ?? {},
        );
        existingPasses.putIfAbsent(p1Id, () => 0);
        existingPasses[userId] = 0;

        await doc.reference.update({
          'player2Id': userId,
          'player2Name': userName,
          'passesUsed': existingPasses,
          'status': 'playing',
          'lastMoveTimestamp': nowMs,
          'matchStartedAtMs': nowMs,
        });

        return {
          'gameId': doc.id,
          'roomCode': data['roomCode'] as String? ?? '',
          'gameMode': docMode,
          'totalRounds': docTotalRounds.toString(),
          'matchedImmediately': 'true',
        };
      }
    }

    final created = await createRoom(
      userId: userId,
      userName: userName,
      boardGenerator: boardGenerator,
      gameMode: gameMode,
      isPublic: true,
      turnDurationSeconds: turnDurationSeconds,
      totalRounds: normalizedTotalRounds,
    );

    return {...created, 'matchedImmediately': 'false'};
  }

  /// Joins an existing room by 6-digit [roomCode].
  /// Never regenerates or modifies `rowTeams`, `colTeams`, `roundBoards`, or `board`.
  Future<Map<String, String>> joinRoomWithDetails({
    required String roomCode,
    required String userId,
    required String userName,
  }) async {
    final query = await _firestore
        .collection('games')
        .where('roomCode', isEqualTo: roomCode.trim())
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      throw StateError(
        'Oda kodu bulunamadı. Lütfen 6 haneli kodu kontrol edin.',
      );
    }

    final doc = query.docs.first;
    final data = doc.data();
    final gameMode = data['gameMode'] as String? ?? 'sos';
    final docTotalRounds = (data['totalRounds'] as num?)?.toInt() ?? 3;

    if (data['status'] != 'waiting' &&
        data['player1Id'] != userId &&
        data['player2Id'] != userId) {
      throw StateError('Bu oda dolu veya maç çoktan başladı.');
    }

    if (data['player1Id'] != userId) {
      final p1Id = data['player1Id'] as String? ?? '';
      final existingPasses = Map<String, dynamic>.from(
        data['passesUsed'] as Map? ?? {},
      );
      if (p1Id.isNotEmpty) existingPasses.putIfAbsent(p1Id, () => 0);
      existingPasses.putIfAbsent(userId, () => 0);
      final nowMs = DateTime.now().millisecondsSinceEpoch;

      await doc.reference.update({
        'player2Id': userId,
        'player2Name': userName,
        'passesUsed': existingPasses,
        'status': 'playing',
        'lastMoveTimestamp': nowMs,
        'matchStartedAtMs': nowMs,
      });
    }

    return {
      'gameId': doc.id,
      'gameMode': gameMode,
      'roomCode': data['roomCode'] as String? ?? roomCode.trim(),
      'totalRounds': docTotalRounds.toString(),
    };
  }

  Future<String> joinRoom({
    required String roomCode,
    required String userId,
    required String userName,
  }) async {
    final res = await joinRoomWithDetails(
      roomCode: roomCode,
      userId: userId,
      userName: userName,
    );
    return res['gameId']!;
  }

  Future<OnlineGame?> getGameOnce(String gameId) async {
    final doc = await _firestore.collection('games').doc(gameId).get();
    if (!doc.exists || doc.data() == null) return null;
    return OnlineGame.fromFirestore(doc.id, doc.data()!);
  }

  Stream<OnlineGame> streamGame(String gameId) {
    return _firestore.collection('games').doc(gameId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) {
        throw StateError('Maç odası bulunamadı.');
      }
      return OnlineGame.fromFirestore(doc.id, doc.data()!);
    });
  }

  /// Syncs score & round progress for any of the 6 arcade/quiz modes in real time.
  Future<void> updateArcadeProgress({
    required String gameId,
    required String userId,
    required int score,
    required int round,
    bool finished = false,
  }) async {
    final gameRef = _firestore.collection('games').doc(gameId);
    await _firestore.runTransaction((transaction) async {
      final snap = await transaction.get(gameRef);
      if (!snap.exists || snap.data() == null) return;
      final data = snap.data()!;

      final p1Id = data['player1Id'] as String? ?? '';
      final isP1 = userId == p1Id;

      final p1Score = isP1
          ? score
          : ((data['player1Score'] as num?)?.toInt() ?? 0);
      final p2Score = !isP1
          ? score
          : ((data['player2Score'] as num?)?.toInt() ?? 0);
      final p1Finished = isP1
          ? finished
          : (data['player1Finished'] as bool? ?? false);
      final p2Finished = !isP1
          ? finished
          : (data['player2Finished'] as bool? ?? false);

      final updates = <String, dynamic>{
        if (isP1) 'player1Score': score else 'player2Score': score,
        if (isP1) 'player1Round': round else 'player2Round': round,
        if (isP1) 'player1Finished': finished else 'player2Finished': finished,
        'lastMoveTimestamp': DateTime.now().millisecondsSinceEpoch,
      };

      if (p1Finished && p2Finished) {
        updates['status'] = 'finished';
        final p2Id = data['player2Id'] as String?;
        if (p1Score > p2Score) {
          updates['winnerId'] = p1Id;
        } else if (p2Score > p1Score && p2Id != null) {
          updates['winnerId'] = p2Id;
        } else {
          updates['winnerId'] = 'draw';
        }
      }

      transaction.update(gameRef, updates);
    });
  }

  /// Submits a footballer move for [cellIndex] inside a Firestore transaction.
  /// Footballer reuse IS ALLOWED across cells — only club criteria and cell occupancy are checked.
  /// Handles multi-round transitions when a round is won or drawn.
  Future<String?> makeMove({
    required String gameId,
    required int cellIndex,
    required Player player,
    required String userId,
    required AnswerValidatorRepository validator,
  }) async {
    final gameRef = _firestore.collection('games').doc(gameId);

    return await _firestore.runTransaction<String?>((transaction) async {
      final snapshot = await transaction.get(gameRef);
      if (!snapshot.exists) return 'Maç bulunamadı.';

      final data = snapshot.data()!;
      final game = OnlineGame.fromFirestore(snapshot.id, data);

      if (game.status != 'playing') return 'Maç henüz aktif değil.';
      if (game.roundStatus == 'round_summary') {
        return 'Yeni tur hazırlanıyor, lütfen bekleyin.';
      }
      if (game.currentTurn != userId) return 'Sıra rakipte.';
      if (cellIndex < 0 || cellIndex >= 9) return 'Geçersiz hücre.';
      if (game.board[cellIndex] != null) return 'Bu kare zaten dolu.';
      if (player.id.trim().isEmpty) return 'Geçersiz futbolcu seçimi.';

      final row = cellIndex ~/ 3;
      final col = cellIndex % 3;
      final rowTeam = game.rowTeams[row];
      final colTeam = game.colTeams[col];

      final otherPlayerId = userId == game.player1Id
          ? game.player2Id
          : game.player1Id;
      final actorName = userId == game.player1Id
          ? game.player1Name
          : (game.player2Name ?? 'Oyuncu 2');
      final nowMs = DateTime.now().millisecondsSinceEpoch;

      bool isValid = await validator.isPlayerInTeamPair(
        player.id,
        rowTeam.id,
        colTeam.id,
      );
      if (!isValid && player.clubs.isNotEmpty) {
        isValid =
            player.clubs.contains(rowTeam.id) &&
            player.clubs.contains(colTeam.id);
      }

      if (!isValid) {
        final updatedWrong = Map<String, int>.from(game.totalWrongByUser);
        updatedWrong[userId] = (updatedWrong[userId] ?? 0) + 1;

        transaction.update(gameRef, {
          'currentTurn': otherPlayerId,
          'totalWrongByUser': updatedWrong,
          'lastMoveTimestamp': nowMs,
          'feedbackMessage':
              'Yanlış cevap! ${player.name}, ${rowTeam.name} ve ${colTeam.name} kulüplerinde oynamadı. Sıra rakibe geçti.',
        });
        return 'Yanlış cevap! Sıra rakibe geçti.';
      }

      final mark = userId == game.player1Id ? 'X' : 'O';
      final newCell = OnlineCell(
        cellIndex: cellIndex,
        playerId: player.id,
        playerName: player.name,
        byUserId: userId,
        mark: mark,
      );

      final newBoard = List<OnlineCell?>.from(game.board);
      newBoard[cellIndex] = newCell;

      final updatedUsed = [...game.usedPlayerIds, player.id];
      final updatedCorrect = Map<String, int>.from(game.totalCorrectByUser);
      updatedCorrect[userId] = (updatedCorrect[userId] ?? 0) + 1;

      final updatedHistory = [
        ...game.moveHistory.map((m) => m.toMap()),
        OnlineMoveRecord(
          type: 'move',
          byUserId: userId,
          byUserName: actorName,
          cellIndex: cellIndex,
          playerId: player.id,
          playerName: player.name,
          timestampMs: nowMs,
          roundNumber: game.roundNumber,
        ).toMap(),
      ];

      final roundWinnerId = OnlineGame.checkWinner(newBoard);
      final isRoundOver = roundWinnerId != null;

      int p1RoundWins = game.player1RoundWins;
      int p2RoundWins = game.player2RoundWins;
      if (roundWinnerId == game.player1Id) {
        p1RoundWins += 1;
      } else if (roundWinnerId != null &&
          game.player2Id != null &&
          roundWinnerId == game.player2Id) {
        p2RoundWins += 1;
      }

      final isSeriesWon =
          p1RoundWins >= game.roundsToWin || p2RoundWins >= game.roundsToWin;
      final isSingleRoundFinished = game.totalRounds <= 1 && isRoundOver;
      final isMatchFinished = isSeriesWon || isSingleRoundFinished;

      final p1TotalCorrect = updatedCorrect[game.player1Id] ?? 0;
      final p2TotalCorrect = game.player2Id != null
          ? (updatedCorrect[game.player2Id!] ?? 0)
          : 0;

      String nextStatus = 'playing';
      String nextRoundStatus = 'playing';
      String? matchWinnerId;
      String? nextTurn = otherPlayerId;
      String feedback = '${player.name} doğru! Sıra rakipte.';

      if (isMatchFinished) {
        nextStatus = 'finished';
        nextRoundStatus = 'finished';
        matchWinnerId = roundWinnerId;
        nextTurn = null;
        feedback = roundWinnerId == 'draw'
            ? 'Tur ve maç berabere tamamlandı!'
            : '$actorName seriyi kazandı!';
      } else if (isRoundOver) {
        nextStatus = 'playing';
        nextRoundStatus = 'round_summary';
        matchWinnerId = null;
        feedback = roundWinnerId == 'draw'
            ? 'Tur ${game.roundNumber} berabere bitti! Yeni tur hazırlanıyor.'
            : 'Tur ${game.roundNumber} tamamlandı! $actorName turu kazandı.';
      }

      transaction.update(gameRef, {
        'board': newBoard.map((c) => c?.toMap()).toList(),
        'usedPlayerIds': updatedUsed,
        'totalCorrectByUser': updatedCorrect,
        'moveHistory': updatedHistory,
        'player1RoundWins': p1RoundWins,
        'player2RoundWins': p2RoundWins,
        'player1Score': p1RoundWins * 300 + p1TotalCorrect * 100,
        'player2Score': p2RoundWins * 300 + p2TotalCorrect * 100,
        'currentTurn': nextTurn,
        'lastMoveTimestamp': nowMs,
        'feedbackMessage': feedback,
        'status': nextStatus,
        'roundStatus': nextRoundStatus,
        'lastRoundWinnerId': isRoundOver ? roundWinnerId : null,
        'winnerId': matchWinnerId,
      });

      return null;
    });
  }

  /// Advances a multi-round Football SOS match from `round_summary` to the next round
  /// inside an atomic Firestore transaction.
  /// Both clients will receive the exact same `rowTeams`, `colTeams`, `boardId`, and `boardVersion`.
  Future<String?> advanceToNextRound({
    required String gameId,
    int? expectedFromRound,
  }) async {
    final gameRef = _firestore.collection('games').doc(gameId);

    return await _firestore.runTransaction<String?>((transaction) async {
      final snapshot = await transaction.get(gameRef);
      if (!snapshot.exists || snapshot.data() == null) return 'GAME_NOT_FOUND';

      final game = OnlineGame.fromFirestore(snapshot.id, snapshot.data()!);
      if (game.status != 'playing' || game.roundStatus != 'round_summary') {
        // Already advanced by the other player's client; safe idempotent no-op
        return null;
      }
      if (expectedFromRound != null && game.roundNumber != expectedFromRound) {
        return null;
      }

      final nextRound = game.roundNumber + 1;
      final nextBoardVersion = game.boardVersion + 1;
      final nowMs = DateTime.now().millisecondsSinceEpoch;

      OnlineRoundBoard nextRoundBoard;
      if (nextRound - 1 < game.roundBoards.length) {
        nextRoundBoard = game.roundBoards[nextRound - 1];
      } else {
        final fallback = BoardGenerator.generateDeterministicVerifiedBoard(
          seed: game.seed,
          roundNumber: nextRound,
        );
        nextRoundBoard = OnlineRoundBoard(
          boardId: fallback.boardId,
          boardVersion: nextBoardVersion,
          rowTeams: _teamsToFirestoreList(
            fallback.rowTeams,
          ).map((m) => OnlineTeam.fromMap(m)).toList(),
          colTeams: _teamsToFirestoreList(
            fallback.colTeams,
          ).map((m) => OnlineTeam.fromMap(m)).toList(),
        );
      }

      // Reset pass rights (2 passes per player) at the start of every new round
      final resetPasses = <String, int>{
        game.player1Id: 0,
        if (game.player2Id != null) game.player2Id!: 0,
      };

      // Alternate starting player each round for fairness
      final nextStarter = (nextRound % 2 == 1)
          ? game.player1Id
          : (game.player2Id ?? game.player1Id);

      transaction.update(gameRef, {
        'roundNumber': nextRound,
        'boardId': nextRoundBoard.boardId,
        'boardVersion': nextBoardVersion,
        'rowTeams': nextRoundBoard.rowTeams.map((t) => t.toMap()).toList(),
        'colTeams': nextRoundBoard.colTeams.map((t) => t.toMap()).toList(),
        'board': List.filled(9, null),
        'passesUsed': resetPasses,
        'roundStatus': 'playing',
        'lastRoundWinnerId': null,
        'currentTurn': nextStarter,
        'lastMoveTimestamp': nowMs,
        'feedbackMessage': 'Tur $nextRound başladı! Yeni tahta yüklendi.',
      });

      return null;
    });
  }

  /// Passes the current player's turn inside a Firestore transaction.
  /// Each player is allowed at most [OnlineGame.maxPassesPerPlayer] (2) passes per round.
  Future<String?> passTurn({
    required String gameId,
    required String userId,
    int? nowMsOverride,
  }) async {
    final gameRef = _firestore.collection('games').doc(gameId);

    return await _firestore.runTransaction<String?>((transaction) async {
      final snapshot = await transaction.get(gameRef);
      if (!snapshot.exists || snapshot.data() == null) {
        return 'GAME_NOT_FOUND';
      }

      final game = OnlineGame.fromFirestore(snapshot.id, snapshot.data()!);
      if (game.status != 'playing' || game.roundStatus == 'round_summary') {
        return 'GAME_NOT_PLAYING';
      }
      if (game.currentTurn != userId) {
        return 'NOT_YOUR_TURN';
      }
      if (game.remainingPassesFor(userId) <= 0) {
        return 'NO_PASSES_LEFT';
      }

      final nowMs = nowMsOverride ?? DateTime.now().millisecondsSinceEpoch;
      final otherPlayerId = userId == game.player1Id
          ? game.player2Id
          : game.player1Id;
      final actorName = userId == game.player1Id
          ? game.player1Name
          : (game.player2Name ?? 'Oyuncu 2');

      final updatedPasses = Map<String, int>.from(game.passesUsed);
      updatedPasses[userId] = (updatedPasses[userId] ?? 0) + 1;

      final updatedTotalPasses = Map<String, int>.from(game.totalPassesByUser);
      updatedTotalPasses[userId] = (updatedTotalPasses[userId] ?? 0) + 1;

      final updatedHistory = [
        ...game.moveHistory.map((m) => m.toMap()),
        OnlineMoveRecord(
          type: 'pass',
          byUserId: userId,
          byUserName: actorName,
          timestampMs: nowMs,
          roundNumber: game.roundNumber,
        ).toMap(),
      ];

      transaction.update(gameRef, {
        'passesUsed': updatedPasses,
        'totalPassesByUser': updatedTotalPasses,
        'moveHistory': updatedHistory,
        'currentTurn': otherPlayerId,
        'lastMoveTimestamp': nowMs,
        'feedbackMessage': '$actorName pas geçti! Sıra rakipte.',
      });

      return null;
    });
  }

  /// Sends a draw offer to the opponent inside a Firestore transaction.
  /// Enforces:
  /// - Only 1 active offer at a time.
  /// - Offer expires after 30 seconds if unanswered.
  /// - Sender has a 60-second cooldown before offering again.
  Future<String?> offerDraw({
    required String gameId,
    required String userId,
    String? userName,
    int? nowMsOverride,
  }) async {
    final gameRef = _firestore.collection('games').doc(gameId);

    return await _firestore.runTransaction<String?>((transaction) async {
      final snapshot = await transaction.get(gameRef);
      if (!snapshot.exists || snapshot.data() == null) {
        return 'GAME_NOT_FOUND';
      }

      final game = OnlineGame.fromFirestore(snapshot.id, snapshot.data()!);
      if (game.status != 'playing' || game.roundStatus == 'round_summary') {
        return 'GAME_NOT_PLAYING';
      }
      if (userId != game.player1Id && userId != game.player2Id) {
        return 'NOT_A_PLAYER';
      }

      final nowMs = nowMsOverride ?? DateTime.now().millisecondsSinceEpoch;

      if (game.hasActiveDrawOffer(nowMs)) {
        return 'ACTIVE_OFFER_EXISTS';
      }

      if (game.drawOfferCooldownSecondsFor(userId, nowMs) > 0) {
        return 'DRAW_OFFER_COOLDOWN';
      }

      final resolvedName =
          userName ??
          (userId == game.player1Id
              ? game.player1Name
              : (game.player2Name ?? 'Oyuncu 2'));

      final offer = OnlineDrawOffer(
        fromUserId: userId,
        fromUserName: resolvedName,
        createdAtMs: nowMs,
        expiresAtMs: nowMs + (OnlineGame.drawOfferDurationSeconds * 1000),
        status: 'pending',
      );

      final updatedCooldowns = Map<String, int>.from(
        game.lastDrawOfferAtByUser,
      );
      updatedCooldowns[userId] = nowMs;

      final updatedHistory = [
        ...game.moveHistory.map((m) => m.toMap()),
        OnlineMoveRecord(
          type: 'draw_offer',
          byUserId: userId,
          byUserName: resolvedName,
          timestampMs: nowMs,
          roundNumber: game.roundNumber,
        ).toMap(),
      ];

      transaction.update(gameRef, {
        'drawOffer': offer.toMap(),
        'lastDrawOfferAtByUser': updatedCooldowns,
        'moveHistory': updatedHistory,
        'feedbackMessage': '$resolvedName beraberlik teklif etti.',
      });

      return null;
    });
  }

  /// Responds (accept or reject) to an active draw offer inside a Firestore transaction.
  Future<String?> respondToDrawOffer({
    required String gameId,
    required String userId,
    required bool accept,
    int? nowMsOverride,
  }) async {
    final gameRef = _firestore.collection('games').doc(gameId);

    return await _firestore.runTransaction<String?>((transaction) async {
      final snapshot = await transaction.get(gameRef);
      if (!snapshot.exists || snapshot.data() == null) {
        return 'GAME_NOT_FOUND';
      }

      final game = OnlineGame.fromFirestore(snapshot.id, snapshot.data()!);
      if (game.status != 'playing') {
        return 'GAME_NOT_PLAYING';
      }
      final offer = game.drawOffer;
      if (offer == null || offer.status != 'pending') {
        return 'NO_ACTIVE_OFFER';
      }
      if (offer.fromUserId == userId) {
        return 'CANNOT_RESPOND_OWN_OFFER';
      }

      final nowMs = nowMsOverride ?? DateTime.now().millisecondsSinceEpoch;
      final responderName = userId == game.player1Id
          ? game.player1Name
          : (game.player2Name ?? 'Oyuncu 2');

      if (nowMs >= offer.expiresAtMs) {
        final expiredOffer = OnlineDrawOffer(
          fromUserId: offer.fromUserId,
          fromUserName: offer.fromUserName,
          createdAtMs: offer.createdAtMs,
          expiresAtMs: offer.expiresAtMs,
          status: 'expired',
          respondedAtMs: nowMs,
        );
        final updatedHistory = [
          ...game.moveHistory.map((m) => m.toMap()),
          OnlineMoveRecord(
            type: 'draw_expired',
            byUserId: offer.fromUserId,
            timestampMs: nowMs,
            roundNumber: game.roundNumber,
          ).toMap(),
        ];
        transaction.update(gameRef, {
          'drawOffer': expiredOffer.toMap(),
          'moveHistory': updatedHistory,
          'feedbackMessage': 'Beraberlik teklifi süresi doldu (30sn).',
        });
        return 'DRAW_OFFER_EXPIRED';
      }

      if (accept) {
        final acceptedOffer = OnlineDrawOffer(
          fromUserId: offer.fromUserId,
          fromUserName: offer.fromUserName,
          createdAtMs: offer.createdAtMs,
          expiresAtMs: offer.expiresAtMs,
          status: 'accepted',
          respondedAtMs: nowMs,
        );
        final updatedHistory = [
          ...game.moveHistory.map((m) => m.toMap()),
          OnlineMoveRecord(
            type: 'draw_accepted',
            byUserId: userId,
            byUserName: responderName,
            timestampMs: nowMs,
            roundNumber: game.roundNumber,
          ).toMap(),
        ];
        transaction.update(gameRef, {
          'drawOffer': acceptedOffer.toMap(),
          'moveHistory': updatedHistory,
          'status': 'finished',
          'roundStatus': 'finished',
          'winnerId': 'draw',
          'currentTurn': null,
          'lastMoveTimestamp': nowMs,
          'feedbackMessage':
              'Beraberlik teklifi kabul edildi! Maç berabere bitti.',
        });
      } else {
        final rejectedOffer = OnlineDrawOffer(
          fromUserId: offer.fromUserId,
          fromUserName: offer.fromUserName,
          createdAtMs: offer.createdAtMs,
          expiresAtMs: offer.expiresAtMs,
          status: 'rejected',
          respondedAtMs: nowMs,
        );
        final updatedHistory = [
          ...game.moveHistory.map((m) => m.toMap()),
          OnlineMoveRecord(
            type: 'draw_rejected',
            byUserId: userId,
            byUserName: responderName,
            timestampMs: nowMs,
            roundNumber: game.roundNumber,
          ).toMap(),
        ];
        transaction.update(gameRef, {
          'drawOffer': rejectedOffer.toMap(),
          'moveHistory': updatedHistory,
          'feedbackMessage': 'Beraberlik teklifi reddedildi. Maç devam ediyor!',
        });
      }

      return null;
    });
  }

  /// Marks an unanswered draw offer as expired once 30 seconds have elapsed.
  Future<void> expireDrawOffer({
    required String gameId,
    int? nowMsOverride,
  }) async {
    final gameRef = _firestore.collection('games').doc(gameId);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(gameRef);
      if (!snapshot.exists || snapshot.data() == null) return;

      final game = OnlineGame.fromFirestore(snapshot.id, snapshot.data()!);
      final offer = game.drawOffer;
      if (offer == null || offer.status != 'pending') return;

      final nowMs = nowMsOverride ?? DateTime.now().millisecondsSinceEpoch;
      if (nowMs < offer.expiresAtMs) return;

      final expiredOffer = OnlineDrawOffer(
        fromUserId: offer.fromUserId,
        fromUserName: offer.fromUserName,
        createdAtMs: offer.createdAtMs,
        expiresAtMs: offer.expiresAtMs,
        status: 'expired',
        respondedAtMs: nowMs,
      );
      final updatedHistory = [
        ...game.moveHistory.map((m) => m.toMap()),
        OnlineMoveRecord(
          type: 'draw_expired',
          byUserId: offer.fromUserId,
          timestampMs: nowMs,
          roundNumber: game.roundNumber,
        ).toMap(),
      ];

      transaction.update(gameRef, {
        'drawOffer': expiredOffer.toMap(),
        'moveHistory': updatedHistory,
        'feedbackMessage': 'Beraberlik teklifi süresi doldu (30sn).',
      });
    });
  }

  Future<void> timeoutPassTurn({
    required String gameId,
    required String timedOutUserId,
  }) async {
    final gameRef = _firestore.collection('games').doc(gameId);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(gameRef);
      if (!snapshot.exists || snapshot.data() == null) return;
      final data = snapshot.data()!;
      if (data['status'] != 'playing') return;
      if (data['roundStatus'] == 'round_summary') return;
      if (data['currentTurn'] != timedOutUserId) return;

      final game = OnlineGame.fromFirestore(snapshot.id, data);
      final p1 = game.player1Id;
      final p2 = game.player2Id;
      final other = timedOutUserId == p1 ? p2 : p1;
      final nowMs = DateTime.now().millisecondsSinceEpoch;

      final updatedHistory = [
        ...game.moveHistory.map((m) => m.toMap()),
        OnlineMoveRecord(
          type: 'timeout',
          byUserId: timedOutUserId,
          timestampMs: nowMs,
          roundNumber: game.roundNumber,
        ).toMap(),
      ];

      transaction.update(gameRef, {
        'currentTurn': other,
        'moveHistory': updatedHistory,
        'lastMoveTimestamp': nowMs,
        'feedbackMessage': 'Süre doldu! Sıra rakibe geçti.',
      });
    });
  }
}

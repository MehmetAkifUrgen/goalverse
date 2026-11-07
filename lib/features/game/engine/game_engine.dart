import 'package:flutter/foundation.dart';

import '../../../../data/repositories/answer_validator_repository.dart';
import '../../../data/models/freezed/entity_models.dart';
import 'board_generator.dart';
import 'score_calculator.dart';

enum GameMark { x, o, none }

enum GameStatus { idle, playing, won, draw }

class GameMoveRecord {
  final String
  type; // 'move', 'pass', 'timeout', 'draw_offer', 'draw_accepted', 'draw_rejected', 'draw_expired'
  final String byUserId;
  final int? cellIndex;
  final String? playerId;
  final String? playerName;
  final int timestampMs;
  final int roundNumber;

  const GameMoveRecord({
    required this.type,
    required this.byUserId,
    this.cellIndex,
    this.playerId,
    this.playerName,
    required this.timestampMs,
    this.roundNumber = 1,
  });

  Map<String, dynamic> toMap() => {
    'type': type,
    'byUserId': byUserId,
    if (cellIndex != null) 'cellIndex': cellIndex,
    if (playerId != null) 'playerId': playerId,
    if (playerName != null) 'playerName': playerName,
    'timestampMs': timestampMs,
    'roundNumber': roundNumber,
  };

  factory GameMoveRecord.fromMap(Map<String, dynamic> map) {
    return GameMoveRecord(
      type: map['type'] as String? ?? 'move',
      byUserId: map['byUserId'] as String? ?? '',
      cellIndex: (map['cellIndex'] as num?)?.toInt(),
      playerId: map['playerId'] as String?,
      playerName: map['playerName'] as String?,
      timestampMs: (map['timestampMs'] as num?)?.toInt() ?? 0,
      roundNumber: (map['roundNumber'] as num?)?.toInt() ?? 1,
    );
  }
}

class GameDrawOffer {
  final String fromUserId;
  final int createdAtMs;
  final int expiresAtMs;
  final String status; // 'pending', 'accepted', 'rejected', 'expired'
  final int? respondedAtMs;

  const GameDrawOffer({
    required this.fromUserId,
    required this.createdAtMs,
    required this.expiresAtMs,
    this.status = 'pending',
    this.respondedAtMs,
  });

  bool isPendingAt(int nowMs) => status == 'pending' && nowMs < expiresAtMs;

  int remainingSecondsAt(int nowMs) {
    if (!isPendingAt(nowMs)) return 0;
    return ((expiresAtMs - nowMs) / 1000).ceil().clamp(0, 30);
  }

  GameDrawOffer copyWith({String? status, int? respondedAtMs}) {
    return GameDrawOffer(
      fromUserId: fromUserId,
      createdAtMs: createdAtMs,
      expiresAtMs: expiresAtMs,
      status: status ?? this.status,
      respondedAtMs: respondedAtMs ?? this.respondedAtMs,
    );
  }

  Map<String, dynamic> toMap() => {
    'fromUserId': fromUserId,
    'createdAtMs': createdAtMs,
    'expiresAtMs': expiresAtMs,
    'status': status,
    if (respondedAtMs != null) 'respondedAtMs': respondedAtMs,
  };

  factory GameDrawOffer.fromMap(Map<String, dynamic> map) {
    return GameDrawOffer(
      fromUserId: map['fromUserId'] as String? ?? '',
      createdAtMs: (map['createdAtMs'] as num?)?.toInt() ?? 0,
      expiresAtMs: (map['expiresAtMs'] as num?)?.toInt() ?? 0,
      status: map['status'] as String? ?? 'pending',
      respondedAtMs: (map['respondedAtMs'] as num?)?.toInt(),
    );
  }
}

class GameCell {
  final int row;
  final int col;
  final Team rowTeam;
  final Team colTeam;
  Player? selectedPlayer;
  String? selectedByUserId;
  GameMark mark = GameMark.none;

  GameCell({
    required this.row,
    required this.col,
    required this.rowTeam,
    required this.colTeam,
  });

  bool get isEmpty => mark == GameMark.none;
}

class GameState {
  static const int maxPassesPerPlayer = 2;
  static const int drawOfferDurationSeconds = 30;
  static const int drawOfferCooldownSeconds = 60;

  String boardId;
  int boardVersion;
  int roundNumber;
  final int totalRounds;
  final int roundsToWin;
  bool isRoundSummary;
  String? lastRoundWinnerId; // userId or 'draw'

  List<GameCell> cells;
  final List<String> usedPlayerIds;
  final List<String> playerOrder;
  int currentTurnIndex = 0;
  GameStatus status = GameStatus.idle;
  String? winnerUserId;
  List<int> winningLine = const [];
  final Map<String, int> scores;
  final Map<String, int> roundWins;
  final Map<String, int> passesUsed;
  final Map<String, int> totalPassesByUser;
  final Map<String, int> totalCorrectByUser;
  final Map<String, int> totalWrongByUser;
  final List<GameMoveRecord> moveHistory;
  final Map<String, int> lastDrawOfferAtByUser;
  GameDrawOffer? drawOffer;
  bool endedByDrawOffer = false;
  int streakPlayer1;
  int streakPlayer2;
  final int matchStartedAtMs;

  GameState({
    this.boardId = 'board_r1',
    this.boardVersion = 1,
    this.roundNumber = 1,
    this.totalRounds = 1,
    int? roundsToWin,
    this.isRoundSummary = false,
    this.lastRoundWinnerId,
    required this.cells,
    required this.usedPlayerIds,
    required this.playerOrder,
    required this.scores,
    Map<String, int>? roundWins,
    Map<String, int>? passesUsed,
    Map<String, int>? totalPassesByUser,
    Map<String, int>? totalCorrectByUser,
    Map<String, int>? totalWrongByUser,
    List<GameMoveRecord>? moveHistory,
    Map<String, int>? lastDrawOfferAtByUser,
    this.drawOffer,
    this.endedByDrawOffer = false,
    this.streakPlayer1 = 0,
    this.streakPlayer2 = 0,
    int? matchStartedAtMs,
  }) : roundsToWin = roundsToWin ?? ((totalRounds ~/ 2) + 1),
       roundWins = roundWins ?? {for (final uid in playerOrder) uid: 0},
       passesUsed = passesUsed ?? {for (final uid in playerOrder) uid: 0},
       totalPassesByUser =
           totalPassesByUser ?? {for (final uid in playerOrder) uid: 0},
       totalCorrectByUser =
           totalCorrectByUser ?? {for (final uid in playerOrder) uid: 0},
       totalWrongByUser =
           totalWrongByUser ?? {for (final uid in playerOrder) uid: 0},
       moveHistory = moveHistory ?? [],
       lastDrawOfferAtByUser = lastDrawOfferAtByUser ?? {},
       matchStartedAtMs =
           matchStartedAtMs ?? DateTime.now().millisecondsSinceEpoch;

  String? get currentTurnUserId {
    if (playerOrder.isEmpty) return null;
    return playerOrder[currentTurnIndex % playerOrder.length];
  }

  int roundWinsFor(String userId) => roundWins[userId] ?? 0;

  int remainingPassesFor(String userId) {
    final used = passesUsed[userId] ?? 0;
    return (maxPassesPerPlayer - used).clamp(0, maxPassesPerPlayer);
  }

  bool canPass(String userId) {
    return status == GameStatus.playing &&
        !isRoundSummary &&
        currentTurnUserId == userId &&
        remainingPassesFor(userId) > 0;
  }

  bool hasActiveDrawOffer([int? nowMs]) {
    final now = nowMs ?? DateTime.now().millisecondsSinceEpoch;
    return drawOffer != null && drawOffer!.isPendingAt(now);
  }

  int drawOfferRemainingSeconds([int? nowMs]) {
    final now = nowMs ?? DateTime.now().millisecondsSinceEpoch;
    return drawOffer?.remainingSecondsAt(now) ?? 0;
  }

  int drawOfferCooldownSecondsFor(String userId, [int? nowMs]) {
    final now = nowMs ?? DateTime.now().millisecondsSinceEpoch;
    final lastSent = lastDrawOfferAtByUser[userId];
    if (lastSent == null || lastSent <= 0) return 0;
    final elapsedMs = now - lastSent;
    const cooldownMs = drawOfferCooldownSeconds * 1000;
    if (elapsedMs >= cooldownMs) return 0;
    return ((cooldownMs - elapsedMs) / 1000).ceil().clamp(
      0,
      drawOfferCooldownSeconds,
    );
  }

  bool canOfferDraw(String userId, [int? nowMs]) {
    final now = nowMs ?? DateTime.now().millisecondsSinceEpoch;
    return status == GameStatus.playing &&
        !isRoundSummary &&
        !hasActiveDrawOffer(now) &&
        drawOfferCooldownSecondsFor(userId, now) == 0;
  }

  bool isCellFilled(int index) {
    if (index < 0 || index >= 9) return false;
    return cells[index].mark != GameMark.none;
  }

  GameCell cellAt(int row, int col) {
    return cells[row * 3 + col];
  }

  int matchDurationSeconds([int? nowMs]) {
    final now = nowMs ?? DateTime.now().millisecondsSinceEpoch;
    return ((now - matchStartedAtMs) / 1000).round().clamp(1, 86400);
  }
}

class GameEngine extends ChangeNotifier {
  final AnswerValidatorRepository answerValidator;
  final ScoreCalculator scoreCalculator;
  late GameState _state;

  final String Function() _getLocalPlayerId;

  GameState get state => _state;

  GameEngine({
    required GeneratedBoard board,
    required this.answerValidator,
    required this.scoreCalculator,
    required List<String> participantUserIds,
    required String localPlayerId,
    int totalRounds = 1,
    int? roundsToWin,
    int? matchStartedAtMs,
  }) : _getLocalPlayerId = (() => localPlayerId) {
    final cells = _buildCellsFromBoard(board);
    final scores = <String, int>{};
    final passesUsed = <String, int>{};
    final roundWins = <String, int>{};
    for (final uid in participantUserIds) {
      scores[uid] = 0;
      passesUsed[uid] = 0;
      roundWins[uid] = 0;
    }
    _state = GameState(
      boardId: board.boardId,
      boardVersion: board.boardVersion,
      roundNumber: 1,
      totalRounds: totalRounds,
      roundsToWin: roundsToWin ?? ((totalRounds ~/ 2) + 1),
      cells: cells,
      usedPlayerIds: [],
      playerOrder: List.from(participantUserIds),
      scores: scores,
      roundWins: roundWins,
      passesUsed: passesUsed,
      matchStartedAtMs: matchStartedAtMs,
    );
  }

  static List<GameCell> _buildCellsFromBoard(GeneratedBoard board) {
    final cells = <GameCell>[];
    for (int r = 0; r < 3; r++) {
      for (int c = 0; c < 3; c++) {
        cells.add(
          GameCell(
            row: r,
            col: c,
            rowTeam: board.rowTeams[r],
            colTeam: board.colTeams[c],
          ),
        );
      }
    }
    return cells;
  }

  void startGame() {
    _state.status = GameStatus.playing;
    _state.isRoundSummary = false;
    _state.currentTurnIndex = 0;
    notifyListeners();
  }

  /// Advances the series to the next round with a fresh 3x3 [nextBoard],
  /// resetting per-round pass counters (2 per player) and alternating the starting player.
  void startNextRound(GeneratedBoard nextBoard) {
    if (_state.status == GameStatus.won || _state.endedByDrawOffer) return;

    _state.roundNumber += 1;
    _state.boardId = nextBoard.boardId;
    _state.boardVersion = _state.roundNumber;
    _state.cells = _buildCellsFromBoard(nextBoard);
    _state.winningLine = const [];
    _state.isRoundSummary = false;
    _state.lastRoundWinnerId = null;
    _state.status = GameStatus.playing;
    for (final uid in _state.playerOrder) {
      _state.passesUsed[uid] = 0;
    }
    // Alternate starting player each round for fairness
    _state.currentTurnIndex =
        (_state.roundNumber - 1) % _state.playerOrder.length;
    notifyListeners();
  }

  /// Timer expiration or wrong answer turn change (does not consume manual pass rights).
  void skipTurn({String reason = 'timeout'}) {
    if (_state.status != GameStatus.playing || _state.isRoundSummary) return;
    final currentUserId = _state.currentTurnUserId;
    final isPlayer1 = currentUserId == _state.playerOrder.first;
    if (isPlayer1) {
      _state.streakPlayer1 = 0;
    } else {
      _state.streakPlayer2 = 0;
    }
    if (currentUserId != null) {
      if (reason == 'wrong_answer') {
        _state.totalWrongByUser[currentUserId] =
            (_state.totalWrongByUser[currentUserId] ?? 0) + 1;
      }
      _state.moveHistory.add(
        GameMoveRecord(
          type: reason,
          byUserId: currentUserId,
          timestampMs: DateTime.now().millisecondsSinceEpoch,
          roundNumber: _state.roundNumber,
        ),
      );
    }
    _state.currentTurnIndex++;
    notifyListeners();
  }

  /// Manual pass action: each player has [GameState.maxPassesPerPlayer] (2) passes per round.
  /// Leaves all cells untouched, records the pass in [moveHistory], and passes the turn to opponent.
  ({bool valid, String? error}) passTurn({String? byUserId, int? nowMs}) {
    final userId = byUserId ?? _getLocalPlayerId();
    if (_state.status != GameStatus.playing || _state.isRoundSummary) {
      return (valid: false, error: 'GAME_NOT_PLAYING');
    }
    if (_state.currentTurnUserId != userId) {
      return (valid: false, error: 'NOT_YOUR_TURN');
    }
    if (_state.remainingPassesFor(userId) <= 0) {
      return (valid: false, error: 'NO_PASSES_LEFT');
    }

    _state.passesUsed[userId] = (_state.passesUsed[userId] ?? 0) + 1;
    _state.totalPassesByUser[userId] =
        (_state.totalPassesByUser[userId] ?? 0) + 1;
    final isPlayer1 = userId == _state.playerOrder.first;
    if (isPlayer1) {
      _state.streakPlayer1 = 0;
    } else {
      _state.streakPlayer2 = 0;
    }
    _state.moveHistory.add(
      GameMoveRecord(
        type: 'pass',
        byUserId: userId,
        timestampMs: nowMs ?? DateTime.now().millisecondsSinceEpoch,
        roundNumber: _state.roundNumber,
      ),
    );
    _state.currentTurnIndex++;
    notifyListeners();
    return (valid: true, error: null);
  }

  /// Sends a draw offer to the opponent.
  /// Rules:
  /// - Only 1 active offer at a time.
  /// - Offer expires after 30 seconds if unanswered.
  /// - Sender has a 60-second cooldown before offering again.
  ({bool valid, String? error}) offerDraw({String? byUserId, int? nowMs}) {
    final userId = byUserId ?? _getLocalPlayerId();
    final now = nowMs ?? DateTime.now().millisecondsSinceEpoch;

    if (_state.status != GameStatus.playing || _state.isRoundSummary) {
      return (valid: false, error: 'GAME_NOT_PLAYING');
    }
    if (!_state.playerOrder.contains(userId)) {
      return (valid: false, error: 'NOT_A_PLAYER');
    }

    // Expire stale offer first if 30s elapsed
    expireDrawOfferIfNeeded(nowMs: now);

    if (_state.hasActiveDrawOffer(now)) {
      return (valid: false, error: 'ACTIVE_OFFER_EXISTS');
    }
    if (_state.drawOfferCooldownSecondsFor(userId, now) > 0) {
      return (valid: false, error: 'DRAW_OFFER_COOLDOWN');
    }

    _state.drawOffer = GameDrawOffer(
      fromUserId: userId,
      createdAtMs: now,
      expiresAtMs: now + (GameState.drawOfferDurationSeconds * 1000),
      status: 'pending',
    );
    _state.lastDrawOfferAtByUser[userId] = now;
    _state.moveHistory.add(
      GameMoveRecord(
        type: 'draw_offer',
        byUserId: userId,
        timestampMs: now,
        roundNumber: _state.roundNumber,
      ),
    );
    notifyListeners();
    return (valid: true, error: null);
  }

  /// Opponent accepts or rejects the active draw offer.
  ({bool valid, String? error}) respondToDrawOffer({
    required bool accept,
    String? byUserId,
    int? nowMs,
  }) {
    final userId = byUserId ?? _getLocalPlayerId();
    final now = nowMs ?? DateTime.now().millisecondsSinceEpoch;

    if (_state.status != GameStatus.playing) {
      return (valid: false, error: 'GAME_NOT_PLAYING');
    }
    final offer = _state.drawOffer;
    if (offer == null || offer.status != 'pending') {
      return (valid: false, error: 'NO_ACTIVE_OFFER');
    }
    if (offer.fromUserId == userId) {
      return (valid: false, error: 'CANNOT_RESPOND_OWN_OFFER');
    }
    if (now >= offer.expiresAtMs) {
      _state.drawOffer = offer.copyWith(status: 'expired', respondedAtMs: now);
      _state.moveHistory.add(
        GameMoveRecord(
          type: 'draw_expired',
          byUserId: offer.fromUserId,
          timestampMs: now,
          roundNumber: _state.roundNumber,
        ),
      );
      notifyListeners();
      return (valid: false, error: 'DRAW_OFFER_EXPIRED');
    }

    if (accept) {
      _state.drawOffer = offer.copyWith(status: 'accepted', respondedAtMs: now);
      _state.status = GameStatus.draw;
      _state.isRoundSummary = false;
      _state.winnerUserId = null;
      _state.endedByDrawOffer = true;
      _state.moveHistory.add(
        GameMoveRecord(
          type: 'draw_accepted',
          byUserId: userId,
          timestampMs: now,
          roundNumber: _state.roundNumber,
        ),
      );
    } else {
      _state.drawOffer = offer.copyWith(status: 'rejected', respondedAtMs: now);
      _state.moveHistory.add(
        GameMoveRecord(
          type: 'draw_rejected',
          byUserId: userId,
          timestampMs: now,
          roundNumber: _state.roundNumber,
        ),
      );
    }
    notifyListeners();
    return (valid: true, error: null);
  }

  /// Automatically marks an unanswered draw offer as expired once 30 seconds have passed.
  bool expireDrawOfferIfNeeded({int? nowMs}) {
    final now = nowMs ?? DateTime.now().millisecondsSinceEpoch;
    final offer = _state.drawOffer;
    if (offer != null &&
        offer.status == 'pending' &&
        now >= offer.expiresAtMs) {
      _state.drawOffer = offer.copyWith(status: 'expired', respondedAtMs: now);
      _state.moveHistory.add(
        GameMoveRecord(
          type: 'draw_expired',
          byUserId: offer.fromUserId,
          timestampMs: now,
          roundNumber: _state.roundNumber,
        ),
      );
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Submits a player for [cellIndex].
  /// Player reuse IS ALLOWED across different cells (both by the same player and by the opponent).
  /// Each cell is evaluated independently against its row and column club criteria.
  Future<({bool valid, String? error})> submitAnswer({
    required int cellIndex,
    required String playerId,
    Player? player,
    String? byUserId,
    int? nowMs,
  }) async {
    final userId = byUserId ?? _getLocalPlayerId();
    if (_state.status != GameStatus.playing || _state.isRoundSummary) {
      return (valid: false, error: 'GAME_NOT_PLAYING');
    }
    if (_state.currentTurnUserId != userId) {
      return (valid: false, error: 'NOT_YOUR_TURN');
    }
    if (cellIndex < 0 || cellIndex > 8) {
      return (valid: false, error: 'INVALID_CELL');
    }
    if (_state.isCellFilled(cellIndex)) {
      return (valid: false, error: 'CELL_ALREADY_FILLED');
    }
    if (playerId.trim().isEmpty) {
      return (valid: false, error: 'INVALID_PLAYER');
    }

    final cell = _state.cells[cellIndex];
    final valid = await answerValidator.isPlayerInTeamPair(
      playerId,
      cell.rowTeam.id,
      cell.colTeam.id,
    );
    if (!valid) {
      _state.totalWrongByUser[userId] =
          (_state.totalWrongByUser[userId] ?? 0) + 1;
      return (valid: false, error: 'INVALID_PLAYER');
    }

    final isPlayer1 = userId == _state.playerOrder.first;
    final cellOwner = isPlayer1 ? 0 : 1;
    final newCell =
        GameCell(
            row: cell.row,
            col: cell.col,
            rowTeam: cell.rowTeam,
            colTeam: cell.colTeam,
          )
          ..selectedPlayer = player
          ..selectedByUserId = userId
          ..mark = cellOwner == 0 ? GameMark.x : GameMark.o;
    _state.cells[cellIndex] = newCell;

    final candidatePlayers = await answerValidator.getPlayersForTeamPair(
      cell.rowTeam.id,
      cell.colTeam.id,
    );
    final streak = isPlayer1 ? _state.streakPlayer1 : _state.streakPlayer2;
    final points = scoreCalculator.calculateCorrectAnswer(
      streak: streak,
      candidatePoolSize: candidatePlayers.length,
    );
    _state.scores[userId] = (_state.scores[userId] ?? 0) + points;
    _state.totalCorrectByUser[userId] =
        (_state.totalCorrectByUser[userId] ?? 0) + 1;

    _state.usedPlayerIds.add(playerId);
    _state.moveHistory.add(
      GameMoveRecord(
        type: 'move',
        byUserId: userId,
        cellIndex: cellIndex,
        playerId: playerId,
        playerName: player?.name,
        timestampMs: nowMs ?? DateTime.now().millisecondsSinceEpoch,
        roundNumber: _state.roundNumber,
      ),
    );

    final winResult = _checkWinner();
    if (winResult.winner != null) {
      final roundWinner = winResult.winner!;
      _state.winningLine = winResult.line;
      _state.lastRoundWinnerId = roundWinner;
      _state.roundWins[roundWinner] = (_state.roundWins[roundWinner] ?? 0) + 1;

      if (_state.roundWins[roundWinner]! >= _state.roundsToWin) {
        _state.status = GameStatus.won;
        _state.winnerUserId = roundWinner;
        _state.isRoundSummary = false;
      } else {
        _state.isRoundSummary = true;
      }
    } else if (_state.cells.every((c) => c.mark != GameMark.none)) {
      _state.lastRoundWinnerId = 'draw';
      if (_state.totalRounds <= 1) {
        _state.status = GameStatus.draw;
        _state.isRoundSummary = false;
      } else {
        // In multi-round series, a board-full draw triggers inter-round summary and advances to next round
        _state.isRoundSummary = true;
      }
    } else {
      if (isPlayer1) {
        _state.streakPlayer1 = streak + 1;
        _state.streakPlayer2 = 0;
      } else {
        _state.streakPlayer2 = streak + 1;
        _state.streakPlayer1 = 0;
      }
      _state.currentTurnIndex++;
    }
    notifyListeners();
    return (valid: true, error: null);
  }

  ({String? winner, GameMark? mark, List<int> line}) _checkWinner() {
    const lines = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];
    for (final line in lines) {
      final a = _state.cells[line[0]];
      final b = _state.cells[line[1]];
      final c = _state.cells[line[2]];
      if (a.mark != GameMark.none && a.mark == b.mark && b.mark == c.mark) {
        return (winner: a.selectedByUserId, mark: a.mark, line: line);
      }
    }
    return (winner: null, mark: null, line: const []);
  }
}

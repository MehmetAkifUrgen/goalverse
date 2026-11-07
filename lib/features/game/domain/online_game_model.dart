class OnlineCell {
  final int cellIndex;
  final String playerId;
  final String playerName;
  final String byUserId;
  final String mark; // 'X' or 'O'

  OnlineCell({
    required this.cellIndex,
    required this.playerId,
    required this.playerName,
    required this.byUserId,
    required this.mark,
  });

  factory OnlineCell.fromMap(Map<String, dynamic> map) {
    return OnlineCell(
      cellIndex: map['cellIndex'] as int? ?? 0,
      playerId: map['playerId'] as String? ?? '',
      playerName: map['playerName'] as String? ?? '',
      byUserId: map['byUserId'] as String? ?? '',
      mark: map['mark'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cellIndex': cellIndex,
      'playerId': playerId,
      'playerName': playerName,
      'byUserId': byUserId,
      'mark': mark,
    };
  }
}

class OnlineMoveRecord {
  final String
  type; // 'move', 'pass', 'timeout', 'draw_offer', 'draw_accepted', 'draw_rejected', 'draw_expired'
  final String byUserId;
  final String? byUserName;
  final int? cellIndex;
  final String? playerId;
  final String? playerName;
  final int timestampMs;
  final int roundNumber;

  const OnlineMoveRecord({
    required this.type,
    required this.byUserId,
    this.byUserName,
    this.cellIndex,
    this.playerId,
    this.playerName,
    required this.timestampMs,
    this.roundNumber = 1,
  });

  factory OnlineMoveRecord.fromMap(Map<String, dynamic> map) {
    return OnlineMoveRecord(
      type: map['type'] as String? ?? 'move',
      byUserId: map['byUserId'] as String? ?? '',
      byUserName: map['byUserName'] as String?,
      cellIndex: (map['cellIndex'] as num?)?.toInt(),
      playerId: map['playerId'] as String?,
      playerName: map['playerName'] as String?,
      timestampMs: (map['timestampMs'] as num?)?.toInt() ?? 0,
      roundNumber: (map['roundNumber'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'byUserId': byUserId,
      if (byUserName != null) 'byUserName': byUserName,
      if (cellIndex != null) 'cellIndex': cellIndex,
      if (playerId != null) 'playerId': playerId,
      if (playerName != null) 'playerName': playerName,
      'timestampMs': timestampMs,
      'roundNumber': roundNumber,
    };
  }
}

class OnlineDrawOffer {
  final String fromUserId;
  final String fromUserName;
  final int createdAtMs;
  final int expiresAtMs;
  final String status; // 'pending', 'accepted', 'rejected', 'expired'
  final int? respondedAtMs;

  const OnlineDrawOffer({
    required this.fromUserId,
    required this.fromUserName,
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

  factory OnlineDrawOffer.fromMap(Map<String, dynamic> map) {
    return OnlineDrawOffer(
      fromUserId: map['fromUserId'] as String? ?? '',
      fromUserName: map['fromUserName'] as String? ?? 'Oyuncu',
      createdAtMs: (map['createdAtMs'] as num?)?.toInt() ?? 0,
      expiresAtMs: (map['expiresAtMs'] as num?)?.toInt() ?? 0,
      status: map['status'] as String? ?? 'pending',
      respondedAtMs: (map['respondedAtMs'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fromUserId': fromUserId,
      'fromUserName': fromUserName,
      'createdAtMs': createdAtMs,
      'expiresAtMs': expiresAtMs,
      'status': status,
      if (respondedAtMs != null) 'respondedAtMs': respondedAtMs,
    };
  }
}

class OnlineTeam {
  final String id;
  final String name;
  final String? country;
  final String? colorHex;
  final String? logoUrl;

  OnlineTeam({
    required this.id,
    required this.name,
    this.country,
    this.colorHex,
    this.logoUrl,
  });

  factory OnlineTeam.fromMap(Map<String, dynamic> map) {
    final id = map['id'] as String? ?? '';
    final numId = id.replaceAll('team_', '');
    final logo =
        map['logoUrl'] as String? ??
        (numId.isNotEmpty
            ? 'https://tmssl.akamaized.net/images/wappen/head/$numId.png'
            : null);

    return OnlineTeam(
      id: id,
      name: map['name'] as String? ?? '',
      country: map['country'] as String?,
      colorHex: map['colorHex'] as String?,
      logoUrl: logo,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'country': country,
      'colorHex': colorHex,
      'logoUrl': logoUrl,
    };
  }
}

class OnlineRoundBoard {
  final String boardId;
  final int boardVersion;
  final List<OnlineTeam> rowTeams;
  final List<OnlineTeam> colTeams;

  const OnlineRoundBoard({
    required this.boardId,
    required this.boardVersion,
    required this.rowTeams,
    required this.colTeams,
  });

  factory OnlineRoundBoard.fromMap(Map<String, dynamic> map) {
    final rows = (map['rowTeams'] as List? ?? [])
        .whereType<Map>()
        .map((e) => OnlineTeam.fromMap(Map<String, dynamic>.from(e)))
        .toList();
    final cols = (map['colTeams'] as List? ?? [])
        .whereType<Map>()
        .map((e) => OnlineTeam.fromMap(Map<String, dynamic>.from(e)))
        .toList();
    return OnlineRoundBoard(
      boardId: map['boardId'] as String? ?? 'board_r1',
      boardVersion: (map['boardVersion'] as num?)?.toInt() ?? 1,
      rowTeams: rows,
      colTeams: cols,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'boardId': boardId,
      'boardVersion': boardVersion,
      'rowTeams': rowTeams.map((t) => t.toMap()).toList(),
      'colTeams': colTeams.map((t) => t.toMap()).toList(),
    };
  }
}

class OnlineGameModeInfo {
  final String id;
  final String title;
  final String subtitle;
  final String routePath;

  const OnlineGameModeInfo({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.routePath,
  });

  static const List<OnlineGameModeInfo> allModes = [
    OnlineGameModeInfo(
      id: 'sos',
      title: 'Football SOS (3x3)',
      subtitle: 'Sıra tabanlı 3x3 kulüp kesişim tablosu',
      routePath: '/online-game',
    ),
    OnlineGameModeInfo(
      id: 'rating_battle',
      title: 'Rating Battle',
      subtitle: 'EA FC Overall & piyasa değeri kapışması',
      routePath: '/rating-battle',
    ),
    OnlineGameModeInfo(
      id: 'two_teams',
      title: '2 Takım 1 Oyuncu',
      subtitle: 'İki kulüpte de oynamış ortak yıldızı bul',
      routePath: '/two-teams',
    ),
    OnlineGameModeInfo(
      id: 'who_am_i',
      title: 'Ben Kimim?',
      subtitle: '5 ipucuyla gizemli futbolcuyu daha hızlı bil',
      routePath: '/who-am-i',
    ),
    OnlineGameModeInfo(
      id: 'imposter',
      title: 'Imposter (Ajan Kim?)',
      subtitle: 'Kulüpte oynamamış sahte futbolcuyu yakala',
      routePath: '/imposter',
    ),
    OnlineGameModeInfo(
      id: 'transfer_path',
      title: 'Transfer Yolu',
      subtitle: 'Kronolojik kariyer geçmişinden oyuncuyu bul',
      routePath: '/transfer-path',
    ),
    OnlineGameModeInfo(
      id: 'football_bomb',
      title: 'Futbol Bombası 💣',
      subtitle: 'Bomba patlamadan kulüpten oyuncu söyle',
      routePath: '/football-bomb',
    ),
  ];

  static OnlineGameModeInfo fromId(String id) {
    return allModes.firstWhere((m) => m.id == id, orElse: () => allModes.first);
  }
}

class OnlineGame {
  static const int maxPassesPerPlayer = 2;
  static const int drawOfferDurationSeconds = 30;
  static const int drawOfferCooldownSeconds = 60;

  final String id;
  final String roomCode;
  final String gameMode;
  final bool isPublic;
  final int seed;
  final String boardId;
  final int boardVersion;
  final int roundNumber;
  final int totalRounds;
  final int roundsToWin;
  final int player1RoundWins;
  final int player2RoundWins;
  final String roundStatus; // 'playing', 'round_summary', 'finished'
  final String? lastRoundWinnerId; // userId or 'draw'
  final List<OnlineRoundBoard> roundBoards;
  final String player1Id;
  final String player1Name;
  final String? player2Id;
  final String? player2Name;
  final int player1Score;
  final int player2Score;
  final int player1Round;
  final int player2Round;
  final bool player1Finished;
  final bool player2Finished;
  final String status; // 'waiting', 'playing', 'finished'
  final String currentTurn; // userId
  final String? winnerId; // null, 'draw', userId
  final List<OnlineTeam> rowTeams;
  final List<OnlineTeam> colTeams;
  final List<OnlineCell?> board;
  final List<String> usedPlayerIds;
  final Map<String, int> passesUsed;
  final Map<String, int> totalPassesByUser;
  final Map<String, int> totalCorrectByUser;
  final Map<String, int> totalWrongByUser;
  final List<OnlineMoveRecord> moveHistory;
  final OnlineDrawOffer? drawOffer;
  final Map<String, int> lastDrawOfferAtByUser;
  final int turnDurationSeconds;
  final int lastMoveTimestamp;
  final int matchStartedAtMs;
  final String? feedbackMessage;

  OnlineGame({
    required this.id,
    required this.roomCode,
    this.gameMode = 'sos',
    this.isPublic = false,
    this.seed = 42,
    this.boardId = 'board_r1',
    this.boardVersion = 1,
    this.roundNumber = 1,
    this.totalRounds = 3,
    int? roundsToWin,
    this.player1RoundWins = 0,
    this.player2RoundWins = 0,
    this.roundStatus = 'playing',
    this.lastRoundWinnerId,
    this.roundBoards = const [],
    required this.player1Id,
    required this.player1Name,
    this.player2Id,
    this.player2Name,
    this.player1Score = 0,
    this.player2Score = 0,
    this.player1Round = 1,
    this.player2Round = 1,
    this.player1Finished = false,
    this.player2Finished = false,
    required this.status,
    required this.currentTurn,
    this.winnerId,
    required this.rowTeams,
    required this.colTeams,
    required this.board,
    required this.usedPlayerIds,
    this.passesUsed = const {},
    this.totalPassesByUser = const {},
    this.totalCorrectByUser = const {},
    this.totalWrongByUser = const {},
    this.moveHistory = const [],
    this.drawOffer,
    this.lastDrawOfferAtByUser = const {},
    this.turnDurationSeconds = 30,
    this.lastMoveTimestamp = 0,
    this.matchStartedAtMs = 0,
    this.feedbackMessage,
  }) : roundsToWin = roundsToWin ?? ((totalRounds ~/ 2) + 1);

  // Canonical field aliases requested in the specification
  String get matchId => id;
  List<OnlineTeam> get rowCriteria => rowTeams;
  List<OnlineTeam> get columnCriteria => colTeams;
  String get currentPlayerId => currentTurn;
  List<OnlineCell?> get boardState => board;
  String get matchStatus => status;

  bool get isPlaying => status == 'playing';
  bool get isWaiting => status == 'waiting';
  bool get isFinished => status == 'finished';
  bool get isRoundSummary =>
      status == 'playing' && roundStatus == 'round_summary';

  int roundWinsFor(String userId) {
    if (userId == player1Id) return player1RoundWins;
    if (userId == player2Id) return player2RoundWins;
    return 0;
  }

  int remainingPassesFor(String userId) {
    final used = passesUsed[userId] ?? 0;
    return (maxPassesPerPlayer - used).clamp(0, maxPassesPerPlayer);
  }

  bool canPass(String userId) {
    return isPlaying &&
        !isRoundSummary &&
        currentTurn == userId &&
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
    return isPlaying &&
        !isRoundSummary &&
        !hasActiveDrawOffer(now) &&
        drawOfferCooldownSecondsFor(userId, now) == 0;
  }

  int matchDurationSeconds([int? nowMs]) {
    final now = nowMs ?? DateTime.now().millisecondsSinceEpoch;
    final base = matchStartedAtMs > 0 ? matchStartedAtMs : lastMoveTimestamp;
    if (base <= 0) return 0;
    return ((now - base) / 1000).round().clamp(1, 86400);
  }

  static Map<String, int> _parseIntMap(dynamic raw) {
    if (raw is! Map) return {};
    final result = <String, int>{};
    for (final entry in raw.entries) {
      result[entry.key.toString()] = (entry.value as num?)?.toInt() ?? 0;
    }
    return result;
  }

  factory OnlineGame.fromFirestore(String id, Map<String, dynamic> data) {
    final rows = (data['rowTeams'] as List? ?? [])
        .map((e) => OnlineTeam.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
    final cols = (data['colTeams'] as List? ?? [])
        .map((e) => OnlineTeam.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();

    final boardRaw = data['board'] as List? ?? List.filled(9, null);
    final board = List<OnlineCell?>.generate(9, (index) {
      if (index < boardRaw.length && boardRaw[index] != null) {
        return OnlineCell.fromMap(
          Map<String, dynamic>.from(boardRaw[index] as Map),
        );
      }
      return null;
    });

    final used = (data['usedPlayerIds'] as List? ?? [])
        .map((e) => e.toString())
        .toList();

    final passesUsed = _parseIntMap(data['passesUsed']);
    final totalPassesByUser = _parseIntMap(data['totalPassesByUser']);
    final totalCorrectByUser = _parseIntMap(data['totalCorrectByUser']);
    final totalWrongByUser = _parseIntMap(data['totalWrongByUser']);
    final lastDrawOfferAtByUser = _parseIntMap(data['lastDrawOfferAtByUser']);

    final historyRaw = data['moveHistory'] as List? ?? [];
    final moveHistory = historyRaw
        .whereType<Map>()
        .map((e) => OnlineMoveRecord.fromMap(Map<String, dynamic>.from(e)))
        .toList();

    final drawOfferRaw = data['drawOffer'];
    final drawOffer = drawOfferRaw is Map
        ? OnlineDrawOffer.fromMap(Map<String, dynamic>.from(drawOfferRaw))
        : null;

    final roundBoardsRaw = data['roundBoards'] as List? ?? [];
    final roundBoards = roundBoardsRaw
        .whereType<Map>()
        .map((e) => OnlineRoundBoard.fromMap(Map<String, dynamic>.from(e)))
        .toList();

    final totalRounds = (data['totalRounds'] as num?)?.toInt() ?? 3;
    final roundsToWin =
        (data['roundsToWin'] as num?)?.toInt() ?? ((totalRounds ~/ 2) + 1);

    return OnlineGame(
      id: id,
      roomCode: data['roomCode'] as String? ?? '',
      gameMode: data['gameMode'] as String? ?? 'sos',
      isPublic: data['isPublic'] as bool? ?? false,
      seed: (data['seed'] as num?)?.toInt() ?? 42,
      boardId: data['boardId'] as String? ?? 'board_r1',
      boardVersion: (data['boardVersion'] as num?)?.toInt() ?? 1,
      roundNumber: (data['roundNumber'] as num?)?.toInt() ?? 1,
      totalRounds: totalRounds,
      roundsToWin: roundsToWin,
      player1RoundWins: (data['player1RoundWins'] as num?)?.toInt() ?? 0,
      player2RoundWins: (data['player2RoundWins'] as num?)?.toInt() ?? 0,
      roundStatus: data['roundStatus'] as String? ?? 'playing',
      lastRoundWinnerId: data['lastRoundWinnerId'] as String?,
      roundBoards: roundBoards,
      player1Id: data['player1Id'] as String? ?? '',
      player1Name: data['player1Name'] as String? ?? 'Oyuncu 1',
      player2Id: data['player2Id'] as String?,
      player2Name: data['player2Name'] as String?,
      player1Score: (data['player1Score'] as num?)?.toInt() ?? 0,
      player2Score: (data['player2Score'] as num?)?.toInt() ?? 0,
      player1Round: (data['player1Round'] as num?)?.toInt() ?? 1,
      player2Round: (data['player2Round'] as num?)?.toInt() ?? 1,
      player1Finished: data['player1Finished'] as bool? ?? false,
      player2Finished: data['player2Finished'] as bool? ?? false,
      status: data['status'] as String? ?? 'waiting',
      currentTurn: data['currentTurn'] as String? ?? '',
      winnerId: data['winnerId'] as String?,
      rowTeams: rows,
      colTeams: cols,
      board: board,
      usedPlayerIds: used,
      passesUsed: passesUsed,
      totalPassesByUser: totalPassesByUser,
      totalCorrectByUser: totalCorrectByUser,
      totalWrongByUser: totalWrongByUser,
      moveHistory: moveHistory,
      drawOffer: drawOffer,
      lastDrawOfferAtByUser: lastDrawOfferAtByUser,
      turnDurationSeconds: (data['turnDurationSeconds'] as num?)?.toInt() ?? 30,
      lastMoveTimestamp: (data['lastMoveTimestamp'] as num?)?.toInt() ?? 0,
      matchStartedAtMs: (data['matchStartedAtMs'] as num?)?.toInt() ?? 0,
      feedbackMessage: data['feedbackMessage'] as String?,
    );
  }

  static String? checkWinner(List<OnlineCell?> board) {
    const lines = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // rows
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // cols
      [0, 4, 8], [2, 4, 6], // diags
    ];

    for (final line in lines) {
      final a = board[line[0]];
      final b = board[line[1]];
      final c = board[line[2]];
      if (a != null && b != null && c != null) {
        if (a.mark == b.mark && b.mark == c.mark) {
          return a.byUserId;
        }
      }
    }

    if (board.every((cell) => cell != null)) {
      return 'draw';
    }

    return null;
  }
}

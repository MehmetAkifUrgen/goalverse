import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/monetization/ad_service.dart';
import '../../../core/providers.dart';
import '../../../core/providers/settings_and_stats_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/stadium_visuals.dart';
import '../../../data/models/freezed/entity_models.dart';
import '../engine/board_generator.dart';
import '../engine/game_engine.dart';
import '../engine/game_timer.dart';
import '../engine/score_calculator.dart';
import 'online_lobby_dialog.dart';
import 'player_search_bottom_sheet.dart';

class GamePage extends ConsumerStatefulWidget {
  final String matchId;
  final int initialTotalRounds;

  const GamePage({
    super.key,
    required this.matchId,
    this.initialTotalRounds = 3,
  });

  @override
  ConsumerState<GamePage> createState() => _GamePageState();
}

class _GamePageState extends ConsumerState<GamePage> {
  GameEngine? _engine;
  GameTimer? _timer;
  Timer? _uiClockTimer;
  StreamSubscription<int>? _timerSub;
  StreamSubscription<void>? _timerExpiredSub;
  List<GeneratedBoard> _roundBoards = const [];
  late int _selectedTotalRounds;
  int _totalTurnSeconds = AppConstants.defaultTimerSeconds;
  int _remaining = AppConstants.defaultTimerSeconds;
  int _nowMs = DateTime.now().millisecondsSinceEpoch;
  int? _selectedCellIndex;
  bool _loading = true;
  String? _error;
  String? _statusMessage;
  Color? _statusColor;
  bool _aiThinking = false;
  bool _gameOverDialogShown = false;
  bool _wasTrailing = false;
  bool _unlockedRareThisMatch = false;

  late bool _isVsAi;

  @override
  void initState() {
    super.initState();
    _isVsAi = widget.matchId == 'solo-ai';
    _selectedTotalRounds =
        (widget.initialTotalRounds == 5 || widget.initialTotalRounds == 1)
        ? widget.initialTotalRounds
        : 3;
    _uiClockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now().millisecondsSinceEpoch;
      final expired = _engine?.expireDrawOfferIfNeeded(nowMs: now) ?? false;
      if (mounted) {
        setState(() {
          _nowMs = now;
          if (expired) {
            final l10n = AppLocalizations.of(context);
            if (l10n != null) {
              _statusMessage = '⌛ ${l10n.drawOfferExpiredMessage}';
              _statusColor = AppColors.trophyGold;
            }
          }
        });
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  @override
  void dispose() {
    _uiClockTimer?.cancel();
    _timerSub?.cancel();
    _timerExpiredSub?.cancel();
    _timer?.dispose();
    _engine?.removeListener(_onEngineChanged);
    _engine?.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    _timerSub?.cancel();
    _timerExpiredSub?.cancel();
    _timer?.dispose();
    _engine?.removeListener(_onEngineChanged);

    final settings = ref.read(appSettingsProvider);
    final turnSec = settings.turnSeconds;
    final boardDiff = switch (settings.difficulty) {
      'easy' => Difficulty.easy,
      'hard' => Difficulty.hard,
      _ => Difficulty.medium,
    };

    setState(() {
      _loading = true;
      _error = null;
      _statusMessage = null;
      _aiThinking = false;
      _gameOverDialogShown = false;
      _wasTrailing = false;
      _unlockedRareThisMatch = false;
      _selectedCellIndex = null;
      _totalTurnSeconds = turnSec;
      _remaining = turnSec;
      _nowMs = DateTime.now().millisecondsSinceEpoch;
    });

    final isarAsync = ref.read(isarDatabaseProvider.future);
    try {
      await isarAsync;
      final teamRepo = ref.read(teamRepositoryProvider);
      final answerValidator = ref.read(answerValidatorRepositoryProvider);
      final generator = BoardGenerator(
        teamRepository: teamRepo,
        answerValidator: answerValidator,
      );
      final boards = await generator.generateMultipleBoards(
        count: max(_selectedTotalRounds + 3, 6),
        difficulty: boardDiff,
      );
      _roundBoards = boards;
      final board = boards.first;
      const localUserId = 'local-player-1';
      const opponentId = 'local-player-2';
      final engine = GameEngine(
        board: board,
        answerValidator: answerValidator,
        scoreCalculator: ScoreCalculator(),
        participantUserIds: const [localUserId, opponentId],
        localPlayerId: localUserId,
        totalRounds: _selectedTotalRounds,
        roundsToWin: (_selectedTotalRounds ~/ 2) + 1,
      );
      engine.addListener(_onEngineChanged);
      engine.startGame();

      final timer = GameTimer(totalSeconds: turnSec);
      _timerSub = timer.tickStream.listen((sec) {
        if (mounted) setState(() => _remaining = sec);
      });
      _timerExpiredSub = timer.expiredStream.listen((_) {
        if (mounted &&
            _engine?.state.status == GameStatus.playing &&
            !(_engine?.state.isRoundSummary ?? false)) {
          ref.read(appSettingsProvider.notifier).triggerErrorHaptic();
          _engine?.skipTurn(reason: 'timeout');
          setState(() {
            _statusMessage =
                AppLocalizations.of(context)?.timeExpiredTurnPasses ??
                '⏰ Süre doldu! Sıra rakibe geçti.';
            _statusColor = AppColors.trophyGold;
          });
          _timer?.reset();
          _timer?.start();
          _checkAndTriggerAiTurn();
        }
      });
      timer.start();

      setState(() {
        _engine = engine;
        _timer = timer;
        _loading = false;
      });
    } catch (e, st) {
      debugPrint('Game init error: $e\n$st');
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _startNextRound() async {
    final engine = _engine;
    if (engine == null || !engine.state.isRoundSummary) return;

    final nextRoundIdx = engine.state.roundNumber; // 0-based index for round+1
    GeneratedBoard nextBoard;
    if (nextRoundIdx < _roundBoards.length) {
      nextBoard = _roundBoards[nextRoundIdx];
    } else {
      final teamRepo = ref.read(teamRepositoryProvider);
      final answerValidator = ref.read(answerValidatorRepositoryProvider);
      final generator = BoardGenerator(
        teamRepository: teamRepo,
        answerValidator: answerValidator,
      );
      nextBoard = await generator.generate(
        roundNumber: engine.state.roundNumber + 1,
      );
    }

    if (!mounted) return;
    engine.startNextRound(nextBoard);
    setState(() {
      _statusMessage =
          AppLocalizations.of(context)?.roundStartedClubsReady(
            engine.state.roundNumber,
          ) ??
          '⚽ Tur ${engine.state.roundNumber} başladı! Yeni kulüp tahtası hazır.';
      _statusColor = AppColors.electricLime;
    });
    _timer?.reset();
    _timer?.start();
    _checkAndTriggerAiTurn();
  }

  void _onEngineChanged() {
    if (!mounted) return;
    setState(() {});
    final engine = _engine;
    if (engine == null) return;
    final state = engine.state;

    if (state.isRoundSummary) {
      _timer?.stop();
      return;
    }

    final p1Marks = state.cells.where((c) => c.mark == GameMark.x).length;
    final p2Marks = state.cells.where((c) => c.mark == GameMark.o).length;
    if (p2Marks > p1Marks) {
      _wasTrailing = true;
    }

    if ((state.status == GameStatus.won || state.status == GameStatus.draw) &&
        !_gameOverDialogShown) {
      _gameOverDialogShown = true;
      _timer?.stop();
      final isWin =
          state.status == GameStatus.won &&
          state.winnerUserId == 'local-player-1';
      final isDraw = state.status == GameStatus.draw;

      final mult = ref.read(appSettingsProvider).scoreMultiplier;
      final rawScore = state.scores['local-player-1'] ?? 0;
      final finalScore = (rawScore * mult).round();
      final totalPassesUsed = state.totalPassesByUser['local-player-1'] ?? 0;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        // ELO & Career Stats are updated ONCE at the end of the series
        ref
            .read(userStatsProvider.notifier)
            .recordGameResult(
              won: isWin,
              draw: isDraw,
              score: finalScore,
              isRare: _unlockedRareThisMatch,
              isComeback: isWin && _wasTrailing,
              passesUsed: totalPassesUsed,
              endedByDrawOffer: state.endedByDrawOffer,
            );
        _showGameOverDialog(state, finalScore);
        unawaited(
          ref
              .read(adServiceProvider.notifier)
              .onMatchCompletedAndMaybeShowInterstitial(),
        );
      });
    }
  }

  int _selectStrategicAiCell(
    GameState state,
    Set<int> playableIndices,
    String difficulty,
  ) {
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
    final rng = Random();

    // Easy mode: 65% random move, 35% tactical
    if (difficulty == 'easy' && rng.nextDouble() < 0.65) {
      final list = playableIndices.toList()..shuffle(rng);
      return list.first;
    }

    // 1. Check if AI (GameMark.o) can win in 1 move
    for (final line in lines) {
      final oCount = line
          .where((idx) => state.cells[idx].mark == GameMark.o)
          .length;
      final emptyInLine = line
          .where((idx) => playableIndices.contains(idx))
          .toList();
      if (oCount == 2 && emptyInLine.length == 1) {
        return emptyInLine.first;
      }
    }

    // 2. Check if Player (GameMark.x) is about to win and BLOCK them
    final shouldBlock = difficulty == 'hard' || rng.nextDouble() < 0.80;
    if (shouldBlock) {
      for (final line in lines) {
        final xCount = line
            .where((idx) => state.cells[idx].mark == GameMark.x)
            .length;
        final emptyInLine = line
            .where((idx) => playableIndices.contains(idx))
            .toList();
        if (xCount == 2 && emptyInLine.length == 1) {
          return emptyInLine.first;
        }
      }
    }

    // 3. Strategic positional priority: Center (4) -> Corners (0,2,6,8) -> Edges
    if (playableIndices.contains(4)) return 4;
    final corners = [0, 2, 6, 8].where(playableIndices.contains).toList();
    if (corners.isNotEmpty) {
      corners.shuffle(rng);
      return corners.first;
    }

    final list = playableIndices.toList()..shuffle(rng);
    return list.first;
  }

  Future<void> _checkAndTriggerAiTurn() async {
    final engine = _engine;
    if (!_isVsAi || engine == null) return;
    if (engine.state.status != GameStatus.playing ||
        engine.state.isRoundSummary) {
      return;
    }
    if (engine.state.currentTurnUserId != 'local-player-2') return;
    if (_aiThinking) return;

    setState(() => _aiThinking = true);
    await Future.delayed(const Duration(milliseconds: 850));
    if (!mounted ||
        engine.state.status != GameStatus.playing ||
        engine.state.isRoundSummary) {
      return;
    }

    final validator = ref.read(answerValidatorRepositoryProvider);
    final playerRepo = ref.read(playerRepositoryProvider);
    final difficulty = ref.read(appSettingsProvider).difficulty;

    // Find all empty cells that have at least 1 valid player (player reuse is allowed across cells)
    final cellToCandidateIds = <int, List<String>>{};
    for (int i = 0; i < 9; i++) {
      if (!engine.state.isCellFilled(i)) {
        final cell = engine.state.cells[i];
        final candidateIds = await validator.getPlayersForTeamPair(
          cell.rowTeam.id,
          cell.colTeam.id,
        );
        if (candidateIds.isNotEmpty) {
          cellToCandidateIds[i] = List<String>.from(candidateIds);
        }
      }
    }

    bool moved = false;
    String? aiPickedName;
    if (cellToCandidateIds.isNotEmpty) {
      final chosenCellIdx = _selectStrategicAiCell(
        engine.state,
        cellToCandidateIds.keys.toSet(),
        difficulty,
      );
      final candidateIds = cellToCandidateIds[chosenCellIdx]!..shuffle();
      final chosenId = candidateIds.first;
      final chosenPlayer = await playerRepo.getById(chosenId);
      aiPickedName = chosenPlayer?.name;
      await engine.submitAnswer(
        cellIndex: chosenCellIdx,
        playerId: chosenId,
        player: chosenPlayer,
        byUserId: 'local-player-2',
      );
      moved = true;
    }

    if (!moved) {
      if (engine.state.canPass('local-player-2')) {
        engine.passTurn(byUserId: 'local-player-2');
      } else {
        engine.skipTurn(reason: 'pass');
      }
    }

    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    setState(() {
      _aiThinking = false;
      _statusMessage = moved
          ? (l10n != null
                ? l10n.botMadeMove(aiPickedName ?? '')
                : '🤖 Bot hamlesini yaptı: ${aiPickedName ?? ''}')
          : (l10n?.botPassedTurn ?? '🤖 Bot sırasını pas geçti.');
      _statusColor = AppColors.skyBlue;
    });
    if (engine.state.status == GameStatus.playing &&
        !engine.state.isRoundSummary) {
      _timer?.reset();
      _timer?.start();
    }
  }

  void _onPassTurn() {
    final engine = _engine;
    if (engine == null || _aiThinking || engine.state.isRoundSummary) return;
    final l10n = AppLocalizations.of(context)!;
    final activeUserId = engine.state.currentTurnUserId ?? 'local-player-1';
    if (_isVsAi && activeUserId != 'local-player-1') return;

    final res = engine.passTurn(byUserId: activeUserId);
    if (!res.valid) {
      ref.read(appSettingsProvider.notifier).triggerErrorHaptic();
      final msg = switch (res.error) {
        'NO_PASSES_LEFT' => l10n.noPassesLeft,
        'NOT_YOUR_TURN' => l10n.errorNotYourTurn,
        _ => res.error ?? l10n.errorUnknown,
      };
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: AppColors.coralRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final actorLabel = activeUserId == 'local-player-1'
        ? (_isVsAi ? 'Sen' : 'Oyuncu 1')
        : (_isVsAi ? 'Bot' : 'Oyuncu 2');
    setState(() {
      _statusMessage = '⏭️ ${l10n.playerPassedTurn(actorLabel)}';
      _statusColor = AppColors.trophyGold;
    });
    _timer?.reset();
    _timer?.start();
    _checkAndTriggerAiTurn();
  }

  void _onOfferDraw() {
    final engine = _engine;
    if (engine == null || _aiThinking || engine.state.isRoundSummary) return;
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now().millisecondsSinceEpoch;
    final senderId = _isVsAi
        ? 'local-player-1'
        : (engine.state.currentTurnUserId ?? 'local-player-1');

    final cooldownSec = engine.state.drawOfferCooldownSecondsFor(senderId, now);
    if (cooldownSec > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.drawOfferCooldownMessage(cooldownSec)),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final res = engine.offerDraw(byUserId: senderId, nowMs: now);
    if (!res.valid) return;

    setState(() {
      _nowMs = now;
      _statusMessage = '🤝 ${l10n.offerDraw}';
      _statusColor = AppColors.trophyGold;
    });
  }

  void _onRespondToDrawOffer(bool accept) {
    final engine = _engine;
    if (engine == null) return;
    final l10n = AppLocalizations.of(context)!;
    final offer = engine.state.drawOffer;
    if (offer == null) return;

    final responderId = offer.fromUserId == 'local-player-1'
        ? 'local-player-2'
        : 'local-player-1';
    final res = engine.respondToDrawOffer(
      accept: accept,
      byUserId: responderId,
      nowMs: DateTime.now().millisecondsSinceEpoch,
    );
    if (!res.valid) return;

    setState(() {
      _statusMessage = accept
          ? '🤝 ${l10n.drawAcceptedMessage}'
          : '❌ ${l10n.drawRejectedMessage}';
      _statusColor = accept ? AppColors.electricLime : AppColors.coralRed;
    });
  }

  void _showMoveHistorySheet(AppLocalizations l10n) {
    final engine = _engine;
    if (engine == null) return;
    final history = engine.state.moveHistory.reversed.toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.65,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.matchHistoryTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                if (history.isEmpty)
                  Expanded(
                    child: Center(child: Text(l10n.noMovesYet)),
                  )
                else
                  Expanded(
                    child: ListView.separated(
                      itemCount: history.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 6),
                      itemBuilder: (_, idx) {
                        final item = history[idx];
                        final actor = item.byUserId == 'local-player-1'
                            ? (_isVsAi
                                  ? '${l10n.scoreboardYou} (X)'
                                  : '${l10n.scoreboardPlayer1} (X)')
                            : (_isVsAi
                                  ? '${l10n.scoreboardBot} (O)'
                                  : '${l10n.scoreboardPlayer2} (O)');
                        final label = switch (item.type) {
                          'move' =>
                            '⚽ [${l10n.roundLabel} ${item.roundNumber}] $actor: ${item.playerName ?? item.playerId ?? ''} (${l10n.yourTurnSelectCell.split(' ').last} ${(item.cellIndex ?? 0) + 1})',
                          'pass' =>
                            '⏭️ [${l10n.roundLabel} ${item.roundNumber}] ${l10n.playerPassedTurn(actor)}',
                          'timeout' =>
                            '⏰ [${l10n.roundLabel} ${item.roundNumber}] $actor (${l10n.errorTimeExpired})',
                          'draw_offer' =>
                            '🤝 [${l10n.roundLabel} ${item.roundNumber}] $actor: ${l10n.offerDraw}',
                          'draw_accepted' => '🤝 ${l10n.drawAcceptedMessage}',
                          'draw_rejected' => '❌ ${l10n.drawRejectedMessage}',
                          'draw_expired' => '⌛ ${l10n.drawOfferExpiredMessage}',
                          _ => '$actor • ${item.type}',
                        };
                        return Card(
                          child: ListTile(
                            dense: true,
                            title: Text(
                              label,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showCellAnswersSheet(GameCell cell) async {
    final validator = ref.read(answerValidatorRepositoryProvider);
    final playerRepo = ref.read(playerRepositoryProvider);
    final ids = await validator.getPlayersForTeamPair(
      cell.rowTeam.id,
      cell.colTeam.id,
    );
    final players = await playerRepo.getByIds(ids);
    players.sort((a, b) => (b.eaFcOverall ?? 0).compareTo(a.eaFcOverall ?? 0));

    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.7,
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppTheme.clubCrestWidget(
                      teamName: cell.rowTeam.name,
                      logoUrl: cell.rowTeam.logoUrl,
                      primaryColorHex: cell.rowTeam.primaryColorHex,
                      size: 36,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Icon(
                        Icons.handshake_rounded,
                        color: AppColors.trophyGold,
                      ),
                    ),
                    AppTheme.clubCrestWidget(
                      teamName: cell.colTeam.name,
                      logoUrl: cell.colTeam.logoUrl,
                      primaryColorHex: cell.colTeam.primaryColorHex,
                      size: 36,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '${cell.rowTeam.name} × ${cell.colTeam.name}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  l10n.verifiedPlayersForCell(players.length),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.slateGray,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.separated(
                    itemCount: players.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 6),
                    itemBuilder: (_, i) {
                      final p = players[i];
                      return Card(
                        child: ListTile(
                          dense: true,
                          leading: AppTheme.playerAvatarWidget(
                            name: p.name,
                            overall: p.eaFcOverall,
                            position: p.position,
                            size: 38,
                          ),
                          title: Text(
                            p.name,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          subtitle: Text(
                            '${AppTheme.nationalityFlag(p.nationality)} ${p.nationality ?? ''} • ${p.position ?? ''}',
                          ),
                          trailing: Text(
                            'OVR ${p.eaFcOverall ?? '?'}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              color: AppColors.electricLime,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onCellTap(int cellIndex) async {
    final engine = _engine;
    if (engine == null || _aiThinking || engine.state.isRoundSummary) return;

    // When game is over, tapping any cell shows all valid answers for that cell!
    if (engine.state.status != GameStatus.playing) {
      await _showCellAnswersSheet(engine.state.cells[cellIndex]);
      return;
    }

    if (engine.state.isCellFilled(cellIndex)) return;

    final activeUserId = engine.state.currentTurnUserId ?? 'local-player-1';
    if (_isVsAi && activeUserId != 'local-player-1') return;

    final targetCell = engine.state.cells[cellIndex];
    setState(() => _selectedCellIndex = cellIndex);

    final player = await showModalBottomSheet<Player>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (_) => PlayerSearchBottomSheet(
        rowTeamName: targetCell.rowTeam.name,
        rowTeamLogoUrl: targetCell.rowTeam.logoUrl,
        rowTeamColorHex: targetCell.rowTeam.primaryColorHex,
        colTeamName: targetCell.colTeam.name,
        colTeamLogoUrl: targetCell.colTeam.logoUrl,
        colTeamColorHex: targetCell.colTeam.primaryColorHex,
        cellIndex: cellIndex,
      ),
    );
    if (!mounted) return;
    setState(() => _selectedCellIndex = null);
    if (player == null) return;

    // Check if rare cell
    final cell = engine.state.cells[cellIndex];
    final validator = ref.read(answerValidatorRepositoryProvider);
    final candidates = await validator.getPlayersForTeamPair(
      cell.rowTeam.id,
      cell.colTeam.id,
    );

    final result = await engine.submitAnswer(
      cellIndex: cellIndex,
      playerId: player.id,
      player: player,
      byUserId: activeUserId,
    );

    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    if (result.valid) {
      ref.read(appSettingsProvider.notifier).triggerSuccessHaptic();
      if (candidates.length <= 4 && activeUserId == 'local-player-1') {
        _unlockedRareThisMatch = true;
      }
      setState(() {
        _statusMessage = '⚽ ${l10n.correctAnswer}: ${player.name}';
        _statusColor = AppColors.electricLime;
      });
      if (engine.state.status == GameStatus.playing &&
          !engine.state.isRoundSummary) {
        _timer?.reset();
        _timer?.start();
        _checkAndTriggerAiTurn();
      }
    } else {
      ref.read(appSettingsProvider.notifier).triggerErrorHaptic();
      engine.skipTurn(reason: 'wrong_answer');
      setState(() {
        switch (result.error) {
          case 'INVALID_PLAYER':
            _statusMessage = l10n.playerDidNotPlayForBoth(player.name);
            break;
          default:
            _statusMessage = result.error ?? l10n.errorServerError;
        }
        _statusColor = AppColors.coralRed;
      });
      _timer?.reset();
      _timer?.start();
      _checkAndTriggerAiTurn();
    }
  }

  String _formatDuration(int totalSeconds) {
    final mins = totalSeconds ~/ 60;
    final secs = totalSeconds % 60;
    return '${mins}m ${secs.toString().padLeft(2, '0')}s';
  }

  void _showGameOverDialog(GameState state, int finalScore) {
    final l10n = AppLocalizations.of(context)!;
    final p1Won = state.winnerUserId == 'local-player-1';
    final isDraw = state.status == GameStatus.draw;
    final p1RoundWins = state.roundWinsFor('local-player-1');
    final p2RoundWins = state.roundWinsFor('local-player-2');
    final p1Correct = state.totalCorrectByUser['local-player-1'] ?? 0;
    final p1Wrong = state.totalWrongByUser['local-player-1'] ?? 0;
    final p1Passes = state.totalPassesByUser['local-player-1'] ?? 0;
    final durationSec = state.matchDurationSeconds(_nowMs);
    final eloDelta = p1Won ? 25 : (isDraw ? 5 : -15);

    final title = isDraw
        ? '🤝 ${l10n.draw}'
        : _isVsAi
        ? (p1Won ? '🏆 ${l10n.won}' : l10n.botWon)
        : (p1Won ? l10n.player1WonX : l10n.player2WonO);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: p1Won
                ? AppColors.electricLime
                : (isDraw ? AppColors.trophyGold : AppColors.coralRed),
            width: 1.6,
          ),
        ),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.pitchGreen,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                l10n.matchEndSummary(state.totalRounds, state.roundsToWin),
                style: AppTypography.label(
                  fontSize: 10.5,
                  color: AppColors.trophyGold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(title, textAlign: TextAlign.center),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.pitchGreen,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Text(
                    '${l10n.roundLabel} ${l10n.score}:  $p1RoundWins  -  $p2RoundWins',
                    textAlign: TextAlign.center,
                    style: AppTheme.scoreboardNumberStyle(
                      fontSize: 22,
                      color: AppColors.electricLime,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${l10n.score}: $finalScore  -  ${state.scores['local-player-2'] ?? 0}',
                    style: AppTypography.label(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.stadiumNight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Column(
                children: [
                  _buildSummaryRow(
                    l10n.roundsWon,
                    '$p1RoundWins - $p2RoundWins',
                  ),
                  const SizedBox(height: 5),
                  _buildSummaryRow(l10n.correctAnswers, '$p1Correct'),
                  const SizedBox(height: 5),
                  _buildSummaryRow(l10n.wrongAnswers, '$p1Wrong'),
                  const SizedBox(height: 5),
                  _buildSummaryRow(l10n.passesUsed, '$p1Passes'),
                  const SizedBox(height: 5),
                  _buildSummaryRow(l10n.matchDuration, _formatDuration(durationSec)),
                  const Divider(height: 14),
                  _buildSummaryRow(
                    l10n.eloChange,
                    '${eloDelta >= 0 ? '+' : ''}$eloDelta ELO',
                    valueColor: eloDelta > 0
                        ? AppColors.electricLime
                        : (eloDelta == 0
                              ? AppColors.trophyGold
                              : AppColors.coralRed),
                  ),
                ],
              ),
            ),
            if (state.endedByDrawOffer) ...[
              const SizedBox(height: 8),
              Text(
                l10n.drawAcceptedMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              l10n.inspectBoardHint,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11.5, color: AppColors.slateGray),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text(l10n.inspectBoard),
          ),
          OutlinedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.pop();
            },
            child: Text(l10n.close),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(ctx).pop();
              _init();
            },
            icon: const Icon(Icons.replay_rounded, size: 18),
            label: const Text('Tekrar Oyna'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.description(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTypography.label(
            fontSize: 12,
            color: valueColor ?? AppColors.warmWhite,
            tabular: true,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final title = _isVsAi
        ? 'Football SOS • vs AI'
        : l10n.footballSos2P;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          // Format Selector (3 Tur - 2 Galibiyet vs 5 Tur - 3 Galibiyet)
          PopupMenuButton<int>(
            tooltip: l10n.selectMatchFormatTooltip,
            initialValue: _selectedTotalRounds,
            onSelected: (rounds) {
              if (rounds != _selectedTotalRounds) {
                setState(() => _selectedTotalRounds = rounds);
                _init();
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 3,
                child: Text('🏆 ${l10n.format3RoundsTitle}'),
              ),
              PopupMenuItem(
                value: 5,
                child: Text('🏆 ${l10n.format5RoundsTitle}'),
              ),
            ],
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.pitchGreen,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.emoji_events_rounded,
                    size: 14,
                    color: AppColors.trophyGold,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    '$_selectedTotalRounds ${l10n.roundLabel}',
                    style: AppTypography.label(
                      fontSize: 11,
                      color: AppColors.trophyGold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: l10n.matchHistoryTitle,
            icon: const Icon(Icons.history_rounded, size: 20),
            onPressed: () => _showMoveHistorySheet(l10n),
          ),
          AppTheme.onlineRoomButton(
            context: context,
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => const OnlineLobbyDialog(initialMode: 'sos'),
              );
            },
          ),
          PopupMenuButton<bool>(
            tooltip: l10n.changeGameModeTooltip,
            icon: Icon(
              _isVsAi ? Icons.smart_toy_rounded : Icons.people_rounded,
              size: 20,
            ),
            onSelected: (vsAi) {
              setState(() => _isVsAi = vsAi);
              _init();
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: true,
                child: Text(l10n.modeSoloVsBot),
              ),
              PopupMenuItem(
                value: false,
                child: Text(l10n.mode2PlayerLocal),
              ),
            ],
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: l10n.newGrid,
            icon: const Icon(Icons.refresh_rounded, size: 20),
            onPressed: _init,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: _remaining <= 5
                      ? AppColors.coralRed.withValues(alpha: 0.2)
                      : AppColors.electricLime.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _remaining <= 5
                        ? AppColors.coralRed
                        : AppColors.electricLime,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 15,
                      color: _remaining <= 5
                          ? AppColors.coralRed
                          : AppColors.electricLime,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_remaining}s',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        color: _remaining <= 5
                            ? AppColors.coralRed
                            : AppColors.electricLime,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${l10n.errorServerError}: $_error',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : StadiumPitchBackground(child: _buildGameBody(context, l10n)),
    );
  }

  Widget _buildGameBody(BuildContext context, AppLocalizations l10n) {
    final engine = _engine!;
    final state = engine.state;
    final cells = state.cells;
    final localScore = state.scores['local-player-1'] ?? 0;
    final opponentScore = state.scores['local-player-2'] ?? 0;
    final activeUserId = state.currentTurnUserId ?? 'local-player-1';
    final canActNow =
        !_aiThinking &&
        !state.isRoundSummary &&
        (!_isVsAi || activeUserId == 'local-player-1');
    final activePassesRemaining = state.remainingPassesFor(
      _isVsAi ? 'local-player-1' : activeUserId,
    );
    final offerSenderId = _isVsAi ? 'local-player-1' : activeUserId;
    final drawCooldownSec = state.drawOfferCooldownSecondsFor(
      offerSenderId,
      _nowMs,
    );
    final hasActiveOffer = state.hasActiveDrawOffer(_nowMs);
    final offerRemainingSec = state.drawOfferRemainingSeconds(_nowMs);
    final selRow = _selectedCellIndex != null ? _selectedCellIndex! ~/ 3 : null;
    final selCol = _selectedCellIndex != null ? _selectedCellIndex! % 3 : null;

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildScoreRow(l10n, localScore, opponentScore, state),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: (_remaining / _totalTurnSeconds).clamp(0.0, 1.0),
                    minHeight: 5,
                    backgroundColor: AppColors.surfaceElevated,
                    color: _remaining <= 5
                        ? AppColors.coralRed
                        : AppColors.electricLime,
                  ),
                ),
                // Tactical Actions Row: PAS GEÇ (2/2) & BERABERLİK TEKLİF ET
                if (state.status == GameStatus.playing &&
                    !state.isRoundSummary) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          key: const Key('local_pass_turn_button'),
                          onPressed:
                              canActNow &&
                                  state.canPass(
                                    _isVsAi ? 'local-player-1' : activeUserId,
                                  )
                              ? _onPassTurn
                              : null,
                          icon: const Icon(Icons.skip_next_rounded, size: 18),
                          label: Text(
                            '${l10n.passTurn} ($activePassesRemaining/${GameState.maxPassesPerPlayer})',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          key: const Key('local_offer_draw_button'),
                          onPressed:
                              !_aiThinking &&
                                  state.canOfferDraw(offerSenderId, _nowMs)
                              ? _onOfferDraw
                              : null,
                          icon: const Icon(Icons.handshake_rounded, size: 18),
                          label: Text(
                            drawCooldownSec > 0
                                ? '${l10n.offerDraw} (${drawCooldownSec}s)'
                                : l10n.offerDraw,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                // Active Draw Offer Banner (Accept / Reject)
                if (hasActiveOffer && state.drawOffer != null) ...[
                  const SizedBox(height: 8),
                  _buildDrawOfferBanner(state, offerRemainingSec, l10n),
                ],
                const SizedBox(height: 8),
                if (_statusMessage != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: (_statusColor ?? AppColors.electricLime)
                          .withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: (_statusColor ?? AppColors.electricLime)
                            .withValues(alpha: 0.55),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.sports_soccer_rounded,
                          color: _statusColor,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _statusMessage!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              color: _statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Center(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final shortest = min(
                              constraints.maxWidth,
                              constraints.maxHeight,
                            );
                            final boardSize = shortest.clamp(220.0, 560.0);
                            final innerSize = boardSize - 19;
                            final cellSize = innerSize / 4;

                            return Container(
                              width: boardSize,
                              height: boardSize,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.pitchGreen,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: AppColors.border,
                                  width: 1.5,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black54,
                                    blurRadius: 20,
                                    offset: Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  // Top Header Row
                                  SizedBox(
                                    height: cellSize,
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: cellSize,
                                          height: cellSize,
                                          child: Padding(
                                            padding: const EdgeInsets.all(3),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    AppColors.electricLime
                                                        .withValues(
                                                          alpha: 0.24,
                                                        ),
                                                    AppColors.pitchGreen,
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                                border: Border.all(
                                                  color: AppColors.electricLime
                                                      .withValues(alpha: 0.6),
                                                  width: 1.4,
                                                ),
                                              ),
                                              alignment: Alignment.center,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.sports_soccer_rounded,
                                                    color:
                                                        AppColors.electricLime,
                                                    size: (cellSize * 0.32)
                                                        .clamp(16.0, 26.0),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    'T${state.roundNumber}',
                                                    style:
                                                        AppTheme.scoreboardNumberStyle(
                                                          fontSize:
                                                              (cellSize * 0.14)
                                                                  .clamp(
                                                                    9.0,
                                                                    12.0,
                                                                  ),
                                                          color: AppColors
                                                              .trophyGold,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        for (int c = 0; c < 3; c++)
                                          SizedBox(
                                            width: cellSize,
                                            height: cellSize,
                                            child: Padding(
                                              padding: const EdgeInsets.all(3),
                                              child: _buildTeamHeader(
                                                cells[c].colTeam,
                                                cellSize,
                                                highlighted: selCol == c,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  // 3 Grid Rows
                                  for (int r = 0; r < 3; r++)
                                    SizedBox(
                                      height: cellSize,
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: cellSize,
                                            height: cellSize,
                                            child: Padding(
                                              padding: const EdgeInsets.all(3),
                                              child: _buildTeamHeader(
                                                cells[r * 3].rowTeam,
                                                cellSize,
                                                highlighted: selRow == r,
                                              ),
                                            ),
                                          ),
                                          for (int c = 0; c < 3; c++)
                                            SizedBox(
                                              width: cellSize,
                                              height: cellSize,
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  3,
                                                ),
                                                child: _buildCell(
                                                  cells[r * 3 + c],
                                                  r * 3 + c,
                                                  cellSize,
                                                  state.winningLine.contains(
                                                    r * 3 + c,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      if (state.isRoundSummary)
                        _buildLocalInterRoundSummaryCard(state),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLocalInterRoundSummaryCard(GameState state) {
    final l10n = AppLocalizations.of(context)!;
    final p1Name = _isVsAi ? l10n.scoreboardYou : l10n.scoreboardPlayer1;
    final p2Name = _isVsAi ? l10n.scoreboardBot : l10n.scoreboardPlayer2;
    final p1RoundWins = state.roundWinsFor('local-player-1');
    final p2RoundWins = state.roundWinsFor('local-player-2');
    final winner = state.lastRoundWinnerId;
    final p1WonRound = winner == 'local-player-1';
    final isDraw = winner == 'draw' || winner == null;

    final title = isDraw
        ? l10n.roundEndedInDraw(state.roundNumber)
        : p1WonRound
        ? '🏆 ${l10n.roundLabel} ${state.roundNumber} ${l10n.won}: $p1Name'
        : '⚽ ${l10n.roundLabel} ${state.roundNumber} ${l10n.won}: $p2Name';

    return Container(
      key: const Key('local_inter_round_summary_card'),
      margin: const EdgeInsets.all(14),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.electricLime, width: 1.8),
        boxShadow: AppShadows.elevated,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.pitchGreen,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.trophyGold),
            ),
            child: Text(
              l10n.roundCompletedNewStarting(state.roundNumber),
              style: AppTypography.label(
                fontSize: 11,
                color: AppColors.trophyGold,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTypography.modeTitle(
              fontSize: 18,
              color: isDraw
                  ? AppColors.trophyGold
                  : (p1WonRound ? AppColors.electricLime : AppColors.skyBlue),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.pitchGreen,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              '${l10n.seriesDraw.split(' ').first} ${l10n.score}:  $p1Name $p1RoundWins  —  $p2RoundWins $p2Name',
              style: AppTheme.scoreboardNumberStyle(
                fontSize: 16,
                color: AppColors.warmWhite,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.nextRoundBanner(state.roundNumber + 1, state.roundsToWin),
            style: AppTypography.description(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          ArenaButton(
            key: const Key('local_next_round_button'),
            label: l10n.startNextRound(state.roundNumber + 1),
            icon: Icons.play_arrow_rounded,
            compact: true,
            onTap: _startNextRound,
          ),
        ],
      ),
    );
  }

  Widget _buildDrawOfferBanner(
    GameState state,
    int remainingSec,
    AppLocalizations l10n,
  ) {
    final offer = state.drawOffer!;
    final senderName = offer.fromUserId == 'local-player-1'
        ? (_isVsAi ? 'Sen' : 'Oyuncu 1')
        : (_isVsAi ? 'Bot' : 'Oyuncu 2');

    return Container(
      key: const Key('local_draw_offer_banner'),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.trophyGold.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.trophyGold, width: 1.5),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.handshake_rounded,
            color: AppColors.trophyGold,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.drawOfferReceived(senderName, remainingSec),
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 12.5,
              ),
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            key: const Key('local_reject_draw_button'),
            onPressed: () => _onRespondToDrawOffer(false),
            child: Text(l10n.rejectDraw),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            key: const Key('local_accept_draw_button'),
            onPressed: () => _onRespondToDrawOffer(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.electricLime,
              foregroundColor: AppColors.stadiumNight,
            ),
            child: Text(l10n.acceptDraw),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreRow(
    AppLocalizations l10n,
    int localScore,
    int opponentScore,
    GameState state,
  ) {
    final p1Turn = state.currentTurnUserId == 'local-player-1';
    final p1Passes = state.remainingPassesFor('local-player-1');
    final p2Passes = state.remainingPassesFor('local-player-2');
    final p1RoundWins = state.roundWinsFor('local-player-1');
    final p2RoundWins = state.roundWinsFor('local-player-2');
    final p1Label = '${_isVsAi ? l10n.scoreboardYou : l10n.scoreboardPlayer1} (${p1Passes}P)';
    final p2Label = '${_isVsAi ? l10n.scoreboardBot : l10n.scoreboardPlayer2} (${p2Passes}P)';
    final centerTop = state.status == GameStatus.won
        ? l10n.scoreboardFinished
        : state.status == GameStatus.draw
        ? l10n.scoreboardDraw
        : 'T${state.roundNumber} • $p1RoundWins-$p2RoundWins';
    final centerBottom = _aiThinking
        ? l10n.scoreboardAiThinking
        : (p1Turn ? l10n.scoreboardTurnX : l10n.scoreboardTurnO);

    return BroadcastScoreboard(
      p1Name: p1Label,
      p1Badge: 'X',
      p1Score: localScore,
      p1Color: AppColors.electricLime,
      p1Active: p1Turn && state.status == GameStatus.playing,
      p2Name: p2Label,
      p2Badge: 'O',
      p2Score: opponentScore,
      p2Color: AppColors.skyBlue,
      p2Active: !p1Turn && state.status == GameStatus.playing,
      centerTopLabel: centerTop,
      centerBottomLabel: centerBottom,
      centerAccent: _remaining <= 5
          ? AppColors.coralRed
          : AppColors.electricLime,
    );
  }

  Widget _buildTeamHeader(Team team, double size, {bool highlighted = false}) {
    final teamColor = AppTheme.hexToColor(
      team.primaryColorHex,
      AppTheme.surfaceElevated,
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  Color.lerp(AppTheme.surface, teamColor, 0.32)!,
                  AppTheme.surfaceSecondary,
                ]
              : [Color.lerp(Colors.white, teamColor, 0.16)!, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: highlighted
              ? AppColors.electricLime
              : teamColor.withValues(alpha: 0.7),
          width: highlighted ? 2.2 : 1.4,
        ),
      ),
      padding: const EdgeInsets.all(4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppTheme.clubCrestWidget(
            logoUrl: team.logoUrl,
            teamName: team.name,
            primaryColorHex: team.primaryColorHex,
            size: (size * 0.44).clamp(20.0, 44.0),
          ),
          const SizedBox(height: 3),
          Flexible(
            child: Text(
              team.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: (size * 0.11).clamp(9.0, 12.5),
                height: 1.08,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCell(GameCell cell, int index, double size, bool isWinningCell) {
    final filled = !cell.isEmpty;
    final isSelected = _selectedCellIndex == index;
    final isX = cell.mark == GameMark.x;
    final markText = isX
        ? 'X'
        : cell.mark == GameMark.o
        ? 'O'
        : '';
    final markColor = isWinningCell
        ? AppColors.trophyGold
        : (isX ? AppColors.electricLime : AppColors.skyBlue);
    final gameEnded = _engine?.state.status != GameStatus.playing;
    final l10n = AppLocalizations.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: (filled && !gameEnded) ? null : () => _onCellTap(index),
        onLongPress: () => _showCellAnswersSheet(cell),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            gradient: filled
                ? LinearGradient(
                    colors: [
                      markColor.withValues(alpha: isWinningCell ? 0.30 : 0.20),
                      AppColors.pitchGreen,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : isSelected
                ? LinearGradient(
                    colors: [
                      AppColors.turfGreen.withValues(alpha: 0.65),
                      AppColors.pitchGreen,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : const LinearGradient(
                    colors: [AppColors.cardBackground, AppColors.pitchGreen],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isWinningCell
                  ? AppColors.trophyGold
                  : filled
                  ? markColor
                  : isSelected
                  ? AppColors.electricLime
                  : AppColors.border,
              width: isWinningCell ? 2.6 : ((filled || isSelected) ? 2.0 : 1.2),
            ),
          ),
          padding: const EdgeInsets.all(4),
          child: Center(
            child: filled
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 1.5,
                        ),
                        decoration: BoxDecoration(
                          color: markColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          markText,
                          style: AppTheme.scoreboardNumberStyle(
                            fontSize: (size * 0.21).clamp(13.0, 22.0),
                            color: AppColors.stadiumNight,
                          ),
                        ),
                      ),
                      if (cell.selectedPlayer != null) ...[
                        const SizedBox(height: 4),
                        Flexible(
                          child: Text(
                            cell.selectedPlayer!.name,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: (size * 0.105).clamp(8.5, 11.5),
                              fontWeight: FontWeight.w800,
                              color: AppColors.warmWhite,
                              height: 1.08,
                            ),
                          ),
                        ),
                      ],
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        gameEnded
                            ? Icons.visibility_outlined
                            : Icons.add_rounded,
                        size: (size * 0.28).clamp(18.0, 28.0),
                        color: isSelected
                            ? AppColors.electricLime
                            : AppColors.electricLime.withValues(alpha: 0.65),
                      ),
                      Text(
                        gameEnded
                            ? (l10n?.cellActionView ?? 'GÖR')
                            : (l10n?.cellActionSelect ?? 'SEÇ'),
                        style: TextStyle(
                          fontSize: (size * 0.095).clamp(8.0, 10.5),
                          fontWeight: FontWeight.w900,
                          color: isSelected
                              ? AppColors.electricLime
                              : AppColors.slateGray,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

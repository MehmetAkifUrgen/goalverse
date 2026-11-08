import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/monetization/ad_service.dart';
import '../../../core/providers.dart';
import '../../../core/providers/auth_providers.dart';
import '../../../core/providers/settings_and_stats_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/stadium_visuals.dart';
import '../../../data/models/freezed/entity_models.dart';
import '../data/online_match_service.dart';
import '../domain/online_game_model.dart';
import 'player_search_bottom_sheet.dart';

class OnlineGamePage extends ConsumerStatefulWidget {
  final String gameId;

  const OnlineGamePage({super.key, required this.gameId});

  @override
  ConsumerState<OnlineGamePage> createState() => _OnlineGamePageState();
}

class _OnlineGamePageState extends ConsumerState<OnlineGamePage> {
  static const int _interRoundDelaySeconds = 5;

  final OnlineMatchService _service = OnlineMatchService();
  bool _makingMove = false;
  bool _advancingRound = false;
  bool _dialogShown = false;
  Timer? _clockTimer;
  int _remainingSeconds = 30;
  int _roundSummaryCountdown = _interRoundDelaySeconds;
  int _nowMs = DateTime.now().millisecondsSinceEpoch;
  int? _selectedCellIndex;
  OnlineGame? _lastGame;

  @override
  void initState() {
    super.initState();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), _onClockTick);
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  void _onClockTick(Timer timer) {
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final game = _lastGame;
    if (game == null || !game.isPlaying) {
      if (mounted) {
        setState(() => _nowMs = nowMs);
      }
      return;
    }

    // Handle inter-round summary countdown & automatic synchronized next-round transition
    if (game.isRoundSummary) {
      final elapsedSummary = (nowMs - game.lastMoveTimestamp) ~/ 1000;
      final remSummary = max(0, _interRoundDelaySeconds - elapsedSummary);
      if (mounted) {
        setState(() {
          _roundSummaryCountdown = remSummary;
          _nowMs = nowMs;
        });
      }
      if (remSummary <= 0 && !_advancingRound) {
        _triggerNextRound(game);
      }
      return;
    }

    final user = ref.read(currentUserProvider);
    final myUserId = user?.uid ?? 'guest';
    final elapsed = (nowMs - game.lastMoveTimestamp) ~/ 1000;
    final remaining = max(0, game.turnDurationSeconds - elapsed);

    if (mounted) {
      setState(() {
        _remainingSeconds = remaining;
        _nowMs = nowMs;
      });
    }

    // Automatically expire pending draw offer after 30 seconds
    if (game.drawOffer != null &&
        game.drawOffer!.status == 'pending' &&
        nowMs >= game.drawOffer!.expiresAtMs &&
        !_makingMove) {
      _service.expireDrawOffer(gameId: widget.gameId, nowMsOverride: nowMs);
    }

    if (remaining <= 0 && game.currentTurn == myUserId && !_makingMove) {
      _service.timeoutPassTurn(gameId: widget.gameId, timedOutUserId: myUserId);
    }
  }

  Future<void> _triggerNextRound(OnlineGame game) async {
    if (_advancingRound) return;
    setState(() => _advancingRound = true);
    try {
      await _service.advanceToNextRound(
        gameId: widget.gameId,
        expectedFromRound: game.roundNumber,
      );
    } finally {
      if (mounted) {
        setState(() => _advancingRound = false);
      }
    }
  }

  Future<bool> _confirmExitIfPlaying(OnlineGame? game) async {
    if (game == null || game.isFinished) return true;
    final l10n = AppLocalizations.of(context);
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n?.leaveMatchTitle ?? 'Maçtan Çıkılsın mı?'),
        content: Text(
          l10n?.leaveMatchConfirm ??
              'Devam eden çok oyunculu maçtan ayrılmak istediğinize emin misiniz?',
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n?.continueMatch ?? 'Maça Devam Et'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.coralRed,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n?.leaveMatch ?? 'Maçtan Ayrıl'),
          ),
        ],
      ),
    );
    return shouldLeave ?? false;
  }

  Future<void> _onCellTapped(
    OnlineGame game,
    int cellIndex,
    String myUserId,
  ) async {
    if (_makingMove || game.isRoundSummary) return;
    final l10n = AppLocalizations.of(context)!;

    if (game.currentTurn != myUserId) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⏳ ${l10n.errorNotYourTurn}'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (game.board[cellIndex] != null) return;

    final rowTeam = game.rowTeams[cellIndex ~/ 3];
    final colTeam = game.colTeams[cellIndex % 3];

    setState(() => _selectedCellIndex = cellIndex);

    final selected = await showModalBottomSheet<Player>(
      context: context,
      isScrollControlled: true,
      builder: (_) => PlayerSearchBottomSheet(
        rowTeamName: rowTeam.name,
        rowTeamLogoUrl: rowTeam.logoUrl,
        rowTeamColorHex: rowTeam.colorHex,
        colTeamName: colTeam.name,
        colTeamLogoUrl: colTeam.logoUrl,
        colTeamColorHex: colTeam.colorHex,
        cellIndex: cellIndex,
      ),
    );

    if (!mounted) return;
    setState(() => _selectedCellIndex = null);
    if (selected == null) return;

    setState(() => _makingMove = true);

    final validator = ref.read(answerValidatorRepositoryProvider);
    final error = await _service.makeMove(
      gameId: widget.gameId,
      cellIndex: cellIndex,
      player: selected,
      userId: myUserId,
      validator: validator,
    );

    if (!mounted) return;
    setState(() => _makingMove = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppColors.coralRed,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _onPassTurn(OnlineGame game, String myUserId) async {
    if (_makingMove || game.isRoundSummary) return;
    final l10n = AppLocalizations.of(context)!;

    if (game.currentTurn != myUserId) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⏳ ${l10n.errorNotYourTurn}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (game.remainingPassesFor(myUserId) <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.noPassesLeft),
          backgroundColor: AppColors.coralRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _makingMove = true);
    final error = await _service.passTurn(
      gameId: widget.gameId,
      userId: myUserId,
    );
    if (!mounted) return;
    setState(() => _makingMove = false);

    if (error != null) {
      final msg = switch (error) {
        'NO_PASSES_LEFT' => l10n.noPassesLeft,
        'NOT_YOUR_TURN' => l10n.errorNotYourTurn,
        _ => error,
      };
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: AppColors.coralRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _onOfferDraw(
    OnlineGame game,
    String myUserId,
    String myName,
  ) async {
    if (_makingMove || game.isRoundSummary) return;
    final l10n = AppLocalizations.of(context)!;
    final nowMs = DateTime.now().millisecondsSinceEpoch;

    final cooldownSec = game.drawOfferCooldownSecondsFor(myUserId, nowMs);
    if (cooldownSec > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.drawOfferCooldownMessage(cooldownSec)),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (game.hasActiveDrawOffer(nowMs)) return;

    setState(() => _makingMove = true);
    final error = await _service.offerDraw(
      gameId: widget.gameId,
      userId: myUserId,
      userName: myName,
    );
    if (!mounted) return;
    setState(() => _makingMove = false);

    if (error != null) {
      final msg = switch (error) {
        'DRAW_OFFER_COOLDOWN' => l10n.drawOfferCooldownMessage(
          game.drawOfferCooldownSecondsFor(myUserId),
        ),
        _ => error,
      };
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: AppColors.coralRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _onRespondToDrawOffer(
    OnlineGame game,
    String myUserId,
    bool accept,
  ) async {
    if (_makingMove) return;
    final l10n = AppLocalizations.of(context)!;

    setState(() => _makingMove = true);
    final error = await _service.respondToDrawOffer(
      gameId: widget.gameId,
      userId: myUserId,
      accept: accept,
    );
    if (!mounted) return;
    setState(() => _makingMove = false);

    if (error != null) {
      final msg = switch (error) {
        'DRAW_OFFER_EXPIRED' => l10n.drawOfferExpiredMessage,
        _ => error,
      };
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: AppColors.coralRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showMoveHistorySheet(OnlineGame game, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        final history = game.moveHistory.reversed.toList();
        return SafeArea(
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
                          final actor =
                              item.byUserName ??
                              (item.byUserId == game.player1Id
                                  ? game.player1Name
                                  : (game.player2Name ?? 'Oyuncu 2'));
                          final label = switch (item.type) {
                            'move' =>
                              '⚽ [Tur ${item.roundNumber}] $actor: ${item.playerName ?? item.playerId ?? ''} (Kare ${(item.cellIndex ?? 0) + 1})',
                            'pass' =>
                              '⏭️ [Tur ${item.roundNumber}] ${l10n.playerPassedTurn(actor)}',
                            'timeout' =>
                              '⏰ [Tur ${item.roundNumber}] $actor (${l10n.errorTimeExpired})',
                            'draw_offer' =>
                              '🤝 [Tur ${item.roundNumber}] $actor: ${l10n.offerDraw}',
                            'draw_accepted' => '🤝 ${l10n.drawAcceptedMessage}',
                            'draw_rejected' => '❌ ${l10n.drawRejectedMessage}',
                            'draw_expired' =>
                              '⌛ ${l10n.drawOfferExpiredMessage}',
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
        );
      },
    );
  }

  String _formatDuration(int totalSeconds) {
    final mins = totalSeconds ~/ 60;
    final secs = totalSeconds % 60;
    return '${mins}dk ${secs.toString().padLeft(2, '0')}sn';
  }

  void _checkAndShowGameOver(OnlineGame game, String myUserId) {
    if (game.isFinished && !_dialogShown) {
      _dialogShown = true;
      final isWin = game.winnerId == myUserId;
      final isDraw = game.winnerId == 'draw' || game.winnerId == null;
      final endedByDrawOffer = game.drawOffer?.status == 'accepted';
      final amIPlayer1 = game.player1Id == myUserId;
      final oppId = amIPlayer1 ? (game.player2Id ?? '') : game.player1Id;
      final myName = amIPlayer1
          ? game.player1Name
          : (game.player2Name ?? 'Oyuncu 2');
      final oppName = amIPlayer1
          ? (game.player2Name ?? 'Rakip')
          : game.player1Name;

      final myRoundWins = amIPlayer1
          ? game.player1RoundWins
          : game.player2RoundWins;
      final oppRoundWins = amIPlayer1
          ? game.player2RoundWins
          : game.player1RoundWins;
      final myCorrect = game.totalCorrectByUser[myUserId] ?? 0;
      final myWrong = game.totalWrongByUser[myUserId] ?? 0;
      final myTotalPasses =
          game.totalPassesByUser[myUserId] ?? (game.passesUsed[myUserId] ?? 0);
      final oppCorrect = oppId.isNotEmpty
          ? (game.totalCorrectByUser[oppId] ?? 0)
          : 0;
      final durationSec = game.matchDurationSeconds(_nowMs);
      final eloDelta = isWin ? 25 : (isDraw ? 5 : -15);
      final myScore = myRoundWins * 300 + myCorrect * 100 + (isWin ? 200 : 0);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final l10n = AppLocalizations.of(context)!;
        // ELO & Career Stats are updated ONCE at the end of the entire series
        ref
            .read(userStatsProvider.notifier)
            .recordGameResult(
              won: isWin,
              draw: isDraw,
              score: myScore,
              passesUsed: myTotalPasses,
              endedByDrawOffer: endedByDrawOffer,
            );
        unawaited(
          ref
              .read(adServiceProvider.notifier)
              .onMatchCompletedAndMaybeShowInterstitial(),
        );

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              backgroundColor: AppColors.cardBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(
                  color: isWin
                      ? AppColors.electricLime
                      : (isDraw ? AppColors.trophyGold : AppColors.coralRed),
                  width: 1.6,
                ),
              ),
              title: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.pitchGreen,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      l10n.matchEndSummary(game.totalRounds, game.roundsToWin),
                      style: AppTypography.label(
                        fontSize: 10.5,
                        color: AppColors.trophyGold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isWin
                        ? '🏆 ${l10n.won}'
                        : isDraw
                        ? '🤝 ${l10n.draw}'
                        : '💔 ${l10n.lost}',
                    textAlign: TextAlign.center,
                    style: AppTypography.modeTitle(
                      fontSize: 23,
                      color: isWin
                          ? AppColors.electricLime
                          : (isDraw
                                ? AppColors.trophyGold
                                : AppColors.coralRed),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isWin
                        ? l10n.congratsMatchWon(game.roundsToWin)
                        : endedByDrawOffer
                        ? l10n.drawAcceptedMessage
                        : isDraw
                        ? l10n.seriesDraw
                        : l10n.opponentMatchWon(oppName, game.roundsToWin),
                    textAlign: TextAlign.center,
                    style: AppTypography.description(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Series Score Banner
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.pitchGreen,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Flexible(
                          child: Column(
                            children: [
                              Text(
                                myName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.label(
                                  fontSize: 12,
                                  color: AppColors.electricLime,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$myRoundWins',
                                style: AppTheme.scoreboardNumberStyle(
                                  fontSize: 28,
                                  color: AppColors.electricLime,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'TUR SKORU',
                          style: AppTypography.label(
                            fontSize: 10,
                            color: AppColors.trophyGold,
                          ),
                        ),
                        Flexible(
                          child: Column(
                            children: [
                              Text(
                                oppName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.label(
                                  fontSize: 12,
                                  color: AppColors.skyBlue,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$oppRoundWins',
                                style: AppTheme.scoreboardNumberStyle(
                                  fontSize: 28,
                                  color: AppColors.skyBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Detailed Match Statistics
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.stadiumNight,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Column(
                      children: [
                        _buildSummaryStatRow(
                          l10n.roundsWon,
                          '$myRoundWins - $oppRoundWins',
                        ),
                        const SizedBox(height: 6),
                        _buildSummaryStatRow(
                          l10n.correctAnswers,
                          '$myCorrect (${l10n.opponentLabel}: $oppCorrect)',
                        ),
                        const SizedBox(height: 6),
                        _buildSummaryStatRow(l10n.wrongAnswers, '$myWrong'),
                        const SizedBox(height: 6),
                        _buildSummaryStatRow(
                          l10n.passesUsed,
                          '$myTotalPasses',
                        ),
                        const SizedBox(height: 6),
                        _buildSummaryStatRow(
                          l10n.matchDuration,
                          _formatDuration(durationSec),
                        ),
                        const Divider(height: 16),
                        _buildSummaryStatRow(
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
                ],
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                ArenaButton(
                  label: l10n.mainMenuButton,
                  icon: Icons.home_rounded,
                  onTap: () {
                    Navigator.of(context).pop();
                    context.go('/home');
                  },
                ),
              ],
            );
          },
        );
      });
    }
  }

  Widget _buildSummaryStatRow(String label, String value, {Color? valueColor}) {
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
            fontSize: 12.5,
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
    final user = ref.watch(currentUserProvider);
    final myUserId = user?.uid ?? 'guest';

    return StreamBuilder<OnlineGame>(
      stream: _service.streamGame(widget.gameId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.onlineMatch)),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${l10n.errorServerError}: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.go('/home'),
                    child: Text(l10n.mainMenuButton),
                  ),
                ],
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: AppColors.electricLime),
                  const SizedBox(height: 16),
                  Text(l10n.connectingToLiveMatch),
                ],
              ),
            ),
          );
        }

        final game = snapshot.data!;
        _lastGame = game;
        _checkAndShowGameOver(game, myUserId);

        final isMyTurn = game.currentTurn == myUserId && !game.isRoundSummary;
        final amIPlayer1 = game.player1Id == myUserId;
        final myMark = amIPlayer1 ? 'X' : 'O';
        final oppMark = amIPlayer1 ? 'O' : 'X';
        final myName = amIPlayer1
            ? game.player1Name
            : (game.player2Name ?? 'Oyuncu 2');
        final oppName = amIPlayer1
            ? (game.player2Name ?? 'Rakip')
            : game.player1Name;
        final oppId = amIPlayer1 ? (game.player2Id ?? '') : game.player1Id;
        final myPassesRemaining = game.remainingPassesFor(myUserId);
        final oppPassesRemaining = oppId.isEmpty
            ? OnlineGame.maxPassesPerPlayer
            : game.remainingPassesFor(oppId);
        final myRoundWins = amIPlayer1
            ? game.player1RoundWins
            : game.player2RoundWins;
        final oppRoundWins = amIPlayer1
            ? game.player2RoundWins
            : game.player1RoundWins;

        final hasActiveDrawOffer = game.hasActiveDrawOffer(_nowMs);
        final drawOfferRemainingSec = game.drawOfferRemainingSeconds(_nowMs);
        final drawCooldownSec = game.drawOfferCooldownSecondsFor(
          myUserId,
          _nowMs,
        );

        return PopScope(
          canPop: game.isFinished,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;
            final leave = await _confirmExitIfPlaying(game);
            if (leave && context.mounted) {
              context.go('/home');
            }
          },
          child: Scaffold(
            appBar: AppBar(
              title: Row(
                children: [
                  Text('Oda: ${game.roomCode}'),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.pitchGreen,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      '${game.totalRounds} Tur • ${game.roundsToWin} Galibiyet',
                      style: AppTypography.label(
                        fontSize: 10.5,
                        color: AppColors.trophyGold,
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  tooltip: l10n.matchHistoryTitle,
                  icon: const Icon(Icons.history_rounded),
                  onPressed: () => _showMoveHistorySheet(game, l10n),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.electricLime.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.electricLime),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.circle,
                        color: AppColors.electricLime,
                        size: 9,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'CANLI',
                        style: TextStyle(
                          color: AppColors.electricLime,
                          fontWeight: FontWeight.w800,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            body: StadiumPitchBackground(
              child: SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      child: Column(
                        children: [
                          // Football Stadium Series Scoreboard + Pass Rights
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.cardBackground,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: AppColors.border,
                                width: 1.2,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _buildPlayerBadge(
                                    name: 'Sen ($myMark)',
                                    passesLabel: l10n.passesRemaining(
                                      myPassesRemaining,
                                    ),
                                    markColor: AppColors.electricLime,
                                    active: isMyTurn,
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.pitchGreen,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: AppColors.trophyGold.withValues(
                                        alpha: 0.45,
                                      ),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'TUR ${game.roundNumber}',
                                        style: AppTypography.label(
                                          fontSize: 10,
                                          color: AppColors.trophyGold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '$myRoundWins  -  $oppRoundWins',
                                        key: const Key(
                                          'online_series_score_text',
                                        ),
                                        style: AppTheme.scoreboardNumberStyle(
                                          fontSize: 19,
                                          color: AppColors.warmWhite,
                                        ),
                                      ),
                                      Text(
                                        'Hedef: ${game.roundsToWin}',
                                        style: AppTypography.description(
                                          fontSize: 9.5,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: _buildPlayerBadge(
                                    name: '$oppName ($oppMark)',
                                    passesLabel: l10n.passesRemaining(
                                      oppPassesRemaining,
                                    ),
                                    markColor: AppColors.skyBlue,
                                    active:
                                        !isMyTurn &&
                                        game.isPlaying &&
                                        !game.isRoundSummary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Turn & Timer Banner
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 12,
                            ),
                            decoration: BoxDecoration(
                              color: !game.isPlaying
                                  ? AppColors.surfaceSecondary
                                  : game.isRoundSummary
                                  ? AppColors.deepForest
                                  : isMyTurn
                                  ? (_remainingSeconds <= 5
                                        ? AppColors.coralRed
                                        : AppColors.turfGreen)
                                  : AppColors.pitchGreen,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isMyTurn
                                    ? AppColors.electricLime
                                    : AppColors.border,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (game.isPlaying && !game.isRoundSummary) ...[
                                  Icon(
                                    _remainingSeconds <= 5
                                        ? Icons.alarm_rounded
                                        : Icons.timer_outlined,
                                    color: AppColors.warmWhite,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${_remainingSeconds}s',
                                    style: AppTheme.scoreboardNumberStyle(
                                      fontSize: 15,
                                      color: AppColors.warmWhite,
                                    ),
                                  ),
                                  const Text(
                                    '  •  ',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                ],
                                Flexible(
                                  child: Text(
                                    !game.isPlaying
                                        ? l10n.waitingForOpponent
                                        : game.isRoundSummary
                                        ? l10n.roundCompletedNewStarting(game.roundNumber)
                                        : isMyTurn
                                        ? l10n.yourTurnSelectCell
                                        : l10n.opponentThinking(oppName),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColors.warmWhite,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Active Draw Offer Banner
                          if (hasActiveDrawOffer && game.drawOffer != null) ...[
                            const SizedBox(height: 8),
                            _buildDrawOfferBanner(
                              game: game,
                              myUserId: myUserId,
                              remainingSec: drawOfferRemainingSec,
                              l10n: l10n,
                            ),
                          ],
                          // Tactical Actions Bar: PAS GEÇ & BERABERLİK TEKLİF ET
                          if (game.isPlaying && !game.isRoundSummary) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    key: const Key('online_pass_turn_button'),
                                    onPressed:
                                        game.canPass(myUserId) && !_makingMove
                                        ? () => _onPassTurn(game, myUserId)
                                        : null,
                                    icon: const Icon(
                                      Icons.skip_next_rounded,
                                      size: 18,
                                    ),
                                    label: Text(
                                      '${l10n.passTurn} ($myPassesRemaining/${OnlineGame.maxPassesPerPlayer})',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    key: const Key('online_offer_draw_button'),
                                    onPressed:
                                        game.canOfferDraw(myUserId, _nowMs) &&
                                            !_makingMove
                                        ? () => _onOfferDraw(
                                            game,
                                            myUserId,
                                            myName,
                                          )
                                        : null,
                                    icon: const Icon(
                                      Icons.handshake_rounded,
                                      size: 18,
                                    ),
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
                          if (game.feedbackMessage != null) ...[
                            const SizedBox(height: 6),
                            Builder(
                              builder: (context) {
                                final l10n = AppLocalizations.of(context);
                                final msg = game.feedbackMessage!;
                                String localizedText = msg;
                                if (l10n != null) {
                                  if (msg.contains('pas geçti') || msg.toLowerCase().contains('passed')) {
                                    final name = msg.split(' ').first;
                                    localizedText = l10n.feedbackPassed(name);
                                  } else if (msg.contains('beraberlik teklif etti') || msg.toLowerCase().contains('proposed a draw')) {
                                    final name = msg.split(' ').first;
                                    localizedText = l10n.feedbackDrawProposed(name);
                                  } else if (msg.contains('reddedildi') || msg.toLowerCase().contains('declined')) {
                                    localizedText = l10n.feedbackDrawRejected;
                                  } else if (msg.contains('süresi doldu') || msg.toLowerCase().contains('timed out')) {
                                    localizedText = l10n.feedbackDrawTimeout;
                                  } else if (msg.contains('Süre doldu') || msg.toLowerCase().contains('time expired')) {
                                    localizedText = l10n.feedbackTimeExpired;
                                  }
                                }
                                final isAlert = msg.contains('Yanlış') ||
                                    msg.contains('doldu') ||
                                    msg.contains('reddedildi') ||
                                    msg.toLowerCase().contains('wrong') ||
                                    msg.toLowerCase().contains('declined') ||
                                    msg.toLowerCase().contains('expired');
                                return Text(
                                  localizedText,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: isAlert
                                        ? AppColors.coralRed
                                        : AppColors.electricLime,
                                  ),
                                );
                              },
                            ),
                          ],
                          const SizedBox(height: 8),
                          // Responsive 3x3 Grid OR Inter-Round Summary Overlay
                          Expanded(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Center(child: _buildGrid(game, myUserId)),
                                if (game.isRoundSummary)
                                  _buildInterRoundSummaryCard(
                                    game: game,
                                    myUserId: myUserId,
                                    myName: myName,
                                    oppName: oppName,
                                    myRoundWins: myRoundWins,
                                    oppRoundWins: oppRoundWins,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInterRoundSummaryCard({
    required OnlineGame game,
    required String myUserId,
    required String myName,
    required String oppName,
    required int myRoundWins,
    required int oppRoundWins,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final roundWinner = game.lastRoundWinnerId;
    final didIWinRound = roundWinner == myUserId;
    final isRoundDraw = roundWinner == 'draw' || roundWinner == null;

    final roundResultTitle = isRoundDraw
        ? l10n.roundEndedInDraw(game.roundNumber)
        : didIWinRound
        ? '🏆 ${l10n.roundLabel} ${game.roundNumber} ${l10n.won}: ${l10n.scoreboardYou} ($myName)'
        : '⚽ ${l10n.roundLabel} ${game.roundNumber} ${l10n.won}: $oppName';

    final roundLoserSubtitle = isRoundDraw
        ? l10n.boardFullNoSeries
        : didIWinRound
        ? l10n.loserOpponentAhead(oppName)
        : l10n.loserYouTieNext(myName);

    return Container(
      key: const Key('online_inter_round_summary_card'),
      margin: const EdgeInsets.all(12),
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
              'TUR ${game.roundNumber} TAMAMLANDI',
              style: AppTypography.label(
                fontSize: 11,
                color: AppColors.trophyGold,
                letterSpacing: 0.6,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            roundResultTitle,
            textAlign: TextAlign.center,
            style: AppTypography.modeTitle(
              fontSize: 18,
              color: isRoundDraw
                  ? AppColors.trophyGold
                  : (didIWinRound ? AppColors.electricLime : AppColors.skyBlue),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            roundLoserSubtitle,
            textAlign: TextAlign.center,
            style: AppTypography.description(
              fontSize: 12.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.pitchGreen,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              '${l10n.seriesDraw.split(' ').first} ${l10n.score}:  $myName $myRoundWins  —  $oppRoundWins $oppName',
              style: AppTheme.scoreboardNumberStyle(
                fontSize: 16,
                color: AppColors.warmWhite,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            l10n.nextRoundCountdown(game.roundNumber + 1, _roundSummaryCountdown),
            style: AppTypography.label(
              fontSize: 12,
              color: AppColors.electricLime,
            ),
          ),
          const SizedBox(height: 10),
          ArenaButton(
            key: const Key('online_next_round_button'),
            label: l10n.startNextRound(game.roundNumber + 1),
            icon: Icons.play_arrow_rounded,
            compact: true,
            isLoading: _advancingRound,
            onTap: () => _triggerNextRound(game),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawOfferBanner({
    required OnlineGame game,
    required String myUserId,
    required int remainingSec,
    required AppLocalizations l10n,
  }) {
    final offer = game.drawOffer!;
    final isSender = offer.fromUserId == myUserId;

    return Container(
      key: const Key('online_draw_offer_banner'),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.trophyGold.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.trophyGold, width: 1.5),
      ),
      child: isSender
          ? Row(
              children: [
                const Icon(
                  Icons.handshake_rounded,
                  color: AppColors.trophyGold,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.drawOfferSent(remainingSec),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.handshake_rounded,
                      color: AppColors.trophyGold,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.drawOfferReceived(
                          offer.fromUserName,
                          remainingSec,
                        ),
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      key: const Key('online_reject_draw_button'),
                      onPressed: _makingMove
                          ? null
                          : () => _onRespondToDrawOffer(game, myUserId, false),
                      child: Text(l10n.rejectDraw),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      key: const Key('online_accept_draw_button'),
                      onPressed: _makingMove
                          ? null
                          : () => _onRespondToDrawOffer(game, myUserId, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.electricLime,
                        foregroundColor: AppColors.stadiumNight,
                      ),
                      child: Text(l10n.acceptDraw),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildPlayerBadge({
    required String name,
    required String passesLabel,
    required Color markColor,
    required bool active,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: active
            ? markColor.withValues(alpha: 0.16)
            : AppColors.stadiumNight.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: active ? markColor : AppColors.borderSubtle,
          width: active ? 1.8 : 1.0,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 12.5,
              color: active ? markColor : AppColors.warmWhite,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            passesLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.slateGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(OnlineGame game, String myUserId) {
    if (game.rowTeams.length < 3 || game.colTeams.length < 3) {
      final l10n = AppLocalizations.of(context);
      return Center(child: Text(l10n?.boardLoadFailed ?? 'Tahta yüklenemedi.'));
    }

    final selRow = _selectedCellIndex != null ? _selectedCellIndex! ~/ 3 : null;
    final selCol = _selectedCellIndex != null ? _selectedCellIndex! % 3 : null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final shortest = min(constraints.maxWidth, constraints.maxHeight);
        final boardSize = shortest.clamp(220.0, 560.0);
        final cellSize = boardSize / 4;

        return SizedBox(
          width: boardSize,
          height: boardSize,
          child: Column(
            children: [
              // Header Row
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
                            gradient: AppTheme.stadiumHeroGradient,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border),
                          ),
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.sports_soccer_rounded,
                                color: AppColors.electricLime,
                                size: 22,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'T${game.roundNumber}',
                                style: AppTypography.label(
                                  fontSize: 10,
                                  color: AppColors.trophyGold,
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
                            game.colTeams[c],
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
                            game.rowTeams[r],
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
                            padding: const EdgeInsets.all(3),
                            child: _buildCell(
                              game,
                              r * 3 + c,
                              cellSize,
                              myUserId,
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
    );
  }

  Widget _buildTeamHeader(
    OnlineTeam team,
    double size, {
    bool highlighted = false,
  }) {
    final teamColor = AppTheme.hexToColor(
      team.colorHex,
      AppTheme.surfaceElevated,
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  Color.lerp(AppTheme.surface, teamColor, 0.28)!,
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
              : teamColor.withValues(alpha: 0.55),
          width: highlighted ? 2.2 : 1.4,
        ),
      ),
      padding: const EdgeInsets.all(4),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppTheme.clubCrestWidget(
            logoUrl: team.logoUrl,
            teamName: team.name,
            primaryColorHex: team.colorHex,
            size: (size * 0.42).clamp(20.0, 44.0),
          ),
          const SizedBox(height: 4),
          Flexible(
            child: Text(
              team.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: (size * 0.115).clamp(9.0, 13.0),
                fontWeight: FontWeight.w800,
                height: 1.1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCell(OnlineGame game, int index, double size, String myUserId) {
    final cell = game.board[index];
    final filled = cell != null;
    final isSelected = _selectedCellIndex == index;
    final markColor = cell?.mark == 'X'
        ? AppColors.electricLime
        : AppColors.skyBlue;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: !filled && game.isPlaying && !game.isRoundSummary
            ? () => _onCellTapped(game, index, myUserId)
            : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          decoration: BoxDecoration(
            color: filled
                ? markColor.withValues(alpha: 0.16)
                : isSelected
                ? AppColors.turfGreen.withValues(alpha: 0.45)
                : AppColors.cardBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: filled
                  ? markColor
                  : isSelected
                  ? AppColors.electricLime
                  : AppColors.border,
              width: (filled || isSelected) ? 2.2 : 1.2,
            ),
          ),
          padding: const EdgeInsets.all(4),
          child: !filled
              ? Center(
                  child: Icon(
                    Icons.add_circle_outline_rounded,
                    color: isSelected
                        ? AppColors.electricLime
                        : AppColors.slateGray.withValues(alpha: 0.65),
                    size: (size * 0.28).clamp(18.0, 30.0),
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      cell.mark,
                      style: TextStyle(
                        fontSize: (size * 0.30).clamp(18.0, 34.0),
                        fontWeight: FontWeight.w900,
                        color: markColor,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Flexible(
                      child: Text(
                        cell.playerName,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: (size * 0.105).clamp(8.5, 12.0),
                          fontWeight: FontWeight.w700,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

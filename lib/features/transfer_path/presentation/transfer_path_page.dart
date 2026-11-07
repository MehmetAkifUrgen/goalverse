import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/settings_and_stats_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/freezed/entity_models.dart';
import '../../../data/repositories/web_data_store.dart';
import '../../game/data/online_match_service.dart';
import '../../game/presentation/online_arena_banner.dart';
import '../../game/presentation/online_lobby_dialog.dart';
import '../../game/presentation/player_search_bottom_sheet.dart';

class TransferPathPage extends ConsumerStatefulWidget {
  final String? roomId;
  final bool initialDuel;

  const TransferPathPage({super.key, this.roomId, this.initialDuel = false});

  @override
  ConsumerState<TransferPathPage> createState() => _TransferPathPageState();
}

class _TransferPathPageState extends ConsumerState<TransferPathPage> {
  bool _loading = true;
  String? _error;
  TransferPathPuzzle? _puzzle;

  int _score = 0;
  int _streak = 0;
  int _secondsLeft = 30;
  bool _hintRevealed = false;
  bool _roundOver = false;
  Timer? _timer;

  // 2P Multiplayer Duel State
  bool _isMultiplayer = false;
  int _p1Score = 0;
  int _p2Score = 0;
  int _currentPlayer = 0;
  int _duelTurn = 1;
  int? _roomSeed;
  int _roundCounter = 1;
  static const int _maxDuelTurns = 4;

  @override
  void initState() {
    super.initState();
    _isMultiplayer = widget.initialDuel;
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadNewPuzzle());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _resetDuel() {
    setState(() {
      _p1Score = 0;
      _p2Score = 0;
      _currentPlayer = 0;
      _duelTurn = 1;
      _roundCounter = 1;
      _score = 0;
      _streak = 0;
    });
    _loadNewPuzzle();
  }

  Future<int?> _resolveOnlineSeed(int round) async {
    if (widget.roomId == null) return null;
    if (_roomSeed == null) {
      final game = await ref
          .read(onlineMatchServiceProvider)
          .getGameOnce(widget.roomId!);
      _roomSeed = game?.seed ?? 42;
    }
    return _roomSeed! * 31 + round;
  }

  Future<void> _loadNewPuzzle() async {
    _timer?.cancel();
    setState(() {
      _loading = true;
      _error = null;
      _hintRevealed = false;
      _roundOver = false;
      _secondsLeft = 30;
    });

    try {
      final roundSeed = await _resolveOnlineSeed(_roundCounter++);
      final puzzle = await WebDataStore.instance.getRandomTransferPathPuzzle(
        random: roundSeed != null ? Random(roundSeed) : null,
      );
      if (!mounted) return;
      setState(() {
        _puzzle = puzzle;
        _loading = false;
      });
      _startTimer();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsLeft <= 1) {
        timer.cancel();
        _onTimeOut();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  void _onTimeOut() {
    if (_roundOver || _puzzle == null) return;
    ref.read(appSettingsProvider.notifier).triggerErrorHaptic();
    setState(() {
      _secondsLeft = 0;
      _roundOver = true;
      _streak = 0;
    });
    ref
        .read(userStatsProvider.notifier)
        .recordGameResult(
          won: false,
          score: _isMultiplayer ? _p1Score : _score,
        );
    _showAnswerDialog(
      title: '⏰ Süre Doldu!',
      subtitle: 'Gizemli futbolcu:',
      pointsEarned: 0,
    );
  }

  Future<void> _onGuessPlayer() async {
    if (_puzzle == null || _roundOver) return;

    final selected = await showModalBottomSheet<Player>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const PlayerSearchBottomSheet(),
    );

    if (selected == null || !mounted || _roundOver) return;

    if (selected.id == _puzzle!.player.id ||
        selected.normalizedName == _puzzle!.player.normalizedName) {
      _timer?.cancel();
      ref.read(appSettingsProvider.notifier).triggerSuccessHaptic();
      final basePts = _hintRevealed ? 200 : 350;
      final timeBonus = _secondsLeft * 10;
      final earned = basePts + timeBonus;

      setState(() {
        _roundOver = true;
        if (_isMultiplayer) {
          if (_currentPlayer == 0) {
            _p1Score += earned;
          } else {
            _p2Score += earned;
          }
        } else {
          _score += earned;
          _streak++;
        }
      });

      ref
          .read(userStatsProvider.notifier)
          .recordGameResult(
            won: true,
            score: _isMultiplayer ? _p1Score : _score,
          );

      _showAnswerDialog(
        title: _isMultiplayer
            ? '🎯 Oyuncu ${_currentPlayer + 1} Bildi!'
            : '🎯 Doğru Transfer Rotası!',
        subtitle: '+$earned Puan kazandın!',
        pointsEarned: earned,
      );
    } else {
      ref.read(appSettingsProvider.notifier).triggerErrorHaptic();
      if (_isMultiplayer) {
        setState(() {
          _currentPlayer = (_currentPlayer + 1) % 2;
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isMultiplayer
                ? '❌ ${selected.name} değil! Sıra Oyuncu ${_currentPlayer + 1}\'e geçti.'
                : '❌ ${selected.name} değil! Kulüp geçmişine tekrar bak.',
          ),
          backgroundColor: AppTheme.crimsonAlert,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _giveUp() {
    if (_puzzle == null || _roundOver) return;
    _timer?.cancel();
    setState(() {
      _roundOver = true;
      _streak = 0;
    });
    _showAnswerDialog(
      title: '🏳️ Cevap Açıldı',
      subtitle: 'Bu transfer geçmişinin sahibi:',
      pointsEarned: 0,
    );
  }

  void _advanceDuelOrNext() {
    if (!_isMultiplayer) {
      _loadNewPuzzle();
      return;
    }
    if (_duelTurn >= _maxDuelTurns) {
      AppTheme.showDuelSummaryDialog(
        context: context,
        p1Score: _p1Score,
        p2Score: _p2Score,
        onRematch: _resetDuel,
        onExit: () => context.pop(),
      );
    } else {
      setState(() {
        _duelTurn++;
        _currentPlayer = (_currentPlayer + 1) % 2;
      });
      _loadNewPuzzle();
    }
  }

  void _showAnswerDialog({
    required String title,
    required String subtitle,
    required int pointsEarned,
  }) {
    if (_puzzle == null) return;
    final p = _puzzle!.player;
    final flag = AppTheme.nationalityFlag(p.nationality);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(title, textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(subtitle, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            AppTheme.playerAvatarWidget(
              name: p.name,
              overall: p.eaFcOverall,
              position: p.position,
              size: 64,
            ),
            const SizedBox(height: 10),
            Text(
              p.name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              '$flag ${p.nationality ?? ''} • ${p.position ?? ''} • OVR ${p.eaFcOverall ?? '?'}',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _advanceDuelOrNext();
            },
            child: const Text('Sonraki Kariyer Rotası ➔'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = _puzzle?.player;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transfer Path'),
        actions: [
          AppTheme.onlineRoomButton(
            isOnlineActive: widget.roomId != null,
            onTap: () {
              showDialog(
                context: context,
                builder: (_) =>
                    const OnlineLobbyDialog(initialMode: 'transfer_path'),
              );
            },
          ),
          AppTheme.modeToggleButton(
            isMultiplayer: _isMultiplayer,
            onChanged: (val) {
              setState(() => _isMultiplayer = val);
              _resetDuel();
            },
          ),
          if (!_isMultiplayer)
            Container(
              margin: const EdgeInsets.only(right: 14),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.goldTrophy.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppTheme.goldTrophy.withValues(alpha: 0.35),
                ),
              ),
              child: Text(
                '🏆 $_score  •  🔥 $_streak',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.goldTrophy,
                ),
              ),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text('Hata: $_error'))
          : SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 740),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        OnlineArenaBanner(
                          roomId: widget.roomId,
                          gameMode: 'transfer_path',
                          localScore: _isMultiplayer ? _p1Score : _score,
                          localRound: _isMultiplayer ? _duelTurn : _streak + 1,
                          localFinished: false,
                        ),
                        if (_isMultiplayer)
                          AppTheme.duelScoreboardBanner(
                            p1Score: _p1Score,
                            p2Score: _p2Score,
                            currentPlayer: _currentPlayer,
                            currentTurn: _duelTurn,
                            maxTurns: _maxDuelTurns,
                          ),
                        // Header & Timer
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.cyberCyan.withValues(
                                  alpha: 0.16,
                                ),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppTheme.cyberCyan.withValues(
                                    alpha: 0.4,
                                  ),
                                ),
                              ),
                              child: Text(
                                'ZORLUK: ${_puzzle!.difficulty}',
                                style: const TextStyle(
                                  color: AppTheme.cyberCyan,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _secondsLeft <= 7
                                    ? AppTheme.crimsonAlert
                                    : AppTheme.pitchEmerald.withValues(
                                        alpha: 0.16,
                                      ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _secondsLeft <= 7
                                      ? AppTheme.crimsonAlert
                                      : AppTheme.pitchEmerald,
                                ),
                              ),
                              child: Text(
                                '⏱ $_secondsLeft sn',
                                style: TextStyle(
                                  color: _secondsLeft <= 7
                                      ? Colors.white
                                      : AppTheme.pitchEmerald,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Bu kronolojik transfer geçmişi hangi futbolcuya ait?',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (_hintRevealed && p != null) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.goldTrophy.withValues(
                                alpha: 0.15,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppTheme.goldTrophy.withValues(
                                  alpha: 0.4,
                                ),
                              ),
                            ),
                            child: Text(
                              '💡 İpucu: Mevki ${p.position ?? '?'} • Ülke ${AppTheme.nationalityFlag(p.nationality)} ${p.nationality ?? '?'} • OVR ${p.eaFcOverall ?? '?'}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: AppTheme.goldTrophy,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 14),

                        // Career Stops Timeline with Club Crests
                        Expanded(
                          child: ListView.builder(
                            itemCount: _puzzle!.path.length,
                            itemBuilder: (context, index) {
                              final stop = _puzzle!.path[index];
                              final isLast = index == _puzzle!.path.length - 1;
                              final years =
                                  '${stop.seasonStart ?? '?'} – ${stop.seasonEnd ?? 'Günümüz'}';

                              return Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? AppTheme.surface
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: AppTheme.cyberCyan.withValues(
                                          alpha: 0.35,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 28,
                                          height: 28,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: AppTheme.cyberCyan
                                                .withValues(alpha: 0.18),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Text(
                                            '${index + 1}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w900,
                                              color: AppTheme.cyberCyan,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        AppTheme.clubCrestWidget(
                                          name: stop.team.name,
                                          logoUrl: stop.team.logoUrl,
                                          primaryColorHex:
                                              stop.team.primaryColorHex,
                                          secondaryColorHex:
                                              stop.team.secondaryColorHex,
                                          size: 40,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                stop.team.name,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              Text(
                                                stop.team.country ?? 'Kulüp',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: isDark
                                                      ? Colors.white60
                                                      : Colors.blueGrey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppTheme.pitchEmerald
                                                .withValues(alpha: 0.14),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Text(
                                            years,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 12,
                                              color: AppTheme.pitchEmerald,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (!isLast)
                                    const Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 4,
                                      ),
                                      child: Icon(
                                        Icons.south_rounded,
                                        color: AppTheme.cyberCyan,
                                        size: 20,
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 10),
                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _hintRevealed || _roundOver
                                    ? null
                                    : () =>
                                          setState(() => _hintRevealed = true),
                                icon: const Icon(Icons.lightbulb_outline),
                                label: const Text('İpucu (-150p)'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _roundOver ? null : _giveUp,
                                icon: const Icon(Icons.flag_outlined),
                                label: const Text('Pes Et'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: _roundOver ? null : _onGuessPlayer,
                          icon: const Icon(Icons.search_rounded, size: 22),
                          label: Text(
                            _isMultiplayer
                                ? 'Oyuncu ${_currentPlayer + 1}: Futbolcu Tahmin Et'
                                : 'Futbolcu Ara ve Tahmin Et',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

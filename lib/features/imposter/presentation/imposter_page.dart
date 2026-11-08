import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/settings_and_stats_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/web_data_store.dart';
import '../../../l10n/app_localizations.dart';
import '../../game/data/online_match_service.dart';
import '../../game/presentation/online_arena_banner.dart';
import '../../game/presentation/online_lobby_dialog.dart';

class ImposterPage extends ConsumerStatefulWidget {
  final String? roomId;
  final bool initialDuel;

  const ImposterPage({super.key, this.roomId, this.initialDuel = false});

  @override
  ConsumerState<ImposterPage> createState() => _ImposterPageState();
}

class _ImposterPageState extends ConsumerState<ImposterPage> {
  bool _loading = true;
  String? _error;
  ImposterPuzzle? _puzzle;

  int _score = 0;
  int _streak = 0;
  int _secondsLeft = 12;
  Timer? _timer;

  bool _revealed = false;
  int? _selectedIndex;

  // 2P Multiplayer Duel State
  bool _isMultiplayer = false;
  int _p1Score = 0;
  int _p2Score = 0;
  int _currentPlayer = 0;
  int _duelTurn = 1;
  int? _roomSeed;
  int _roundCounter = 1;
  static const int _maxDuelTurns = 6;

  @override
  void initState() {
    super.initState();
    _isMultiplayer = widget.initialDuel;
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadNextPuzzle());
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
    _loadNextPuzzle();
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

  Future<void> _loadNextPuzzle() async {
    _timer?.cancel();
    final diffSec = ref.read(appSettingsProvider).difficulty == 'easy'
        ? 16
        : (ref.read(appSettingsProvider).difficulty == 'hard' ? 9 : 12);
    setState(() {
      _loading = true;
      _error = null;
      _revealed = false;
      _selectedIndex = null;
      _secondsLeft = diffSec;
    });

    try {
      final roundSeed = await _resolveOnlineSeed(_roundCounter++);
      final puzzle = await WebDataStore.instance.getRandomImposterPuzzle(
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
        _onTimeExpired();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  void _onTimeExpired() {
    if (_revealed) return;
    ref.read(appSettingsProvider.notifier).triggerErrorHaptic();
    setState(() {
      _secondsLeft = 0;
      _revealed = true;
      _streak = 0;
    });
    ref
        .read(userStatsProvider.notifier)
        .recordGameResult(
          won: false,
          score: _isMultiplayer ? _p1Score : _score,
        );
    final l10n = AppLocalizations.of(context);
    _showResultDialog(title: l10n?.timeExpired ?? '⏰ Süre Doldu!', correct: false);
  }

  void _onSelectOption(int index) {
    if (_revealed || _puzzle == null) return;
    _timer?.cancel();
    final l10n = AppLocalizations.of(context);

    final option = _puzzle!.options[index];
    final correct = option.isImposter;
    final earned = correct ? (200 + _secondsLeft * 15 + _streak * 25) : 0;

    if (correct) {
      ref.read(appSettingsProvider.notifier).triggerSuccessHaptic();
    } else {
      ref.read(appSettingsProvider.notifier).triggerErrorHaptic();
    }

    setState(() {
      _selectedIndex = index;
      _revealed = true;
      if (_isMultiplayer) {
        if (correct) {
          if (_currentPlayer == 0) {
            _p1Score += earned;
          } else {
            _p2Score += earned;
          }
        }
      } else {
        if (correct) {
          _score += earned;
          _streak++;
        } else {
          _streak = 0;
        }
      }
    });

    ref
        .read(userStatsProvider.notifier)
        .recordGameResult(
          won: correct,
          score: _isMultiplayer ? _p1Score : _score,
        );

    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      _showResultDialog(
        title: correct
            ? (l10n != null
                ? l10n.imposterCaughtTitle(earned.toString())
                : '🕵️ Ajan Yakalandı! +$earned Puan')
            : (l10n?.imposterWrongSuspect ?? '❌ Yanlış Şüpheli!'),
        correct: correct,
      );
    });
  }

  void _advanceDuelOrNext(bool correct) {
    if (!_isMultiplayer) {
      if (!correct) {
        setState(() => _score = 0);
      }
      _loadNextPuzzle();
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
      _loadNextPuzzle();
    }
  }

  void _showResultDialog({required String title, required bool correct}) {
    if (_puzzle == null) return;
    final imposterPlayer = _puzzle!.options
        .firstWhere(
          (o) => o.isImposter,
          orElse: () => _puzzle!.options.first,
        )
        .player;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final l10n = AppLocalizations.of(ctx);
        return AlertDialog(
          title: Text(title, textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n != null
                    ? l10n.neverPlayedForTeamExplanation(
                        imposterPlayer.name,
                        _puzzle!.targetTeam.name,
                        imposterPlayer.clubs.join(', '),
                      )
                    : _puzzle!.explanation,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 12),
              Text(
                _isMultiplayer
                    ? '${l10n?.scoreboardPlayer1 ?? "Player 1"}: $_p1Score  •  ${l10n?.scoreboardPlayer2 ?? "Player 2"}: $_p2Score'
                    : 'Score: $_score  •  🔥 $_streak',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
          if (!correct && !_isMultiplayer)
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                context.pop();
              },
              child: Text(AppLocalizations.of(context)?.exitAction ?? 'Çıkış'),
            ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _advanceDuelOrNext(correct);
            },
            child: Text(
              _isMultiplayer || correct
                  ? (AppLocalizations.of(context)?.nextMatch ?? 'Sonraki Tur ➔')
                  : (AppLocalizations.of(context)?.playAgainButton ?? 'Tekrar Oyna'),
            ),
          ),
        ],
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.imposterTitle ?? 'Imposter'),
        actions: [
          AppTheme.onlineRoomButton(
            isOnlineActive: widget.roomId != null,
            context: context,
            onTap: () {
              showDialog(
                context: context,
                builder: (_) =>
                    const OnlineLobbyDialog(initialMode: 'imposter'),
              );
            },
          ),
          AppTheme.modeToggleButton(
            isMultiplayer: _isMultiplayer,
            context: context,
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
                          gameMode: 'imposter',
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
                            context: context,
                          ),
                        // Timer Bar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                _isMultiplayer
                                    ? (l10n != null
                                        ? '${l10n.selectPlayerPlayerTurn((_currentPlayer + 1).toString())} - ${l10n.imposterPrompt}'
                                        : 'Oyuncu ${_currentPlayer + 1}: Kulüpte oynamayan ajanı seç!')
                                    : (l10n?.imposterPrompt ?? 'Bu kulüpte HİÇ oynamamış olan futbolcuyu seç:'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _secondsLeft <= 4
                                    ? AppTheme.crimsonAlert
                                    : AppTheme.pitchEmerald.withValues(
                                        alpha: 0.16,
                                      ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _secondsLeft <= 4
                                      ? AppTheme.crimsonAlert
                                      : AppTheme.pitchEmerald,
                                ),
                              ),
                              child: Text(
                                '⏱ $_secondsLeft ${l10n?.secondsSuffix ?? "s"}',
                                style: TextStyle(
                                  color: _secondsLeft <= 4
                                      ? Colors.white
                                      : AppTheme.pitchEmerald,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: (_secondsLeft / 12.0).clamp(0.0, 1.0),
                            minHeight: 7,
                            color: _secondsLeft <= 4
                                ? AppTheme.crimsonAlert
                                : AppTheme.pitchEmerald,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Rule Banner with Club Crest
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.primary.withValues(alpha: 0.25),
                                AppTheme.surfaceSecondary,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppTheme.primary.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Row(
                            children: [
                              AppTheme.clubCrestWidget(
                                name: _puzzle!.targetTeam.name,
                                logoUrl: _puzzle!.targetTeam.logoUrl,
                                primaryColorHex:
                                    _puzzle!.targetTeam.primaryColorHex,
                                secondaryColorHex:
                                    _puzzle!.targetTeam.secondaryColorHex,
                                size: 54,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '🕵️ ${(l10n?.imposterTitle ?? "IMPOSTER").toUpperCase()}',
                                      style: const TextStyle(
                                        color: AppTheme.warning,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.1,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      l10n != null
                                          ? l10n.whichPlayerNeverPlayedFor(
                                              _puzzle!.targetTeam.name,
                                            )
                                          : _puzzle!.ruleDescription,
                                      style: const TextStyle(
                                        color: AppTheme.textPrimary,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w900,
                                        height: 1.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // 4 Suspect Cards (Responsive)
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final cellW = (constraints.maxWidth - 12) / 2;
                              final cellH = ((constraints.maxHeight - 12) / 2)
                                  .clamp(115.0, 220.0);
                              final ratio = (cellW / cellH).clamp(0.85, 2.2);

                              return GridView.builder(
                                itemCount: _puzzle!.options.length,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      mainAxisSpacing: 12,
                                      crossAxisSpacing: 12,
                                      childAspectRatio: ratio,
                                    ),
                                itemBuilder: (context, index) {
                                  final opt = _puzzle!.options[index];
                                  final p = opt.player;
                                  final isSelected = _selectedIndex == index;
                                  final flag = AppTheme.nationalityFlag(
                                    p.nationality,
                                  );

                                  Color borderColor = isDark
                                      ? AppTheme.border
                                      : Colors.black.withValues(alpha: 0.08);
                                  Color cardBg = isDark
                                      ? AppTheme.surface
                                      : Colors.white;

                                  if (_revealed) {
                                    if (opt.isImposter) {
                                      borderColor = AppTheme.pitchEmerald;
                                      cardBg = AppTheme.pitchEmerald.withValues(
                                        alpha: 0.14,
                                      );
                                    } else if (isSelected) {
                                      borderColor = AppTheme.crimsonAlert;
                                      cardBg = AppTheme.crimsonAlert.withValues(
                                        alpha: 0.14,
                                      );
                                    }
                                  }

                                  return InkWell(
                                    onTap: () => _onSelectOption(index),
                                    borderRadius: BorderRadius.circular(18),
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 220,
                                      ),
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: cardBg,
                                        borderRadius: BorderRadius.circular(18),
                                        border: Border.all(
                                          color: borderColor,
                                          width:
                                              _revealed &&
                                                  (opt.isImposter || isSelected)
                                              ? 2.5
                                              : 1.2,
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          AppTheme.playerAvatarWidget(
                                            name: p.name,
                                            overall: p.eaFcOverall,
                                            position: p.position,
                                            size: cellH < 145 ? 42 : 52,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            p.name,
                                            textAlign: TextAlign.center,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '$flag ${p.nationality ?? ''} • ${p.position ?? 'FW'}',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: isDark
                                                  ? Colors.white60
                                                  : Colors.blueGrey,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          if (_revealed) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              opt.isImposter
                                                  ? (l10n?.imposterBadgeNeverPlayed ?? '🕵️ AJAN! Hiç Oynamadı')
                                                  : '✅ ${_puzzle!.targetTeam.name}',
                                              textAlign: TextAlign.center,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w900,
                                                color: opt.isImposter
                                                    ? AppTheme.pitchEmerald
                                                    : Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
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

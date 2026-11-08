import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers.dart';
import '../../../core/providers/settings_and_stats_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/clue_localizer.dart';
import '../../../data/models/freezed/entity_models.dart';
import '../../../l10n/app_localizations.dart';
import '../../game/data/online_match_service.dart';
import '../../game/presentation/online_arena_banner.dart';
import '../../game/presentation/online_lobby_dialog.dart';
import '../../game/presentation/player_search_bottom_sheet.dart';

class WhoAmIPage extends ConsumerStatefulWidget {
  final String? roomId;
  final bool initialDuel;

  const WhoAmIPage({super.key, this.roomId, this.initialDuel = false});

  @override
  ConsumerState<WhoAmIPage> createState() => _WhoAmIPageState();
}

class _WhoAmIPageState extends ConsumerState<WhoAmIPage> {
  bool _loading = true;
  String? _error;
  Player? _mysteryPlayer;
  int _unlockedCluesCount = 1;
  int _strikes = 0;
  int _score = 0;
  int _soloRound = 1;
  bool _isGameOver = false;

  // 2P Multiplayer Duel State
  bool _isMultiplayer = false;
  int _p1Score = 0;
  int _p2Score = 0;
  int _currentPlayer = 0;
  int _duelTurn = 1;
  static const int _maxDuelTurns = 4;

  int? _roomSeed;
  int _roundCounter = 1;

  @override
  void initState() {
    super.initState();
    _isMultiplayer = widget.initialDuel;
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadMysteryPlayer());
  }

  void _resetDuel() {
    setState(() {
      _p1Score = 0;
      _p2Score = 0;
      _currentPlayer = 0;
      _duelTurn = 1;
      _roundCounter = 1;
      _score = 0;
      _soloRound = 1;
    });
    _loadMysteryPlayer();
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

  Future<void> _loadMysteryPlayer() async {
    setState(() {
      _loading = true;
      _error = null;
      _unlockedCluesCount = 1;
      _strikes = 0;
      _isGameOver = false;
    });

    try {
      final isarAsync = ref.read(isarDatabaseProvider.future);
      await isarAsync;
      final playerRepo = ref.read(playerRepositoryProvider);
      final roundSeed = await _resolveOnlineSeed(_roundCounter++);

      final player = await playerRepo.getRandomWhoAmI(seed: roundSeed);
      if (player == null) {
        throw StateError('İpucu verisi olan futbolcu bulunamadı.');
      }

      setState(() {
        _mysteryPlayer = player;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _unlockNextClue() {
    if (_mysteryPlayer == null) return;
    final totalClues = _mysteryPlayer!.clues.length;
    if (_unlockedCluesCount < totalClues) {
      setState(() {
        _unlockedCluesCount++;
      });
    }
  }

  void _advanceDuelOrNext() {
    if (!_isMultiplayer) {
      _loadMysteryPlayer();
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
      _loadMysteryPlayer();
    }
  }

  Future<void> _onGuess() async {
    if (_mysteryPlayer == null || _isGameOver) return;

    final selected = await showModalBottomSheet<Player>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const PlayerSearchBottomSheet(),
    );

    if (selected == null || !mounted) return;

    if (selected.id == _mysteryPlayer!.id ||
        selected.normalizedName == _mysteryPlayer!.normalizedName) {
      ref.read(appSettingsProvider.notifier).triggerSuccessHaptic();
      final pointsEarned = _calculatePoints();
      setState(() {
        if (_isMultiplayer) {
          if (_currentPlayer == 0) {
            _p1Score += pointsEarned;
          } else {
            _p2Score += pointsEarned;
          }
        } else {
          _score += pointsEarned;
        }
        _isGameOver = true;
      });
      ref
          .read(userStatsProvider.notifier)
          .recordGameResult(
            won: true,
            score: _isMultiplayer ? _p1Score : _score,
            isPerfect: _unlockedCluesCount == 1,
          );
      _showSuccessDialog(pointsEarned);
    } else {
      ref.read(appSettingsProvider.notifier).triggerErrorHaptic();
      setState(() {
        _strikes++;
        if (_strikes >= 3) {
          _isGameOver = true;
        } else if (_isMultiplayer) {
          // In 2P mode, wrong guess unlocks next clue and passes turn to other player!
          if (_unlockedCluesCount < _mysteryPlayer!.clues.length) {
            _unlockedCluesCount++;
          }
          _currentPlayer = (_currentPlayer + 1) % 2;
        }
      });

      if (_strikes >= 3) {
        ref
            .read(userStatsProvider.notifier)
            .recordGameResult(
              won: false,
              score: _isMultiplayer ? _p1Score : _score,
            );
        _showGameOverDialog();
      } else {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isMultiplayer
                  ? (l10n != null
                      ? l10n.wrongPlayerNextTurn(selected.name, (_currentPlayer + 1).toString())
                      : '❌ ${selected.name} değil! Sıra Oyuncu ${_currentPlayer + 1}\'e geçti.')
                  : (l10n != null
                      ? '❌ ${selected.name} ${l10n.wrongGuess}! ($_strikes/3)'
                      : '❌ ${selected.name} değil! Hata: $_strikes/3'),
            ),
            backgroundColor: AppTheme.crimsonStrike,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  int _calculatePoints() {
    switch (_unlockedCluesCount) {
      case 1:
        return 1000;
      case 2:
        return 750;
      case 3:
        return 500;
      case 4:
        return 350;
      default:
        return 250;
    }
  }

  void _showSuccessDialog(int points) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(
            _isMultiplayer
                ? (l10n != null
                    ? l10n.playerGuessedCorrect(_currentPlayer + 1, points)
                    : '🎯 Oyuncu ${_currentPlayer + 1} Bildi!')
                : (l10n != null
                    ? l10n.greatGuessSolo(points)
                    : '🎯 TAM İSABET!'),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTheme.playerAvatarWidget(
                name: _mysteryPlayer!.name,
                overall: _mysteryPlayer!.eaFcOverall,
                position: _mysteryPlayer!.position,
                nationality: _mysteryPlayer!.nationality,
                size: 64,
              ),
              const SizedBox(height: 12),
              Text(
                _mysteryPlayer!.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '+$points Pts',
                style: const TextStyle(
                  fontSize: 17,
                  color: AppTheme.accentEmerald,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                _advanceDuelOrNext();
              },
              icon: const Icon(Icons.arrow_forward_rounded),
              label: Text(l10n?.nextMatch ?? 'Sonraki Futbolcu'),
            ),
          ],
        );
      },
    );
  }

  void _showGameOverDialog() {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(
            l10n?.duelFinished ?? '❌ 3 Hata! Tur Bitti',
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n?.whoAmITitle ?? 'Gizemli futbolcu:'),
              const SizedBox(height: 10),
              AppTheme.playerAvatarWidget(
                name: _mysteryPlayer!.name,
                overall: _mysteryPlayer!.eaFcOverall,
                position: _mysteryPlayer!.position,
                nationality: _mysteryPlayer!.nationality,
                size: 60,
              ),
              const SizedBox(height: 8),
              Text(
                _mysteryPlayer!.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                _advanceDuelOrNext();
              },
              icon: const Icon(Icons.replay_rounded),
              label: Text(l10n?.nextMatch ?? 'Sonraki Futbolcu'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final clues = _mysteryPlayer?.clues ?? const [];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.whoAmITitle ?? 'Ben Kimim?'),
        actions: [
          AppTheme.onlineRoomButton(
            isOnlineActive: widget.roomId != null,
            context: context,
            onTap: () {
              showDialog(
                context: context,
                builder: (_) =>
                    const OnlineLobbyDialog(initialMode: 'who_am_i'),
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
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.trophyGold.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _isMultiplayer
                      ? '❌ $_strikes/3'
                      : '🏆 $_score  •  ❌ $_strikes/3',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.trophyGold,
                  ),
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
              child: Text(
                l10n != null ? '${l10n.errorTitle}: $_error' : 'Error: $_error',
              ),
            )
          : SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        OnlineArenaBanner(
                          roomId: widget.roomId,
                          gameMode: 'who_am_i',
                          localScore: _isMultiplayer ? _p1Score : _score,
                          localRound: _isMultiplayer ? _duelTurn : _soloRound,
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
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 18,
                          ),
                          decoration: BoxDecoration(
                            gradient: AppTheme.stadiumHeroGradient,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: AppTheme.trophyGold.withValues(
                                alpha: 0.45,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.psychology_alt_rounded,
                                    color: AppTheme.trophyGold,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    l10n?.potentialPoints ?? 'Olası Ödül Puanı:',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  gradient: AppTheme.goldGradient,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${_calculatePoints()} PTS',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: ListView.builder(
                            itemCount: clues.length,
                            itemBuilder: (context, index) {
                              final isUnlocked = index < _unlockedCluesCount;
                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                  color: isUnlocked
                                      ? AppTheme.accentEmerald.withValues(
                                          alpha: 0.10,
                                        )
                                      : Theme.of(context).cardTheme.color,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isUnlocked
                                        ? AppTheme.accentEmerald.withValues(
                                            alpha: 0.55,
                                          )
                                        : Theme.of(context).dividerColor,
                                    width: isUnlocked ? 1.5 : 1,
                                  ),
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: isUnlocked
                                        ? AppTheme.accentEmerald
                                        : Theme.of(
                                            context,
                                          ).colorScheme.surfaceContainerHighest,
                                    child: Text(
                                      '${index + 1}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        color: isUnlocked
                                            ? Colors.black
                                            : Theme.of(
                                                context,
                                              ).colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                  title: isUnlocked
                                      ? Text(
                                          ClueLocalizer.getClue(
                                            _mysteryPlayer!,
                                            index,
                                            context,
                                          ),
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        )
                                      : Text(
                                          l10n?.lockedClue ?? '🔒 Kilitli İpucu',
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                ),
                              );
                            },
                          ),
                        ),
                        if (_unlockedCluesCount < clues.length &&
                            !_isGameOver) ...[
                          OutlinedButton.icon(
                            onPressed: _unlockNextClue,
                            icon: const Icon(Icons.lock_open_rounded),
                            label: Text(
                              l10n != null
                                  ? l10n.unlockNextClueRemaining((clues.length - _unlockedCluesCount).toString())
                                  : 'Sonraki İpucunu Aç (Kalan: ${clues.length - _unlockedCluesCount})',
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                        ElevatedButton.icon(
                          onPressed: _isGameOver ? null : _onGuess,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.trophyGold,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          icon: const Icon(Icons.sports_soccer_rounded),
                          label: Text(
                            _isMultiplayer
                                ? (l10n != null
                                    ? l10n.selectPlayerPlayerTurn(
                                        (_currentPlayer + 1).toString(),
                                      )
                                    : 'Player ${_currentPlayer + 1}: Guess')
                                : (l10n?.guessMysteryPlayer ?? 'Guess Footballer'),
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
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

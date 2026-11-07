import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers.dart';
import '../../../core/providers/settings_and_stats_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/stadium_visuals.dart';
import '../../../data/models/freezed/entity_models.dart';
import '../../../data/repositories/rating_category.dart';
import '../../game/data/online_match_service.dart';
import '../../game/presentation/online_arena_banner.dart';
import '../../game/presentation/online_lobby_dialog.dart';

class RatingBattlePage extends ConsumerStatefulWidget {
  final String? roomId;
  final bool initialDuel;

  const RatingBattlePage({super.key, this.roomId, this.initialDuel = false});

  @override
  ConsumerState<RatingBattlePage> createState() => _RatingBattlePageState();
}

class _RatingBattlePageState extends ConsumerState<RatingBattlePage> {
  bool _loading = true;
  String? _error;
  Player? _playerA;
  Player? _playerB;
  RatingCategory _currentCategory = RatingCategory.eaFcOverall;
  int _streak = 0;
  int _bestStreak = 0;
  bool _revealed = false;
  bool? _lastGuessCorrect;

  // 2P Multiplayer Duel State
  bool _isMultiplayer = false;
  int _p1Score = 0;
  int _p2Score = 0;
  int _currentPlayer = 0; // 0: P1, 1: P2
  int _duelTurn = 1;
  int _roundCounter = 1;
  int? _roomSeed;
  bool _onlineFinished = false;
  static const int _maxDuelTurns = 6;

  @override
  void initState() {
    super.initState();
    _isMultiplayer = widget.initialDuel;
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadNextPair());
  }

  void _resetDuel() {
    setState(() {
      _p1Score = 0;
      _p2Score = 0;
      _currentPlayer = 0;
      _duelTurn = 1;
      _roundCounter = 1;
      _streak = 0;
      _onlineFinished = false;
    });
    _loadNextPair();
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

  Future<void> _loadNextPair({bool keepPlayerB = false}) async {
    setState(() {
      _loading = true;
      _revealed = false;
      _lastGuessCorrect = null;
    });

    try {
      final isarAsync = ref.read(isarDatabaseProvider.future);
      await isarAsync;
      final playerRepo = ref.read(playerRepositoryProvider);
      final roundSeed = await _resolveOnlineSeed(_roundCounter++);

      final categories = [
        RatingCategory.eaFcOverall,
        RatingCategory.marketValue,
        RatingCategory.goalsCareer,
        RatingCategory.speed,
        RatingCategory.assistsCareer,
        RatingCategory.clGoals,
      ];
      final nextCat =
          categories[(_isMultiplayer
                  ? _duelTurn
                  : (widget.roomId != null ? _roundCounter : _streak)) %
              categories.length];

      final pair = await playerRepo.getRandomRatingPair(
        category: nextCat,
        seed: roundSeed,
      );

      setState(() {
        _currentCategory = nextCat;
        if (keepPlayerB && _playerB != null && widget.roomId == null) {
          _playerA = _playerB;
          _playerB = pair.$2.id != _playerA!.id ? pair.$2 : pair.$1;
        } else {
          _playerA = pair.$1;
          _playerB = pair.$2;
        }
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _onGuess({required bool guessHigher}) {
    if (_playerA == null || _playerB == null || _revealed) return;

    final valA = _currentCategory.valueOf(_playerA!) ?? 0;
    final valB = _currentCategory.valueOf(_playerB!) ?? 0;

    final bool isHigherOrEqual = valB >= valA;
    final bool isLowerOrEqual = valB <= valA;

    final bool correct = guessHigher ? isHigherOrEqual : isLowerOrEqual;
    final settingsNotifier = ref.read(appSettingsProvider.notifier);
    if (correct) {
      settingsNotifier.triggerSuccessHaptic();
    } else {
      settingsNotifier.triggerErrorHaptic();
    }

    setState(() {
      _revealed = true;
      _lastGuessCorrect = correct;
      if (_isMultiplayer) {
        if (correct) {
          if (_currentPlayer == 0) {
            _p1Score += 150;
          } else {
            _p2Score += 150;
          }
        }
      } else {
        if (correct) {
          _streak++;
          if (_streak > _bestStreak) _bestStreak = _streak;
        }
      }
    });

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      if (_isMultiplayer) {
        if (_duelTurn >= _maxDuelTurns) {
          ref
              .read(userStatsProvider.notifier)
              .recordGameResult(
                won: _p1Score > _p2Score,
                draw: _p1Score == _p2Score,
                score: _p1Score,
              );
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
          _loadNextPair(keepPlayerB: true);
        }
      } else {
        if (correct) {
          _loadNextPair(keepPlayerB: true);
        } else {
          setState(() => _onlineFinished = true);
          ref
              .read(userStatsProvider.notifier)
              .recordGameResult(won: _streak >= 3, score: _streak * 150);
          _showGameOverDialog();
        }
      }
    });
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Düello Bitti!',
            textAlign: TextAlign.center,
            style: AppTypography.sectionTitle(fontSize: 24),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$_streak',
                style: AppTypography.scoreLarge(
                  fontSize: 48,
                  color: AppColors.primary,
                ),
              ),
              Text('Doğru Tahmin Serisi', style: AppTypography.description()),
              const SizedBox(height: 12),
              Text(
                'En İyi Seri: $_bestStreak  •  +${_streak * 150} Puan',
                style: AppTypography.statValue(
                  fontSize: 15,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            SecondaryButton(
              label: 'Çıkış',
              onTap: () {
                Navigator.of(context).pop();
                context.pop();
              },
            ),
            ArenaButton(
              label: 'Tekrar Oyna',
              icon: Icons.replay_rounded,
              onTap: () {
                Navigator.of(context).pop();
                setState(() => _streak = 0);
                _loadNextPair();
              },
            ),
          ],
        );
      },
    );
  }

  String _formatStat(int? val) {
    if (val == null) return '-';
    if (_currentCategory == RatingCategory.marketValue) {
      if (val >= 1000000) {
        return '€${(val / 1000000).toStringAsFixed(0)}M';
      }
      return '€${(val / 1000).toStringAsFixed(0)}K';
    }
    return val.toString();
  }

  String _getCategoryTitle() {
    switch (_currentCategory) {
      case RatingCategory.eaFcOverall:
        return 'EA FC Overall Reytingi';
      case RatingCategory.marketValue:
        return 'Zirve Piyasa Değeri';
      case RatingCategory.goalsCareer:
        return 'Kariyer Gol Sayısı';
      case RatingCategory.assistsCareer:
        return 'Kariyer Asist Sayısı';
      case RatingCategory.speed:
        return 'Hız / Sprint Reytingi';
      case RatingCategory.clGoals:
        return 'Şampiyonlar Ligi Golleri';
      case RatingCategory.age:
      case RatingCategory.ageLOW:
        return 'Futbolcu Yaşı';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rating Battle'),
        actions: [
          AppTheme.onlineRoomButton(
            isOnlineActive: widget.roomId != null,
            onTap: () {
              showDialog(
                context: context,
                builder: (_) =>
                    const OnlineLobbyDialog(initialMode: 'rating_battle'),
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
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: AppRadius.pillBorder,
                    border: Border.all(
                      color: AppColors.warning.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_fire_department_rounded,
                        size: 15,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Seri: $_streak',
                        style: AppTypography.statValue(
                          fontSize: 13,
                          color: AppColors.foreground,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      body: StadiumPitchBackground(
        child: _loading && _playerA == null
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(child: Text('Hata: $_error'))
            : SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 960),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        children: [
                          OnlineArenaBanner(
                            roomId: widget.roomId,
                            gameMode: 'rating_battle',
                            localScore: _isMultiplayer
                                ? _p1Score
                                : _streak * 150,
                            localRound: _isMultiplayer
                                ? _duelTurn
                                : _streak + 1,
                            localFinished: _onlineFinished,
                          ),
                          if (_isMultiplayer)
                            AppTheme.duelScoreboardBanner(
                              p1Score: _p1Score,
                              p2Score: _p2Score,
                              currentPlayer: _currentPlayer,
                              currentTurn: _duelTurn,
                              maxTurns: _maxDuelTurns,
                            ),
                          // Category Broadcast Pill
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 11,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.surface
                                  : AppColors.lightSurface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isDark
                                    ? AppColors.border
                                    : AppColors.lightBorder,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.equalizer_rounded,
                                  size: 18,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'KARŞILAŞTIRILAN İSTATİSTİK: ${_getCategoryTitle().toUpperCase()}',
                                  style: AppTypography.label(
                                    fontSize: 12,
                                    color: isDark
                                        ? AppColors.foreground
                                        : AppColors.lightTextPrimary,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final isWide = constraints.maxWidth > 620;
                                if (isWide) {
                                  return Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Expanded(child: _buildPlayerACard()),
                                      const _VsBadgeSeparator(
                                        isHorizontal: true,
                                      ),
                                      Expanded(child: _buildPlayerBCard()),
                                    ],
                                  );
                                }
                                return Column(
                                  children: [
                                    Expanded(child: _buildPlayerACard()),
                                    const _VsBadgeSeparator(
                                      isHorizontal: false,
                                    ),
                                    Expanded(child: _buildPlayerBCard()),
                                  ],
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
      ),
    );
  }

  Widget _buildPlayerACard() {
    final p = _playerA;
    if (p == null) return const SizedBox();
    final stat = _formatStat(_currentCategory.valueOf(p));
    final flag = AppTheme.nationalityFlag(p.nationality);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? AppColors.border : AppColors.lightBorder,
        ),
        boxShadow: isDark ? AppShadows.card : null,
      ),
      padding: const EdgeInsets.all(16),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // FUT Card Top Meta Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _FutMetaPill(
                    label: p.position ?? 'FW',
                    accentColor: AppColors.cyberCyan,
                  ),
                  const SizedBox(width: 8),
                  _FutMetaPill(
                    label: '$flag ${p.nationality ?? ''}',
                    accentColor: AppColors.muted,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              AppTheme.playerAvatarWidget(
                name: p.name,
                overall: p.eaFcOverall,
                position: p.position,
                nationality: p.nationality,
                size: 66,
              ),
              const SizedBox(height: 10),
              Text(
                p.name,
                style: AppTypography.modeTitle(
                  fontSize: 24,
                  color: isDark
                      ? AppColors.foreground
                      : AppColors.lightTextPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 26,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.surfaceElevated
                      : AppColors.lightSurfaceElevated,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.cyberCyan.withValues(alpha: 0.45),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      stat,
                      style: AppTypography.scoreLarge(
                        fontSize: 34,
                        color: AppColors.cyberCyan,
                      ),
                    ),
                    Text(
                      _getCategoryTitle(),
                      style: AppTypography.label(
                        fontSize: 10.5,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerBCard() {
    final p = _playerB;
    if (p == null) return const SizedBox();
    final actualStat = _formatStat(_currentCategory.valueOf(p));
    final flag = AppTheme.nationalityFlag(p.nationality);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color borderColor = isDark ? AppColors.border : AppColors.lightBorder;
    if (_revealed) {
      borderColor = _lastGuessCorrect == true
          ? AppColors.success
          : AppColors.error;
    }

    return AnimatedContainer(
      duration: AppMotion.normal,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor, width: _revealed ? 2.0 : 1.0),
        boxShadow: isDark ? AppShadows.card : null,
      ),
      padding: const EdgeInsets.all(16),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _FutMetaPill(
                    label: p.position ?? 'FW',
                    accentColor: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  _FutMetaPill(
                    label: '$flag ${p.nationality ?? ''}',
                    accentColor: AppColors.muted,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              AppTheme.playerAvatarWidget(
                name: p.name,
                overall: _revealed ? p.eaFcOverall : null,
                position: p.position,
                nationality: p.nationality,
                size: 66,
              ),
              const SizedBox(height: 10),
              Text(
                p.name,
                style: AppTypography.modeTitle(
                  fontSize: 24,
                  color: isDark
                      ? AppColors.foreground
                      : AppColors.lightTextPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              AnimatedSwitcher(
                duration: AppMotion.normal,
                child: _revealed
                    ? Container(
                        key: const ValueKey('revealed_stat'),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 26,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color:
                              (_lastGuessCorrect == true
                                      ? AppColors.success
                                      : AppColors.error)
                                  .withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _lastGuessCorrect == true
                                ? AppColors.success
                                : AppColors.error,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              actualStat,
                              style: AppTypography.scoreLarge(
                                fontSize: 34,
                                color: _lastGuessCorrect == true
                                    ? AppColors.success
                                    : AppColors.error,
                              ),
                            ),
                            Text(
                              _lastGuessCorrect == true
                                  ? 'DOĞRU TAHMİN!'
                                  : 'YANLIŞ TAHMİN',
                              style: AppTypography.label(
                                fontSize: 10.5,
                                color: _lastGuessCorrect == true
                                    ? AppColors.success
                                    : AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Wrap(
                        key: const ValueKey('guess_buttons'),
                        spacing: 12,
                        runSpacing: 10,
                        alignment: WrapAlignment.center,
                        children: [
                          PressableScale(
                            onTap: () => _onGuess(guessHigher: true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.trending_up_rounded,
                                    size: 18,
                                    color: AppColors.primaryText,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Daha Yüksek',
                                    style: AppTypography.button(
                                      fontSize: 14,
                                      color: AppColors.primaryText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          PressableScale(
                            onTap: () => _onGuess(guessHigher: false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceElevated,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: AppColors.error.withValues(alpha: 0.6),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.trending_down_rounded,
                                    size: 18,
                                    color: AppColors.error,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Daha Düşük',
                                    style: AppTypography.button(
                                      fontSize: 14,
                                      color: AppColors.foreground,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FutMetaPill extends StatelessWidget {
  final String label;
  final Color accentColor;

  const _FutMetaPill({required this.label, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceElevated
            : AppColors.lightSurfaceElevated,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: AppTypography.label(fontSize: 11, color: accentColor),
      ),
    );
  }
}

class _VsBadgeSeparator extends StatelessWidget {
  final bool isHorizontal;

  const _VsBadgeSeparator({required this.isHorizontal});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isHorizontal ? 10 : 0,
        vertical: isHorizontal ? 0 : 8,
      ),
      child: Center(
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border),
          ),
          child: Center(
            child: Text(
              'VS',
              style: AppTypography.modeTitle(
                fontSize: 14,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

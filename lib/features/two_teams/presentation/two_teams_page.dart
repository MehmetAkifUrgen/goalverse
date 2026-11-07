import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers.dart';
import '../../../core/providers/settings_and_stats_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/freezed/entity_models.dart';
import '../../game/data/online_match_service.dart';
import '../../game/presentation/online_arena_banner.dart';
import '../../game/presentation/online_lobby_dialog.dart';
import '../../game/presentation/player_search_bottom_sheet.dart';

class TwoTeamsPage extends ConsumerStatefulWidget {
  final String? roomId;
  final bool initialDuel;

  const TwoTeamsPage({super.key, this.roomId, this.initialDuel = false});

  @override
  ConsumerState<TwoTeamsPage> createState() => _TwoTeamsPageState();
}

class _TwoTeamsPageState extends ConsumerState<TwoTeamsPage> {
  bool _loading = true;
  String? _error;
  Team? _teamA;
  Team? _teamB;
  int _candidateCount = 0;
  int _score = 0;
  int _streak = 0;
  int _soloRound = 1;
  List<Player> _revealedAnswers = const [];
  bool _puzzleSolved = false;

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
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadNewPuzzle());
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
      _soloRound = 1;
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
    setState(() {
      _loading = true;
      _error = null;
      _revealedAnswers = const [];
      _puzzleSolved = false;
    });

    try {
      final isarAsync = ref.read(isarDatabaseProvider.future);
      await isarAsync;
      final teamRepo = ref.read(teamRepositoryProvider);
      final validator = ref.read(answerValidatorRepositoryProvider);
      final roundSeed = await _resolveOnlineSeed(_roundCounter++);

      final pairs = await teamRepo.getTeamPairsWithMinPlayers(
        minPlayersPerPair: 2,
        limit: 40,
        seed: roundSeed,
      );
      if (pairs.isEmpty) {
        throw StateError('Eşleşen takım çifti bulunamadı.');
      }

      if (roundSeed == null) {
        pairs.shuffle();
      }
      final pair = pairs.first;
      final validIds = await validator.getPlayersForTeamPair(
        pair.$1.id,
        pair.$2.id,
      );

      setState(() {
        _teamA = pair.$1;
        _teamB = pair.$2;
        _candidateCount = validIds.length;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _onPickPlayer() async {
    if (_teamA == null || _teamB == null || _puzzleSolved) return;

    final selected = await showModalBottomSheet<Player>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const PlayerSearchBottomSheet(),
    );

    if (selected == null || !mounted) return;

    final validator = ref.read(answerValidatorRepositoryProvider);
    final isValid = await validator.isPlayerInTeamPair(
      selected.id,
      _teamA!.id,
      _teamB!.id,
    );
    if (!mounted) return;

    if (isValid) {
      ref.read(appSettingsProvider.notifier).triggerSuccessHaptic();
      setState(() {
        _puzzleSolved = true;
        if (_isMultiplayer) {
          if (_currentPlayer == 0) {
            _p1Score += 250;
          } else {
            _p2Score += 250;
          }
        } else {
          _score += 250;
          _streak += 1;
        }
      });
      ref
          .read(userStatsProvider.notifier)
          .recordGameResult(
            won: true,
            score: _isMultiplayer ? _p1Score : _score,
            isRare: _candidateCount <= 4,
          );
      _showSuccessDialog(selected);
    } else {
      ref.read(appSettingsProvider.notifier).triggerErrorHaptic();
      if (_isMultiplayer) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '❌ ${selected.name} her iki kulüpte oynamadı! Sıra diğer oyuncuya geçti.',
            ),
            backgroundColor: AppTheme.crimsonStrike,
            behavior: SnackBarBehavior.floating,
          ),
        );
        _advanceDuelTurn();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '❌ ${selected.name} hem ${_teamA!.name} hem ${_teamB!.name} forması giymedi!',
            ),
            backgroundColor: AppTheme.crimsonStrike,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _advanceDuelTurn() {
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

  Future<void> _revealAnswers() async {
    if (_teamA == null || _teamB == null) return;
    final validator = ref.read(answerValidatorRepositoryProvider);
    final playerRepo = ref.read(playerRepositoryProvider);

    final playerIds = await validator.getPlayersForTeamPair(
      _teamA!.id,
      _teamB!.id,
    );
    final players = await playerRepo.getByIds(playerIds);

    setState(() {
      _revealedAnswers = players;
      _streak = 0;
    });
  }

  void _showSuccessDialog(Player player) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(
            _isMultiplayer
                ? '🎉 Oyuncu ${_currentPlayer + 1} Bildi! +250 Puan'
                : '🎉 Harika Tahmin! +250 Puan',
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTheme.playerAvatarWidget(
                name: player.name,
                overall: player.eaFcOverall,
                position: player.position,
                nationality: player.nationality,
                size: 64,
              ),
              const SizedBox(height: 12),
              Text(
                player.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'hem ${_teamA!.name} hem de ${_teamB!.name} kulüplerinde oynadı!',
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                if (_isMultiplayer) {
                  _advanceDuelTurn();
                } else {
                  _loadNewPuzzle();
                }
              },
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('Sonraki Eşleşme'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('2 Takım 1 Oyuncu'),
        actions: [
          AppTheme.onlineRoomButton(
            isOnlineActive: widget.roomId != null,
            onTap: () {
              showDialog(
                context: context,
                builder: (_) =>
                    const OnlineLobbyDialog(initialMode: 'two_teams'),
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
                    color: AppTheme.accentEmerald.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '🏆 $_score  •  🔥 $_streak',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.accentEmerald,
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
          ? Center(child: Text('Hata: $_error'))
          : SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        OnlineArenaBanner(
                          roomId: widget.roomId,
                          gameMode: 'two_teams',
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
                          ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            gradient: AppTheme.stadiumHeroGradient,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'İki kulübün formasını da giyen futbolcuyu bul!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              if (_candidateCount > 0) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Veritabanında bu iki kulüpte oynayan $_candidateCount yıldız var',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.accentEmerald,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),
                        Row(
                          children: [
                            Expanded(child: _buildTeamCard(_teamA!)),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: AppTheme.goldGradient,
                                ),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.compare_arrows_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                            Expanded(child: _buildTeamCard(_teamB!)),
                          ],
                        ),
                        const SizedBox(height: 26),
                        ElevatedButton.icon(
                          onPressed: _puzzleSolved ? null : _onPickPlayer,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          icon: const Icon(Icons.search_rounded, size: 22),
                          label: Text(
                            _isMultiplayer
                                ? 'Oyuncu ${_currentPlayer + 1}: Futbolcu Seç'
                                : 'Futbolcu Ara & Seç',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _revealedAnswers.isEmpty
                                    ? _revealAnswers
                                    : null,
                                icon: const Icon(
                                  Icons.visibility_outlined,
                                  size: 18,
                                ),
                                label: const Text('Cevapları Göster'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _isMultiplayer
                                    ? _advanceDuelTurn
                                    : _loadNewPuzzle,
                                icon: const Icon(
                                  Icons.skip_next_rounded,
                                  size: 18,
                                ),
                                label: Text(
                                  _isMultiplayer
                                      ? 'Turu Pas Geç'
                                      : 'Yeni Eşleşme',
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_revealedAnswers.isNotEmpty) ...[
                          const SizedBox(height: 22),
                          Text(
                            'Ortak Futbolcular (${_revealedAnswers.length}):',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ..._revealedAnswers.map((p) {
                            final flag = AppTheme.nationalityFlag(
                              p.nationality,
                            );
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Card(
                                child: ListTile(
                                  leading: AppTheme.playerAvatarWidget(
                                    name: p.name,
                                    overall: p.eaFcOverall,
                                    position: p.position,
                                    nationality: p.nationality,
                                    size: 40,
                                  ),
                                  title: Text(
                                    p.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '$flag ${p.nationality ?? ''} • ${p.position ?? ''}',
                                  ),
                                  trailing: p.eaFcOverall != null
                                      ? Text(
                                          '${p.eaFcOverall} OVR',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            color: AppTheme.accentEmerald,
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                            );
                          }),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildTeamCard(Team team) {
    final color = AppTheme.hexToColor(
      team.primaryColorHex,
      AppTheme.surfaceElevated,
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 175,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  Color.lerp(AppTheme.surface, color, 0.35)!,
                  AppTheme.surfaceSecondary,
                ]
              : [Color.lerp(Colors.white, color, 0.2)!, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withValues(alpha: 0.65), width: 1.8),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.22),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppTheme.clubCrestWidget(
            logoUrl: team.logoUrl,
            teamName: team.name,
            primaryColorHex: team.primaryColorHex,
            size: 62,
          ),
          const SizedBox(height: 12),
          Text(
            team.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              height: 1.15,
            ),
          ),
        ],
      ),
    );
  }
}

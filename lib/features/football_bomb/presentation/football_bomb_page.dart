import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/settings_and_stats_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/freezed/entity_models.dart';
import '../../../data/repositories/web_data_store.dart';
import '../../game/data/online_match_service.dart';
import '../../game/presentation/online_arena_banner.dart';
import '../../game/presentation/online_lobby_dialog.dart';
import '../../game/presentation/player_search_bottom_sheet.dart';

class FootballBombPage extends ConsumerStatefulWidget {
  final String? roomId;
  final bool initialDuel;

  const FootballBombPage({super.key, this.roomId, this.initialDuel = false});

  @override
  ConsumerState<FootballBombPage> createState() => _FootballBombPageState();
}

class _FootballBombPageState extends ConsumerState<FootballBombPage> {
  bool _loading = true;
  String? _error;

  BombChallenge? _challenge;
  int _playerCount = 2;
  late List<String> _activePlayers;
  int _currentTurnIndex = 0;

  int _fuseSeconds = 18;
  int _currentMaxFuse = 18;
  int _passesCount = 0;
  final List<Player> _usedPlayers = [];
  Timer? _timer;
  bool _exploded = false;
  int? _roomSeed;
  int _roundCounter = 1;

  @override
  void initState() {
    super.initState();
    _resetPlayers(widget.roomId != null ? 1 : (widget.initialDuel ? 2 : 2));
    WidgetsBinding.instance.addPostFrameCallback((_) => _startNewRound());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _resetPlayers(int count) {
    _playerCount = count;
    _activePlayers = List.generate(count, (i) => 'Oyuncu ${i + 1}');
    _currentTurnIndex = 0;
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

  Future<void> _startNewRound() async {
    _timer?.cancel();
    setState(() {
      _loading = true;
      _error = null;
      _exploded = false;
      _usedPlayers.clear();
      _passesCount = 0;
    });

    try {
      final roundSeed = await _resolveOnlineSeed(_roundCounter++);
      final challenge = await WebDataStore.instance.getRandomBombChallenge(
        random: roundSeed != null ? Random(roundSeed) : null,
      );
      if (!mounted) return;
      setState(() {
        _challenge = challenge;
        _currentMaxFuse = challenge.initialTimerSeconds;
        _fuseSeconds = _currentMaxFuse;
        _loading = false;
      });
      _startBombTimer();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _startBombTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_fuseSeconds <= 1) {
        timer.cancel();
        _onBombExploded();
      } else {
        setState(() => _fuseSeconds--);
      }
    });
  }

  void _onBombExploded() {
    if (_exploded) return;
    final eliminatedPlayer = _activePlayers[_currentTurnIndex];

    setState(() {
      _fuseSeconds = 0;
      _exploded = true;
    });

    ref
        .read(userStatsProvider.notifier)
        .recordGameResult(won: _passesCount >= 5, score: _passesCount * 100);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final remaining = List<String>.from(_activePlayers)
          ..removeAt(_currentTurnIndex);
        final hasWinner = remaining.length == 1;

        return AlertDialog(
          title: Text(
            hasWinner
                ? '🏆 ${remaining.first} Kazandı!'
                : '💥 GÜM! Bomba Patladı!',
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Bomba $eliminatedPlayer elindeyken patladı ve ELENDİ!',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              Text('Toplam Başarılı Pas: $_passesCount'),
              if (hasWinner) ...[
                const SizedBox(height: 8),
                Text(
                  '🎉 ${remaining.first} Hayatta Kalan Son Oyuncu!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppTheme.pitchEmerald,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ],
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            if (!hasWinner && remaining.isNotEmpty)
              ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  setState(() {
                    _activePlayers.removeAt(_currentTurnIndex);
                    if (_currentTurnIndex >= _activePlayers.length) {
                      _currentTurnIndex = 0;
                    }
                  });
                  _startNewRound();
                },
                child: const Text('Kalanlarla Devam Et ➔'),
              ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                setState(() => _resetPlayers(_playerCount));
                _startNewRound();
              },
              child: const Text('Yeni Maç'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _onSubmitPlayer() async {
    if (_challenge == null || _exploded) return;

    final selected = await showModalBottomSheet<Player>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const PlayerSearchBottomSheet(),
    );

    if (selected == null || !mounted || _exploded) return;

    if (_usedPlayers.any((p) => p.id == selected.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ ${selected.name} bu turda zaten söylendi!'),
          backgroundColor: AppTheme.goldTrophy,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final isValid = _challenge!.validPlayerIds.contains(selected.id);
    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ ${selected.name} bu kurala uymuyor!'),
          backgroundColor: AppTheme.crimsonAlert,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _usedPlayers.insert(0, selected);
      _passesCount++;
      _currentMaxFuse = (_currentMaxFuse - 1).clamp(5, 20);
      _fuseSeconds = _currentMaxFuse;
      _currentTurnIndex = (_currentTurnIndex + 1) % _activePlayers.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentHolder = _activePlayers.isNotEmpty
        ? _activePlayers[_currentTurnIndex]
        : 'Oyuncu 1';
    final targetTeam = _challenge?.targetTeam;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Football Bomb 💣'),
        actions: [
          AppTheme.onlineRoomButton(
            isOnlineActive: widget.roomId != null,
            onTap: () {
              showDialog(
                context: context,
                builder: (_) =>
                    const OnlineLobbyDialog(initialMode: 'football_bomb'),
              );
            },
          ),
          PopupMenuButton<int>(
            tooltip: 'Oyuncu Sayısı',
            icon: const Icon(Icons.group_rounded),
            onSelected: (count) {
              setState(() => _resetPlayers(count));
              _startNewRound();
            },
            itemBuilder: (context) => [
              const PopupMenuItem<int>(
                value: 1,
                child: Text('1 Oyuncu (Solo Hayatta Kalma)'),
              ),
              for (final c in [2, 3, 4, 6, 8])
                PopupMenuItem<int>(
                  value: c,
                  child: Text('$c Oyuncu (Parti Modu)'),
                ),
            ],
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
                          gameMode: 'football_bomb',
                          localScore: _passesCount * 100,
                          localRound: _passesCount + 1,
                          localFinished: _exploded,
                        ),
                        // Active Players Bar
                        SizedBox(
                          height: 42,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _activePlayers.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: 8),
                            itemBuilder: (context, idx) {
                              final isHolder = idx == _currentTurnIndex;
                              return Chip(
                                avatar: Text(isHolder ? '💣' : '⚽'),
                                label: Text(
                                  _activePlayers[idx],
                                  style: TextStyle(
                                    fontWeight: isHolder
                                        ? FontWeight.w900
                                        : FontWeight.w600,
                                    color: isHolder ? Colors.white : null,
                                  ),
                                ),
                                backgroundColor: isHolder
                                    ? AppTheme.crimsonAlert
                                    : Theme.of(
                                        context,
                                      ).colorScheme.surfaceContainerHighest,
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Bomb & Fuse Display
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: _fuseSeconds <= 5
                                  ? [
                                      AppTheme.crimsonAlert.withValues(
                                        alpha: 0.35,
                                      ),
                                      AppTheme.surfaceSecondary,
                                    ]
                                  : const [
                                      AppTheme.surfaceSecondary,
                                      AppTheme.surface,
                                    ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: _fuseSeconds <= 5
                                  ? AppTheme.crimsonAlert
                                  : AppTheme.goldTrophy.withValues(alpha: 0.4),
                              width: 2,
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '🎯 Sıra: $currentHolder',
                                    style: const TextStyle(
                                      color: AppTheme.goldTrophy,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white12,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '${_challenge!.validPlayerIds.length} olası cevap',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (targetTeam != null) ...[
                                    AppTheme.clubCrestWidget(
                                      name: targetTeam.name,
                                      logoUrl: targetTeam.logoUrl,
                                      primaryColorHex:
                                          targetTeam.primaryColorHex,
                                      secondaryColorHex:
                                          targetTeam.secondaryColorHex,
                                      size: 52,
                                    ),
                                    const SizedBox(width: 14),
                                  ],
                                  Text(
                                    _exploded ? '💥' : '💣 $_fuseSeconds sn',
                                    style: const TextStyle(
                                      fontSize: 38,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _challenge!.prompt,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Pas: $_passesCount • Her doğru cevapta fitil 1 sn kısalır!',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Used Players List
                        const Text(
                          'BU TURDA SÖYLENEN FUTBOLCULAR (TEKRAR YOK):',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: _usedPlayers.isEmpty
                              ? const Center(
                                  child: Text(
                                    'Henüz futbolcu söylenmedi. Çabuk bombayı pasla!',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: _usedPlayers.length,
                                  itemBuilder: (context, index) {
                                    final p = _usedPlayers[index];
                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      child: ListTile(
                                        dense: true,
                                        leading: AppTheme.playerAvatarWidget(
                                          name: p.name,
                                          overall: p.eaFcOverall,
                                          position: p.position,
                                          size: 36,
                                        ),
                                        title: Text(
                                          p.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        subtitle: Text(
                                          '${AppTheme.nationalityFlag(p.nationality)} ${p.nationality ?? ''} • ${p.position ?? ''}',
                                          style: const TextStyle(fontSize: 11),
                                        ),
                                        trailing: Text(
                                          '#${_usedPlayers.length - index}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w900,
                                            color: AppTheme.pitchEmerald,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                        const SizedBox(height: 10),

                        // Submit Answer Button
                        ElevatedButton.icon(
                          onPressed: _exploded ? null : _onSubmitPlayer,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.crimsonAlert,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          icon: const Icon(
                            Icons.local_fire_department_rounded,
                            size: 22,
                          ),
                          label: const Text(
                            'Futbolcu Söyle ve Bombayı Pasla!',
                            style: TextStyle(
                              fontSize: 16,
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

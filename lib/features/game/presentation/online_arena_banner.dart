import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/auth_providers.dart';
import '../../../core/providers/settings_and_stats_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../data/online_match_service.dart';
import '../domain/online_game_model.dart';

class OnlineArenaBanner extends ConsumerStatefulWidget {
  final String? roomId;
  final String gameMode;
  final int localScore;
  final int localRound;
  final bool localFinished;

  const OnlineArenaBanner({
    super.key,
    required this.roomId,
    required this.gameMode,
    required this.localScore,
    this.localRound = 1,
    this.localFinished = false,
  });

  @override
  ConsumerState<OnlineArenaBanner> createState() => _OnlineArenaBannerState();
}

class _OnlineArenaBannerState extends ConsumerState<OnlineArenaBanner> {
  late final OnlineMatchService _service = ref.read(onlineMatchServiceProvider);
  bool _resultShown = false;
  int _lastSyncedScore = -1;
  int _lastSyncedRound = -1;
  bool _lastSyncedFinished = false;

  @override
  void initState() {
    super.initState();
    _syncIfNeeded();
  }

  @override
  void didUpdateWidget(covariant OnlineArenaBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.localScore != _lastSyncedScore ||
        widget.localRound != _lastSyncedRound ||
        widget.localFinished != _lastSyncedFinished) {
      _syncIfNeeded();
    }
  }

  void _syncIfNeeded() {
    final roomId = widget.roomId;
    if (roomId == null || roomId.isEmpty) return;

    _lastSyncedScore = widget.localScore;
    _lastSyncedRound = widget.localRound;
    _lastSyncedFinished = widget.localFinished;

    final user = ref.read(currentUserProvider);
    final userId = user?.uid ?? 'guest';

    _service.updateArcadeProgress(
      gameId: roomId,
      userId: userId,
      score: widget.localScore,
      round: widget.localRound,
      finished: widget.localFinished,
    );
  }

  void _checkShowOnlineResult(OnlineGame game, String myUserId) {
    if (!game.isFinished || _resultShown) return;
    _resultShown = true;

    final amIP1 = game.player1Id == myUserId;
    final myScore = amIP1 ? game.player1Score : game.player2Score;
    final oppScore = amIP1 ? game.player2Score : game.player1Score;
    final oppName = amIP1 ? (game.player2Name ?? 'Rakip') : game.player1Name;

    final won = myScore > oppScore;
    final draw = myScore == oppScore;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(userStatsProvider.notifier)
          .recordGameResult(won: won, draw: draw, score: myScore);

      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: won
                      ? AppTheme.emeraldGradient
                      : draw
                      ? AppTheme.goldGradient
                      : const LinearGradient(
                          colors: [Color(0xFFEF4444), Color(0xFF991B1B)],
                        ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  won
                      ? Icons.emoji_events_rounded
                      : draw
                      ? Icons.handshake_rounded
                      : Icons.sports_mma_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                won
                    ? '🏆 ONLINE DÜELLO ZAFERİ!'
                    : draw
                    ? '🤝 ONLINE MAÇ BERABERE!'
                    : '💔 ONLINE MAÇI KAYBETTİNİZ',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Oda #${game.roomCode} • Canlı Skor Tablosu',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ScoreColumn(
                    label: 'SEN',
                    score: myScore,
                    color: AppTheme.accentEmerald,
                  ),
                  const Text(
                    'VS',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Colors.grey,
                    ),
                  ),
                  _ScoreColumn(
                    label: oppName,
                    score: oppScore,
                    color: AppTheme.cyberCyan,
                  ),
                ],
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Tamam'),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final roomId = widget.roomId;
    if (roomId == null || roomId.isEmpty) {
      return const SizedBox.shrink();
    }

    final user = ref.watch(currentUserProvider);
    final myUserId = user?.uid ?? 'guest';

    return StreamBuilder<OnlineGame>(
      stream: _service.streamGame(roomId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: AppTheme.stadiumHeroGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.accentEmerald,
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  'Canlı odaya bağlanılıyor...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          );
        }

        final game = snapshot.data!;
        _checkShowOnlineResult(game, myUserId);

        final amIP1 = game.player1Id == myUserId;
        final myName = amIP1 ? game.player1Name : (game.player2Name ?? 'Sen');
        final oppName = amIP1
            ? (game.player2Name ?? 'Rakip Bekleniyor...')
            : game.player1Name;
        final myScore = amIP1 ? game.player1Score : game.player2Score;
        final oppScore = amIP1 ? game.player2Score : game.player1Score;
        final oppRound = amIP1 ? game.player2Round : game.player1Round;
        final oppFinished = amIP1 ? game.player2Finished : game.player1Finished;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            gradient: AppTheme.stadiumHeroGradient,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.accentEmerald.withValues(alpha: 0.55),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: game.roomCode));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Oda kodu kopyalandı: ${game.roomCode}',
                          ),
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: game.player2Id != null
                                ? AppTheme.accentEmerald
                                : AppTheme.trophyGold,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'CANLI ODA #${game.roomCode}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 11.5,
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.copy_rounded,
                          size: 13,
                          color: Colors.white70,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      game.player2Id == null
                          ? '⏳ Rakip Bekleniyor'
                          : oppFinished
                          ? '✓ Rakip Tamamladı'
                          : '⚡ Rakip Tur $oppRound',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.accentEmerald.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppTheme.accentEmerald.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              '🟢 $myName (Sen)',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Text(
                            '$myScore P',
                            style: const TextStyle(
                              color: AppTheme.accentEmerald,
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'VS',
                      style: TextStyle(
                        color: AppTheme.trophyGold,
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.cyberCyan.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppTheme.cyberCyan.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              '🔵 $oppName',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Text(
                            '$oppScore P',
                            style: const TextStyle(
                              color: AppTheme.cyberCyan,
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ScoreColumn extends StatelessWidget {
  final String label;
  final int score;
  final Color color;

  const _ScoreColumn({
    required this.label,
    required this.score,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 13,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$score',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 26,
            color: color,
          ),
        ),
      ],
    );
  }
}

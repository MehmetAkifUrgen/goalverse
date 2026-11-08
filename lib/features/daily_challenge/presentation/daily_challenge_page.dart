import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/providers/settings_and_stats_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/freezed/entity_models.dart';
import '../../../data/repositories/web_data_store.dart';
import '../../../l10n/app_localizations.dart';
import '../../game/engine/score_calculator.dart';
import '../../game/presentation/player_search_bottom_sheet.dart';

class DailyChallengePage extends ConsumerStatefulWidget {
  const DailyChallengePage({super.key});

  @override
  ConsumerState<DailyChallengePage> createState() => _DailyChallengePageState();
}

class _DailyChallengePageState extends ConsumerState<DailyChallengePage> {
  bool _loading = true;
  String? _error;

  late final String _todayKey;
  int _currentStage =
      0; // 0: 2 Teams, 1: Who Am I, 2: Imposter, 3: Transfer Path, 4: Summary
  int _totalRawScore = 0;

  // Stage 0: 2 Teams 1 Player
  Team? _teamA;
  Team? _teamB;
  bool _stage0Solved = false;

  // Stage 1: Who Am I?
  Player? _whoAmIPlayer;
  int _unlockedClues = 1;
  bool _stage1Solved = false;

  // Stage 2: Imposter
  ImposterPuzzle? _imposterPuzzle;
  bool _stage2Solved = false;
  int? _selectedImposterIdx;

  // Stage 3: Transfer Path
  TransferPathPuzzle? _transferPuzzle;
  bool _stage3Solved = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _todayKey =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDailyPack());
  }

  Future<void> _loadDailyPack() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await WebDataStore.instance.init();
      await ref.read(isarDatabaseProvider.future);

      final seed = _todayKey.codeUnits.fold<int>(0, (a, b) => a * 31 + b);
      final rng = Random(seed);

      final pairs = await WebDataStore.instance.teamRepo
          .getTeamPairsWithMinPlayers(minPlayersPerPair: 3, limit: 40);
      if (pairs.isNotEmpty) {
        final pair = pairs[rng.nextInt(pairs.length)];
        _teamA = pair.$1;
        _teamB = pair.$2;
      }

      final allWithClues = WebDataStore.instance.players
          .where((p) => p.clues.isNotEmpty)
          .toList();
      if (allWithClues.isNotEmpty) {
        _whoAmIPlayer = allWithClues[rng.nextInt(allWithClues.length)];
      }

      _imposterPuzzle = await WebDataStore.instance.getRandomImposterPuzzle(
        random: rng,
      );
      _transferPuzzle = await WebDataStore.instance.getRandomTransferPathPuzzle(
        random: rng,
      );

      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _pickPlayerForStage0() async {
    if (_teamA == null || _teamB == null || _stage0Solved) return;

    final selected = await showModalBottomSheet<Player>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const PlayerSearchBottomSheet(),
    );
    if (selected == null || !mounted) return;

    final validator = ref.read(answerValidatorRepositoryProvider);
    final valid = await validator.isPlayerInTeamPair(
      selected.id,
      _teamA!.id,
      _teamB!.id,
    );
    if (!mounted) return;

    if (valid) {
      setState(() {
        _stage0Solved = true;
        _totalRawScore += 250;
      });
      _advanceStage();
    } else {
      final l10n = AppLocalizations.of(context);
      _showWrongSnack(
        l10n != null
            ? l10n.twoTeamsWrongBoth(selected.name, _teamA?.name ?? '', _teamB?.name ?? '')
            : '${selected.name} her iki kulüpte birden oynamadı!',
      );
    }
  }

  Future<void> _pickPlayerForStage1() async {
    if (_whoAmIPlayer == null || _stage1Solved) return;

    final selected = await showModalBottomSheet<Player>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const PlayerSearchBottomSheet(),
    );
    if (selected == null || !mounted) return;

    if (selected.id == _whoAmIPlayer!.id) {
      final pts = (5 - _unlockedClues).clamp(1, 4) * 100;
      setState(() {
        _stage1Solved = true;
        _totalRawScore += pts;
      });
      _advanceStage();
    } else {
      setState(() {
        if (_unlockedClues < _whoAmIPlayer!.clues.length) {
          _unlockedClues++;
        }
      });
      final l10n = AppLocalizations.of(context);
      _showWrongSnack(
        l10n != null
            ? '${selected.name} ${l10n.wrongGuess}!'
            : '${selected.name} değil! Yeni ipucu açıldı.',
      );
    }
  }

  void _selectImposterOption(int index) {
    if (_imposterPuzzle == null || _stage2Solved) return;
    final opt = _imposterPuzzle!.options[index];
    setState(() {
      _selectedImposterIdx = index;
      _stage2Solved = true;
      if (opt.isImposter) {
        _totalRawScore += 300;
      }
    });
    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      _advanceStage();
    });
  }

  Future<void> _pickPlayerForStage3() async {
    if (_transferPuzzle == null || _stage3Solved) return;

    final selected = await showModalBottomSheet<Player>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const PlayerSearchBottomSheet(),
    );
    if (selected == null || !mounted) return;

    if (selected.id == _transferPuzzle!.player.id) {
      setState(() {
        _stage3Solved = true;
        _totalRawScore += 350;
      });
      _advanceStage();
    } else {
      final l10n = AppLocalizations.of(context);
      _showWrongSnack(
        l10n != null
            ? l10n.wrongPlayerCheckHistory(selected.name)
            : '${selected.name} değil! Transfer geçmişini kontrol et.',
      );
    }
  }

  void _skipCurrentStage() {
    _advanceStage();
  }

  Future<void> _advanceStage() async {
    if (_currentStage < 3) {
      setState(() {
        _currentStage++;
      });
    } else {
      final finalScore = ScoreCalculator.applyDailyChallengeMultiplier(
        _totalRawScore,
      );
      await ref
          .read(userStatsProvider.notifier)
          .completeDailyChallenge(_todayKey, finalScore);
      if (!mounted) return;
      setState(() {
        _currentStage = 4;
      });
    }
  }

  void _showWrongSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('❌ $msg'),
        backgroundColor: AppTheme.crimsonAlert,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final stats = ref.watch(userStatsProvider);
    final alreadyDone = stats.isDailyCompleted(_todayKey);
    final savedScore = stats.completedDailyChallenges[_todayKey] ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text('${l10n.dailyChallenge} ($_todayKey)'),
        actions: [
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
              '⭐ ${ScoreCalculator.applyDailyChallengeMultiplier(_totalRawScore)}',
              style: const TextStyle(
                fontSize: 14,
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
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 740),
                child: (alreadyDone || _currentStage == 4)
                    ? _buildCompletedView(
                        l10n,
                        alreadyDone
                            ? savedScore
                            : ScoreCalculator.applyDailyChallengeMultiplier(
                                _totalRawScore,
                              ),
                        stats.completedDailyChallenges,
                      )
                    : SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Progress Stepper
                              Row(
                                children: List.generate(4, (idx) {
                                  final isDone = idx < _currentStage;
                                  final isCurrent = idx == _currentStage;
                                  return Expanded(
                                    child: Container(
                                      height: 8,
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isDone
                                            ? AppTheme.pitchEmerald
                                            : isCurrent
                                            ? AppTheme.goldTrophy
                                            : Colors.grey.withValues(
                                                alpha: 0.3,
                                              ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                l10n.dailyStageHeader(_currentStage + 1),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.1,
                                  color: AppTheme.goldTrophy,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Expanded(child: _buildCurrentStageWidget()),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: _skipCurrentStage,
                                child: Text(l10n.skipThisStage),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ),
    );
  }

  Widget _buildCurrentStageWidget() {
    final l10n = AppLocalizations.of(context);
    switch (_currentStage) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n?.dailyStage1 ?? '⚡ Aşama 1: 2 Takım 1 Oyuncu',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              l10n?.twoTeamsPrompt ?? 'Her İKİ kulüpte de forma giymiş bir futbolcu seçin:',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            if (_teamA != null && _teamB != null)
              Row(
                children: [
                  Expanded(child: _ClubBox(team: _teamA!)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text('🤝', style: TextStyle(fontSize: 26)),
                  ),
                  Expanded(child: _ClubBox(team: _teamB!)),
                ],
              ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _pickPlayerForStage0,
              icon: const Icon(Icons.search_rounded),
              label: Text(l10n?.searchAndSubmitPlayer ?? 'Futbolcu Ara ve Gönder'),
            ),
          ],
        );

      case 1:
        final clues = _whoAmIPlayer?.clues ?? const [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n?.dailyStage2 ?? '🧩 Aşama 2: Ben Kimim?',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: clues.length,
                itemBuilder: (context, idx) {
                  final unlocked = idx < _unlockedClues;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: unlocked
                            ? AppTheme.pitchEmerald.withValues(alpha: 0.2)
                            : Colors.grey.withValues(alpha: 0.2),
                        child: Text(
                          '${idx + 1}',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: unlocked
                                ? AppTheme.pitchEmerald
                                : Colors.grey,
                          ),
                        ),
                      ),
                      title: Text(
                        unlocked ? clues[idx] : (l10n?.lockedClue ?? '🔒 Kilitli İpucu'),
                        style: TextStyle(
                          fontWeight: unlocked
                              ? FontWeight.w700
                              : FontWeight.normal,
                          fontStyle: unlocked
                              ? FontStyle.normal
                              : FontStyle.italic,
                          color: unlocked ? null : Colors.grey,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_unlockedClues < clues.length)
              OutlinedButton.icon(
                onPressed: () => setState(() => _unlockedClues++),
                icon: const Icon(Icons.lock_open_rounded),
                label: Text(l10n?.unlockNextClue ?? 'Sonraki İpucunu Aç'),
              ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _pickPlayerForStage1,
              icon: const Icon(Icons.help_outline_rounded),
              label: Text(l10n?.guessMysteryPlayer ?? 'Gizemli Futbolcuyu Tahmin Et'),
            ),
          ],
        );

      case 2:
        final puzzle = _imposterPuzzle!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n?.dailyStage3 ?? '🕵️ Aşama 3: Ajanı Bul (Imposter)',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.crimsonAlert.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppTheme.crimsonAlert.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                children: [
                  AppTheme.clubCrestWidget(
                    name: puzzle.targetTeam.name,
                    logoUrl: puzzle.targetTeam.logoUrl,
                    primaryColorHex: puzzle.targetTeam.primaryColorHex,
                    secondaryColorHex: puzzle.targetTeam.secondaryColorHex,
                    size: 40,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      puzzle.ruleDescription,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                itemCount: puzzle.options.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.35,
                ),
                itemBuilder: (context, idx) {
                  final opt = puzzle.options[idx];
                  final isSelected = _selectedImposterIdx == idx;
                  Color? borderColor;
                  if (_stage2Solved) {
                    if (opt.isImposter) {
                      borderColor = AppTheme.pitchEmerald;
                    } else if (isSelected) {
                      borderColor = AppTheme.crimsonAlert;
                    }
                  }
                  return InkWell(
                    onTap: () => _selectImposterOption(idx),
                    borderRadius: BorderRadius.circular(16),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: borderColor != null
                            ? BorderSide(color: borderColor, width: 2.5)
                            : BorderSide.none,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AppTheme.playerAvatarWidget(
                              name: opt.player.name,
                              overall: opt.player.eaFcOverall,
                              position: opt.player.position,
                              size: 40,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              opt.player.name,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );

      default:
        final puzzle = _transferPuzzle!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n?.dailyStage4 ?? '✈️ Aşama 4: Transfer Rotası',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              l10n?.transferPathQuestion ?? 'Kariyer geçmişinden futbolcuyu bul:',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: puzzle.path.length,
                itemBuilder: (context, idx) {
                  final stop = puzzle.path[idx];
                  final years =
                      '${stop.seasonStart ?? '?'} – ${stop.seasonEnd ?? (l10n?.presentDay ?? "Günümüz")}';
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: AppTheme.clubCrestWidget(
                        name: stop.team.name,
                        logoUrl: stop.team.logoUrl,
                        primaryColorHex: stop.team.primaryColorHex,
                        secondaryColorHex: stop.team.secondaryColorHex,
                        size: 38,
                      ),
                      title: Text(
                        stop.team.name,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      trailing: Text(
                        years,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppTheme.pitchEmerald,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton.icon(
              onPressed: _pickPlayerForStage3,
              icon: const Icon(Icons.search_rounded),
              label: const Text('Futbolcuyu Tahmin Et'),
            ),
          ],
        );
    }
  }

  Widget _buildCompletedView(
    AppLocalizations l10n,
    int finalScore,
    Map<String, int> history,
  ) {
    final sortedDates = history.keys.toList()..sort((a, b) => b.compareTo(a));

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber.shade700, Colors.orange.shade900],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                children: [
                  const Text('🏆', style: TextStyle(fontSize: 52)),
                  const SizedBox(height: 12),
                  Text(
                    l10n.dailyChallengeCompleted,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${l10n.score}: $finalScore Puan',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.comeBackTomorrow,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.dailyCompletedTournaments,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: sortedDates.length,
                itemBuilder: (context, index) {
                  final date = sortedDates[index];
                  final pts = history[date] ?? 0;
                  return Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.check_circle_rounded,
                        color: AppTheme.pitchEmerald,
                      ),
                      title: Text(
                        date,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      trailing: Text(
                        '$pts Puan',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                          color: AppTheme.goldTrophy,
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
    );
  }
}

class _ClubBox extends StatelessWidget {
  final Team team;

  const _ClubBox({required this.team});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 145,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppTheme.pitchEmerald.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppTheme.clubCrestWidget(
            name: team.name,
            logoUrl: team.logoUrl,
            primaryColorHex: team.primaryColorHex,
            secondaryColorHex: team.secondaryColorHex,
            size: 52,
          ),
          const SizedBox(height: 10),
          Text(
            team.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

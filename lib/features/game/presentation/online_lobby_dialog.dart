import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers.dart';
import '../../../core/providers/auth_providers.dart';
import '../../../core/providers/settings_and_stats_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/stadium_visuals.dart';
import '../data/online_match_service.dart';
import '../domain/online_game_model.dart';
import '../engine/board_generator.dart';

class OnlineLobbyDialog extends ConsumerStatefulWidget {
  final String initialMode;
  final int initialTab;

  const OnlineLobbyDialog({
    super.key,
    this.initialMode = 'sos',
    this.initialTab = 0,
  });

  @override
  ConsumerState<OnlineLobbyDialog> createState() => _OnlineLobbyDialogState();
}

class _OnlineLobbyDialogState extends ConsumerState<OnlineLobbyDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _codeController = TextEditingController();
  final OnlineMatchService _service = OnlineMatchService();

  late String _selectedMode;
  bool _creating = false;
  bool _matchmaking = false;
  bool _joining = false;
  String? _createdRoomCode;
  String? _createdGameId;
  StreamSubscription<OnlineGame>? _waitingSub;
  String? _error;
  int _selectedTurnSeconds = 30;
  int _selectedTotalRounds = 3; // 3 (2 Galibiyet) or 5 (3 Galibiyet)

  @override
  void initState() {
    super.initState();
    _selectedMode = widget.initialMode;
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, 2),
    );
  }

  @override
  void dispose() {
    _waitingSub?.cancel();
    _tabController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  String _currentUserName() {
    final stats = ref.read(userStatsProvider);
    final user = ref.read(currentUserProvider);
    if (stats.customDisplayName?.isNotEmpty ?? false) {
      return stats.customDisplayName!;
    }
    if (user?.displayName?.isNotEmpty ?? false) {
      return user!.displayName!;
    }
    if (user?.email?.isNotEmpty ?? false) {
      return user!.email!.split('@').first;
    }
    return 'Pro Menajer';
  }

  String _currentUserId() {
    final user = ref.read(currentUserProvider);
    return user?.uid ?? 'guest_${DateTime.now().millisecondsSinceEpoch}';
  }

  void _navigateToOnlineMatch(String gameId, String gameMode) {
    _waitingSub?.cancel();
    if (!mounted) return;
    Navigator.of(context).pop();

    if (gameMode == 'sos') {
      context.push('/online-game/$gameId');
      return;
    }

    final info = OnlineGameModeInfo.fromId(gameMode);
    context.push('${info.routePath}?roomId=$gameId');
  }

  void _navigateToLocalMode({required bool twoPlayer}) {
    _waitingSub?.cancel();
    Navigator.of(context).pop();

    if (_selectedMode == 'sos') {
      final path = twoPlayer ? '/game/local-demo' : '/game/solo-ai';
      context.push('$path?rounds=$_selectedTotalRounds');
      return;
    }

    final info = OnlineGameModeInfo.fromId(_selectedMode);
    context.push('${info.routePath}${twoPlayer ? '?duel=1' : ''}');
  }

  BoardGenerator? _buildBoardGeneratorIfNeeded(String mode) {
    if (mode != 'sos') return null;
    final teamRepo = ref.read(teamRepositoryProvider);
    final answerValidator = ref.read(answerValidatorRepositoryProvider);
    return BoardGenerator(
      teamRepository: teamRepo,
      answerValidator: answerValidator,
    );
  }

  Future<void> _onQuickMatch() async {
    setState(() {
      _matchmaking = true;
      _error = null;
      _createdRoomCode = null;
      _createdGameId = null;
    });

    try {
      final result = await _service.findOrCreateQuickMatch(
        userId: _currentUserId(),
        userName: _currentUserName(),
        gameMode: _selectedMode,
        boardGenerator: _buildBoardGeneratorIfNeeded(_selectedMode),
        turnDurationSeconds: _selectedTurnSeconds,
        totalRounds: _selectedTotalRounds,
      );

      final gameId = result['gameId']!;
      final roomCode = result['roomCode']!;
      final gameMode = result['gameMode'] ?? _selectedMode;
      final matchedImmediately = result['matchedImmediately'] == 'true';

      if (matchedImmediately) {
        _navigateToOnlineMatch(gameId, gameMode);
        return;
      }

      if (!mounted) return;
      setState(() {
        _matchmaking = false;
        _createdRoomCode = roomCode;
        _createdGameId = gameId;
      });

      _listenForOpponent(gameId, gameMode);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _matchmaking = false;
        _error = e
            .toString()
            .replaceAll('StateError: ', '')
            .replaceAll('Exception: ', '');
      });
    }
  }

  Future<void> _onCreateRoom() async {
    setState(() {
      _creating = true;
      _error = null;
      _createdRoomCode = null;
      _createdGameId = null;
    });

    try {
      final result = await _service.createRoom(
        userId: _currentUserId(),
        userName: _currentUserName(),
        boardGenerator: _buildBoardGeneratorIfNeeded(_selectedMode),
        gameMode: _selectedMode,
        isPublic: false,
        turnDurationSeconds: _selectedTurnSeconds,
        totalRounds: _selectedTotalRounds,
      );

      final gameId = result['gameId']!;
      final roomCode = result['roomCode']!;

      if (!mounted) return;
      setState(() {
        _creating = false;
        _createdRoomCode = roomCode;
        _createdGameId = gameId;
      });

      _listenForOpponent(gameId, _selectedMode);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _creating = false;
        _error = e
            .toString()
            .replaceAll('StateError: ', '')
            .replaceAll('Exception: ', '');
      });
    }
  }

  void _listenForOpponent(String gameId, String gameMode) {
    _waitingSub?.cancel();
    _waitingSub = _service.streamGame(gameId).listen((game) {
      if (game.player2Id != null && mounted) {
        _navigateToOnlineMatch(gameId, game.gameMode);
      }
    });
  }

  Future<void> _pasteClipboardCode() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final raw = data?.text?.trim() ?? '';
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isNotEmpty && mounted) {
      setState(() {
        _codeController.text = digits.length > 6
            ? digits.substring(0, 6)
            : digits;
        _error = null;
      });
    }
  }

  Future<void> _onJoinRoom() async {
    final code = _codeController.text.trim();
    if (code.length != 6) {
      setState(() => _error = 'Lütfen 6 haneli oda kodunu eksiksiz girin.');
      return;
    }

    setState(() {
      _joining = true;
      _error = null;
    });

    try {
      final res = await _service.joinRoomWithDetails(
        roomCode: code,
        userId: _currentUserId(),
        userName: _currentUserName(),
      );

      final gameId = res['gameId']!;
      final gameMode = res['gameMode'] ?? 'sos';
      _navigateToOnlineMatch(gameId, gameMode);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _joining = false;
        _error = e
            .toString()
            .replaceAll('StateError: ', '')
            .replaceAll('Exception: ', '');
      });
    }
  }

  Widget _buildMatchFormatSelector(bool isDark) {
    if (_selectedMode != 'sos') return const SizedBox.shrink();

    final options = [
      (
        rounds: 3,
        wins: 2,
        title: '3 TUR – 2 GALİBİYET',
        desc: 'En fazla 3 tur oynanır, 2 tur kazanan maçı alır',
      ),
      (
        rounds: 5,
        wins: 3,
        title: '5 TUR – 3 GALİBİYET',
        desc: 'En fazla 5 tur oynanır, 3 tur kazanan maçı alır',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(
              Icons.emoji_events_rounded,
              size: 15,
              color: AppColors.trophyGold,
            ),
            const SizedBox(width: 6),
            Text(
              'MAÇ FORMATI (FOOTBALL SOS SERİSİ)',
              style: AppTypography.label(
                fontSize: 11.5,
                color: AppColors.trophyGold,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (int i = 0; i < options.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: (_createdRoomCode != null)
                      ? null
                      : () => setState(
                          () => _selectedTotalRounds = options[i].rounds,
                        ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: _selectedTotalRounds == options[i].rounds
                          ? AppColors.primary.withValues(alpha: 0.14)
                          : (isDark
                                ? AppColors.surfaceSecondary
                                : AppColors.lightSurfaceElevated),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _selectedTotalRounds == options[i].rounds
                            ? AppColors.primary
                            : (isDark
                                  ? AppColors.border
                                  : AppColors.lightBorder),
                        width: _selectedTotalRounds == options[i].rounds
                            ? 1.5
                            : 1.0,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _selectedTotalRounds == options[i].rounds
                                  ? Icons.radio_button_checked_rounded
                                  : Icons.radio_button_off_rounded,
                              size: 15,
                              color: _selectedTotalRounds == options[i].rounds
                                  ? AppColors.primary
                                  : AppColors.muted,
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                options[i].title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.label(
                                  fontSize: 11,
                                  color:
                                      _selectedTotalRounds == options[i].rounds
                                      ? AppColors.primary
                                      : (isDark
                                            ? AppColors.foreground
                                            : AppColors.lightTextPrimary),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          options[i].desc,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.description(
                            fontSize: 10,
                            color: isDark
                                ? AppColors.muted
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedInfo = OnlineGameModeInfo.fromId(_selectedMode);

    return Dialog(
      backgroundColor: isDark ? AppColors.surface : AppColors.lightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: isDark ? AppColors.border : AppColors.lightBorder,
        ),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Clean Header
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.wifi_tethering_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Canlı Çok Oyunculu Lobi',
                          style: AppTypography.modeTitle(
                            fontSize: 21,
                            color: isDark
                                ? AppColors.foreground
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                        Text(
                          'Hızlı Eşleşme • Özel Oda • 6 Haneli Kod',
                          style: AppTypography.description(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.muted
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconActionButton(
                    icon: Icons.close_rounded,
                    size: 36,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Mode Selector Pills (All 7 Modes)
              Text(
                'Oyun Modu Seçimi',
                style: AppTypography.label(
                  fontSize: 11.5,
                  color: isDark
                      ? AppColors.muted
                      : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: OnlineGameModeInfo.allModes.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final mode = OnlineGameModeInfo.allModes[index];
                    final selected = mode.id == _selectedMode;
                    return ChoiceChip(
                      label: Text(
                        mode.title,
                        style: AppTypography.label(
                          fontSize: 12,
                          color: selected
                              ? AppColors.primaryText
                              : (isDark
                                    ? AppColors.foreground
                                    : AppColors.lightTextPrimary),
                        ),
                      ),
                      selected: selected,
                      selectedColor: AppColors.primary,
                      backgroundColor: isDark
                          ? AppColors.surfaceElevated
                          : AppColors.lightSurfaceElevated,
                      side: BorderSide(
                        color: selected
                            ? AppColors.primary
                            : (isDark
                                  ? AppColors.borderSubtle
                                  : AppColors.lightBorder),
                      ),
                      onSelected: (val) {
                        if (val) {
                          _waitingSub?.cancel();
                          setState(() {
                            _selectedMode = mode.id;
                            _createdRoomCode = null;
                            _createdGameId = null;
                            _error = null;
                          });
                        }
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 6),
              Text(
                selectedInfo.subtitle,
                style: AppTypography.description(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.muted
                      : AppColors.lightTextSecondary,
                ),
              ),

              // Match Format Selector for Football SOS (3 Rounds vs 5 Rounds)
              _buildMatchFormatSelector(isDark),

              const SizedBox(height: 14),

              // 3 Clean Tabs: Hızlı Eşleşme / Oda Oluştur / Koda Katıl
              Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.surfaceSubtle
                      : AppColors.lightSurfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? AppColors.borderSubtle
                        : AppColors.lightBorder,
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.muted,
                  indicatorColor: AppColors.primary,
                  labelStyle: AppTypography.label(fontSize: 12),
                  tabs: const [
                    Tab(text: 'Hızlı Eşleşme'),
                    Tab(text: 'Oda Oluştur'),
                    Tab(text: 'Koda Katıl'),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              if (_error != null)
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.45),
                    ),
                  ),
                  child: Text(
                    _error!,
                    style: AppTypography.label(
                      color: AppColors.error,
                      fontSize: 12.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              SizedBox(
                height: 245,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildQuickMatchTab(selectedInfo, isDark),
                    _buildCreateRoomTab(selectedInfo, isDark),
                    _buildJoinTab(isDark),
                  ],
                ),
              ),

              Divider(
                height: 22,
                color: isDark ? AppColors.borderSubtle : AppColors.lightBorder,
              ),

              // Quick Local / Solo Fallback Buttons
              Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      label: _selectedMode == 'sos'
                          ? 'Tek Oyna (Bot)'
                          : 'Tek Başına Oyna',
                      icon: Icons.person_outline_rounded,
                      onTap: () => _navigateToLocalMode(twoPlayer: false),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SecondaryButton(
                      label: '2 Oyuncu (Aynı Cihaz)',
                      icon: Icons.people_outline_rounded,
                      onTap: () => _navigateToLocalMode(twoPlayer: true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickMatchTab(OnlineGameModeInfo selectedInfo, bool isDark) {
    if (_matchmaking) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 16),
            Text(
              'Açık odalar taranıyor ve rakip aranıyor...',
              style: AppTypography.body(
                color: isDark
                    ? AppColors.foreground
                    : AppColors.lightTextPrimary,
              ),
            ),
          ],
        ),
      );
    }

    if (_createdRoomCode != null) {
      return _buildWaitingRoomView(
        title: 'Eşleşme Odası Açıldı — Rakip Bekleniyor',
        selectedInfo: selectedInfo,
        isDark: isDark,
      );
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.surfaceElevated
                  : AppColors.lightSurfaceElevated,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.35),
              ),
            ),
            child: const Icon(
              Icons.radar_rounded,
              color: AppColors.primary,
              size: 32,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${selectedInfo.title} için açık bir odaya anında bağlanın veya otomatik eşleşme kuyruğuna girin.',
            textAlign: TextAlign.center,
            style: AppTypography.description(
              fontSize: 13,
              color: isDark ? AppColors.muted : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 18),
          ArenaButton(
            label: 'Hızlı Eşleşme Başlat',
            icon: Icons.bolt_rounded,
            onTap: _onQuickMatch,
          ),
        ],
      ),
    );
  }

  Widget _buildCreateRoomTab(OnlineGameModeInfo selectedInfo, bool isDark) {
    if (_creating) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 12),
            Text('Özel oda ve maç verisi hazırlanıyor...'),
          ],
        ),
      );
    }

    if (_createdRoomCode != null) {
      return _buildWaitingRoomView(
        title: 'Arkadaşınızla 6 Haneli Kodu Paylaşın:',
        selectedInfo: selectedInfo,
        isDark: isDark,
      );
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${selectedInfo.title} modunda 6 haneli özel oda oluşturun ve arkadaşınızı davet edin.',
            textAlign: TextAlign.center,
            style: AppTypography.description(
              fontSize: 13,
              color: isDark ? AppColors.muted : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.timer_outlined,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                'Hamle Süresi:',
                style: AppTypography.label(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.foreground
                      : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(width: 8),
              for (final sec in [15, 30, 45, 60])
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: ChoiceChip(
                    label: Text(
                      '${sec}s',
                      style: AppTypography.label(
                        fontSize: 11.5,
                        color: _selectedTurnSeconds == sec
                            ? AppColors.primaryText
                            : (isDark
                                  ? AppColors.foreground
                                  : AppColors.lightTextPrimary),
                        tabular: true,
                      ),
                    ),
                    selected: _selectedTurnSeconds == sec,
                    selectedColor: AppColors.primary,
                    onSelected: (val) {
                      if (val) setState(() => _selectedTurnSeconds = sec);
                    },
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          ArenaButton(
            label: '6 Haneli Özel Oda Kur',
            icon: Icons.add_circle_outline_rounded,
            onTap: _onCreateRoom,
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingRoomView({
    required String title,
    required OnlineGameModeInfo selectedInfo,
    required bool isDark,
  }) {
    final roundsToWin = (_selectedTotalRounds ~/ 2) + 1;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: AppTypography.label(
              fontSize: 12.5,
              color: isDark ? AppColors.muted : AppColors.lightTextSecondary,
            ),
          ),
          if (_selectedMode == 'sos') ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.trophyGold.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: AppColors.trophyGold.withValues(alpha: 0.45),
                ),
              ),
              child: Text(
                'Format: $_selectedTotalRounds TUR – $roundsToWin GALİBİYET (Kilitli)',
                style: AppTypography.label(
                  fontSize: 11,
                  color: AppColors.trophyGold,
                ),
              ),
            ),
          ],
          const SizedBox(height: 10),
          PressableScale(
            onTap: () {
              Clipboard.setData(ClipboardData(text: _createdRoomCode!));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Oda kodu kopyalandı! Arkadaşınıza gönderin.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.surfaceElevated
                    : AppColors.lightSurfaceElevated,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.7),
                  width: 1.4,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _createdRoomCode!,
                    style: AppTypography.statValue(
                      fontSize: 30,
                      color: AppColors.primary,
                      letterSpacing: 6,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(
                    Icons.copy_rounded,
                    size: 20,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Rakip katıldığında maç otomatik başlayacak...',
                style: AppTypography.description(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.muted
                      : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
          if (_createdGameId != null && _selectedMode != 'sos') ...[
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () =>
                  _navigateToOnlineMatch(_createdGameId!, _selectedMode),
              icon: const Icon(Icons.play_arrow_rounded, size: 18),
              label: const Text(
                'Odaya Şimdi Gir (Rakip Katılınca Canlı Bağlanır)',
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildJoinTab(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Arkadaşınızın paylaştığı 6 haneli oda kodunu girin:',
            textAlign: TextAlign.center,
            style: AppTypography.description(
              fontSize: 13,
              color: isDark ? AppColors.muted : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 200,
                child: TextField(
                  controller: _codeController,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  style: AppTypography.statValue(
                    fontSize: 24,
                    color: isDark
                        ? AppColors.foreground
                        : AppColors.lightTextPrimary,
                    letterSpacing: 6,
                  ),
                  decoration: const InputDecoration(
                    hintText: '123456',
                    counterText: '',
                  ),
                  onSubmitted: (_) => _onJoinRoom(),
                ),
              ),
              const SizedBox(width: 8),
              IconActionButton(
                icon: Icons.content_paste_rounded,
                tooltip: 'Panodan Yapıştır',
                size: 46,
                onTap: _pasteClipboardCode,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ArenaButton(
            label: 'Odaya Katıl ve Maça Başla',
            icon: Icons.login_rounded,
            isLoading: _joining,
            onTap: _onJoinRoom,
          ),
        ],
      ),
    );
  }
}

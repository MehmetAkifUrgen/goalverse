import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:football_tic_tac_toe/core/monetization/cosmetic_store_service.dart';
import 'package:football_tic_tac_toe/core/monetization/monetization_models.dart';
import 'package:football_tic_tac_toe/core/monetization/premium_service.dart';
import 'package:football_tic_tac_toe/core/providers.dart';
import 'package:football_tic_tac_toe/core/providers/auth_providers.dart';
import 'package:football_tic_tac_toe/core/providers/settings_and_stats_provider.dart';
import 'package:football_tic_tac_toe/core/theme/app_theme.dart';
import 'package:football_tic_tac_toe/data/repositories/web_data_store.dart';
import 'package:football_tic_tac_toe/features/auth/domain/app_user.dart';
import 'package:football_tic_tac_toe/features/auth/domain/auth_repository.dart';
import 'package:football_tic_tac_toe/features/daily_challenge/presentation/daily_challenge_page.dart';
import 'package:football_tic_tac_toe/features/game/presentation/game_page.dart';
import 'package:football_tic_tac_toe/features/game/presentation/player_search_bottom_sheet.dart';
import 'package:football_tic_tac_toe/features/home/presentation/home_page.dart';
import 'package:football_tic_tac_toe/features/leaderboard/presentation/leaderboard_page.dart';
import 'package:football_tic_tac_toe/features/profile/presentation/profile_page.dart';
import 'package:football_tic_tac_toe/features/two_teams/presentation/two_teams_page.dart';
import 'package:football_tic_tac_toe/features/who_am_i/presentation/who_am_i_page.dart';
import 'package:football_tic_tac_toe/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeAuthRepository implements AuthRepository {
  final AppUser user;
  const _FakeAuthRepository(this.user);

  @override
  Stream<AppUser?> authStateChanges() => Stream<AppUser?>.value(user);

  @override
  AppUser? get currentUser => user;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _InAppScreenSpec {
  final String fileStem;
  final Widget Function() pageBuilder;
  final Future<void> Function(WidgetTester tester)? afterLoadAction;

  const _InAppScreenSpec({
    required this.fileStem,
    required this.pageBuilder,
    this.afterLoadAction,
  });
}

class _LocaleTarget {
  final String langCode;
  final Locale locale;
  final String androidLocaleDir;
  final String iosLocaleDir;

  const _LocaleTarget({
    required this.langCode,
    required this.locale,
    required this.androidLocaleDir,
    required this.iosLocaleDir,
  });
}

const _localeTargets = <_LocaleTarget>[
  _LocaleTarget(
    langCode: 'tr',
    locale: Locale('tr'),
    androidLocaleDir: 'tr-TR',
    iosLocaleDir: 'tr',
  ),
  _LocaleTarget(
    langCode: 'en',
    locale: Locale('en'),
    androidLocaleDir: 'en-US',
    iosLocaleDir: 'en-US',
  ),
  _LocaleTarget(
    langCode: 'en',
    locale: Locale('en', 'GB'),
    androidLocaleDir: 'en-GB',
    iosLocaleDir: 'en-GB',
  ),
  _LocaleTarget(
    langCode: 'es',
    locale: Locale('es'),
    androidLocaleDir: 'es-ES',
    iosLocaleDir: 'es-ES',
  ),
  _LocaleTarget(
    langCode: 'fr',
    locale: Locale('fr'),
    androidLocaleDir: 'fr-FR',
    iosLocaleDir: 'fr-FR',
  ),
  _LocaleTarget(
    langCode: 'de',
    locale: Locale('de'),
    androidLocaleDir: 'de-DE',
    iosLocaleDir: 'de-DE',
  ),
  _LocaleTarget(
    langCode: 'it',
    locale: Locale('it'),
    androidLocaleDir: 'it-IT',
    iosLocaleDir: 'it',
  ),
];

Future<void> _loadRealFontsForScreenshots() async {
  Future<void> registerFontFile(String family, String path) async {
    final file = File(path);
    if (!file.existsSync()) return;
    final bytes = file.readAsBytesSync();
    final loader = FontLoader(family);
    loader.addFont(Future.value(ByteData.view(bytes.buffer)));
    await loader.load();
  }

  await registerFontFile('Sora', 'assets/fonts/Sora.ttf');
  await registerFontFile('Manrope', 'assets/fonts/Manrope.ttf');
  await registerFontFile('SpaceGrotesk', 'assets/fonts/SpaceGrotesk.ttf');
  await registerFontFile('Roboto', 'assets/fonts/Manrope.ttf');

  final possibleMaterialIconPaths = <String>[
    '/Users/a./flutter/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
    '/opt/homebrew/share/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
    '/Users/a./development/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
    '/Users/a./flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
  ];
  for (final iconPath in possibleMaterialIconPaths) {
    if (File(iconPath).existsSync()) {
      await registerFontFile('MaterialIcons', iconPath);
      break;
    }
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'user_stats_v1_store_captain':
          '{"gamesPlayed":124,"wins":89,"losses":23,"draws":12,"bestScore":2480,"currentStreak":9,"bestStreak":16,"rating":1785,"country":"TR","customDisplayName":"ArdaGuler_10","unlockedAchievements":["first_win","streak_5","elo_1500"]}',
    });
    await _loadRealFontsForScreenshots();
  });

  final specs = <_InAppScreenSpec>[
    // 1. Real HomePage
    _InAppScreenSpec(
      fileStem: '01_home_arena',
      pageBuilder: () => const HomePage(),
    ),
    // 2. Real Football SOS 3x3 GamePage (3-Round Series vs AI)
    _InAppScreenSpec(
      fileStem: '02_football_sos_board',
      pageBuilder: () => const GamePage(matchId: 'solo-ai', initialTotalRounds: 3),
    ),
    // 3. Real 2 Teams 1 Player 1v1 Duel Mode Page
    _InAppScreenSpec(
      fileStem: '03_online_match',
      pageBuilder: () => const TwoTeamsPage(initialDuel: true),
    ),
    // 4. Real GamePage with PlayerSearchBottomSheet open showing real search results
    _InAppScreenSpec(
      fileStem: '04_player_search',
      pageBuilder: () => const GamePage(matchId: 'local-duel', initialTotalRounds: 5),
      afterLoadAction: (tester) async {
        final ctx = tester.element(find.byType(GamePage));
        showModalBottomSheet<void>(
          context: ctx,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const PlayerSearchBottomSheet(
            rowTeamName: 'Real Madrid',
            rowTeamColorHex: '#F5C451',
            colTeamName: 'Fenerbahçe',
            colTeamColorHex: '#F5C451',
            cellIndex: 0,
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        final textField = find.byType(TextField);
        if (textField.evaluate().isNotEmpty) {
          await tester.enterText(textField.first, 'Arda');
          await tester.runAsync(() async {
            await Future<void>.delayed(const Duration(milliseconds: 50));
          });
          await tester.pump(const Duration(milliseconds: 350));
        }
      },
    ),
    // 5. Real Who Am I? Mystery Footballer Mode Page
    _InAppScreenSpec(
      fileStem: '05_match_result',
      pageBuilder: () => const WhoAmIPage(),
    ),
    // 6. Real Global ELO LeaderboardPage
    _InAppScreenSpec(
      fileStem: '06_leaderboard',
      pageBuilder: () => const LeaderboardPage(),
    ),
    // 7. Real ProfilePage with Career Stats & Cosmetics
    _InAppScreenSpec(
      fileStem: '07_profile',
      pageBuilder: () => const ProfilePage(),
    ),
    // 8. Real 4-Stage DailyChallengePage
    _InAppScreenSpec(
      fileStem: '08_daily_challenge',
      pageBuilder: () => const DailyChallengePage(),
    ),
  ];

  testWidgets(
    'Captures 100% real full-screen in-app screenshots (8 screens x 7 locales x Android/iOS)',
    (tester) async {
      await tester.runAsync(() async {
        await WebDataStore.instance.init();
      });

      final nowMs = DateTime(2026, 11, 7, 15, 30).millisecondsSinceEpoch;
      const fakeUser = AppUser(
        uid: 'store_captain',
        email: 'captain@goalverse.app',
        displayName: 'ArdaGuler_10',
        isAnonymous: false,
        emailVerified: true,
        providerId: 'password',
      );

      var generatedCount = 0;

      for (final target in _localeTargets) {
        final androidDir = Directory(
          'android/fastlane/metadata/android/${target.androidLocaleDir}/images/phoneScreenshots',
        )..createSync(recursive: true);
        final iosDir = Directory(
          'ios/fastlane/screenshots/${target.iosLocaleDir}',
        )..createSync(recursive: true);

        for (final spec in specs) {
          // 1. Capture Android 1080x1920 (logical 540x960 @ 2.0x)
          final androidBytes = await _captureFullBleedInAppPng(
            tester: tester,
            logicalSize: const Size(540, 960),
            pixelRatio: 2.0,
            locale: target.locale,
            page: spec.pageBuilder(),
            afterLoadAction: spec.afterLoadAction,
            fakeUser: fakeUser,
            nowMs: nowMs,
          );
          final androidFile = File('${androidDir.path}/${spec.fileStem}.png');
          await tester.runAsync(() async {
            await androidFile.writeAsBytes(androidBytes, flush: true);
          });
          generatedCount++;

          // 2. Capture iOS 6.7" 1290x2796 (logical 430x932 @ 3.0x)
          final iosBytes = await _captureFullBleedInAppPng(
            tester: tester,
            logicalSize: const Size(430, 932),
            pixelRatio: 3.0,
            locale: target.locale,
            page: spec.pageBuilder(),
            afterLoadAction: spec.afterLoadAction,
            fakeUser: fakeUser,
            nowMs: nowMs,
          );
          final iosFile = File('${iosDir.path}/${spec.fileStem}.png');
          await tester.runAsync(() async {
            await iosFile.writeAsBytes(iosBytes, flush: true);
          });
          generatedCount++;
        }
      }

      await tester.pumpWidget(const SizedBox.shrink());
      expect(generatedCount, 112);
    },
  );
}

Future<Uint8List> _captureFullBleedInAppPng({
  required WidgetTester tester,
  required Size logicalSize,
  required double pixelRatio,
  required Locale locale,
  required Widget page,
  required Future<void> Function(WidgetTester tester)? afterLoadAction,
  required AppUser fakeUser,
  required int nowMs,
}) async {
  final boundaryKey = GlobalKey();

  final premiumService = PremiumService(
    uid: 'store_captain',
    clockMs: () => nowMs,
  );
  await premiumService.applyServerVerifiedEntitlement({
    'isVerifiedByServer': true,
    'status': 'active',
    'subscriptionProductId': MonetizationProductIds.proYearly,
    'expiresAtMs': nowMs + const Duration(days: 365).inMilliseconds,
    'willRenew': true,
    'storeSource': 'app_store',
    'serverVerifiedAtMs': nowMs,
  });

  final cosmeticService = CosmeticStoreService(
    uid: 'store_captain',
    initialState: const CosmeticStoreState(
      purchasedProductIds: {
        MonetizationProductIds.frameBallonDor,
        MonetizationProductIds.boardRoyalGold,
      },
      equipped: EquippedCosmetics(
        profileFrameId: 'frame_ballon_dor',
        boardThemeId: 'board_royal_gold',
        pitchThemeId: 'pitch_champions_night',
      ),
    ),
  );

  final userStatsNotifier = UserStatsNotifier();
  userStatsNotifier.state = UserStatsState(
    gamesPlayed: 124,
    wins: 89,
    losses: 23,
    draws: 12,
    bestScore: 2480,
    currentStreak: 9,
    bestStreak: 16,
    rating: 1785,
    country: 'TR',
    customDisplayName: 'ArdaGuler_10',
    unlockedAchievements: const {
      'first_win',
      'streak_5',
      'elo_1500',
      'daily_master',
    },
    completedDailyChallenges: const {
      '2026-11-05': 890,
      '2026-11-06': 940,
      '2026-11-07': 980,
    },
    recentMatches: [
      MatchHistorySummary(
        outcome: 'win',
        score: 860,
        ratingDelta: 24,
        passesUsed: 1,
        endedByDrawOffer: false,
        timestampMs: nowMs - 600000,
      ),
      MatchHistorySummary(
        outcome: 'win',
        score: 790,
        ratingDelta: 21,
        passesUsed: 0,
        endedByDrawOffer: false,
        timestampMs: nowMs - 3600000,
      ),
      MatchHistorySummary(
        outcome: 'draw',
        score: 540,
        ratingDelta: 4,
        passesUsed: 2,
        endedByDrawOffer: true,
        timestampMs: nowMs - 7200000,
      ),
    ],
  );

  await tester.binding.setSurfaceSize(logicalSize);
  tester.view.physicalSize = Size(
    logicalSize.width * pixelRatio,
    logicalSize.height * pixelRatio,
  );
  tester.view.devicePixelRatio = pixelRatio;

  await tester.pumpWidget(
    RepaintBoundary(
      key: boundaryKey,
      child: ProviderScope(
        overrides: [
          isarDatabaseProvider.overrideWith((ref) async => null),
          playerRepositoryProvider.overrideWithValue(
            WebDataStore.instance.playerRepo,
          ),
          teamRepositoryProvider.overrideWithValue(
            WebDataStore.instance.teamRepo,
          ),
          answerValidatorRepositoryProvider.overrideWithValue(
            WebDataStore.instance.answerRepo,
          ),
          authRepositoryProvider.overrideWithValue(_FakeAuthRepository(fakeUser)),
          currentUserProvider.overrideWithValue(fakeUser),
          userStatsProvider.overrideWith((_) => userStatsNotifier),
          premiumServiceProvider.overrideWith((_) => premiumService),
          cosmeticStoreServiceProvider.overrideWith((_) => cosmeticService),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: AppTheme.darkTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.dark,
          home: page,
        ),
      ),
    ),
  );

  // Allow post-frame initialization (_init, _loadNewPuzzle, _loadDailyPack, etc.) to complete
  await tester.pump();
  await tester.runAsync(() async {
    await Future<void>.delayed(const Duration(milliseconds: 60));
  });
  await tester.pump(const Duration(milliseconds: 250));
  await tester.pump(const Duration(milliseconds: 250));

  if (afterLoadAction != null) {
    await afterLoadAction(tester);
  }

  final boundary =
      boundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
  final bytes = await tester.runAsync<Uint8List>(() async {
    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return byteData!.buffer.asUint8List();
  });

  // Dispose page cleanly so periodic timers are cancelled before next screen
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();
  if (premiumService.mounted) {
    premiumService.dispose();
  }
  if (cosmeticService.mounted) {
    cosmeticService.dispose();
  }
  if (userStatsNotifier.mounted) {
    userStatsNotifier.dispose();
  }

  return bytes!;
}

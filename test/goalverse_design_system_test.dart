import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:football_tic_tac_toe/core/theme/app_colors.dart';
import 'package:football_tic_tac_toe/core/theme/app_radius.dart';
import 'package:football_tic_tac_toe/core/theme/app_spacing.dart';
import 'package:football_tic_tac_toe/core/theme/app_typography.dart';
import 'package:football_tic_tac_toe/features/home/presentation/home_page.dart';

void main() {
  group('Goalverse Design Tokens', () {
    test('Color tokens match Football Stadium & Pitch palette', () {
      expect(AppColors.stadiumNight, const Color(0xFF101B18));
      expect(AppColors.background, const Color(0xFF101B18));
      expect(AppColors.cardBackground, const Color(0xFF1A2922));
      expect(AppColors.surface, const Color(0xFF1A2922));
      expect(AppColors.pitchGreen, const Color(0xFF173D2B));
      expect(AppColors.surfaceSecondary, const Color(0xFF173D2B));
      expect(AppColors.deepForest, const Color(0xFF20543A));
      expect(AppColors.surfaceElevated, const Color(0xFF20543A));
      expect(AppColors.turfGreen, const Color(0xFF2D754B));
      expect(AppColors.electricLime, const Color(0xFFC6F36B));
      expect(AppColors.primary, const Color(0xFFC6F36B));
      expect(AppColors.warmWhite, const Color(0xFFF5F5ED));
      expect(AppColors.textPrimary, const Color(0xFFF5F5ED));
      expect(AppColors.skyBlue, const Color(0xFF72B7E8));
      expect(AppColors.secondary, const Color(0xFF72B7E8));
      expect(AppColors.trophyGold, const Color(0xFFF3C969));
      expect(AppColors.warning, const Color(0xFFF3C969));
      expect(AppColors.coralRed, const Color(0xFFF07870));
      expect(AppColors.error, const Color(0xFFF07870));
      expect(AppColors.slateGray, const Color(0xFF82918A));
      expect(AppColors.textMuted, const Color(0xFF82918A));
      expect(AppColors.border, const Color(0xFF30483A));
    });

    test('Typography uses Sora, Manrope, and SpaceGrotesk font families', () {
      expect(AppTypography.displayFamily, 'Sora');
      expect(AppTypography.bodyFamily, 'Manrope');
      expect(AppTypography.numericFamily, 'SpaceGrotesk');

      expect(AppTypography.displayLarge().fontFamily, 'Sora');
      expect(AppTypography.headlineMedium().fontFamily, 'Sora');
      expect(AppTypography.bodyLarge().fontFamily, 'Manrope');
      expect(AppTypography.numericLarge().fontFamily, 'SpaceGrotesk');
    });

    test('Spacing and Radius scales match specification', () {
      expect(AppSpacing.s4, 4.0);
      expect(AppSpacing.s8, 8.0);
      expect(AppSpacing.s12, 12.0);
      expect(AppSpacing.s16, 16.0);
      expect(AppSpacing.s20, 20.0);
      expect(AppSpacing.s24, 24.0);
      expect(AppSpacing.s32, 32.0);
      expect(AppSpacing.s40, 40.0);

      expect(AppRadius.sm, 10.0);
      expect(AppRadius.md, 16.0);
      expect(AppRadius.lg, 22.0);
      expect(AppRadius.xl, 28.0);
      expect(AppRadius.pill, 999.0);
    });
  });

  group('GoalverseBottomNav Layout & Navigation', () {
    testWidgets('is pinned at the bottom of the screen and renders all 5 tabs', (
      tester,
    ) async {
      int tappedIndex = -1;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const SizedBox.expand(),
            bottomNavigationBar: GoalverseBottomNav(
              activeIndex: 0,
              isDark: true,
              onArenaTap: () => tappedIndex = 0,
              onOnlineTap: () => tappedIndex = 1,
              onDailyTap: () => tappedIndex = 2,
              onRankingTap: () => tappedIndex = 3,
              onProfileTap: () => tappedIndex = 4,
            ),
          ),
        ),
      );

      expect(find.text('ARENA'), findsOneWidget);
      expect(find.text('ONLINE'), findsOneWidget);
      expect(find.text('DAILY'), findsOneWidget);
      expect(find.text('RANKING'), findsOneWidget);
      expect(find.text('PROFILE'), findsOneWidget);

      final navRect = tester.getRect(find.byType(GoalverseBottomNav));
      final screenSize =
          tester.view.physicalSize / tester.view.devicePixelRatio;

      // Must be pinned at the bottom edge of the screen, NOT centered vertically
      expect(navRect.bottom, closeTo(screenSize.height, 0.5));
      expect(navRect.height, lessThanOrEqualTo(80.0));
      expect(navRect.top, greaterThan(screenSize.height - 85.0));

      await tester.tap(find.text('RANKING'));
      await tester.pump();
      expect(tappedIndex, 3);
    });
  });
}

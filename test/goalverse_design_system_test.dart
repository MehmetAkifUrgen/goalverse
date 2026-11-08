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
      expect(AppColors.background, const Color(0xFF101316));
      expect(AppColors.surface, const Color(0xFF191E23));
      expect(AppColors.surfaceElevated, const Color(0xFF222930));
      expect(AppColors.primary, const Color(0xFFC9FD06));
      expect(AppColors.primaryText, const Color(0xFF101316));
      expect(AppColors.foreground, const Color(0xFFF5F7F8));
      expect(AppColors.border, const Color(0xFF303940));
      expect(AppColors.success, const Color(0xFF45C486));
      expect(AppColors.error, const Color(0xFFE34B5F));
      expect(AppColors.warning, const Color(0xFFF4C65E));
      expect(AppColors.cyberCyan, const Color(0xFF38BDF8));
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

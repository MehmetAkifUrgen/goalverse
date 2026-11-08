import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:football_tic_tac_toe/core/utils/clue_localizer.dart';
import 'package:football_tic_tac_toe/data/models/freezed/entity_models.dart';
import 'package:football_tic_tac_toe/l10n/app_localizations.dart';

void main() {
  testWidgets('ClueLocalizer correctly localizes all 5 clues across languages', (
    tester,
  ) async {
    final player = Player(
      id: 'player_0001',
      name: 'Cristiano Ronaldo',
      normalizedName: 'cristiano ronaldo',
      nationality: 'PT',
      position: 'FW',
      goalsCareer: 915,
      assistsCareer: 255,
      eaFcOverall: 94,
      clubs: ['Sporting CP', 'Manchester United', 'Real Madrid', 'Juventus'],
      clues: [
        'Uyruk: PT | Mevki: Forvet / Hücum',
        'Kariyerinde 915 gol ve 255 asist üretti (Overall: 94).',
        'Oynadığı kulüpler: Sporting CP, Manchester United, Real Madrid, Juventus',
        "5 kez Ballon d'Or kazandı ve Şampiyonlar Ligi tarihinin en golcü oyuncusudur (140 gol).",
        'Baş harfleri: C.R. (16 harfli)',
      ],
    );

    // Test with English locale
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            final clue0 = ClueLocalizer.getClue(player, 0, context);
            final clue1 = ClueLocalizer.getClue(player, 1, context);
            final clue2 = ClueLocalizer.getClue(player, 2, context);
            final clue3 = ClueLocalizer.getClue(player, 3, context);
            final clue4 = ClueLocalizer.getClue(player, 4, context);

            // Verify English keywords and zero Turkish leak
            expect(clue0, contains('Nationality:'));
            expect(clue0, contains('Position:'));
            expect(clue0, contains('Forward / Attacker'));
            expect(clue0, isNot(contains('Uyruk:')));
            expect(clue0, isNot(contains('Mevki:')));

            expect(clue1, contains('Recorded 915 goals and 255 assists'));
            expect(clue1, isNot(contains('Kariyerinde')));

            expect(clue2, contains('Clubs played for:'));
            expect(clue2, isNot(contains('Oynadığı kulüpler:')));

            expect(clue3, contains("5-time Ballon d'Or winner"));
            expect(clue3, isNot(contains('kazandı')));

            expect(clue4, contains('Initials: C.R.'));
            expect(clue4, contains('letters'));
            expect(clue4, isNot(contains('harfli')));

            return const SizedBox.shrink();
          },
        ),
      ),
    );

    // Test with Turkish locale
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('tr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            final clue0 = ClueLocalizer.getClue(player, 0, context);
            final clue3 = ClueLocalizer.getClue(player, 3, context);
            final clue4 = ClueLocalizer.getClue(player, 4, context);

            expect(clue0, contains('Uyruk:'));
            expect(clue0, contains('Mevki:'));
            expect(clue3, contains("5 kez Ballon d'Or kazandı"));
            expect(clue4, contains('harfli'));

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  });
}

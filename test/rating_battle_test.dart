import 'package:flutter_test/flutter_test.dart';
import 'package:football_tic_tac_toe/data/models/freezed/entity_models.dart';
import 'package:football_tic_tac_toe/data/repositories/rating_category.dart';

void main() {
  group('RatingCategory Tests', () {
    final playerA = Player(
      id: 'p1',
      name: 'Player One',
      normalizedName: 'player one',
      eaFcOverall: 90,
      marketValueEuro: 100000000,
      goalsCareer: 400,
      speedRating: 92,
      age: 28,
    );

    final playerB = Player(
      id: 'p2',
      name: 'Player Two',
      normalizedName: 'player two',
      eaFcOverall: 85,
      marketValueEuro: 60000000,
      goalsCareer: 250,
      speedRating: 95,
      age: 22,
    );

    test('valueOf extracts correct properties', () {
      expect(RatingCategory.eaFcOverall.valueOf(playerA), 90);
      expect(RatingCategory.marketValue.valueOf(playerA), 100000000);
      expect(RatingCategory.goalsCareer.valueOf(playerA), 400);
      expect(RatingCategory.speed.valueOf(playerA), 92);
      expect(RatingCategory.age.valueOf(playerA), 28);
    });

    test('higherIsBetter reflects metric logic', () {
      expect(RatingCategory.eaFcOverall.higherIsBetter, isTrue);
      expect(RatingCategory.marketValue.higherIsBetter, isTrue);
      expect(RatingCategory.goalsCareer.higherIsBetter, isTrue);
      expect(RatingCategory.ageLOW.higherIsBetter, isFalse);
    });

    test('player comparison logic works correctly', () {
      final ratingA = RatingCategory.eaFcOverall.valueOf(playerA)!;
      final ratingB = RatingCategory.eaFcOverall.valueOf(playerB)!;
      expect(ratingA > ratingB, isTrue);

      final speedA = RatingCategory.speed.valueOf(playerA)!;
      final speedB = RatingCategory.speed.valueOf(playerB)!;
      expect(speedB > speedA, isTrue);
    });
  });
}

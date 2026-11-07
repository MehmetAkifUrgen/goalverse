import '../models/freezed/entity_models.dart';

enum RatingCategory {
  eaFcOverall,
  marketValue,
  age,
  goalsCareer,
  assistsCareer,
  speed,
  clGoals,
  ageLOW,
}

extension RatingCategoryX on RatingCategory {
  bool get higherIsBetter {
    switch (this) {
      case RatingCategory.eaFcOverall:
      case RatingCategory.marketValue:
      case RatingCategory.goalsCareer:
      case RatingCategory.assistsCareer:
      case RatingCategory.speed:
      case RatingCategory.clGoals:
        return true;
      case RatingCategory.age:
        return true;
      case RatingCategory.ageLOW:
        return false;
    }
  }

  int? valueOf(Player p) {
    switch (this) {
      case RatingCategory.eaFcOverall:
        return p.eaFcOverall;
      case RatingCategory.marketValue:
        return p.marketValueEuro;
      case RatingCategory.age:
      case RatingCategory.ageLOW:
        return p.age;
      case RatingCategory.goalsCareer:
        return p.goalsCareer;
      case RatingCategory.assistsCareer:
        return p.assistsCareer;
      case RatingCategory.speed:
        return p.speedRating;
      case RatingCategory.clGoals:
        return p.clGoals;
    }
  }
}

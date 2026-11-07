class ScoreCalculator {
  static const int baseCorrectPoints = 100;
  static const int streakBonusStep = 25;
  static const int maxStreakBonus = 100;

  int calculateCorrectAnswer({
    int streak = 0,
    int candidatePoolSize = 10,
    bool isDailyChallenge = false,
  }) {
    int score = baseCorrectPoints;

    final streakBonus = (streak * streakBonusStep).clamp(0, maxStreakBonus);
    score += streakBonus;

    if (candidatePoolSize <= 3) {
      score += 50;
    } else if (candidatePoolSize <= 5) {
      score += 25;
    }

    if (isDailyChallenge) {
      score = (score * 1.5).round();
    }

    return score;
  }

  int calculateTimeBonus(int remainingSeconds, int totalSeconds) {
    if (totalSeconds <= 0) return 0;
    final ratio = remainingSeconds / totalSeconds;
    return (ratio * 50).round();
  }

  static int applyDailyChallengeMultiplier(int rawScore) {
    return (rawScore * 1.5).round();
  }
}

abstract class AnswerValidatorRepository {
  Future<bool> isPlayerInTeamPair(
    String playerId,
    String teamIdA,
    String teamIdB,
  );
  Future<List<String>> getPlayersForTeamPair(String teamIdA, String teamIdB);
}

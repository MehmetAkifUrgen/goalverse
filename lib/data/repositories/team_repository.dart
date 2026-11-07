import '../models/freezed/entity_models.dart';

abstract class TeamRepository {
  Future<List<Team>> searchTeams(String query, {int limit = 20});
  Future<Team?> getById(String teamId);
  Future<List<Team>> getAllTeams();
  Future<List<Team>> getByIds(List<String> teamIds);
  Future<List<(Team a, Team b)>> getTeamPairsWithMinPlayers({
    int minPlayersPerPair = 3,
    int limit = 20,
    int? seed,
  });
}

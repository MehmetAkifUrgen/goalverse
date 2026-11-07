import '../models/freezed/entity_models.dart';
import 'rating_category.dart';

abstract class PlayerRepository {
  Future<List<Player>> searchPlayers(String query, {int limit = 20});
  Future<Player?> getById(String playerId);
  Future<List<Player>> getByIds(List<String> playerIds);
  Future<List<Player>> searchPlayersWithClues(String query, {int limit = 20});
  Future<Player?> getRandomWhoAmI({int? seed});
  Future<(Player a, Player b)> getRandomRatingPair({
    RatingCategory? category,
    int? seed,
  });
}

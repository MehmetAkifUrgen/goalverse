import 'package:isar/isar.dart';

import '../models/isar/answer_index_isar.dart';
import 'answer_validator_repository.dart';

class IsarAnswerValidatorRepository implements AnswerValidatorRepository {
  final Isar isar;

  IsarAnswerValidatorRepository(this.isar);

  @override
  Future<bool> isPlayerInTeamPair(
    String playerId,
    String teamIdA,
    String teamIdB,
  ) async {
    final teamPair = _normalizeTeamPair(teamIdA, teamIdB);
    final entry = await isar.answerIndexIsars
        .where()
        .teamPairEqualTo(teamPair)
        .findFirst();

    if (entry == null) return false;
    return entry.playerIds.contains(playerId);
  }

  @override
  Future<List<String>> getPlayersForTeamPair(
    String teamIdA,
    String teamIdB,
  ) async {
    final teamPair = _normalizeTeamPair(teamIdA, teamIdB);
    final entry = await isar.answerIndexIsars
        .where()
        .teamPairEqualTo(teamPair)
        .findFirst();

    return entry?.playerIds ?? const [];
  }

  String _normalizeTeamPair(String teamIdA, String teamIdB) {
    final pair = [teamIdA, teamIdB]..sort();
    return '${pair[0]}|${pair[1]}';
  }
}

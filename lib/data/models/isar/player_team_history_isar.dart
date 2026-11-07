import 'package:isar/isar.dart';

part 'player_team_history_isar.g.dart';

@collection
class PlayerTeamHistoryIsar {
  Id id = Isar.autoIncrement;

  @Index(composite: [CompositeIndex('teamId')])
  late String playerId;

  @Index()
  late String teamId;

  int? seasonStart;

  int? seasonEnd;

  bool verified = false;

  double? confidence;
}

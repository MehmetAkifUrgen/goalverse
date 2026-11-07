import 'package:json_annotation/json_annotation.dart';

part 'player_team_history.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class PlayerTeamHistory {
  final String id;
  final String playerId;
  final String teamId;
  final int? seasonStart;
  final int? seasonEnd;
  final bool verified;
  final double? confidence;

  PlayerTeamHistory({
    required this.id,
    required this.playerId,
    required this.teamId,
    this.seasonStart,
    this.seasonEnd,
    this.verified = false,
    this.confidence,
  });

  factory PlayerTeamHistory.fromJson(Map<String, dynamic> json) =>
      _$PlayerTeamHistoryFromJson(json);

  Map<String, dynamic> toJson() => _$PlayerTeamHistoryToJson(this);

  PlayerTeamHistory copyWith({
    String? id,
    String? playerId,
    String? teamId,
    int? seasonStart,
    int? seasonEnd,
    bool? verified,
    double? confidence,
  }) {
    return PlayerTeamHistory(
      id: id ?? this.id,
      playerId: playerId ?? this.playerId,
      teamId: teamId ?? this.teamId,
      seasonStart: seasonStart ?? this.seasonStart,
      seasonEnd: seasonEnd ?? this.seasonEnd,
      verified: verified ?? this.verified,
      confidence: confidence ?? this.confidence,
    );
  }
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_team_history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlayerTeamHistory _$PlayerTeamHistoryFromJson(Map<String, dynamic> json) =>
    PlayerTeamHistory(
      id: json['id'] as String,
      playerId: json['player_id'] as String,
      teamId: json['team_id'] as String,
      seasonStart: (json['season_start'] as num?)?.toInt(),
      seasonEnd: (json['season_end'] as num?)?.toInt(),
      verified: json['verified'] as bool? ?? false,
      confidence: (json['confidence'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$PlayerTeamHistoryToJson(PlayerTeamHistory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'player_id': instance.playerId,
      'team_id': instance.teamId,
      'season_start': instance.seasonStart,
      'season_end': instance.seasonEnd,
      'verified': instance.verified,
      'confidence': instance.confidence,
    };

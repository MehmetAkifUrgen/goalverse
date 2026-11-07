// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Player _$PlayerFromJson(Map<String, dynamic> json) => Player(
  id: json['id'] as String,
  name: json['name'] as String,
  normalizedName: json['normalizedName'] as String,
  aliases:
      (json['aliases'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  nationality: json['nationality'] as String?,
  position: json['position'] as String?,
  verified: json['verified'] as bool? ?? false,
  eaFcOverall: (json['eaFcOverall'] as num?)?.toInt(),
  marketValueEuro: (json['marketValueEuro'] as num?)?.toInt(),
  age: (json['age'] as num?)?.toInt(),
  goalsCareer: (json['goalsCareer'] as num?)?.toInt(),
  assistsCareer: (json['assistsCareer'] as num?)?.toInt(),
  speedRating: (json['speedRating'] as num?)?.toInt(),
  clGoals: (json['clGoals'] as num?)?.toInt(),
  clues:
      (json['clues'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  photoAssetPath: json['photoAssetPath'] as String?,
  clubs:
      (json['clubs'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$PlayerToJson(Player instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'normalizedName': instance.normalizedName,
  'aliases': instance.aliases,
  'nationality': instance.nationality,
  'position': instance.position,
  'verified': instance.verified,
  'eaFcOverall': instance.eaFcOverall,
  'marketValueEuro': instance.marketValueEuro,
  'age': instance.age,
  'goalsCareer': instance.goalsCareer,
  'assistsCareer': instance.assistsCareer,
  'speedRating': instance.speedRating,
  'clGoals': instance.clGoals,
  'clues': instance.clues,
  'photoAssetPath': instance.photoAssetPath,
  'clubs': instance.clubs,
};

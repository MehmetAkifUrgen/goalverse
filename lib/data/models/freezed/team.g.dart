// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Team _$TeamFromJson(Map<String, dynamic> json) => Team(
  id: json['id'] as String,
  name: json['name'] as String,
  normalizedName: json['normalizedName'] as String,
  aliases:
      (json['aliases'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  country: json['country'] as String?,
  verified: json['verified'] as bool? ?? false,
  primaryColorHex: json['primaryColorHex'] as String?,
  secondaryColorHex: json['secondaryColorHex'] as String?,
  logoAssetPath: json['logoAssetPath'] as String?,
  kitAssetPath: json['kitAssetPath'] as String?,
  logoUrl: json['logoUrl'] as String?,
);

Map<String, dynamic> _$TeamToJson(Team instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'normalizedName': instance.normalizedName,
  'aliases': instance.aliases,
  'country': instance.country,
  'verified': instance.verified,
  'primaryColorHex': instance.primaryColorHex,
  'secondaryColorHex': instance.secondaryColorHex,
  'logoAssetPath': instance.logoAssetPath,
  'kitAssetPath': instance.kitAssetPath,
  'logoUrl': instance.logoUrl,
};

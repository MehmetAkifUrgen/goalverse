import 'package:json_annotation/json_annotation.dart';

part 'team.g.dart';

@JsonSerializable()
class Team {
  final String id;
  final String name;
  final String normalizedName;
  final List<String> aliases;
  final String? country;
  final bool verified;
  final String? primaryColorHex;
  final String? secondaryColorHex;
  final String? logoAssetPath;
  final String? kitAssetPath;
  final String? logoUrl;

  Team({
    required this.id,
    required this.name,
    required this.normalizedName,
    this.aliases = const [],
    this.country,
    this.verified = false,
    this.primaryColorHex,
    this.secondaryColorHex,
    this.logoAssetPath,
    this.kitAssetPath,
    this.logoUrl,
  });

  factory Team.fromJson(Map<String, dynamic> json) => _$TeamFromJson(json);

  Map<String, dynamic> toJson() => _$TeamToJson(this);

  Team copyWith({
    String? id,
    String? name,
    String? normalizedName,
    List<String>? aliases,
    String? country,
    bool? verified,
    String? primaryColorHex,
    String? secondaryColorHex,
    String? logoAssetPath,
    String? kitAssetPath,
  }) {
    return Team(
      id: id ?? this.id,
      name: name ?? this.name,
      normalizedName: normalizedName ?? this.normalizedName,
      aliases: aliases ?? this.aliases,
      country: country ?? this.country,
      verified: verified ?? this.verified,
      primaryColorHex: primaryColorHex ?? this.primaryColorHex,
      secondaryColorHex: secondaryColorHex ?? this.secondaryColorHex,
      logoAssetPath: logoAssetPath ?? this.logoAssetPath,
      kitAssetPath: kitAssetPath ?? this.kitAssetPath,
    );
  }
}

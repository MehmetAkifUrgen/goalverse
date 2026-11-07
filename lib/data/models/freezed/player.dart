import 'package:json_annotation/json_annotation.dart';

part 'player.g.dart';

@JsonSerializable()
class Player {
  final String id;
  final String name;
  final String normalizedName;
  final List<String> aliases;
  final String? nationality;
  final String? position;
  final bool verified;
  final int? eaFcOverall;
  final int? marketValueEuro;
  final int? age;
  final int? goalsCareer;
  final int? assistsCareer;
  final int? speedRating;
  final int? clGoals;
  final List<String> clues;
  final String? photoAssetPath;
  final List<String> clubs;

  Player({
    required this.id,
    required this.name,
    required this.normalizedName,
    this.aliases = const [],
    this.nationality,
    this.position,
    this.verified = false,
    this.eaFcOverall,
    this.marketValueEuro,
    this.age,
    this.goalsCareer,
    this.assistsCareer,
    this.speedRating,
    this.clGoals,
    this.clues = const [],
    this.photoAssetPath,
    this.clubs = const [],
  });

  factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);

  Map<String, dynamic> toJson() => _$PlayerToJson(this);

  Player copyWith({
    String? id,
    String? name,
    String? normalizedName,
    List<String>? aliases,
    String? nationality,
    String? position,
    bool? verified,
    int? eaFcOverall,
    int? marketValueEuro,
    int? age,
    int? goalsCareer,
    int? assistsCareer,
    int? speedRating,
    int? clGoals,
    List<String>? clues,
    String? photoAssetPath,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      normalizedName: normalizedName ?? this.normalizedName,
      aliases: aliases ?? this.aliases,
      nationality: nationality ?? this.nationality,
      position: position ?? this.position,
      verified: verified ?? this.verified,
      eaFcOverall: eaFcOverall ?? this.eaFcOverall,
      marketValueEuro: marketValueEuro ?? this.marketValueEuro,
      age: age ?? this.age,
      goalsCareer: goalsCareer ?? this.goalsCareer,
      assistsCareer: assistsCareer ?? this.assistsCareer,
      speedRating: speedRating ?? this.speedRating,
      clGoals: clGoals ?? this.clGoals,
      clues: clues ?? this.clues,
      photoAssetPath: photoAssetPath ?? this.photoAssetPath,
    );
  }
}

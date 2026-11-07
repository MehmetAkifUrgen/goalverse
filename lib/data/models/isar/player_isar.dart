import 'package:isar/isar.dart';

part 'player_isar.g.dart';

@collection
class PlayerIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String playerId;

  @Index(caseSensitive: false)
  late String name;

  @Index(caseSensitive: false, type: IndexType.value)
  late String normalizedName;

  List<String>? aliases;

  String? nationality;

  String? position;

  bool verified = false;

  @Index()
  int? eaFcOverall;

  int? marketValueEuro;

  int? age;

  int? goalsCareer;

  int? assistsCareer;

  int? speedRating;

  int? clGoals;

  List<String>? clues;

  String? photoAssetPath;
}

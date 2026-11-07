import 'package:isar/isar.dart';

part 'team_isar.g.dart';

@collection
class TeamIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String teamId;

  @Index(caseSensitive: false)
  late String name;

  @Index(caseSensitive: false, type: IndexType.value)
  late String normalizedName;

  List<String>? aliases;

  String? country;

  bool verified = false;

  String? primaryColorHex;

  String? secondaryColorHex;

  String? logoAssetPath;

  String? kitAssetPath;
}

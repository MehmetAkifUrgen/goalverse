import 'package:isar/isar.dart';

part 'answer_index_isar.g.dart';

@collection
class AnswerIndexIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true, type: IndexType.hash)
  late String teamPair;

  late List<String> playerIds;
}

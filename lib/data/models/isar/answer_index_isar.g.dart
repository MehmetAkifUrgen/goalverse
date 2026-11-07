// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'answer_index_isar.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAnswerIndexIsarCollection on Isar {
  IsarCollection<AnswerIndexIsar> get answerIndexIsars => this.collection();
}

const AnswerIndexIsarSchema = CollectionSchema(
  name: r'AnswerIndexIsar',
  id: 252973495891963,
  properties: {
    r'playerIds': PropertySchema(
      id: 0,
      name: r'playerIds',
      type: IsarType.stringList,
    ),
    r'teamPair': PropertySchema(
      id: 1,
      name: r'teamPair',
      type: IsarType.string,
    ),
  },
  estimateSize: _answerIndexIsarEstimateSize,
  serialize: _answerIndexIsarSerialize,
  deserialize: _answerIndexIsarDeserialize,
  deserializeProp: _answerIndexIsarDeserializeProp,
  idName: r'id',
  indexes: {
    r'teamPair': IndexSchema(
      id: -803577650360776,
      name: r'teamPair',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'teamPair',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},
  getId: _answerIndexIsarGetId,
  getLinks: _answerIndexIsarGetLinks,
  attach: _answerIndexIsarAttach,
  version: '3.1.0+1',
);

int _answerIndexIsarEstimateSize(
  AnswerIndexIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.playerIds.length * 3;
  {
    for (var i = 0; i < object.playerIds.length; i++) {
      final value = object.playerIds[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.teamPair.length * 3;
  return bytesCount;
}

void _answerIndexIsarSerialize(
  AnswerIndexIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeStringList(offsets[0], object.playerIds);
  writer.writeString(offsets[1], object.teamPair);
}

AnswerIndexIsar _answerIndexIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AnswerIndexIsar();
  object.id = id;
  object.playerIds = reader.readStringList(offsets[0]) ?? [];
  object.teamPair = reader.readString(offsets[1]);
  return object;
}

P _answerIndexIsarDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringList(offset) ?? []) as P;
    case 1:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _answerIndexIsarGetId(AnswerIndexIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _answerIndexIsarGetLinks(AnswerIndexIsar object) {
  return [];
}

void _answerIndexIsarAttach(
  IsarCollection<dynamic> col,
  Id id,
  AnswerIndexIsar object,
) {
  object.id = id;
}

extension AnswerIndexIsarByIndex on IsarCollection<AnswerIndexIsar> {
  Future<AnswerIndexIsar?> getByTeamPair(String teamPair) {
    return getByIndex(r'teamPair', [teamPair]);
  }

  AnswerIndexIsar? getByTeamPairSync(String teamPair) {
    return getByIndexSync(r'teamPair', [teamPair]);
  }

  Future<bool> deleteByTeamPair(String teamPair) {
    return deleteByIndex(r'teamPair', [teamPair]);
  }

  bool deleteByTeamPairSync(String teamPair) {
    return deleteByIndexSync(r'teamPair', [teamPair]);
  }

  Future<List<AnswerIndexIsar?>> getAllByTeamPair(List<String> teamPairValues) {
    final values = teamPairValues.map((e) => [e]).toList();
    return getAllByIndex(r'teamPair', values);
  }

  List<AnswerIndexIsar?> getAllByTeamPairSync(List<String> teamPairValues) {
    final values = teamPairValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'teamPair', values);
  }

  Future<int> deleteAllByTeamPair(List<String> teamPairValues) {
    final values = teamPairValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'teamPair', values);
  }

  int deleteAllByTeamPairSync(List<String> teamPairValues) {
    final values = teamPairValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'teamPair', values);
  }

  Future<Id> putByTeamPair(AnswerIndexIsar object) {
    return putByIndex(r'teamPair', object);
  }

  Id putByTeamPairSync(AnswerIndexIsar object, {bool saveLinks = true}) {
    return putByIndexSync(r'teamPair', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByTeamPair(List<AnswerIndexIsar> objects) {
    return putAllByIndex(r'teamPair', objects);
  }

  List<Id> putAllByTeamPairSync(
    List<AnswerIndexIsar> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'teamPair', objects, saveLinks: saveLinks);
  }
}

extension AnswerIndexIsarQueryWhereSort
    on QueryBuilder<AnswerIndexIsar, AnswerIndexIsar, QWhere> {
  QueryBuilder<AnswerIndexIsar, AnswerIndexIsar, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AnswerIndexIsarQueryWhere
    on QueryBuilder<AnswerIndexIsar, AnswerIndexIsar, QWhereClause> {
  QueryBuilder<AnswerIndexIsar, AnswerIndexIsar, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<AnswerIndexIsar, AnswerIndexIsar, QAfterWhereClause>
  idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<AnswerIndexIsar, AnswerIndexIsar, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AnswerIndexIsar, AnswerIndexIsar, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AnswerIndexIsar, AnswerIndexIsar, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<AnswerIndexIsar, AnswerIndexIsar, QAfterWhereClause>
  teamPairEqualTo(String teamPair) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'teamPair', value: [teamPair]),
      );
    });
  }

  QueryBuilder<AnswerIndexIsar, AnswerIndexIsar, QAfterWhereClause>
  teamPairNotEqualTo(String teamPair) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'teamPair',
                lower: [],
                upper: [teamPair],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'teamPair',
                lower: [teamPair],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'teamPair',
                lower: [teamPair],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'teamPair',
                lower: [],
                upper: [teamPair],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension AnswerIndexIsarQueryFilter
    on QueryBuilder<AnswerIndexIsar, AnswerIndexIsar, QFilterCondition> {
  QueryBuilder<AnswerIndexIsar, AnswerIndexIsar, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<AnswerIndexIsar, AnswerIndexIsar, QAfterFilterCondition>
  idGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AnswerIndexIsar, AnswerIndexIsar, QAfterFilterCondition>
  idLessThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AnswerIndexIsar, AnswerIndexIsar, QAfterFilterCondition>
  idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<AnswerIndexIsar, AnswerIndexIsar, QAfterFilterCondition>
  playerIdsElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'playerIds',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnswerIndexIsar, AnswerIndexIsar, QAfterFilterCondition>
  playerIdsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'playerIds',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnswerIndexIsar, AnswerIndexIsar, QAfterFilterCondition>
  playerIdsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'playerIds',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnswerIndexIsar, AnswerIndexIsar, QAfterFilterCondition>
  playerIdsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'playerIds',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnswerIndexIsar, AnswerIndexIsar, QAfterFilterCondition>
  playerIdsElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'playerIds',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnswerIndexIsar, AnswerIndexIsar, QAfterFilterCondition>
  playerIdsElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'playerIds',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnswerIndexIsar, AnswerIndexIsar, QAfterFilterCondition>
  playerIdsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'playerIds',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnswerIndexIsar, AnswerIndexIsar, QAfterFilterCondition>
  playerIdsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'playerIds',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnswerIndexIsar, AnswerIndexIsar, QAfterFilterCondition>
  playerIdsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'playerIds', value: ''),
      );
    });
  }

  QueryBuilder<AnswerIndexIsar, AnswerIndexIsar, QAfterFilterCondition>
  playerIdsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'playerIds', value: ''),
      );
    });
  }

  QueryBuilder<AnswerIndexIsar, AnswerIndexIsar, QAfterFilterCondition>
  playerIdsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'playerIds', length, true, length, true);
    });
  }

  QueryBuilder<AnswerIndexIsar, AnswerIndexIsar, QAfterFilterCondition>
  playerIdsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'playerIds', 0, true, 0, true);
    });
  }

  QueryBuilder<AnswerIndexIsar, AnswerIndexIsar, QAfterFilterCondition>
  playerIdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'playerIds', 0, false, 999999, true);
    });
  }

  QueryBuilder<AnswerIndexIsar, AnswerIndexIsar, QAfterFilterCondition>
  playerIdsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'playerIds', 0, true, length, include);
    });
  }

  QueryBuilder<AnswerIndexIsar, AnswerIndexIsar, QAfterFilterCondition>
  playerIdsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'playerIds', length, include, 999999, true);
    });
  }

  QueryBuilder<AnswerIndexIsar, AnswerIndexIsar, QAfterFilterCondition>
  playerIdsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'playerIds',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<AnswerIndexIsar, AnswerIndexIsar, QAfterFilterCondition>
  teamPairEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'teamPair',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnswerIndexIsar, AnswerIndexIsar, QAfterFilterCondition>
  teamPairGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'teamPair',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnswerIndexIsar, AnswerIndexIsar, QAfterFilterCondition>
  teamPairLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'teamPair',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnswerIndexIsar, AnswerIndexIsar, QAfterFilterCondition>
  teamPairBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'teamPair',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnswerIndexIsar, AnswerIndexIsar, QAfterFilterCondition>
  teamPairStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'teamPair',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnswerIndexIsar, AnswerIndexIsar, QAfterFilterCondition>
  teamPairEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'teamPair',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnswerIndexIsar, AnswerIndexIsar, QAfterFilterCondition>
  teamPairContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'teamPair',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnswerIndexIsar, AnswerIndexIsar, QAfterFilterCondition>
  teamPairMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'teamPair',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AnswerIndexIsar, AnswerIndexIsar, QAfterFilterCondition>
  teamPairIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'teamPair', value: ''),
      );
    });
  }

  QueryBuilder<AnswerIndexIsar, AnswerIndexIsar, QAfterFilterCondition>
  teamPairIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'teamPair', value: ''),
      );
    });
  }
}

extension AnswerIndexIsarQueryObject
    on QueryBuilder<AnswerIndexIsar, AnswerIndexIsar, QFilterCondition> {}

extension AnswerIndexIsarQueryLinks
    on QueryBuilder<AnswerIndexIsar, AnswerIndexIsar, QFilterCondition> {}

extension AnswerIndexIsarQuerySortBy
    on QueryBuilder<AnswerIndexIsar, AnswerIndexIsar, QSortBy> {
  QueryBuilder<AnswerIndexIsar, AnswerIndexIsar, QAfterSortBy>
  sortByTeamPair() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'teamPair', Sort.asc);
    });
  }

  QueryBuilder<AnswerIndexIsar, AnswerIndexIsar, QAfterSortBy>
  sortByTeamPairDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'teamPair', Sort.desc);
    });
  }
}

extension AnswerIndexIsarQuerySortThenBy
    on QueryBuilder<AnswerIndexIsar, AnswerIndexIsar, QSortThenBy> {
  QueryBuilder<AnswerIndexIsar, AnswerIndexIsar, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AnswerIndexIsar, AnswerIndexIsar, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AnswerIndexIsar, AnswerIndexIsar, QAfterSortBy>
  thenByTeamPair() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'teamPair', Sort.asc);
    });
  }

  QueryBuilder<AnswerIndexIsar, AnswerIndexIsar, QAfterSortBy>
  thenByTeamPairDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'teamPair', Sort.desc);
    });
  }
}

extension AnswerIndexIsarQueryWhereDistinct
    on QueryBuilder<AnswerIndexIsar, AnswerIndexIsar, QDistinct> {
  QueryBuilder<AnswerIndexIsar, AnswerIndexIsar, QDistinct>
  distinctByPlayerIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'playerIds');
    });
  }

  QueryBuilder<AnswerIndexIsar, AnswerIndexIsar, QDistinct> distinctByTeamPair({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'teamPair', caseSensitive: caseSensitive);
    });
  }
}

extension AnswerIndexIsarQueryProperty
    on QueryBuilder<AnswerIndexIsar, AnswerIndexIsar, QQueryProperty> {
  QueryBuilder<AnswerIndexIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AnswerIndexIsar, List<String>, QQueryOperations>
  playerIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'playerIds');
    });
  }

  QueryBuilder<AnswerIndexIsar, String, QQueryOperations> teamPairProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'teamPair');
    });
  }
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_team_history_isar.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPlayerTeamHistoryIsarCollection on Isar {
  IsarCollection<PlayerTeamHistoryIsar> get playerTeamHistoryIsars =>
      this.collection();
}

const PlayerTeamHistoryIsarSchema = CollectionSchema(
  name: r'PlayerTeamHistoryIsar',
  id: 313582562284343,
  properties: {
    r'confidence': PropertySchema(
      id: 0,
      name: r'confidence',
      type: IsarType.double,
    ),
    r'playerId': PropertySchema(
      id: 1,
      name: r'playerId',
      type: IsarType.string,
    ),
    r'seasonEnd': PropertySchema(
      id: 2,
      name: r'seasonEnd',
      type: IsarType.long,
    ),
    r'seasonStart': PropertySchema(
      id: 3,
      name: r'seasonStart',
      type: IsarType.long,
    ),
    r'teamId': PropertySchema(id: 4, name: r'teamId', type: IsarType.string),
    r'verified': PropertySchema(id: 5, name: r'verified', type: IsarType.bool),
  },
  estimateSize: _playerTeamHistoryIsarEstimateSize,
  serialize: _playerTeamHistoryIsarSerialize,
  deserialize: _playerTeamHistoryIsarDeserialize,
  deserializeProp: _playerTeamHistoryIsarDeserializeProp,
  idName: r'id',
  indexes: {
    r'playerId_teamId': IndexSchema(
      id: -219775047179718,
      name: r'playerId_teamId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'playerId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
        IndexPropertySchema(
          name: r'teamId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'teamId': IndexSchema(
      id: 889449891813377,
      name: r'teamId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'teamId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},
  getId: _playerTeamHistoryIsarGetId,
  getLinks: _playerTeamHistoryIsarGetLinks,
  attach: _playerTeamHistoryIsarAttach,
  version: '3.1.0+1',
);

int _playerTeamHistoryIsarEstimateSize(
  PlayerTeamHistoryIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.playerId.length * 3;
  bytesCount += 3 + object.teamId.length * 3;
  return bytesCount;
}

void _playerTeamHistoryIsarSerialize(
  PlayerTeamHistoryIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.confidence);
  writer.writeString(offsets[1], object.playerId);
  writer.writeLong(offsets[2], object.seasonEnd);
  writer.writeLong(offsets[3], object.seasonStart);
  writer.writeString(offsets[4], object.teamId);
  writer.writeBool(offsets[5], object.verified);
}

PlayerTeamHistoryIsar _playerTeamHistoryIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PlayerTeamHistoryIsar();
  object.confidence = reader.readDoubleOrNull(offsets[0]);
  object.id = id;
  object.playerId = reader.readString(offsets[1]);
  object.seasonEnd = reader.readLongOrNull(offsets[2]);
  object.seasonStart = reader.readLongOrNull(offsets[3]);
  object.teamId = reader.readString(offsets[4]);
  object.verified = reader.readBool(offsets[5]);
  return object;
}

P _playerTeamHistoryIsarDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDoubleOrNull(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readLongOrNull(offset)) as P;
    case 3:
      return (reader.readLongOrNull(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _playerTeamHistoryIsarGetId(PlayerTeamHistoryIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _playerTeamHistoryIsarGetLinks(
  PlayerTeamHistoryIsar object,
) {
  return [];
}

void _playerTeamHistoryIsarAttach(
  IsarCollection<dynamic> col,
  Id id,
  PlayerTeamHistoryIsar object,
) {
  object.id = id;
}

extension PlayerTeamHistoryIsarQueryWhereSort
    on QueryBuilder<PlayerTeamHistoryIsar, PlayerTeamHistoryIsar, QWhere> {
  QueryBuilder<PlayerTeamHistoryIsar, PlayerTeamHistoryIsar, QAfterWhere>
  anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PlayerTeamHistoryIsarQueryWhere
    on
        QueryBuilder<
          PlayerTeamHistoryIsar,
          PlayerTeamHistoryIsar,
          QWhereClause
        > {
  QueryBuilder<PlayerTeamHistoryIsar, PlayerTeamHistoryIsar, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<PlayerTeamHistoryIsar, PlayerTeamHistoryIsar, QAfterWhereClause>
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

  QueryBuilder<PlayerTeamHistoryIsar, PlayerTeamHistoryIsar, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PlayerTeamHistoryIsar, PlayerTeamHistoryIsar, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PlayerTeamHistoryIsar, PlayerTeamHistoryIsar, QAfterWhereClause>
  idBetween(
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

  QueryBuilder<PlayerTeamHistoryIsar, PlayerTeamHistoryIsar, QAfterWhereClause>
  playerIdEqualToAnyTeamId(String playerId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'playerId_teamId',
          value: [playerId],
        ),
      );
    });
  }

  QueryBuilder<PlayerTeamHistoryIsar, PlayerTeamHistoryIsar, QAfterWhereClause>
  playerIdNotEqualToAnyTeamId(String playerId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'playerId_teamId',
                lower: [],
                upper: [playerId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'playerId_teamId',
                lower: [playerId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'playerId_teamId',
                lower: [playerId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'playerId_teamId',
                lower: [],
                upper: [playerId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<PlayerTeamHistoryIsar, PlayerTeamHistoryIsar, QAfterWhereClause>
  playerIdTeamIdEqualTo(String playerId, String teamId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'playerId_teamId',
          value: [playerId, teamId],
        ),
      );
    });
  }

  QueryBuilder<PlayerTeamHistoryIsar, PlayerTeamHistoryIsar, QAfterWhereClause>
  playerIdEqualToTeamIdNotEqualTo(String playerId, String teamId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'playerId_teamId',
                lower: [playerId],
                upper: [playerId, teamId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'playerId_teamId',
                lower: [playerId, teamId],
                includeLower: false,
                upper: [playerId],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'playerId_teamId',
                lower: [playerId, teamId],
                includeLower: false,
                upper: [playerId],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'playerId_teamId',
                lower: [playerId],
                upper: [playerId, teamId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<PlayerTeamHistoryIsar, PlayerTeamHistoryIsar, QAfterWhereClause>
  teamIdEqualTo(String teamId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'teamId', value: [teamId]),
      );
    });
  }

  QueryBuilder<PlayerTeamHistoryIsar, PlayerTeamHistoryIsar, QAfterWhereClause>
  teamIdNotEqualTo(String teamId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'teamId',
                lower: [],
                upper: [teamId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'teamId',
                lower: [teamId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'teamId',
                lower: [teamId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'teamId',
                lower: [],
                upper: [teamId],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension PlayerTeamHistoryIsarQueryFilter
    on
        QueryBuilder<
          PlayerTeamHistoryIsar,
          PlayerTeamHistoryIsar,
          QFilterCondition
        > {
  QueryBuilder<
    PlayerTeamHistoryIsar,
    PlayerTeamHistoryIsar,
    QAfterFilterCondition
  >
  confidenceIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'confidence'),
      );
    });
  }

  QueryBuilder<
    PlayerTeamHistoryIsar,
    PlayerTeamHistoryIsar,
    QAfterFilterCondition
  >
  confidenceIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'confidence'),
      );
    });
  }

  QueryBuilder<
    PlayerTeamHistoryIsar,
    PlayerTeamHistoryIsar,
    QAfterFilterCondition
  >
  confidenceEqualTo(double? value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'confidence',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    PlayerTeamHistoryIsar,
    PlayerTeamHistoryIsar,
    QAfterFilterCondition
  >
  confidenceGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'confidence',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    PlayerTeamHistoryIsar,
    PlayerTeamHistoryIsar,
    QAfterFilterCondition
  >
  confidenceLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'confidence',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    PlayerTeamHistoryIsar,
    PlayerTeamHistoryIsar,
    QAfterFilterCondition
  >
  confidenceBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'confidence',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    PlayerTeamHistoryIsar,
    PlayerTeamHistoryIsar,
    QAfterFilterCondition
  >
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<
    PlayerTeamHistoryIsar,
    PlayerTeamHistoryIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    PlayerTeamHistoryIsar,
    PlayerTeamHistoryIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    PlayerTeamHistoryIsar,
    PlayerTeamHistoryIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    PlayerTeamHistoryIsar,
    PlayerTeamHistoryIsar,
    QAfterFilterCondition
  >
  playerIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'playerId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PlayerTeamHistoryIsar,
    PlayerTeamHistoryIsar,
    QAfterFilterCondition
  >
  playerIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'playerId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PlayerTeamHistoryIsar,
    PlayerTeamHistoryIsar,
    QAfterFilterCondition
  >
  playerIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'playerId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PlayerTeamHistoryIsar,
    PlayerTeamHistoryIsar,
    QAfterFilterCondition
  >
  playerIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'playerId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PlayerTeamHistoryIsar,
    PlayerTeamHistoryIsar,
    QAfterFilterCondition
  >
  playerIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'playerId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PlayerTeamHistoryIsar,
    PlayerTeamHistoryIsar,
    QAfterFilterCondition
  >
  playerIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'playerId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PlayerTeamHistoryIsar,
    PlayerTeamHistoryIsar,
    QAfterFilterCondition
  >
  playerIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'playerId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PlayerTeamHistoryIsar,
    PlayerTeamHistoryIsar,
    QAfterFilterCondition
  >
  playerIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'playerId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PlayerTeamHistoryIsar,
    PlayerTeamHistoryIsar,
    QAfterFilterCondition
  >
  playerIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'playerId', value: ''),
      );
    });
  }

  QueryBuilder<
    PlayerTeamHistoryIsar,
    PlayerTeamHistoryIsar,
    QAfterFilterCondition
  >
  playerIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'playerId', value: ''),
      );
    });
  }

  QueryBuilder<
    PlayerTeamHistoryIsar,
    PlayerTeamHistoryIsar,
    QAfterFilterCondition
  >
  seasonEndIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'seasonEnd'),
      );
    });
  }

  QueryBuilder<
    PlayerTeamHistoryIsar,
    PlayerTeamHistoryIsar,
    QAfterFilterCondition
  >
  seasonEndIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'seasonEnd'),
      );
    });
  }

  QueryBuilder<
    PlayerTeamHistoryIsar,
    PlayerTeamHistoryIsar,
    QAfterFilterCondition
  >
  seasonEndEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'seasonEnd', value: value),
      );
    });
  }

  QueryBuilder<
    PlayerTeamHistoryIsar,
    PlayerTeamHistoryIsar,
    QAfterFilterCondition
  >
  seasonEndGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'seasonEnd',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    PlayerTeamHistoryIsar,
    PlayerTeamHistoryIsar,
    QAfterFilterCondition
  >
  seasonEndLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'seasonEnd',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    PlayerTeamHistoryIsar,
    PlayerTeamHistoryIsar,
    QAfterFilterCondition
  >
  seasonEndBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'seasonEnd',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    PlayerTeamHistoryIsar,
    PlayerTeamHistoryIsar,
    QAfterFilterCondition
  >
  seasonStartIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'seasonStart'),
      );
    });
  }

  QueryBuilder<
    PlayerTeamHistoryIsar,
    PlayerTeamHistoryIsar,
    QAfterFilterCondition
  >
  seasonStartIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'seasonStart'),
      );
    });
  }

  QueryBuilder<
    PlayerTeamHistoryIsar,
    PlayerTeamHistoryIsar,
    QAfterFilterCondition
  >
  seasonStartEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'seasonStart', value: value),
      );
    });
  }

  QueryBuilder<
    PlayerTeamHistoryIsar,
    PlayerTeamHistoryIsar,
    QAfterFilterCondition
  >
  seasonStartGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'seasonStart',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    PlayerTeamHistoryIsar,
    PlayerTeamHistoryIsar,
    QAfterFilterCondition
  >
  seasonStartLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'seasonStart',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    PlayerTeamHistoryIsar,
    PlayerTeamHistoryIsar,
    QAfterFilterCondition
  >
  seasonStartBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'seasonStart',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    PlayerTeamHistoryIsar,
    PlayerTeamHistoryIsar,
    QAfterFilterCondition
  >
  teamIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'teamId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PlayerTeamHistoryIsar,
    PlayerTeamHistoryIsar,
    QAfterFilterCondition
  >
  teamIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'teamId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PlayerTeamHistoryIsar,
    PlayerTeamHistoryIsar,
    QAfterFilterCondition
  >
  teamIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'teamId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PlayerTeamHistoryIsar,
    PlayerTeamHistoryIsar,
    QAfterFilterCondition
  >
  teamIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'teamId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PlayerTeamHistoryIsar,
    PlayerTeamHistoryIsar,
    QAfterFilterCondition
  >
  teamIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'teamId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PlayerTeamHistoryIsar,
    PlayerTeamHistoryIsar,
    QAfterFilterCondition
  >
  teamIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'teamId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PlayerTeamHistoryIsar,
    PlayerTeamHistoryIsar,
    QAfterFilterCondition
  >
  teamIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'teamId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PlayerTeamHistoryIsar,
    PlayerTeamHistoryIsar,
    QAfterFilterCondition
  >
  teamIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'teamId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PlayerTeamHistoryIsar,
    PlayerTeamHistoryIsar,
    QAfterFilterCondition
  >
  teamIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'teamId', value: ''),
      );
    });
  }

  QueryBuilder<
    PlayerTeamHistoryIsar,
    PlayerTeamHistoryIsar,
    QAfterFilterCondition
  >
  teamIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'teamId', value: ''),
      );
    });
  }

  QueryBuilder<
    PlayerTeamHistoryIsar,
    PlayerTeamHistoryIsar,
    QAfterFilterCondition
  >
  verifiedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'verified', value: value),
      );
    });
  }
}

extension PlayerTeamHistoryIsarQueryObject
    on
        QueryBuilder<
          PlayerTeamHistoryIsar,
          PlayerTeamHistoryIsar,
          QFilterCondition
        > {}

extension PlayerTeamHistoryIsarQueryLinks
    on
        QueryBuilder<
          PlayerTeamHistoryIsar,
          PlayerTeamHistoryIsar,
          QFilterCondition
        > {}

extension PlayerTeamHistoryIsarQuerySortBy
    on QueryBuilder<PlayerTeamHistoryIsar, PlayerTeamHistoryIsar, QSortBy> {
  QueryBuilder<PlayerTeamHistoryIsar, PlayerTeamHistoryIsar, QAfterSortBy>
  sortByConfidence() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confidence', Sort.asc);
    });
  }

  QueryBuilder<PlayerTeamHistoryIsar, PlayerTeamHistoryIsar, QAfterSortBy>
  sortByConfidenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confidence', Sort.desc);
    });
  }

  QueryBuilder<PlayerTeamHistoryIsar, PlayerTeamHistoryIsar, QAfterSortBy>
  sortByPlayerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playerId', Sort.asc);
    });
  }

  QueryBuilder<PlayerTeamHistoryIsar, PlayerTeamHistoryIsar, QAfterSortBy>
  sortByPlayerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playerId', Sort.desc);
    });
  }

  QueryBuilder<PlayerTeamHistoryIsar, PlayerTeamHistoryIsar, QAfterSortBy>
  sortBySeasonEnd() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seasonEnd', Sort.asc);
    });
  }

  QueryBuilder<PlayerTeamHistoryIsar, PlayerTeamHistoryIsar, QAfterSortBy>
  sortBySeasonEndDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seasonEnd', Sort.desc);
    });
  }

  QueryBuilder<PlayerTeamHistoryIsar, PlayerTeamHistoryIsar, QAfterSortBy>
  sortBySeasonStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seasonStart', Sort.asc);
    });
  }

  QueryBuilder<PlayerTeamHistoryIsar, PlayerTeamHistoryIsar, QAfterSortBy>
  sortBySeasonStartDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seasonStart', Sort.desc);
    });
  }

  QueryBuilder<PlayerTeamHistoryIsar, PlayerTeamHistoryIsar, QAfterSortBy>
  sortByTeamId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'teamId', Sort.asc);
    });
  }

  QueryBuilder<PlayerTeamHistoryIsar, PlayerTeamHistoryIsar, QAfterSortBy>
  sortByTeamIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'teamId', Sort.desc);
    });
  }

  QueryBuilder<PlayerTeamHistoryIsar, PlayerTeamHistoryIsar, QAfterSortBy>
  sortByVerified() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verified', Sort.asc);
    });
  }

  QueryBuilder<PlayerTeamHistoryIsar, PlayerTeamHistoryIsar, QAfterSortBy>
  sortByVerifiedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verified', Sort.desc);
    });
  }
}

extension PlayerTeamHistoryIsarQuerySortThenBy
    on QueryBuilder<PlayerTeamHistoryIsar, PlayerTeamHistoryIsar, QSortThenBy> {
  QueryBuilder<PlayerTeamHistoryIsar, PlayerTeamHistoryIsar, QAfterSortBy>
  thenByConfidence() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confidence', Sort.asc);
    });
  }

  QueryBuilder<PlayerTeamHistoryIsar, PlayerTeamHistoryIsar, QAfterSortBy>
  thenByConfidenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confidence', Sort.desc);
    });
  }

  QueryBuilder<PlayerTeamHistoryIsar, PlayerTeamHistoryIsar, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PlayerTeamHistoryIsar, PlayerTeamHistoryIsar, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PlayerTeamHistoryIsar, PlayerTeamHistoryIsar, QAfterSortBy>
  thenByPlayerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playerId', Sort.asc);
    });
  }

  QueryBuilder<PlayerTeamHistoryIsar, PlayerTeamHistoryIsar, QAfterSortBy>
  thenByPlayerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playerId', Sort.desc);
    });
  }

  QueryBuilder<PlayerTeamHistoryIsar, PlayerTeamHistoryIsar, QAfterSortBy>
  thenBySeasonEnd() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seasonEnd', Sort.asc);
    });
  }

  QueryBuilder<PlayerTeamHistoryIsar, PlayerTeamHistoryIsar, QAfterSortBy>
  thenBySeasonEndDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seasonEnd', Sort.desc);
    });
  }

  QueryBuilder<PlayerTeamHistoryIsar, PlayerTeamHistoryIsar, QAfterSortBy>
  thenBySeasonStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seasonStart', Sort.asc);
    });
  }

  QueryBuilder<PlayerTeamHistoryIsar, PlayerTeamHistoryIsar, QAfterSortBy>
  thenBySeasonStartDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seasonStart', Sort.desc);
    });
  }

  QueryBuilder<PlayerTeamHistoryIsar, PlayerTeamHistoryIsar, QAfterSortBy>
  thenByTeamId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'teamId', Sort.asc);
    });
  }

  QueryBuilder<PlayerTeamHistoryIsar, PlayerTeamHistoryIsar, QAfterSortBy>
  thenByTeamIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'teamId', Sort.desc);
    });
  }

  QueryBuilder<PlayerTeamHistoryIsar, PlayerTeamHistoryIsar, QAfterSortBy>
  thenByVerified() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verified', Sort.asc);
    });
  }

  QueryBuilder<PlayerTeamHistoryIsar, PlayerTeamHistoryIsar, QAfterSortBy>
  thenByVerifiedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verified', Sort.desc);
    });
  }
}

extension PlayerTeamHistoryIsarQueryWhereDistinct
    on QueryBuilder<PlayerTeamHistoryIsar, PlayerTeamHistoryIsar, QDistinct> {
  QueryBuilder<PlayerTeamHistoryIsar, PlayerTeamHistoryIsar, QDistinct>
  distinctByConfidence() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'confidence');
    });
  }

  QueryBuilder<PlayerTeamHistoryIsar, PlayerTeamHistoryIsar, QDistinct>
  distinctByPlayerId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'playerId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PlayerTeamHistoryIsar, PlayerTeamHistoryIsar, QDistinct>
  distinctBySeasonEnd() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'seasonEnd');
    });
  }

  QueryBuilder<PlayerTeamHistoryIsar, PlayerTeamHistoryIsar, QDistinct>
  distinctBySeasonStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'seasonStart');
    });
  }

  QueryBuilder<PlayerTeamHistoryIsar, PlayerTeamHistoryIsar, QDistinct>
  distinctByTeamId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'teamId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PlayerTeamHistoryIsar, PlayerTeamHistoryIsar, QDistinct>
  distinctByVerified() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'verified');
    });
  }
}

extension PlayerTeamHistoryIsarQueryProperty
    on
        QueryBuilder<
          PlayerTeamHistoryIsar,
          PlayerTeamHistoryIsar,
          QQueryProperty
        > {
  QueryBuilder<PlayerTeamHistoryIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PlayerTeamHistoryIsar, double?, QQueryOperations>
  confidenceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'confidence');
    });
  }

  QueryBuilder<PlayerTeamHistoryIsar, String, QQueryOperations>
  playerIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'playerId');
    });
  }

  QueryBuilder<PlayerTeamHistoryIsar, int?, QQueryOperations>
  seasonEndProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'seasonEnd');
    });
  }

  QueryBuilder<PlayerTeamHistoryIsar, int?, QQueryOperations>
  seasonStartProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'seasonStart');
    });
  }

  QueryBuilder<PlayerTeamHistoryIsar, String, QQueryOperations>
  teamIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'teamId');
    });
  }

  QueryBuilder<PlayerTeamHistoryIsar, bool, QQueryOperations>
  verifiedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'verified');
    });
  }
}

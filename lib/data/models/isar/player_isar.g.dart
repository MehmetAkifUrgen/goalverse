// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_isar.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPlayerIsarCollection on Isar {
  IsarCollection<PlayerIsar> get playerIsars => this.collection();
}

const PlayerIsarSchema = CollectionSchema(
  name: r'PlayerIsar',
  id: 578142524339344,
  properties: {
    r'age': PropertySchema(id: 0, name: r'age', type: IsarType.long),
    r'aliases': PropertySchema(
      id: 1,
      name: r'aliases',
      type: IsarType.stringList,
    ),
    r'assistsCareer': PropertySchema(
      id: 2,
      name: r'assistsCareer',
      type: IsarType.long,
    ),
    r'clGoals': PropertySchema(id: 3, name: r'clGoals', type: IsarType.long),
    r'clues': PropertySchema(id: 4, name: r'clues', type: IsarType.stringList),
    r'eaFcOverall': PropertySchema(
      id: 5,
      name: r'eaFcOverall',
      type: IsarType.long,
    ),
    r'goalsCareer': PropertySchema(
      id: 6,
      name: r'goalsCareer',
      type: IsarType.long,
    ),
    r'marketValueEuro': PropertySchema(
      id: 7,
      name: r'marketValueEuro',
      type: IsarType.long,
    ),
    r'name': PropertySchema(id: 8, name: r'name', type: IsarType.string),
    r'nationality': PropertySchema(
      id: 9,
      name: r'nationality',
      type: IsarType.string,
    ),
    r'normalizedName': PropertySchema(
      id: 10,
      name: r'normalizedName',
      type: IsarType.string,
    ),
    r'photoAssetPath': PropertySchema(
      id: 11,
      name: r'photoAssetPath',
      type: IsarType.string,
    ),
    r'playerId': PropertySchema(
      id: 12,
      name: r'playerId',
      type: IsarType.string,
    ),
    r'position': PropertySchema(
      id: 13,
      name: r'position',
      type: IsarType.string,
    ),
    r'speedRating': PropertySchema(
      id: 14,
      name: r'speedRating',
      type: IsarType.long,
    ),
    r'verified': PropertySchema(id: 15, name: r'verified', type: IsarType.bool),
  },
  estimateSize: _playerIsarEstimateSize,
  serialize: _playerIsarSerialize,
  deserialize: _playerIsarDeserialize,
  deserializeProp: _playerIsarDeserializeProp,
  idName: r'id',
  indexes: {
    r'playerId': IndexSchema(
      id: 833858029338314,
      name: r'playerId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'playerId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'name': IndexSchema(
      id: 879695947855722,
      name: r'name',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'name',
          type: IndexType.hash,
          caseSensitive: false,
        ),
      ],
    ),
    r'normalizedName': IndexSchema(
      id: -911537109220657,
      name: r'normalizedName',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'normalizedName',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
    r'eaFcOverall': IndexSchema(
      id: -787464085898522,
      name: r'eaFcOverall',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'eaFcOverall',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},
  getId: _playerIsarGetId,
  getLinks: _playerIsarGetLinks,
  attach: _playerIsarAttach,
  version: '3.1.0+1',
);

int _playerIsarEstimateSize(
  PlayerIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final list = object.aliases;
    if (list != null) {
      bytesCount += 3 + list.length * 3;
      {
        for (var i = 0; i < list.length; i++) {
          final value = list[i];
          bytesCount += value.length * 3;
        }
      }
    }
  }
  {
    final list = object.clues;
    if (list != null) {
      bytesCount += 3 + list.length * 3;
      {
        for (var i = 0; i < list.length; i++) {
          final value = list[i];
          bytesCount += value.length * 3;
        }
      }
    }
  }
  bytesCount += 3 + object.name.length * 3;
  {
    final value = object.nationality;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.normalizedName.length * 3;
  {
    final value = object.photoAssetPath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.playerId.length * 3;
  {
    final value = object.position;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _playerIsarSerialize(
  PlayerIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.age);
  writer.writeStringList(offsets[1], object.aliases);
  writer.writeLong(offsets[2], object.assistsCareer);
  writer.writeLong(offsets[3], object.clGoals);
  writer.writeStringList(offsets[4], object.clues);
  writer.writeLong(offsets[5], object.eaFcOverall);
  writer.writeLong(offsets[6], object.goalsCareer);
  writer.writeLong(offsets[7], object.marketValueEuro);
  writer.writeString(offsets[8], object.name);
  writer.writeString(offsets[9], object.nationality);
  writer.writeString(offsets[10], object.normalizedName);
  writer.writeString(offsets[11], object.photoAssetPath);
  writer.writeString(offsets[12], object.playerId);
  writer.writeString(offsets[13], object.position);
  writer.writeLong(offsets[14], object.speedRating);
  writer.writeBool(offsets[15], object.verified);
}

PlayerIsar _playerIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PlayerIsar();
  object.age = reader.readLongOrNull(offsets[0]);
  object.aliases = reader.readStringList(offsets[1]);
  object.assistsCareer = reader.readLongOrNull(offsets[2]);
  object.clGoals = reader.readLongOrNull(offsets[3]);
  object.clues = reader.readStringList(offsets[4]);
  object.eaFcOverall = reader.readLongOrNull(offsets[5]);
  object.goalsCareer = reader.readLongOrNull(offsets[6]);
  object.id = id;
  object.marketValueEuro = reader.readLongOrNull(offsets[7]);
  object.name = reader.readString(offsets[8]);
  object.nationality = reader.readStringOrNull(offsets[9]);
  object.normalizedName = reader.readString(offsets[10]);
  object.photoAssetPath = reader.readStringOrNull(offsets[11]);
  object.playerId = reader.readString(offsets[12]);
  object.position = reader.readStringOrNull(offsets[13]);
  object.speedRating = reader.readLongOrNull(offsets[14]);
  object.verified = reader.readBool(offsets[15]);
  return object;
}

P _playerIsarDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset)) as P;
    case 1:
      return (reader.readStringList(offset)) as P;
    case 2:
      return (reader.readLongOrNull(offset)) as P;
    case 3:
      return (reader.readLongOrNull(offset)) as P;
    case 4:
      return (reader.readStringList(offset)) as P;
    case 5:
      return (reader.readLongOrNull(offset)) as P;
    case 6:
      return (reader.readLongOrNull(offset)) as P;
    case 7:
      return (reader.readLongOrNull(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (reader.readStringOrNull(offset)) as P;
    case 14:
      return (reader.readLongOrNull(offset)) as P;
    case 15:
      return (reader.readBool(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _playerIsarGetId(PlayerIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _playerIsarGetLinks(PlayerIsar object) {
  return [];
}

void _playerIsarAttach(IsarCollection<dynamic> col, Id id, PlayerIsar object) {
  object.id = id;
}

extension PlayerIsarByIndex on IsarCollection<PlayerIsar> {
  Future<PlayerIsar?> getByPlayerId(String playerId) {
    return getByIndex(r'playerId', [playerId]);
  }

  PlayerIsar? getByPlayerIdSync(String playerId) {
    return getByIndexSync(r'playerId', [playerId]);
  }

  Future<bool> deleteByPlayerId(String playerId) {
    return deleteByIndex(r'playerId', [playerId]);
  }

  bool deleteByPlayerIdSync(String playerId) {
    return deleteByIndexSync(r'playerId', [playerId]);
  }

  Future<List<PlayerIsar?>> getAllByPlayerId(List<String> playerIdValues) {
    final values = playerIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'playerId', values);
  }

  List<PlayerIsar?> getAllByPlayerIdSync(List<String> playerIdValues) {
    final values = playerIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'playerId', values);
  }

  Future<int> deleteAllByPlayerId(List<String> playerIdValues) {
    final values = playerIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'playerId', values);
  }

  int deleteAllByPlayerIdSync(List<String> playerIdValues) {
    final values = playerIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'playerId', values);
  }

  Future<Id> putByPlayerId(PlayerIsar object) {
    return putByIndex(r'playerId', object);
  }

  Id putByPlayerIdSync(PlayerIsar object, {bool saveLinks = true}) {
    return putByIndexSync(r'playerId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByPlayerId(List<PlayerIsar> objects) {
    return putAllByIndex(r'playerId', objects);
  }

  List<Id> putAllByPlayerIdSync(
    List<PlayerIsar> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'playerId', objects, saveLinks: saveLinks);
  }
}

extension PlayerIsarQueryWhereSort
    on QueryBuilder<PlayerIsar, PlayerIsar, QWhere> {
  QueryBuilder<PlayerIsar, PlayerIsar, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterWhere> anyNormalizedName() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'normalizedName'),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterWhere> anyEaFcOverall() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'eaFcOverall'),
      );
    });
  }
}

extension PlayerIsarQueryWhere
    on QueryBuilder<PlayerIsar, PlayerIsar, QWhereClause> {
  QueryBuilder<PlayerIsar, PlayerIsar, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterWhereClause> idBetween(
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

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterWhereClause> playerIdEqualTo(
    String playerId,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'playerId', value: [playerId]),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterWhereClause> playerIdNotEqualTo(
    String playerId,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'playerId',
                lower: [],
                upper: [playerId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'playerId',
                lower: [playerId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'playerId',
                lower: [playerId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'playerId',
                lower: [],
                upper: [playerId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterWhereClause> nameEqualTo(
    String name,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'name', value: [name]),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterWhereClause> nameNotEqualTo(
    String name,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'name',
                lower: [],
                upper: [name],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'name',
                lower: [name],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'name',
                lower: [name],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'name',
                lower: [],
                upper: [name],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterWhereClause> normalizedNameEqualTo(
    String normalizedName,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'normalizedName',
          value: [normalizedName],
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterWhereClause>
  normalizedNameNotEqualTo(String normalizedName) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'normalizedName',
                lower: [],
                upper: [normalizedName],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'normalizedName',
                lower: [normalizedName],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'normalizedName',
                lower: [normalizedName],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'normalizedName',
                lower: [],
                upper: [normalizedName],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterWhereClause>
  normalizedNameGreaterThan(String normalizedName, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'normalizedName',
          lower: [normalizedName],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterWhereClause>
  normalizedNameLessThan(String normalizedName, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'normalizedName',
          lower: [],
          upper: [normalizedName],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterWhereClause> normalizedNameBetween(
    String lowerNormalizedName,
    String upperNormalizedName, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'normalizedName',
          lower: [lowerNormalizedName],
          includeLower: includeLower,
          upper: [upperNormalizedName],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterWhereClause>
  normalizedNameStartsWith(String NormalizedNamePrefix) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'normalizedName',
          lower: [NormalizedNamePrefix],
          upper: ['$NormalizedNamePrefix\u{FFFFF}'],
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterWhereClause>
  normalizedNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'normalizedName', value: ['']),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterWhereClause>
  normalizedNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.lessThan(
                indexName: r'normalizedName',
                upper: [''],
              ),
            )
            .addWhereClause(
              IndexWhereClause.greaterThan(
                indexName: r'normalizedName',
                lower: [''],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.greaterThan(
                indexName: r'normalizedName',
                lower: [''],
              ),
            )
            .addWhereClause(
              IndexWhereClause.lessThan(
                indexName: r'normalizedName',
                upper: [''],
              ),
            );
      }
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterWhereClause> eaFcOverallIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'eaFcOverall', value: [null]),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterWhereClause>
  eaFcOverallIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'eaFcOverall',
          lower: [null],
          includeLower: false,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterWhereClause> eaFcOverallEqualTo(
    int? eaFcOverall,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'eaFcOverall',
          value: [eaFcOverall],
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterWhereClause> eaFcOverallNotEqualTo(
    int? eaFcOverall,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'eaFcOverall',
                lower: [],
                upper: [eaFcOverall],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'eaFcOverall',
                lower: [eaFcOverall],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'eaFcOverall',
                lower: [eaFcOverall],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'eaFcOverall',
                lower: [],
                upper: [eaFcOverall],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterWhereClause>
  eaFcOverallGreaterThan(int? eaFcOverall, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'eaFcOverall',
          lower: [eaFcOverall],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterWhereClause> eaFcOverallLessThan(
    int? eaFcOverall, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'eaFcOverall',
          lower: [],
          upper: [eaFcOverall],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterWhereClause> eaFcOverallBetween(
    int? lowerEaFcOverall,
    int? upperEaFcOverall, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'eaFcOverall',
          lower: [lowerEaFcOverall],
          includeLower: includeLower,
          upper: [upperEaFcOverall],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension PlayerIsarQueryFilter
    on QueryBuilder<PlayerIsar, PlayerIsar, QFilterCondition> {
  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition> ageIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'age'),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition> ageIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'age'),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition> ageEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'age', value: value),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition> ageGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'age',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition> ageLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'age',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition> ageBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'age',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition> aliasesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'aliases'),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  aliasesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'aliases'),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  aliasesElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'aliases',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  aliasesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'aliases',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  aliasesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'aliases',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  aliasesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'aliases',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  aliasesElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'aliases',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  aliasesElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'aliases',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  aliasesElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'aliases',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  aliasesElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'aliases',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  aliasesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'aliases', value: ''),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  aliasesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'aliases', value: ''),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  aliasesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'aliases', length, true, length, true);
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition> aliasesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'aliases', 0, true, 0, true);
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  aliasesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'aliases', 0, false, 999999, true);
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  aliasesLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'aliases', 0, true, length, include);
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  aliasesLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'aliases', length, include, 999999, true);
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  aliasesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'aliases',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  assistsCareerIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'assistsCareer'),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  assistsCareerIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'assistsCareer'),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  assistsCareerEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'assistsCareer', value: value),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  assistsCareerGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'assistsCareer',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  assistsCareerLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'assistsCareer',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  assistsCareerBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'assistsCareer',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition> clGoalsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'clGoals'),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  clGoalsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'clGoals'),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition> clGoalsEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'clGoals', value: value),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  clGoalsGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'clGoals',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition> clGoalsLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'clGoals',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition> clGoalsBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'clGoals',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition> cluesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'clues'),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition> cluesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'clues'),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  cluesElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'clues',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  cluesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'clues',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  cluesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'clues',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  cluesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'clues',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  cluesElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'clues',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  cluesElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'clues',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  cluesElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'clues',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  cluesElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'clues',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  cluesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'clues', value: ''),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  cluesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'clues', value: ''),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  cluesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'clues', length, true, length, true);
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition> cluesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'clues', 0, true, 0, true);
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  cluesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'clues', 0, false, 999999, true);
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  cluesLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'clues', 0, true, length, include);
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  cluesLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'clues', length, include, 999999, true);
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  cluesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'clues',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  eaFcOverallIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'eaFcOverall'),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  eaFcOverallIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'eaFcOverall'),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  eaFcOverallEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'eaFcOverall', value: value),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  eaFcOverallGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'eaFcOverall',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  eaFcOverallLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'eaFcOverall',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  eaFcOverallBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'eaFcOverall',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  goalsCareerIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'goalsCareer'),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  goalsCareerIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'goalsCareer'),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  goalsCareerEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'goalsCareer', value: value),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  goalsCareerGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'goalsCareer',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  goalsCareerLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'goalsCareer',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  goalsCareerBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'goalsCareer',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
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

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
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

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition> idBetween(
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

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  marketValueEuroIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'marketValueEuro'),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  marketValueEuroIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'marketValueEuro'),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  marketValueEuroEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'marketValueEuro', value: value),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  marketValueEuroGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'marketValueEuro',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  marketValueEuroLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'marketValueEuro',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  marketValueEuroBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'marketValueEuro',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition> nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition> nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'name',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition> nameContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition> nameMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'name',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  nationalityIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'nationality'),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  nationalityIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'nationality'),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  nationalityEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'nationality',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  nationalityGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'nationality',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  nationalityLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'nationality',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  nationalityBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'nationality',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  nationalityStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'nationality',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  nationalityEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'nationality',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  nationalityContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'nationality',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  nationalityMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'nationality',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  nationalityIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'nationality', value: ''),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  nationalityIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'nationality', value: ''),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  normalizedNameEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'normalizedName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  normalizedNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'normalizedName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  normalizedNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'normalizedName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  normalizedNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'normalizedName',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  normalizedNameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'normalizedName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  normalizedNameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'normalizedName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  normalizedNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'normalizedName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  normalizedNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'normalizedName',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  normalizedNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'normalizedName', value: ''),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  normalizedNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'normalizedName', value: ''),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  photoAssetPathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'photoAssetPath'),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  photoAssetPathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'photoAssetPath'),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  photoAssetPathEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'photoAssetPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  photoAssetPathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'photoAssetPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  photoAssetPathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'photoAssetPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  photoAssetPathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'photoAssetPath',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  photoAssetPathStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'photoAssetPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  photoAssetPathEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'photoAssetPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  photoAssetPathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'photoAssetPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  photoAssetPathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'photoAssetPath',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  photoAssetPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'photoAssetPath', value: ''),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  photoAssetPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'photoAssetPath', value: ''),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition> playerIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
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

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition> playerIdLessThan(
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

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition> playerIdBetween(
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

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
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

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition> playerIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition> playerIdContains(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition> playerIdMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  playerIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'playerId', value: ''),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  playerIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'playerId', value: ''),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition> positionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'position'),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  positionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'position'),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition> positionEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'position',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  positionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'position',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition> positionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'position',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition> positionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'position',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  positionStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'position',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition> positionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'position',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition> positionContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'position',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition> positionMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'position',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  positionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'position', value: ''),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  positionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'position', value: ''),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  speedRatingIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'speedRating'),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  speedRatingIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'speedRating'),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  speedRatingEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'speedRating', value: value),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  speedRatingGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'speedRating',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  speedRatingLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'speedRating',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition>
  speedRatingBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'speedRating',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterFilterCondition> verifiedEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'verified', value: value),
      );
    });
  }
}

extension PlayerIsarQueryObject
    on QueryBuilder<PlayerIsar, PlayerIsar, QFilterCondition> {}

extension PlayerIsarQueryLinks
    on QueryBuilder<PlayerIsar, PlayerIsar, QFilterCondition> {}

extension PlayerIsarQuerySortBy
    on QueryBuilder<PlayerIsar, PlayerIsar, QSortBy> {
  QueryBuilder<PlayerIsar, PlayerIsar, QAfterSortBy> sortByAge() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'age', Sort.asc);
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterSortBy> sortByAgeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'age', Sort.desc);
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterSortBy> sortByAssistsCareer() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assistsCareer', Sort.asc);
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterSortBy> sortByAssistsCareerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assistsCareer', Sort.desc);
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterSortBy> sortByClGoals() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clGoals', Sort.asc);
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterSortBy> sortByClGoalsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clGoals', Sort.desc);
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterSortBy> sortByEaFcOverall() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eaFcOverall', Sort.asc);
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterSortBy> sortByEaFcOverallDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eaFcOverall', Sort.desc);
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterSortBy> sortByGoalsCareer() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalsCareer', Sort.asc);
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterSortBy> sortByGoalsCareerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalsCareer', Sort.desc);
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterSortBy> sortByMarketValueEuro() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'marketValueEuro', Sort.asc);
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterSortBy>
  sortByMarketValueEuroDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'marketValueEuro', Sort.desc);
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterSortBy> sortByNationality() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nationality', Sort.asc);
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterSortBy> sortByNationalityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nationality', Sort.desc);
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterSortBy> sortByNormalizedName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'normalizedName', Sort.asc);
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterSortBy>
  sortByNormalizedNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'normalizedName', Sort.desc);
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterSortBy> sortByPhotoAssetPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photoAssetPath', Sort.asc);
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterSortBy>
  sortByPhotoAssetPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photoAssetPath', Sort.desc);
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterSortBy> sortByPlayerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playerId', Sort.asc);
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterSortBy> sortByPlayerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playerId', Sort.desc);
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterSortBy> sortByPosition() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'position', Sort.asc);
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterSortBy> sortByPositionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'position', Sort.desc);
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterSortBy> sortBySpeedRating() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speedRating', Sort.asc);
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterSortBy> sortBySpeedRatingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speedRating', Sort.desc);
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterSortBy> sortByVerified() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verified', Sort.asc);
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterSortBy> sortByVerifiedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verified', Sort.desc);
    });
  }
}

extension PlayerIsarQuerySortThenBy
    on QueryBuilder<PlayerIsar, PlayerIsar, QSortThenBy> {
  QueryBuilder<PlayerIsar, PlayerIsar, QAfterSortBy> thenByAge() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'age', Sort.asc);
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterSortBy> thenByAgeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'age', Sort.desc);
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterSortBy> thenByAssistsCareer() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assistsCareer', Sort.asc);
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterSortBy> thenByAssistsCareerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assistsCareer', Sort.desc);
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterSortBy> thenByClGoals() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clGoals', Sort.asc);
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterSortBy> thenByClGoalsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clGoals', Sort.desc);
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterSortBy> thenByEaFcOverall() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eaFcOverall', Sort.asc);
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterSortBy> thenByEaFcOverallDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eaFcOverall', Sort.desc);
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterSortBy> thenByGoalsCareer() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalsCareer', Sort.asc);
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterSortBy> thenByGoalsCareerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalsCareer', Sort.desc);
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterSortBy> thenByMarketValueEuro() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'marketValueEuro', Sort.asc);
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterSortBy>
  thenByMarketValueEuroDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'marketValueEuro', Sort.desc);
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterSortBy> thenByNationality() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nationality', Sort.asc);
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterSortBy> thenByNationalityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nationality', Sort.desc);
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterSortBy> thenByNormalizedName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'normalizedName', Sort.asc);
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterSortBy>
  thenByNormalizedNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'normalizedName', Sort.desc);
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterSortBy> thenByPhotoAssetPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photoAssetPath', Sort.asc);
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterSortBy>
  thenByPhotoAssetPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photoAssetPath', Sort.desc);
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterSortBy> thenByPlayerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playerId', Sort.asc);
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterSortBy> thenByPlayerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playerId', Sort.desc);
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterSortBy> thenByPosition() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'position', Sort.asc);
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterSortBy> thenByPositionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'position', Sort.desc);
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterSortBy> thenBySpeedRating() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speedRating', Sort.asc);
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterSortBy> thenBySpeedRatingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speedRating', Sort.desc);
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterSortBy> thenByVerified() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verified', Sort.asc);
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QAfterSortBy> thenByVerifiedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verified', Sort.desc);
    });
  }
}

extension PlayerIsarQueryWhereDistinct
    on QueryBuilder<PlayerIsar, PlayerIsar, QDistinct> {
  QueryBuilder<PlayerIsar, PlayerIsar, QDistinct> distinctByAge() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'age');
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QDistinct> distinctByAliases() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'aliases');
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QDistinct> distinctByAssistsCareer() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'assistsCareer');
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QDistinct> distinctByClGoals() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'clGoals');
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QDistinct> distinctByClues() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'clues');
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QDistinct> distinctByEaFcOverall() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'eaFcOverall');
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QDistinct> distinctByGoalsCareer() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'goalsCareer');
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QDistinct> distinctByMarketValueEuro() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'marketValueEuro');
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QDistinct> distinctByName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QDistinct> distinctByNationality({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nationality', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QDistinct> distinctByNormalizedName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'normalizedName',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QDistinct> distinctByPhotoAssetPath({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'photoAssetPath',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QDistinct> distinctByPlayerId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'playerId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QDistinct> distinctByPosition({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'position', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QDistinct> distinctBySpeedRating() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'speedRating');
    });
  }

  QueryBuilder<PlayerIsar, PlayerIsar, QDistinct> distinctByVerified() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'verified');
    });
  }
}

extension PlayerIsarQueryProperty
    on QueryBuilder<PlayerIsar, PlayerIsar, QQueryProperty> {
  QueryBuilder<PlayerIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PlayerIsar, int?, QQueryOperations> ageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'age');
    });
  }

  QueryBuilder<PlayerIsar, List<String>?, QQueryOperations> aliasesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'aliases');
    });
  }

  QueryBuilder<PlayerIsar, int?, QQueryOperations> assistsCareerProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'assistsCareer');
    });
  }

  QueryBuilder<PlayerIsar, int?, QQueryOperations> clGoalsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'clGoals');
    });
  }

  QueryBuilder<PlayerIsar, List<String>?, QQueryOperations> cluesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'clues');
    });
  }

  QueryBuilder<PlayerIsar, int?, QQueryOperations> eaFcOverallProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'eaFcOverall');
    });
  }

  QueryBuilder<PlayerIsar, int?, QQueryOperations> goalsCareerProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'goalsCareer');
    });
  }

  QueryBuilder<PlayerIsar, int?, QQueryOperations> marketValueEuroProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'marketValueEuro');
    });
  }

  QueryBuilder<PlayerIsar, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<PlayerIsar, String?, QQueryOperations> nationalityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nationality');
    });
  }

  QueryBuilder<PlayerIsar, String, QQueryOperations> normalizedNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'normalizedName');
    });
  }

  QueryBuilder<PlayerIsar, String?, QQueryOperations> photoAssetPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'photoAssetPath');
    });
  }

  QueryBuilder<PlayerIsar, String, QQueryOperations> playerIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'playerId');
    });
  }

  QueryBuilder<PlayerIsar, String?, QQueryOperations> positionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'position');
    });
  }

  QueryBuilder<PlayerIsar, int?, QQueryOperations> speedRatingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'speedRating');
    });
  }

  QueryBuilder<PlayerIsar, bool, QQueryOperations> verifiedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'verified');
    });
  }
}

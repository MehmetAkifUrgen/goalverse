// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team_isar.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetTeamIsarCollection on Isar {
  IsarCollection<TeamIsar> get teamIsars => this.collection();
}

const TeamIsarSchema = CollectionSchema(
  name: r'TeamIsar',
  id: 158529301170407,
  properties: {
    r'aliases': PropertySchema(
      id: 0,
      name: r'aliases',
      type: IsarType.stringList,
    ),
    r'country': PropertySchema(id: 1, name: r'country', type: IsarType.string),
    r'kitAssetPath': PropertySchema(
      id: 2,
      name: r'kitAssetPath',
      type: IsarType.string,
    ),
    r'logoAssetPath': PropertySchema(
      id: 3,
      name: r'logoAssetPath',
      type: IsarType.string,
    ),
    r'name': PropertySchema(id: 4, name: r'name', type: IsarType.string),
    r'normalizedName': PropertySchema(
      id: 5,
      name: r'normalizedName',
      type: IsarType.string,
    ),
    r'primaryColorHex': PropertySchema(
      id: 6,
      name: r'primaryColorHex',
      type: IsarType.string,
    ),
    r'secondaryColorHex': PropertySchema(
      id: 7,
      name: r'secondaryColorHex',
      type: IsarType.string,
    ),
    r'teamId': PropertySchema(id: 8, name: r'teamId', type: IsarType.string),
    r'verified': PropertySchema(id: 9, name: r'verified', type: IsarType.bool),
  },
  estimateSize: _teamIsarEstimateSize,
  serialize: _teamIsarSerialize,
  deserialize: _teamIsarDeserialize,
  deserializeProp: _teamIsarDeserializeProp,
  idName: r'id',
  indexes: {
    r'teamId': IndexSchema(
      id: 889449891813377,
      name: r'teamId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'teamId',
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
  },
  links: {},
  embeddedSchemas: {},
  getId: _teamIsarGetId,
  getLinks: _teamIsarGetLinks,
  attach: _teamIsarAttach,
  version: '3.1.0+1',
);

int _teamIsarEstimateSize(
  TeamIsar object,
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
    final value = object.country;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.kitAssetPath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.logoAssetPath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.normalizedName.length * 3;
  {
    final value = object.primaryColorHex;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.secondaryColorHex;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.teamId.length * 3;
  return bytesCount;
}

void _teamIsarSerialize(
  TeamIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeStringList(offsets[0], object.aliases);
  writer.writeString(offsets[1], object.country);
  writer.writeString(offsets[2], object.kitAssetPath);
  writer.writeString(offsets[3], object.logoAssetPath);
  writer.writeString(offsets[4], object.name);
  writer.writeString(offsets[5], object.normalizedName);
  writer.writeString(offsets[6], object.primaryColorHex);
  writer.writeString(offsets[7], object.secondaryColorHex);
  writer.writeString(offsets[8], object.teamId);
  writer.writeBool(offsets[9], object.verified);
}

TeamIsar _teamIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TeamIsar();
  object.aliases = reader.readStringList(offsets[0]);
  object.country = reader.readStringOrNull(offsets[1]);
  object.id = id;
  object.kitAssetPath = reader.readStringOrNull(offsets[2]);
  object.logoAssetPath = reader.readStringOrNull(offsets[3]);
  object.name = reader.readString(offsets[4]);
  object.normalizedName = reader.readString(offsets[5]);
  object.primaryColorHex = reader.readStringOrNull(offsets[6]);
  object.secondaryColorHex = reader.readStringOrNull(offsets[7]);
  object.teamId = reader.readString(offsets[8]);
  object.verified = reader.readBool(offsets[9]);
  return object;
}

P _teamIsarDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringList(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readBool(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _teamIsarGetId(TeamIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _teamIsarGetLinks(TeamIsar object) {
  return [];
}

void _teamIsarAttach(IsarCollection<dynamic> col, Id id, TeamIsar object) {
  object.id = id;
}

extension TeamIsarByIndex on IsarCollection<TeamIsar> {
  Future<TeamIsar?> getByTeamId(String teamId) {
    return getByIndex(r'teamId', [teamId]);
  }

  TeamIsar? getByTeamIdSync(String teamId) {
    return getByIndexSync(r'teamId', [teamId]);
  }

  Future<bool> deleteByTeamId(String teamId) {
    return deleteByIndex(r'teamId', [teamId]);
  }

  bool deleteByTeamIdSync(String teamId) {
    return deleteByIndexSync(r'teamId', [teamId]);
  }

  Future<List<TeamIsar?>> getAllByTeamId(List<String> teamIdValues) {
    final values = teamIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'teamId', values);
  }

  List<TeamIsar?> getAllByTeamIdSync(List<String> teamIdValues) {
    final values = teamIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'teamId', values);
  }

  Future<int> deleteAllByTeamId(List<String> teamIdValues) {
    final values = teamIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'teamId', values);
  }

  int deleteAllByTeamIdSync(List<String> teamIdValues) {
    final values = teamIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'teamId', values);
  }

  Future<Id> putByTeamId(TeamIsar object) {
    return putByIndex(r'teamId', object);
  }

  Id putByTeamIdSync(TeamIsar object, {bool saveLinks = true}) {
    return putByIndexSync(r'teamId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByTeamId(List<TeamIsar> objects) {
    return putAllByIndex(r'teamId', objects);
  }

  List<Id> putAllByTeamIdSync(List<TeamIsar> objects, {bool saveLinks = true}) {
    return putAllByIndexSync(r'teamId', objects, saveLinks: saveLinks);
  }
}

extension TeamIsarQueryWhereSort on QueryBuilder<TeamIsar, TeamIsar, QWhere> {
  QueryBuilder<TeamIsar, TeamIsar, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterWhere> anyNormalizedName() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'normalizedName'),
      );
    });
  }
}

extension TeamIsarQueryWhere on QueryBuilder<TeamIsar, TeamIsar, QWhereClause> {
  QueryBuilder<TeamIsar, TeamIsar, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<TeamIsar, TeamIsar, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterWhereClause> idBetween(
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

  QueryBuilder<TeamIsar, TeamIsar, QAfterWhereClause> teamIdEqualTo(
    String teamId,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'teamId', value: [teamId]),
      );
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterWhereClause> teamIdNotEqualTo(
    String teamId,
  ) {
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

  QueryBuilder<TeamIsar, TeamIsar, QAfterWhereClause> nameEqualTo(String name) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'name', value: [name]),
      );
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterWhereClause> nameNotEqualTo(
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

  QueryBuilder<TeamIsar, TeamIsar, QAfterWhereClause> normalizedNameEqualTo(
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

  QueryBuilder<TeamIsar, TeamIsar, QAfterWhereClause> normalizedNameNotEqualTo(
    String normalizedName,
  ) {
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

  QueryBuilder<TeamIsar, TeamIsar, QAfterWhereClause> normalizedNameGreaterThan(
    String normalizedName, {
    bool include = false,
  }) {
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

  QueryBuilder<TeamIsar, TeamIsar, QAfterWhereClause> normalizedNameLessThan(
    String normalizedName, {
    bool include = false,
  }) {
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

  QueryBuilder<TeamIsar, TeamIsar, QAfterWhereClause> normalizedNameBetween(
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

  QueryBuilder<TeamIsar, TeamIsar, QAfterWhereClause> normalizedNameStartsWith(
    String NormalizedNamePrefix,
  ) {
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

  QueryBuilder<TeamIsar, TeamIsar, QAfterWhereClause> normalizedNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'normalizedName', value: ['']),
      );
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterWhereClause>
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
}

extension TeamIsarQueryFilter
    on QueryBuilder<TeamIsar, TeamIsar, QFilterCondition> {
  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition> aliasesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'aliases'),
      );
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition> aliasesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'aliases'),
      );
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition> aliasesElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition>
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

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition>
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

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition> aliasesElementBetween(
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

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition>
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

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition>
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

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition>
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

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition> aliasesElementMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition>
  aliasesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'aliases', value: ''),
      );
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition>
  aliasesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'aliases', value: ''),
      );
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition> aliasesLengthEqualTo(
    int length,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'aliases', length, true, length, true);
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition> aliasesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'aliases', 0, true, 0, true);
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition> aliasesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'aliases', 0, false, 999999, true);
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition> aliasesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'aliases', 0, true, length, include);
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition>
  aliasesLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'aliases', length, include, 999999, true);
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition> aliasesLengthBetween(
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

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition> countryIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'country'),
      );
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition> countryIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'country'),
      );
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition> countryEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'country',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition> countryGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'country',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition> countryLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'country',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition> countryBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'country',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition> countryStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'country',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition> countryEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'country',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition> countryContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'country',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition> countryMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'country',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition> countryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'country', value: ''),
      );
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition> countryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'country', value: ''),
      );
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition> idBetween(
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

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition> kitAssetPathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'kitAssetPath'),
      );
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition>
  kitAssetPathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'kitAssetPath'),
      );
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition> kitAssetPathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'kitAssetPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition>
  kitAssetPathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'kitAssetPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition> kitAssetPathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'kitAssetPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition> kitAssetPathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'kitAssetPath',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition>
  kitAssetPathStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'kitAssetPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition> kitAssetPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'kitAssetPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition> kitAssetPathContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'kitAssetPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition> kitAssetPathMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'kitAssetPath',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition>
  kitAssetPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'kitAssetPath', value: ''),
      );
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition>
  kitAssetPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'kitAssetPath', value: ''),
      );
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition>
  logoAssetPathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'logoAssetPath'),
      );
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition>
  logoAssetPathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'logoAssetPath'),
      );
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition> logoAssetPathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'logoAssetPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition>
  logoAssetPathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'logoAssetPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition> logoAssetPathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'logoAssetPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition> logoAssetPathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'logoAssetPath',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition>
  logoAssetPathStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'logoAssetPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition> logoAssetPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'logoAssetPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition> logoAssetPathContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'logoAssetPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition> logoAssetPathMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'logoAssetPath',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition>
  logoAssetPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'logoAssetPath', value: ''),
      );
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition>
  logoAssetPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'logoAssetPath', value: ''),
      );
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition> nameEqualTo(
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

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition> nameGreaterThan(
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

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition> nameLessThan(
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

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition> nameBetween(
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

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition> nameStartsWith(
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

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition> nameEndsWith(
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

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition> nameContains(
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

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition> nameMatches(
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

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition> normalizedNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition>
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

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition>
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

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition> normalizedNameBetween(
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

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition>
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

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition>
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

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition>
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

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition> normalizedNameMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition>
  normalizedNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'normalizedName', value: ''),
      );
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition>
  normalizedNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'normalizedName', value: ''),
      );
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition>
  primaryColorHexIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'primaryColorHex'),
      );
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition>
  primaryColorHexIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'primaryColorHex'),
      );
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition>
  primaryColorHexEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'primaryColorHex',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition>
  primaryColorHexGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'primaryColorHex',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition>
  primaryColorHexLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'primaryColorHex',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition>
  primaryColorHexBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'primaryColorHex',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition>
  primaryColorHexStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'primaryColorHex',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition>
  primaryColorHexEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'primaryColorHex',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition>
  primaryColorHexContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'primaryColorHex',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition>
  primaryColorHexMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'primaryColorHex',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition>
  primaryColorHexIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'primaryColorHex', value: ''),
      );
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition>
  primaryColorHexIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'primaryColorHex', value: ''),
      );
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition>
  secondaryColorHexIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'secondaryColorHex'),
      );
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition>
  secondaryColorHexIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'secondaryColorHex'),
      );
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition>
  secondaryColorHexEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'secondaryColorHex',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition>
  secondaryColorHexGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'secondaryColorHex',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition>
  secondaryColorHexLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'secondaryColorHex',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition>
  secondaryColorHexBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'secondaryColorHex',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition>
  secondaryColorHexStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'secondaryColorHex',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition>
  secondaryColorHexEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'secondaryColorHex',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition>
  secondaryColorHexContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'secondaryColorHex',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition>
  secondaryColorHexMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'secondaryColorHex',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition>
  secondaryColorHexIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'secondaryColorHex', value: ''),
      );
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition>
  secondaryColorHexIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'secondaryColorHex', value: ''),
      );
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition> teamIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition> teamIdGreaterThan(
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

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition> teamIdLessThan(
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

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition> teamIdBetween(
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

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition> teamIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition> teamIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition> teamIdContains(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition> teamIdMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition> teamIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'teamId', value: ''),
      );
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition> teamIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'teamId', value: ''),
      );
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterFilterCondition> verifiedEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'verified', value: value),
      );
    });
  }
}

extension TeamIsarQueryObject
    on QueryBuilder<TeamIsar, TeamIsar, QFilterCondition> {}

extension TeamIsarQueryLinks
    on QueryBuilder<TeamIsar, TeamIsar, QFilterCondition> {}

extension TeamIsarQuerySortBy on QueryBuilder<TeamIsar, TeamIsar, QSortBy> {
  QueryBuilder<TeamIsar, TeamIsar, QAfterSortBy> sortByCountry() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'country', Sort.asc);
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterSortBy> sortByCountryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'country', Sort.desc);
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterSortBy> sortByKitAssetPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kitAssetPath', Sort.asc);
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterSortBy> sortByKitAssetPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kitAssetPath', Sort.desc);
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterSortBy> sortByLogoAssetPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'logoAssetPath', Sort.asc);
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterSortBy> sortByLogoAssetPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'logoAssetPath', Sort.desc);
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterSortBy> sortByNormalizedName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'normalizedName', Sort.asc);
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterSortBy> sortByNormalizedNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'normalizedName', Sort.desc);
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterSortBy> sortByPrimaryColorHex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'primaryColorHex', Sort.asc);
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterSortBy> sortByPrimaryColorHexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'primaryColorHex', Sort.desc);
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterSortBy> sortBySecondaryColorHex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'secondaryColorHex', Sort.asc);
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterSortBy> sortBySecondaryColorHexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'secondaryColorHex', Sort.desc);
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterSortBy> sortByTeamId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'teamId', Sort.asc);
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterSortBy> sortByTeamIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'teamId', Sort.desc);
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterSortBy> sortByVerified() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verified', Sort.asc);
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterSortBy> sortByVerifiedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verified', Sort.desc);
    });
  }
}

extension TeamIsarQuerySortThenBy
    on QueryBuilder<TeamIsar, TeamIsar, QSortThenBy> {
  QueryBuilder<TeamIsar, TeamIsar, QAfterSortBy> thenByCountry() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'country', Sort.asc);
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterSortBy> thenByCountryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'country', Sort.desc);
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterSortBy> thenByKitAssetPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kitAssetPath', Sort.asc);
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterSortBy> thenByKitAssetPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kitAssetPath', Sort.desc);
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterSortBy> thenByLogoAssetPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'logoAssetPath', Sort.asc);
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterSortBy> thenByLogoAssetPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'logoAssetPath', Sort.desc);
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterSortBy> thenByNormalizedName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'normalizedName', Sort.asc);
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterSortBy> thenByNormalizedNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'normalizedName', Sort.desc);
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterSortBy> thenByPrimaryColorHex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'primaryColorHex', Sort.asc);
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterSortBy> thenByPrimaryColorHexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'primaryColorHex', Sort.desc);
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterSortBy> thenBySecondaryColorHex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'secondaryColorHex', Sort.asc);
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterSortBy> thenBySecondaryColorHexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'secondaryColorHex', Sort.desc);
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterSortBy> thenByTeamId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'teamId', Sort.asc);
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterSortBy> thenByTeamIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'teamId', Sort.desc);
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterSortBy> thenByVerified() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verified', Sort.asc);
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QAfterSortBy> thenByVerifiedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verified', Sort.desc);
    });
  }
}

extension TeamIsarQueryWhereDistinct
    on QueryBuilder<TeamIsar, TeamIsar, QDistinct> {
  QueryBuilder<TeamIsar, TeamIsar, QDistinct> distinctByAliases() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'aliases');
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QDistinct> distinctByCountry({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'country', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QDistinct> distinctByKitAssetPath({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'kitAssetPath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QDistinct> distinctByLogoAssetPath({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'logoAssetPath',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QDistinct> distinctByName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QDistinct> distinctByNormalizedName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'normalizedName',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QDistinct> distinctByPrimaryColorHex({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'primaryColorHex',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QDistinct> distinctBySecondaryColorHex({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'secondaryColorHex',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QDistinct> distinctByTeamId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'teamId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TeamIsar, TeamIsar, QDistinct> distinctByVerified() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'verified');
    });
  }
}

extension TeamIsarQueryProperty
    on QueryBuilder<TeamIsar, TeamIsar, QQueryProperty> {
  QueryBuilder<TeamIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<TeamIsar, List<String>?, QQueryOperations> aliasesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'aliases');
    });
  }

  QueryBuilder<TeamIsar, String?, QQueryOperations> countryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'country');
    });
  }

  QueryBuilder<TeamIsar, String?, QQueryOperations> kitAssetPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'kitAssetPath');
    });
  }

  QueryBuilder<TeamIsar, String?, QQueryOperations> logoAssetPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'logoAssetPath');
    });
  }

  QueryBuilder<TeamIsar, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<TeamIsar, String, QQueryOperations> normalizedNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'normalizedName');
    });
  }

  QueryBuilder<TeamIsar, String?, QQueryOperations> primaryColorHexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'primaryColorHex');
    });
  }

  QueryBuilder<TeamIsar, String?, QQueryOperations>
  secondaryColorHexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'secondaryColorHex');
    });
  }

  QueryBuilder<TeamIsar, String, QQueryOperations> teamIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'teamId');
    });
  }

  QueryBuilder<TeamIsar, bool, QQueryOperations> verifiedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'verified');
    });
  }
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credit_card_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCreditCardModelCollection on Isar {
  IsarCollection<CreditCardModel> get creditCardModels => this.collection();
}

const CreditCardModelSchema = CollectionSchema(
  name: r'CreditCardModel',
  id: 5536749382818049299,
  properties: {
    r'cardTypeName': PropertySchema(
      id: 0,
      name: r'cardTypeName',
      type: IsarType.string,
    ),
    r'cardholderName': PropertySchema(
      id: 1,
      name: r'cardholderName',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 2,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'encryptedCardNumber': PropertySchema(
      id: 3,
      name: r'encryptedCardNumber',
      type: IsarType.string,
    ),
    r'encryptedCvv': PropertySchema(
      id: 4,
      name: r'encryptedCvv',
      type: IsarType.string,
    ),
    r'expiryMonth': PropertySchema(
      id: 5,
      name: r'expiryMonth',
      type: IsarType.string,
    ),
    r'expiryYear': PropertySchema(
      id: 6,
      name: r'expiryYear',
      type: IsarType.string,
    ),
    r'isDefault': PropertySchema(
      id: 7,
      name: r'isDefault',
      type: IsarType.bool,
    ),
    r'localId': PropertySchema(id: 8, name: r'localId', type: IsarType.string),
    r'updatedAt': PropertySchema(
      id: 9,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
  },

  estimateSize: _creditCardModelEstimateSize,
  serialize: _creditCardModelSerialize,
  deserialize: _creditCardModelDeserialize,
  deserializeProp: _creditCardModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'localId': IndexSchema(
      id: 1199848425898359622,
      name: r'localId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'localId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'isDefault': IndexSchema(
      id: -6569979013669400724,
      name: r'isDefault',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'isDefault',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _creditCardModelGetId,
  getLinks: _creditCardModelGetLinks,
  attach: _creditCardModelAttach,
  version: '3.3.0',
);

int _creditCardModelEstimateSize(
  CreditCardModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.cardTypeName.length * 3;
  bytesCount += 3 + object.cardholderName.length * 3;
  bytesCount += 3 + object.encryptedCardNumber.length * 3;
  bytesCount += 3 + object.encryptedCvv.length * 3;
  bytesCount += 3 + object.expiryMonth.length * 3;
  bytesCount += 3 + object.expiryYear.length * 3;
  bytesCount += 3 + object.localId.length * 3;
  return bytesCount;
}

void _creditCardModelSerialize(
  CreditCardModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.cardTypeName);
  writer.writeString(offsets[1], object.cardholderName);
  writer.writeDateTime(offsets[2], object.createdAt);
  writer.writeString(offsets[3], object.encryptedCardNumber);
  writer.writeString(offsets[4], object.encryptedCvv);
  writer.writeString(offsets[5], object.expiryMonth);
  writer.writeString(offsets[6], object.expiryYear);
  writer.writeBool(offsets[7], object.isDefault);
  writer.writeString(offsets[8], object.localId);
  writer.writeDateTime(offsets[9], object.updatedAt);
}

CreditCardModel _creditCardModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CreditCardModel();
  object.cardTypeName = reader.readString(offsets[0]);
  object.cardholderName = reader.readString(offsets[1]);
  object.createdAt = reader.readDateTime(offsets[2]);
  object.encryptedCardNumber = reader.readString(offsets[3]);
  object.encryptedCvv = reader.readString(offsets[4]);
  object.expiryMonth = reader.readString(offsets[5]);
  object.expiryYear = reader.readString(offsets[6]);
  object.id = id;
  object.isDefault = reader.readBool(offsets[7]);
  object.localId = reader.readString(offsets[8]);
  object.updatedAt = reader.readDateTimeOrNull(offsets[9]);
  return object;
}

P _creditCardModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readBool(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readDateTimeOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _creditCardModelGetId(CreditCardModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _creditCardModelGetLinks(CreditCardModel object) {
  return [];
}

void _creditCardModelAttach(
  IsarCollection<dynamic> col,
  Id id,
  CreditCardModel object,
) {
  object.id = id;
}

extension CreditCardModelByIndex on IsarCollection<CreditCardModel> {
  Future<CreditCardModel?> getByLocalId(String localId) {
    return getByIndex(r'localId', [localId]);
  }

  CreditCardModel? getByLocalIdSync(String localId) {
    return getByIndexSync(r'localId', [localId]);
  }

  Future<bool> deleteByLocalId(String localId) {
    return deleteByIndex(r'localId', [localId]);
  }

  bool deleteByLocalIdSync(String localId) {
    return deleteByIndexSync(r'localId', [localId]);
  }

  Future<List<CreditCardModel?>> getAllByLocalId(List<String> localIdValues) {
    final values = localIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'localId', values);
  }

  List<CreditCardModel?> getAllByLocalIdSync(List<String> localIdValues) {
    final values = localIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'localId', values);
  }

  Future<int> deleteAllByLocalId(List<String> localIdValues) {
    final values = localIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'localId', values);
  }

  int deleteAllByLocalIdSync(List<String> localIdValues) {
    final values = localIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'localId', values);
  }

  Future<Id> putByLocalId(CreditCardModel object) {
    return putByIndex(r'localId', object);
  }

  Id putByLocalIdSync(CreditCardModel object, {bool saveLinks = true}) {
    return putByIndexSync(r'localId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByLocalId(List<CreditCardModel> objects) {
    return putAllByIndex(r'localId', objects);
  }

  List<Id> putAllByLocalIdSync(
    List<CreditCardModel> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'localId', objects, saveLinks: saveLinks);
  }
}

extension CreditCardModelQueryWhereSort
    on QueryBuilder<CreditCardModel, CreditCardModel, QWhere> {
  QueryBuilder<CreditCardModel, CreditCardModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterWhere> anyIsDefault() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'isDefault'),
      );
    });
  }
}

extension CreditCardModelQueryWhere
    on QueryBuilder<CreditCardModel, CreditCardModel, QWhereClause> {
  QueryBuilder<CreditCardModel, CreditCardModel, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterWhereClause>
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

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterWhereClause> idBetween(
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

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterWhereClause>
  localIdEqualTo(String localId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'localId', value: [localId]),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterWhereClause>
  localIdNotEqualTo(String localId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'localId',
                lower: [],
                upper: [localId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'localId',
                lower: [localId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'localId',
                lower: [localId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'localId',
                lower: [],
                upper: [localId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterWhereClause>
  isDefaultEqualTo(bool isDefault) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'isDefault', value: [isDefault]),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterWhereClause>
  isDefaultNotEqualTo(bool isDefault) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'isDefault',
                lower: [],
                upper: [isDefault],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'isDefault',
                lower: [isDefault],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'isDefault',
                lower: [isDefault],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'isDefault',
                lower: [],
                upper: [isDefault],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension CreditCardModelQueryFilter
    on QueryBuilder<CreditCardModel, CreditCardModel, QFilterCondition> {
  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
  cardTypeNameEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'cardTypeName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
  cardTypeNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'cardTypeName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
  cardTypeNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'cardTypeName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
  cardTypeNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'cardTypeName',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
  cardTypeNameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'cardTypeName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
  cardTypeNameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'cardTypeName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
  cardTypeNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'cardTypeName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
  cardTypeNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'cardTypeName',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
  cardTypeNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'cardTypeName', value: ''),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
  cardTypeNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'cardTypeName', value: ''),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
  cardholderNameEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'cardholderName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
  cardholderNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'cardholderName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
  cardholderNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'cardholderName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
  cardholderNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'cardholderName',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
  cardholderNameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'cardholderName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
  cardholderNameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'cardholderName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
  cardholderNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'cardholderName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
  cardholderNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'cardholderName',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
  cardholderNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'cardholderName', value: ''),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
  cardholderNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'cardholderName', value: ''),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
  createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
  createdAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
  createdAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
  createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'createdAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
  encryptedCardNumberEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'encryptedCardNumber',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
  encryptedCardNumberGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'encryptedCardNumber',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
  encryptedCardNumberLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'encryptedCardNumber',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
  encryptedCardNumberBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'encryptedCardNumber',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
  encryptedCardNumberStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'encryptedCardNumber',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
  encryptedCardNumberEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'encryptedCardNumber',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
  encryptedCardNumberContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'encryptedCardNumber',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
  encryptedCardNumberMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'encryptedCardNumber',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
  encryptedCardNumberIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'encryptedCardNumber', value: ''),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
  encryptedCardNumberIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'encryptedCardNumber',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
  encryptedCvvEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'encryptedCvv',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
  encryptedCvvGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'encryptedCvv',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
  encryptedCvvLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'encryptedCvv',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
  encryptedCvvBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'encryptedCvv',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
  encryptedCvvStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'encryptedCvv',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
  encryptedCvvEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'encryptedCvv',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
  encryptedCvvContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'encryptedCvv',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
  encryptedCvvMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'encryptedCvv',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
  encryptedCvvIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'encryptedCvv', value: ''),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
  encryptedCvvIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'encryptedCvv', value: ''),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
  expiryMonthEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'expiryMonth',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
  expiryMonthGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'expiryMonth',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
  expiryMonthLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'expiryMonth',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
  expiryMonthBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'expiryMonth',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
  expiryMonthStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'expiryMonth',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
  expiryMonthEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'expiryMonth',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
  expiryMonthContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'expiryMonth',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
  expiryMonthMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'expiryMonth',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
  expiryMonthIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'expiryMonth', value: ''),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
  expiryMonthIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'expiryMonth', value: ''),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
  expiryYearEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'expiryYear',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
  expiryYearGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'expiryYear',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
  expiryYearLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'expiryYear',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
  expiryYearBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'expiryYear',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
  expiryYearStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'expiryYear',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
  expiryYearEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'expiryYear',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
  expiryYearContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'expiryYear',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
  expiryYearMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'expiryYear',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
  expiryYearIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'expiryYear', value: ''),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
  expiryYearIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'expiryYear', value: ''),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
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

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
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

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
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

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
  isDefaultEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isDefault', value: value),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
  localIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'localId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
  localIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'localId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
  localIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'localId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
  localIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'localId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
  localIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'localId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
  localIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'localId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
  localIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'localId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
  localIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'localId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
  localIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'localId', value: ''),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
  localIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'localId', value: ''),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
  updatedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'updatedAt'),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
  updatedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'updatedAt'),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
  updatedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'updatedAt', value: value),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
  updatedAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'updatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
  updatedAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'updatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
  updatedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'updatedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension CreditCardModelQueryObject
    on QueryBuilder<CreditCardModel, CreditCardModel, QFilterCondition> {}

extension CreditCardModelQueryLinks
    on QueryBuilder<CreditCardModel, CreditCardModel, QFilterCondition> {}

extension CreditCardModelQuerySortBy
    on QueryBuilder<CreditCardModel, CreditCardModel, QSortBy> {
  QueryBuilder<CreditCardModel, CreditCardModel, QAfterSortBy>
  sortByCardTypeName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardTypeName', Sort.asc);
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterSortBy>
  sortByCardTypeNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardTypeName', Sort.desc);
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterSortBy>
  sortByCardholderName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardholderName', Sort.asc);
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterSortBy>
  sortByCardholderNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardholderName', Sort.desc);
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterSortBy>
  sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterSortBy>
  sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterSortBy>
  sortByEncryptedCardNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'encryptedCardNumber', Sort.asc);
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterSortBy>
  sortByEncryptedCardNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'encryptedCardNumber', Sort.desc);
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterSortBy>
  sortByEncryptedCvv() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'encryptedCvv', Sort.asc);
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterSortBy>
  sortByEncryptedCvvDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'encryptedCvv', Sort.desc);
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterSortBy>
  sortByExpiryMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expiryMonth', Sort.asc);
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterSortBy>
  sortByExpiryMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expiryMonth', Sort.desc);
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterSortBy>
  sortByExpiryYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expiryYear', Sort.asc);
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterSortBy>
  sortByExpiryYearDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expiryYear', Sort.desc);
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterSortBy>
  sortByIsDefault() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDefault', Sort.asc);
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterSortBy>
  sortByIsDefaultDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDefault', Sort.desc);
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterSortBy> sortByLocalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localId', Sort.asc);
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterSortBy>
  sortByLocalIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localId', Sort.desc);
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterSortBy>
  sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterSortBy>
  sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension CreditCardModelQuerySortThenBy
    on QueryBuilder<CreditCardModel, CreditCardModel, QSortThenBy> {
  QueryBuilder<CreditCardModel, CreditCardModel, QAfterSortBy>
  thenByCardTypeName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardTypeName', Sort.asc);
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterSortBy>
  thenByCardTypeNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardTypeName', Sort.desc);
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterSortBy>
  thenByCardholderName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardholderName', Sort.asc);
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterSortBy>
  thenByCardholderNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardholderName', Sort.desc);
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterSortBy>
  thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterSortBy>
  thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterSortBy>
  thenByEncryptedCardNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'encryptedCardNumber', Sort.asc);
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterSortBy>
  thenByEncryptedCardNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'encryptedCardNumber', Sort.desc);
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterSortBy>
  thenByEncryptedCvv() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'encryptedCvv', Sort.asc);
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterSortBy>
  thenByEncryptedCvvDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'encryptedCvv', Sort.desc);
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterSortBy>
  thenByExpiryMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expiryMonth', Sort.asc);
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterSortBy>
  thenByExpiryMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expiryMonth', Sort.desc);
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterSortBy>
  thenByExpiryYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expiryYear', Sort.asc);
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterSortBy>
  thenByExpiryYearDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expiryYear', Sort.desc);
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterSortBy>
  thenByIsDefault() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDefault', Sort.asc);
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterSortBy>
  thenByIsDefaultDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDefault', Sort.desc);
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterSortBy> thenByLocalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localId', Sort.asc);
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterSortBy>
  thenByLocalIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localId', Sort.desc);
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterSortBy>
  thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterSortBy>
  thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension CreditCardModelQueryWhereDistinct
    on QueryBuilder<CreditCardModel, CreditCardModel, QDistinct> {
  QueryBuilder<CreditCardModel, CreditCardModel, QDistinct>
  distinctByCardTypeName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cardTypeName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QDistinct>
  distinctByCardholderName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'cardholderName',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QDistinct>
  distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QDistinct>
  distinctByEncryptedCardNumber({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'encryptedCardNumber',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QDistinct>
  distinctByEncryptedCvv({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'encryptedCvv', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QDistinct>
  distinctByExpiryMonth({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'expiryMonth', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QDistinct>
  distinctByExpiryYear({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'expiryYear', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QDistinct>
  distinctByIsDefault() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isDefault');
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QDistinct> distinctByLocalId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'localId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QDistinct>
  distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension CreditCardModelQueryProperty
    on QueryBuilder<CreditCardModel, CreditCardModel, QQueryProperty> {
  QueryBuilder<CreditCardModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CreditCardModel, String, QQueryOperations>
  cardTypeNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cardTypeName');
    });
  }

  QueryBuilder<CreditCardModel, String, QQueryOperations>
  cardholderNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cardholderName');
    });
  }

  QueryBuilder<CreditCardModel, DateTime, QQueryOperations>
  createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<CreditCardModel, String, QQueryOperations>
  encryptedCardNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'encryptedCardNumber');
    });
  }

  QueryBuilder<CreditCardModel, String, QQueryOperations>
  encryptedCvvProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'encryptedCvv');
    });
  }

  QueryBuilder<CreditCardModel, String, QQueryOperations>
  expiryMonthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'expiryMonth');
    });
  }

  QueryBuilder<CreditCardModel, String, QQueryOperations> expiryYearProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'expiryYear');
    });
  }

  QueryBuilder<CreditCardModel, bool, QQueryOperations> isDefaultProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isDefault');
    });
  }

  QueryBuilder<CreditCardModel, String, QQueryOperations> localIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'localId');
    });
  }

  QueryBuilder<CreditCardModel, DateTime?, QQueryOperations>
  updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}

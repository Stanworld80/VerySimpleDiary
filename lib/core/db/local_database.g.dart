// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_database.dart';

// ignore_for_file: type=lint
class $QuestionSetsTable extends QuestionSets
    with TableInfo<$QuestionSetsTable, QuestionSet> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuestionSetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _selectedPeriodsMeta =
      const VerificationMeta('selectedPeriods');
  @override
  late final GeneratedColumn<String> selectedPeriods = GeneratedColumn<String>(
      'selected_periods', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('nuit,matin,journee,soir'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, isActive, selectedPeriods, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'question_sets';
  @override
  VerificationContext validateIntegrity(Insertable<QuestionSet> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('selected_periods')) {
      context.handle(
          _selectedPeriodsMeta,
          selectedPeriods.isAcceptableOrUnknown(
              data['selected_periods']!, _selectedPeriodsMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QuestionSet map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuestionSet(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      selectedPeriods: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}selected_periods'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $QuestionSetsTable createAlias(String alias) {
    return $QuestionSetsTable(attachedDatabase, alias);
  }
}

class QuestionSet extends DataClass implements Insertable<QuestionSet> {
  final String id;
  final String name;
  final bool isActive;
  final String selectedPeriods;
  final DateTime createdAt;
  final DateTime updatedAt;
  const QuestionSet(
      {required this.id,
      required this.name,
      required this.isActive,
      required this.selectedPeriods,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['is_active'] = Variable<bool>(isActive);
    map['selected_periods'] = Variable<String>(selectedPeriods);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  QuestionSetsCompanion toCompanion(bool nullToAbsent) {
    return QuestionSetsCompanion(
      id: Value(id),
      name: Value(name),
      isActive: Value(isActive),
      selectedPeriods: Value(selectedPeriods),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory QuestionSet.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuestionSet(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      selectedPeriods: serializer.fromJson<String>(json['selectedPeriods']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'isActive': serializer.toJson<bool>(isActive),
      'selectedPeriods': serializer.toJson<String>(selectedPeriods),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  QuestionSet copyWith(
          {String? id,
          String? name,
          bool? isActive,
          String? selectedPeriods,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      QuestionSet(
        id: id ?? this.id,
        name: name ?? this.name,
        isActive: isActive ?? this.isActive,
        selectedPeriods: selectedPeriods ?? this.selectedPeriods,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  QuestionSet copyWithCompanion(QuestionSetsCompanion data) {
    return QuestionSet(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      selectedPeriods: data.selectedPeriods.present
          ? data.selectedPeriods.value
          : this.selectedPeriods,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuestionSet(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isActive: $isActive, ')
          ..write('selectedPeriods: $selectedPeriods, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, isActive, selectedPeriods, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuestionSet &&
          other.id == this.id &&
          other.name == this.name &&
          other.isActive == this.isActive &&
          other.selectedPeriods == this.selectedPeriods &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class QuestionSetsCompanion extends UpdateCompanion<QuestionSet> {
  final Value<String> id;
  final Value<String> name;
  final Value<bool> isActive;
  final Value<String> selectedPeriods;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const QuestionSetsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.isActive = const Value.absent(),
    this.selectedPeriods = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  QuestionSetsCompanion.insert({
    required String id,
    required String name,
    this.isActive = const Value.absent(),
    this.selectedPeriods = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<QuestionSet> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<bool>? isActive,
    Expression<String>? selectedPeriods,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (isActive != null) 'is_active': isActive,
      if (selectedPeriods != null) 'selected_periods': selectedPeriods,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  QuestionSetsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<bool>? isActive,
      Value<String>? selectedPeriods,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return QuestionSetsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
      selectedPeriods: selectedPeriods ?? this.selectedPeriods,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (selectedPeriods.present) {
      map['selected_periods'] = Variable<String>(selectedPeriods.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuestionSetsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isActive: $isActive, ')
          ..write('selectedPeriods: $selectedPeriods, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DiaryDaysTable extends DiaryDays
    with TableInfo<$DiaryDaysTable, DiaryDay> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DiaryDaysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
      'date', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _totalScoreMeta =
      const VerificationMeta('totalScore');
  @override
  late final GeneratedColumn<double> totalScore = GeneratedColumn<double>(
      'total_score', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _meanScoreMeta =
      const VerificationMeta('meanScore');
  @override
  late final GeneratedColumn<double> meanScore = GeneratedColumn<double>(
      'mean_score', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _medianScoreMeta =
      const VerificationMeta('medianScore');
  @override
  late final GeneratedColumn<double> medianScore = GeneratedColumn<double>(
      'median_score', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<String> level = GeneratedColumn<String>(
      'level', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _insightTextMeta =
      const VerificationMeta('insightText');
  @override
  late final GeneratedColumn<String> insightText = GeneratedColumn<String>(
      'insight_text', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _syncedAtMeta =
      const VerificationMeta('syncedAt');
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
      'synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _questionSetIdMeta =
      const VerificationMeta('questionSetId');
  @override
  late final GeneratedColumn<String> questionSetId = GeneratedColumn<String>(
      'question_set_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES question_sets (id) ON DELETE SET NULL'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        date,
        status,
        totalScore,
        meanScore,
        medianScore,
        level,
        insightText,
        createdAt,
        updatedAt,
        syncedAt,
        questionSetId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'diary_days';
  @override
  VerificationContext validateIntegrity(Insertable<DiaryDay> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('total_score')) {
      context.handle(
          _totalScoreMeta,
          totalScore.isAcceptableOrUnknown(
              data['total_score']!, _totalScoreMeta));
    } else if (isInserting) {
      context.missing(_totalScoreMeta);
    }
    if (data.containsKey('mean_score')) {
      context.handle(_meanScoreMeta,
          meanScore.isAcceptableOrUnknown(data['mean_score']!, _meanScoreMeta));
    } else if (isInserting) {
      context.missing(_meanScoreMeta);
    }
    if (data.containsKey('median_score')) {
      context.handle(
          _medianScoreMeta,
          medianScore.isAcceptableOrUnknown(
              data['median_score']!, _medianScoreMeta));
    } else if (isInserting) {
      context.missing(_medianScoreMeta);
    }
    if (data.containsKey('level')) {
      context.handle(
          _levelMeta, level.isAcceptableOrUnknown(data['level']!, _levelMeta));
    } else if (isInserting) {
      context.missing(_levelMeta);
    }
    if (data.containsKey('insight_text')) {
      context.handle(
          _insightTextMeta,
          insightText.isAcceptableOrUnknown(
              data['insight_text']!, _insightTextMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('synced_at')) {
      context.handle(_syncedAtMeta,
          syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta));
    }
    if (data.containsKey('question_set_id')) {
      context.handle(
          _questionSetIdMeta,
          questionSetId.isAcceptableOrUnknown(
              data['question_set_id']!, _questionSetIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DiaryDay map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DiaryDay(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      totalScore: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total_score'])!,
      meanScore: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}mean_score'])!,
      medianScore: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}median_score'])!,
      level: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}level'])!,
      insightText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}insight_text']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      syncedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}synced_at']),
      questionSetId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}question_set_id']),
    );
  }

  @override
  $DiaryDaysTable createAlias(String alias) {
    return $DiaryDaysTable(attachedDatabase, alias);
  }
}

class DiaryDay extends DataClass implements Insertable<DiaryDay> {
  final String id;
  final String date;
  final String status;
  final double totalScore;
  final double meanScore;
  final double medianScore;
  final String level;
  final String? insightText;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? syncedAt;
  final String? questionSetId;
  const DiaryDay(
      {required this.id,
      required this.date,
      required this.status,
      required this.totalScore,
      required this.meanScore,
      required this.medianScore,
      required this.level,
      this.insightText,
      required this.createdAt,
      required this.updatedAt,
      this.syncedAt,
      this.questionSetId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['date'] = Variable<String>(date);
    map['status'] = Variable<String>(status);
    map['total_score'] = Variable<double>(totalScore);
    map['mean_score'] = Variable<double>(meanScore);
    map['median_score'] = Variable<double>(medianScore);
    map['level'] = Variable<String>(level);
    if (!nullToAbsent || insightText != null) {
      map['insight_text'] = Variable<String>(insightText);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    if (!nullToAbsent || questionSetId != null) {
      map['question_set_id'] = Variable<String>(questionSetId);
    }
    return map;
  }

  DiaryDaysCompanion toCompanion(bool nullToAbsent) {
    return DiaryDaysCompanion(
      id: Value(id),
      date: Value(date),
      status: Value(status),
      totalScore: Value(totalScore),
      meanScore: Value(meanScore),
      medianScore: Value(medianScore),
      level: Value(level),
      insightText: insightText == null && nullToAbsent
          ? const Value.absent()
          : Value(insightText),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
      questionSetId: questionSetId == null && nullToAbsent
          ? const Value.absent()
          : Value(questionSetId),
    );
  }

  factory DiaryDay.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DiaryDay(
      id: serializer.fromJson<String>(json['id']),
      date: serializer.fromJson<String>(json['date']),
      status: serializer.fromJson<String>(json['status']),
      totalScore: serializer.fromJson<double>(json['totalScore']),
      meanScore: serializer.fromJson<double>(json['meanScore']),
      medianScore: serializer.fromJson<double>(json['medianScore']),
      level: serializer.fromJson<String>(json['level']),
      insightText: serializer.fromJson<String?>(json['insightText']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
      questionSetId: serializer.fromJson<String?>(json['questionSetId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'date': serializer.toJson<String>(date),
      'status': serializer.toJson<String>(status),
      'totalScore': serializer.toJson<double>(totalScore),
      'meanScore': serializer.toJson<double>(meanScore),
      'medianScore': serializer.toJson<double>(medianScore),
      'level': serializer.toJson<String>(level),
      'insightText': serializer.toJson<String?>(insightText),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
      'questionSetId': serializer.toJson<String?>(questionSetId),
    };
  }

  DiaryDay copyWith(
          {String? id,
          String? date,
          String? status,
          double? totalScore,
          double? meanScore,
          double? medianScore,
          String? level,
          Value<String?> insightText = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> syncedAt = const Value.absent(),
          Value<String?> questionSetId = const Value.absent()}) =>
      DiaryDay(
        id: id ?? this.id,
        date: date ?? this.date,
        status: status ?? this.status,
        totalScore: totalScore ?? this.totalScore,
        meanScore: meanScore ?? this.meanScore,
        medianScore: medianScore ?? this.medianScore,
        level: level ?? this.level,
        insightText: insightText.present ? insightText.value : this.insightText,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
        questionSetId:
            questionSetId.present ? questionSetId.value : this.questionSetId,
      );
  DiaryDay copyWithCompanion(DiaryDaysCompanion data) {
    return DiaryDay(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      status: data.status.present ? data.status.value : this.status,
      totalScore:
          data.totalScore.present ? data.totalScore.value : this.totalScore,
      meanScore: data.meanScore.present ? data.meanScore.value : this.meanScore,
      medianScore:
          data.medianScore.present ? data.medianScore.value : this.medianScore,
      level: data.level.present ? data.level.value : this.level,
      insightText:
          data.insightText.present ? data.insightText.value : this.insightText,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
      questionSetId: data.questionSetId.present
          ? data.questionSetId.value
          : this.questionSetId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DiaryDay(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('status: $status, ')
          ..write('totalScore: $totalScore, ')
          ..write('meanScore: $meanScore, ')
          ..write('medianScore: $medianScore, ')
          ..write('level: $level, ')
          ..write('insightText: $insightText, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('questionSetId: $questionSetId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      date,
      status,
      totalScore,
      meanScore,
      medianScore,
      level,
      insightText,
      createdAt,
      updatedAt,
      syncedAt,
      questionSetId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DiaryDay &&
          other.id == this.id &&
          other.date == this.date &&
          other.status == this.status &&
          other.totalScore == this.totalScore &&
          other.meanScore == this.meanScore &&
          other.medianScore == this.medianScore &&
          other.level == this.level &&
          other.insightText == this.insightText &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncedAt == this.syncedAt &&
          other.questionSetId == this.questionSetId);
}

class DiaryDaysCompanion extends UpdateCompanion<DiaryDay> {
  final Value<String> id;
  final Value<String> date;
  final Value<String> status;
  final Value<double> totalScore;
  final Value<double> meanScore;
  final Value<double> medianScore;
  final Value<String> level;
  final Value<String?> insightText;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> syncedAt;
  final Value<String?> questionSetId;
  final Value<int> rowid;
  const DiaryDaysCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.status = const Value.absent(),
    this.totalScore = const Value.absent(),
    this.meanScore = const Value.absent(),
    this.medianScore = const Value.absent(),
    this.level = const Value.absent(),
    this.insightText = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.questionSetId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DiaryDaysCompanion.insert({
    required String id,
    required String date,
    required String status,
    required double totalScore,
    required double meanScore,
    required double medianScore,
    required String level,
    this.insightText = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.syncedAt = const Value.absent(),
    this.questionSetId = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        date = Value(date),
        status = Value(status),
        totalScore = Value(totalScore),
        meanScore = Value(meanScore),
        medianScore = Value(medianScore),
        level = Value(level),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<DiaryDay> custom({
    Expression<String>? id,
    Expression<String>? date,
    Expression<String>? status,
    Expression<double>? totalScore,
    Expression<double>? meanScore,
    Expression<double>? medianScore,
    Expression<String>? level,
    Expression<String>? insightText,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? syncedAt,
    Expression<String>? questionSetId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (status != null) 'status': status,
      if (totalScore != null) 'total_score': totalScore,
      if (meanScore != null) 'mean_score': meanScore,
      if (medianScore != null) 'median_score': medianScore,
      if (level != null) 'level': level,
      if (insightText != null) 'insight_text': insightText,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (questionSetId != null) 'question_set_id': questionSetId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DiaryDaysCompanion copyWith(
      {Value<String>? id,
      Value<String>? date,
      Value<String>? status,
      Value<double>? totalScore,
      Value<double>? meanScore,
      Value<double>? medianScore,
      Value<String>? level,
      Value<String?>? insightText,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? syncedAt,
      Value<String?>? questionSetId,
      Value<int>? rowid}) {
    return DiaryDaysCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      status: status ?? this.status,
      totalScore: totalScore ?? this.totalScore,
      meanScore: meanScore ?? this.meanScore,
      medianScore: medianScore ?? this.medianScore,
      level: level ?? this.level,
      insightText: insightText ?? this.insightText,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      questionSetId: questionSetId ?? this.questionSetId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (totalScore.present) {
      map['total_score'] = Variable<double>(totalScore.value);
    }
    if (meanScore.present) {
      map['mean_score'] = Variable<double>(meanScore.value);
    }
    if (medianScore.present) {
      map['median_score'] = Variable<double>(medianScore.value);
    }
    if (level.present) {
      map['level'] = Variable<String>(level.value);
    }
    if (insightText.present) {
      map['insight_text'] = Variable<String>(insightText.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (questionSetId.present) {
      map['question_set_id'] = Variable<String>(questionSetId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DiaryDaysCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('status: $status, ')
          ..write('totalScore: $totalScore, ')
          ..write('meanScore: $meanScore, ')
          ..write('medianScore: $medianScore, ')
          ..write('level: $level, ')
          ..write('insightText: $insightText, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('questionSetId: $questionSetId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DiaryResponsesTable extends DiaryResponses
    with TableInfo<$DiaryResponsesTable, DiaryResponse> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DiaryResponsesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _diaryDayIdMeta =
      const VerificationMeta('diaryDayId');
  @override
  late final GeneratedColumn<String> diaryDayId = GeneratedColumn<String>(
      'diary_day_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES diary_days (id) ON DELETE CASCADE'));
  static const VerificationMeta _questionNumberMeta =
      const VerificationMeta('questionNumber');
  @override
  late final GeneratedColumn<int> questionNumber = GeneratedColumn<int>(
      'question_number', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _nuitValuesMeta =
      const VerificationMeta('nuitValues');
  @override
  late final GeneratedColumn<String> nuitValues = GeneratedColumn<String>(
      'nuit_values', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _matinValuesMeta =
      const VerificationMeta('matinValues');
  @override
  late final GeneratedColumn<String> matinValues = GeneratedColumn<String>(
      'matin_values', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _journeeValuesMeta =
      const VerificationMeta('journeeValues');
  @override
  late final GeneratedColumn<String> journeeValues = GeneratedColumn<String>(
      'journee_values', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _soirValuesMeta =
      const VerificationMeta('soirValues');
  @override
  late final GeneratedColumn<String> soirValues = GeneratedColumn<String>(
      'soir_values', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nuitCommentMeta =
      const VerificationMeta('nuitComment');
  @override
  late final GeneratedColumn<String> nuitComment = GeneratedColumn<String>(
      'nuit_comment', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _matinCommentMeta =
      const VerificationMeta('matinComment');
  @override
  late final GeneratedColumn<String> matinComment = GeneratedColumn<String>(
      'matin_comment', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _journeeCommentMeta =
      const VerificationMeta('journeeComment');
  @override
  late final GeneratedColumn<String> journeeComment = GeneratedColumn<String>(
      'journee_comment', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _soirCommentMeta =
      const VerificationMeta('soirComment');
  @override
  late final GeneratedColumn<String> soirComment = GeneratedColumn<String>(
      'soir_comment', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        diaryDayId,
        questionNumber,
        nuitValues,
        matinValues,
        journeeValues,
        soirValues,
        nuitComment,
        matinComment,
        journeeComment,
        soirComment,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'diary_responses';
  @override
  VerificationContext validateIntegrity(Insertable<DiaryResponse> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('diary_day_id')) {
      context.handle(
          _diaryDayIdMeta,
          diaryDayId.isAcceptableOrUnknown(
              data['diary_day_id']!, _diaryDayIdMeta));
    } else if (isInserting) {
      context.missing(_diaryDayIdMeta);
    }
    if (data.containsKey('question_number')) {
      context.handle(
          _questionNumberMeta,
          questionNumber.isAcceptableOrUnknown(
              data['question_number']!, _questionNumberMeta));
    } else if (isInserting) {
      context.missing(_questionNumberMeta);
    }
    if (data.containsKey('nuit_values')) {
      context.handle(
          _nuitValuesMeta,
          nuitValues.isAcceptableOrUnknown(
              data['nuit_values']!, _nuitValuesMeta));
    } else if (isInserting) {
      context.missing(_nuitValuesMeta);
    }
    if (data.containsKey('matin_values')) {
      context.handle(
          _matinValuesMeta,
          matinValues.isAcceptableOrUnknown(
              data['matin_values']!, _matinValuesMeta));
    } else if (isInserting) {
      context.missing(_matinValuesMeta);
    }
    if (data.containsKey('journee_values')) {
      context.handle(
          _journeeValuesMeta,
          journeeValues.isAcceptableOrUnknown(
              data['journee_values']!, _journeeValuesMeta));
    } else if (isInserting) {
      context.missing(_journeeValuesMeta);
    }
    if (data.containsKey('soir_values')) {
      context.handle(
          _soirValuesMeta,
          soirValues.isAcceptableOrUnknown(
              data['soir_values']!, _soirValuesMeta));
    } else if (isInserting) {
      context.missing(_soirValuesMeta);
    }
    if (data.containsKey('nuit_comment')) {
      context.handle(
          _nuitCommentMeta,
          nuitComment.isAcceptableOrUnknown(
              data['nuit_comment']!, _nuitCommentMeta));
    }
    if (data.containsKey('matin_comment')) {
      context.handle(
          _matinCommentMeta,
          matinComment.isAcceptableOrUnknown(
              data['matin_comment']!, _matinCommentMeta));
    }
    if (data.containsKey('journee_comment')) {
      context.handle(
          _journeeCommentMeta,
          journeeComment.isAcceptableOrUnknown(
              data['journee_comment']!, _journeeCommentMeta));
    }
    if (data.containsKey('soir_comment')) {
      context.handle(
          _soirCommentMeta,
          soirComment.isAcceptableOrUnknown(
              data['soir_comment']!, _soirCommentMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DiaryResponse map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DiaryResponse(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      diaryDayId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}diary_day_id'])!,
      questionNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}question_number'])!,
      nuitValues: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nuit_values'])!,
      matinValues: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}matin_values'])!,
      journeeValues: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}journee_values'])!,
      soirValues: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}soir_values'])!,
      nuitComment: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nuit_comment'])!,
      matinComment: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}matin_comment'])!,
      journeeComment: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}journee_comment'])!,
      soirComment: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}soir_comment'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $DiaryResponsesTable createAlias(String alias) {
    return $DiaryResponsesTable(attachedDatabase, alias);
  }
}

class DiaryResponse extends DataClass implements Insertable<DiaryResponse> {
  final String id;
  final String diaryDayId;
  final int questionNumber;
  final String nuitValues;
  final String matinValues;
  final String journeeValues;
  final String soirValues;
  final String nuitComment;
  final String matinComment;
  final String journeeComment;
  final String soirComment;
  final DateTime updatedAt;
  const DiaryResponse(
      {required this.id,
      required this.diaryDayId,
      required this.questionNumber,
      required this.nuitValues,
      required this.matinValues,
      required this.journeeValues,
      required this.soirValues,
      required this.nuitComment,
      required this.matinComment,
      required this.journeeComment,
      required this.soirComment,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['diary_day_id'] = Variable<String>(diaryDayId);
    map['question_number'] = Variable<int>(questionNumber);
    map['nuit_values'] = Variable<String>(nuitValues);
    map['matin_values'] = Variable<String>(matinValues);
    map['journee_values'] = Variable<String>(journeeValues);
    map['soir_values'] = Variable<String>(soirValues);
    map['nuit_comment'] = Variable<String>(nuitComment);
    map['matin_comment'] = Variable<String>(matinComment);
    map['journee_comment'] = Variable<String>(journeeComment);
    map['soir_comment'] = Variable<String>(soirComment);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DiaryResponsesCompanion toCompanion(bool nullToAbsent) {
    return DiaryResponsesCompanion(
      id: Value(id),
      diaryDayId: Value(diaryDayId),
      questionNumber: Value(questionNumber),
      nuitValues: Value(nuitValues),
      matinValues: Value(matinValues),
      journeeValues: Value(journeeValues),
      soirValues: Value(soirValues),
      nuitComment: Value(nuitComment),
      matinComment: Value(matinComment),
      journeeComment: Value(journeeComment),
      soirComment: Value(soirComment),
      updatedAt: Value(updatedAt),
    );
  }

  factory DiaryResponse.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DiaryResponse(
      id: serializer.fromJson<String>(json['id']),
      diaryDayId: serializer.fromJson<String>(json['diaryDayId']),
      questionNumber: serializer.fromJson<int>(json['questionNumber']),
      nuitValues: serializer.fromJson<String>(json['nuitValues']),
      matinValues: serializer.fromJson<String>(json['matinValues']),
      journeeValues: serializer.fromJson<String>(json['journeeValues']),
      soirValues: serializer.fromJson<String>(json['soirValues']),
      nuitComment: serializer.fromJson<String>(json['nuitComment']),
      matinComment: serializer.fromJson<String>(json['matinComment']),
      journeeComment: serializer.fromJson<String>(json['journeeComment']),
      soirComment: serializer.fromJson<String>(json['soirComment']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'diaryDayId': serializer.toJson<String>(diaryDayId),
      'questionNumber': serializer.toJson<int>(questionNumber),
      'nuitValues': serializer.toJson<String>(nuitValues),
      'matinValues': serializer.toJson<String>(matinValues),
      'journeeValues': serializer.toJson<String>(journeeValues),
      'soirValues': serializer.toJson<String>(soirValues),
      'nuitComment': serializer.toJson<String>(nuitComment),
      'matinComment': serializer.toJson<String>(matinComment),
      'journeeComment': serializer.toJson<String>(journeeComment),
      'soirComment': serializer.toJson<String>(soirComment),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DiaryResponse copyWith(
          {String? id,
          String? diaryDayId,
          int? questionNumber,
          String? nuitValues,
          String? matinValues,
          String? journeeValues,
          String? soirValues,
          String? nuitComment,
          String? matinComment,
          String? journeeComment,
          String? soirComment,
          DateTime? updatedAt}) =>
      DiaryResponse(
        id: id ?? this.id,
        diaryDayId: diaryDayId ?? this.diaryDayId,
        questionNumber: questionNumber ?? this.questionNumber,
        nuitValues: nuitValues ?? this.nuitValues,
        matinValues: matinValues ?? this.matinValues,
        journeeValues: journeeValues ?? this.journeeValues,
        soirValues: soirValues ?? this.soirValues,
        nuitComment: nuitComment ?? this.nuitComment,
        matinComment: matinComment ?? this.matinComment,
        journeeComment: journeeComment ?? this.journeeComment,
        soirComment: soirComment ?? this.soirComment,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  DiaryResponse copyWithCompanion(DiaryResponsesCompanion data) {
    return DiaryResponse(
      id: data.id.present ? data.id.value : this.id,
      diaryDayId:
          data.diaryDayId.present ? data.diaryDayId.value : this.diaryDayId,
      questionNumber: data.questionNumber.present
          ? data.questionNumber.value
          : this.questionNumber,
      nuitValues:
          data.nuitValues.present ? data.nuitValues.value : this.nuitValues,
      matinValues:
          data.matinValues.present ? data.matinValues.value : this.matinValues,
      journeeValues: data.journeeValues.present
          ? data.journeeValues.value
          : this.journeeValues,
      soirValues:
          data.soirValues.present ? data.soirValues.value : this.soirValues,
      nuitComment:
          data.nuitComment.present ? data.nuitComment.value : this.nuitComment,
      matinComment: data.matinComment.present
          ? data.matinComment.value
          : this.matinComment,
      journeeComment: data.journeeComment.present
          ? data.journeeComment.value
          : this.journeeComment,
      soirComment:
          data.soirComment.present ? data.soirComment.value : this.soirComment,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DiaryResponse(')
          ..write('id: $id, ')
          ..write('diaryDayId: $diaryDayId, ')
          ..write('questionNumber: $questionNumber, ')
          ..write('nuitValues: $nuitValues, ')
          ..write('matinValues: $matinValues, ')
          ..write('journeeValues: $journeeValues, ')
          ..write('soirValues: $soirValues, ')
          ..write('nuitComment: $nuitComment, ')
          ..write('matinComment: $matinComment, ')
          ..write('journeeComment: $journeeComment, ')
          ..write('soirComment: $soirComment, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      diaryDayId,
      questionNumber,
      nuitValues,
      matinValues,
      journeeValues,
      soirValues,
      nuitComment,
      matinComment,
      journeeComment,
      soirComment,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DiaryResponse &&
          other.id == this.id &&
          other.diaryDayId == this.diaryDayId &&
          other.questionNumber == this.questionNumber &&
          other.nuitValues == this.nuitValues &&
          other.matinValues == this.matinValues &&
          other.journeeValues == this.journeeValues &&
          other.soirValues == this.soirValues &&
          other.nuitComment == this.nuitComment &&
          other.matinComment == this.matinComment &&
          other.journeeComment == this.journeeComment &&
          other.soirComment == this.soirComment &&
          other.updatedAt == this.updatedAt);
}

class DiaryResponsesCompanion extends UpdateCompanion<DiaryResponse> {
  final Value<String> id;
  final Value<String> diaryDayId;
  final Value<int> questionNumber;
  final Value<String> nuitValues;
  final Value<String> matinValues;
  final Value<String> journeeValues;
  final Value<String> soirValues;
  final Value<String> nuitComment;
  final Value<String> matinComment;
  final Value<String> journeeComment;
  final Value<String> soirComment;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const DiaryResponsesCompanion({
    this.id = const Value.absent(),
    this.diaryDayId = const Value.absent(),
    this.questionNumber = const Value.absent(),
    this.nuitValues = const Value.absent(),
    this.matinValues = const Value.absent(),
    this.journeeValues = const Value.absent(),
    this.soirValues = const Value.absent(),
    this.nuitComment = const Value.absent(),
    this.matinComment = const Value.absent(),
    this.journeeComment = const Value.absent(),
    this.soirComment = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DiaryResponsesCompanion.insert({
    required String id,
    required String diaryDayId,
    required int questionNumber,
    required String nuitValues,
    required String matinValues,
    required String journeeValues,
    required String soirValues,
    this.nuitComment = const Value.absent(),
    this.matinComment = const Value.absent(),
    this.journeeComment = const Value.absent(),
    this.soirComment = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        diaryDayId = Value(diaryDayId),
        questionNumber = Value(questionNumber),
        nuitValues = Value(nuitValues),
        matinValues = Value(matinValues),
        journeeValues = Value(journeeValues),
        soirValues = Value(soirValues),
        updatedAt = Value(updatedAt);
  static Insertable<DiaryResponse> custom({
    Expression<String>? id,
    Expression<String>? diaryDayId,
    Expression<int>? questionNumber,
    Expression<String>? nuitValues,
    Expression<String>? matinValues,
    Expression<String>? journeeValues,
    Expression<String>? soirValues,
    Expression<String>? nuitComment,
    Expression<String>? matinComment,
    Expression<String>? journeeComment,
    Expression<String>? soirComment,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (diaryDayId != null) 'diary_day_id': diaryDayId,
      if (questionNumber != null) 'question_number': questionNumber,
      if (nuitValues != null) 'nuit_values': nuitValues,
      if (matinValues != null) 'matin_values': matinValues,
      if (journeeValues != null) 'journee_values': journeeValues,
      if (soirValues != null) 'soir_values': soirValues,
      if (nuitComment != null) 'nuit_comment': nuitComment,
      if (matinComment != null) 'matin_comment': matinComment,
      if (journeeComment != null) 'journee_comment': journeeComment,
      if (soirComment != null) 'soir_comment': soirComment,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DiaryResponsesCompanion copyWith(
      {Value<String>? id,
      Value<String>? diaryDayId,
      Value<int>? questionNumber,
      Value<String>? nuitValues,
      Value<String>? matinValues,
      Value<String>? journeeValues,
      Value<String>? soirValues,
      Value<String>? nuitComment,
      Value<String>? matinComment,
      Value<String>? journeeComment,
      Value<String>? soirComment,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return DiaryResponsesCompanion(
      id: id ?? this.id,
      diaryDayId: diaryDayId ?? this.diaryDayId,
      questionNumber: questionNumber ?? this.questionNumber,
      nuitValues: nuitValues ?? this.nuitValues,
      matinValues: matinValues ?? this.matinValues,
      journeeValues: journeeValues ?? this.journeeValues,
      soirValues: soirValues ?? this.soirValues,
      nuitComment: nuitComment ?? this.nuitComment,
      matinComment: matinComment ?? this.matinComment,
      journeeComment: journeeComment ?? this.journeeComment,
      soirComment: soirComment ?? this.soirComment,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (diaryDayId.present) {
      map['diary_day_id'] = Variable<String>(diaryDayId.value);
    }
    if (questionNumber.present) {
      map['question_number'] = Variable<int>(questionNumber.value);
    }
    if (nuitValues.present) {
      map['nuit_values'] = Variable<String>(nuitValues.value);
    }
    if (matinValues.present) {
      map['matin_values'] = Variable<String>(matinValues.value);
    }
    if (journeeValues.present) {
      map['journee_values'] = Variable<String>(journeeValues.value);
    }
    if (soirValues.present) {
      map['soir_values'] = Variable<String>(soirValues.value);
    }
    if (nuitComment.present) {
      map['nuit_comment'] = Variable<String>(nuitComment.value);
    }
    if (matinComment.present) {
      map['matin_comment'] = Variable<String>(matinComment.value);
    }
    if (journeeComment.present) {
      map['journee_comment'] = Variable<String>(journeeComment.value);
    }
    if (soirComment.present) {
      map['soir_comment'] = Variable<String>(soirComment.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DiaryResponsesCompanion(')
          ..write('id: $id, ')
          ..write('diaryDayId: $diaryDayId, ')
          ..write('questionNumber: $questionNumber, ')
          ..write('nuitValues: $nuitValues, ')
          ..write('matinValues: $matinValues, ')
          ..write('journeeValues: $journeeValues, ')
          ..write('soirValues: $soirValues, ')
          ..write('nuitComment: $nuitComment, ')
          ..write('matinComment: $matinComment, ')
          ..write('journeeComment: $journeeComment, ')
          ..write('soirComment: $soirComment, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $QuestionCategoriesTable extends QuestionCategories
    with TableInfo<$QuestionCategoriesTable, QuestionCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuestionCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
      'color', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('#6C63FF'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, name, color, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'question_categories';
  @override
  VerificationContext validateIntegrity(Insertable<QuestionCategory> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QuestionCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuestionCategory(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $QuestionCategoriesTable createAlias(String alias) {
    return $QuestionCategoriesTable(attachedDatabase, alias);
  }
}

class QuestionCategory extends DataClass
    implements Insertable<QuestionCategory> {
  final String id;
  final String name;
  final String color;
  final DateTime createdAt;
  final DateTime updatedAt;
  const QuestionCategory(
      {required this.id,
      required this.name,
      required this.color,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['color'] = Variable<String>(color);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  QuestionCategoriesCompanion toCompanion(bool nullToAbsent) {
    return QuestionCategoriesCompanion(
      id: Value(id),
      name: Value(name),
      color: Value(color),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory QuestionCategory.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuestionCategory(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      color: serializer.fromJson<String>(json['color']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'color': serializer.toJson<String>(color),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  QuestionCategory copyWith(
          {String? id,
          String? name,
          String? color,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      QuestionCategory(
        id: id ?? this.id,
        name: name ?? this.name,
        color: color ?? this.color,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  QuestionCategory copyWithCompanion(QuestionCategoriesCompanion data) {
    return QuestionCategory(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      color: data.color.present ? data.color.value : this.color,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuestionCategory(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, color, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuestionCategory &&
          other.id == this.id &&
          other.name == this.name &&
          other.color == this.color &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class QuestionCategoriesCompanion extends UpdateCompanion<QuestionCategory> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> color;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const QuestionCategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.color = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  QuestionCategoriesCompanion.insert({
    required String id,
    required String name,
    this.color = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<QuestionCategory> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? color,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (color != null) 'color': color,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  QuestionCategoriesCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? color,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return QuestionCategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuestionCategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CustomQuestionsTable extends CustomQuestions
    with TableInfo<$CustomQuestionsTable, CustomQuestion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomQuestionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _setIdMeta = const VerificationMeta('setId');
  @override
  late final GeneratedColumn<String> setId = GeneratedColumn<String>(
      'set_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES question_sets (id) ON DELETE CASCADE'));
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<int> number = GeneratedColumn<int>(
      'number', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
      'category_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES question_categories (id) ON DELETE SET NULL'));
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        setId,
        number,
        categoryId,
        category,
        title,
        description,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'custom_questions';
  @override
  VerificationContext validateIntegrity(Insertable<CustomQuestion> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('set_id')) {
      context.handle(
          _setIdMeta, setId.isAcceptableOrUnknown(data['set_id']!, _setIdMeta));
    } else if (isInserting) {
      context.missing(_setIdMeta);
    }
    if (data.containsKey('number')) {
      context.handle(_numberMeta,
          number.isAcceptableOrUnknown(data['number']!, _numberMeta));
    } else if (isInserting) {
      context.missing(_numberMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomQuestion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomQuestion(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      setId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}set_id'])!,
      number: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}number'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_id']),
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $CustomQuestionsTable createAlias(String alias) {
    return $CustomQuestionsTable(attachedDatabase, alias);
  }
}

class CustomQuestion extends DataClass implements Insertable<CustomQuestion> {
  final String id;
  final String setId;
  final int number;
  final String? categoryId;
  final String category;
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;
  const CustomQuestion(
      {required this.id,
      required this.setId,
      required this.number,
      this.categoryId,
      required this.category,
      required this.title,
      required this.description,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['set_id'] = Variable<String>(setId);
    map['number'] = Variable<int>(number);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    map['category'] = Variable<String>(category);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CustomQuestionsCompanion toCompanion(bool nullToAbsent) {
    return CustomQuestionsCompanion(
      id: Value(id),
      setId: Value(setId),
      number: Value(number),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      category: Value(category),
      title: Value(title),
      description: Value(description),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory CustomQuestion.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomQuestion(
      id: serializer.fromJson<String>(json['id']),
      setId: serializer.fromJson<String>(json['setId']),
      number: serializer.fromJson<int>(json['number']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      category: serializer.fromJson<String>(json['category']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'setId': serializer.toJson<String>(setId),
      'number': serializer.toJson<int>(number),
      'categoryId': serializer.toJson<String?>(categoryId),
      'category': serializer.toJson<String>(category),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CustomQuestion copyWith(
          {String? id,
          String? setId,
          int? number,
          Value<String?> categoryId = const Value.absent(),
          String? category,
          String? title,
          String? description,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      CustomQuestion(
        id: id ?? this.id,
        setId: setId ?? this.setId,
        number: number ?? this.number,
        categoryId: categoryId.present ? categoryId.value : this.categoryId,
        category: category ?? this.category,
        title: title ?? this.title,
        description: description ?? this.description,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  CustomQuestion copyWithCompanion(CustomQuestionsCompanion data) {
    return CustomQuestion(
      id: data.id.present ? data.id.value : this.id,
      setId: data.setId.present ? data.setId.value : this.setId,
      number: data.number.present ? data.number.value : this.number,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      category: data.category.present ? data.category.value : this.category,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomQuestion(')
          ..write('id: $id, ')
          ..write('setId: $setId, ')
          ..write('number: $number, ')
          ..write('categoryId: $categoryId, ')
          ..write('category: $category, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, setId, number, categoryId, category,
      title, description, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomQuestion &&
          other.id == this.id &&
          other.setId == this.setId &&
          other.number == this.number &&
          other.categoryId == this.categoryId &&
          other.category == this.category &&
          other.title == this.title &&
          other.description == this.description &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CustomQuestionsCompanion extends UpdateCompanion<CustomQuestion> {
  final Value<String> id;
  final Value<String> setId;
  final Value<int> number;
  final Value<String?> categoryId;
  final Value<String> category;
  final Value<String> title;
  final Value<String> description;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CustomQuestionsCompanion({
    this.id = const Value.absent(),
    this.setId = const Value.absent(),
    this.number = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.category = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomQuestionsCompanion.insert({
    required String id,
    required String setId,
    required int number,
    this.categoryId = const Value.absent(),
    this.category = const Value.absent(),
    required String title,
    required String description,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        setId = Value(setId),
        number = Value(number),
        title = Value(title),
        description = Value(description),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<CustomQuestion> custom({
    Expression<String>? id,
    Expression<String>? setId,
    Expression<int>? number,
    Expression<String>? categoryId,
    Expression<String>? category,
    Expression<String>? title,
    Expression<String>? description,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (setId != null) 'set_id': setId,
      if (number != null) 'number': number,
      if (categoryId != null) 'category_id': categoryId,
      if (category != null) 'category': category,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomQuestionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? setId,
      Value<int>? number,
      Value<String?>? categoryId,
      Value<String>? category,
      Value<String>? title,
      Value<String>? description,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return CustomQuestionsCompanion(
      id: id ?? this.id,
      setId: setId ?? this.setId,
      number: number ?? this.number,
      categoryId: categoryId ?? this.categoryId,
      category: category ?? this.category,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (setId.present) {
      map['set_id'] = Variable<String>(setId.value);
    }
    if (number.present) {
      map['number'] = Variable<int>(number.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomQuestionsCompanion(')
          ..write('id: $id, ')
          ..write('setId: $setId, ')
          ..write('number: $number, ')
          ..write('categoryId: $categoryId, ')
          ..write('category: $category, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$LocalDatabase extends GeneratedDatabase {
  _$LocalDatabase(QueryExecutor e) : super(e);
  $LocalDatabaseManager get managers => $LocalDatabaseManager(this);
  late final $QuestionSetsTable questionSets = $QuestionSetsTable(this);
  late final $DiaryDaysTable diaryDays = $DiaryDaysTable(this);
  late final $DiaryResponsesTable diaryResponses = $DiaryResponsesTable(this);
  late final $QuestionCategoriesTable questionCategories =
      $QuestionCategoriesTable(this);
  late final $CustomQuestionsTable customQuestions =
      $CustomQuestionsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        questionSets,
        diaryDays,
        diaryResponses,
        questionCategories,
        customQuestions
      ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('question_sets',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('diary_days', kind: UpdateKind.update),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('diary_days',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('diary_responses', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('question_sets',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('custom_questions', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('question_categories',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('custom_questions', kind: UpdateKind.update),
            ],
          ),
        ],
      );
}

typedef $$QuestionSetsTableCreateCompanionBuilder = QuestionSetsCompanion
    Function({
  required String id,
  required String name,
  Value<bool> isActive,
  Value<String> selectedPeriods,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$QuestionSetsTableUpdateCompanionBuilder = QuestionSetsCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<bool> isActive,
  Value<String> selectedPeriods,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$QuestionSetsTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $QuestionSetsTable,
    QuestionSet,
    $$QuestionSetsTableFilterComposer,
    $$QuestionSetsTableOrderingComposer,
    $$QuestionSetsTableCreateCompanionBuilder,
    $$QuestionSetsTableUpdateCompanionBuilder> {
  $$QuestionSetsTableTableManager(_$LocalDatabase db, $QuestionSetsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$QuestionSetsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$QuestionSetsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<String> selectedPeriods = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              QuestionSetsCompanion(
            id: id,
            name: name,
            isActive: isActive,
            selectedPeriods: selectedPeriods,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<bool> isActive = const Value.absent(),
            Value<String> selectedPeriods = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              QuestionSetsCompanion.insert(
            id: id,
            name: name,
            isActive: isActive,
            selectedPeriods: selectedPeriods,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
        ));
}

class $$QuestionSetsTableFilterComposer
    extends FilterComposer<_$LocalDatabase, $QuestionSetsTable> {
  $$QuestionSetsTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isActive => $state.composableBuilder(
      column: $state.table.isActive,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get selectedPeriods => $state.composableBuilder(
      column: $state.table.selectedPeriods,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ComposableFilter diaryDaysRefs(
      ComposableFilter Function($$DiaryDaysTableFilterComposer f) f) {
    final $$DiaryDaysTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.diaryDays,
        getReferencedColumn: (t) => t.questionSetId,
        builder: (joinBuilder, parentComposers) =>
            $$DiaryDaysTableFilterComposer(ComposerState(
                $state.db, $state.db.diaryDays, joinBuilder, parentComposers)));
    return f(composer);
  }

  ComposableFilter customQuestionsRefs(
      ComposableFilter Function($$CustomQuestionsTableFilterComposer f) f) {
    final $$CustomQuestionsTableFilterComposer composer =
        $state.composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $state.db.customQuestions,
            getReferencedColumn: (t) => t.setId,
            builder: (joinBuilder, parentComposers) =>
                $$CustomQuestionsTableFilterComposer(ComposerState($state.db,
                    $state.db.customQuestions, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$QuestionSetsTableOrderingComposer
    extends OrderingComposer<_$LocalDatabase, $QuestionSetsTable> {
  $$QuestionSetsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isActive => $state.composableBuilder(
      column: $state.table.isActive,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get selectedPeriods => $state.composableBuilder(
      column: $state.table.selectedPeriods,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$DiaryDaysTableCreateCompanionBuilder = DiaryDaysCompanion Function({
  required String id,
  required String date,
  required String status,
  required double totalScore,
  required double meanScore,
  required double medianScore,
  required String level,
  Value<String?> insightText,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> syncedAt,
  Value<String?> questionSetId,
  Value<int> rowid,
});
typedef $$DiaryDaysTableUpdateCompanionBuilder = DiaryDaysCompanion Function({
  Value<String> id,
  Value<String> date,
  Value<String> status,
  Value<double> totalScore,
  Value<double> meanScore,
  Value<double> medianScore,
  Value<String> level,
  Value<String?> insightText,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> syncedAt,
  Value<String?> questionSetId,
  Value<int> rowid,
});

class $$DiaryDaysTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $DiaryDaysTable,
    DiaryDay,
    $$DiaryDaysTableFilterComposer,
    $$DiaryDaysTableOrderingComposer,
    $$DiaryDaysTableCreateCompanionBuilder,
    $$DiaryDaysTableUpdateCompanionBuilder> {
  $$DiaryDaysTableTableManager(_$LocalDatabase db, $DiaryDaysTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$DiaryDaysTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$DiaryDaysTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> date = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<double> totalScore = const Value.absent(),
            Value<double> meanScore = const Value.absent(),
            Value<double> medianScore = const Value.absent(),
            Value<String> level = const Value.absent(),
            Value<String?> insightText = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> syncedAt = const Value.absent(),
            Value<String?> questionSetId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DiaryDaysCompanion(
            id: id,
            date: date,
            status: status,
            totalScore: totalScore,
            meanScore: meanScore,
            medianScore: medianScore,
            level: level,
            insightText: insightText,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncedAt: syncedAt,
            questionSetId: questionSetId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String date,
            required String status,
            required double totalScore,
            required double meanScore,
            required double medianScore,
            required String level,
            Value<String?> insightText = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<DateTime?> syncedAt = const Value.absent(),
            Value<String?> questionSetId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DiaryDaysCompanion.insert(
            id: id,
            date: date,
            status: status,
            totalScore: totalScore,
            meanScore: meanScore,
            medianScore: medianScore,
            level: level,
            insightText: insightText,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncedAt: syncedAt,
            questionSetId: questionSetId,
            rowid: rowid,
          ),
        ));
}

class $$DiaryDaysTableFilterComposer
    extends FilterComposer<_$LocalDatabase, $DiaryDaysTable> {
  $$DiaryDaysTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get date => $state.composableBuilder(
      column: $state.table.date,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get status => $state.composableBuilder(
      column: $state.table.status,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get totalScore => $state.composableBuilder(
      column: $state.table.totalScore,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get meanScore => $state.composableBuilder(
      column: $state.table.meanScore,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get medianScore => $state.composableBuilder(
      column: $state.table.medianScore,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get level => $state.composableBuilder(
      column: $state.table.level,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get insightText => $state.composableBuilder(
      column: $state.table.insightText,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get syncedAt => $state.composableBuilder(
      column: $state.table.syncedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  $$QuestionSetsTableFilterComposer get questionSetId {
    final $$QuestionSetsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.questionSetId,
        referencedTable: $state.db.questionSets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$QuestionSetsTableFilterComposer(ComposerState($state.db,
                $state.db.questionSets, joinBuilder, parentComposers)));
    return composer;
  }

  ComposableFilter diaryResponsesRefs(
      ComposableFilter Function($$DiaryResponsesTableFilterComposer f) f) {
    final $$DiaryResponsesTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.diaryResponses,
        getReferencedColumn: (t) => t.diaryDayId,
        builder: (joinBuilder, parentComposers) =>
            $$DiaryResponsesTableFilterComposer(ComposerState($state.db,
                $state.db.diaryResponses, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$DiaryDaysTableOrderingComposer
    extends OrderingComposer<_$LocalDatabase, $DiaryDaysTable> {
  $$DiaryDaysTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get date => $state.composableBuilder(
      column: $state.table.date,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get status => $state.composableBuilder(
      column: $state.table.status,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get totalScore => $state.composableBuilder(
      column: $state.table.totalScore,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get meanScore => $state.composableBuilder(
      column: $state.table.meanScore,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get medianScore => $state.composableBuilder(
      column: $state.table.medianScore,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get level => $state.composableBuilder(
      column: $state.table.level,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get insightText => $state.composableBuilder(
      column: $state.table.insightText,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get syncedAt => $state.composableBuilder(
      column: $state.table.syncedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$QuestionSetsTableOrderingComposer get questionSetId {
    final $$QuestionSetsTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.questionSetId,
        referencedTable: $state.db.questionSets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$QuestionSetsTableOrderingComposer(ComposerState($state.db,
                $state.db.questionSets, joinBuilder, parentComposers)));
    return composer;
  }
}

typedef $$DiaryResponsesTableCreateCompanionBuilder = DiaryResponsesCompanion
    Function({
  required String id,
  required String diaryDayId,
  required int questionNumber,
  required String nuitValues,
  required String matinValues,
  required String journeeValues,
  required String soirValues,
  Value<String> nuitComment,
  Value<String> matinComment,
  Value<String> journeeComment,
  Value<String> soirComment,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$DiaryResponsesTableUpdateCompanionBuilder = DiaryResponsesCompanion
    Function({
  Value<String> id,
  Value<String> diaryDayId,
  Value<int> questionNumber,
  Value<String> nuitValues,
  Value<String> matinValues,
  Value<String> journeeValues,
  Value<String> soirValues,
  Value<String> nuitComment,
  Value<String> matinComment,
  Value<String> journeeComment,
  Value<String> soirComment,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$DiaryResponsesTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $DiaryResponsesTable,
    DiaryResponse,
    $$DiaryResponsesTableFilterComposer,
    $$DiaryResponsesTableOrderingComposer,
    $$DiaryResponsesTableCreateCompanionBuilder,
    $$DiaryResponsesTableUpdateCompanionBuilder> {
  $$DiaryResponsesTableTableManager(
      _$LocalDatabase db, $DiaryResponsesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$DiaryResponsesTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$DiaryResponsesTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> diaryDayId = const Value.absent(),
            Value<int> questionNumber = const Value.absent(),
            Value<String> nuitValues = const Value.absent(),
            Value<String> matinValues = const Value.absent(),
            Value<String> journeeValues = const Value.absent(),
            Value<String> soirValues = const Value.absent(),
            Value<String> nuitComment = const Value.absent(),
            Value<String> matinComment = const Value.absent(),
            Value<String> journeeComment = const Value.absent(),
            Value<String> soirComment = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DiaryResponsesCompanion(
            id: id,
            diaryDayId: diaryDayId,
            questionNumber: questionNumber,
            nuitValues: nuitValues,
            matinValues: matinValues,
            journeeValues: journeeValues,
            soirValues: soirValues,
            nuitComment: nuitComment,
            matinComment: matinComment,
            journeeComment: journeeComment,
            soirComment: soirComment,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String diaryDayId,
            required int questionNumber,
            required String nuitValues,
            required String matinValues,
            required String journeeValues,
            required String soirValues,
            Value<String> nuitComment = const Value.absent(),
            Value<String> matinComment = const Value.absent(),
            Value<String> journeeComment = const Value.absent(),
            Value<String> soirComment = const Value.absent(),
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              DiaryResponsesCompanion.insert(
            id: id,
            diaryDayId: diaryDayId,
            questionNumber: questionNumber,
            nuitValues: nuitValues,
            matinValues: matinValues,
            journeeValues: journeeValues,
            soirValues: soirValues,
            nuitComment: nuitComment,
            matinComment: matinComment,
            journeeComment: journeeComment,
            soirComment: soirComment,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
        ));
}

class $$DiaryResponsesTableFilterComposer
    extends FilterComposer<_$LocalDatabase, $DiaryResponsesTable> {
  $$DiaryResponsesTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get questionNumber => $state.composableBuilder(
      column: $state.table.questionNumber,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get nuitValues => $state.composableBuilder(
      column: $state.table.nuitValues,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get matinValues => $state.composableBuilder(
      column: $state.table.matinValues,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get journeeValues => $state.composableBuilder(
      column: $state.table.journeeValues,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get soirValues => $state.composableBuilder(
      column: $state.table.soirValues,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get nuitComment => $state.composableBuilder(
      column: $state.table.nuitComment,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get matinComment => $state.composableBuilder(
      column: $state.table.matinComment,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get journeeComment => $state.composableBuilder(
      column: $state.table.journeeComment,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get soirComment => $state.composableBuilder(
      column: $state.table.soirComment,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  $$DiaryDaysTableFilterComposer get diaryDayId {
    final $$DiaryDaysTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.diaryDayId,
        referencedTable: $state.db.diaryDays,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$DiaryDaysTableFilterComposer(ComposerState(
                $state.db, $state.db.diaryDays, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$DiaryResponsesTableOrderingComposer
    extends OrderingComposer<_$LocalDatabase, $DiaryResponsesTable> {
  $$DiaryResponsesTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get questionNumber => $state.composableBuilder(
      column: $state.table.questionNumber,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get nuitValues => $state.composableBuilder(
      column: $state.table.nuitValues,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get matinValues => $state.composableBuilder(
      column: $state.table.matinValues,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get journeeValues => $state.composableBuilder(
      column: $state.table.journeeValues,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get soirValues => $state.composableBuilder(
      column: $state.table.soirValues,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get nuitComment => $state.composableBuilder(
      column: $state.table.nuitComment,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get matinComment => $state.composableBuilder(
      column: $state.table.matinComment,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get journeeComment => $state.composableBuilder(
      column: $state.table.journeeComment,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get soirComment => $state.composableBuilder(
      column: $state.table.soirComment,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$DiaryDaysTableOrderingComposer get diaryDayId {
    final $$DiaryDaysTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.diaryDayId,
        referencedTable: $state.db.diaryDays,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$DiaryDaysTableOrderingComposer(ComposerState(
                $state.db, $state.db.diaryDays, joinBuilder, parentComposers)));
    return composer;
  }
}

typedef $$QuestionCategoriesTableCreateCompanionBuilder
    = QuestionCategoriesCompanion Function({
  required String id,
  required String name,
  Value<String> color,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$QuestionCategoriesTableUpdateCompanionBuilder
    = QuestionCategoriesCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> color,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$QuestionCategoriesTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $QuestionCategoriesTable,
    QuestionCategory,
    $$QuestionCategoriesTableFilterComposer,
    $$QuestionCategoriesTableOrderingComposer,
    $$QuestionCategoriesTableCreateCompanionBuilder,
    $$QuestionCategoriesTableUpdateCompanionBuilder> {
  $$QuestionCategoriesTableTableManager(
      _$LocalDatabase db, $QuestionCategoriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$QuestionCategoriesTableFilterComposer(ComposerState(db, table)),
          orderingComposer: $$QuestionCategoriesTableOrderingComposer(
              ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> color = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              QuestionCategoriesCompanion(
            id: id,
            name: name,
            color: color,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String> color = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              QuestionCategoriesCompanion.insert(
            id: id,
            name: name,
            color: color,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
        ));
}

class $$QuestionCategoriesTableFilterComposer
    extends FilterComposer<_$LocalDatabase, $QuestionCategoriesTable> {
  $$QuestionCategoriesTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get color => $state.composableBuilder(
      column: $state.table.color,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ComposableFilter customQuestionsRefs(
      ComposableFilter Function($$CustomQuestionsTableFilterComposer f) f) {
    final $$CustomQuestionsTableFilterComposer composer =
        $state.composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $state.db.customQuestions,
            getReferencedColumn: (t) => t.categoryId,
            builder: (joinBuilder, parentComposers) =>
                $$CustomQuestionsTableFilterComposer(ComposerState($state.db,
                    $state.db.customQuestions, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$QuestionCategoriesTableOrderingComposer
    extends OrderingComposer<_$LocalDatabase, $QuestionCategoriesTable> {
  $$QuestionCategoriesTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get color => $state.composableBuilder(
      column: $state.table.color,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$CustomQuestionsTableCreateCompanionBuilder = CustomQuestionsCompanion
    Function({
  required String id,
  required String setId,
  required int number,
  Value<String?> categoryId,
  Value<String> category,
  required String title,
  required String description,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$CustomQuestionsTableUpdateCompanionBuilder = CustomQuestionsCompanion
    Function({
  Value<String> id,
  Value<String> setId,
  Value<int> number,
  Value<String?> categoryId,
  Value<String> category,
  Value<String> title,
  Value<String> description,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$CustomQuestionsTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $CustomQuestionsTable,
    CustomQuestion,
    $$CustomQuestionsTableFilterComposer,
    $$CustomQuestionsTableOrderingComposer,
    $$CustomQuestionsTableCreateCompanionBuilder,
    $$CustomQuestionsTableUpdateCompanionBuilder> {
  $$CustomQuestionsTableTableManager(
      _$LocalDatabase db, $CustomQuestionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$CustomQuestionsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$CustomQuestionsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> setId = const Value.absent(),
            Value<int> number = const Value.absent(),
            Value<String?> categoryId = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CustomQuestionsCompanion(
            id: id,
            setId: setId,
            number: number,
            categoryId: categoryId,
            category: category,
            title: title,
            description: description,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String setId,
            required int number,
            Value<String?> categoryId = const Value.absent(),
            Value<String> category = const Value.absent(),
            required String title,
            required String description,
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              CustomQuestionsCompanion.insert(
            id: id,
            setId: setId,
            number: number,
            categoryId: categoryId,
            category: category,
            title: title,
            description: description,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
        ));
}

class $$CustomQuestionsTableFilterComposer
    extends FilterComposer<_$LocalDatabase, $CustomQuestionsTable> {
  $$CustomQuestionsTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get number => $state.composableBuilder(
      column: $state.table.number,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get category => $state.composableBuilder(
      column: $state.table.category,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get title => $state.composableBuilder(
      column: $state.table.title,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get description => $state.composableBuilder(
      column: $state.table.description,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  $$QuestionSetsTableFilterComposer get setId {
    final $$QuestionSetsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.setId,
        referencedTable: $state.db.questionSets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$QuestionSetsTableFilterComposer(ComposerState($state.db,
                $state.db.questionSets, joinBuilder, parentComposers)));
    return composer;
  }

  $$QuestionCategoriesTableFilterComposer get categoryId {
    final $$QuestionCategoriesTableFilterComposer composer = $state
        .composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.categoryId,
            referencedTable: $state.db.questionCategories,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder, parentComposers) =>
                $$QuestionCategoriesTableFilterComposer(ComposerState(
                    $state.db,
                    $state.db.questionCategories,
                    joinBuilder,
                    parentComposers)));
    return composer;
  }
}

class $$CustomQuestionsTableOrderingComposer
    extends OrderingComposer<_$LocalDatabase, $CustomQuestionsTable> {
  $$CustomQuestionsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get number => $state.composableBuilder(
      column: $state.table.number,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get category => $state.composableBuilder(
      column: $state.table.category,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get title => $state.composableBuilder(
      column: $state.table.title,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get description => $state.composableBuilder(
      column: $state.table.description,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$QuestionSetsTableOrderingComposer get setId {
    final $$QuestionSetsTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.setId,
        referencedTable: $state.db.questionSets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$QuestionSetsTableOrderingComposer(ComposerState($state.db,
                $state.db.questionSets, joinBuilder, parentComposers)));
    return composer;
  }

  $$QuestionCategoriesTableOrderingComposer get categoryId {
    final $$QuestionCategoriesTableOrderingComposer composer =
        $state.composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.categoryId,
            referencedTable: $state.db.questionCategories,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder, parentComposers) =>
                $$QuestionCategoriesTableOrderingComposer(ComposerState(
                    $state.db,
                    $state.db.questionCategories,
                    joinBuilder,
                    parentComposers)));
    return composer;
  }
}

class $LocalDatabaseManager {
  final _$LocalDatabase _db;
  $LocalDatabaseManager(this._db);
  $$QuestionSetsTableTableManager get questionSets =>
      $$QuestionSetsTableTableManager(_db, _db.questionSets);
  $$DiaryDaysTableTableManager get diaryDays =>
      $$DiaryDaysTableTableManager(_db, _db.diaryDays);
  $$DiaryResponsesTableTableManager get diaryResponses =>
      $$DiaryResponsesTableTableManager(_db, _db.diaryResponses);
  $$QuestionCategoriesTableTableManager get questionCategories =>
      $$QuestionCategoriesTableTableManager(_db, _db.questionCategories);
  $$CustomQuestionsTableTableManager get customQuestions =>
      $$CustomQuestionsTableTableManager(_db, _db.customQuestions);
}

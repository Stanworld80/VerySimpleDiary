// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_database.dart';

// ignore_for_file: type=lint
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
        syncedAt
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
      this.syncedAt});
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
          Value<DateTime?> syncedAt = const Value.absent()}) =>
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
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, date, status, totalScore, meanScore,
      medianScore, level, insightText, createdAt, updatedAt, syncedAt);
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
          other.syncedAt == this.syncedAt);
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

abstract class _$LocalDatabase extends GeneratedDatabase {
  _$LocalDatabase(QueryExecutor e) : super(e);
  $LocalDatabaseManager get managers => $LocalDatabaseManager(this);
  late final $DiaryDaysTable diaryDays = $DiaryDaysTable(this);
  late final $DiaryResponsesTable diaryResponses = $DiaryResponsesTable(this);
  late final Index diaryResponsesDiaryDayIdIdx = Index(
      'diary_responses_diary_day_id_idx',
      'CREATE INDEX diary_responses_diary_day_id_idx ON diary_responses (diary_day_id)');
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [diaryDays, diaryResponses, diaryResponsesDiaryDayIdIdx];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('diary_days',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('diary_responses', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
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

class $LocalDatabaseManager {
  final _$LocalDatabase _db;
  $LocalDatabaseManager(this._db);
  $$DiaryDaysTableTableManager get diaryDays =>
      $$DiaryDaysTableTableManager(_db, _db.diaryDays);
  $$DiaryResponsesTableTableManager get diaryResponses =>
      $$DiaryResponsesTableTableManager(_db, _db.diaryResponses);
}

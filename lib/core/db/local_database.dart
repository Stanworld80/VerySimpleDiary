import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'local_database.g.dart';

@DataClassName('DiaryDay')
class DiaryDays extends Table {
  TextColumn get id => text()();
  TextColumn get date => text().unique()();
  TextColumn get status => text()(); // 'draft' or 'finalized'
  RealColumn get totalScore => real()();
  RealColumn get meanScore => real()();
  RealColumn get medianScore => real()();
  TextColumn get level => text()();
  TextColumn get insightText => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('DiaryResponse')
class DiaryResponses extends Table {
  TextColumn get id => text()();
  TextColumn get diaryDayId => text().references(DiaryDays, #id, onDelete: KeyAction.cascade)();
  IntColumn get questionNumber => integer()();
  TextColumn get nuitValues => text()(); // Stored as comma-separated or JSON list
  TextColumn get matinValues => text()();
  TextColumn get journeeValues => text()();
  TextColumn get soirValues => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [DiaryDays, DiaryResponses])
class LocalDatabase extends _$LocalDatabase {
  LocalDatabase() : super(_openConnection());

  LocalDatabase.forTesting(super.connection);

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'diary.db'));
    return NativeDatabase.createInBackground(file);
  });
}

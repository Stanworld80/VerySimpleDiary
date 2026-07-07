import 'package:drift/drift.dart';
import 'connection/connection.dart' as conn;

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
// ⚡ Bolt Optimization: Added index on foreign key to prevent full table scans
// Expected Impact: Improves read/delete performance when querying by diaryDayId.
@TableIndex(name: 'diary_responses_diary_day_id_idx', columns: {#diaryDayId})
class DiaryResponses extends Table {
  TextColumn get id => text()();
  TextColumn get diaryDayId => text().references(DiaryDays, #id, onDelete: KeyAction.cascade)();
  IntColumn get questionNumber => integer()();
  TextColumn get nuitValues => text()(); // Stored as comma-separated or JSON list
  TextColumn get matinValues => text()();
  TextColumn get journeeValues => text()();
  TextColumn get soirValues => text()();
  TextColumn get nuitComment => text().withDefault(const Constant(''))();
  TextColumn get matinComment => text().withDefault(const Constant(''))();
  TextColumn get journeeComment => text().withDefault(const Constant(''))();
  TextColumn get soirComment => text().withDefault(const Constant(''))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [DiaryDays, DiaryResponses])
class LocalDatabase extends _$LocalDatabase {
  LocalDatabase() : super(conn.openConnection());

  LocalDatabase.forTesting(super.connection);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (migrator, from, to) async {
          if (from < 2) {
            await migrator.addColumn(diaryResponses, diaryResponses.nuitComment);
            await migrator.addColumn(diaryResponses, diaryResponses.matinComment);
            await migrator.addColumn(diaryResponses, diaryResponses.journeeComment);
            await migrator.addColumn(diaryResponses, diaryResponses.soirComment);
          }
          if (from < 3) {
            await migrator.createIndex(diaryResponsesDiaryDayIdIdx);
          }
        },
      );
}

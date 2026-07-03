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
  TextColumn get questionSetId => text().nullable().references(QuestionSets, #id, onDelete: KeyAction.setNull)();

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
  TextColumn get nuitComment => text().withDefault(const Constant(''))();
  TextColumn get matinComment => text().withDefault(const Constant(''))();
  TextColumn get journeeComment => text().withDefault(const Constant(''))();
  TextColumn get soirComment => text().withDefault(const Constant(''))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('QuestionSet')
class QuestionSets extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  BoolColumn get isActive => boolean().withDefault(const Constant(false))();
  TextColumn get selectedPeriods => text().withDefault(const Constant('nuit,matin,journee,soir'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('QuestionCategory')
class QuestionCategories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get color => text().withDefault(const Constant('#6C63FF'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('CustomQuestion')
class CustomQuestions extends Table {
  TextColumn get id => text()();
  TextColumn get setId => text().references(QuestionSets, #id, onDelete: KeyAction.cascade)();
  IntColumn get number => integer()();
  // categoryId references QuestionCategories; nullable for backward-compat with migration
  TextColumn get categoryId => text().nullable().references(QuestionCategories, #id, onDelete: KeyAction.setNull)();
  // Legacy text field kept for display fallback (set to category name for old data)
  TextColumn get category => text().withDefault(const Constant(''))();
  TextColumn get title => text()();
  TextColumn get description => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [DiaryDays, DiaryResponses, QuestionSets, QuestionCategories, CustomQuestions])
class LocalDatabase extends _$LocalDatabase {
  LocalDatabase() : super(conn.openConnection());

  LocalDatabase.forTesting(super.connection);

  @override
  int get schemaVersion => 4;

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
            await migrator.createTable(questionSets);
            await migrator.createTable(customQuestions);
            await migrator.addColumn(diaryDays, diaryDays.questionSetId);
          }
          if (from < 4) {
            // Create the new QuestionCategories table
            await migrator.createTable(questionCategories);
            // Add categoryId column to CustomQuestions (nullable FK)
            await migrator.addColumn(customQuestions, customQuestions.categoryId);
          }
        },
      );
}

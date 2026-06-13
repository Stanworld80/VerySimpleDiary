import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import '../../../core/db/local_database.dart';

class DiaryRepository {
  final LocalDatabase _db;

  DiaryRepository(this._db);

  // Watch a diary day by date
  Stream<DiaryDay?> watchDiaryDay(String date) {
    return (_db.select(_db.diaryDays)..where((tbl) => tbl.date.equals(date)))
        .watchSingleOrNull();
  }

  // Watch responses for a diary day
  Stream<List<DiaryResponse>> watchResponses(String diaryDayId) {
    return (_db.select(_db.diaryResponses)..where((tbl) => tbl.diaryDayId.equals(diaryDayId)))
        .watch();
  }

  // Get or Create draft day
  Future<DiaryDay> getOrCreateDiaryDay(String date) async {
    final existing = await (_db.select(_db.diaryDays)..where((tbl) => tbl.date.equals(date)))
        .getSingleOrNull();
        
    if (existing != null) {
      return existing;
    }

    final newId = DateTime.now().millisecondsSinceEpoch.toString(); // Unique local ID
    final newDay = DiaryDaysCompanion.insert(
      id: newId,
      date: date,
      status: 'draft',
      totalScore: 0.0,
      meanScore: 0.0,
      medianScore: 0.0,
      level: 'Moyen',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _db.into(_db.diaryDays).insert(newDay);
    return await (_db.select(_db.diaryDays)..where((tbl) => tbl.date.equals(date))).getSingle();
  }

  // Save response draft
  Future<void> saveResponseDraft({
    required String diaryDayId,
    required int questionNumber,
    required List<int> nuit,
    required List<int> matin,
    required List<int> journee,
    required List<int> soir,
  }) async {
    final existing = await (_db.select(_db.diaryResponses)
      ..where((tbl) => tbl.diaryDayId.equals(diaryDayId) & tbl.questionNumber.equals(questionNumber)))
      .getSingleOrNull();

    final id = existing?.id ?? '${diaryDayId}_$questionNumber';
    final companion = DiaryResponsesCompanion(
      id: Value(id),
      diaryDayId: Value(diaryDayId),
      questionNumber: Value(questionNumber),
      nuitValues: Value(nuit.join(',')),
      matinValues: Value(matin.join(',')),
      journeeValues: Value(journee.join(',')),
      soirValues: Value(soir.join(',')),
      updatedAt: Value(DateTime.now()),
    );

    await _db.into(_db.diaryResponses).insertOnConflictUpdate(companion);
  }

  // Update diary day scores and status
  Future<void> updateDiaryDay({
    required String id,
    required String status,
    required double total,
    required double mean,
    required double median,
    required String level,
    String? insight,
  }) async {
    final companion = DiaryDaysCompanion(
      status: Value(status),
      totalScore: Value(total),
      meanScore: Value(mean),
      medianScore: Value(median),
      level: Value(level),
      insightText: Value(insight),
      updatedAt: Value(DateTime.now()),
    );
    await (_db.update(_db.diaryDays)..where((tbl) => tbl.id.equals(id))).write(companion);
  }
}

final databaseProvider = Provider<LocalDatabase>((ref) {
  final db = LocalDatabase();
  ref.onDispose(() => db.close());
  return db;
});

final diaryRepositoryProvider = Provider<DiaryRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return DiaryRepository(db);
});

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/db/local_database.dart';
import '../controller/diary_controller.dart'; // To reference DiaryQuestion and diaryQuestionsList
import 'diary_repository.dart';
import 'category_repository.dart';

class QuestionSetRepository {
  final LocalDatabase _db;

  QuestionSetRepository(this._db);

  // Watch all question sets
  Stream<List<QuestionSet>> watchAllQuestionSets() {
    return (_db.select(_db.questionSets)
          ..orderBy([
            (tbl) => OrderingTerm(expression: tbl.createdAt, mode: OrderingMode.desc)
          ]))
        .watch();
  }

  // Get question set by ID
  Future<QuestionSet?> getQuestionSetById(String id) async {
    return await (_db.select(_db.questionSets)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  // Get active question set
  Future<QuestionSet?> getActiveQuestionSet() async {
    return await (_db.select(_db.questionSets)
          ..where((tbl) => tbl.isActive.equals(true))
          ..limit(1))
        .getSingleOrNull();
  }

  // Watch active question set
  Stream<QuestionSet?> watchActiveQuestionSet() {
    return (_db.select(_db.questionSets)
          ..where((tbl) => tbl.isActive.equals(true))
          ..limit(1))
        .watchSingleOrNull();
  }

  // Watch questions for a specific set
  Stream<List<CustomQuestion>> watchQuestionsForSet(String setId) {
    return (_db.select(_db.customQuestions)
          ..where((tbl) => tbl.setId.equals(setId))
          ..orderBy([
            (tbl) => OrderingTerm(expression: tbl.number, mode: OrderingMode.asc)
          ]))
        .watch();
  }

  // Get questions for a specific set
  Future<List<CustomQuestion>> getQuestionsForSet(String setId) async {
    return await (_db.select(_db.customQuestions)
          ..where((tbl) => tbl.setId.equals(setId))
          ..orderBy([
            (tbl) => OrderingTerm(expression: tbl.number, mode: OrderingMode.asc)
          ]))
        .get();
  }

  // Insert or update a question set
  Future<void> saveQuestionSet(QuestionSet set) async {
    final companion = QuestionSetsCompanion(
      id: Value(set.id),
      name: Value(set.name),
      isActive: Value(set.isActive),
      selectedPeriods: Value(set.selectedPeriods),
      createdAt: Value(set.createdAt),
      updatedAt: Value(DateTime.now()),
    );
    await _db.into(_db.questionSets).insertOnConflictUpdate(companion);
  }

  // Create a new custom set
  Future<String> createQuestionSet(String name, List<String> periods) async {
    final newId = DateTime.now().millisecondsSinceEpoch.toString();
    final companion = QuestionSetsCompanion.insert(
      id: newId,
      name: name,
      isActive: const Value(false),
      selectedPeriods: Value(periods.join(',')),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _db.into(_db.questionSets).insert(companion);
    return newId;
  }

  // Set active set and deactivate others
  Future<void> setActiveQuestionSet(String setId) async {
    await _db.transaction(() async {
      // Deactivate all
      await (_db.update(_db.questionSets)
            ..where((tbl) => tbl.isActive.equals(true)))
          .write(const QuestionSetsCompanion(isActive: Value(false)));

      // Activate selected
      await (_db.update(_db.questionSets)
            ..where((tbl) => tbl.id.equals(setId)))
          .write(const QuestionSetsCompanion(isActive: Value(true)));
    });
  }

  // Delete question set
  Future<void> deleteQuestionSet(String setId) async {
    await (_db.delete(_db.questionSets)..where((tbl) => tbl.id.equals(setId))).go();
  }

  // Save custom question
  Future<void> saveCustomQuestion(CustomQuestion question) async {
    final companion = CustomQuestionsCompanion(
      id: Value(question.id),
      setId: Value(question.setId),
      number: Value(question.number),
      categoryId: Value(question.categoryId),
      category: Value(question.category),
      title: Value(question.title),
      description: Value(question.description),
      createdAt: Value(question.createdAt),
      updatedAt: Value(DateTime.now()),
    );
    await _db.into(_db.customQuestions).insertOnConflictUpdate(companion);
  }


  // Add question to set
  Future<void> addQuestionToSet({
    required String setId,
    String? categoryId,
    String category = '',
    required String title,
    required String description,
  }) async {
    final existing = await getQuestionsForSet(setId);
    final nextNum = existing.isEmpty ? 1 : existing.length + 1;
    final newId = '${setId}_q_${DateTime.now().millisecondsSinceEpoch}';

    final companion = CustomQuestionsCompanion.insert(
      id: newId,
      setId: setId,
      number: nextNum,
      categoryId: Value(categoryId),
      category: Value(category),
      title: title,
      description: description,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _db.into(_db.customQuestions).insert(companion);
  }

  // Remove question from set and re-number others
  Future<void> removeQuestionFromSet(String questionId) async {
    final question = await (_db.select(_db.customQuestions)
          ..where((tbl) => tbl.id.equals(questionId)))
        .getSingleOrNull();

    if (question == null) return;

    await _db.transaction(() async {
      await (_db.delete(_db.customQuestions)..where((tbl) => tbl.id.equals(questionId))).go();

      // Re-number remaining
      final remaining = await getQuestionsForSet(question.setId);
      for (int i = 0; i < remaining.length; i++) {
        final r = remaining[i];
        final companion = CustomQuestionsCompanion(
          number: Value(i + 1),
        );
        await (_db.update(_db.customQuestions)..where((tbl) => tbl.id.equals(r.id))).write(companion);
      }
    });
  }

  // Check if database needs seeding, and seed default set
  Future<void> seedDefaultSetIfEmpty() async {
    // Ensure categories exist first
    final catRepo = CategoryRepository(_db);
    await catRepo.seedDefaultCategoriesIfEmpty();

    final countExp = _db.questionSets.id.count();
    final query = _db.selectOnly(_db.questionSets)..addColumns([countExp]);
    final row = await query.getSingle();
    final count = row.read(countExp) ?? 0;

    if (count == 0) {
      // Build a map of category name -> id for linking questions
      final categories = await catRepo.getAllCategories();
      final categoryByName = {for (final c in categories) c.name: c.id};

      await _db.transaction(() async {
        const defaultSetId = 'default_system_set';

        // Insert default question set
        final setCompanion = QuestionSetsCompanion.insert(
          id: defaultSetId,
          name: 'Set par défaut',
          isActive: const Value(true),
          selectedPeriods: const Value('nuit,matin,journee,soir'),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _db.into(_db.questionSets).insert(setCompanion);

        // Insert default questions with FK categoryId
        for (final q in diaryQuestionsList) {
          final catId = categoryByName[q.category];
          final questionCompanion = CustomQuestionsCompanion.insert(
            id: '${defaultSetId}_q_${q.number}',
            setId: defaultSetId,
            number: q.number,
            categoryId: Value(catId),
            category: Value(q.category),
            title: q.title,
            description: q.description,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          await _db.into(_db.customQuestions).insert(questionCompanion);
        }
      });
    }
  }
}

final questionSetRepositoryProvider = Provider<QuestionSetRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return QuestionSetRepository(db);
});

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/db/local_database.dart';
import 'diary_repository.dart';

/// The 6 default categories matching the built-in question list.
const List<Map<String, String>> defaultCategories = [
  {'id': 'cat_sante', 'name': '1. Santé, Sport & Sommeil', 'color': '#4CAF50'},
  {'id': 'cat_alimentation', 'name': '2. Alimentation', 'color': '#FF9800'},
  {'id': 'cat_psychisme', 'name': '3. Psychisme', 'color': '#9C27B0'},
  {'id': 'cat_hygiene', 'name': '4. Hygiène & Ménage', 'color': '#2196F3'},
  {'id': 'cat_admin', 'name': '5. Admin & Finances', 'color': '#F44336'},
  {'id': 'cat_relations', 'name': '6. Relations & Famille', 'color': '#E91E63'},
];

class CategoryRepository {
  final LocalDatabase _db;

  CategoryRepository(this._db);

  // ---------------------------------------------------------------------------
  // Read operations
  // ---------------------------------------------------------------------------

  /// Watch all categories ordered by name.
  Stream<List<QuestionCategory>> watchAllCategories() {
    return (_db.select(_db.questionCategories)
          ..orderBy([(tbl) => OrderingTerm(expression: tbl.name)]))
        .watch();
  }

  /// Fetch all categories (one-shot).
  Future<List<QuestionCategory>> getAllCategories() async {
    return (_db.select(_db.questionCategories)
          ..orderBy([(tbl) => OrderingTerm(expression: tbl.name)]))
        .get();
  }

  /// Get a single category by id.
  Future<QuestionCategory?> getCategoryById(String id) async {
    return (_db.select(_db.questionCategories)
          ..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
  }

  /// Returns all questions (from any set) that are linked to this category.
  Future<List<CustomQuestion>> getQuestionsForCategory(String categoryId) async {
    return (_db.select(_db.customQuestions)
          ..where((tbl) => tbl.categoryId.equals(categoryId))
          ..orderBy([(tbl) => OrderingTerm(expression: tbl.title)]))
        .get();
  }

  // ---------------------------------------------------------------------------
  // Write operations
  // ---------------------------------------------------------------------------

  /// Creates a new category and returns its id.
  Future<String> createCategory(String name, {String color = '#6C63FF'}) async {
    final newId = 'cat_${DateTime.now().millisecondsSinceEpoch}';
    final companion = QuestionCategoriesCompanion.insert(
      id: newId,
      name: name,
      color: Value(color),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _db.into(_db.questionCategories).insert(companion);
    return newId;
  }

  /// Updates an existing category's name and/or color.
  Future<void> updateCategory(String id, {required String name, required String color}) async {
    await (_db.update(_db.questionCategories)..where((tbl) => tbl.id.equals(id)))
        .write(QuestionCategoriesCompanion(
      name: Value(name),
      color: Value(color),
      updatedAt: Value(DateTime.now()),
    ));
  }

  /// Deletes a category. Throws [CategoryHasQuestionsException] if questions are linked.
  Future<void> deleteCategory(String id) async {
    final linked = await getQuestionsForCategory(id);
    if (linked.isNotEmpty) {
      throw CategoryHasQuestionsException(linked);
    }
    await (_db.delete(_db.questionCategories)..where((tbl) => tbl.id.equals(id))).go();
  }

  // ---------------------------------------------------------------------------
  // Seed / Migration helpers
  // ---------------------------------------------------------------------------

  /// Seeds the 6 default categories if the table is empty, and migrates existing
  /// CustomQuestions that still have a text [category] field but no [categoryId].
  Future<void> seedDefaultCategoriesIfEmpty() async {
    final countExp = _db.questionCategories.id.count();
    final query = _db.selectOnly(_db.questionCategories)..addColumns([countExp]);
    final row = await query.getSingle();
    final count = row.read(countExp) ?? 0;

    if (count == 0) {
      // Insert default categories
      for (final cat in defaultCategories) {
        final companion = QuestionCategoriesCompanion.insert(
          id: cat['id']!,
          name: cat['name']!,
          color: Value(cat['color']!),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _db
            .into(_db.questionCategories)
            .insertOnConflictUpdate(companion);
      }
    }

    // Migrate existing questions that have category text but no categoryId
    await _migrateTextCategoriesToFk();
  }

  /// Matches old text `category` values to known category names and sets `categoryId`.
  Future<void> _migrateTextCategoriesToFk() async {
    final allCategories = await getAllCategories();
    if (allCategories.isEmpty) return;

    // Get questions without a categoryId but with a non-empty category text
    final unlinked = await (_db.select(_db.customQuestions)
          ..where((tbl) => tbl.categoryId.isNull()))
        .get();

    for (final q in unlinked) {
      if (q.category.isEmpty) continue;
      // Find matching category by name (case-insensitive contains)
      final match = allCategories.cast<QuestionCategory?>().firstWhere(
            (cat) => cat!.name.toLowerCase() == q.category.toLowerCase(),
            orElse: () => null,
          );
      if (match != null) {
        await (_db.update(_db.customQuestions)
              ..where((tbl) => tbl.id.equals(q.id)))
            .write(CustomQuestionsCompanion(
          categoryId: Value(match.id),
          updatedAt: Value(DateTime.now()),
        ));
      }
    }
  }
}

/// Thrown when trying to delete a category that still has questions linked to it.
class CategoryHasQuestionsException implements Exception {
  final List<CustomQuestion> linkedQuestions;
  CategoryHasQuestionsException(this.linkedQuestions);

  @override
  String toString() =>
      'CategoryHasQuestionsException: ${linkedQuestions.length} question(s) use this category.';
}

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return CategoryRepository(db);
});

final categoryListProvider = StreamProvider<List<QuestionCategory>>((ref) {
  return ref.watch(categoryRepositoryProvider).watchAllCategories();
});

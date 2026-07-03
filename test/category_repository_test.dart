import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:verysimplediary/core/db/local_database.dart';
import 'package:verysimplediary/features/diary/repository/category_repository.dart';

void main() {
  late LocalDatabase db;
  late CategoryRepository repo;

  setUp(() {
    db = LocalDatabase.forTesting(NativeDatabase.memory());
    repo = CategoryRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('CategoryRepository', () {
    test('seedDefaultCategoriesIfEmpty creates 6 default categories', () async {
      await repo.seedDefaultCategoriesIfEmpty();

      final cats = await repo.getAllCategories();
      expect(cats.length, 6);
    });

    test('seedDefaultCategoriesIfEmpty is idempotent', () async {
      await repo.seedDefaultCategoriesIfEmpty();
      await repo.seedDefaultCategoriesIfEmpty(); // Second call should not double-insert

      final cats = await repo.getAllCategories();
      expect(cats.length, 6);
    });

    test('createCategory adds a new category', () async {
      final id = await repo.createCategory('Ma catégorie', color: '#FF5722');

      final cat = await repo.getCategoryById(id);
      expect(cat, isNotNull);
      expect(cat!.name, 'Ma catégorie');
      expect(cat.color, '#FF5722');
    });

    test('updateCategory renames and recolors a category', () async {
      final id = await repo.createCategory('Ancienne', color: '#111111');

      await repo.updateCategory(id, name: 'Nouvelle', color: '#222222');

      final cat = await repo.getCategoryById(id);
      expect(cat!.name, 'Nouvelle');
      expect(cat.color, '#222222');
    });

    test('deleteCategory removes category when no questions linked', () async {
      final id = await repo.createCategory('Vide');

      await repo.deleteCategory(id);

      final cat = await repo.getCategoryById(id);
      expect(cat, isNull);
    });

    test('deleteCategory throws CategoryHasQuestionsException when questions are linked', () async {
      // Create a category
      final catId = await repo.createCategory('Occupée');

      // Create a question set and a question linked to that category
      await db.into(db.questionSets).insert(QuestionSetsCompanion.insert(
        id: 'set_test',
        name: 'Set test',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      await db.into(db.customQuestions).insert(CustomQuestionsCompanion.insert(
        id: 'q_test',
        setId: 'set_test',
        number: 1,
        categoryId: drift.Value(catId),
        category: const drift.Value('Occupée'),
        title: 'Test',
        description: 'Description',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      // Attempt to delete the category — should throw
      expect(
        () => repo.deleteCategory(catId),
        throwsA(isA<CategoryHasQuestionsException>()),
      );
    });

    test('getQuestionsForCategory returns correct questions', () async {
      final catId = await repo.createCategory('Test Cat');

      // Create question set
      await db.into(db.questionSets).insert(QuestionSetsCompanion.insert(
        id: 'set_1',
        name: 'Set 1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      // Create 2 questions in this category
      for (int i = 1; i <= 2; i++) {
        await db.into(db.customQuestions).insert(CustomQuestionsCompanion.insert(
          id: 'q_$i',
          setId: 'set_1',
          number: i,
          categoryId: drift.Value(catId),
          category: const drift.Value('Test Cat'),
          title: 'Q$i',
          description: 'Desc $i',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));
      }

      final questions = await repo.getQuestionsForCategory(catId);
      expect(questions.length, 2);
    });

    test('watchAllCategories stream emits initial empty list', () async {
      final cats = await repo.watchAllCategories().first;
      expect(cats, isEmpty);
    });
  });
}

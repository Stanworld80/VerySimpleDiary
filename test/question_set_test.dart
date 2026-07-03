import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:drift/native.dart';
import 'package:verysimplediary/core/db/local_database.dart';
import 'package:verysimplediary/core/config/settings_provider.dart';
import 'package:verysimplediary/features/diary/repository/diary_repository.dart';
import 'package:verysimplediary/features/diary/repository/question_set_repository.dart';
import 'package:verysimplediary/features/diary/controller/question_set_controller.dart';
import 'package:verysimplediary/features/diary/controller/diary_controller.dart';

void main() {
  late ProviderContainer container;
  late LocalDatabase db;
  late QuestionSetRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    
    db = LocalDatabase.forTesting(NativeDatabase.memory());
    repository = QuestionSetRepository(db);

    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        questionSetRepositoryProvider.overrideWithValue(repository),
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
    );
  });

  tearDown(() async {
    await db.close();
    container.dispose();
  });

  group('QuestionSetRepository & Controller Unit Tests', () {
    test('Default set is seeded if database is empty', () async {
      // Trigger initialization
      final notifier = container.read(questionSetControllerProvider.notifier);
      
      // Allow async streams to emit
      await Future.delayed(const Duration(milliseconds: 50));

      final state = container.read(questionSetControllerProvider);
      
      expect(state.questionSets.length, 1);
      expect(state.activeSet, isNotNull);
      expect(state.activeSet!.id, 'default_system_set');
      expect(state.activeSet!.name, 'Set par défaut');
      expect(state.activeSetQuestions.length, 24);
    });

    test('Mon Set Personnalise can be created', () async {
      final notifier = container.read(questionSetControllerProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 50));

      final newSetId = await notifier.createSet('Mon Set Personnalise', ['matin', 'soir']);
      
      // Wait for watch Stream to emit
      await Future.delayed(const Duration(milliseconds: 50));
      
      final state = container.read(questionSetControllerProvider);
      
      expect(state.questionSets.any((s) => s.id == newSetId), isTrue);
      final createdSet = state.questionSets.firstWhere((s) => s.id == newSetId);
      expect(createdSet.name, 'Mon Set Personnalise');
      expect(createdSet.selectedPeriods, 'matin,soir');
    });

    test('Can select a set as active', () async {
      final notifier = container.read(questionSetControllerProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 50));

      final newSetId = await notifier.createSet('Second Set', ['journee']);
      await Future.delayed(const Duration(milliseconds: 50));

      await notifier.selectActiveSet(newSetId);
      await Future.delayed(const Duration(milliseconds: 50));

      final state = container.read(questionSetControllerProvider);
      expect(state.activeSet!.id, newSetId);
      expect(state.activeSet!.selectedPeriods, 'journee');
    });

    test('Can duplicate an existing set with its questions', () async {
      final notifier = container.read(questionSetControllerProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 50));

      // Duplicate the default set
      await notifier.duplicateSet('default_system_set', 'Set Copie');
      await Future.delayed(const Duration(milliseconds: 50));

      final state = container.read(questionSetControllerProvider);
      expect(state.questionSets.length, 2);
      
      final duplicatedSet = state.questionSets.firstWhere((s) => s.name == 'Set Copie');
      expect(duplicatedSet.isActive, isFalse);

      final duplicatedQuestions = await repository.getQuestionsForSet(duplicatedSet.id);
      expect(duplicatedQuestions.length, 24);
      expect(duplicatedQuestions.first.title, state.activeSetQuestions.first.title);
    });

    test('Can rename a set', () async {
      final notifier = container.read(questionSetControllerProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 50));

      await notifier.renameSet('default_system_set', 'Set Renomme');
      await Future.delayed(const Duration(milliseconds: 50));

      final state = container.read(questionSetControllerProvider);
      expect(state.activeSet!.name, 'Set Renomme');
    });

    test('Can update set active periods', () async {
      final notifier = container.read(questionSetControllerProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 50));

      await notifier.updateSetPeriods('default_system_set', ['nuit', 'soir']);
      await Future.delayed(const Duration(milliseconds: 50));

      final state = container.read(questionSetControllerProvider);
      expect(state.activeSet!.selectedPeriods, 'nuit,soir');
    });

    test('Can add, edit, and remove a question', () async {
      final notifier = container.read(questionSetControllerProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 50));

      // Add a custom question
      await notifier.addQuestion('default_system_set', 'Humeur', 'Comment ca va ?', 'Description');
      await Future.delayed(const Duration(milliseconds: 50));

      var state = container.read(questionSetControllerProvider);
      expect(state.activeSetQuestions.length, 25);
      
      final addedQuestion = state.activeSetQuestions.last;
      expect(addedQuestion.title, 'Comment ca va ?');
      expect(addedQuestion.number, 25);

      // Edit the custom question
      final editedQuestion = addedQuestion.copyWith(title: 'Nouveau titre');
      await notifier.editQuestion(editedQuestion);
      await Future.delayed(const Duration(milliseconds: 50));

      state = container.read(questionSetControllerProvider);
      expect(state.activeSetQuestions.last.title, 'Nouveau titre');

      // Remove the custom question
      await notifier.removeQuestion(addedQuestion.id);
      await Future.delayed(const Duration(milliseconds: 50));

      state = container.read(questionSetControllerProvider);
      expect(state.activeSetQuestions.length, 24);
    });

    test('Deleting an active set triggers fallback set selection', () async {
      final notifier = container.read(questionSetControllerProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 50));

      // Create a second set and make it active
      final secondSetId = await notifier.createSet('Second', ['nuit']);
      await Future.delayed(const Duration(milliseconds: 50));
      await notifier.selectActiveSet(secondSetId);
      await Future.delayed(const Duration(milliseconds: 50));

      var state = container.read(questionSetControllerProvider);
      expect(state.activeSet!.id, secondSetId);

      // Delete the active second set
      await notifier.deleteSet(secondSetId);
      await Future.delayed(const Duration(milliseconds: 50));

      state = container.read(questionSetControllerProvider);
      expect(state.activeSet!.id, 'default_system_set'); // Fell back to default set
      expect(state.questionSets.any((s) => s.id == secondSetId), isFalse);
    });
  });
}

import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verysimplediary/features/diary/controller/diary_controller.dart';
import 'package:verysimplediary/features/diary/repository/diary_repository.dart';
import 'package:verysimplediary/core/db/local_database.dart';

class MockDiaryRepository implements DiaryRepository {
  final _dayController = StreamController<DiaryDay?>.broadcast();
  final _responsesController = StreamController<List<DiaryResponse>>.broadcast();
  
  DiaryDay? currentDay;
  List<DiaryResponse> currentResponses = [];

  @override
  Stream<DiaryDay?> watchDiaryDay(String date) async* {
    yield currentDay;
    yield* _dayController.stream;
  }

  @override
  Stream<List<DiaryResponse>> watchResponses(String diaryDayId) async* {
    yield currentResponses;
    yield* _responsesController.stream;
  }

  @override
  Future<DiaryDay> getOrCreateDiaryDay(String date) async {
    final day = DiaryDay(
      id: 'mock_day_id',
      date: date,
      status: 'draft',
      totalScore: 0.0,
      meanScore: 0.0,
      medianScore: 0.0,
      level: 'Moyen',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    currentDay = day;
    _dayController.add(day);
    return day;
  }

  @override
  Future<void> saveResponseDraft({
    required String diaryDayId,
    required int questionNumber,
    required List<int> nuit,
    required List<int> matin,
    required List<int> journee,
    required List<int> soir,
  }) async {
    final resp = DiaryResponse(
      id: '${diaryDayId}_$questionNumber',
      diaryDayId: diaryDayId,
      questionNumber: questionNumber,
      nuitValues: nuit.join(','),
      matinValues: matin.join(','),
      journeeValues: journee.join(','),
      soirValues: soir.join(','),
      updatedAt: DateTime.now(),
    );
    currentResponses.removeWhere((r) => r.questionNumber == questionNumber);
    currentResponses.add(resp);
    _responsesController.add(currentResponses);
  }

  @override
  Future<void> updateDiaryDay({
    required String id,
    required String status,
    required double total,
    required double mean,
    required double median,
    required String level,
    String? insight,
  }) async {
    if (currentDay != null) {
      final updated = DiaryDay(
        id: id,
        date: currentDay!.date,
        status: status,
        totalScore: total,
        meanScore: mean,
        medianScore: median,
        level: level,
        insightText: insight,
        createdAt: currentDay!.createdAt,
        updatedAt: DateTime.now(),
      );
      currentDay = updated;
      _dayController.add(updated);
    }
  }

  void dispose() {
    _dayController.close();
    _responsesController.close();
  }
}

void main() {
  late ProviderContainer container;
  late MockDiaryRepository mockRepository;
  const testDate = '2026-06-12';

  setUp(() {
    mockRepository = MockDiaryRepository();
    container = ProviderContainer(
      overrides: [
        diaryRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() {
    mockRepository.dispose();
    container.dispose();
  });

  group('DiaryNotifier Unit Tests', () {
    test('Initial State is loaded correctly', () async {
      // Trigger initialization by reading the notifier
      container.read(diaryControllerProvider(testDate).notifier);

      // Let initialization complete
      await Future.delayed(Duration.zero);
      
      final state = container.read(diaryControllerProvider(testDate));
      expect(state.date, testDate);
      expect(state.currentQuestionIndex, 0);
      expect(state.currentSelection['nuit'], isEmpty);
      expect(state.currentSelection['matin'], isEmpty);
    });

    test('Navigates questions and saves answers draft', () async {
      final notifier = container.read(diaryControllerProvider(testDate).notifier);
      await Future.delayed(Duration.zero);

      // Select rating
      notifier.toggleRating('matin', 1);
      notifier.toggleRating('soir', 2);
      
      var state = container.read(diaryControllerProvider(testDate));
      expect(state.currentSelection['matin'], equals([1]));
      expect(state.currentSelection['soir'], equals([2]));

      // Go to next question
      await notifier.nextQuestion();
      
      state = container.read(diaryControllerProvider(testDate));
      expect(state.currentQuestionIndex, 1);
      expect(state.currentSelection['matin'], isEmpty); // should be reset on the new question
      
      // Verify answer was saved in mock repository
      expect(mockRepository.currentResponses.length, 1);
      expect(mockRepository.currentResponses.first.questionNumber, 1);
      expect(mockRepository.currentResponses.first.matinValues, '1');
      expect(mockRepository.currentResponses.first.soirValues, '2');
    });

    test('Prev question recovers previous answers', () async {
      final notifier = container.read(diaryControllerProvider(testDate).notifier);
      await Future.delayed(Duration.zero);

      // Set answer for Q1
      notifier.toggleRating('journee', -1);
      await notifier.nextQuestion();

      // Set answer for Q2
      notifier.toggleRating('nuit', 0);
      await notifier.nextQuestion();
      
      // Go back to Q2
      notifier.prevQuestion();
      var state = container.read(diaryControllerProvider(testDate));
      expect(state.currentQuestionIndex, 1);
      expect(state.currentSelection['nuit'], equals([0]));

      // Go back to Q1
      notifier.prevQuestion();
      state = container.read(diaryControllerProvider(testDate));
      expect(state.currentQuestionIndex, 0);
      expect(state.currentSelection['journee'], equals([-1]));
    });

    test('Finalize day updates status to finalized and computes scores', () async {
      final notifier = container.read(diaryControllerProvider(testDate).notifier);
      await Future.delayed(Duration.zero);

      // Save a mock response
      mockRepository.currentResponses = [
        DiaryResponse(
          id: 'mock_day_id_1',
          diaryDayId: 'mock_day_id',
          questionNumber: 1,
          nuitValues: '2',
          matinValues: '1',
          journeeValues: '2',
          soirValues: '1',
          updatedAt: DateTime.now(),
        )
      ];
      
      // Force notifier state response sync
      mockRepository._responsesController.add(mockRepository.currentResponses);
      await Future.delayed(Duration.zero);

      await notifier.finalizeDay();
      await Future.delayed(Duration.zero);

      final finalDay = mockRepository.currentDay;
      expect(finalDay, isNotNull);
      expect(finalDay!.status, 'finalized');
      expect(finalDay.totalScore, 6.0); // 2 + 1 + 2 + 1
      expect(finalDay.meanScore, 1.5);
      expect(finalDay.medianScore, 1.5);
      expect(finalDay.level, 'Optimal');
    });
  });
}

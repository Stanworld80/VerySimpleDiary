import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:verysimplediary/main.dart';
import 'package:verysimplediary/core/db/local_database.dart';
import 'package:verysimplediary/features/auth/repository/auth_repository.dart';
import 'package:verysimplediary/features/diary/repository/diary_repository.dart';
import 'package:verysimplediary/features/diary/repository/sync_repository.dart';
import 'package:verysimplediary/core/config/settings_provider.dart';

class MockDiaryRepository implements DiaryRepository {
  final _dayController = StreamController<DiaryDay?>.broadcast();
  final _responsesController = StreamController<List<DiaryResponse>>.broadcast();
  final _allDaysController = StreamController<List<DiaryDay>>.broadcast();

  DiaryDay? currentDay;
  List<DiaryResponse> currentResponses = [];
  List<DiaryDay> allDays = [];

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
  Stream<List<DiaryResponse>> watchAllResponses() async* {
    yield currentResponses;
    yield* _responsesController.stream;
  }

  @override
  Stream<List<DiaryDay>> watchAllDiaryDays() async* {
    yield allDays;
    yield* _allDaysController.stream;
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
    if (!allDays.any((d) => d.date == date)) {
      allDays.add(day);
      _allDaysController.add(allDays);
    }
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
    String nuitComment = '',
    String matinComment = '',
    String journeeComment = '',
    String soirComment = '',
  }) async {
    final resp = DiaryResponse(
      id: '${diaryDayId}_$questionNumber',
      diaryDayId: diaryDayId,
      questionNumber: questionNumber,
      nuitValues: nuit.join(','),
      matinValues: matin.join(','),
      journeeValues: journee.join(','),
      soirValues: soir.join(','),
      nuitComment: nuitComment,
      matinComment: matinComment,
      journeeComment: journeeComment,
      soirComment: soirComment,
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
      final idx = allDays.indexWhere((d) => d.id == id);
      if (idx != -1) {
        allDays[idx] = updated;
      } else {
        allDays.add(updated);
      }
      _allDaysController.add(allDays);
    }
  }

  @override
  Future<void> deleteDiaryDay(String date) async {
    allDays.removeWhere((d) => d.date == date);
    _allDaysController.add(allDays);
    if (currentDay?.date == date) {
      currentDay = null;
      _dayController.add(null);
    }
  }

  void dispose() {
    _dayController.close();
    _responsesController.close();
    _allDaysController.close();
  }
}

class MockSyncRepository implements SyncRepository {
  @override
  Future<void> syncDay(String date) async {}
  @override
  Future<void> syncAll() async {}
  @override
  Future<void> deleteDay(String date) async {}
}

void main() {
  late MockDiaryRepository mockDiaryRepository;
  late MockSyncRepository mockSyncRepository;

  setUp(() async {
    mockDiaryRepository = MockDiaryRepository();
    mockSyncRepository = MockSyncRepository();
    AuthRepository.forceMock = true;
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
  });

  testWidgets('Full User Integration Flow (Login, Comments, Explorer Stats)', (WidgetTester tester) async {
    final prefs = await SharedPreferences.getInstance();
    // 1. Initialize container and sign out
    final container = ProviderContainer(
      overrides: [
        diaryRepositoryProvider.overrideWithValue(mockDiaryRepository),
        syncRepositoryProvider.overrideWithValue(mockSyncRepository),
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
    );
    
    await container.read(authRepositoryProvider).signOut();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MyApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Login Screen loaded
    expect(find.text('Very Simple Diary'), findsOneWidget);
    expect(find.text('Se connecter avec Google'), findsOneWidget);

    // Tap "Se connecter avec Google" to login
    await tester.tap(find.text('Se connecter avec Google'));
    await tester.pumpAndSettle();

    // 2. Verify Home Screen is now loaded
    expect(find.text('Votre journal sémantique personnel, sécurisé et local.'), findsOneWidget);
    expect(find.text('Exploration'), findsOneWidget);

    // Tap on the daily diary button
    final journalButton = find.byWidgetPredicate(
      (widget) => widget is ElevatedButton &&
                  widget.child is Row &&
                  (widget.child as Row).children.any(
                    (c) => c is Flexible &&
                           c.child is Text &&
                           (c.child as Text).data!.startsWith('Journal du jour'),
                  ),
    );
    expect(journalButton, findsOneWidget);
    await tester.tap(journalButton);
    await tester.pumpAndSettle();

    // 3. Verify Diary Screen (Question 1)
    expect(find.text('1. Santé, Sport & Sommeil'), findsOneWidget);
    expect(find.text('Q 1 / 24'), findsOneWidget);

    // Tap 'Nuit' to add a comment
    final nuitText = find.text('Nuit (00h-05h)');
    expect(nuitText, findsOneWidget);
    await tester.tap(nuitText);
    await tester.pumpAndSettle();

    // Verify AlertDialog is shown
    expect(find.text('Commentaire - Nuit (00h-05h)'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Sommeil agité');
    await tester.pumpAndSettle();

    // Validate
    await tester.tap(find.text('VALIDER'));
    await tester.pumpAndSettle();

    // Verify the comment is visible on the main screen
    expect(find.text('Sommeil agité'), findsOneWidget);

    // Test the 64 characters limit
    await tester.tap(nuitText);
    await tester.pumpAndSettle();
    
    final seventyCharsString = 'B' * 70;
    await tester.enterText(find.byType(TextField), seventyCharsString);
    await tester.pumpAndSettle();
    await tester.tap(find.text('VALIDER'));
    await tester.pumpAndSettle();

    // Verify it was truncated to 64 chars
    final sixtyFourCharsString = 'B' * 64;
    expect(find.text(sixtyFourCharsString), findsOneWidget);

    // Test swipe left to go to next question
    await tester.fling(find.text('SOMMEIL'), const Offset(-200, 0), 1000);
    await tester.pumpAndSettle();
    expect(find.text('Q 2 / 24'), findsOneWidget);
    expect(find.text('SPORT'), findsOneWidget);

    // Test swipe right to go back to previous question
    await tester.fling(find.text('SPORT'), const Offset(200, 0), 1000);
    await tester.pumpAndSettle();
    expect(find.text('Q 1 / 24'), findsOneWidget);
    expect(find.text('SOMMEIL'), findsOneWidget);

    // Navigate back to Home
    final backButton = find.byType(BackButton);
    expect(backButton, findsOneWidget);
    await tester.tap(backButton);
    await tester.pumpAndSettle();

    // Tap "Explorer les données"
    final explorerButton = find.widgetWithText(OutlinedButton, 'Exploration');
    expect(explorerButton, findsOneWidget);
    await tester.tap(explorerButton);
    await tester.pumpAndSettle();

    // 4. Verify Explorer Screen elements
    expect(find.text('ÉVOLUTION SUR PÉRIODE'), findsOneWidget);
    expect(find.text('Moyenne'), findsOneWidget);
    expect(find.text('Médiane'), findsOneWidget);

    // Toggle Moyenne / Médiane selection
    await tester.tap(find.text('Médiane'));
    await tester.pumpAndSettle();

    // Tap start date button "De:"
    final deButton = find.textContaining('De:');
    if (deButton.evaluate().isNotEmpty) {
      await tester.tap(deButton);
      await tester.pumpAndSettle();
      // Close DatePicker
      final cancelBtn = find.text('CANCEL');
      if (cancelBtn.evaluate().isNotEmpty) {
        await tester.tap(cancelBtn);
        await tester.pumpAndSettle();
      }
    }
    
    // Dispose the container manually
    container.dispose();
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:drift/native.dart';
import 'package:verysimplediary/main.dart';
import 'package:verysimplediary/core/db/local_database.dart';
import 'package:verysimplediary/core/config/settings_provider.dart';
import 'package:verysimplediary/features/diary/repository/diary_repository.dart';
import 'package:verysimplediary/features/diary/repository/question_set_repository.dart';
import 'package:verysimplediary/features/diary/ui/question_sets_screen.dart';
import 'package:verysimplediary/features/auth/repository/auth_repository.dart';

void main() {
  setUp(() async {
    AuthRepository.forceMock = true;
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
  });

  testWidgets('Integration Test 1: Notification Setting UI Flow', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final prefs = await SharedPreferences.getInstance();
    final inMemoryDb = LocalDatabase.forTesting(NativeDatabase.memory());
    
    final questionSetRepo = QuestionSetRepository(inMemoryDb);
    final diaryRepo = DiaryRepository(inMemoryDb);

    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(inMemoryDb),
        questionSetRepositoryProvider.overrideWithValue(questionSetRepo),
        diaryRepositoryProvider.overrideWithValue(diaryRepo),
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

    // 1. Login
    await tester.tap(find.text('Se connecter avec Google'));
    await tester.pumpAndSettle();

    // 2. Open Settings
    final profileButtonIcon = find.byIcon(Icons.account_circle_rounded);
    expect(profileButtonIcon, findsOneWidget);
    await tester.tap(profileButtonIcon);
    await tester.pumpAndSettle();

    final settingsOption = find.text('Paramètres');
    expect(settingsOption, findsOneWidget);
    await tester.tap(settingsOption);
    await tester.pumpAndSettle();

    // 3. Toggle and save notifications
    expect(find.text('Rappels de fin de période'), findsOneWidget);
    final switchFinder = find.byType(Switch).last;
    expect(switchFinder, findsOneWidget);
    
    await tester.tap(switchFinder);
    await tester.pumpAndSettle();

    final saveBtn = find.text('Enregistrer');
    await tester.tap(saveBtn);
    await tester.pumpAndSettle();

    final settings = container.read(settingsProvider);
    expect(settings.notificationsEnabled, isTrue);
    
    await inMemoryDb.close();
  });

  testWidgets('Integration Test 2: Question Set Management UI Flow', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final prefs = await SharedPreferences.getInstance();
    final inMemoryDb = LocalDatabase.forTesting(NativeDatabase.memory());
    
    final questionSetRepo = QuestionSetRepository(inMemoryDb);
    final diaryRepo = DiaryRepository(inMemoryDb);

    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(inMemoryDb),
        questionSetRepositoryProvider.overrideWithValue(questionSetRepo),
        diaryRepositoryProvider.overrideWithValue(diaryRepo),
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

    // 1. Login
    await tester.tap(find.text('Se connecter avec Google'));
    await tester.pumpAndSettle();

    // 2. Open Questionnaires screen
    final profileButtonIcon = find.byIcon(Icons.account_circle_rounded);
    expect(profileButtonIcon, findsOneWidget);
    await tester.tap(profileButtonIcon);
    await tester.pumpAndSettle();

    final questionnairesOption = find.text('Questionnaires');
    expect(questionnairesOption, findsOneWidget);
    await tester.tap(questionnairesOption);
    await tester.pumpAndSettle();

    // Verify Question Sets Screen is shown
    expect(find.byType(QuestionSetsScreen), findsOneWidget);
    expect(find.text('Set par défaut'), findsOneWidget);

    // 3. Create a Custom Set
    final createBtn = find.byIcon(Icons.add_rounded);
    expect(createBtn, findsOneWidget);
    await tester.tap(createBtn);
    await tester.pumpAndSettle();

    expect(find.text('Nouveau questionnaire'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Set De Test UI');
    await tester.pumpAndSettle();

    await tester.tap(find.text('VALIDER'));
    await tester.pumpAndSettle();

    expect(find.text('Set De Test UI'), findsOneWidget);

    // 4. Navigate Back to Home
    final backBtn = find.byIcon(Icons.arrow_back_rounded);
    expect(backBtn, findsOneWidget);
    await tester.tap(backBtn);
    await tester.pumpAndSettle();

    expect(find.text('Votre journal sémantique personnel, sécurisé et local.'), findsOneWidget);
    
    await inMemoryDb.close();
  });
}

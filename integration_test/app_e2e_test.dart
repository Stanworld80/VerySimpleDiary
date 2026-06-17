import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:verysimplediary/main.dart' as app;
import 'package:verysimplediary/features/auth/repository/auth_repository.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-End App Flow Test', () {
    testWidgets('Complete user flow (Login -> Question grid -> Summary validation)', (tester) async {
      // Force mock mode during integration testing
      AuthRepository.forceMock = true;

      // Create an auth repo instance to manage sign-out without relying on BuildContext
      final authRepo = AuthRepository();

      // Ensure signed out before the test so we land on the login screen
      if (authRepo.currentUser != null) {
        await authRepo.signOut();
      }

      // Start the application
      app.main();
      await tester.pumpAndSettle();

      // 1. Verify we are on the Login Screen
      expect(find.text('Very Simple Diary'), findsOneWidget);
      expect(find.text('Se connecter'), findsOneWidget);

      // Enter login credentials
      final emailField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).last;

      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, 'password123');
      await tester.pumpAndSettle();

      // Tap Se connecter
      final validerButton = find.widgetWithText(ElevatedButton, 'Se connecter');
      await tester.tap(validerButton);
      await tester.pump();

      bool homeScreenVisibleAfterLogin = false;
      for (int i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 200));
        if (find.text('Exploration').evaluate().isNotEmpty) {
          homeScreenVisibleAfterLogin = true;
          break;
        }
      }
      expect(homeScreenVisibleAfterLogin, isTrue);

      // 2. We should now be on the Home Screen
      expect(find.text('Exploration'), findsOneWidget);

      // Tap on "Journal du jour" button
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

      // 3. We should now be on the Diary Screen (Question 1)
      expect(find.text('1. Santé, Sport & Sommeil'), findsOneWidget);
      expect(find.text('Q 1 / 24'), findsOneWidget);

      // Loop through all 24 questions, tapping a rating then NEXT each time
      for (int q = 1; q <= 24; q++) {
        // Tap the first available GestureDetector to register a rating
        final gestureDetectors = find.byType(GestureDetector);
        if (gestureDetectors.evaluate().isNotEmpty) {
          await tester.tap(gestureDetectors.at(5));
          await tester.pump();
        }

        // Tap the NEXT button
        final nextButton = find.byType(ElevatedButton);
        await tester.tap(nextButton);
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
      }

      // 4. We should now be on the Summary Screen
      expect(find.text('Récapitulatif Final'), findsOneWidget);
      expect(find.text('Score Total'), findsOneWidget);
      expect(find.text('Médiane'), findsOneWidget);
      expect(find.text('Valider la journée'), findsOneWidget);

      // Tap "Valider la journée"
      final finalizeButton = find.widgetWithText(ElevatedButton, 'Valider la journée');
      await tester.tap(finalizeButton);
      await tester.pump();

      // We should be redirected back to the Home Screen. Since finalizeDay is async,
      // we pump and wait in a loop until the home screen is visible.
      bool homeScreenVisible = false;
      for (int i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 200));
        if (find.text('Exploration').evaluate().isNotEmpty) {
          homeScreenVisible = true;
          break;
        }
      }
      expect(homeScreenVisible, isTrue);
    });
  });
}

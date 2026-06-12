import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:verysimplediary/main.dart' as app;
import 'package:verysimplediary/features/auth/repository/auth_repository.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-End App Flow Test', () {
    testWidgets('Complete user flow (Login -> Question grid -> Summary validation)', (tester) async {
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
      expect(find.text('Valider'), findsOneWidget);

      // Enter login credentials
      final emailField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).last;

      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, 'password123');
      await tester.pumpAndSettle();

      // Tap Valider
      final validerButton = find.widgetWithText(ElevatedButton, 'Valider');
      await tester.tap(validerButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // 2. We should now be on the Diary Screen (Question 1)
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

      // 3. We should now be on the Summary Screen
      expect(find.text('Récapitulatif Final'), findsOneWidget);
      expect(find.text('Score Total'), findsOneWidget);
      expect(find.text('Médiane'), findsOneWidget);
      expect(find.text('Valider la journée'), findsOneWidget);

      // Tap "Valider la journée"
      final finalizeButton = find.widgetWithText(ElevatedButton, 'Valider la journée');
      await tester.tap(finalizeButton);
      await tester.pumpAndSettle();

      // We should be redirected back to the beginning of the Diary screen
      expect(find.text('1. Santé, Sport & Sommeil'), findsOneWidget);
    });
  });
}

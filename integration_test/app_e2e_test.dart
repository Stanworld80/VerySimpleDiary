import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verysimplediary/main.dart' as app;
import 'package:verysimplediary/features/auth/repository/auth_repository.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-End App Flow Test', () {
    testWidgets('Complete user flow (Login -> Question grid -> Summary validation)', (tester) async {
      // Start the application
      app.main();
      await tester.pumpAndSettle();

      // If we are logged in by default (in local mock mode), let's sign out first to test login
      final BuildContext context = tester.element(find.byType(app.MyApp));
      final container = ProviderScope.containerOf(context);
      final authRepo = container.read(authRepositoryProvider);

      if (authRepo.currentUser != null) {
        await authRepo.signOut();
        await tester.pumpAndSettle();
      }

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

      // We will loop through the 24 questions.
      // For each question, we'll select some ratings and hit SUIVANT.
      for (int q = 1; q <= 24; q++) {
        // Toggle some ratings to simulate user input
        // Let's toggle 'matin' to +1 (which is index 3 of ratings [-2, -1, 0, 1, 2])
        // To do this simply, we find the GestureDetector/InkWell or toggle using the controller directly for speed,
        // or tap on a circle. Let's tap the circle of 'Matin' for rating '0' (the 3rd rating).
        // Let's check if we can find the gesture detectors.
        final gestureDetectors = find.byType(GestureDetector);
        if (gestureDetectors.evaluate().isNotEmpty) {
          // Tap the 5th detector (first row ratings)
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

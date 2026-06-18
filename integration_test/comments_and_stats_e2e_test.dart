import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:verysimplediary/main.dart' as app;
import 'package:verysimplediary/features/auth/repository/auth_repository.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Comments and Explorer Stats E2E Test', () {
    testWidgets('Verify period comments entry, 64-char limit, and explorer period stats screen', (tester) async {
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

      // Login
      final emailField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).last;

      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, 'password123');
      await tester.pumpAndSettle();

      final validerButton = find.widgetWithText(ElevatedButton, 'Se connecter');
      await tester.tap(validerButton);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

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

      // We should be on the Diary Screen
      expect(find.text('1. Santé, Sport & Sommeil'), findsOneWidget);

      // Verify E2E Swipe gestures (Swipe Left to go to Q2, Swipe Right to go back to Q1)
      await tester.fling(find.text('SOMMEIL'), const Offset(-200, 0), 1000);
      await tester.pumpAndSettle();
      expect(find.text('Q 2 / 24'), findsOneWidget);
      expect(find.text('SPORT'), findsOneWidget);

      await tester.fling(find.text('SPORT'), const Offset(200, 0), 1000);
      await tester.pumpAndSettle();
      expect(find.text('Q 1 / 24'), findsOneWidget);
      expect(find.text('SOMMEIL'), findsOneWidget);

      // Tap on the 'Nuit' period row to enter a comment
      final nuitText = find.text('Nuit (00h-05h)');
      expect(nuitText, findsOneWidget);
      await tester.tap(nuitText);
      await tester.pumpAndSettle();

      // Dialog should be open
      expect(find.text('Commentaire - Nuit (00h-05h)'), findsOneWidget);
      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);

      // Enter a normal comment
      await tester.enterText(textField, 'Bonne nuit tranquille');
      await tester.pumpAndSettle();

      // Tap VALIDER
      final validateCommentBtn = find.text('VALIDER');
      await tester.tap(validateCommentBtn);
      await tester.pumpAndSettle();

      // Verify comment is saved and displayed on diary screen
      expect(find.text('Bonne nuit tranquille'), findsOneWidget);

      // Tap Nuit again to test 64 characters limit
      await tester.tap(nuitText);
      await tester.pumpAndSettle();

      // Enter a long comment (> 64 chars)
      final longComment = 'A' * 70;
      await tester.enterText(textField, longComment);
      await tester.pumpAndSettle();

      // Tap VALIDER
      await tester.tap(find.text('VALIDER'));
      await tester.pumpAndSettle();

      // Verify comment is truncated to 64 chars
      final truncatedComment = 'A' * 64;
      expect(find.text(truncatedComment), findsOneWidget);

      // Navigate back to Home
      final backButton = find.byTooltip('Back');
      if (backButton.evaluate().isNotEmpty) {
        await tester.tap(backButton);
        await tester.pumpAndSettle();
      } else {
        final backIcon = find.byIcon(Icons.arrow_back_ios_new_rounded);
        if (backIcon.evaluate().isNotEmpty) {
          await tester.tap(backIcon);
          await tester.pumpAndSettle();
        }
      }

      // Now tap "Explorer les données"
      final explorerButton = find.widgetWithText(OutlinedButton, 'Exploration');
      expect(explorerButton, findsOneWidget);
      await tester.tap(explorerButton);
      await tester.pumpAndSettle();

      // Verify Explorer Screen UI components
      expect(find.text('ÉVOLUTION SUR PÉRIODE'), findsOneWidget);
      expect(find.text('Moyenne'), findsOneWidget);
      expect(find.text('Médiane'), findsOneWidget);

      // Tap on Médiane
      final medianeText = find.text('Médiane');
      await tester.tap(medianeText);
      await tester.pumpAndSettle();

      // Tap on De: to check start date selection
      final deButton = find.textContaining('De:');
      if (deButton.evaluate().isNotEmpty) {
        await tester.tap(deButton);
        await tester.pumpAndSettle();
        // Close the DatePicker by clicking Cancel
        final cancelBtn = find.text('CANCEL');
        if (cancelBtn.evaluate().isNotEmpty) {
          await tester.tap(cancelBtn);
          await tester.pumpAndSettle();
        }
      }

      // --- NEW: HistoryScreen E2E Test Flows ---
      // 1. Go back to Home Screen from ExplorerScreen
      final backButtonExplorer = find.byIcon(Icons.arrow_back_ios_new_rounded);
      expect(backButtonExplorer, findsOneWidget);
      await tester.tap(backButtonExplorer);
      await tester.pumpAndSettle();

      expect(find.text('Exploration'), findsOneWidget);

      // 2. Go to HistoryScreen
      final historiqueButton = find.widgetWithText(OutlinedButton, 'Historique');
      expect(historiqueButton, findsOneWidget);
      await tester.tap(historiqueButton);
      await tester.pumpAndSettle();

      expect(find.text('Historique & Modifications'), findsOneWidget);

      // 3. Verify that the draft day is present in the list (badge BROUILLON)
      expect(find.text('BROUILLON'), findsOneWidget);

      // 4. Test Edit/Revert to Draft Flow
      final editIconBtn = find.byIcon(Icons.edit_note_rounded);
      expect(editIconBtn, findsOneWidget);
      await tester.tap(editIconBtn);
      await tester.pumpAndSettle();

      // Verify confirmation popup
      expect(find.text('Modifier cette journée ?'), findsOneWidget);
      final confirmEditBtn = find.widgetWithText(ElevatedButton, 'Confirmer');
      expect(confirmEditBtn, findsOneWidget);
      await tester.tap(confirmEditBtn);
      await tester.pumpAndSettle();

      // Should be redirected back to the DiaryScreen for Q1
      expect(find.text('1. Santé, Sport & Sommeil'), findsOneWidget);
      expect(find.text('Q 1 / 24'), findsOneWidget);
      // Verify our comments were loaded and restored properly
      expect(find.text(truncatedComment), findsOneWidget);

      // Go back to Home
      final backArrowDiary = find.byIcon(Icons.arrow_back_ios_new_rounded);
      expect(backArrowDiary, findsOneWidget);
      await tester.tap(backArrowDiary);
      await tester.pumpAndSettle();

      // Go back to History Screen
      await tester.tap(historiqueButton);
      await tester.pumpAndSettle();

      // 5. Test Delete Flow
      // Tap on BROUILLON to highlight/select the day
      await tester.tap(find.text('BROUILLON'));
      await tester.pumpAndSettle();

      // Tap delete (trash) in actions header
      final deleteIcon = find.byIcon(Icons.delete_outline_rounded);
      expect(deleteIcon, findsOneWidget);
      await tester.tap(deleteIcon);
      await tester.pumpAndSettle();

      // Verify deletion popup
      expect(find.text('Supprimer cette journée ?'), findsOneWidget);
      final confirmDeleteBtn = find.widgetWithText(ElevatedButton, 'Supprimer');
      expect(confirmDeleteBtn, findsOneWidget);
      await tester.tap(confirmDeleteBtn);
      await tester.pumpAndSettle();

      // List should now be empty
      expect(find.text('Aucune journée enregistrée.'), findsOneWidget);
    });
  });
}

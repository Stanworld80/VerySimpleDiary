import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verysimplediary/main.dart';
import 'package:verysimplediary/features/auth/repository/auth_repository.dart';

void main() {
  testWidgets('Loads LoginScreen successfully', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWithValue(const AsyncValue.data(null)),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify that the login screen header and buttons are rendered.
    expect(find.text('Very Simple Diary'), findsOneWidget);
    expect(find.text('Se connecter avec Google'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Mot de passe'), findsOneWidget);
  });
}

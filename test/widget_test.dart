import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:verysimplediary/main.dart';
import 'package:verysimplediary/features/auth/repository/auth_repository.dart';
import 'package:verysimplediary/core/config/settings_provider.dart';

void main() {
  testWidgets('Loads LoginScreen successfully', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith((ref) => Stream.value(null)),
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pump();
    await tester.pumpAndSettle();

    // Verify that the login screen header and buttons are rendered.
    expect(find.text('Very Simple Diary'), findsOneWidget);
    expect(find.text('Se connecter avec Google'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Mot de passe'), findsOneWidget);
  });
}

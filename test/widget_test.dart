import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verysimplediary/main.dart';

void main() {
  testWidgets('Loads LoginScreen successfully', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
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

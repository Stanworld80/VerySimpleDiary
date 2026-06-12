import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/repository/auth_repository.dart';
import 'features/auth/ui/login_screen.dart';
import 'features/diary/ui/diary_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase init failed: $e. Running in Local-First Mode.");
  }
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'Very Simple Diary',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: authState.when(
        data: (user) {
          if (user != null) {
            return const DiaryScreen();
          }
          return const LoginScreen();
        },
        loading: () => const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
        error: (err, stack) => Scaffold(
          body: Center(
            child: Text('Erreur: $err'),
          ),
        ),
      ),
    );
  }
}

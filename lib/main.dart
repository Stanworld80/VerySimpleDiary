// Very Simple Diary - Main Entry Point
// Supports local-first SQLite database and optional Firebase Sync.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:yaml/yaml.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/repository/auth_repository.dart';
import 'features/auth/ui/login_screen.dart';
import 'features/diary/ui/diary_screen.dart';
import 'features/diary/controller/diary_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load and parse questions list from assets/questions.yaml
  try {
    final yamlString = await rootBundle.loadString('assets/questions.yaml');
    final yamlList = loadYaml(yamlString) as YamlList;
    diaryQuestionsList = yamlList.map((element) {
      final map = element as Map;
      return DiaryQuestion(
        number: map['number'] as int,
        category: map['category'] as String,
        title: map['title'] as String,
        description: map['description'] as String,
      );
    }).toList();
  } catch (e) {
    debugPrint("Failed to load questions from assets/questions.yaml: $e");
  }

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

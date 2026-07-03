import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repository/diary_repository.dart';
import '../repository/sync_repository.dart';
import '../repository/question_set_repository.dart';
import '../score_calculator.dart';
import '../../../core/db/local_database.dart';
import '../../../core/config/settings_provider.dart';
import '../../../core/services/gemini_service.dart';

class DiaryQuestion {
  final int number;
  final String category;
  final String title;
  final String description;

  const DiaryQuestion({
    required this.number,
    required this.category,
    required this.title,
    required this.description,
  });
}

List<DiaryQuestion> diaryQuestionsList = [
  // 1. Santé, Sport & Sommeil
  const DiaryQuestion(number: 1, category: '1. Santé, Sport & Sommeil', title: 'SOMMEIL', description: 'Qualité de la nuit, endormissement, récupération.'),
  const DiaryQuestion(number: 2, category: '1. Santé, Sport & Sommeil', title: 'SPORT', description: 'Activité physique, étirements, mouvements.'),
  const DiaryQuestion(number: 3, category: '1. Santé, Sport & Sommeil', title: 'DOULEUR', description: 'Présence et intensité de douleurs physiques ou inconforts.'),
  const DiaryQuestion(number: 4, category: '1. Santé, Sport & Sommeil', title: 'ÉNERGIE & MALADIE', description: 'Vitalité globale, symptômes viraux ou fatigue chronique.'),
  // 2. Alimentation
  const DiaryQuestion(number: 5, category: '2. Alimentation', title: 'NOURRITURE', description: 'Qualité des repas, respect des objectifs nutritionnels.'),
  const DiaryQuestion(number: 6, category: '2. Alimentation', title: 'HYDRATATION', description: 'Quantité d\'eau bue dans la journée.'),
  const DiaryQuestion(number: 7, category: '2. Alimentation', title: 'ÉLIMINATION', description: 'Digestion, transit et confort intestinal.'),
  const DiaryQuestion(number: 8, category: '2. Alimentation', title: 'EXCÈS', description: 'Gestion des craquages (trash food, sucre, excitants).'),
  // 3. Psychisme
  const DiaryQuestion(number: 9, category: '3. Psychisme', title: 'STRESS & ANXIÉTÉ', description: 'Niveau de tension interne, pics d\'angoisse.'),
  const DiaryQuestion(number: 10, category: '3. Psychisme', title: 'HUMEUR & MORAL', description: 'Météo intérieure, optimisme ou rumination.'),
  const DiaryQuestion(number: 11, category: '3. Psychisme', title: 'FOCUS & RÉFLEXION', description: 'Clarté mentale, concentration, gestion des distractions.'),
  const DiaryQuestion(number: 12, category: '3. Psychisme', title: 'SPIRITUALITÉ & MÉDITATION', description: 'Temps de pause, alignement, pleine conscience.'),
  // 4. Hygiène & Ménage
  const DiaryQuestion(number: 13, category: '4. Hygiène & Ménage', title: 'HYGIÈNE DU CORPS', description: 'Douche, soins personnels, routine corporelle.'),
  const DiaryQuestion(number: 14, category: '4. Hygiène & Ménage', title: 'RANGEMENT', description: 'Maintien de l\'ordre visuel dans les pièces de vie.'),
  const DiaryQuestion(number: 15, category: '4. Hygiène & Ménage', title: 'PROPRETÉ & MÉNAGE', description: 'Nettoyage effectif (aspirateur, vaisselle, linge).'),
  const DiaryQuestion(number: 16, category: '4. Hygiène & Ménage', title: 'ATMOSPHÈRE', description: 'Calme, aération et confort global de la maison.'),
  // 5. Admin & Finances
  const DiaryQuestion(number: 17, category: '5. Admin & Finances', title: 'TRAVAIL PRÉVU', description: 'Accomplissement des objectifs professionnels ou professionnels planifiés.'),
  const DiaryQuestion(number: 18, category: '5. Admin & Finances', title: 'ÉTUDES & RECHERCHE', description: 'Temps dédié à l\'apprentissage, la programmation ou la lecture.'),
  const DiaryQuestion(number: 19, category: '5. Admin & Finances', title: 'BUDGET & FINANCES', description: 'Suivi des comptes, contrôle des dépenses.'),
  const DiaryQuestion(number: 20, category: '5. Admin & Finances', title: 'DÉMARCHES', description: 'Gestion des courriers, contrats et obligations légales.'),
  // 6. Relations & Famille
  const DiaryQuestion(number: 21, category: '6. Relations & Famille', title: 'VIE DE COUPLE', description: 'Complicité, partage, soutien mutuel.'),
  const DiaryQuestion(number: 22, category: '6. Relations & Famille', title: 'FOYER & ENFANTS', description: 'Échanges avec les enfants, gestion du quotidien familial.'),
  const DiaryQuestion(number: 23, category: '6. Relations & Famille', title: 'SOCIAL EXTÉRIEUR', description: 'Contacts avec les amis, collègues.'),
  const DiaryQuestion(number: 24, category: '6. Relations & Famille', title: 'MONDE EXTÉRIEUR', description: 'Relation avec monde extérieur et inconnus : administration, institutions, prospect client...'),
];

class DiaryState {
  final String date;
  final DiaryDay? diaryDay;
  final List<DiaryResponse> responses;
  final int currentQuestionIndex;
  final Map<String, List<int>> currentSelection;
  final Map<String, String> currentComments;
  final List<CustomQuestion> questions;
  final List<String> activePeriods;

  const DiaryState({
    required this.date,
    this.diaryDay,
    this.responses = const [],
    this.currentQuestionIndex = 0,
    this.currentSelection = const {
      'nuit': [],
      'matin': [],
      'journee': [],
      'soir': [],
    },
    this.currentComments = const {
      'nuit': '',
      'matin': '',
      'journee': '',
      'soir': '',
    },
    this.questions = const [],
    this.activePeriods = const ['nuit', 'matin', 'journee', 'soir'],
  });

  CustomQuestion get currentQuestion {
    if (questions.isEmpty) {
      return CustomQuestion(
        id: 'dummy',
        setId: 'dummy',
        number: 1,
        category: 'Chargement...',
        title: 'Chargement...',
        description: 'Veuillez patienter...',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
    return questions[currentQuestionIndex];
  }
  
  double get progressPercentage => questions.isEmpty ? 0.0 : ((currentQuestionIndex + 1) / questions.length) * 100;

  DiaryState copyWith({
    String? date,
    DiaryDay? diaryDay,
    List<DiaryResponse>? responses,
    int? currentQuestionIndex,
    Map<String, List<int>>? currentSelection,
    Map<String, String>? currentComments,
    List<CustomQuestion>? questions,
    List<String>? activePeriods,
  }) {
    return DiaryState(
      date: date ?? this.date,
      diaryDay: diaryDay ?? this.diaryDay,
      responses: responses ?? this.responses,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      currentSelection: currentSelection ?? this.currentSelection,
      currentComments: currentComments ?? this.currentComments,
      questions: questions ?? this.questions,
      activePeriods: activePeriods ?? this.activePeriods,
    );
  }
}

class DiaryNotifier extends StateNotifier<DiaryState> {
  final DiaryRepository _diaryRepository;
  final SyncRepository _syncRepository;
  final Ref _ref;

  DiaryNotifier(this._diaryRepository, this._syncRepository, this._ref, String date) : super(DiaryState(date: date)) {
    _init();
  }

  Future<void> _init() async {
    final day = await _diaryRepository.getOrCreateDiaryDay(state.date);
    state = state.copyWith(diaryDay: day);
    
    final questionSetRepo = _ref.read(questionSetRepositoryProvider);
    await questionSetRepo.seedDefaultSetIfEmpty();
    
    String? setId = day.questionSetId;
    if (setId == null) {
      final activeSet = await questionSetRepo.getActiveQuestionSet();
      setId = activeSet?.id ?? 'default_system_set';
      await _diaryRepository.updateDiaryDaySet(day.id, setId);
    }
    
    final qs = await questionSetRepo.getQuestionsForSet(setId);
    final activeSetObj = await questionSetRepo.getQuestionSetById(setId);
    final periodsStr = activeSetObj?.selectedPeriods ?? 'nuit,matin,journee,soir';
    final periods = periodsStr.split(',').map((p) => p.trim()).where((p) => p.isNotEmpty).toList();

    state = state.copyWith(
      questions: qs,
      activePeriods: periods,
    );

    // Listen to updates for the day
    _diaryRepository.watchDiaryDay(state.date).listen((day) {
      if (day != null) {
        state = state.copyWith(diaryDay: day);
      }
    });

    // Watch responses for a diary day
    _diaryRepository.watchResponses(day.id).listen((responsesList) {
      state = state.copyWith(responses: responsesList);
      _loadSelectionForCurrentQuestion();
    });
  }

  void _loadSelectionForCurrentQuestion() {
    final qNumber = state.currentQuestionIndex + 1;
    final resp = state.responses.cast<DiaryResponse?>().firstWhere(
          (r) => r?.questionNumber == qNumber,
          orElse: () => null,
        );

    if (resp != null) {
      state = state.copyWith(
        currentSelection: {
          'nuit': _parseValues(resp.nuitValues),
          'matin': _parseValues(resp.matinValues),
          'journee': _parseValues(resp.journeeValues),
          'soir': _parseValues(resp.soirValues),
        },
        currentComments: {
          'nuit': resp.nuitComment,
          'matin': resp.matinComment,
          'journee': resp.journeeComment,
          'soir': resp.soirComment,
        },
      );
    } else {
      state = state.copyWith(
        currentSelection: const {
          'nuit': [],
          'matin': [],
          'journee': [],
          'soir': [],
        },
        currentComments: const {
          'nuit': '',
          'matin': '',
          'journee': '',
          'soir': '',
        },
      );
    }
  }

  List<int> _parseValues(String valStr) {
    if (valStr.trim().isEmpty) return [];
    return valStr.split(',').map(int.parse).toList();
  }

  void toggleRating(String period, int rating) {
    final currentSelection = Map<String, List<int>>.from(state.currentSelection);
    final periodList = List<int>.from(currentSelection[period] ?? []);

    if (periodList.contains(rating)) {
      periodList.clear(); // Deselect if already selected
    } else {
      periodList.clear(); // Clear previous choices on this line
      periodList.add(rating); // Set the new single choice
    }
    
    currentSelection[period] = periodList;
    state = state.copyWith(currentSelection: currentSelection);
  }

  void setComment(String period, String comment) {
    final currentComments = Map<String, String>.from(state.currentComments);
    // Limit to 64 characters
    final truncated = comment.length > 64 ? comment.substring(0, 64) : comment;
    currentComments[period] = truncated;
    state = state.copyWith(currentComments: currentComments);
  }

  Future<void> nextQuestion() async {
    if (state.diaryDay == null) return;
    
    // Save active answers in draft database
    await _diaryRepository.saveResponseDraft(
      diaryDayId: state.diaryDay!.id,
      questionNumber: state.currentQuestionIndex + 1,
      nuit: state.currentSelection['nuit'] ?? [],
      matin: state.currentSelection['matin'] ?? [],
      journee: state.currentSelection['journee'] ?? [],
      soir: state.currentSelection['soir'] ?? [],
      nuitComment: state.currentComments['nuit'] ?? '',
      matinComment: state.currentComments['matin'] ?? '',
      journeeComment: state.currentComments['journee'] ?? '',
      soirComment: state.currentComments['soir'] ?? '',
    );

    // Sync draft in background
    _syncRepository.syncDay(state.date).catchError((e) {
      debugPrint("Background sync error: $e");
    });

    if (state.currentQuestionIndex < state.questions.length - 1) {
      state = state.copyWith(currentQuestionIndex: state.currentQuestionIndex + 1);
      _loadSelectionForCurrentQuestion();
    } else {
      // End of questions, calculate final score
      await calculateScores();
    }
  }

  void prevQuestion() {
    if (state.currentQuestionIndex > 0) {
      state = state.copyWith(currentQuestionIndex: state.currentQuestionIndex - 1);
      _loadSelectionForCurrentQuestion();
    }
  }

  Future<void> calculateScores() async {
    if (state.diaryDay == null) return;

    final List<int> allValues = [];
    for (final r in state.responses) {
      if (state.activePeriods.contains('nuit')) allValues.addAll(_parseValues(r.nuitValues));
      if (state.activePeriods.contains('matin')) allValues.addAll(_parseValues(r.matinValues));
      if (state.activePeriods.contains('journee')) allValues.addAll(_parseValues(r.journeeValues));
      if (state.activePeriods.contains('soir')) allValues.addAll(_parseValues(r.soirValues));
    }

    final scoreResult = ScoreCalculator.calculate(allValues);
    
    final currentInsight = state.diaryDay?.insightText;
    final hasValidGeminiInsight = currentInsight != null &&
        currentInsight.isNotEmpty &&
        !currentInsight.startsWith("Aujourd'hui, votre score est") &&
        !currentInsight.startsWith("Journée finalisée avec un score") &&
        !currentInsight.contains("Échec de la génération");

    // Check if Gemini is enabled and configured
    final settings = _ref.read(settingsProvider);
    String insight;
    if (hasValidGeminiInsight) {
      // Keep the existing Gemini insight to avoid calling the LLM again
      insight = currentInsight;
    } else if (settings.useGemini && (settings.geminiMode == 'proxy' || settings.geminiApiKey.isNotEmpty)) {
      try {
        insight = await GeminiService.generateInsight(
          apiKey: settings.geminiApiKey,
          mode: settings.geminiMode,
          proxyUrl: settings.geminiProxyUrl,
          totalScore: scoreResult.total.toDouble(),
          meanScore: scoreResult.mean,
          medianScore: scoreResult.median,
          level: scoreResult.level,
          responses: state.responses,
          questions: state.questions,
        );
      } catch (e) {
        debugPrint("Gemini generation failed, falling back to standard insight: $e");
        insight = "Aujourd'hui, votre score est ${scoreResult.level}. "
            "Vous avez cumulé un score total de ${scoreResult.total} "
            "avec une moyenne de ${scoreResult.mean.toStringAsFixed(2)}.\n\n"
            "(Échec de la génération de l'analyse IA : $e)";
      }
    } else {
      // Auto-generate some dynamic summary description based on level
      insight = "Aujourd'hui, votre score est ${scoreResult.level}. "
          "Vous avez cumulé un score total de ${scoreResult.total} "
          "avec une moyenne de ${scoreResult.mean.toStringAsFixed(2)}.";
    }

    await _diaryRepository.updateDiaryDay(
      id: state.diaryDay!.id,
      status: state.diaryDay!.status, // keep current status ('draft')
      total: scoreResult.total.toDouble(),
      mean: scoreResult.mean,
      median: scoreResult.median,
      level: scoreResult.level,
      insight: insight,
    );

    // Sync draft in background
    _syncRepository.syncDay(state.date).catchError((e) {
      debugPrint("Background sync error: $e");
    });
  }

  Future<void> generateGeminiInsightManual() async {
    if (state.diaryDay == null) return;
    
    final settings = _ref.read(settingsProvider);
    if (settings.geminiMode == 'direct' && settings.geminiApiKey.isEmpty) {
      throw Exception("Clé API Gemini manquante. Veuillez la configurer dans les Paramètres.");
    }
    if (settings.geminiMode == 'proxy' && settings.geminiProxyUrl.isEmpty) {
      throw Exception("URL du Proxy Gemini manquante. Veuillez la configurer dans les Paramètres.");
    }

    // Temporarily set insightText to a loading state
    await _diaryRepository.updateDiaryDay(
      id: state.diaryDay!.id,
      status: state.diaryDay!.status,
      total: state.diaryDay!.totalScore,
      mean: state.diaryDay!.meanScore,
      median: state.diaryDay!.medianScore,
      level: state.diaryDay!.level,
      insight: "Génération de l'analyse par Gemini en cours...",
    );

    try {
      final insight = await GeminiService.generateInsight(
        apiKey: settings.geminiApiKey,
        mode: settings.geminiMode,
        proxyUrl: settings.geminiProxyUrl,
        totalScore: state.diaryDay!.totalScore,
        meanScore: state.diaryDay!.meanScore,
        medianScore: state.diaryDay!.medianScore,
        level: state.diaryDay!.level,
        responses: state.responses,
        questions: state.questions,
      );

      await _diaryRepository.updateDiaryDay(
        id: state.diaryDay!.id,
        status: state.diaryDay!.status,
        total: state.diaryDay!.totalScore,
        mean: state.diaryDay!.meanScore,
        median: state.diaryDay!.medianScore,
        level: state.diaryDay!.level,
        insight: insight,
      );

      _syncRepository.syncDay(state.date).catchError((e) {
        debugPrint("Background sync error: $e");
      });
    } catch (e) {
      // Fallback
      await _diaryRepository.updateDiaryDay(
        id: state.diaryDay!.id,
        status: state.diaryDay!.status,
        total: state.diaryDay!.totalScore,
        mean: state.diaryDay!.meanScore,
        median: state.diaryDay!.medianScore,
        level: state.diaryDay!.level,
        insight: "Échec de la génération de l'analyse IA : $e",
      );
      rethrow;
    }
  }

  Future<void> finalizeDay() async {
    if (state.diaryDay == null) return;
    
    // Calculate final scores first to ensure correctness
    final List<int> allValues = [];
    for (final r in state.responses) {
      if (state.activePeriods.contains('nuit')) allValues.addAll(_parseValues(r.nuitValues));
      if (state.activePeriods.contains('matin')) allValues.addAll(_parseValues(r.matinValues));
      if (state.activePeriods.contains('journee')) allValues.addAll(_parseValues(r.journeeValues));
      if (state.activePeriods.contains('soir')) allValues.addAll(_parseValues(r.soirValues));
    }

    final scoreResult = ScoreCalculator.calculate(allValues);
    
    final currentInsight = state.diaryDay?.insightText;
    final hasValidGeminiInsight = currentInsight != null &&
        currentInsight.isNotEmpty &&
        !currentInsight.startsWith("Aujourd'hui, votre score est") &&
        !currentInsight.startsWith("Journée finalisée avec un score") &&
        !currentInsight.contains("Échec de la génération");

    // Check if Gemini is enabled and configured, and if we should generate/regenerate on finalization
    final settings = _ref.read(settingsProvider);
    String insight;
    if (hasValidGeminiInsight) {
      insight = currentInsight;
    } else if (settings.useGemini && (settings.geminiMode == 'proxy' || settings.geminiApiKey.isNotEmpty)) {
      try {
        insight = await GeminiService.generateInsight(
          apiKey: settings.geminiApiKey,
          mode: settings.geminiMode,
          proxyUrl: settings.geminiProxyUrl,
          totalScore: scoreResult.total.toDouble(),
          meanScore: scoreResult.mean,
          medianScore: scoreResult.median,
          level: scoreResult.level,
          responses: state.responses,
          questions: state.questions,
        );
      } catch (e) {
        debugPrint("Gemini generation failed on finalization: $e");
        insight = state.diaryDay!.insightText ?? "Journée finalisée avec un score total de ${scoreResult.total} (${scoreResult.level}).";
      }
    } else {
      insight = "Journée finalisée avec un score total de ${scoreResult.total} (${scoreResult.level}). "
          "Pensez à bien observer vos corrélations quotidiennes.";
    }

    await _diaryRepository.updateDiaryDay(
      id: state.diaryDay!.id,
      status: 'finalized',
      total: scoreResult.total.toDouble(),
      mean: scoreResult.mean,
      median: scoreResult.median,
      level: scoreResult.level,
      insight: insight,
    );

    // Sync finalized entry in background
    _syncRepository.syncDay(state.date).catchError((e) {
      debugPrint("Background sync error: $e");
    });

    state = state.copyWith(currentQuestionIndex: 0);
  }
}

final diaryDateProvider = StateProvider<String>((ref) {
  // Default to today
  final now = DateTime.now();
  return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
});

final diaryControllerProvider = StateNotifierProvider.family<DiaryNotifier, DiaryState, String>((ref, date) {
  final repo = ref.watch(diaryRepositoryProvider);
  final syncRepo = ref.watch(syncRepositoryProvider);
  return DiaryNotifier(repo, syncRepo, ref, date);
});

final allDiaryDaysProvider = StreamProvider<List<DiaryDay>>((ref) {
  final repo = ref.watch(diaryRepositoryProvider);
  return repo.watchAllDiaryDays();
});

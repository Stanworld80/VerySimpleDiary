import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repository/diary_repository.dart';
import '../score_calculator.dart';
import '../../../core/db/local_database.dart';

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

final List<DiaryQuestion> diaryQuestionsList = [
  // 1. Santé, Sport & Sommeil
  const DiaryQuestion(number: 1, category: '1. Santé, Sport & Sommeil', title: 'SOMMEIL', description: 'Qualité de la nuit, endormissement, récupération...'),
  const DiaryQuestion(number: 2, category: '1. Santé, Sport & Sommeil', title: 'SPORT & MOUVEMENT', description: 'Activité physique, marche, étirements, tonus...'),
  const DiaryQuestion(number: 3, category: '1. Santé, Sport & Sommeil', title: 'ALIMENTATION', description: 'Qualité des repas, digestion, hydratation, excès...'),
  const DiaryQuestion(number: 4, category: '1. Santé, Sport & Sommeil', title: 'ÉNERGIE GLOBALE', description: 'Niveau de vitalité physique, fatigue générale...'),
  // 2. Émotions & Humeur
  const DiaryQuestion(number: 5, category: '2. Émotions & Humeur', title: 'JOIE & ENTHOUSIASME', description: 'Moments de bonheur, sourires, pensées positives...'),
  const DiaryQuestion(number: 6, category: '2. Émotions & Humeur', title: 'STRESS & ANXIÉTÉ', description: 'Tension mentale, inquiétude, paix d\'esprit...'),
  const DiaryQuestion(number: 7, category: '2. Émotions & Humeur', title: 'Patience & Calme', description: 'Réactivité émotionnelle, self-control, irritation...'),
  const DiaryQuestion(number: 8, category: '2. Émotions & Humeur', title: 'CONFIANCE EN SOI', description: 'Estime personnelle, sentiment de capacité...'),
  // 3. Mental & Productivité
  const DiaryQuestion(number: 9, category: '3. Mental & Productivité', title: 'CONCENTRATION', description: 'Focus, clarté mentale, capacité d\'attention...'),
  const DiaryQuestion(number: 10, category: '3. Mental & Productivité', title: 'EFFICACITÉ', description: 'Avancement des tâches, sentiment de devoir accompli...'),
  const DiaryQuestion(number: 11, category: '3. Mental & Productivité', title: 'APPRENTISSAGE', description: 'Nouvelles connaissances, curiosité, lectures...'),
  const DiaryQuestion(number: 12, category: '3. Mental & Productivité', title: 'ORGANISATION', description: 'Gestion du temps, planification, ordre...'),
  // 4. Social & Relations
  const DiaryQuestion(number: 13, category: '4. Social & Relations', title: 'RELATION PROCHES', description: 'Qualité des échanges en famille ou avec le/la partenaire...'),
  const DiaryQuestion(number: 14, category: '4. Social & Relations', title: 'AMITIÉS', description: 'Discussions, contacts, partages avec des amis...'),
  const DiaryQuestion(number: 15, category: '4. Social & Relations', title: 'TRAVAIL & COLLÈGUES', description: 'Climat professionnel, collaborations, échanges...'),
  const DiaryQuestion(number: 16, category: '4. Social & Relations', title: 'EMPATHIE', description: 'Écoute active, bienveillance envers autrui...'),
  // 5. Environnement & Cadre
  const DiaryQuestion(number: 17, category: '5. Environnement & Cadre', title: 'ORDRE & PROPRETÉ', description: 'Rangement de l\'espace de vie et de travail...'),
  const DiaryQuestion(number: 18, category: '5. Environnement & Cadre', title: 'MÉTÉO & NATURE', description: 'Lumière naturelle, temps passé dehors, grand air...'),
  const DiaryQuestion(number: 19, category: '5. Environnement & Cadre', title: 'CONFORT & SÉCURITÉ', description: 'Bien-être matériel, calme sonore, température...'),
  const DiaryQuestion(number: 20, category: '5. Environnement & Cadre', title: 'ÉCRANS & BADAUDAGE', description: 'Consommation digitale, réseaux sociaux, distraction...'),
  // 6. Loisirs & Épanouissement
  const DiaryQuestion(number: 21, category: '6. Loisirs & Épanouissement', title: 'PASSIONS & PROJETS', description: 'Temps dédié aux hobbies, projets personnels...'),
  const DiaryQuestion(number: 22, category: '6. Loisirs & Épanouissement', title: 'RELAXATION & LÂCHER-PRISE', description: 'Méditation, sieste, déconnexion totale...'),
  const DiaryQuestion(number: 23, category: '6. Loisirs & Épanouissement', title: 'CRÉATIVITÉ', description: 'Inspiration, expression artistique, résolution innovante...'),
  const DiaryQuestion(number: 24, category: '6. Loisirs & Épanouissement', title: 'GRATITUDE', description: 'Reconnaissance pour les bons moments de la journée...'),
];

class DiaryState {
  final String date;
  final DiaryDay? diaryDay;
  final List<DiaryResponse> responses;
  final int currentQuestionIndex;
  final Map<String, List<int>> currentSelection;

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
  });

  DiaryQuestion get currentQuestion => diaryQuestionsList[currentQuestionIndex];
  double get progressPercentage => ((currentQuestionIndex + 1) / diaryQuestionsList.length) * 100;

  DiaryState copyWith({
    String? date,
    DiaryDay? diaryDay,
    List<DiaryResponse>? responses,
    int? currentQuestionIndex,
    Map<String, List<int>>? currentSelection,
  }) {
    return DiaryState(
      date: date ?? this.date,
      diaryDay: diaryDay ?? this.diaryDay,
      responses: responses ?? this.responses,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      currentSelection: currentSelection ?? this.currentSelection,
    );
  }
}

class DiaryNotifier extends StateNotifier<DiaryState> {
  final DiaryRepository _diaryRepository;

  DiaryNotifier(this._diaryRepository, String date) : super(DiaryState(date: date)) {
    _init();
  }

  Future<void> _init() async {
    final day = await _diaryRepository.getOrCreateDiaryDay(state.date);
    state = state.copyWith(diaryDay: day);
    
    // Listen to updates for the day
    _diaryRepository.watchDiaryDay(state.date).listen((day) {
      if (day != null) {
        state = state.copyWith(diaryDay: day);
      }
    });

    // Listen to responses
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
      );
    } else {
      state = state.copyWith(
        currentSelection: const {
          'nuit': [],
          'matin': [],
          'journee': [],
          'soir': [],
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
      periodList.remove(rating);
    } else {
      periodList.add(rating);
    }
    
    currentSelection[period] = periodList;
    state = state.copyWith(currentSelection: currentSelection);
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
    );

    if (state.currentQuestionIndex < diaryQuestionsList.length - 1) {
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
      allValues.addAll(_parseValues(r.nuitValues));
      allValues.addAll(_parseValues(r.matinValues));
      allValues.addAll(_parseValues(r.journeeValues));
      allValues.addAll(_parseValues(r.soirValues));
    }

    final scoreResult = ScoreCalculator.calculate(allValues);
    
    // Auto-generate some dynamic summary description based on level
    final insight = "Aujourd'hui, votre score est ${scoreResult.level}. "
        "Vous avez cumulé un score total de ${scoreResult.total} "
        "avec une moyenne de ${scoreResult.mean.toStringAsFixed(2)}.";

    await _diaryRepository.updateDiaryDay(
      id: state.diaryDay!.id,
      status: state.diaryDay!.status, // keep current status ('draft')
      total: scoreResult.total.toDouble(),
      mean: scoreResult.mean,
      median: scoreResult.median,
      level: scoreResult.level,
      insight: insight,
    );
  }

  Future<void> finalizeDay() async {
    if (state.diaryDay == null) return;
    
    // Calculate final scores first to ensure correctness
    final List<int> allValues = [];
    for (final r in state.responses) {
      allValues.addAll(_parseValues(r.nuitValues));
      allValues.addAll(_parseValues(r.matinValues));
      allValues.addAll(_parseValues(r.journeeValues));
      allValues.addAll(_parseValues(r.soirValues));
    }

    final scoreResult = ScoreCalculator.calculate(allValues);
    final insight = "Journée finalisée avec un score total de ${scoreResult.total} (${scoreResult.level}). "
        "Pensez à bien observer vos corrélations quotidiennes.";

    await _diaryRepository.updateDiaryDay(
      id: state.diaryDay!.id,
      status: 'finalized',
      total: scoreResult.total.toDouble(),
      mean: scoreResult.mean,
      median: scoreResult.median,
      level: scoreResult.level,
      insight: insight,
    );

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
  return DiaryNotifier(repo, date);
});

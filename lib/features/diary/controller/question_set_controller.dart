import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/db/local_database.dart';
import '../repository/question_set_repository.dart';
import '../../../../core/config/settings_provider.dart';
import '../../../core/services/notification_service.dart';

class QuestionSetState {
  final List<QuestionSet> questionSets;
  final QuestionSet? activeSet;
  final List<CustomQuestion> activeSetQuestions;
  final bool isLoading;

  const QuestionSetState({
    this.questionSets = const [],
    this.activeSet,
    this.activeSetQuestions = const [],
    this.isLoading = false,
  });

  QuestionSetState copyWith({
    List<QuestionSet>? questionSets,
    QuestionSet? activeSet,
    List<CustomQuestion>? activeSetQuestions,
    bool? isLoading,
  }) {
    return QuestionSetState(
      questionSets: questionSets ?? this.questionSets,
      activeSet: activeSet ?? this.activeSet,
      activeSetQuestions: activeSetQuestions ?? this.activeSetQuestions,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class QuestionSetNotifier extends StateNotifier<QuestionSetState> {
  final QuestionSetRepository _repository;
  final Ref _ref;

  QuestionSetNotifier(this._repository, this._ref) : super(const QuestionSetState()) {
    _init();
  }

  Future<void> _init() async {
    state = state.copyWith(isLoading: true);
    await _repository.seedDefaultSetIfEmpty();
    
    // Watch all question sets
    _repository.watchAllQuestionSets().listen((sets) {
      state = state.copyWith(questionSets: sets);
      final active = sets.cast<QuestionSet?>().firstWhere((s) => s?.isActive == true, orElse: () => null);
      state = state.copyWith(activeSet: active);
      if (active != null) {
        _watchQuestionsForSet(active.id);
      }
    });
    
    state = state.copyWith(isLoading: false);
  }

  void _watchQuestionsForSet(String setId) {
    _repository.watchQuestionsForSet(setId).listen((questions) {
      state = state.copyWith(activeSetQuestions: questions);
    });
  }

  Future<void> selectActiveSet(String setId) async {
    await _repository.setActiveQuestionSet(setId);
    
    // Reschedule notifications if they are enabled
    final active = state.questionSets.cast<QuestionSet?>().firstWhere((s) => s?.id == setId, orElse: () => null);
    if (active != null) {
      state = state.copyWith(activeSet: active);
      final questions = await _repository.getQuestionsForSet(setId);
      state = state.copyWith(activeSetQuestions: questions);
      
      final settings = _ref.read(settingsProvider);
      if (settings.notificationsEnabled) {
        final periods = active.selectedPeriods.split(',').map((p) => p.trim()).where((p) => p.isNotEmpty).toList();
        await NotificationService.schedulePeriodNotifications(activePeriods: periods);
      }
    }
  }

  Future<String> createSet(String name, List<String> periods) async {
    final newId = await _repository.createQuestionSet(name, periods);
    return newId;
  }

  Future<void> duplicateSet(String sourceSetId, String newName) async {
    final questions = await _repository.getQuestionsForSet(sourceSetId);
    final sourceSet = state.questionSets.firstWhere((s) => s.id == sourceSetId);
    
    final newSetId = DateTime.now().millisecondsSinceEpoch.toString();
    final newSet = QuestionSet(
      id: newSetId,
      name: newName,
      isActive: false,
      selectedPeriods: sourceSet.selectedPeriods,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    await _repository.saveQuestionSet(newSet);
    
    for (final q in questions) {
      final newQuestion = CustomQuestion(
        id: '${newSetId}_q_${q.number}',
        setId: newSetId,
        number: q.number,
        category: q.category,
        title: q.title,
        description: q.description,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _repository.saveCustomQuestion(newQuestion);
    }
  }

  Future<void> updateSetPeriods(String setId, List<String> periods) async {
    final set = state.questionSets.firstWhere((s) => s.id == setId);
    final updatedSet = QuestionSet(
      id: set.id,
      name: set.name,
      isActive: set.isActive,
      selectedPeriods: periods.join(','),
      createdAt: set.createdAt,
      updatedAt: DateTime.now(),
    );
    await _repository.saveQuestionSet(updatedSet);
  }

  Future<void> renameSet(String setId, String newName) async {
    final set = state.questionSets.firstWhere((s) => s.id == setId);
    final updatedSet = QuestionSet(
      id: set.id,
      name: newName,
      isActive: set.isActive,
      selectedPeriods: set.selectedPeriods,
      createdAt: set.createdAt,
      updatedAt: DateTime.now(),
    );
    await _repository.saveQuestionSet(updatedSet);
  }

  Future<void> deleteSet(String setId) async {
    final set = state.questionSets.firstWhere((s) => s.id == setId);
    if (set.isActive) {
      // Find another set to make active, e.g. default system set
      final fallback = state.questionSets.firstWhere((s) => s.id != setId, orElse: () => set);
      if (fallback.id != setId) {
        await selectActiveSet(fallback.id);
      }
    }
    await _repository.deleteQuestionSet(setId);
  }

  Future<void> addQuestion(String setId, String category, String title, String description) async {
    await _repository.addQuestionToSet(
      setId: setId,
      category: category,
      title: title,
      description: description,
    );
  }

  Future<void> removeQuestion(String questionId) async {
    await _repository.removeQuestionFromSet(questionId);
  }

  Future<void> editQuestion(CustomQuestion question) async {
    await _repository.saveCustomQuestion(question);
  }
}

final questionSetControllerProvider = StateNotifierProvider<QuestionSetNotifier, QuestionSetState>((ref) {
  final repo = ref.watch(questionSetRepositoryProvider);
  return QuestionSetNotifier(repo, ref);
});

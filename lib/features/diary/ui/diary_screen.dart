import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controller/diary_controller.dart';
import 'summary_screen.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/version_footer.dart';
import '../../../core/ui/profile_menu_button.dart';

class DiaryScreen extends ConsumerWidget {
  const DiaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(diaryDateProvider);
    final diaryState = ref.watch(diaryControllerProvider(selectedDate));
    final notifier = ref.read(diaryControllerProvider(selectedDate).notifier);

    if (diaryState.diaryDay == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currentQuestion = diaryState.currentQuestion;

    final List<String> periods = ['nuit', 'matin', 'journee', 'soir'];
    final Map<String, String> periodLabels = {
      'nuit': 'Nuit (00h-05h)',
      'matin': 'Matin (05h-11h)',
      'journee': 'Journée (11h-17h)',
      'soir': 'Soir (17h-00h)',
    };
    final List<int> ratings = [-2, -1, 0, 1, 2];

    return Scaffold(
      appBar: AppBar(
        title: Text(currentQuestion.category),
        leading: diaryState.currentQuestionIndex > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => notifier.prevQuestion(),
              )
            : null,
        actions: [
          Center(
            child: Text(
              'Q ${currentQuestion.number} / ${diaryQuestionsList.length}',
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
            ),
          ),
          const ProfileMenuButton(),
        ],
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragEnd: (details) async {
          if (details.primaryVelocity == null) return;
          if (details.primaryVelocity! < -300) {
            // Swipe left -> Next question
            await notifier.nextQuestion();
            if (context.mounted && currentQuestion.number == diaryQuestionsList.length) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SummaryScreen(date: selectedDate),
                ),
              );
            }
          } else if (details.primaryVelocity! > 300) {
            // Swipe right -> Prev question
            if (diaryState.currentQuestionIndex > 0) {
              notifier.prevQuestion();
            }
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Linear progress bar
            LinearProgressIndicator(
              value: diaryState.progressPercentage / 100,
              backgroundColor: const Color(0xFF2E3047),
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
              minHeight: 6,
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    
                    // Question Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.darkCard,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF2E3047)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            currentQuestion.title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            currentQuestion.description,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Grid Header
                    const Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            'PÉRIODE',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 7,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('-2', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text('-1', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text('0', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text('+1', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text('+2', style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: Color(0xFF2E3047), height: 24),
                    
                    // Time Periods Rows
                    ...periods.map((period) {
                      final selectedRatings = diaryState.currentSelection[period] ?? [];
                      final comment = diaryState.currentComments[period] ?? '';
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: InkWell(
                                onTap: () {
                                  _showCommentDialog(
                                    context,
                                    ref,
                                    period,
                                    periodLabels[period]!,
                                    comment,
                                    notifier,
                                  );
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        periodLabels[period]!,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.chat_bubble_outline_rounded,
                                            size: 10,
                                            color: comment.isNotEmpty
                                                ? AppTheme.primaryLight
                                                : AppTheme.textSecondary.withValues(alpha: 0.5),
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              comment.isNotEmpty ? comment : 'Ajouter...',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontStyle: comment.isNotEmpty
                                                    ? FontStyle.normal
                                                    : FontStyle.italic,
                                                color: comment.isNotEmpty
                                                    ? AppTheme.textPrimary
                                                    : AppTheme.textSecondary.withValues(alpha: 0.5),
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 7,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: ratings.map((rating) {
                                  final isSelected = selectedRatings.contains(rating);
                                  return GestureDetector(
                                    onTap: () => notifier.toggleRating(period, rating),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 150),
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isSelected
                                            ? AppTheme.primary.withValues(alpha: 0.2)
                                            : Colors.transparent,
                                        border: Border.all(
                                          color: isSelected
                                              ? AppTheme.primary
                                              : const Color(0xFF2E3047),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Center(
                                        child: SizedBox(
                                          height: 16,
                                          width: 16,
                                          child: isSelected
                                              ? const Icon(
                                                  Icons.circle,
                                                  size: 10,
                                                  color: AppTheme.primary,
                                                )
                                              : null,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            
            // Next / Validate Button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: ElevatedButton(
                onPressed: () async {
                  await notifier.nextQuestion();
                  if (context.mounted && currentQuestion.number == diaryQuestionsList.length) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => SummaryScreen(date: selectedDate),
                      ),
                    );
                  }
                },
                child: Text(
                  currentQuestion.number < diaryQuestionsList.length ? 'SUIVANT >' : 'RÉCAPITULATIF >',
                ),
              ),
            ),
            const VersionFooter(),
          ],
        ),
      ),
    );
  }
}

void _showCommentDialog(
  BuildContext context,
  WidgetRef ref,
  String period,
  String periodLabel,
  String currentComment,
  DiaryNotifier notifier,
) {
  final controller = TextEditingController(text: currentComment);
  
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: AppTheme.darkSurface,
        title: Text(
          'Commentaire - $periodLabel',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: controller,
              maxLength: 64,
              maxLines: 2,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Saisir un commentaire (64 car. max)...',
                hintStyle: TextStyle(color: AppTheme.textSecondary.withValues(alpha: 0.5)),
                counterStyle: const TextStyle(color: AppTheme.textSecondary),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF2E3047)),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.primary),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ANNULER', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(100, 44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              notifier.setComment(period, controller.text);
              Navigator.of(context).pop();
            },
            child: const Text('VALIDER'),
          ),
        ],
      );
    },
  );
}

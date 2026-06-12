import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controller/diary_controller.dart';
import 'summary_screen.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/version_footer.dart';

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
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                'Q ${currentQuestion.number} / 24',
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
              ),
            ),
          )
        ],
      ),
      body: Column(
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
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              periodLabels[period]!,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
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
                if (context.mounted && currentQuestion.number == 24) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SummaryScreen(date: selectedDate),
                    ),
                  );
                }
              },
              child: Text(
                currentQuestion.number < 24 ? 'SUIVANT >' : 'RÉCAPITULATIF >',
              ),
            ),
          ),
          const VersionFooter(),
        ],
      ),
    );
  }
}

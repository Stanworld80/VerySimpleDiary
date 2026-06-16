import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controller/diary_controller.dart';
import '../../../core/db/local_database.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/version_footer.dart';
import '../../../core/ui/profile_menu_button.dart';

class SummaryScreen extends ConsumerWidget {
  final String date;

  const SummaryScreen({super.key, required this.date});

  Color _getLevelColor(String level) {
    switch (level) {
      case 'Optimal':
        return AppTheme.levelOptimal;
      case 'Bon':
        return AppTheme.levelBon;
      case 'Moyen':
        return AppTheme.levelMoyen;
      case 'Nul':
        return AppTheme.levelNul;
      case 'Négatif':
        return AppTheme.levelNegatif;
      default:
        return AppTheme.levelMoyen;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diaryState = ref.watch(diaryControllerProvider(date));
    final notifier = ref.read(diaryControllerProvider(date).notifier);

    final day = diaryState.diaryDay;
    if (day == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final levelColor = _getLevelColor(day.level);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Récapitulatif Final'),
        actions: const [
          ProfileMenuButton(),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Circular level ring or big score display
            Center(
              child: Container(
                height: 140,
                width: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: levelColor, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: levelColor.withValues(alpha: 0.15),
                      blurRadius: 30,
                      spreadRadius: 5,
                    )
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        day.meanScore.toStringAsFixed(2),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        'Moyenne',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Level name
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: levelColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: levelColor.withValues(alpha: 0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, color: levelColor, size: 12),
                    const SizedBox(width: 8),
                    Text(
                      day.level,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: levelColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Scores metrics row
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    title: 'Score Total',
                    value: day.totalScore.toStringAsFixed(0),
                    icon: Icons.functions_rounded,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _MetricCard(
                    title: 'Médiane',
                    value: day.medianScore.toStringAsFixed(1),
                    icon: Icons.equalizer_rounded,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            const Text(
              'RÉPONSES AUX 24 QUESTIONS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.textSecondary,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: diaryQuestionsList.length,
                itemBuilder: (context, index) {
                  final question = diaryQuestionsList[index];
                  final response = diaryState.responses.cast<DiaryResponse?>().firstWhere(
                    (r) => r?.questionNumber == question.number,
                    orElse: () => null,
                  );
                  
                  List<int> parseVals(String valStr) {
                    if (valStr.trim().isEmpty) return [];
                    return valStr.split(',').map((e) => int.tryParse(e) ?? 0).toList();
                  }

                  final Map<String, List<int>> selections = response != null ? {
                    'nuit': parseVals(response.nuitValues),
                    'matin': parseVals(response.matinValues),
                    'journee': parseVals(response.journeeValues),
                    'soir': parseVals(response.soirValues),
                  } : {
                    'nuit': [],
                    'matin': [],
                    'journee': [],
                    'soir': [],
                  };
                  
                  final Map<String, String> comments = response != null ? {
                    'nuit': response.nuitComment,
                    'matin': response.matinComment,
                    'journee': response.journeeComment,
                    'soir': response.soirComment,
                  } : {
                    'nuit': '',
                    'matin': '',
                    'journee': '',
                    'soir': '',
                  };

                  final hasAnyData = selections.values.any((l) => l.isNotEmpty) || comments.values.any((s) => s.isNotEmpty);

                  return Container(
                    width: 220,
                    margin: const EdgeInsets.only(right: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.darkCard,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF2E3047), width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Q${question.number}. ${question.title}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          question.category.substring(question.category.indexOf('.') + 1).trim(),
                          style: TextStyle(
                            fontSize: 10,
                            color: AppTheme.primaryLight.withOpacity(0.8),
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Divider(color: Color(0xFF2E3047), height: 16),
                        Expanded(
                          child: !hasAnyData
                              ? const Center(
                                  child: Text(
                                    'Aucune réponse',
                                    style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppTheme.textSecondary),
                                  ),
                                )
                              : ListView(
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding: EdgeInsets.zero,
                                  children: ['nuit', 'matin', 'journee', 'soir'].map((p) {
                                    final ratings = selections[p] ?? [];
                                    final comment = comments[p] ?? '';
                                    if (ratings.isEmpty && comment.isEmpty) return const SizedBox.shrink();
                                    
                                    final label = p == 'nuit' ? 'Nuit' : p == 'matin' ? 'Matin' : p == 'journee' ? 'Journée' : 'Soir';

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '$label: ',
                                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                if (ratings.isNotEmpty)
                                                  Text(
                                                    ratings.map((r) => r > 0 ? '+$r' : '$r').join(', '),
                                                    style: const TextStyle(fontSize: 11, color: AppTheme.primaryLight, fontWeight: FontWeight.bold),
                                                  ),
                                                if (comment.isNotEmpty)
                                                  Text(
                                                    '"$comment"',
                                                    style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: Colors.white.withOpacity(0.7)),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Summary insight card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.darkCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF2E3047)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Analyse de la journée',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    day.insightText ?? 'Aucun détail généré pour cette journée.',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 60),

            // Finalize Button
            ElevatedButton.icon(
              onPressed: () async {
                await notifier.finalizeDay();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Journée validée et enregistrée !'),
                      backgroundColor: AppTheme.levelOptimal,
                    ),
                  );
                  // Go back to diary screen starting point
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              },
              icon: const Icon(Icons.check_circle_rounded),
              label: const Text('Valider la journée'),
              style: ElevatedButton.styleFrom(
                backgroundColor: levelColor,
              ),
            ),
            const SizedBox(height: 24),
            const VersionFooter(),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2E3047)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primary, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

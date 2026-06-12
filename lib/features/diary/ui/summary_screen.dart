import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controller/diary_controller.dart';
import '../../../core/theme/app_theme.dart';

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
        automaticallyImplyLeading: false,
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
                      color: levelColor.withOpacity(0.15),
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
                  color: levelColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: levelColor.withOpacity(0.5)),
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
                  Navigator.of(context).pop();
                }
              },
              icon: const Icon(Icons.check_circle_rounded),
              label: const Text('Valider la journée'),
              style: ElevatedButton.styleFrom(
                backgroundColor: levelColor,
              ),
            ),
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

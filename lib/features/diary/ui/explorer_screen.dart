import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controller/diary_controller.dart';
import 'summary_screen.dart';
import 'diary_screen.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/db/local_database.dart';
import '../../../core/ui/profile_menu_button.dart';

class ExplorerScreen extends ConsumerStatefulWidget {
  const ExplorerScreen({super.key});

  @override
  ConsumerState<ExplorerScreen> createState() => _ExplorerScreenState();
}

class _ExplorerScreenState extends ConsumerState<ExplorerScreen> {
  String _selectedStatus = 'All'; // 'All', 'draft', 'finalized'
  String _selectedLevel = 'All'; // 'All', 'Optimal', 'Bon', 'Moyen', 'Nul', 'Négatif'

  String _formatDisplayDate(String dateStr) {
    try {
      final parts = dateStr.split('-');
      if (parts.length == 3) {
        return "${parts[2]}/${parts[1]}/${parts[0]}";
      }
    } catch (_) {}
    return dateStr;
  }

  Color _getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'optimal':
        return AppTheme.levelOptimal;
      case 'bon':
        return AppTheme.levelBon;
      case 'moyen':
        return AppTheme.levelMoyen;
      case 'nul':
        return AppTheme.levelNul;
      case 'négatif':
      case 'negatif':
        return AppTheme.levelNegatif;
      default:
        return AppTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final daysAsync = ref.watch(allDiaryDaysProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explorer les Données'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: const [
          ProfileMenuButton(),
        ],
      ),
      body: daysAsync.when(
        data: (days) {
          // Apply filters
          final filteredDays = days.where((day) {
            final matchesStatus = _selectedStatus == 'All' || day.status == _selectedStatus;
            final matchesLevel = _selectedLevel == 'All' || day.level == _selectedLevel;
            return matchesStatus && matchesLevel;
          }).toList();

          // Calculations
          final totalCount = filteredDays.length;
          final finalizedDays = filteredDays.where((d) => d.status == 'finalized').toList();
          final averageScore = finalizedDays.isEmpty
              ? 0.0
              : finalizedDays.map((d) => d.meanScore).reduce((a, b) => a + b) / finalizedDays.length;

          // Level breakdown
          final levelCounts = <String, int>{};
          for (final d in filteredDays) {
            levelCounts[d.level] = (levelCounts[d.level] ?? 0) + 1;
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Dashboard Metrics Header Card
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E2030), Color(0xFF161722)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFF2E3047), width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'STATISTIQUES GLOBALES',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textSecondary,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildMetricCard(
                              'Jours suivis',
                              '$totalCount',
                              Icons.calendar_today_rounded,
                              Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildMetricCard(
                              'Score moyen',
                              averageScore.toStringAsFixed(2),
                              Icons.analytics_rounded,
                              AppTheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Horizontal Filters UI
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    // Status filters
                    _buildFilterChip('Statut : Tout', _selectedStatus == 'All', () {
                      setState(() => _selectedStatus = 'All');
                    }),
                    const SizedBox(width: 8),
                    _buildFilterChip('Brouillons', _selectedStatus == 'draft', () {
                      setState(() => _selectedStatus = 'draft');
                    }),
                    const SizedBox(width: 8),
                    _buildFilterChip('Finalisés', _selectedStatus == 'finalized', () {
                      setState(() => _selectedStatus = 'finalized');
                    }),
                    
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('|', style: TextStyle(color: Color(0xFF2E3047))),
                    ),

                    // Level filters
                    _buildFilterChip('Niveau : Tout', _selectedLevel == 'All', () {
                      setState(() => _selectedLevel = 'All');
                    }),
                    const SizedBox(width: 8),
                    ...['Optimal', 'Bon', 'Moyen', 'Nul', 'Négatif'].map((level) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: _buildFilterChip(
                          level,
                          _selectedLevel == level,
                          () => setState(() => _selectedLevel = level),
                          activeColor: _getLevelColor(level),
                        ),
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Entries List
              Expanded(
                child: filteredDays.isEmpty
                    ? const Center(
                        child: Text(
                          'Aucune donnée ne correspond à vos filtres.',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: filteredDays.length,
                        itemBuilder: (context, index) {
                          final day = filteredDays[index];
                          final isDraft = day.status == 'draft';
                          final dateText = _formatDisplayDate(day.date);

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              title: Row(
                                children: [
                                  Text(
                                    dateText,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  if (isDraft)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: Colors.orange.withValues(alpha: 0.5)),
                                      ),
                                      child: const Text(
                                        'BROUILLON',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  day.insightText ?? 'Aucune note explicative enregistrée.',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 13, height: 1.3),
                                ),
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _getLevelColor(day.level).withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: _getLevelColor(day.level).withValues(alpha: 0.5)),
                                    ),
                                    child: Text(
                                      day.level,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: _getLevelColor(day.level),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Score: ${day.totalScore.toInt()}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () {
                                if (isDraft) {
                                  ref.read(diaryDateProvider.notifier).state = day.date;
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => const DiaryScreen()),
                                  );
                                } else {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => SummaryScreen(date: day.date)),
                                  );
                                }
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erreur: $err')),
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2030),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2E3047)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap, {Color? activeColor}) {
    final themeColor = activeColor ?? AppTheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? themeColor.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? themeColor : const Color(0xFF2E3047),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? themeColor : AppTheme.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

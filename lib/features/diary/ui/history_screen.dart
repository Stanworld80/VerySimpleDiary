import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controller/diary_controller.dart';
import '../repository/diary_repository.dart';
import '../repository/sync_repository.dart';
import '../../../core/db/local_database.dart';
import 'diary_screen.dart';
import 'summary_screen.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/profile_menu_button.dart';
import '../../../core/ui/version_footer.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  String _selectedStatus = 'All'; // 'All', 'draft', 'finalized'
  String? _highlightedDate;

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

  void _showEditConfirmation(BuildContext context, DiaryDay day) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: AppTheme.darkCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFF2E3047), width: 1.5),
          ),
          title: const Text(
            'Modifier cette journée ?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Cette action va repasser cette journée en brouillon et ouvrir le questionnaire pour la journée du ${_formatDisplayDate(day.date)}. Confirmer ?',
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Annuler', style: TextStyle(color: AppTheme.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                minimumSize: const Size(100, 40),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onPressed: () async {
                Navigator.of(ctx).pop();
                
                if (day.status == 'finalized') {
                  await ref.read(diaryRepositoryProvider).updateDiaryDay(
                    id: day.id,
                    status: 'draft',
                    total: day.totalScore,
                    mean: day.meanScore,
                    median: day.medianScore,
                    level: day.level,
                    insight: day.insightText,
                  );
                  await ref.read(syncRepositoryProvider).syncDay(day.date);
                }

                ref.read(diaryDateProvider.notifier).state = day.date;
                if (context.mounted) {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const DiaryScreen()),
                  );
                }
              },
              child: const Text('Confirmer'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, DiaryDay day) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: AppTheme.darkCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFF2E3047), width: 1.5),
          ),
          title: const Text(
            'Supprimer cette journée ?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Attention, cette action est irréversible et supprimera définitivement toutes les données saisies pour le ${_formatDisplayDate(day.date)} (locale et cloud). Confirmer ?',
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Annuler', style: TextStyle(color: AppTheme.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.levelNegatif,
                minimumSize: const Size(100, 40),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onPressed: () async {
                Navigator.of(ctx).pop();
                
                await ref.read(syncRepositoryProvider).deleteDay(day.date);
                
                setState(() {
                  if (_highlightedDate == day.date) {
                    _highlightedDate = null;
                  }
                });

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('La journée du ${_formatDisplayDate(day.date)} a été supprimée.'),
                      backgroundColor: AppTheme.levelNegatif,
                    ),
                  );
                }
              },
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHighlightedDayChoices(DiaryState? diaryState) {
    if (diaryState == null || diaryState.diaryDay == null) {
      return const SizedBox.shrink();
    }
    
    final dateText = _formatDisplayDate(diaryState.date);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.darkCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF2E3047), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'ACTIONS POUR LE $dateText',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textSecondary,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Score: ${diaryState.diaryDay!.totalScore.toInt()}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _getLevelColor(diaryState.diaryDay!.level),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 18, color: AppTheme.primaryLight),
                      tooltip: 'Modifier / Repasser en brouillon',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => _showEditConfirmation(context, diaryState.diaryDay!),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppTheme.levelNegatif),
                      tooltip: 'Supprimer',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => _showDeleteConfirmation(context, diaryState.diaryDay!),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 140,
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
                    width: 180,
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.darkSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF2E3047)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Q${question.number}. ${question.title}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Divider(color: Color(0xFF2E3047), height: 12),
                        Expanded(
                          child: !hasAnyData
                              ? const Center(
                                  child: Text(
                                    'Aucune réponse',
                                    style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: AppTheme.textSecondary),
                                  ),
                                )
                              : ListView(
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding: EdgeInsets.zero,
                                  children: ['nuit', 'matin', 'journee', 'soir'].map((p) {
                                    final ratings = selections[p] ?? [];
                                    final comment = comments[p] ?? '';
                                    if (ratings.isEmpty && comment.isEmpty) return const SizedBox.shrink();

                                    final label = p == 'nuit' ? 'Nui' : p == 'matin' ? 'Mat' : p == 'journee' ? 'Jrn' : 'Soi';

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 1.0),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '$label: ',
                                            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                if (ratings.isNotEmpty)
                                                  Text(
                                                    ratings.map((r) => r > 0 ? '+$r' : '$r').join(', '),
                                                    style: const TextStyle(fontSize: 9, color: AppTheme.primaryLight, fontWeight: FontWeight.bold),
                                                  ),
                                                if (comment.isNotEmpty)
                                                  Text(
                                                    '"$comment"',
                                                    style: TextStyle(fontSize: 8, fontStyle: FontStyle.italic, color: Colors.white.withValues(alpha: 0.6)),
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
          ],
        ),
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

  @override
  Widget build(BuildContext context) {
    final daysAsync = ref.watch(allDiaryDaysProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique & Modifications'),
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
          final filteredDays = days.where((day) {
            return _selectedStatus == 'All' || day.status == _selectedStatus;
          }).toList();

          if (_highlightedDate == null && filteredDays.isNotEmpty) {
            _highlightedDate = filteredDays.first.date;
          }

          final highlightedState = _highlightedDate != null
              ? ref.watch(diaryControllerProvider(_highlightedDate!))
              : null;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info Banner
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.darkCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF2E3047)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline_rounded, color: AppTheme.primaryLight, size: 24),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Sélectionnez une journée pour la modifier (repasser en brouillon) ou la supprimer définitivement.',
                          style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Filter Chips Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    _buildFilterChip('Tout l\'historique', _selectedStatus == 'All', () {
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
                  ],
                ),
              ),

              // Action choices for highlighted date
              if (highlightedState != null)
                _buildHighlightedDayChoices(highlightedState),

              const Padding(
                padding: EdgeInsets.only(left: 16.0, top: 16.0, bottom: 8.0),
                child: Text(
                  'JOURNAUX ENREGISTRÉS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textSecondary,
                    letterSpacing: 1.2,
                  ),
                ),
              ),

              Expanded(
                child: filteredDays.isEmpty
                    ? const Center(
                        child: Text(
                          'Aucune journée enregistrée.',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: filteredDays.length,
                        itemBuilder: (context, index) {
                          final day = filteredDays[index];
                          final isDraft = day.status == 'draft';
                          final dateText = _formatDisplayDate(day.date);
                          final isHighlighted = _highlightedDate == day.date;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: isHighlighted ? AppTheme.primary : const Color(0xFF2E3047),
                                width: isHighlighted ? 2.0 : 1.0,
                              ),
                            ),
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
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Column(
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
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(Icons.edit_note_rounded, size: 22, color: AppTheme.primaryLight),
                                    tooltip: 'Modifier',
                                    onPressed: () {
                                      _showEditConfirmation(context, day);
                                    },
                                  ),
                                ],
                              ),
                              onTap: () {
                                setState(() {
                                  _highlightedDate = day.date;
                                });
                              },
                            ),
                          );
                        },
                      ),
              ),
              const VersionFooter(),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erreur: $err')),
      ),
    );
  }
}

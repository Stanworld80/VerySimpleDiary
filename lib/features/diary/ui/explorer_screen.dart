import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controller/diary_controller.dart';
import '../repository/diary_repository.dart';
import '../repository/sync_repository.dart';
import '../../../core/db/local_database.dart';
import 'summary_screen.dart';
import 'diary_screen.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/profile_menu_button.dart';

class ExplorerScreen extends ConsumerStatefulWidget {
  const ExplorerScreen({super.key});

  @override
  ConsumerState<ExplorerScreen> createState() => _ExplorerScreenState();
}

class _ExplorerScreenState extends ConsumerState<ExplorerScreen> {
  String _selectedStatus = 'All'; // 'All', 'draft', 'finalized'
  String _selectedLevel = 'All'; // 'All', 'Optimal', 'Bon', 'Moyen', 'Nul', 'Négatif'

  String? _highlightedDate;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _useMean = true; // true = Moyenne, false = Médiane

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _startDate = now.subtract(const Duration(days: 30));
    _endDate = now;
  }

  String _formatDate(DateTime dt) {
    return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}";
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
        if (_endDate != null && _startDate!.isAfter(_endDate!)) {
          _endDate = _startDate;
        }
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
        if (_startDate != null && _endDate!.isBefore(_startDate!)) {
          _startDate = _endDate;
        }
      });
    }
  }

  double _calculateMedian(List<int> values) {
    if (values.isEmpty) return 0.0;
    final sorted = List<int>.from(values)..sort();
    final middle = sorted.length ~/ 2;
    if (sorted.length % 2 == 1) {
      return sorted[middle].toDouble();
    } else {
      return (sorted[middle - 1] + sorted[middle]) / 2.0;
    }
  }

  Widget _buildToggleOption(String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.white : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodStatsCarousel(WidgetRef ref, List<DiaryDay> days) {
    final responsesAsync = ref.watch(allResponsesProvider);

    return responsesAsync.when(
      data: (allResponses) {
        final Map<String, String> dayIdToDate = {
          for (var d in days) d.id: d.date
        };

        final inRangeResponses = allResponses.where((resp) {
          final dateStr = dayIdToDate[resp.diaryDayId];
          if (dateStr == null) return false;
          try {
            final date = DateTime.parse(dateStr);
            final checkDate = DateTime(date.year, date.month, date.day);
            final start = _startDate != null ? DateTime(_startDate!.year, _startDate!.month, _startDate!.day) : null;
            final end = _endDate != null ? DateTime(_endDate!.year, _endDate!.month, _endDate!.day) : null;
            if (start != null && checkDate.isBefore(start)) return false;
            if (end != null && checkDate.isAfter(end)) return false;
            return true;
          } catch (_) {
            return false;
          }
        }).toList();

        List<int> parseVals(String valStr) {
          if (valStr.trim().isEmpty) return [];
          return valStr.split(',').map((e) => int.tryParse(e) ?? 0).toList();
        }

        final Map<int, List<int>> questionValues = {};
        for (int i = 1; i <= 24; i++) {
          questionValues[i] = [];
        }

        for (final resp in inRangeResponses) {
          final vals = [
            ...parseVals(resp.nuitValues),
            ...parseVals(resp.matinValues),
            ...parseVals(resp.journeeValues),
            ...parseVals(resp.soirValues),
          ];
          questionValues[resp.questionNumber]?.addAll(vals);
        }

        return SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: diaryQuestionsList.length,
            itemBuilder: (context, index) {
              final question = diaryQuestionsList[index];
              final values = questionValues[question.number] ?? [];
              
              String displayVal;
              double scoreNum = 0.0;
              if (values.isEmpty) {
                displayVal = '—';
              } else {
                if (_useMean) {
                  scoreNum = values.reduce((a, b) => a + b) / values.length;
                  displayVal = scoreNum.toStringAsFixed(2);
                } else {
                  scoreNum = _calculateMedian(values);
                  displayVal = scoreNum.toStringAsFixed(1);
                }
                if (scoreNum > 0) displayVal = '+$displayVal';
              }

              Color scoreColor;
              if (values.isEmpty) {
                scoreColor = AppTheme.textSecondary;
              } else if (scoreNum >= 1.5) {
                scoreColor = AppTheme.levelOptimal;
              } else if (scoreNum >= 0.5) {
                scoreColor = AppTheme.levelBon;
              } else if (scoreNum >= -0.5) {
                scoreColor = AppTheme.levelMoyen;
              } else if (scoreNum >= -1.5) {
                scoreColor = AppTheme.levelNul;
              } else {
                scoreColor = AppTheme.levelNegatif;
              }

              return Container(
                width: 150,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.darkSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF2E3047)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          displayVal,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: scoreColor,
                          ),
                        ),
                        Icon(
                          _useMean ? Icons.analytics_rounded : Icons.equalizer_rounded,
                          color: AppTheme.textSecondary.withValues(alpha: 0.4),
                          size: 16,
                        ),
                      ],
                    ),
                    Text(
                      values.isEmpty ? 'Aucun vote' : '${values.length} votes',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
      loading: () => const SizedBox(
        height: 110,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => SizedBox(
        height: 110,
        child: Center(child: Text('Erreur: $err', style: const TextStyle(fontSize: 11))),
      ),
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
                    'CHOIX DU $dateText',
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
                      icon: const Icon(Icons.edit_outlined, size: 16, color: AppTheme.primaryLight),
                      tooltip: 'Modifier',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => _showEditConfirmation(context, diaryState.diaryDay!),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, size: 16, color: AppTheme.levelNegatif),
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

          // Set default highlighted date if not yet initialized or if it was cleared
          if (_highlightedDate == null && filteredDays.isNotEmpty) {
            _highlightedDate = filteredDays.first.date;
          }

          final highlightedState = _highlightedDate != null
              ? ref.watch(diaryControllerProvider(_highlightedDate!))
              : null;

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

              // Scrollable area for lists and stats
              Expanded(
                child: filteredDays.isEmpty
                    ? const Center(
                        child: Text(
                          'Aucune donnée ne correspond à vos filtres.',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      )
                    : CustomScrollView(
                        slivers: [
                          // 1. Period Stats Card
                          SliverToBoxAdapter(
                            child: Padding(
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
                                        const Text(
                                          'ÉVOLUTION SUR PÉRIODE',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.textSecondary,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: AppTheme.darkBg,
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: const Color(0xFF2E3047)),
                                          ),
                                          child: Row(
                                            children: [
                                              _buildToggleOption('Moyenne', _useMean, () {
                                                setState(() => _useMean = true);
                                              }),
                                              _buildToggleOption('Médiane', !_useMean, () {
                                                setState(() => _useMean = false);
                                              }),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            onPressed: () => _selectStartDate(context),
                                            icon: const Icon(Icons.date_range_rounded, size: 16),
                                            label: Text(
                                              _startDate != null ? 'De: ${_formatDate(_startDate!)}' : 'De...',
                                              style: const TextStyle(fontSize: 12),
                                            ),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: Colors.white,
                                              side: const BorderSide(color: Color(0xFF2E3047)),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                              padding: const EdgeInsets.symmetric(vertical: 8),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            onPressed: () => _selectEndDate(context),
                                            icon: const Icon(Icons.date_range_rounded, size: 16),
                                            label: Text(
                                              _endDate != null ? 'À: ${_formatDate(_endDate!)}' : 'À...',
                                              style: const TextStyle(fontSize: 12),
                                            ),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: Colors.white,
                                              side: const BorderSide(color: Color(0xFF2E3047)),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                              padding: const EdgeInsets.symmetric(vertical: 8),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    _buildPeriodStatsCarousel(ref, days),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          
                          // 2. Highlighted Day Choices Card
                          SliverToBoxAdapter(
                            child: _buildHighlightedDayChoices(highlightedState),
                          ),
                          
                          // 3. Section Title for entries
                          const SliverToBoxAdapter(
                            child: Padding(
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
                          ),
                          
                          // 4. Entries list
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
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
                                            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppTheme.textSecondary),
                                            onPressed: () {
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
                                childCount: filteredDays.length,
                              ),
                            ),
                          ),
                        ],
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controller/diary_controller.dart';
import '../repository/diary_repository.dart';
import '../../../core/db/local_database.dart';
import 'summary_screen.dart';
// diary_screen.dart removed since modification is separated
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

  Widget _buildPeriodThemesStatsCarousel(WidgetRef ref, List<DiaryDay> days) {
    final responsesAsync = ref.watch(allResponsesProvider);

    return responsesAsync.when(
      data: (allResponses) {
        final Map<String, String> dayIdToDate = {
          for (var d in days) d.id: d.date
        };

        final String? startDateStr = _startDate != null
            ? "${_startDate!.year.toString().padLeft(4, '0')}-${_startDate!.month.toString().padLeft(2, '0')}-${_startDate!.day.toString().padLeft(2, '0')}"
            : null;
        final String? endDateStr = _endDate != null
            ? "${_endDate!.year.toString().padLeft(4, '0')}-${_endDate!.month.toString().padLeft(2, '0')}-${_endDate!.day.toString().padLeft(2, '0')}T23:59:59"
            : null;

        final inRangeResponses = allResponses.where((resp) {
          final dateStr = dayIdToDate[resp.diaryDayId];
          if (dateStr == null) return false;
          if (startDateStr != null && dateStr.compareTo(startDateStr) < 0) return false;
          if (endDateStr != null && dateStr.compareTo(endDateStr) > 0) return false;
          return true;
        }).toList();

        void addVals(String valStr, List<int> out) {
          if (valStr.trim().isEmpty) return;
          for (final s in valStr.split(',')) {
            final v = int.tryParse(s);
            out.add(v ?? 0);
          }
        }

        final Map<int, List<int>> questionValues = {};
        for (int i = 1; i <= 24; i++) {
          questionValues[i] = [];
        }

        for (final resp in inRangeResponses) {
          final list = questionValues[resp.questionNumber];
          if (list != null) {
            addVals(resp.nuitValues, list);
            addVals(resp.matinValues, list);
            addVals(resp.journeeValues, list);
            addVals(resp.soirValues, list);
          }
        }

        final List<Map<String, dynamic>> themeDefinitions = [
          {
            'title': 'Santé, Sport & Sommeil',
            'qNumbers': [1, 2, 3, 4],
            'icon': Icons.favorite_rounded,
            'color': Colors.tealAccent,
          },
          {
            'title': 'Alimentation',
            'qNumbers': [5, 6, 7, 8],
            'icon': Icons.restaurant_rounded,
            'color': Colors.orangeAccent,
          },
          {
            'title': 'Psychisme',
            'qNumbers': [9, 10, 11, 12],
            'icon': Icons.psychology_rounded,
            'color': Colors.purpleAccent,
          },
          {
            'title': 'Hygiène & Ménage',
            'qNumbers': [13, 14, 15, 16],
            'icon': Icons.clean_hands_rounded,
            'color': Colors.lightBlueAccent,
          },
          {
            'title': 'Admin & Finances',
            'qNumbers': [17, 18, 19, 20],
            'icon': Icons.attach_money_rounded,
            'color': Colors.greenAccent,
          },
          {
            'title': 'Relations & Famille',
            'qNumbers': [21, 22, 23, 24],
            'icon': Icons.people_rounded,
            'color': Colors.pinkAccent,
          },
        ];

        return SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: themeDefinitions.length,
            itemBuilder: (context, index) {
              final theme = themeDefinitions[index];
              final qNumbers = theme['qNumbers'] as List<int>;
              final List<int> values = [];
              for (final qNum in qNumbers) {
                values.addAll(questionValues[qNum] ?? []);
              }
              
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          theme['icon'] as IconData,
                          color: theme['color'] as Color,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            theme['title'] as String,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          displayVal,
                          style: TextStyle(
                            fontSize: 22,
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

  Widget _buildPeriodTimeOfDayStatsCarousel(WidgetRef ref, List<DiaryDay> days) {
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

        final List<int> nuitValues = [];
        final List<int> matinValues = [];
        final List<int> journeeValues = [];
        final List<int> soirValues = [];

        for (final resp in inRangeResponses) {
          nuitValues.addAll(parseVals(resp.nuitValues));
          matinValues.addAll(parseVals(resp.matinValues));
          journeeValues.addAll(parseVals(resp.journeeValues));
          soirValues.addAll(parseVals(resp.soirValues));
        }

        final List<Map<String, dynamic>> periodsDefinitions = [
          {
            'title': 'Nuit (00h - 05h)',
            'values': nuitValues,
            'icon': Icons.bedtime_rounded,
            'color': AppTheme.getPeriodColor('nuit'),
          },
          {
            'title': 'Matin (05h - 11h)',
            'values': matinValues,
            'icon': Icons.light_mode_rounded,
            'color': AppTheme.getPeriodColor('matin'),
          },
          {
            'title': 'Après-midi (11h - 17h)',
            'values': journeeValues,
            'icon': Icons.wb_sunny_rounded,
            'color': AppTheme.getPeriodColor('journee'),
          },
          {
            'title': 'Soir (17h - 00h)',
            'values': soirValues,
            'icon': Icons.nights_stay_rounded,
            'color': AppTheme.getPeriodColor('soir'),
          },
        ];

        return SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: periodsDefinitions.length,
            itemBuilder: (context, index) {
              final period = periodsDefinitions[index];
              final values = period['values'] as List<int>;
              
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
                width: 170,
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
                    Row(
                      children: [
                        Icon(
                          period['icon'] as IconData,
                          color: period['color'] as Color,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            period['title'] as String,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          displayVal,
                          style: TextStyle(
                            fontSize: 22,
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

  Widget _buildPeriodQuestionsStatsCarousel(WidgetRef ref, List<DiaryDay> days) {
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getLevelColor(diaryState.diaryDay!.level).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _getLevelColor(diaryState.diaryDay!.level).withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    'Score: ${diaryState.diaryDay!.totalScore.toInt()} (${diaryState.diaryDay!.level})',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _getLevelColor(diaryState.diaryDay!.level),
                    ),
                  ),
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
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.getPeriodColor(p),
                                            ),
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                if (ratings.isNotEmpty)
                                                  Wrap(
                                                    spacing: 4,
                                                    children: ratings.map((r) {
                                                      final valText = r > 0 ? '+$r' : '$r';
                                                      return Text(
                                                        valText,
                                                        style: TextStyle(
                                                          fontSize: 9,
                                                          color: AppTheme.getRatingColor(r),
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      );
                                                    }).toList(),
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
                                    const Text(
                                      'STATS PAR THÈME',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primaryLight,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    _buildPeriodThemesStatsCarousel(ref, days),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'STATS PAR SOUS-THÈME',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primaryLight,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    _buildPeriodQuestionsStatsCarousel(ref, days),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'STATS PAR MOMENT DE LA JOURNÉE',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primaryLight,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    _buildPeriodTimeOfDayStatsCarousel(ref, days),
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
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text('Cette journée est en brouillon. Allez sur l\'écran Historique pour la modifier ou la valider.'),
                                                    backgroundColor: Colors.orange,
                                                  ),
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

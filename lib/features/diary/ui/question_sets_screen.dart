import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/db/local_database.dart';
import '../controller/question_set_controller.dart';
import '../repository/question_set_repository.dart';
import '../repository/category_repository.dart';

// ---------------------------------------------------------------------------
// Predefined palette of colours for categories
// ---------------------------------------------------------------------------
const List<String> _categoryColorPalette = [
  '#6C63FF', // violet (default)
  '#4CAF50', // vert
  '#FF9800', // orange
  '#9C27B0', // violet foncé
  '#2196F3', // bleu
  '#F44336', // rouge
  '#E91E63', // rose
  '#00BCD4', // cyan
  '#FF5722', // orange foncé
  '#607D8B', // bleu-gris
];

class QuestionSetsScreen extends ConsumerStatefulWidget {
  const QuestionSetsScreen({super.key});

  @override
  ConsumerState<QuestionSetsScreen> createState() => _QuestionSetsScreenState();
}

class _QuestionSetsScreenState extends ConsumerState<QuestionSetsScreen>
    with SingleTickerProviderStateMixin {
  QuestionSet? _selectedSetForEditing;
  final _setNameController = TextEditingController();
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _setNameController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // Set dialogs
  // -------------------------------------------------------------------------

  void _showAddOrEditSetDialog({QuestionSet? setToEdit}) {
    final isEditing = setToEdit != null;
    _setNameController.text = isEditing ? setToEdit.name : '';
    List<String> activePeriods = isEditing
        ? setToEdit.selectedPeriods.split(',').map((p) => p.trim()).toList()
        : ['nuit', 'matin', 'journee', 'soir'];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppTheme.darkSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFF2E3047), width: 1.5),
              ),
              title: Text(
                isEditing ? 'Modifier le questionnaire' : 'Nouveau questionnaire',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _setNameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Nom du questionnaire',
                        labelStyle: TextStyle(color: AppTheme.textSecondary),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF2E3047)),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: AppTheme.primary),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Périodes d\'évaluation :',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    ...['nuit', 'matin', 'journee', 'soir'].map((period) {
                      final label = period == 'journee' ? 'Journée' : period[0].toUpperCase() + period.substring(1);
                      final isSelected = activePeriods.contains(period);
                      return CheckboxListTile(
                        title: Text(
                          label,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        activeColor: AppTheme.getPeriodColor(period),
                        value: isSelected,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (val) {
                          setDialogState(() {
                            if (val == true) {
                              activePeriods.add(period);
                            } else {
                              if (activePeriods.length > 1) {
                                activePeriods.remove(period);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Au moins une période doit être sélectionnée.'),
                                    backgroundColor: AppTheme.levelNegatif,
                                  ),
                                );
                              }
                            }
                          });
                        },
                      );
                    }),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('ANNULER', style: TextStyle(color: AppTheme.textSecondary)),
                ),
                TextButton(
                  onPressed: () async {
                    final name = _setNameController.text.trim();
                    if (name.isEmpty) return;

                    if (isEditing) {
                      await ref.read(questionSetControllerProvider.notifier).renameSet(setToEdit.id, name);
                      await ref.read(questionSetControllerProvider.notifier).updateSetPeriods(setToEdit.id, activePeriods);
                    } else {
                      final newId = await ref.read(questionSetControllerProvider.notifier).createSet(name, activePeriods);
                      // Add one default question so it's not empty
                      await ref.read(questionSetControllerProvider.notifier).addQuestion(
                        newId,
                        null,
                        '1. Général',
                        'BIEN-ÊTRE GLOBAL',
                        'Ressenti général sur cette période.',
                      );
                    }

                    if (context.mounted) Navigator.pop(context);
                  },
                  child: const Text('VALIDER', style: TextStyle(color: AppTheme.primaryLight, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // -------------------------------------------------------------------------
  // Question dialog — category is now a dropdown
  // -------------------------------------------------------------------------

  void _showAddQuestionDialog(String setId, {CustomQuestion? questionToEdit}) {
    final isEditing = questionToEdit != null;
    final titleController = TextEditingController(text: isEditing ? questionToEdit.title : '');
    final subtitleController = TextEditingController(text: isEditing ? questionToEdit.description : '');

    // We'll load categories inside the dialog
    showDialog(
      context: context,
      builder: (ctx) {
        return _QuestionDialogWithCategories(
          isEditing: isEditing,
          setId: setId,
          questionToEdit: questionToEdit,
          titleController: titleController,
          subtitleController: subtitleController,
          onSave: (categoryId, categoryText, title, subtitle) async {
            if (isEditing) {
              final updated = CustomQuestion(
                id: questionToEdit.id,
                setId: questionToEdit.setId,
                number: questionToEdit.number,
                categoryId: categoryId,
                category: categoryText,
                title: title,
                description: subtitle,
                createdAt: questionToEdit.createdAt,
                updatedAt: DateTime.now(),
              );
              await ref.read(questionSetControllerProvider.notifier).editQuestion(updated);
            } else {
              await ref.read(questionSetControllerProvider.notifier).addQuestion(
                setId,
                categoryId,
                categoryText,
                title,
                subtitle,
              );
            }
          },
        );
      },
    );
  }

  // -------------------------------------------------------------------------
  // Category dialogs
  // -------------------------------------------------------------------------

  void _showAddOrEditCategoryDialog({QuestionCategory? categoryToEdit}) {
    final isEditing = categoryToEdit != null;
    final nameController = TextEditingController(text: isEditing ? categoryToEdit.name : '');
    String selectedColor = isEditing ? categoryToEdit.color : _categoryColorPalette.first;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              backgroundColor: AppTheme.darkSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFF2E3047), width: 1.5),
              ),
              title: Text(
                isEditing ? 'Modifier la catégorie' : 'Nouvelle catégorie',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Nom de la catégorie',
                        labelStyle: TextStyle(color: AppTheme.textSecondary),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF2E3047)),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: AppTheme.primary),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Couleur :',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _categoryColorPalette.map((colorHex) {
                        final color = _hexToColor(colorHex);
                        final isSelected = selectedColor == colorHex;
                        return GestureDetector(
                          onTap: () => setDialogState(() => selectedColor = colorHex),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? Colors.white : Colors.transparent,
                                width: 2.5,
                              ),
                              boxShadow: isSelected
                                  ? [BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 8)]
                                  : [],
                            ),
                            child: isSelected
                                ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('ANNULER', style: TextStyle(color: AppTheme.textSecondary)),
                ),
                TextButton(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    if (name.isEmpty) return;
                    final catRepo = ref.read(categoryRepositoryProvider);
                    if (isEditing) {
                      await catRepo.updateCategory(categoryToEdit.id, name: name, color: selectedColor);
                    } else {
                      await catRepo.createCategory(name, color: selectedColor);
                    }
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: const Text('VALIDER', style: TextStyle(color: AppTheme.primaryLight, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDeleteCategory(QuestionCategory category) async {
    final catRepo = ref.read(categoryRepositoryProvider);
    final linked = await catRepo.getQuestionsForCategory(category.id);

    if (!mounted) return;

    if (linked.isNotEmpty) {
      // Show blocking dialog listing associated questions
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppTheme.darkSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF2E3047), width: 1.5),
          ),
          title: const Text('Suppression impossible', style: TextStyle(color: AppTheme.levelNegatif, fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${linked.length} question(s) utilisent cette catégorie. '
                  'Réassignez-les ou supprimez-les avant de supprimer la catégorie.',
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 12),
                ...linked.map((q) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppTheme.levelNegatif,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              q.title,
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('FERMER', style: TextStyle(color: AppTheme.primaryLight)),
            ),
          ],
        ),
      );
      return;
    }

    // Safe to delete — confirm dialog
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF2E3047), width: 1.5),
        ),
        title: const Text('Supprimer ?', style: TextStyle(color: Colors.white)),
        content: Text(
          'Voulez-vous vraiment supprimer la catégorie "${category.name}" ?',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('NON', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              await catRepo.deleteCategory(category.id);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('SUPPRIMER', style: TextStyle(color: AppTheme.levelNegatif, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final setsState = ref.watch(questionSetControllerProvider);
    final notifier = ref.read(questionSetControllerProvider.notifier);

    // When editing questions of a set, show a back-navigation without tabs
    if (_selectedSetForEditing != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_selectedSetForEditing!.name),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => setState(() => _selectedSetForEditing = null),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_rounded),
              onPressed: () => _showAddOrEditSetDialog(setToEdit: _selectedSetForEditing),
            ),
          ],
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppTheme.darkBg, AppTheme.darkSurface],
            ),
          ),
          child: _buildQuestionsEditor(notifier),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Questionnaires'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryLight,
          labelColor: AppTheme.primaryLight,
          unselectedLabelColor: AppTheme.textSecondary,
          tabs: const [
            Tab(icon: Icon(Icons.list_alt_rounded), text: 'Sets'),
            Tab(icon: Icon(Icons.label_rounded), text: 'Catégories'),
          ],
        ),
        actions: [
          // FAB-like add button changes based on active tab
          ListenableBuilder(
            listenable: _tabController,
            builder: (_, __) {
              return IconButton(
                icon: const Icon(Icons.add_rounded, color: AppTheme.primaryLight),
                tooltip: _tabController.index == 0 ? 'Nouveau set' : 'Nouvelle catégorie',
                onPressed: _tabController.index == 0
                    ? () => _showAddOrEditSetDialog()
                    : () => _showAddOrEditCategoryDialog(),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.darkBg, AppTheme.darkSurface],
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildSetsList(setsState, notifier),
            _buildCategoriesList(),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Sets tab
  // -------------------------------------------------------------------------

  Widget _buildSetsList(QuestionSetState state, QuestionSetNotifier notifier) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.questionSets.isEmpty) {
      return const Center(
        child: Text(
          'Aucun questionnaire. Créez-en un en haut à droite !',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.questionSets.length,
      itemBuilder: (context, index) {
        final set = state.questionSets[index];
        final periods = set.selectedPeriods.split(',').map((p) {
          if (p.trim() == 'journee') return 'Journée';
          return p.trim()[0].toUpperCase() + p.trim().substring(1);
        }).join(', ');

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        set.name,
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (set.isActive)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.levelOptimal.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.levelOptimal),
                        ),
                        child: const Text(
                          'En cours',
                          style: TextStyle(color: AppTheme.levelOptimal, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Périodes : $periods',
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                ),
                const Divider(color: Color(0xFF2E3047), height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (!set.isActive)
                      TextButton.icon(
                        icon: const Icon(Icons.check_rounded, size: 18, color: AppTheme.levelOptimal),
                        label: const Text('Activer', style: TextStyle(color: AppTheme.levelOptimal)),
                        onPressed: () => notifier.selectActiveSet(set.id),
                      ),
                    TextButton.icon(
                      icon: const Icon(Icons.copy_rounded, size: 18, color: AppTheme.primaryLight),
                      label: const Text('Copier', style: TextStyle(color: AppTheme.primaryLight)),
                      onPressed: () => notifier.duplicateSet(set.id, '${set.name} (copie)'),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.list_alt_rounded, size: 18, color: Colors.white),
                      label: const Text('Questions', style: TextStyle(color: Colors.white)),
                      onPressed: () {
                        setState(() {
                          _selectedSetForEditing = set;
                        });
                      },
                    ),
                    if (set.id != 'default_system_set')
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.levelNegatif),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: AppTheme.darkSurface,
                              title: const Text('Supprimer ?', style: TextStyle(color: Colors.white)),
                              content: Text('Voulez-vous vraiment supprimer le questionnaire "${set.name}" ?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('NON', style: TextStyle(color: AppTheme.textSecondary)),
                                ),
                                TextButton(
                                  onPressed: () {
                                    notifier.deleteSet(set.id);
                                    Navigator.pop(context);
                                  },
                                  child: const Text('SUPPRIMER', style: TextStyle(color: AppTheme.levelNegatif, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // -------------------------------------------------------------------------
  // Categories tab
  // -------------------------------------------------------------------------

  Widget _buildCategoriesList() {
    final categoriesAsync = ref.watch(categoryListProvider);

    return categoriesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erreur : $e', style: const TextStyle(color: AppTheme.levelNegatif))),
      data: (categories) {
        if (categories.isEmpty) {
          return const Center(
            child: Text(
              'Aucune catégorie. Créez-en une en haut à droite !',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final cat = categories[index];
            final catColor = _hexToColor(cat.color);

            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: catColor.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: catColor, width: 1.5),
                  ),
                  child: Icon(Icons.label_rounded, color: catColor, size: 22),
                ),
                title: Text(
                  cat.name,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20, color: AppTheme.textSecondary),
                      onPressed: () => _showAddOrEditCategoryDialog(categoryToEdit: cat),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppTheme.levelNegatif),
                      onPressed: () => _confirmDeleteCategory(cat),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // -------------------------------------------------------------------------
  // Questions editor (sub-page for a set)
  // -------------------------------------------------------------------------

  Widget _buildQuestionsEditor(QuestionSetNotifier notifier) {
    final setId = _selectedSetForEditing!.id;
    return StreamBuilder<List<CustomQuestion>>(
      stream: ref.read(questionSetRepositoryProvider).watchQuestionsForSet(setId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final questions = snapshot.data!;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${questions.length} question(s)',
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      minimumSize: const Size(140, 40),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Ajouter', style: TextStyle(fontSize: 13)),
                    onPressed: () => _showAddQuestionDialog(setId),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  final q = questions[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(
                        '${q.number}. ${q.title}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(q.description, style: const TextStyle(color: AppTheme.textSecondary)),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              q.category.isNotEmpty ? q.category : 'Sans catégorie',
                              style: const TextStyle(color: AppTheme.primaryLight, fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 20, color: AppTheme.textSecondary),
                            onPressed: () => _showAddQuestionDialog(setId, questionToEdit: q),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppTheme.levelNegatif),
                            onPressed: () {
                              if (questions.length <= 1) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Un questionnaire doit comporter au moins une question.'),
                                    backgroundColor: AppTheme.levelNegatif,
                                  ),
                                );
                                return;
                              }
                              notifier.removeQuestion(q.id);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

// =============================================================================
// Question dialog widget (needs Consumer to load categories)
// =============================================================================

class _QuestionDialogWithCategories extends ConsumerStatefulWidget {
  final bool isEditing;
  final String setId;
  final CustomQuestion? questionToEdit;
  final TextEditingController titleController;
  final TextEditingController subtitleController;
  final Future<void> Function(String? categoryId, String categoryText, String title, String subtitle) onSave;

  const _QuestionDialogWithCategories({
    required this.isEditing,
    required this.setId,
    required this.questionToEdit,
    required this.titleController,
    required this.subtitleController,
    required this.onSave,
  });

  @override
  ConsumerState<_QuestionDialogWithCategories> createState() => _QuestionDialogWithCategoriesState();
}

class _QuestionDialogWithCategoriesState extends ConsumerState<_QuestionDialogWithCategories> {
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.questionToEdit?.categoryId;
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoryListProvider);

    return AlertDialog(
      backgroundColor: AppTheme.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF2E3047), width: 1.5),
      ),
      title: Text(
        widget.isEditing ? 'Modifier la question' : 'Ajouter une question',
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title field
            TextField(
              controller: widget.titleController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Titre (ex: SOMMEIL)',
                labelStyle: TextStyle(color: AppTheme.textSecondary),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF2E3047))),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.primary)),
              ),
            ),
            const SizedBox(height: 16),
            // Subtitle field
            TextField(
              controller: widget.subtitleController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Sous-titre (ex: Qualité de la nuit...)',
                labelStyle: TextStyle(color: AppTheme.textSecondary),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF2E3047))),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.primary)),
              ),
            ),
            const SizedBox(height: 16),
            // Category dropdown
            const Text(
              'Catégorie :',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 6),
            categoriesAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Erreur : $e', style: const TextStyle(color: AppTheme.levelNegatif)),
              data: (categories) {
                // Ensure selected value exists in list
                final validId = categories.any((c) => c.id == _selectedCategoryId)
                    ? _selectedCategoryId
                    : null;

                return DropdownButtonFormField<String?>(
                  initialValue: validId,
                  dropdownColor: AppTheme.darkSurface,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF2E3047)),
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.primary),
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                  ),
                  hint: const Text('Choisir une catégorie', style: TextStyle(color: AppTheme.textSecondary)),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Sans catégorie', style: TextStyle(color: AppTheme.textSecondary)),
                    ),
                    ...categories.map((cat) {
                      final catColor = _hexToColor(cat.color);
                      return DropdownMenuItem<String?>(
                        value: cat.id,
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(color: catColor, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                cat.name,
                                style: const TextStyle(color: Colors.white, fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                  onChanged: (val) => setState(() => _selectedCategoryId = val),
                );
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('ANNULER', style: TextStyle(color: AppTheme.textSecondary)),
        ),
        TextButton(
          onPressed: () async {
            final title = widget.titleController.text.trim();
            final subtitle = widget.subtitleController.text.trim();
            if (title.isEmpty || subtitle.isEmpty) return;

            // Resolve category text from id
            String categoryText = '';
            if (_selectedCategoryId != null) {
              final catRepo = ref.read(categoryRepositoryProvider);
              final cat = await catRepo.getCategoryById(_selectedCategoryId!);
              categoryText = cat?.name ?? '';
            }

            await widget.onSave(_selectedCategoryId, categoryText, title, subtitle);
            if (context.mounted) Navigator.pop(context);
          },
          child: const Text('VALIDER', style: TextStyle(color: AppTheme.primaryLight, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Utility
// ---------------------------------------------------------------------------

Color _hexToColor(String hex) {
  final buffer = StringBuffer();
  if (hex.length == 7) buffer.write('ff');
  buffer.write(hex.replaceFirst('#', ''));
  return Color(int.parse(buffer.toString(), radix: 16));
}

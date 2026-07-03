import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/db/local_database.dart';
import '../controller/question_set_controller.dart';
import '../repository/question_set_repository.dart';

class QuestionSetsScreen extends ConsumerStatefulWidget {
  const QuestionSetsScreen({super.key});

  @override
  ConsumerState<QuestionSetsScreen> createState() => _QuestionSetsScreenState();
}

class _QuestionSetsScreenState extends ConsumerState<QuestionSetsScreen> {
  QuestionSet? _selectedSetForEditing;
  final _setNameController = TextEditingController();

  @override
  void dispose() {
    _setNameController.dispose();
    super.dispose();
  }

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

  void _showAddQuestionDialog(String setId, {CustomQuestion? questionToEdit}) {
    final isEditing = questionToEdit != null;
    final titleController = TextEditingController(text: isEditing ? questionToEdit.title : '');
    final subtitleController = TextEditingController(text: isEditing ? questionToEdit.description : '');
    final categoryController = TextEditingController(text: isEditing ? questionToEdit.category : '1. Général');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.darkSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF2E3047), width: 1.5),
          ),
          title: Text(
            isEditing ? 'Modifier la question' : 'Ajouter une question',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: titleController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Titre (ex: SOMMEIL)',
                    labelStyle: TextStyle(color: AppTheme.textSecondary),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF2E3047)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: subtitleController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Sous-titre (ex: Qualité de la nuit...)',
                    labelStyle: TextStyle(color: AppTheme.textSecondary),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF2E3047)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: categoryController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Catégorie (ex: 1. Santé)',
                    labelStyle: TextStyle(color: AppTheme.textSecondary),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF2E3047)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.primary),
                    ),
                  ),
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
                final title = titleController.text.trim();
                final subtitle = subtitleController.text.trim();
                final category = categoryController.text.trim();

                if (title.isEmpty || subtitle.isEmpty || category.isEmpty) return;

                if (isEditing) {
                  final updated = CustomQuestion(
                    id: questionToEdit.id,
                    setId: questionToEdit.setId,
                    number: questionToEdit.number,
                    category: category,
                    title: title,
                    description: subtitle,
                    createdAt: questionToEdit.createdAt,
                    updatedAt: DateTime.now(),
                  );
                  await ref.read(questionSetControllerProvider.notifier).editQuestion(updated);
                } else {
                  await ref.read(questionSetControllerProvider.notifier).addQuestion(setId, category, title, subtitle);
                }

                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('VALIDER', style: TextStyle(color: AppTheme.primaryLight, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final setsState = ref.watch(questionSetControllerProvider);
    final notifier = ref.read(questionSetControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Questionnaires'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (_selectedSetForEditing != null) {
              setState(() {
                _selectedSetForEditing = null;
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          if (_selectedSetForEditing == null)
            IconButton(
              icon: const Icon(Icons.add_rounded, color: AppTheme.primaryLight),
              onPressed: () => _showAddOrEditSetDialog(),
            )
          else
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
        child: _selectedSetForEditing != null
            ? _buildQuestionsEditor(notifier)
            : _buildSetsList(setsState, notifier),
      ),
    );
  }

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
                    'Questions de "${_selectedSetForEditing!.name}"',
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
                          const SizedBox(height: 2),
                          Text(
                            q.category,
                            style: const TextStyle(color: AppTheme.primaryLight, fontSize: 11),
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

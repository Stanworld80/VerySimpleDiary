import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/repository/auth_repository.dart';
import '../theme/app_theme.dart';
import '../config/settings_provider.dart';
import '../../features/diary/ui/question_sets_screen.dart';
import '../../features/diary/controller/question_set_controller.dart';
import '../services/notification_service.dart';

class ProfileMenuButton extends ConsumerWidget {
  const ProfileMenuButton({super.key});

  void _showDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.darkSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFF2E3047), width: 1.5),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          content: Text(
            content,
            style: const TextStyle(color: AppTheme.textSecondary, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Fermer',
                style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSettingsDialog(BuildContext context, WidgetRef ref) {
    final settings = ref.read(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    
    final apiKeyController = TextEditingController(text: settings.geminiApiKey);
    final proxyUrlController = TextEditingController(text: settings.geminiProxyUrl);
    bool useGemini = settings.useGemini;
    String geminiMode = settings.geminiMode;
    bool notificationsEnabled = settings.notificationsEnabled;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppTheme.darkSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Color(0xFF2E3047), width: 1.5),
              ),
              title: const Row(
                children: [
                  Icon(Icons.settings_rounded, color: AppTheme.primaryLight),
                  SizedBox(width: 8),
                  Text(
                    'Paramètres',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Configuration de l\'application :',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• Synchronisation Cloud active\n• Mode Local-First activé\n• Langue : Français',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.4),
                    ),
                    const Divider(color: Color(0xFF2E3047), height: 32),
                    
                    // Gemini title
                    const Row(
                      children: [
                        Icon(Icons.auto_awesome_rounded, color: Colors.amber, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Analyse IA par Gemini',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Générez automatiquement un résumé de vos ressentis de la journée et des conseils personnalisés pour vous améliorer.',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, height: 1.3),
                    ),
                    const SizedBox(height: 12),
                    
                    // Switch
                    SwitchListTile(
                      title: const Text('Activer l\'analyse IA', style: TextStyle(fontSize: 14, color: Colors.white)),
                      value: useGemini,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) {
                        setState(() {
                          useGemini = val;
                        });
                      },
                    ),
                    
                    if (useGemini) ...[
                      const SizedBox(height: 8),
                      // Dropdown for Mode Selection
                      DropdownButtonFormField<String>(
                        initialValue: geminiMode,
                        dropdownColor: AppTheme.darkCard,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: const InputDecoration(
                          labelText: 'Mode d\'intégration',
                          labelStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF2E3047)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppTheme.primary),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'direct',
                            child: Text('Direct (clé API personnelle)'),
                          ),
                          DropdownMenuItem(
                            value: 'proxy',
                            child: Text('Serveur Proxy (Option B)'),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              geminiMode = val;
                            });
                          }
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Conditionally show API Key or Proxy URL
                      if (geminiMode == 'direct') ...[
                        TextField(
                          controller: apiKeyController,
                          obscureText: true,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          decoration: InputDecoration(
                            labelText: 'Clé API Gemini',
                            labelStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                            hintText: 'Saisir votre clé API Gemini...',
                            hintStyle: TextStyle(color: AppTheme.textSecondary.withValues(alpha: 0.5)),
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF2E3047)),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: AppTheme.primary),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Où trouver une clé API Gemini gratuite ?\n→ Sur Google AI Studio (aistudio.google.com)',
                          style: TextStyle(color: AppTheme.primaryLight, fontSize: 11),
                        ),
                      ] else ...[
                        TextField(
                          controller: proxyUrlController,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          decoration: InputDecoration(
                            labelText: 'URL du Proxy Gemini',
                            labelStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                            hintText: 'https://votre-proxy.com/api/insight',
                            hintStyle: TextStyle(color: AppTheme.textSecondary.withValues(alpha: 0.5)),
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF2E3047)),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: AppTheme.primary),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Configurez l\'URL du serveur proxy qui détient la clé d\'API.',
                          style: TextStyle(color: AppTheme.primaryLight, fontSize: 11),
                        ),
                      ],
                    ],
                    
                    const Divider(color: Color(0xFF2E3047), height: 32),
                    
                    // Notifications Section
                    const Row(
                      children: [
                        Icon(Icons.notifications_rounded, color: AppTheme.primaryLight, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Rappels et Notifications',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Recevez un rappel de fin de période pour renseigner vos ressentis quotidiens.',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, height: 1.3),
                    ),
                    const SizedBox(height: 12),
                    
                    SwitchListTile(
                      title: const Text('Rappels de fin de période', style: TextStyle(fontSize: 14, color: Colors.white)),
                      value: notificationsEnabled,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) {
                        setState(() {
                          notificationsEnabled = val;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Annuler',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    minimumSize: const Size(100, 40),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onPressed: () async {
                    await notifier.setUseGemini(useGemini);
                    await notifier.setGeminiMode(geminiMode);
                    if (geminiMode == 'direct') {
                      await notifier.setGeminiApiKey(apiKeyController.text);
                    } else {
                      await notifier.setGeminiProxyUrl(proxyUrlController.text);
                    }
                    
                    final wasEnabled = settings.notificationsEnabled;
                    await notifier.setNotificationsEnabled(notificationsEnabled);
                    if (notificationsEnabled) {
                      await NotificationService.requestPermissions();
                      final activeSet = ref.read(questionSetControllerProvider).activeSet;
                      if (activeSet != null) {
                        final periods = activeSet.selectedPeriods.split(',').map((p) => p.trim()).where((p) => p.isNotEmpty).toList();
                        await NotificationService.schedulePeriodNotifications(activePeriods: periods);
                      }
                    } else if (wasEnabled && !notificationsEnabled) {
                      await NotificationService.cancelAll();
                    }

                    if (context.mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Paramètres enregistrés avec succès.'),
                          backgroundColor: AppTheme.levelOptimal,
                        ),
                      );
                    }
                  },
                  child: const Text('Enregistrer'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.account_circle_rounded, color: AppTheme.textPrimary, size: 28),
      tooltip: 'Profil',
      offset: const Offset(0, 48),
      color: AppTheme.darkCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF2E3047), width: 1),
      ),
      onSelected: (value) async {
        switch (value) {
          case 'settings':
            _showSettingsDialog(context, ref);
            break;
          case 'questionnaires':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const QuestionSetsScreen()),
            );
            break;
          case 'legal':
            _showDialog(
              context,
              'Mentions Légales',
              'Very Simple Diary est une application open-source.\n\nDonnées locales chiffrées (SQLite). Aucune collecte de données publicitaires. Conforme RGPD.',
            );
            break;
          case 'help':
            _showDialog(
              context,
              'Aide & Support',
              'Comment utiliser l\'application :\n- Remplissez les questions quotidiennement.\n- Choisissez plusieurs réponses par période si besoin.\n- Validez pour enregistrer et générer votre score de synthèse.',
            );
            break;
          case 'logout':
            // Handle popping all routes back to root before signing out to prevent errors
            Navigator.of(context).popUntil((route) => route.isFirst);
            await ref.read(authRepositoryProvider).signOut();
            break;
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'settings',
          child: Row(
            children: [
              Icon(Icons.settings_rounded, size: 20, color: AppTheme.textSecondary),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Paramètres',
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'questionnaires',
          child: Row(
            children: [
              Icon(Icons.list_alt_rounded, size: 20, color: AppTheme.textSecondary),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Questionnaires',
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'legal',
          child: Row(
            children: [
              Icon(Icons.gavel_rounded, size: 20, color: AppTheme.textSecondary),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Mentions Légales',
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'help',
          child: Row(
            children: [
              Icon(Icons.help_outline_rounded, size: 20, color: AppTheme.textSecondary),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Aide',
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(height: 1),
        const PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout_rounded, size: 20, color: AppTheme.levelNegatif),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Déconnexion',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.levelNegatif,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/repository/auth_repository.dart';
import '../theme/app_theme.dart';

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
            _showDialog(
              context,
              'Paramètres',
              'Configuration de l\'application :\n- Synchronisation Cloud active\n- Mode Local-First activé\n- Langue : Français',
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
              Text('Paramètres', style: TextStyle(fontSize: 14)),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'legal',
          child: Row(
            children: [
              Icon(Icons.gavel_rounded, size: 20, color: AppTheme.textSecondary),
              SizedBox(width: 12),
              Text('Mentions Légales', style: TextStyle(fontSize: 14)),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'help',
          child: Row(
            children: [
              Icon(Icons.help_outline_rounded, size: 20, color: AppTheme.textSecondary),
              SizedBox(width: 12),
              Text('Aide', style: TextStyle(fontSize: 14)),
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
              Text(
                'Déconnexion',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.levelNegatif,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

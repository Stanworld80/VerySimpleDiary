import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'diary_screen.dart';
import 'explorer_screen.dart';
import '../controller/diary_controller.dart';
import '../repository/sync_repository.dart';
import '../../auth/repository/auth_repository.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/version_footer.dart';
import '../../../core/ui/profile_menu_button.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    return "$day/$month/$year";
  }

  String _getIsoDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return "${date.year}-$month-$day";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Trigger background synchronization at startup/home view loading
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(syncRepositoryProvider).syncAll();
    });

    final now = DateTime.now();
    final todayStr = _getIsoDate(now);
    final formattedDate = _formatDate(now);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0D0E15),
              Color(0xFF161722),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top row with Profile menu button
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const ProfileMenuButton(),
                  ],
                ),
                
                const Spacer(),
                
                // Welcome / Logo Section
                Center(
                  child: Container(
                    height: 96,
                    width: 96,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primary, AppTheme.accent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.3),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.book_rounded,
                      size: 44,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Very Simple Diary',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Votre journal sémantique personnel, sécurisé et local.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const Spacer(),
                
                // Action Buttons Section
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.darkCard,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFF2E3047), width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Journal of the day Button
                      ElevatedButton(
                        onPressed: () {
                          // Select today's date and open the Diary Screen
                          ref.read(diaryDateProvider.notifier).state = todayStr;
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const DiaryScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          minimumSize: const Size.fromHeight(60),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                          shadowColor: AppTheme.primary.withValues(alpha: 0.4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.edit_calendar_rounded, size: 20),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                'Journal du jour : $formattedDate',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Explore data Button
                      OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ExplorerScreen(),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(60),
                          side: const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.analytics_rounded, size: 20, color: Color(0xFF3B82F6)),
                            const SizedBox(width: 12),
                            Text(
                              'Explorer les données',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF3B82F6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Spacer(),
                const VersionFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

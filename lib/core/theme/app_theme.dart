import 'package:flutter/material.dart';

class AppTheme {
  // Rich Dark mode color palette
  static const Color darkBg = Color(0xFF0D0E15);
  static const Color darkSurface = Color(0xFF161722);
  static const Color darkCard = Color(0xFF1E2030);
  
  static const Color primary = Color(0xFF6366F1); // Sleek Indigo
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color accent = Color(0xFFEC4899); // Electric Pink
  
  static const Color textPrimary = Color(0xFFF3F4F6);
  static const Color textSecondary = Color(0xFF9CA3AF);
  
  // Score indicator colors
  static const Color levelOptimal = Color(0xFF10B981); // Emerald Green
  static const Color levelBon = Color(0xFF34D399);     // Mint Green
  static const Color levelMoyen = Color(0xFFFBBF24);   // Amber Yellow
  static const Color levelNul = Color(0xFFF97316);     // Orange
  static const Color levelNegatif = Color(0xFFEF4444);  // Red

  // Period colors
  static const Color periodNuit = Color(0xFF818CF8);    // Indigo/Blue
  static const Color periodMatin = Color(0xFFFFD54F);   // Amber/Yellow
  static const Color periodJournee = Color(0xFFFF9800); // Orange
  static const Color periodSoir = Color(0xFFE040FB);    // Purple/Magenta

  static Color getRatingColor(int rating) {
    switch (rating) {
      case -2:
        return levelNegatif;
      case -1:
        return levelNul;
      case 0:
        return Colors.white;
      case 1:
        return levelBon;
      case 2:
        return levelOptimal;
      default:
        return textSecondary;
    }
  }

  static Color getPeriodColor(String period) {
    switch (period.toLowerCase()) {
      case 'nuit':
        return periodNuit;
      case 'matin':
        return periodMatin;
      case 'journee':
      case 'journée':
      case 'après-midi':
      case 'apres-midi':
      case 'jrn':
        return periodJournee;
      case 'soir':
      case 'soirée':
      case 'soi':
        return periodSoir;
      default:
        return textSecondary;
    }
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: darkBg,
      primaryColor: primary,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: accent,
        surface: darkSurface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF2E3047), width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBg,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        titleLarge: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(
          color: textPrimary,
          fontSize: 16,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          color: textSecondary,
          fontSize: 14,
          height: 1.4,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

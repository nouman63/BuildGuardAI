import 'package:flutter/material.dart';

/// Design tokens sampled directly from the BuildGuard AI Figma landing
/// page export (blue-700 / amber-600 SaaS palette on white).
class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF1D4ED8); // blue-700
  static const Color primaryHover = Color(0xFF1E40AF); // blue-800
  static const Color primarySoft = Color(0xFFEFF6FF); // blue-50 (pills/badge)
  static const Color primarySoftStrong = Color(0xFFDBEAFE); // blue-100 (card header band)

  // Secondary module accent (Risk Management)
  static const Color amber = Color(0xFFD97706); // amber-600
  static const Color amberSoft = Color(0xFFFFFBEB); // amber-50

  // Neutrals / text
  static const Color navy = Color(0xFF0B1D3E); // headings
  static const Color textSecondary = Color(0xFF475569); // slate-600 body copy
  static const Color textMuted = Color(0xFF94A3B8); // slate-400
  static const Color divider = Color(0xFFE5EAF2);
  static const Color fieldFill = Color(0xFFF3F6FB);
  static const Color surface = Colors.white;
  static const Color background = Colors.white;

  // Status
  static const Color danger = Color(0xFFDC2626);
  static const Color success = Color(0xFF16A34A);
  static const Color warning = amber;
}

class AppRadius {
  AppRadius._();
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 20;
  static const double pill = 999;
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        error: AppColors.danger,
      ),
      scaffoldBackgroundColor: AppColors.background,
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        foregroundColor: AppColors.navy,
        iconTheme: IconThemeData(color: AppColors.navy),
        titleTextStyle: TextStyle(
          color: AppColors.navy,
          fontSize: 19,
          fontWeight: FontWeight.w800,
        ),
      ),
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.navy,
        displayColor: AppColors.navy,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.fieldFill,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.2),
        ),
        hintStyle: const TextStyle(color: AppColors.textMuted),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
          minimumSize: const Size.fromHeight(52),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(color: AppColors.divider),
        ),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.divider, space: 1),
    );
  }
}

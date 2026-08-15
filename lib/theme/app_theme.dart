import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tokens.dart';

class SigapTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: SigapColors.primary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: SigapColors.background,
      fontFamily: GoogleFonts.ibmPlexSans().fontFamily,
      textTheme: GoogleFonts.ibmPlexSansTextTheme(),
      appBarTheme: const AppBarTheme(
        backgroundColor: SigapColors.surface,
        foregroundColor: SigapColors.textPrimary,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: SigapColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: SigapSpacing.lg,
            vertical: SigapSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SigapRadius.md),
          ),
        ),
      ),
    );
  }
}

class AppTypography {
  static TextStyle get sans => GoogleFonts.ibmPlexSans();
  static TextStyle get mono => GoogleFonts.ibmPlexMono();
}

class PantauTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.bgSurface,
      fontFamily: GoogleFonts.ibmPlexSans().fontFamily,
      textTheme: GoogleFonts.ibmPlexSansTextTheme().copyWith(
        displayLarge: GoogleFonts.ibmPlexSans(color: AppColors.textPrimary),
        displayMedium: GoogleFonts.ibmPlexSans(color: AppColors.textPrimary),
        displaySmall: GoogleFonts.ibmPlexSans(color: AppColors.textPrimary),
        headlineLarge: GoogleFonts.ibmPlexSans(color: AppColors.textPrimary),
        headlineMedium: GoogleFonts.ibmPlexSans(color: AppColors.textPrimary),
        headlineSmall: GoogleFonts.ibmPlexSans(color: AppColors.textPrimary),
        titleLarge: GoogleFonts.ibmPlexSans(color: AppColors.textPrimary),
        titleMedium: GoogleFonts.ibmPlexSans(color: AppColors.textPrimary),
        titleSmall: GoogleFonts.ibmPlexSans(color: AppColors.textSecondary),
        bodyLarge: GoogleFonts.ibmPlexSans(color: AppColors.textPrimary),
        bodyMedium: GoogleFonts.ibmPlexSans(color: AppColors.textSecondary),
        bodySmall: GoogleFonts.ibmPlexSans(color: AppColors.textTertiary),
        labelLarge: GoogleFonts.ibmPlexSans(color: AppColors.textPrimary),
        labelMedium: GoogleFonts.ibmPlexSans(color: AppColors.textSecondary),
        labelSmall: GoogleFonts.ibmPlexSans(color: AppColors.textTertiary),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bgCard,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: AppColors.bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(color: AppColors.borderCard),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.borderCard),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.borderCard),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderCard,
        thickness: 1,
      ),
    );
  }
}

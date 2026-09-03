import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tokens.dart';

// ============================================================================
// SIGAP Flutter Theme
// Uses design tokens from tokens.dart (single source of truth)
// ============================================================================

class SigapTheme {
  SigapTheme._();

  static ThemeData light() {
    // Precache IBM Plex Mono so fontFamilyMono consumers resolve at runtime
    GoogleFonts.ibmPlexMonoTextTheme();

    final textTheme = GoogleFonts.ibmPlexSansTextTheme().copyWith(
      displayLarge: GoogleFonts.ibmPlexSans(color: SigapColors.textPrimary),
      displayMedium: GoogleFonts.ibmPlexSans(color: SigapColors.textPrimary),
      displaySmall: GoogleFonts.ibmPlexSans(color: SigapColors.textPrimary),
      headlineLarge: GoogleFonts.ibmPlexSans(color: SigapColors.textPrimary),
      headlineMedium: GoogleFonts.ibmPlexSans(color: SigapColors.textPrimary),
      headlineSmall: GoogleFonts.ibmPlexSans(color: SigapColors.textPrimary),
      titleLarge: GoogleFonts.ibmPlexSans(color: SigapColors.textPrimary),
      titleMedium: GoogleFonts.ibmPlexSans(color: SigapColors.textPrimary),
      titleSmall: GoogleFonts.ibmPlexSans(color: SigapColors.textSecondary),
      bodyLarge: GoogleFonts.ibmPlexSans(color: SigapColors.textPrimary),
      bodyMedium: GoogleFonts.ibmPlexMono(color: SigapColors.textSecondary),
      bodySmall: GoogleFonts.ibmPlexSans(color: SigapColors.textTertiary),
      labelLarge: GoogleFonts.ibmPlexSans(color: SigapColors.textPrimary),
      labelMedium: GoogleFonts.ibmPlexSans(color: SigapColors.textSecondary),
      labelSmall: GoogleFonts.ibmPlexSans(color: SigapColors.textTertiary),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: SigapColors.primary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: SigapColors.background,
      fontFamily: GoogleFonts.ibmPlexSans().fontFamily,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: SigapColors.surface,
        foregroundColor: SigapColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: SigapColors.bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SigapRadius.lg),
          side: const BorderSide(color: SigapColors.border),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: SigapColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: SigapSpacing.xl,
            vertical: SigapSpacing.x15,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SigapRadius.md),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: SigapColors.primary,
          side: const BorderSide(color: SigapColors.primary),
          padding: const EdgeInsets.symmetric(
            horizontal: SigapSpacing.xl,
            vertical: SigapSpacing.x15,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SigapRadius.md),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: SigapColors.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: SigapSpacing.lg,
            vertical: SigapSpacing.sm,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: SigapColors.bgCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SigapRadius.md),
          borderSide: const BorderSide(color: SigapColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SigapRadius.md),
          borderSide: const BorderSide(color: SigapColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SigapRadius.md),
          borderSide: const BorderSide(color: SigapColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: SigapSpacing.lg,
          vertical: SigapSpacing.md,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: SigapColors.border,
        thickness: 1,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: SigapColors.primary,
        unselectedItemColor: SigapColors.textMuted,
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
    );
  }
}

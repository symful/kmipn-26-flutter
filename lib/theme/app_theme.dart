import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tokens.dart';
import 'sigap_color_scheme.dart';

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
      extensions: [SigapColorScheme.light],
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

  static ThemeData dark() {
    // Precache IBM Plex Mono so fontFamilyMono consumers resolve at runtime
    GoogleFonts.ibmPlexMonoTextTheme();

    final textTheme = GoogleFonts.ibmPlexSansTextTheme().copyWith(
      displayLarge: GoogleFonts.ibmPlexSans(
        color: SigapColorScheme.dark.textPrimary,
      ),
      displayMedium: GoogleFonts.ibmPlexSans(
        color: SigapColorScheme.dark.textPrimary,
      ),
      displaySmall: GoogleFonts.ibmPlexSans(
        color: SigapColorScheme.dark.textPrimary,
      ),
      headlineLarge: GoogleFonts.ibmPlexSans(
        color: SigapColorScheme.dark.textPrimary,
      ),
      headlineMedium: GoogleFonts.ibmPlexSans(
        color: SigapColorScheme.dark.textPrimary,
      ),
      headlineSmall: GoogleFonts.ibmPlexSans(
        color: SigapColorScheme.dark.textPrimary,
      ),
      titleLarge: GoogleFonts.ibmPlexSans(
        color: SigapColorScheme.dark.textPrimary,
      ),
      titleMedium: GoogleFonts.ibmPlexSans(
        color: SigapColorScheme.dark.textPrimary,
      ),
      titleSmall: GoogleFonts.ibmPlexSans(
        color: SigapColorScheme.dark.textSecondary,
      ),
      bodyLarge: GoogleFonts.ibmPlexSans(
        color: SigapColorScheme.dark.textPrimary,
      ),
      bodyMedium: GoogleFonts.ibmPlexMono(
        color: SigapColorScheme.dark.textSecondary,
      ),
      bodySmall: GoogleFonts.ibmPlexSans(
        color: SigapColorScheme.dark.textTertiary,
      ),
      labelLarge: GoogleFonts.ibmPlexSans(
        color: SigapColorScheme.dark.textPrimary,
      ),
      labelMedium: GoogleFonts.ibmPlexSans(
        color: SigapColorScheme.dark.textSecondary,
      ),
      labelSmall: GoogleFonts.ibmPlexSans(
        color: SigapColorScheme.dark.textTertiary,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: SigapColorScheme.dark.primary,
        brightness: Brightness.dark,
      ),
      extensions: [SigapColorScheme.dark],
      scaffoldBackgroundColor: SigapColorScheme.dark.background,
      fontFamily: GoogleFonts.ibmPlexSans().fontFamily,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: SigapColorScheme.dark.surface,
        foregroundColor: SigapColorScheme.dark.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: SigapColorScheme.dark.bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SigapRadius.lg),
          side: BorderSide(color: SigapColorScheme.dark.border),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: SigapColorScheme.dark.primary,
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
          foregroundColor: SigapColorScheme.dark.primary,
          side: BorderSide(color: SigapColorScheme.dark.primary),
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
          foregroundColor: SigapColorScheme.dark.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: SigapSpacing.lg,
            vertical: SigapSpacing.sm,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: SigapColorScheme.dark.bgCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SigapRadius.md),
          borderSide: BorderSide(color: SigapColorScheme.dark.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SigapRadius.md),
          borderSide: BorderSide(color: SigapColorScheme.dark.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SigapRadius.md),
          borderSide: BorderSide(
            color: SigapColorScheme.dark.primary,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: SigapSpacing.lg,
          vertical: SigapSpacing.md,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: SigapColorScheme.dark.border,
        thickness: 1,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: SigapColorScheme.dark.primary,
        unselectedItemColor: SigapColorScheme.dark.textMuted,
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
    );
  }
}

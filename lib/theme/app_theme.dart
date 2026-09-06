import 'package:flutter/material.dart';
import 'tokens.dart';
import 'sigap_color_scheme.dart';

// ============================================================================
// SIGAP Flutter Theme
// Uses design tokens from tokens.dart (single source of truth)
// ============================================================================

class SigapTheme {
  SigapTheme._();

  static const String _fontFamily = 'IBMPlexSans';

  static TextTheme _buildTextTheme({
    required Color primary,
    required Color secondary,
    required Color tertiary,
  }) {
    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: _fontFamily,
        fontSize: SigapTypography.displayLarge,
        fontWeight: FontWeight.w400,
        color: primary,
      ),
      displayMedium: TextStyle(
        fontFamily: _fontFamily,
        fontSize: SigapTypography.displayMedium,
        fontWeight: FontWeight.w400,
        color: primary,
      ),
      displaySmall: TextStyle(
        fontFamily: _fontFamily,
        fontSize: SigapTypography.displaySmall,
        fontWeight: FontWeight.w400,
        color: primary,
      ),
      headlineLarge: TextStyle(
        fontFamily: _fontFamily,
        fontSize: SigapTypography.headlineLarge,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      headlineMedium: TextStyle(
        fontFamily: _fontFamily,
        fontSize: SigapTypography.headlineMedium,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      headlineSmall: TextStyle(
        fontFamily: _fontFamily,
        fontSize: SigapTypography.headlineSmall,
        fontWeight: FontWeight.w500,
        color: primary,
      ),
      titleLarge: TextStyle(
        fontFamily: _fontFamily,
        fontSize: SigapTypography.titleLarge,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      titleMedium: TextStyle(
        fontFamily: _fontFamily,
        fontSize: SigapTypography.titleMedium,
        fontWeight: FontWeight.w500,
        color: primary,
      ),
      titleSmall: TextStyle(
        fontFamily: _fontFamily,
        fontSize: SigapTypography.titleSmall,
        fontWeight: FontWeight.w500,
        color: secondary,
      ),
      bodyLarge: TextStyle(
        fontFamily: _fontFamily,
        fontSize: SigapTypography.bodyLarge,
        fontWeight: FontWeight.w400,
        color: primary,
      ),
      bodyMedium: TextStyle(
        fontFamily: _fontFamily,
        fontSize: SigapTypography.bodyMedium,
        fontWeight: FontWeight.w400,
        color: secondary,
      ),
      bodySmall: TextStyle(
        fontFamily: _fontFamily,
        fontSize: SigapTypography.bodySmall,
        fontWeight: FontWeight.w400,
        color: tertiary,
      ),
      labelLarge: TextStyle(
        fontFamily: _fontFamily,
        fontSize: SigapTypography.captionLarge,
        fontWeight: FontWeight.w500,
        color: primary,
      ),
      labelMedium: TextStyle(
        fontFamily: _fontFamily,
        fontSize: SigapTypography.captionMedium,
        fontWeight: FontWeight.w500,
        color: secondary,
      ),
      labelSmall: TextStyle(
        fontFamily: _fontFamily,
        fontSize: SigapTypography.captionSmall,
        fontWeight: FontWeight.w500,
        color: tertiary,
      ),
    );
  }

  static ThemeData light() {
    final textTheme = _buildTextTheme(
      primary: SigapColors.textPrimary,
      secondary: SigapColors.textSecondary,
      tertiary: SigapColors.textTertiary,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: SigapColors.primary,
        brightness: Brightness.light,
      ),
      extensions: [SigapColorScheme.light],
      scaffoldBackgroundColor: SigapColors.background,
      fontFamily: _fontFamily,
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
    final textTheme = _buildTextTheme(
      primary: SigapColorScheme.dark.textPrimary,
      secondary: SigapColorScheme.dark.textSecondary,
      tertiary: SigapColorScheme.dark.textTertiary,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: SigapColorScheme.dark.primary,
        brightness: Brightness.dark,
      ),
      extensions: [SigapColorScheme.dark],
      scaffoldBackgroundColor: SigapColorScheme.dark.background,
      fontFamily: _fontFamily,
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

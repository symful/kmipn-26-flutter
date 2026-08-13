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

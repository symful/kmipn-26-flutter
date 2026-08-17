import 'package:flutter/material.dart';

// ============================================================================
// SIGAP Design Tokens - Single Source of Truth (Flutter)
// Matches kmipn-26-deno/web/src/theme/tokens.ts
// ============================================================================

// ----------------------------------------------------------------------------
// Colors - matches web tokens.ts colors + extended palette
// ----------------------------------------------------------------------------
class SigapColors {
  SigapColors._();

  // Primary
  static const Color primary = Color(0xFF0F7A6B);
  static const Color primaryHover = Color(0xFF0A5C50);
  static const Color primaryLight = Color(0xFFE2F1EE);
  static const Color primaryDark = Color(0xFF0A5C50);

  // Status
  static const Color perluTindakan = Color(0xFFC0392B);
  static const Color diproses = Color(0xFF2563EB);
  static const Color selesai = Color(0xFF22C55E);

  // Offline Banner
  static const Color offlineBg = Color(0xFFF8ECD6);
  static const Color offlineBorder = Color(0xFFECD7A6);
  static const Color offlineText = Color(0xFF8A5808);
  static const Color offlineDot = Color(0xFFB8730A);

  // Base
  static const Color background = Color(0xFFE6E8E3);
  static const Color surface = Color(0xFFF4F5F3);
  static const Color border = Color(0xFFE4E7E2);

  // Text
  static const Color textPrimary = Color(0xFF17191C);
  static const Color textSecondary = Color(0xFF4A5058);
  static const Color textTertiary = Color(0xFF616770);
  static const Color textMuted = Color(0xFF8A9099);

  // Sidebar (T-W1.14)
  static const Color sidebarBg = Color(0xFF16302B);
  static const Color sidebarText = Color(0xFFCFE4DF);
  static const Color sidebarTextHover = Color(0xFFFFFFFF);
  static const Color sidebarTextMuted = Color(0xFF9DC0B9);
  static const Color sidebarDivider = Color(0xFF234A43);
  static const Color sidebarAccent = Color(0xFF7FA8A0);

  // Extended palette (T-W1.15)
  static const Color infoChartBar = Color(0xFFC7D7FB);
  static const Color dangerTextStrong = Color(0xFFA5271A);
  static const Color dangerBorder = Color(0xFFECC4BD);
  static const Color dangerBg = Color(0xFFF8E2DE);
  static const Color danger = Color(0xFFC0392B); // Alias for perluTindakan
  static const Color warningText = Color(0xFF8A5808);
  static const Color warningBorder = Color(0xFFECD7A6);
  static const Color warningBg = Color(0xFFF8ECD6);
  static const Color warningTextStrong = Color(0xFF7A4D06);
  static const Color warning = Color(0xFF8A5808); // Alias for warningText
  static const Color info = Color(0xFF2563EB);
  static const Color infoBg = Color(0xFFE5EDFD);
  static const Color successBorder = Color(0xFFBFE0D9);
  static const Color borderSoft = Color(0xFFD3D7D0);
  static const Color borderCard = Color(0xFFE4E7E2); // Alias for border
  static const Color bgSoft = Color(0xFFEEF0EC);
  static const Color bgScreen = Color(0xFFF9FAF8);
  static const Color bgCard = Color(0xFFFFFFFF);
  static const Color bgSurface = Color(0xFFF4F5F3);

  // Misc
  static const Color textSoft = Color(0xFF4A5058);
  static const Color textDisabled = Color(0xFF8A9099);
  static const Color macGreen = Color(0xFF66C07F);
  static const Color macYellow = Color(0xFFE8BD57);
  static const Color macRed = Color(0xFFE06C60);
  static const Color mapBg = Color(0xFFEAEEE9);
  static const Color mapGrid = Color(0xFFDFE4DE);
  static const Color phoneBezel = Color(0xFF1F2226);
}

// ----------------------------------------------------------------------------
// Spacing - matches web tokens.ts spacing
// ----------------------------------------------------------------------------
class SigapSpacing {
  SigapSpacing._();

  static const double xs = 5;
  static const double sm = 8;
  static const double md = 13;
  static const double lg = 18;
  static const double xl = 24;

  // Extended tokens (used in Flutter but not in web)
  static const double xxs = 2;
  static const double x4 = 4;
  static const double x6 = 6;
  static const double x7 = 7;
  static const double x9 = 9;
  static const double x10 = 10;
  static const double x11 = 11;
  static const double x12 = 12;
  static const double x14 = 14;
  static const double x15 = 15;
  static const double x17 = 17;
  static const double x22 = 22;
  static const double x28 = 28;
  static const double x32 = 32;
  static const double x34 = 34;
  static const double x56 = 56;
  static const double x60 = 60;
  static const double x90 = 90;
  static const double xxl = 48;
}

// ----------------------------------------------------------------------------
// Radius - matches web tokens.ts radius
// ----------------------------------------------------------------------------
class SigapRadius {
  SigapRadius._();

  static const double sm = 5;
  static const double md = 11;
  static const double lg = 13;

  // Extended tokens
  static const double x1 = 1;
  static const double x2 = 2;
  static const double x3 = 3;
  static const double x4 = 4;
  static const double x6 = 6;
  static const double x7 = 7;
  static const double x8 = 8;
  static const double x9 = 9;
  static const double x10 = 10;
  static const double x12 = 12;
  static const double xl = 14;
  static const double x16 = 16;
  static const double x34 = 34;
  static const double x44 = 44;
  static const double pill = 999;
}

// ----------------------------------------------------------------------------
// Shadows - matches web shadow definitions
// ----------------------------------------------------------------------------
class SigapShadows {
  SigapShadows._();

  static const List<BoxShadow> buttonPrimary = [
    BoxShadow(color: Color(0xE60F7A6B), blurRadius: 22, offset: Offset(0, 10)),
  ];

  static const List<BoxShadow> fab = [
    BoxShadow(color: Color(0xE60F7A6B), blurRadius: 20, offset: Offset(0, 10)),
  ];

  static const List<BoxShadow> phoneBezel = [
    BoxShadow(color: Color(0x80000000), blurRadius: 60, offset: Offset(0, 28)),
  ];

  static const List<BoxShadow> browserFrame = [
    BoxShadow(color: Color(0x66000000), blurRadius: 60, offset: Offset(0, 24)),
  ];

  static const List<BoxShadow> mapLegend = [
    BoxShadow(color: Color(0x4D000000), blurRadius: 16, offset: Offset(0, 6)),
  ];

  static const List<BoxShadow> toggleThumb = [
    BoxShadow(color: Color(0x33000000), blurRadius: 2, offset: Offset(0, 1)),
  ];
}

// ----------------------------------------------------------------------------
// Typography - IBM Plex Sans + Mono via google_fonts
// ----------------------------------------------------------------------------
class SigapTypography {
  SigapTypography._();

  // Font families (via google_fonts)
  static const String fontFamilySans = 'IBM Plex Sans';
  static const String fontFamilyMono = 'IBM Plex Mono';

  // Type scale
  static const double size8 = 8;
  static const double size9 = 9;
  static const double size10 = 10;
  static const double size11 = 11;
  static const double size11_5 = 11.5;
  static const double size12 = 12;
  static const double size12_5 = 12.5;
  static const double size13 = 13;
  static const double size13_5 = 13.5;
  static const double size14 = 14;
  static const double size15 = 15;
  static const double size16 = 16;
  static const double size17 = 17;
  static const double size19 = 19;
  static const double size20 = 20;
  static const double size22 = 22;
  static const double size24 = 24;
  static const double size26 = 26;
  static const double size30 = 30;

  // Line heights
  static const double lineHeight125 = 1.25;
  static const double lineHeight130 = 1.3;
  static const double lineHeight135 = 1.35;
  static const double lineHeight140 = 1.4;
  static const double lineHeight145 = 1.45;
  static const double lineHeight150 = 1.5;
  static const double lineHeight155 = 1.55;

  // Letter spacing
  static const double letterSpacingTight = -0.01;
  static const double letterSpacingLabel = 0.04;
}

// ============================================================================
// Backward-Compatible Aliases (for existing code using old names)
// ============================================================================

/// Backward-compatible alias for SigapColors.
typedef AppColors = SigapColors;

/// Backward-compatible alias for SigapSpacing.
typedef AppSpacing = SigapSpacing;

/// Backward-compatible alias for SigapRadius.
typedef AppRadius = SigapRadius;

/// Backward-compatible alias for SigapShadows.
typedef AppShadows = SigapShadows;

/// Backward-compatible alias for SigapTypography.
typedef AppTypography = SigapTypography;

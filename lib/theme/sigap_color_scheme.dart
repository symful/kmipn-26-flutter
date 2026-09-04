import 'package:flutter/material.dart';

class SigapColorScheme extends ThemeExtension<SigapColorScheme> {
  final Color primary;
  final Color primaryHover;
  final Color primaryLight;
  final Color primaryDark;

  final Color perluTindakan;
  final Color diproses;
  final Color selesai;
  final Color success;
  final Color warning;

  final Color offlineBg;
  final Color offlineBorder;
  final Color offlineText;
  final Color offlineDot;

  final Color background;
  final Color surface;
  final Color border;

  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textMuted;
  final Color text;

  final Color sidebarBg;
  final Color sidebarText;
  final Color sidebarTextHover;
  final Color sidebarTextMuted;
  final Color sidebarDivider;
  final Color sidebarAccent;

  final Color infoChartBar;
  final Color dangerTextStrong;
  final Color dangerBorder;
  final Color dangerBg;
  final Color danger;
  final Color warningText;
  final Color warningBorder;
  final Color warningBg;
  final Color warningTextStrong;
  final Color info;
  final Color infoBg;
  final Color successBorder;
  final Color borderSoft;
  final Color borderCard;
  final Color bgSoft;
  final Color bgScreen;
  final Color bgCard;
  final Color bgSurface;

  final Color textSoft;
  final Color textDisabled;
  final Color macGreen;
  final Color macYellow;
  final Color macRed;

  final Color roleOperator;
  final Color roleVerifikator;
  final Color roleAdmin;
  final Color rolePetugas;
  final Color roleSurveyor;
  final Color roleAuditor;
  final Color roleWarga;
  final Color roleRtRw;
  final Color rolePengambilKeputusan;
  final Color roleExec;

  final Color mapBg;
  final Color mapGrid;
  final Color phoneBezel;

  const SigapColorScheme({
    required this.primary,
    required this.primaryHover,
    required this.primaryLight,
    required this.primaryDark,
    required this.perluTindakan,
    required this.diproses,
    required this.selesai,
    required this.success,
    required this.warning,
    required this.offlineBg,
    required this.offlineBorder,
    required this.offlineText,
    required this.offlineDot,
    required this.background,
    required this.surface,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textMuted,
    required this.text,
    required this.sidebarBg,
    required this.sidebarText,
    required this.sidebarTextHover,
    required this.sidebarTextMuted,
    required this.sidebarDivider,
    required this.sidebarAccent,
    required this.infoChartBar,
    required this.dangerTextStrong,
    required this.dangerBorder,
    required this.dangerBg,
    required this.danger,
    required this.warningText,
    required this.warningBorder,
    required this.warningBg,
    required this.warningTextStrong,
    required this.info,
    required this.infoBg,
    required this.successBorder,
    required this.borderSoft,
    required this.borderCard,
    required this.bgSoft,
    required this.bgScreen,
    required this.bgCard,
    required this.bgSurface,
    required this.textSoft,
    required this.textDisabled,
    required this.macGreen,
    required this.macYellow,
    required this.macRed,
    required this.roleOperator,
    required this.roleVerifikator,
    required this.roleAdmin,
    required this.rolePetugas,
    required this.roleSurveyor,
    required this.roleAuditor,
    required this.roleWarga,
    required this.roleRtRw,
    required this.rolePengambilKeputusan,
    required this.roleExec,
    required this.mapBg,
    required this.mapGrid,
    required this.phoneBezel,
  });

  static const light = SigapColorScheme(
    primary: Color(0xFF0F7A6B),
    primaryHover: Color(0xFF0D6A5D),
    primaryLight: Color(0xFFE2F1EE),
    primaryDark: Color(0xFF0A5C50),
    perluTindakan: Color(0xFFC0392B),
    diproses: Color(0xFF2563EB),
    selesai: Color(0xFF0F7A6B),
    success: Color(0xFF0F7A6B),
    warning: Color(0xFFB8730A),
    offlineBg: Color(0xFFF8ECD6),
    offlineBorder: Color(0xFFECD7A6),
    offlineText: Color(0xFF8A5808),
    offlineDot: Color(0xFFB8730A),
    background: Color(0xFFF4F5F3),
    surface: Color(0xFFFFFFFF),
    border: Color(0xFFE4E7E2),
    textPrimary: Color(0xFF17191C),
    textSecondary: Color(0xFF3A3F45),
    textTertiary: Color(0xFF616770),
    textMuted: Color(0xFF8A9099),
    text: Color(0xFF17191C),
    sidebarBg: Color(0xFF16302B),
    sidebarText: Color(0xFFE8EEF0),
    sidebarTextHover: Color(0xFFFFFFFF),
    sidebarTextMuted: Color(0xFF9DC0B9),
    sidebarDivider: Color(0xFF234A43),
    sidebarAccent: Color(0xFF7FA8A0),
    infoChartBar: Color(0xFFC7D7FB),
    dangerTextStrong: Color(0xFFA5271A),
    dangerBorder: Color(0xFFECC4BD),
    dangerBg: Color(0xFFF8E2DE),
    danger: Color(0xFFC0392B),
    warningText: Color(0xFF8A5808),
    warningBorder: Color(0xFFECD7A6),
    warningBg: Color(0xFFF8ECD6),
    warningTextStrong: Color(0xFF7A4D06),
    info: Color(0xFF2563EB),
    infoBg: Color(0xFFE5EDFD),
    successBorder: Color(0xFFBFE0D9),
    borderSoft: Color(0xFFD3D7D0),
    borderCard: Color(0xFFE4E7E2),
    bgSoft: Color(0xFFEEF0EC),
    bgScreen: Color(0xFFF9FAF8),
    bgCard: Color(0xFFFFFFFF),
    bgSurface: Color(0xFFF4F5F3),
    textSoft: Color(0xFF4A5058),
    textDisabled: Color(0xFF8A9099),
    macGreen: Color(0xFF66C07F),
    macYellow: Color(0xFFE8BD57),
    macRed: Color(0xFFE06C60),
    roleOperator: Color(0xFF2E7D32),
    roleVerifikator: Color(0xFF1565C0),
    roleAdmin: Color(0xFF6A1B9A),
    rolePetugas: Color(0xFFE65100),
    roleSurveyor: Color(0xFF00695C),
    roleAuditor: Color(0xFF4527A0),
    roleWarga: Color(0xFF558B2F),
    roleRtRw: Color(0xFF6D4C41),
    rolePengambilKeputusan: Color(0xFFC62828),
    roleExec: Color(0xFFC62828),
    mapBg: Color(0xFFEAEEE9),
    mapGrid: Color(0xFFDFE4DE),
    phoneBezel: Color(0xFF1F2226),
  );

  static const dark = SigapColorScheme(
    primary: Color(0xFF4DB6A5),
    primaryHover: Color(0xFF5FC9B7),
    primaryLight: Color(0xFF1A3D36),
    primaryDark: Color(0xFF6FCFBC),
    perluTindakan: Color(0xFFEF6B5B),
    diproses: Color(0xFF5B8DEF),
    selesai: Color(0xFF4DB6A5),
    success: Color(0xFF4DB6A5),
    warning: Color(0xFFD4A03A),
    offlineBg: Color(0xFF2D2518),
    offlineBorder: Color(0xFF3D3525),
    offlineText: Color(0xFFD4A03A),
    offlineDot: Color(0xFFD4A03A),
    background: Color(0xFF121416),
    surface: Color(0xFF1E2124),
    border: Color(0xFF2E3135),
    textPrimary: Color(0xFFE8EAED),
    textSecondary: Color(0xFFB0B5BA),
    textTertiary: Color(0xFF787D84),
    textMuted: Color(0xFF555A62),
    text: Color(0xFFE8EAED),
    sidebarBg: Color(0xFF0D1513),
    sidebarText: Color(0xFFE8EEF0),
    sidebarTextHover: Color(0xFFFFFFFF),
    sidebarTextMuted: Color(0xFF6B7D76),
    sidebarDivider: Color(0xFF1A2E28),
    sidebarAccent: Color(0xFF4A6B63),
    infoChartBar: Color(0xFF2A3A55),
    dangerTextStrong: Color(0xFFEF6B5B),
    dangerBorder: Color(0xFF4A2522),
    dangerBg: Color(0xFF2A1A19),
    danger: Color(0xFFEF6B5B),
    warningText: Color(0xFFD4A03A),
    warningBorder: Color(0xFF3D3525),
    warningBg: Color(0xFF2D2518),
    warningTextStrong: Color(0xFFE8B84A),
    info: Color(0xFF5B8DEF),
    infoBg: Color(0xFF1A2540),
    successBorder: Color(0xFF1A3D36),
    borderSoft: Color(0xFF252830),
    borderCard: Color(0xFF2E3135),
    bgSoft: Color(0xFF1A1D20),
    bgScreen: Color(0xFF0F1113),
    bgCard: Color(0xFF1E2124),
    bgSurface: Color(0xFF171A1D),
    textSoft: Color(0xFF9AA0A6),
    textDisabled: Color(0xFF555A62),
    macGreen: Color(0xFF4CAF50),
    macYellow: Color(0xFFFFC107),
    macRed: Color(0xFFE57373),
    roleOperator: Color(0xFF4CAF50),
    roleVerifikator: Color(0xFF42A5F5),
    roleAdmin: Color(0xFFBA68C8),
    rolePetugas: Color(0xFFFF9800),
    roleSurveyor: Color(0xFF26A69A),
    roleAuditor: Color(0xFF7E57C2),
    roleWarga: Color(0xFF8BC34A),
    roleRtRw: Color(0xFF8D6E63),
    rolePengambilKeputusan: Color(0xFFEF5350),
    roleExec: Color(0xFFEF5350),
    mapBg: Color(0xFF1A1D20),
    mapGrid: Color(0xFF252830),
    phoneBezel: Color(0xFF1F2226),
  );

  @override
  ThemeExtension<SigapColorScheme> copyWith({
    Color? primary,
    Color? primaryHover,
    Color? primaryLight,
    Color? primaryDark,
    Color? perluTindakan,
    Color? diproses,
    Color? selesai,
    Color? success,
    Color? warning,
    Color? offlineBg,
    Color? offlineBorder,
    Color? offlineText,
    Color? offlineDot,
    Color? background,
    Color? surface,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textMuted,
    Color? text,
    Color? sidebarBg,
    Color? sidebarText,
    Color? sidebarTextHover,
    Color? sidebarTextMuted,
    Color? sidebarDivider,
    Color? sidebarAccent,
    Color? infoChartBar,
    Color? dangerTextStrong,
    Color? dangerBorder,
    Color? dangerBg,
    Color? danger,
    Color? warningText,
    Color? warningBorder,
    Color? warningBg,
    Color? warningTextStrong,
    Color? info,
    Color? infoBg,
    Color? successBorder,
    Color? borderSoft,
    Color? borderCard,
    Color? bgSoft,
    Color? bgScreen,
    Color? bgCard,
    Color? bgSurface,
    Color? textSoft,
    Color? textDisabled,
    Color? macGreen,
    Color? macYellow,
    Color? macRed,
    Color? roleOperator,
    Color? roleVerifikator,
    Color? roleAdmin,
    Color? rolePetugas,
    Color? roleSurveyor,
    Color? roleAuditor,
    Color? roleWarga,
    Color? roleRtRw,
    Color? rolePengambilKeputusan,
    Color? roleExec,
    Color? mapBg,
    Color? mapGrid,
    Color? phoneBezel,
  }) {
    return SigapColorScheme(
      primary: primary ?? this.primary,
      primaryHover: primaryHover ?? this.primaryHover,
      primaryLight: primaryLight ?? this.primaryLight,
      primaryDark: primaryDark ?? this.primaryDark,
      perluTindakan: perluTindakan ?? this.perluTindakan,
      diproses: diproses ?? this.diproses,
      selesai: selesai ?? this.selesai,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      offlineBg: offlineBg ?? this.offlineBg,
      offlineBorder: offlineBorder ?? this.offlineBorder,
      offlineText: offlineText ?? this.offlineText,
      offlineDot: offlineDot ?? this.offlineDot,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      border: border ?? this.border,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      textMuted: textMuted ?? this.textMuted,
      text: text ?? this.text,
      sidebarBg: sidebarBg ?? this.sidebarBg,
      sidebarText: sidebarText ?? this.sidebarText,
      sidebarTextHover: sidebarTextHover ?? this.sidebarTextHover,
      sidebarTextMuted: sidebarTextMuted ?? this.sidebarTextMuted,
      sidebarDivider: sidebarDivider ?? this.sidebarDivider,
      sidebarAccent: sidebarAccent ?? this.sidebarAccent,
      infoChartBar: infoChartBar ?? this.infoChartBar,
      dangerTextStrong: dangerTextStrong ?? this.dangerTextStrong,
      dangerBorder: dangerBorder ?? this.dangerBorder,
      dangerBg: dangerBg ?? this.dangerBg,
      danger: danger ?? this.danger,
      warningText: warningText ?? this.warningText,
      warningBorder: warningBorder ?? this.warningBorder,
      warningBg: warningBg ?? this.warningBg,
      warningTextStrong: warningTextStrong ?? this.warningTextStrong,
      info: info ?? this.info,
      infoBg: infoBg ?? this.infoBg,
      successBorder: successBorder ?? this.successBorder,
      borderSoft: borderSoft ?? this.borderSoft,
      borderCard: borderCard ?? this.borderCard,
      bgSoft: bgSoft ?? this.bgSoft,
      bgScreen: bgScreen ?? this.bgScreen,
      bgCard: bgCard ?? this.bgCard,
      bgSurface: bgSurface ?? this.bgSurface,
      textSoft: textSoft ?? this.textSoft,
      textDisabled: textDisabled ?? this.textDisabled,
      macGreen: macGreen ?? this.macGreen,
      macYellow: macYellow ?? this.macYellow,
      macRed: macRed ?? this.macRed,
      roleOperator: roleOperator ?? this.roleOperator,
      roleVerifikator: roleVerifikator ?? this.roleVerifikator,
      roleAdmin: roleAdmin ?? this.roleAdmin,
      rolePetugas: rolePetugas ?? this.rolePetugas,
      roleSurveyor: roleSurveyor ?? this.roleSurveyor,
      roleAuditor: roleAuditor ?? this.roleAuditor,
      roleWarga: roleWarga ?? this.roleWarga,
      roleRtRw: roleRtRw ?? this.roleRtRw,
      rolePengambilKeputusan:
          rolePengambilKeputusan ?? this.rolePengambilKeputusan,
      roleExec: roleExec ?? this.roleExec,
      mapBg: mapBg ?? this.mapBg,
      mapGrid: mapGrid ?? this.mapGrid,
      phoneBezel: phoneBezel ?? this.phoneBezel,
    );
  }

  @override
  ThemeExtension<SigapColorScheme> lerp(
    covariant ThemeExtension<SigapColorScheme>? other,
    double t,
  ) {
    if (other is! SigapColorScheme) return this;
    return SigapColorScheme(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryHover: Color.lerp(primaryHover, other.primaryHover, t)!,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t)!,
      perluTindakan: Color.lerp(perluTindakan, other.perluTindakan, t)!,
      diproses: Color.lerp(diproses, other.diproses, t)!,
      selesai: Color.lerp(selesai, other.selesai, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      offlineBg: Color.lerp(offlineBg, other.offlineBg, t)!,
      offlineBorder: Color.lerp(offlineBorder, other.offlineBorder, t)!,
      offlineText: Color.lerp(offlineText, other.offlineText, t)!,
      offlineDot: Color.lerp(offlineDot, other.offlineDot, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      border: Color.lerp(border, other.border, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      text: Color.lerp(text, other.text, t)!,
      sidebarBg: Color.lerp(sidebarBg, other.sidebarBg, t)!,
      sidebarText: Color.lerp(sidebarText, other.sidebarText, t)!,
      sidebarTextHover: Color.lerp(
        sidebarTextHover,
        other.sidebarTextHover,
        t,
      )!,
      sidebarTextMuted: Color.lerp(
        sidebarTextMuted,
        other.sidebarTextMuted,
        t,
      )!,
      sidebarDivider: Color.lerp(sidebarDivider, other.sidebarDivider, t)!,
      sidebarAccent: Color.lerp(sidebarAccent, other.sidebarAccent, t)!,
      infoChartBar: Color.lerp(infoChartBar, other.infoChartBar, t)!,
      dangerTextStrong: Color.lerp(
        dangerTextStrong,
        other.dangerTextStrong,
        t,
      )!,
      dangerBorder: Color.lerp(dangerBorder, other.dangerBorder, t)!,
      dangerBg: Color.lerp(dangerBg, other.dangerBg, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      warningText: Color.lerp(warningText, other.warningText, t)!,
      warningBorder: Color.lerp(warningBorder, other.warningBorder, t)!,
      warningBg: Color.lerp(warningBg, other.warningBg, t)!,
      warningTextStrong: Color.lerp(
        warningTextStrong,
        other.warningTextStrong,
        t,
      )!,
      info: Color.lerp(info, other.info, t)!,
      infoBg: Color.lerp(infoBg, other.infoBg, t)!,
      successBorder: Color.lerp(successBorder, other.successBorder, t)!,
      borderSoft: Color.lerp(borderSoft, other.borderSoft, t)!,
      borderCard: Color.lerp(borderCard, other.borderCard, t)!,
      bgSoft: Color.lerp(bgSoft, other.bgSoft, t)!,
      bgScreen: Color.lerp(bgScreen, other.bgScreen, t)!,
      bgCard: Color.lerp(bgCard, other.bgCard, t)!,
      bgSurface: Color.lerp(bgSurface, other.bgSurface, t)!,
      textSoft: Color.lerp(textSoft, other.textSoft, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      macGreen: Color.lerp(macGreen, other.macGreen, t)!,
      macYellow: Color.lerp(macYellow, other.macYellow, t)!,
      macRed: Color.lerp(macRed, other.macRed, t)!,
      roleOperator: Color.lerp(roleOperator, other.roleOperator, t)!,
      roleVerifikator: Color.lerp(roleVerifikator, other.roleVerifikator, t)!,
      roleAdmin: Color.lerp(roleAdmin, other.roleAdmin, t)!,
      rolePetugas: Color.lerp(rolePetugas, other.rolePetugas, t)!,
      roleSurveyor: Color.lerp(roleSurveyor, other.roleSurveyor, t)!,
      roleAuditor: Color.lerp(roleAuditor, other.roleAuditor, t)!,
      roleWarga: Color.lerp(roleWarga, other.roleWarga, t)!,
      roleRtRw: Color.lerp(roleRtRw, other.roleRtRw, t)!,
      rolePengambilKeputusan: Color.lerp(
        rolePengambilKeputusan,
        other.rolePengambilKeputusan,
        t,
      )!,
      roleExec: Color.lerp(roleExec, other.roleExec, t)!,
      mapBg: Color.lerp(mapBg, other.mapBg, t)!,
      mapGrid: Color.lerp(mapGrid, other.mapGrid, t)!,
      phoneBezel: Color.lerp(phoneBezel, other.phoneBezel, t)!,
    );
  }

  static SigapColorScheme of(BuildContext context) {
    final extension = Theme.of(context).extension<SigapColorScheme>();
    if (extension != null) return extension;
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? dark : light;
  }
}

extension SigapColorSchemeContext on BuildContext {
  SigapColorScheme get sigapColors => SigapColorScheme.of(this);
}

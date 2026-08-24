/// Application radius definitions.
///
/// Provides 13 radius presets for consistent border radius across the app.
class SigapRadius {
  SigapRadius._();

  /// Extra small radius for compact elements.
  static const double xs = 4;

  /// Small radius for buttons and small surfaces.
  static const double sm = 8;

  /// Medium-small radius for input fields.
  static const double smMd = 9;

  /// Medium radius for cards and medium surfaces.
  static const double md = 10;

  /// Medium-large radius for larger cards.
  static const double mdLg = 12;

  /// Default radius for standard UI elements.
  static const double defaultRadius = 13;

  /// Large radius for large cards and containers.
  static const double lg = 14;

  /// Extra large radius for modals and dialogs.
  static const double xl = 16;

  /// 2x extra large radius for large surfaces.
  static const double xxl = 20;

  /// 3x extra large radius for drawers.
  static const double xxxl = 24;

  /// 4x extra large radius for very large surfaces.
  static const double xxxxl = 28;

  /// 5x extra large radius for full-width surfaces.
  static const double xxxxxl = 32;

  /// Large circular radius for pills.
  static const double pill = 999;
}

// ============================================================================
// SIGAP Responsive Breakpoint Helpers
// Parity with web breakpoints.ts (W2-4)
// 3 breakpoints: Mobile <600 / Tablet 600–1024 / Desktop >1024
// ============================================================================

/// Responsive breakpoints matching web/design system spec.
/// - Mobile: width < 600
/// - Tablet: 600 <= width <= 1024
/// - Desktop: width > 1024
class Breakpoints {
  Breakpoints._();

  /// Upper bound for mobile layout (exclusive).
  static const double mobile = 600;

  /// Upper bound for tablet layout (inclusive).
  /// Desktop starts above this value.
  static const double tablet = 1024;
}

/// Returns true when [width] qualifies as mobile (< 600).
bool isMobile(double width) => width < Breakpoints.mobile;

/// Returns true when [width] qualifies as tablet (600–1024 inclusive).
bool isTablet(double width) =>
    width >= Breakpoints.mobile && width <= Breakpoints.tablet;

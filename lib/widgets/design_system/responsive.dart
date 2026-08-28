import 'package:flutter/material.dart';

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

/// Returns true when [width] qualifies as desktop (> 1024).
bool isDesktop(double width) => width > Breakpoints.tablet;

/// Returns the current breakpoint label for a given width.
String breakpointName(double width) {
  if (isMobile(width)) return 'mobile';
  if (isTablet(width)) return 'tablet';
  return 'desktop';
}

// ---------------------------------------------------------------------------
// ResponsiveValue<T>
// ---------------------------------------------------------------------------

/// A nullable responsive value holder returned by [ResponsiveValue.of].
class ResponsiveValue<T> {
  final T? mobile;
  final T? tablet;
  final T? desktop;

  const ResponsiveValue({this.mobile, this.tablet, this.desktop});

  /// Returns the appropriate value for the current [width].
  T? resolve(double width) {
    if (isMobile(width)) return mobile;
    if (isTablet(width)) return tablet;
    return desktop;
  }
}

/// A [ContextWidget] that resolves the appropriate widget from its
/// [mobile], [tablet], and [desktop] variants based on the current
/// layout width from [LayoutBuilder].
///
/// All three variants are optional; if a variant is null, it falls back
/// to the next larger breakpoint's value (mobile → tablet → desktop).
///
/// Example:
/// ```dart
/// ResponsiveWidget(
///   mobile: Text('Mobile'),
///   tablet: Text('Tablet'),
///   desktop: Text('Desktop'),
/// )
/// ```
class ResponsiveWidget extends StatelessWidget {
  final Widget? mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveWidget({super.key, this.mobile, this.tablet, this.desktop});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        if (isMobile(w)) {
          return mobile ?? tablet ?? desktop ?? const SizedBox.shrink();
        }
        if (isTablet(w)) {
          return tablet ?? desktop ?? mobile ?? const SizedBox.shrink();
        }
        return desktop ?? mobile ?? const SizedBox.shrink();
      },
    );
  }
}

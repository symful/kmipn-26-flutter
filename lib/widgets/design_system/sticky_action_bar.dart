import 'package:flutter/material.dart';
import 'package:sigap/theme/tokens.dart';
import 'package:sigap/widgets/design_system/responsive.dart';

/// StickyActionBar — adaptive action bar that changes behavior by breakpoint.
///
/// Spec (guide.txt §S-02, §S-04, §M-11):
/// - Mobile:  bottom-fixed bar via [Positioned] + [Stack] or [BottomAppBar];
///            safe-area aware; 1–2 primary actions with min 48px tap target.
/// - Tablet+: inline top/side action row (no sticky; just a padded row).
///
/// Uses [Breakpoints] for responsive decisions.
class StickyActionBar extends StatelessWidget {
  const StickyActionBar({
    super.key,
    required this.actions,
    this.label,
    this.stickyOnMobile = true,
    this.backgroundColor,
    this.height,
  });

  /// Primary action widgets (1–2 buttons). Each must be min 48px tall/wide.
  final List<Widget> actions;

  /// Optional left-side label shown before the actions (e.g. "Aksi kasus:").
  final String? label;

  /// When true (default), the bar sticks to the bottom on mobile.
  /// When false, the bar is always inline regardless of breakpoint.
  final bool stickyOnMobile;

  /// Override background color. Defaults to [SigapColors.surface].
  final Color? backgroundColor;

  /// Custom height for the action bar. Defaults to 72px on mobile.
  final double? height;

  @override
  Widget build(BuildContext context) {
    if (!stickyOnMobile) {
      return _InlineBar(
        actions: actions,
        label: label,
        backgroundColor: backgroundColor,
        height: height,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobileLayout = isMobile(constraints.maxWidth);

        if (isMobileLayout) {
          return _StickyMobileBar(
            actions: actions,
            backgroundColor: backgroundColor,
            height: height,
          );
        }

        return _InlineBar(
          actions: actions,
          label: label,
          backgroundColor: backgroundColor,
          height: height,
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Sticky mobile bar (Positioned + Stack)
// ---------------------------------------------------------------------------

class _StickyMobileBar extends StatelessWidget {
  const _StickyMobileBar({
    required this.actions,
    required this.backgroundColor,
    required this.height,
  });

  final List<Widget> actions;
  final Color? backgroundColor;
  final double? height;

  static const double _defaultHeight = 72.0;

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.of(context).padding.bottom;

    return SizedBox(
      height: (height ?? _defaultHeight) + safeBottom,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: (height ?? _defaultHeight) + safeBottom,
              decoration: BoxDecoration(
                color: backgroundColor ?? SigapColors.surface,
                border: const Border(
                  top: BorderSide(color: SigapColors.border, width: 1),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  left: SigapSpacing.lg,
                  right: SigapSpacing.lg,
                  top: SigapSpacing.md,
                  bottom: safeBottom + SigapSpacing.md,
                ),
                child: Row(
                  children: [
                    if (actions.isNotEmpty) ...[
                      for (int i = 0; i < actions.length; i++) ...[
                        if (i > 0) const SizedBox(width: SigapSpacing.sm),
                        Expanded(child: actions[i]),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Inline bar (tablet / desktop)
// ---------------------------------------------------------------------------

class _InlineBar extends StatelessWidget {
  const _InlineBar({
    required this.actions,
    required this.label,
    required this.backgroundColor,
    required this.height,
  });

  final List<Widget> actions;
  final String? label;
  final Color? backgroundColor;
  final double? height;

  static const double _defaultHeight = 64.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? _defaultHeight,
      decoration: BoxDecoration(
        color: backgroundColor ?? SigapColors.surface,
        border: const Border(
          top: BorderSide(color: SigapColors.border, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: SigapSpacing.xl,
        vertical: SigapSpacing.sm,
      ),
      child: Row(
        children: [
          if (label != null) ...[
            Padding(
              padding: const EdgeInsets.only(right: SigapSpacing.md),
              child: Text(
                label!,
                style: TextStyle(
                  fontSize: SigapTypography.size13,
                  fontWeight: FontWeight.w500,
                  color: SigapColors.textSecondary,
                ),
              ),
            ),
          ],
          if (actions.isNotEmpty) ...[
            for (int i = 0; i < actions.length; i++) ...[
              if (i > 0) const SizedBox(width: SigapSpacing.sm),
              actions[i],
            ],
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Convenience primary button factory (SigapColors.primary, min 48px)
// ---------------------------------------------------------------------------

/// Creates a primary action button for [StickyActionBar] with:
/// - [SigapColors.primary] background
/// - min height 48px (tap target)
/// - [Semantics] label for accessibility
class SigapActionButton extends StatelessWidget {
  const SigapActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.semanticsLabel,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel ?? label,
      button: true,
      enabled: onPressed != null,
      child: SizedBox(
        height: 48,
        child: icon != null
            ? FilledButton.icon(
                onPressed: onPressed,
                icon: Icon(icon, size: 20),
                label: Text(label),
                style: FilledButton.styleFrom(
                  backgroundColor: SigapColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 48),
                  padding: const EdgeInsets.symmetric(
                    horizontal: SigapSpacing.lg,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(SigapRadius.x8),
                  ),
                ),
              )
            : FilledButton(
                onPressed: onPressed,
                style: FilledButton.styleFrom(
                  backgroundColor: SigapColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 48),
                  padding: const EdgeInsets.symmetric(
                    horizontal: SigapSpacing.lg,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(SigapRadius.x8),
                  ),
                ),
                child: Text(label),
              ),
      ),
    );
  }
}

/// Creates an outline action button for [StickyActionBar] with:
/// - [SigapColors.primary] border/text, transparent background
/// - min 48px tap target
/// - [Semantics] label for accessibility
class SigapOutlineButton extends StatelessWidget {
  const SigapOutlineButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.semanticsLabel,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel ?? label,
      button: true,
      enabled: onPressed != null,
      child: SizedBox(
        height: 48,
        child: icon != null
            ? OutlinedButton.icon(
                onPressed: onPressed,
                icon: Icon(icon, size: 20),
                label: Text(label),
                style: OutlinedButton.styleFrom(
                  foregroundColor: SigapColors.primary,
                  minimumSize: const Size(0, 48),
                  padding: const EdgeInsets.symmetric(
                    horizontal: SigapSpacing.lg,
                  ),
                  side: const BorderSide(color: SigapColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(SigapRadius.x8),
                  ),
                ),
              )
            : OutlinedButton(
                onPressed: onPressed,
                style: OutlinedButton.styleFrom(
                  foregroundColor: SigapColors.primary,
                  minimumSize: const Size(0, 48),
                  padding: const EdgeInsets.symmetric(
                    horizontal: SigapSpacing.lg,
                  ),
                  side: const BorderSide(color: SigapColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(SigapRadius.x8),
                  ),
                ),
                child: Text(label),
              ),
      ),
    );
  }
}

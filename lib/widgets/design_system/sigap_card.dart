import 'package:flutter/material.dart';
import 'package:sigap/theme/tokens.dart';

/// SigapCard — canonical card widget for the SIGAP design system.
///
/// Card spec (guide §4, §5.2):
/// - Radius 12, 1px [SigapColors.border] border, [SigapColors.surface] fill.
/// - Optional left border (4px) = severity indicator (e.g. perluTindakan, diproses).
/// - Optional top border (3px) = status indicator (e.g. selesai, warning).
class SigapCard extends StatelessWidget {
  /// The content of the card.
  final Widget child;

  /// When set, draws a 4px left border in this color to indicate severity.
  final Color? borderLeftColor;

  /// When set, draws a 3px top border in this color to indicate status.
  final Color? borderTopColor;

  /// Inner padding. Defaults to 16px all sides.
  final EdgeInsets? padding;

  const SigapCard({
    super.key,
    required this.child,
    this.borderLeftColor,
    this.borderTopColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    // Flutter only allows borderRadius on BoxDecoration when the border has
    // uniform color on all sides. To support per-side colored borders (severity
    // left, status top) with rounded corners, we use a Stack:
    //   1. Base card with uniform 1px border + radius (clipped to rounded rect)
    //   2. Positioned left border (4px, colored) if borderLeftColor is set
    //   3. Positioned top border (3px, colored) if borderTopColor is set
    // The child sits inside ClipRRect so it respects the card radius.
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Base card with uniform border + radius
        Container(
          decoration: BoxDecoration(
            color: SigapColors.surface,
            borderRadius: BorderRadius.circular(SigapRadius.x12),
            border: Border.all(color: SigapColors.border),
          ),
          padding: padding ?? const EdgeInsets.all(16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(SigapRadius.x12),
            child: child,
          ),
        ),
        // Left colored border (severity) — 4px
        if (borderLeftColor != null)
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 4,
            child: Container(
              decoration: BoxDecoration(
                color: borderLeftColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(SigapRadius.x12),
                  bottomLeft: Radius.circular(SigapRadius.x12),
                ),
              ),
            ),
          ),
        // Top colored border (status) — 3px
        if (borderTopColor != null)
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: 3,
            child: Container(
              decoration: BoxDecoration(
                color: borderTopColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(SigapRadius.x12),
                  topRight: Radius.circular(SigapRadius.x12),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

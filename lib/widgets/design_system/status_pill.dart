import 'package:flutter/material.dart';
import 'package:sigap/theme/tokens.dart';

/// Tone variants for [StatusPill].
/// Maps to teal/amber/red/blue/grey semantic palette.
enum StatusTone { success, warning, danger, info, neutral }

/// Deprecated: use [StatusTone] instead of [StatusPillVariant].
@Deprecated('Use StatusTone instead')
enum StatusPillVariant { success, warning, danger, info, neutral, pill }

/// Canonical status pill widget with severity dot and tone variants.
///
/// **Spec (guide.txt §4):** 7px dot + 11px/600 text, radius 6, padding(8,4).
/// Tones: success (teal), warning (amber), danger (red), info (blue), neutral (grey).
class StatusPill extends StatelessWidget {
  /// Creates a [StatusPill] with explicit [StatusTone].
  ///
  /// - [label]: text shown in the pill
  /// - [tone]: severity tone (success/warning/danger/info/neutral)
  /// - [showDot]: whether to render the 7px severity dot (default true)
  /// - [borderLeft]: whether to add a 4px left border in tone color (default false)
  const StatusPill({
    super.key,
    required this.label,
    required this.tone,
    this.showDot = true,
    this.borderLeft = false,
  });

  /// Deprecated: use [StatusPill] with [StatusTone] instead.
  @Deprecated('Use StatusPill(label:, tone:) instead')
  StatusPill.variant({
    super.key,
    required this.label,
    required StatusPillVariant variant,
  }) : tone = _variantToTone(variant),
       showDot = true,
       borderLeft = false;

  final String label;
  final StatusTone tone;
  final bool showDot;
  final bool borderLeft;

  static StatusTone _variantToTone(StatusPillVariant variant) {
    switch (variant) {
      case StatusPillVariant.success:
        return StatusTone.success;
      case StatusPillVariant.warning:
        return StatusTone.warning;
      case StatusPillVariant.danger:
        return StatusTone.danger;
      case StatusPillVariant.info:
        return StatusTone.info;
      case StatusPillVariant.neutral:
        return StatusTone.neutral;
      case StatusPillVariant.pill:
        return StatusTone.neutral;
    }
  }

  // --- Tone config helpers ---

  Color get _dotColor {
    switch (tone) {
      case StatusTone.success:
        return SigapColors.success;
      case StatusTone.warning:
        return SigapColors.warning;
      case StatusTone.danger:
        return SigapColors.danger;
      case StatusTone.info:
        return SigapColors.info;
      case StatusTone.neutral:
        return SigapColors.textDisabled;
    }
  }

  Color get _backgroundColor {
    switch (tone) {
      case StatusTone.success:
        return SigapColors.success.withValues(alpha: 0.1);
      case StatusTone.warning:
        return SigapColors.warningBg;
      case StatusTone.danger:
        return SigapColors.dangerBg;
      case StatusTone.info:
        return SigapColors.infoBg;
      case StatusTone.neutral:
        return SigapColors.textDisabled.withValues(alpha: 0.1);
    }
  }

  Color get _textColor {
    switch (tone) {
      case StatusTone.success:
        return SigapColors.success;
      case StatusTone.warning:
        return SigapColors.warningText;
      case StatusTone.danger:
        return SigapColors.danger;
      case StatusTone.info:
        return SigapColors.info;
      case StatusTone.neutral:
        return SigapColors.textDisabled;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(6),
        border: borderLeft
            ? Border(left: BorderSide(color: _dotColor, width: 4))
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: _dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: SigapTypography.size11,
              fontWeight: FontWeight.w600,
              color: _textColor,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:sigap/theme/tokens.dart';

/// Status badge for inline status indicators.
///
/// Renders a colored badge with text label, used across multiple screens
/// for displaying status states. Similar to [StatusPill] but with explicit
/// color control for custom status colors.
///
/// **Design spec:** Container with colored background, text, radius
/// [SigapRadius.x6] (6px), padding (8, 4).
class StatusBadge extends StatelessWidget {
  /// The status label text.
  final String label;

  /// Background color of the badge.
  final Color backgroundColor;

  /// Text color of the label.
  final Color textColor;

  const StatusBadge({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  /// Creates a [StatusBadge] with predefined tone presets.
  StatusBadge.tone({
    super.key,
    required this.label,
    required StatusBadgeTone tone,
  }) : backgroundColor = _toneBackground(tone),
       textColor = _toneText(tone);

  static Color _toneBackground(StatusBadgeTone tone) {
    switch (tone) {
      case StatusBadgeTone.success:
        return SigapColors.success.withValues(alpha: 0.1);
      case StatusBadgeTone.warning:
        return SigapColors.warningBg;
      case StatusBadgeTone.danger:
        return SigapColors.dangerBg;
      case StatusBadgeTone.info:
        return SigapColors.infoBg;
      case StatusBadgeTone.neutral:
        return SigapColors.bgSoft;
    }
  }

  static Color _toneText(StatusBadgeTone tone) {
    switch (tone) {
      case StatusBadgeTone.success:
        return SigapColors.success;
      case StatusBadgeTone.warning:
        return SigapColors.warningTextStrong;
      case StatusBadgeTone.danger:
        return SigapColors.danger;
      case StatusBadgeTone.info:
        return SigapColors.info;
      case StatusBadgeTone.neutral:
        return SigapColors.textTertiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SigapSpacing.sm,
        vertical: SigapSpacing.x4,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(SigapRadius.x6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: SigapTypography.captionMedium,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

/// Semantic tone presets for [StatusBadge.tone] constructor.
enum StatusBadgeTone { success, warning, danger, info, neutral }

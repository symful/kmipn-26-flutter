import 'package:flutter/material.dart';
import 'package:sigap/theme/tokens.dart';

enum StatusPillVariant { success, warning, danger, info, neutral, pill }

class StatusPill extends StatelessWidget {
  final String label;
  final StatusPillVariant variant;

  const StatusPill({super.key, required this.label, required this.variant});

  Color get _dotColor {
    switch (variant) {
      case StatusPillVariant.success:
        return SigapColors.primary;
      case StatusPillVariant.warning:
        return SigapColors.warning;
      case StatusPillVariant.danger:
        return SigapColors.danger;
      case StatusPillVariant.info:
        return SigapColors.info;
      case StatusPillVariant.neutral:
        return SigapColors.textDisabled;
      case StatusPillVariant.pill:
        return SigapColors.primary;
    }
  }

  Color get _textColor {
    switch (variant) {
      case StatusPillVariant.success:
        return SigapColors.primary;
      case StatusPillVariant.warning:
        return SigapColors.warningText;
      case StatusPillVariant.danger:
        return SigapColors.danger;
      case StatusPillVariant.info:
        return SigapColors.info;
      case StatusPillVariant.neutral:
        return SigapColors.textDisabled;
      case StatusPillVariant.pill:
        return SigapColors.textTertiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _dotColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: _dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
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

import 'package:flutter/material.dart';

enum StatusPillVariant { success, warning, danger, info, neutral, pill }

class StatusPill extends StatelessWidget {
  final String label;
  final StatusPillVariant variant;

  const StatusPill({super.key, required this.label, required this.variant});

  Color get _dotColor {
    switch (variant) {
      case StatusPillVariant.success:
        return const Color(0xFF0F7A6B);
      case StatusPillVariant.warning:
        return const Color(0xFFB8730A);
      case StatusPillVariant.danger:
        return const Color(0xFFC0392B);
      case StatusPillVariant.info:
        return const Color(0xFF2563EB);
      case StatusPillVariant.neutral:
        return const Color(0xFF8A9099);
      case StatusPillVariant.pill:
        return const Color(0xFF0F7A6B);
    }
  }

  Color get _textColor {
    switch (variant) {
      case StatusPillVariant.success:
        return const Color(0xFF0F7A6B);
      case StatusPillVariant.warning:
        return const Color(0xFF8A5808);
      case StatusPillVariant.danger:
        return const Color(0xFFC0392B);
      case StatusPillVariant.info:
        return const Color(0xFF2563EB);
      case StatusPillVariant.neutral:
        return const Color(0xFF8A9099);
      case StatusPillVariant.pill:
        return const Color(0xFF616770);
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
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _textColor,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'package:kmipn_26/theme/tokens.dart';

enum TimelineVariant { amber, teal, gray }

class TimelineEvent extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? actor;
  final TimelineVariant variant;
  final bool isLast;

  const TimelineEvent({
    super.key,
    required this.title,
    required this.subtitle,
    this.actor,
    required this.variant,
    this.isLast = false,
  });

  Color get _dotColor {
    switch (variant) {
      case TimelineVariant.amber:
        return SigapColors.warning;
      case TimelineVariant.teal:
        return SigapColors.primary;
      case TimelineVariant.gray:
        return SigapColors.textDisabled;
    }
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                    color: _dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(width: 2, color: SigapColors.borderCard),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: SigapColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: SigapColors.textTertiary,
                  ),
                ),
                if (actor != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    actor!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: SigapColors.textDisabled,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

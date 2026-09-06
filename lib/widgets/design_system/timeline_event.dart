import 'package:sigap/theme/sigap_color_scheme.dart';
import 'package:flutter/material.dart';

import 'package:sigap/theme/tokens.dart';

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

  Color _dotColor(BuildContext context) {
    switch (variant) {
      case TimelineVariant.amber:
        return SigapColorScheme.of(context).warning;
      case TimelineVariant.teal:
        return SigapColors.primary;
      case TimelineVariant.gray:
        return SigapColorScheme.of(context).textMuted;
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
                    color: _dotColor(context),
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: SigapColorScheme.of(context).borderCard,
                    ),
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
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: SigapColorScheme.of(context).textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: SigapColorScheme.of(context).textTertiary,
                  ),
                ),
                if (actor != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    actor!,
                    style: TextStyle(
                      fontSize: 11,
                      color: SigapColorScheme.of(context).textMuted,
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

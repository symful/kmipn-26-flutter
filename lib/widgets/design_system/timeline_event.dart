import 'package:flutter/material.dart';

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
        return const Color(0xFFB8730A);
      case TimelineVariant.teal:
        return const Color(0xFF0F7A6B);
      case TimelineVariant.gray:
        return const Color(0xFF8A9099);
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
                    child: Container(width: 2, color: const Color(0xFFE4E7E2)),
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
                    color: Color(0xFF3A3F45),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF616770),
                  ),
                ),
                if (actor != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    actor!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF8A9099),
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

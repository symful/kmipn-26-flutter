import 'package:sigap/theme/sigap_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:sigap/theme/tokens.dart';

/// A simple progress bar row (without the card wrapper).
class ProgressRow extends StatelessWidget {
  const ProgressRow({
    super.key,
    required this.label,
    required this.percentage,
    required this.color,
    int? count,
  }) : _count = count;

  final String label;
  final int percentage;
  final Color color;
  final int? _count;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: SigapTypography.bodyText,
                  color: SigapColorScheme.of(context).textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _count == null ? '$percentage%' : '$_count ($percentage%)',
              style: TextStyle(
                fontSize: SigapTypography.bodyText,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: SigapSpacing.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: color.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: SigapSpacing.sm),
      ],
    );
  }
}

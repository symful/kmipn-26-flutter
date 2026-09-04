import 'package:flutter/material.dart';
import 'package:sigap/theme/tokens.dart';
import 'package:sigap/widgets/design_system/sigap_card.dart';

/// A card showing a metric with a progress bar and optional subtitle.
///
/// Usage:
/// ```dart
/// ProgressMetricCard(
///   label: 'Tepat Waktu',
///   percentage: 85,
///   color: SigapColors.selesai,
///   subtitle: '10 kasus berisiko SLA',
/// )
/// ```
class ProgressMetricCard extends StatelessWidget {
  /// Creates a [ProgressMetricCard].
  ///
  /// - [label]: Title text for the metric
  /// - [percentage]: Progress percentage (0-100)
  /// - [color]: Color for the progress bar and percentage text
  /// - [subtitle]: Optional text shown below the progress bar
  const ProgressMetricCard({
    super.key,
    required this.label,
    required this.percentage,
    required this.color,
    this.subtitle,
  });

  /// Title text for the metric row.
  final String label;

  /// Progress percentage (0-100).
  final int percentage;

  /// Color for the progress bar and percentage display.
  final Color color;

  /// Optional subtitle text below the progress bar.
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return SigapCard(
      padding: const EdgeInsets.all(SigapSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          label,
                          style: const TextStyle(
                            fontSize: SigapTypography.captionMedium,
                            color: SigapColors.textMuted,
                          ),
                        ),
                        Text(
                          '$percentage%',
                          style: TextStyle(
                            fontSize: SigapTypography.bodySmall,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: SigapSpacing.xs),
                    LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: color.withValues(alpha: 0.15),
                      valueColor: AlwaysStoppedAnimation(color),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: SigapSpacing.sm),
            Text(
              subtitle!,
              style: const TextStyle(
                fontSize: SigapTypography.captionMedium,
                color: SigapColors.textTertiary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

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
            Text(
              label,
              style: const TextStyle(
                fontSize: SigapTypography.bodyText,
                color: SigapColors.textPrimary,
              ),
            ),
            Text(
              '${_count ?? percentage} ($percentage%)',
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

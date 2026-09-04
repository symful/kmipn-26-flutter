import 'package:flutter/material.dart';
import 'package:sigap/theme/tokens.dart';
import 'package:sigap/widgets/design_system/sigap_card.dart';

/// A reusable metric/stat card widget.
///
/// Displays a label, large value, and optional icon with consistent styling.
///
/// Usage:
/// ```dart
/// MetricCard(
///   label: 'Total Kasus',
///   value: '42',
///   color: SigapColors.primary,
/// )
/// ```
class MetricCard extends StatelessWidget {
  /// Creates a [MetricCard] with explicit styling.
  ///
  /// - [label]: Small descriptive text above the value
  /// - [value]: Large numeric/text value
  /// - [color]: Accent color for the value text
  /// - [icon]: Optional leading icon (displayed in a colored container)
  /// - [severityColor]: Optional left border color (e.g. for status indicators)
  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    this.icon,
    this.severityColor,
  });

  /// Short descriptive label (e.g. "Total Kasus").
  final String label;

  /// Primary metric value (e.g. "42", "99%", "12.5K").
  final String value;

  /// Accent color for the value text.
  final Color color;

  /// Optional leading icon.
  final IconData? icon;

  /// Optional left border color for severity indicators.
  final Color? severityColor;

  @override
  Widget build(BuildContext context) {
    final cardContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: SigapTypography.captionMedium,
            fontWeight: FontWeight.w500,
            color: SigapColors.textMuted,
          ),
        ),
        const SizedBox(height: SigapSpacing.xs),
        Text(
          value,
          style: TextStyle(
            fontSize: SigapTypography.headlineLarge,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );

    if (icon != null) {
      return SigapCard(
        borderLeftColor: severityColor,
        padding: const EdgeInsets.all(SigapSpacing.md),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(SigapSpacing.sm),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(SigapRadius.sm),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: SigapSpacing.md),
            Expanded(child: cardContent),
          ],
        ),
      );
    }

    if (severityColor != null) {
      return SigapCard(
        borderLeftColor: severityColor,
        padding: const EdgeInsets.all(SigapSpacing.md),
        child: cardContent,
      );
    }

    return SigapCard(
      padding: const EdgeInsets.all(SigapSpacing.md),
      child: cardContent,
    );
  }
}

/// KPI Card variant with larger value text (for executive dashboards).
class KPICard extends StatelessWidget {
  const KPICard({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: SigapTypography.captionMedium,
            color: SigapColors.textMuted,
          ),
        ),
        const SizedBox(height: SigapSpacing.xs),
        Text(
          value,
          style: TextStyle(
            fontSize: SigapTypography.heroText,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );

    if (icon != null) {
      return SigapCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(SigapSpacing.sm),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(SigapRadius.sm),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: SigapSpacing.md),
            content,
          ],
        ),
      );
    }

    return SigapCard(child: content);
  }
}

/// Queue card variant for dashboard rows (compact, no padding waste).
class QueueCard extends StatelessWidget {
  const QueueCard({
    super.key,
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SigapSpacing.md),
      decoration: BoxDecoration(
        color: SigapColors.surface,
        borderRadius: BorderRadius.circular(SigapRadius.md),
        border: Border.all(color: SigapColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: SigapTypography.headlineMedium,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: SigapSpacing.xxs),
          Text(
            label,
            style: const TextStyle(
              fontSize: SigapTypography.captionSmall,
              color: SigapColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

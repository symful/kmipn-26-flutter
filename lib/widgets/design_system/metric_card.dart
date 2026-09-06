import 'package:sigap/theme/sigap_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:sigap/theme/tokens.dart';
import 'package:sigap/widgets/design_system/sigap_card.dart';

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
          style: TextStyle(
            fontSize: SigapTypography.captionMedium,
            color: SigapColorScheme.of(context).textMuted,
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

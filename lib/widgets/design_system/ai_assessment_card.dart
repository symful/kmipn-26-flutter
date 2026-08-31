import 'package:flutter/material.dart';
import 'package:sigap/theme/tokens.dart';

/// Displays AI-generated assessment results for a case.
///
/// Renders confidence score, supporting factors, risk factors,
/// and duplicate correlation IDs derived from the AI assessment pipeline.
class AiAssessmentCard extends StatelessWidget {
  /// Assessment data map with keys:
  /// - `confidence` (double): confidence score 0–1
  /// - `factors` (Map): `{ supporting: List<String>, risk: List<String>, correlation_ids: List<String> }`
  final Map<String, dynamic> assessment;

  const AiAssessmentCard({super.key, required this.assessment});

  @override
  Widget build(BuildContext context) {
    final confidence = (assessment['confidence'] as num?)?.toDouble() ?? 0.0;
    final factors = assessment['factors'] as Map<String, dynamic>? ?? {};
    final supporting = (factors['supporting'] as List?)?.cast<String>() ?? [];
    final risks = (factors['risk'] as List?)?.cast<String>() ?? [];
    final correlationIds =
        (factors['correlation_ids'] as List?)?.cast<String>() ?? [];

    final confidencePct = (confidence * 100).clamp(0, 100).toInt();
    final confidenceColor = confidence >= 0.7
        ? SigapColors.success
        : confidence >= 0.4
        ? SigapColors.warning
        : SigapColors.danger;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: SigapColors.border),
        borderRadius: BorderRadius.circular(SigapRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Confidence header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(SigapSpacing.md),
            decoration: BoxDecoration(
              color: confidenceColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(SigapRadius.md - 1),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.psychology_outlined,
                  color: confidenceColor,
                  size: 18,
                ),
                const SizedBox(width: SigapSpacing.sm),
                Text(
                  'Confidence',
                  style: TextStyle(
                    fontSize: SigapTypography.size13,
                    fontWeight: FontWeight.w600,
                    color: SigapColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SigapSpacing.sm,
                    vertical: SigapSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: confidenceColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(SigapRadius.pill),
                  ),
                  child: Text(
                    '$confidencePct%',
                    style: TextStyle(
                      fontSize: SigapTypography.size13,
                      fontWeight: FontWeight.w700,
                      color: confidenceColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(SigapSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (supporting.isNotEmpty) ...[
                  _FactorList(
                    title: 'Supporting Factors',
                    icon: Icons.thumb_up_outlined,
                    color: SigapColors.success,
                    items: supporting,
                  ),
                  const SizedBox(height: SigapSpacing.md),
                ],
                if (risks.isNotEmpty) ...[
                  _FactorList(
                    title: 'Risk Factors',
                    icon: Icons.warning_amber_outlined,
                    color: SigapColors.danger,
                    items: risks,
                  ),
                  const SizedBox(height: SigapSpacing.md),
                ],
                if (correlationIds.isNotEmpty) ...[
                  _CorrelationIds(correlationIds: correlationIds),
                ],
                if (supporting.isEmpty &&
                    risks.isEmpty &&
                    correlationIds.isEmpty)
                  Text(
                    'No assessment factors available.',
                    style: TextStyle(
                      fontSize: SigapTypography.size13,
                      color: SigapColors.textMuted,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FactorList extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<String> items;

  const _FactorList({
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: SigapSpacing.xs),
            Text(
              title,
              style: TextStyle(
                fontSize: SigapTypography.size12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: SigapSpacing.xs),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(
              left: SigapSpacing.lg,
              bottom: SigapSpacing.xxs,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '• ',
                  style: TextStyle(
                    color: color,
                    fontSize: SigapTypography.size13,
                  ),
                ),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: SigapTypography.size13,
                      color: SigapColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CorrelationIds extends StatelessWidget {
  final List<String> correlationIds;

  const _CorrelationIds({required this.correlationIds});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.link, color: SigapColors.info, size: 14),
            const SizedBox(width: SigapSpacing.xs),
            Text(
              'Duplicate Candidates',
              style: TextStyle(
                fontSize: SigapTypography.size12,
                fontWeight: FontWeight.w600,
                color: SigapColors.info,
              ),
            ),
          ],
        ),
        const SizedBox(height: SigapSpacing.xs),
        Wrap(
          spacing: SigapSpacing.xs,
          runSpacing: SigapSpacing.xs,
          children: correlationIds
              .map(
                (id) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SigapSpacing.sm,
                    vertical: SigapSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: SigapColors.infoBg,
                    borderRadius: BorderRadius.circular(SigapRadius.sm),
                  ),
                  child: Text(
                    id,
                    style: TextStyle(
                      fontSize: SigapTypography.size11,
                      color: SigapColors.info,
                      fontFamily: SigapTypography.fontFamilyMono,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

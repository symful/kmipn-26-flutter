import 'package:flutter/material.dart';
import '../../theme/tokens.dart';

/// Displays a priority score with color coding, override badge, factor breakdown bars,
/// and an optional "Adjust" button that opens a priority adjustment dialog.
///
/// Score color thresholds:
/// - 0-33: Red (low priority)
/// - 34-66: Amber (medium priority)
/// - 67-100: Green (high priority)
class PriorityScoreCard extends StatelessWidget {
  /// The computed priority score (0-100).
  final double computedScore;

  /// Override score if manually set, otherwise null.
  final double? overrideScore;

  /// Reason for the override (only shown to operator/auditor).
  final String? overrideReason;

  /// Who set the override.
  final String? overrideBy;

  /// When the override was set.
  final DateTime? overriddenAt;

  /// Factor breakdown showing severity, impact, vulnerability, and SLA components.
  /// Each entry maps factor name to its 0-100 score.
  final Map<String, double>? factorBreakdown;

  /// Callback when the Adjust button is pressed.
  /// If null, the Adjust button is hidden.
  final VoidCallback? onAdjust;

  const PriorityScoreCard({
    super.key,
    required this.computedScore,
    this.overrideScore,
    this.overrideReason,
    this.overrideBy,
    this.overriddenAt,
    this.factorBreakdown,
    this.onAdjust,
  });

  /// Returns the color for a given score.
  /// 0-33: red, 34-66: amber, 67-100: green
  static Color scoreColor(double score) {
    if (score <= 33) return SigapColors.perluTindakan;
    if (score <= 66) return Colors.orange;
    return SigapColors.selesai;
  }

  Color get _scoreColor => scoreColor(displayScore);
  double get displayScore => overrideScore ?? computedScore;

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
        children: [
          // Header row: score + override badge + adjust button
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Large score number
              Text(
                displayScore.round().toString(),
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: _scoreColor,
                ),
              ),
              const SizedBox(width: SigapSpacing.sm),
              Text(
                '/ 100',
                style: TextStyle(fontSize: 16, color: SigapColors.textMuted),
              ),
              const SizedBox(width: SigapSpacing.md),
              // Override badge
              if (overrideScore != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SigapSpacing.sm,
                    vertical: SigapSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(SigapRadius.sm),
                    border: Border.all(
                      color: Colors.amber.withValues(alpha: 0.4),
                    ),
                  ),
                  child: const Text(
                    'Override',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.amber,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              if (onAdjust != null)
                TextButton.icon(
                  onPressed: onAdjust,
                  icon: const Icon(Icons.tune, size: 16),
                  label: const Text('Adjust'),
                  style: TextButton.styleFrom(
                    foregroundColor: SigapColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: SigapSpacing.sm,
                    ),
                  ),
                ),
            ],
          ),

          // Color bar
          const SizedBox(height: SigapSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(SigapRadius.sm),
            child: LinearProgressIndicator(
              value: displayScore / 100,
              backgroundColor: SigapColors.border,
              valueColor: AlwaysStoppedAnimation(_scoreColor),
              minHeight: 6,
            ),
          ),

          // Override details (operator/auditor only - passed reason)
          if (overrideScore != null && overrideReason != null) ...[
            const SizedBox(height: SigapSpacing.sm),
            Container(
              padding: const EdgeInsets.all(SigapSpacing.sm),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(SigapRadius.sm),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 14,
                    color: Colors.amber.shade700,
                  ),
                  const SizedBox(width: SigapSpacing.xs),
                  Expanded(
                    child: Text(
                      overrideReason!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.amber.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Factor breakdown bars
          if (factorBreakdown != null && factorBreakdown!.isNotEmpty) ...[
            const SizedBox(height: SigapSpacing.md),
            const Text(
              'Faktor Prioritas',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: SigapColors.textSecondary,
              ),
            ),
            const SizedBox(height: SigapSpacing.sm),
            ...factorBreakdown!.entries.map(
              (entry) => _FactorBar(label: entry.key, value: entry.value),
            ),
          ],
        ],
      ),
    );
  }
}

class _FactorBar extends StatelessWidget {
  final String label;
  final double value;

  const _FactorBar({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: SigapSpacing.xs),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: SigapColors.textMuted,
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(SigapRadius.sm),
              child: LinearProgressIndicator(
                value: value / 100,
                backgroundColor: SigapColors.border,
                valueColor: AlwaysStoppedAnimation(
                  PriorityScoreCard.scoreColor(value),
                ),
                minHeight: 4,
              ),
            ),
          ),
          const SizedBox(width: SigapSpacing.sm),
          SizedBox(
            width: 28,
            child: Text(
              '${value.round()}',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: SigapColors.textSecondary,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

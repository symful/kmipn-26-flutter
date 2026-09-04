import 'package:flutter/material.dart';
import 'package:sigap/l10n/generated/app_localizations.dart';
import 'package:sigap/theme/tokens.dart';
import 'package:sigap/widgets/design_system/sigap_card.dart';
import 'package:sigap/widgets/design_system/skeleton_loaders.dart';

/// Data quality metrics for W-02 dashboard.
class DataQualityMetrics {
  /// Synchronization percentage (0-100).
  final int sinkronPercent;

  /// Number of surveyors waiting.
  final int surveyorsMenunggu;

  /// Number of cases at SLA risk.
  final int slaAtRisk;

  const DataQualityMetrics({
    required this.sinkronPercent,
    required this.surveyorsMenunggu,
    required this.slaAtRisk,
  });
}

/// W-02 Data Quality Panel.
///
/// Displays data quality metrics including synchronization rate
/// and surveyor queue status.
/// Right-side panel when placed side-by-side with [KasusKritisPanel].
class DataQualityPanel extends StatelessWidget {
  const DataQualityPanel({
    super.key,
    required this.metrics,
    this.isLoading = false,
    this.errorMessage,
  });

  /// Data quality metrics to display.
  final DataQualityMetrics? metrics;

  /// Whether data is currently loading.
  final bool isLoading;

  /// Optional error message to display.
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return SigapCard(
      padding: const EdgeInsets.all(SigapSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header row
          Row(
            children: [
              const Icon(
                Icons.analytics_outlined,
                color: SigapColors.info,
                size: 18,
              ),
              const SizedBox(width: SigapSpacing.xs),
              const Text(
                'Kualitas Data',
                style: TextStyle(
                  fontSize: SigapTypography.bodyText,
                  fontWeight: FontWeight.w600,
                  color: SigapColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: SigapSpacing.md),

          // Content
          if (isLoading)
            _buildLoadingState()
          else if (errorMessage != null)
            _buildErrorState(errorMessage!)
          else if (metrics == null)
            _buildEmptyState()
          else
            _buildMetrics(),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: [
        _DataQualityItemSkeleton(label: 'Tingkat Sinkronisasi'),
        const SizedBox(height: SigapSpacing.md),
        _DataQualityItemSkeleton(label: 'Surveyor Menunggu'),
      ],
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SigapSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: SigapColors.danger,
              size: 24,
            ),
            const SizedBox(height: SigapSpacing.xs),
            Text(
              message,
              style: const TextStyle(
                fontSize: SigapTypography.bodySmall,
                color: SigapColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(SigapSpacing.md),
        child: Text(
          'Data tidak tersedia',
          style: TextStyle(
            fontSize: SigapTypography.bodySmall,
            color: SigapColors.textTertiary,
          ),
        ),
      ),
    );
  }

  Widget _buildMetrics() {
    final m = metrics!;

    return Column(
      children: [
        // Synchronization rate with progress bar
        _SinkronisasiItem(percent: m.sinkronPercent),
        const SizedBox(height: SigapSpacing.md),

        // Surveyor waiting count
        _SurveyorMenungguItem(count: m.surveyorsMenunggu),
        const SizedBox(height: SigapSpacing.md),

        // SLA at risk count
        _SlaAtRiskItem(count: m.slaAtRisk),
      ],
    );
  }
}

/// Synchronization rate display item.
class _SinkronisasiItem extends StatelessWidget {
  const _SinkronisasiItem({required this.percent});

  final int percent;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = _getColorForPercent(percent);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.cloud_sync_outlined, size: 14, color: color),
                const SizedBox(width: SigapSpacing.xs),
                Text(
                  l10n.tingkatSinkronisasi,
                  style: const TextStyle(
                    fontSize: SigapTypography.captionMedium,
                    color: SigapColors.textMuted,
                  ),
                ),
              ],
            ),
            Text(
              '$percent%',
              style: TextStyle(
                fontSize: SigapTypography.bodySmall,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: SigapSpacing.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(SigapRadius.sm),
          child: LinearProgressIndicator(
            value: percent / 100,
            backgroundColor: SigapColors.surface,
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Color _getColorForPercent(int percent) {
    if (percent >= 80) return SigapColors.success;
    if (percent >= 50) return SigapColors.warning;
    return SigapColors.danger;
  }
}

/// Surveyor waiting count display item.
class _SurveyorMenungguItem extends StatelessWidget {
  const _SurveyorMenungguItem({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasWaiting = count > 0;

    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: hasWaiting
                ? SigapColors.warningBg
                : SigapColors.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(SigapRadius.sm),
          ),
          alignment: Alignment.center,
          child: Icon(
            hasWaiting ? Icons.pending_outlined : Icons.check_circle_outline,
            size: 16,
            color: hasWaiting ? SigapColors.warning : SigapColors.success,
          ),
        ),
        const SizedBox(width: SigapSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.surveyorMenunggu,
                style: const TextStyle(
                  fontSize: SigapTypography.captionMedium,
                  color: SigapColors.textMuted,
                ),
              ),
              Text(
                hasWaiting
                    ? '$count surveyor perlu ditugaskan'
                    : 'Semua surveyor aktif',
                style: TextStyle(
                  fontSize: SigapTypography.captionMedium,
                  fontWeight: FontWeight.w500,
                  color: hasWaiting
                      ? SigapColors.warningTextStrong
                      : SigapColors.success,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// SLA at risk count display item.
class _SlaAtRiskItem extends StatelessWidget {
  const _SlaAtRiskItem({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final hasAtRisk = count > 0;

    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: hasAtRisk
                ? SigapColors.dangerBg
                : SigapColors.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(SigapRadius.sm),
          ),
          alignment: Alignment.center,
          child: Icon(
            hasAtRisk ? Icons.schedule : Icons.check_circle_outline,
            size: 16,
            color: hasAtRisk ? SigapColors.danger : SigapColors.success,
          ),
        ),
        const SizedBox(width: SigapSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Risiko SLA',
                style: TextStyle(
                  fontSize: SigapTypography.captionMedium,
                  color: SigapColors.textMuted,
                ),
              ),
              Text(
                hasAtRisk
                    ? '$count kasus berisiko terlambat'
                    : 'Semua kasus on track',
                style: TextStyle(
                  fontSize: SigapTypography.captionMedium,
                  fontWeight: FontWeight.w500,
                  color: hasAtRisk
                      ? SigapColors.dangerTextStrong
                      : SigapColors.success,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Skeleton loading for data quality item.
class _DataQualityItemSkeleton extends StatelessWidget {
  const _DataQualityItemSkeleton({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SkeletonBox(width: 100, height: 11, borderRadius: 4),
            SkeletonBox(width: 40, height: 12, borderRadius: 4),
          ],
        ),
        const SizedBox(height: SigapSpacing.xs),
        SkeletonBox(width: double.infinity, height: 8, borderRadius: 4),
      ],
    );
  }
}

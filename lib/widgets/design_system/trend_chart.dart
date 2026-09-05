import 'package:flutter/material.dart';
import 'package:sigap/l10n/generated/app_localizations.dart';
import 'package:sigap/theme/tokens.dart';
import 'package:sigap/widgets/design_system/sigap_card.dart';
import 'package:sigap/widgets/design_system/skeleton_loaders.dart';
import 'package:sigap/widgets/design_system/legend_dot.dart';

/// A data point for trend/bar charts.
class ChartDataPoint {
  const ChartDataPoint({
    required this.label,
    required this.primaryValue,
    required this.secondaryValue,
  });

  /// X-axis label (e.g. date or category).
  final String label;

  /// Primary bar value (e.g. laporan count).
  final int primaryValue;

  /// Secondary bar value (e.g. kasus count).
  final int secondaryValue;
}

/// A trend chart showing dual bar series with legend.
///
/// Usage:
/// ```dart
/// TrendChart(
///   data: [
///     ChartDataPoint(label: '01/09', primaryValue: 5, secondaryValue: 3),
///     ChartDataPoint(label: '02/09', primaryValue: 8, secondaryValue: 4),
///   ],
///   primaryLabel: 'laporan',
///   secondaryLabel: 'kasus',
///   primaryColor: SigapColors.info,
///   secondaryColor: SigapColors.primary,
/// )
/// ```
class TrendChart extends StatelessWidget {
  /// Creates a [TrendChart].
  ///
  /// - [data]: List of data points to display
  /// - [primaryLabel]: Legend label for primary bars
  /// - [secondaryLabel]: Legend label for secondary bars
  /// - [primaryColor]: Color for primary bars
  /// - [secondaryColor]: Color for secondary bars
  const TrendChart({
    super.key,
    required this.data,
    this.primaryLabel = 'laporan',
    this.secondaryLabel = 'kasus',
    this.primaryColor = SigapColors.info,
    this.secondaryColor = SigapColors.primary,
  });

  final List<ChartDataPoint> data;
  final String primaryLabel;
  final String secondaryLabel;
  final Color primaryColor;
  final Color secondaryColor;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (data.isEmpty) {
      return SigapCard(
        padding: const EdgeInsets.all(SigapSpacing.md),
        child: Center(
          child: Text(
            l10n.tidakAdaDataTren,
            style: TextStyle(
              color: SigapColors.textMuted,
              fontSize: SigapTypography.bodyText,
            ),
          ),
        ),
      );
    }

    final maxValue = data.fold<int>(1, (max, p) {
      final m = [
        max,
        p.primaryValue,
        p.secondaryValue,
      ].reduce((a, b) => a > b ? a : b);
      return m;
    });

    return SigapCard(
      padding: const EdgeInsets.all(SigapSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.umurBacklogKasus,
                style: TextStyle(
                  fontSize: SigapTypography.bodyText,
                  fontWeight: FontWeight.w600,
                  color: SigapColors.textPrimary,
                ),
              ),
              Row(
                children: [
                  LegendDot(color: primaryColor),
                  const SizedBox(width: SigapSpacing.xs),
                  Text(
                    primaryLabel,
                    style: const TextStyle(
                      fontSize: SigapTypography.captionSmall,
                      color: SigapColors.textTertiary,
                    ),
                  ),
                  const SizedBox(width: SigapSpacing.sm),
                  LegendDot(color: secondaryColor),
                  const SizedBox(width: SigapSpacing.xs),
                  Text(
                    secondaryLabel,
                    style: const TextStyle(
                      fontSize: SigapTypography.captionSmall,
                      color: SigapColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: SigapSpacing.md),
          SizedBox(
            height: 110,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: data.map((point) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          child: FractionallySizedBox(
                            heightFactor: maxValue > 0
                                ? point.primaryValue / maxValue
                                : 0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(2),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Flexible(
                          child: FractionallySizedBox(
                            heightFactor: maxValue > 0
                                ? point.secondaryValue / maxValue
                                : 0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: secondaryColor,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(2),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Loading state for [TrendChart].
class TrendChartLoading extends StatelessWidget {
  const TrendChartLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return SigapCard(
      padding: const EdgeInsets.all(SigapSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(width: 120, height: 14, borderRadius: 4),
          const SizedBox(height: SigapSpacing.md),
          SizedBox(
            height: 110,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(
                10,
                (_) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: SkeletonBox(height: 80, borderRadius: 2),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

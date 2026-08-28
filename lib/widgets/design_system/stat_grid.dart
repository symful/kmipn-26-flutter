import 'package:flutter/material.dart';
import 'package:sigap/theme/tokens.dart';
import 'package:sigap/widgets/design_system/responsive.dart';
import 'package:sigap/widgets/design_system/sigap_card.dart';
import 'package:sigap/widgets/design_system/status_pill.dart';

/// StatGrid — responsive grid of metric stat cards.
///
/// Layout (guide.txt §M-05 W-02):
/// - Mobile (<600):   1 column
/// - Tablet (600–1024): 2–3 columns
/// - Desktop (>1024):  4 columns
///
/// Each cell is a [SigapCard] showing:
/// - [label] (small, muted)
/// - [value] (large, bold)
/// - optional [delta] with [StatusPill] trend indicator
/// - optional [StatusPill] for severity / status
class StatGrid extends StatelessWidget {
  const StatGrid({
    super.key,
    required this.stats,
    this.crossAxisCount,
    this.mainAxisSpacing,
    this.crossAxisSpacing,
    this.childAspectRatio,
  });

  /// List of stat items to display.
  final List<StatItem> stats;

  /// Override column count. By default, columns are determined by [Breakpoints].
  final int? crossAxisCount;

  /// Spacing between rows. Defaults to [SigapSpacing.md].
  final double? mainAxisSpacing;

  /// Spacing between columns. Defaults to [SigapSpacing.md].
  final double? crossAxisSpacing;

  /// Aspect ratio of each cell. Defaults to 1.4 (taller than wide).
  final double? childAspectRatio;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final actualCrossAxisCount = crossAxisCount ?? _resolveColumns(w);
        final actualMainSpacing = mainAxisSpacing ?? SigapSpacing.md;
        final actualCrossSpacing = crossAxisSpacing ?? SigapSpacing.md;
        final actualAspectRatio = childAspectRatio ?? 1.4;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: actualCrossAxisCount,
            mainAxisSpacing: actualMainSpacing,
            crossAxisSpacing: actualCrossSpacing,
            childAspectRatio: actualAspectRatio,
          ),
          itemCount: stats.length,
          itemBuilder: (context, index) => StatCell(item: stats[index]),
        );
      },
    );
  }

  int _resolveColumns(double width) {
    if (isMobile(width)) return 1;
    if (isTablet(width)) {
      // 600–840: 2 columns; 840–1024: 3 columns
      if (width < 840) return 2;
      return 3;
    }
    return 4; // desktop
  }
}

// ---------------------------------------------------------------------------
// StatCell
// ---------------------------------------------------------------------------

/// A single stat card within [StatGrid].
class StatCell extends StatelessWidget {
  const StatCell({super.key, required this.item});

  final StatItem item;

  @override
  Widget build(BuildContext context) {
    return SigapCard(
      borderLeftColor: item.severityColor,
      padding: const EdgeInsets.all(SigapSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Label row + optional StatusPill
          Row(
            children: [
              Expanded(
                child: Text(
                  item.label,
                  style: TextStyle(
                    fontSize: SigapTypography.size11,
                    fontWeight: FontWeight.w500,
                    color: SigapColors.textMuted,
                    letterSpacing: SigapTypography.letterSpacingLabel,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (item.statusPill != null) ...[
                const SizedBox(width: SigapSpacing.xs),
                item.statusPill!,
              ],
            ],
          ),
          const SizedBox(height: SigapSpacing.xs),
          // Value
          Text(
            item.value,
            style: TextStyle(
              fontSize: SigapTypography.size28,
              fontWeight: FontWeight.w700,
              color: SigapColors.textPrimary,
              height: SigapTypography.lineHeight130,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          // Optional delta
          if (item.delta != null) ...[
            const SizedBox(height: SigapSpacing.xxs),
            _DeltaWidget(delta: item.delta!),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Delta indicator
// ---------------------------------------------------------------------------

class _DeltaWidget extends StatelessWidget {
  const _DeltaWidget({required this.delta});

  final StatDelta delta;

  @override
  Widget build(BuildContext context) {
    final isPositive = delta.value >= 0;
    final color = isPositive ? SigapColors.success : SigapColors.danger;
    final icon = isPositive ? Icons.trending_up : Icons.trending_down;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 2),
        Text(
          '${isPositive ? '+' : ''}${delta.value}${delta.suffix ?? ''}',
          style: TextStyle(
            fontSize: SigapTypography.size11,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        if (delta.label != null) ...[
          const SizedBox(width: 2),
          Text(
            delta.label!,
            style: TextStyle(
              fontSize: SigapTypography.size10,
              color: SigapColors.textMuted,
            ),
          ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Data models
// ---------------------------------------------------------------------------

/// A single stat item displayed in [StatGrid].
class StatItem {
  const StatItem({
    required this.label,
    required this.value,
    this.delta,
    this.statusPill,
    this.severityColor,
  });

  /// Short descriptive label (e.g. "Perlu Tindakan").
  final String label;

  /// Primary metric value (e.g. "42", "99%", "12.5K").
  final String value;

  /// Optional delta / trend indicator.
  final StatDelta? delta;

  /// Optional [StatusPill] shown in top-right of the cell.
  final StatusPill? statusPill;

  /// When set, draws a 4px left border in this color (severity indicator).
  final Color? severityColor;
}

/// A delta / change indicator for a [StatItem].
class StatDelta {
  const StatDelta({required this.value, this.label, this.suffix});

  /// Numeric value (positive = up, negative = down).
  /// Displayed as "+N" or "-N".
  final num value;

  /// Optional short label appended after the value (e.g. "vs yesterday").
  final String? label;

  /// Optional suffix appended to the value (e.g. "%", "件").
  final String? suffix;
}

import 'package:sigap/theme/sigap_color_scheme.dart';

import 'package:flutter/material.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../theme/tokens.dart';

/// A single status card in the StatusGrid.
///
/// Displays a count number with a colored style and a label underneath.
class _StatusCard extends StatelessWidget {
  final int? count;
  final String label;
  final Color countColor;

  const _StatusCard({
    required this.count,
    required this.label,
    required this.countColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: SigapColorScheme.of(context).bgCard,
        border: Border.all(color: SigapColorScheme.of(context).borderCard),
        borderRadius: BorderRadius.circular(SigapRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            count?.toString() ?? '—',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w600,
              color: countColor,
            ),
          ),
          SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: SigapColorScheme.of(context).textTertiary,
              height: SigapTypography.lineHeight125,
            ),
          ),
        ],
      ),
    );
  }
}

/// 3-column grid showing report status summary.
///
/// Used in "Laporan saya" (My Reports) section of Beranda Warga screen.
/// Each column represents a status: Perlu tindakan, Diproses, Selesai.
///
/// Design spec: PantauDesa M-05, "ringkasan status" section.
class StatusGrid extends StatelessWidget {
  /// Count for "Perlu tindakan" (Need action) status.
  final int? perluTindakan;

  /// Count for "Diproses" (In process) status.
  final int? diproses;

  /// Count for "Selesai" (Done) status.
  final int? selesai;

  const StatusGrid({
    super.key,
    required this.perluTindakan,
    required this.diproses,
    required this.selesai,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final entries = [
      (perluTindakan, l10n.perluTindakan, SigapColorScheme.of(context).warning),
      (diproses, l10n.diproses, SigapColorScheme.of(context).info),
      (selesai, l10n.selesai, SigapColorScheme.of(context).primary),
    ];
    final available = entries.where((entry) => entry.$1 != null).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (available.length != entries.length) ...[
          Text(l10n.mobileSummaryUnavailable),
          const SizedBox(height: SigapSpacing.sm),
        ],
        if (available.isNotEmpty)
          Row(
            children: [
              for (var index = 0; index < available.length; index++) ...[
                if (index > 0) const SizedBox(width: SigapSpacing.sm),
                Expanded(
                  child: _StatusCard(
                    count: available[index].$1,
                    label: available[index].$2,
                    countColor: available[index].$3,
                  ),
                ),
              ],
            ],
          ),
      ],
    );
  }
}

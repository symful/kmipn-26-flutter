import 'package:flutter/material.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../theme/tokens.dart';

/// A single status card in the StatusGrid.
///
/// Displays a count number with a colored style and a label underneath.
class _StatusCard extends StatelessWidget {
  final int count;
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
      padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 10),
      decoration: BoxDecoration(
        color: SigapColors.bgCard,
        border: Border.all(color: SigapColors.borderCard),
        borderRadius: BorderRadius.circular(SigapRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontSize: SigapTypography.headlineMedium,
              fontWeight: FontWeight.w700,
              color: countColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: SigapTypography.captionMedium,
              color: SigapColors.textTertiary,
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
  final int perluTindakan;

  /// Count for "Diproses" (In process) status.
  final int diproses;

  /// Count for "Selesai" (Done) status.
  final int selesai;

  const StatusGrid({
    super.key,
    required this.perluTindakan,
    required this.diproses,
    required this.selesai,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: _StatusCard(
            count: perluTindakan,
            label: l10n.perluTindakan,
            countColor: SigapColors.danger,
          ),
        ),
        const SizedBox(width: SigapSpacing.sm),
        Expanded(
          child: _StatusCard(
            count: diproses,
            label: l10n.diproses,
            countColor: SigapColors.info,
          ),
        ),
        const SizedBox(width: SigapSpacing.sm),
        Expanded(
          child: _StatusCard(
            count: selesai,
            label: l10n.selesai,
            countColor: SigapColors.primary,
          ),
        ),
      ],
    );
  }
}

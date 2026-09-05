import 'package:flutter/material.dart';
import '../../theme/tokens.dart';
import '../../widgets/design_system/sigap_card.dart';
import '../../db/database.dart';

class ReportListItem extends StatelessWidget {
  final LocalReport report;
  final VoidCallback onTap;
  const ReportListItem({super.key, required this.report, required this.onTap});

  Color _statusColor() {
    switch (report.status) {
      case 'submitted':
      case 'under_review':
        return SigapColors.perluTindakan;
      case 'verified':
      case 'in_progress':
        return SigapColors.diproses;
      case 'resolved':
        return SigapColors.selesai;
      default:
        return SigapColors.textMuted;
    }
  }

  String _statusLabel() {
    switch (report.status) {
      case 'submitted':
        return 'Perlu Tindakan';
      case 'under_review':
        return 'Perlu Tindakan';
      case 'verified':
        return 'Diproses';
      case 'in_progress':
        return 'Diproses';
      case 'resolved':
        return 'Selesai';
      case 'rejected':
        return 'Ditolak';
      case 'duplicate_merged':
        return 'Duplikat';
      case 'needs_survey':
        return 'Perlu Survei';
      default:
        return report.status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SigapCard(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SigapRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(SigapSpacing.md),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: SigapSpacing.sm,
                  vertical: SigapSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: _statusColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(SigapRadius.sm),
                ),
                child: Text(
                  _statusLabel(),
                  style: TextStyle(
                    color: _statusColor(),
                    fontSize: SigapTypography.captionMedium,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: SigapSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: SigapTypography.bodyText,
                      ),
                    ),
                    const SizedBox(height: SigapSpacing.xs),
                    Text(
                      '${report.lat.toStringAsFixed(4)}, ${report.lng.toStringAsFixed(4)}',
                      style: TextStyle(
                        color: SigapColors.textMuted,
                        fontSize: SigapTypography.captionMedium,
                      ),
                    ),
                  ],
                ),
              ),
              if (report.syncStatus == 0)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: SigapColors.offlineDot,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

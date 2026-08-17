import 'package:flutter/material.dart';
import '../../../../theme/tokens.dart';

/// S-01 Surveyor Home Screen Header Widget
///
/// Displays "Tugas hari ini" (Today's Tasks) title along with
/// current date and surveyor wilayah (region) information.
///
/// Design: PantauDesa S-01 region header
class SurveyorTaskListHeader extends StatelessWidget {
  /// Surveyor wilayah (region/area) name, e.g., "Kab. Bandung" or "Kec. Sukasari".
  final String wilayahName;

  /// Optional date to display. Defaults to current date if not provided.
  final DateTime? date;

  const SurveyorTaskListHeader({
    super.key,
    required this.wilayahName,
    this.date,
  });

  @override
  Widget build(BuildContext context) {
    final displayDate = date ?? DateTime.now();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
        border: Border(bottom: BorderSide(color: AppColors.borderCard)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title: "Tugas hari ini"
          Text(
            'Tugas hari ini',
            style: const TextStyle(
              fontSize: AppTypography.size22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          // Row: Date and Wilayah info
          Row(
            children: [
              // Date
              Text(
                _formatDate(displayDate),
                style: const TextStyle(
                  fontSize: AppTypography.size12,
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              // Separator dot
              Container(
                width: 3,
                height: 3,
                decoration: const BoxDecoration(
                  color: AppColors.textTertiary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              // Wilayah name
              Expanded(
                child: Text(
                  wilayahName,
                  style: const TextStyle(
                    fontSize: AppTypography.size12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Formats date as "Hari, DD Month YYYY" in Indonesian.
  /// Example: "Sabtu, 15 Agustus 2026"
  String _formatDate(DateTime dt) {
    const dayNames = [
      'Minggu',
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
    ];
    const monthNames = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    final dayName = dayNames[dt.weekday % 7];
    final monthName = monthNames[dt.month - 1];

    return '$dayName, ${dt.day} $monthName ${dt.year}';
  }
}

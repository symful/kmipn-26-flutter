import 'package:flutter/material.dart';
import 'package:sigap/theme/tokens.dart';

/// Status types for M-14 report detail banner.
///
/// Maps to PantauDesa design spec colors and labels:
/// - perluTindakan: Orange/amber banner with "Perlu tindakan Anda" badge
/// - diproses: Blue banner with "Sedang diperiksa" badge
/// - selesai: Green/teal banner with "Selesai" badge
enum M14ReportStatus {
  /// Requires user action (upload additional evidence, etc.)
  perluTindakan,

  /// Report is being processed/verified
  diproses,

  /// Report has been resolved
  selesai,
}

/// Data model for M-14 status action banner.
///
/// Contains all information needed to render the banner:
/// - Status type (determines colors and badge text)
/// - Description message
/// - Deadline date
/// - Optional action button callback
class M14StatusBannerData {
  final M14ReportStatus status;
  final String description;
  final DateTime deadline;
  final VoidCallback? onActionTap;

  const M14StatusBannerData({
    required this.status,
    required this.description,
    required this.deadline,
    this.onActionTap,
  });
}

/// Banner widget for M-14 report detail screen.
///
/// Shows status with colored background, status badge, description
/// with deadline countdown, and optional CTA button.
///
/// Design spec from PantauDesa M-14:
/// - Background: warningBg (#f8ecd6) with warningBorder (#ecd7a6) border
/// - Status badge: warning (#b8730a) background, white text, rounded 7px
/// - Description: warningTextStrong (#7a4d06), 12.5px
/// - CTA button: primary (#0f7a6b), white text, rounded 10px, full width
class M14StatusActionBanner extends StatelessWidget {
  final M14StatusBannerData data;

  const M14StatusActionBanner({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.warningBg,
        border: Border.all(color: AppColors.warningBorder),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      padding: const EdgeInsets.all(AppSpacing.x14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status badge
          _StatusBadge(status: data.status),

          // Description with deadline
          const SizedBox(height: AppSpacing.x9),
          _DeadlineDescription(
            description: data.description,
            deadline: data.deadline,
          ),

          // CTA button
          if (data.onActionTap != null) ...[
            const SizedBox(height: AppSpacing.x11),
            _ActionButton(onTap: data.onActionTap!),
          ],
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final M14ReportStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x10,
        vertical: AppSpacing.x4,
      ),
      decoration: BoxDecoration(
        color: AppColors.warning,
        borderRadius: BorderRadius.circular(AppRadius.x7),
      ),
      child: Text(
        _statusLabel,
        style: const TextStyle(
          fontSize: AppTypography.size12,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }

  String get _statusLabel {
    switch (status) {
      case M14ReportStatus.perluTindakan:
        return 'Perlu tindakan Anda';
      case M14ReportStatus.diproses:
        return 'Sedang diperiksa';
      case M14ReportStatus.selesai:
        return 'Selesai';
    }
  }
}

class _DeadlineDescription extends StatelessWidget {
  final String description;
  final DateTime deadline;

  const _DeadlineDescription({
    required this.description,
    required this.deadline,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      '$description Tenggat $_formattedDeadline.',
      style: const TextStyle(
        fontSize: AppTypography.size12_5,
        color: AppColors.warningTextStrong,
        height: AppTypography.lineHeight145,
      ),
    );
  }

  String get _formattedDeadline {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${deadline.day} ${months[deadline.month - 1]} ${deadline.year}';
  }
}

class _ActionButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ActionButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.x11,
          horizontal: AppSpacing.x17,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: const Text(
          'Lengkapi laporan',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: AppTypography.size13,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:sigap/theme/tokens.dart';

/// Status types for report detail banner.
///
/// Maps to PantauDesa design spec colors and labels:
/// - perluTindakan: Orange/amber banner with "Perlu tindakan Anda" badge
/// - diproses: Blue banner with "Sedang diperiksa" badge
/// - selesai: Green/teal banner with "Selesai" badge
enum ReportStatus {
  /// Requires user action (upload additional evidence, etc.)
  perluTindakan,

  /// Report is being processed/verified
  diproses,

  /// Report has been resolved
  selesai,
}

/// Data model for status action banner.
///
/// Contains all information needed to render the banner:
/// - Status type (determines colors and badge text)
/// - Description message
/// - Deadline date
/// - Optional action button callback
class StatusBannerData {
  final ReportStatus status;
  final String description;
  final DateTime deadline;
  final VoidCallback? onActionTap;

  const StatusBannerData({
    required this.status,
    required this.description,
    required this.deadline,
    this.onActionTap,
  });
}

/// Banner widget for report detail screen.
///
/// Shows status with colored background, status badge, description
/// with deadline countdown, and optional CTA button.
///
/// Design spec from PantauDesa:
/// - Background: warningBg (#f8ecd6) with warningBorder (#ecd7a6) border
/// - Status badge: warning (#b8730a) background, white text, rounded 7px
/// - Description: warningTextStrong (#7a4d06), 12.5px
/// - CTA button: primary (#0f7a6b), white text, rounded 10px, full width
class StatusActionBanner extends StatelessWidget {
  final StatusBannerData data;

  const StatusActionBanner({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SigapColors.warningBg,
        border: Border.all(color: SigapColors.warningBorder),
        borderRadius: BorderRadius.circular(SigapRadius.lg),
      ),
      padding: const EdgeInsets.all(SigapSpacing.x14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status badge
          _StatusBadge(status: data.status),

          // Description with deadline
          const SizedBox(height: SigapSpacing.x9),
          _DeadlineDescription(
            description: data.description,
            deadline: data.deadline,
          ),

          // CTA button
          if (data.onActionTap != null) ...[
            const SizedBox(height: SigapSpacing.x11),
            _ActionButton(onTap: data.onActionTap!),
          ],
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final ReportStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SigapSpacing.x10,
        vertical: SigapSpacing.x4,
      ),
      decoration: BoxDecoration(
        color: SigapColors.warning,
        borderRadius: BorderRadius.circular(SigapRadius.x7),
      ),
      child: Text(
        _statusLabel,
        style: const TextStyle(
          fontSize: SigapTypography.size12,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }

  String get _statusLabel {
    switch (status) {
      case ReportStatus.perluTindakan:
        return 'Perlu tindakan Anda';
      case ReportStatus.diproses:
        return 'Sedang diperiksa';
      case ReportStatus.selesai:
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
        fontSize: SigapTypography.size12_5,
        color: SigapColors.warningTextStrong,
        height: SigapTypography.lineHeight145,
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
          vertical: SigapSpacing.x11,
          horizontal: SigapSpacing.x17,
        ),
        decoration: BoxDecoration(
          color: SigapColors.primary,
          borderRadius: BorderRadius.circular(SigapRadius.md),
        ),
        child: const Text(
          'Lengkapi laporan',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: SigapTypography.size13,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

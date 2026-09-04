import 'package:flutter/material.dart';
import '../../../theme/tokens.dart';

/// Status of a nearby case.
enum KasusStatus {
  /// Case is being handled (blue).
  sedangDitangani,

  /// Case is verified (teal).
  terverifikasi,
}

/// A single nearby case card for the "Kasus terdekat" section.
///
/// Displays case avatar/initials, title, location info, distance,
/// supporting reports count, and status badge.
///
/// Design spec: PantauDesa M-05, "kasus terdekat" section.
class KasusTerdekatCard extends StatelessWidget {
  /// Two-letter initials code for the case category.
  final String initials;

  /// Case title/description.
  final String title;

  /// RW location (e.g., "RW 04").
  final String rw;

  /// Distance in meters (e.g., 320).
  final int distanceMeters;

  /// Number of supporting reports.
  final int laporanCount;

  /// Current case status.
  final KasusStatus status;

  /// Callback when card is tapped.
  final VoidCallback? onTap;

  const KasusTerdekatCard({
    super.key,
    required this.initials,
    required this.title,
    required this.rw,
    required this.distanceMeters,
    required this.laporanCount,
    required this.status,
    this.onTap,
  });

  String get _statusLabel {
    switch (status) {
      case KasusStatus.sedangDitangani:
        return 'Sedang ditangani';
      case KasusStatus.terverifikasi:
        return 'Terverifikasi';
    }
  }

  Color get _statusDotColor {
    switch (status) {
      case KasusStatus.sedangDitangani:
        return SigapColors.info;
      case KasusStatus.terverifikasi:
        return SigapColors.primary;
    }
  }

  Color get _statusBgColor {
    switch (status) {
      case KasusStatus.sedangDitangani:
        return SigapColors.infoBg;
      case KasusStatus.terverifikasi:
        return SigapColors.primaryLight;
    }
  }

  Color get _statusTextColor {
    switch (status) {
      case KasusStatus.sedangDitangani:
        return SigapColors.info;
      case KasusStatus.terverifikasi:
        return SigapColors.primaryDark;
    }
  }

  String get _distanceText {
    if (distanceMeters >= 1000) {
      return '${(distanceMeters / 1000).toStringAsFixed(1)} km';
    }
    return '$distanceMeters m';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(SigapSpacing.md),
        decoration: BoxDecoration(
          color: SigapColors.bgCard,
          border: Border.all(color: SigapColors.borderCard),
          borderRadius: BorderRadius.circular(SigapRadius.x12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar badge
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: SigapColors.primaryLight,
                borderRadius: BorderRadius.circular(SigapRadius.x9),
              ),
              alignment: Alignment.center,
              child: Text(
                initials,
                style: const TextStyle(
                  fontFamily: SigapTypography.fontFamilyMono,
                  fontSize: SigapTypography.bodyText,
                  fontWeight: FontWeight.w600,
                  color: SigapColors.primaryDark,
                ),
              ),
            ),
            const SizedBox(width: SigapSpacing.x11),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: SigapTypography.bodyTextWide,
                      fontWeight: FontWeight.w600,
                      color: SigapColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1),

                  // Subtitle: RW · distance · laporan count
                  Text(
                    '$rw · $_distanceText · $laporanCount laporan pendukung',
                    style: const TextStyle(
                      fontSize: SigapTypography.captionFine,
                      color: SigapColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Status pill
                  _StatusPill(
                    label: _statusLabel,
                    dotColor: _statusDotColor,
                    bgColor: _statusBgColor,
                    textColor: _statusTextColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color dotColor;
  final Color bgColor;
  final Color textColor;

  const _StatusPill({
    required this.label,
    required this.dotColor,
    required this.bgColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(SigapRadius.x6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: SigapTypography.captionMedium,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Section widget containing a list of nearby case cards.
///
/// Displays a "Kasus terdekat" header with "Lihat peta" link,
/// followed by a vertical list of [KasusTerdekatCard] widgets.
///
/// Design spec: PantauDesa M-05, "kasus terdekat" section.
class KasusTerdekatSection extends StatelessWidget {
  /// List of nearby cases to display.
  final List<KasusTerdekatCase> cases;

  /// Callback when "Lihat peta" is tapped.
  final VoidCallback? onLihatPeta;

  /// Callback when a specific case card is tapped.
  final void Function(KasusTerdekatCase kasus)? onCaseTap;

  const KasusTerdekatSection({
    super.key,
    required this.cases,
    this.onLihatPeta,
    this.onCaseTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Kasus terdekat',
              style: TextStyle(
                fontSize: SigapTypography.bodyText,
                fontWeight: FontWeight.w700,
                color: SigapColors.textPrimary,
              ),
            ),
            GestureDetector(
              onTap: onLihatPeta,
              child: const Text(
                'Lihat peta',
                style: TextStyle(
                  fontSize: SigapTypography.bodySmall,
                  fontWeight: FontWeight.w600,
                  color: SigapColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Cards list
        ...cases.map(
          (kasus) => Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: KasusTerdekatCard(
              initials: kasus.initials,
              title: kasus.title,
              rw: kasus.rw,
              distanceMeters: kasus.distanceMeters,
              laporanCount: kasus.laporanCount,
              status: kasus.status,
              onTap: onCaseTap != null ? () => onCaseTap!(kasus) : null,
            ),
          ),
        ),
      ],
    );
  }
}

/// Data model for a nearby case.
class KasusTerdekatCase {
  final String initials;
  final String title;
  final String rw;
  final int distanceMeters;
  final int laporanCount;
  final KasusStatus status;

  const KasusTerdekatCase({
    required this.initials,
    required this.title,
    required this.rw,
    required this.distanceMeters,
    required this.laporanCount,
    required this.status,
  });
}

import 'package:flutter/material.dart';
import 'package:sigap/theme/tokens.dart';

/// M-11 report summary card model.
///
/// Displays the report being submitted with category, description,
/// location, timestamp, and impact information.
class ReportSummary {
  /// Short code / initials for category badge (e.g. "JL" from "Jalan").
  final String initials;

  /// Full category name (e.g. "JALAN").
  final String categoryName;

  /// Severity/condition label (e.g. "Berat", "Ringan", "Kritis").
  final String condition;

  /// Report title/description.
  final String title;

  /// Location string (e.g. "Jl. Raya Ciburuy").
  final String location;

  /// Location accuracy description (e.g. "Akurasi baik").
  final String accuracy;

  /// Timestamp of report creation (e.g. "17 Jul 2026, 09:32").
  final String timestamp;

  /// Impact summary (e.g. "Keselamatan · akses terganggu").
  final String impact;

  /// Photo index display (e.g. "1/3").
  final String photoIndex;

  /// Whether location is editable.
  final bool canEditLocation;

  /// Whether timestamp is editable.
  final bool canEditTimestamp;

  const ReportSummary({
    required this.initials,
    required this.categoryName,
    required this.condition,
    required this.title,
    required this.location,
    required this.accuracy,
    required this.timestamp,
    required this.impact,
    this.photoIndex = '1/3',
    this.canEditLocation = true,
    this.canEditTimestamp = true,
  });
}

/// Report summary card for M-11 Review Kiriman screen.
///
/// Matches PantauDesa M-11 design spec:
/// - Section label: "Ringkasan laporan" (uppercase, .04em letter-spacing)
/// - Card: white bg, #e4e7e2 border, 13px radius
/// - Photo placeholder (64x64, 9px radius) with striped gradient
/// - Category badge: IBM Plex Mono, #e2f1ee bg, #0a5c50 color, 5px radius
/// - Info rows with #eef0ec dividers for Lokasi, Waktu, Dampak
class ReportSummaryCard extends StatelessWidget {
  /// Report summary data to display.
  final ReportSummary report;

  /// Called when user taps the edit button for location.
  final VoidCallback? onEditLocation;

  /// Called when user taps the edit button for timestamp.
  final VoidCallback? onEditTimestamp;

  const ReportSummaryCard({
    super.key,
    required this.report,
    this.onEditLocation,
    this.onEditTimestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section label
        const Text(
          'RINGKASAN LAPORAN',
          style: TextStyle(
            fontSize: SigapTypography.size12,
            fontWeight: FontWeight.w700,
            color: SigapColors.textTertiary,
            letterSpacing: SigapTypography.letterSpacingLabel,
          ),
        ),
        const SizedBox(height: SigapSpacing.sm),

        // Card
        Container(
          decoration: BoxDecoration(
            color: SigapColors.bgCard,
            border: Border.all(color: SigapColors.borderCard),
            borderRadius: BorderRadius.circular(SigapRadius.lg),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              // Photo + info row
              Padding(
                padding: const EdgeInsets.all(SigapSpacing.x11),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Photo placeholder
                    _PhotoPlaceholder(photoIndex: report.photoIndex),
                    const SizedBox(width: SigapSpacing.x9),

                    // Info column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category badge + condition
                          Row(
                            children: [
                              _CategoryBadge(initials: report.initials),
                              const SizedBox(width: SigapSpacing.x6),
                              Text(
                                'Kondisi: ${report.condition}',
                                style: const TextStyle(
                                  fontSize: SigapTypography.size11,
                                  color: SigapColors.textTertiary,
                                ),
                              ),
                            ],
                          ),

                          // Title
                          const SizedBox(height: 6),
                          Text(
                            report.title,
                            style: const TextStyle(
                              fontSize: SigapTypography.size13,
                              fontWeight: FontWeight.w600,
                              color: SigapColors.textPrimary,
                              height: SigapTypography.lineHeight135,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Divider
              const _Divider(),

              // Location row
              _InfoRow(
                label: 'Lokasi',
                value: report.location,
                accuracy: report.accuracy,
                canEdit: report.canEditLocation,
                onEdit: onEditLocation,
              ),

              // Divider
              const _Divider(),

              // Timestamp row
              _InfoRow(
                label: 'Waktu',
                value: report.timestamp,
                canEdit: report.canEditTimestamp,
                onEdit: onEditTimestamp,
                isTimestamp: true,
              ),

              // Divider
              const _Divider(),

              // Impact row
              _InfoRow(label: 'Dampak', value: report.impact, isImpact: true),
            ],
          ),
        ),
      ],
    );
  }
}

/// Photo placeholder with striped diagonal gradient.
class _PhotoPlaceholder extends StatelessWidget {
  final String photoIndex;

  const _PhotoPlaceholder({required this.photoIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SigapRadius.x9),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            SigapColors.borderCard,
            SigapColors.borderCard,
            SigapColors.bgSoft,
            SigapColors.bgSoft,
          ],
          stops: [0.0, 0.5, 0.5, 1.0],
        ),
      ),
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        'foto $photoIndex',
        style: const TextStyle(
          fontFamily: SigapTypography.fontFamilyMono,
          fontSize: SigapTypography.size8,
          color: SigapColors.textDisabled,
        ),
      ),
    );
  }
}

/// Category badge with initials (e.g. "JL" for Jalan).
class _CategoryBadge extends StatelessWidget {
  final String initials;

  const _CategoryBadge({required this.initials});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: SigapColors.primaryLight,
        borderRadius: BorderRadius.circular(SigapRadius.sm),
      ),
      child: Text(
        initials,
        style: const TextStyle(
          fontFamily: SigapTypography.fontFamilyMono,
          fontSize: SigapTypography.size10,
          fontWeight: FontWeight.w600,
          color: SigapColors.primaryDark,
        ),
      ),
    );
  }
}

/// Horizontal divider between info rows.
class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, thickness: 1, color: SigapColors.bgSoft);
  }
}

/// Single info row (label + value with optional edit button).
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final String? accuracy;
  final bool canEdit;
  final bool isTimestamp;
  final bool isImpact;
  final VoidCallback? onEdit;

  const _InfoRow({
    required this.label,
    required this.value,
    this.accuracy,
    this.canEdit = false,
    this.isTimestamp = false,
    this.isImpact = false,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: SigapSpacing.x12,
        vertical: SigapSpacing.x10,
      ),
      child: Row(
        mainAxisAlignment: isImpact
            ? MainAxisAlignment.spaceBetween
            : MainAxisAlignment.spaceBetween,
        crossAxisAlignment: isImpact
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: SigapTypography.size12,
              color: SigapColors.textTertiary,
            ),
          ),
          if (isImpact)
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: SigapTypography.size12,
                  fontWeight: FontWeight.w600,
                  color: SigapColors.textPrimary,
                ),
              ),
            )
          else if (isTimestamp)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: SigapTypography.size12,
                    fontWeight: FontWeight.w600,
                    color: SigapColors.textPrimary,
                  ),
                ),
                if (canEdit) ...[
                  const SizedBox(width: 2),
                  GestureDetector(
                    onTap: onEdit,
                    child: const Text(
                      '✎',
                      style: TextStyle(
                        fontSize: SigapTypography.size12,
                        color: SigapColors.primary,
                      ),
                    ),
                  ),
                ],
              ],
            )
          else
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    accuracy != null ? '$value · $accuracy' : value,
                    style: const TextStyle(
                      fontSize: SigapTypography.size12,
                      fontWeight: FontWeight.w600,
                      color: SigapColors.textPrimary,
                    ),
                  ),
                ),
                if (canEdit) ...[
                  const SizedBox(width: 2),
                  GestureDetector(
                    onTap: onEdit,
                    child: const Text(
                      '✎',
                      style: TextStyle(
                        fontSize: SigapTypography.size12,
                        color: SigapColors.primary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

import 'package:sigap/theme/sigap_color_scheme.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sigap/l10n/generated/app_localizations.dart';
import 'package:sigap/theme/tokens.dart';
import 'package:sigap/widgets/design_system/sigap_card.dart';

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
  final String? photoPath;

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
    required this.photoIndex,
    this.photoPath,
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
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section label
        Text(
          l10n.ringkasanLaporanUppercase,
          style: TextStyle(
            fontSize: SigapTypography.bodySmall,
            fontWeight: FontWeight.w700,
            color: SigapColorScheme.of(context).textTertiary,
            letterSpacing: SigapTypography.letterSpacingLabel,
          ),
        ),
        const SizedBox(height: SigapSpacing.sm),
        Text(l10n.reportReviewExplanation),
        const SizedBox(height: SigapSpacing.sm),

        // Card
        SigapCard(
          child: Column(
            children: [
              // Photo + info row
              Padding(
                padding: const EdgeInsets.all(SigapSpacing.x11),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Photo placeholder
                    if (report.photoPath?.isNotEmpty == true)
                      SizedBox(
                        width: 64,
                        height: 64,
                        child: report.photoPath!.startsWith('http')
                            ? Image.network(
                                report.photoPath!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.broken_image_outlined),
                              )
                            : Image.file(
                                File(report.photoPath!),
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.broken_image_outlined),
                              ),
                      )
                    else
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
                              Expanded(
                                child: Text(
                                  l10n.kondisiColonLabel(report.condition),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: SigapTypography.captionMedium,
                                    color: SigapColorScheme.of(
                                      context,
                                    ).textTertiary,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Title
                          const SizedBox(height: 6),
                          Text(
                            report.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: SigapTypography.bodyText,
                              fontWeight: FontWeight.w600,
                              color: SigapColorScheme.of(context).textPrimary,
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
                label: l10n.lokasi,
                value: report.location,
                accuracy: report.accuracy,
                canEdit: report.canEditLocation,
                onEdit: onEditLocation,
              ),

              // Divider
              const _Divider(),

              // Timestamp row
              _InfoRow(
                label: l10n.waktuLabel,
                value: report.timestamp,
                canEdit: report.canEditTimestamp,
                onEdit: onEditTimestamp,
                isTimestamp: true,
              ),

              // Divider
              const _Divider(),

              // Impact row
              if (report.impact.isNotEmpty && report.impact != '—')
                _InfoRow(
                  label: l10n.dampakLabel,
                  value: report.impact,
                  isImpact: true,
                ),
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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            SigapColorScheme.of(context).borderCard,
            SigapColorScheme.of(context).borderCard,
            SigapColorScheme.of(context).bgSoft,
            SigapColorScheme.of(context).bgSoft,
          ],
          stops: [0.0, 0.5, 0.5, 1.0],
        ),
      ),
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        '${AppLocalizations.of(context)!.fotoLabel} $photoIndex',
        style: TextStyle(
          fontFamily: SigapTypography.fontFamilyMono,
          fontSize: SigapTypography.captionNano,
          color: SigapColorScheme.of(context).textMuted,
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
        color: SigapColorScheme.of(context).primaryLight,
        borderRadius: BorderRadius.circular(SigapRadius.sm),
      ),
      child: Text(
        initials,
        style: TextStyle(
          fontFamily: SigapTypography.fontFamilyMono,
          fontSize: SigapTypography.captionSmall,
          fontWeight: FontWeight.w600,
          color: SigapColorScheme.of(context).primaryDark,
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
    return Divider(
      height: 1,
      thickness: 1,
      color: SigapColorScheme.of(context).bgSoft,
    );
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
          Expanded(
            flex: isImpact ? 1 : 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: SigapTypography.bodySmall,
                color: SigapColorScheme.of(context).textTertiary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isImpact)
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: SigapTypography.bodySmall,
                  fontWeight: FontWeight.w600,
                  color: SigapColorScheme.of(context).textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            )
          else if (isTimestamp)
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      value,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: SigapTypography.bodySmall,
                        fontWeight: FontWeight.w600,
                        color: SigapColorScheme.of(context).textPrimary,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (canEdit) ...[
                    const SizedBox(width: 2),
                    GestureDetector(
                      onTap: onEdit,
                      child: const Text(
                        '✎',
                        style: TextStyle(
                          fontSize: SigapTypography.bodySmall,
                          color: SigapColors.primary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            )
          else
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      accuracy != null &&
                              accuracy!.isNotEmpty &&
                              accuracy != '—'
                          ? '$value · $accuracy'
                          : value,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: SigapTypography.bodySmall,
                        fontWeight: FontWeight.w600,
                        color: SigapColorScheme.of(context).textPrimary,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (canEdit) ...[
                    const SizedBox(width: 2),
                    GestureDetector(
                      onTap: onEdit,
                      child: const Text(
                        '✎',
                        style: TextStyle(
                          fontSize: SigapTypography.bodySmall,
                          color: SigapColors.primary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

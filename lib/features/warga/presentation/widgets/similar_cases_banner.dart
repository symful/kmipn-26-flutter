import 'package:flutter/material.dart';
import 'package:sigap/theme/tokens.dart';

/// A case matched by location/similarity during report creation (M-11).
///
/// Used in the SimilarCasesBanner to display duplicate candidates.
class SimilarCase {
  /// Unique report ID.
  final String id;

  /// Short code / initials (e.g. "JL" from "Jalan berlubang").
  final String initials;

  /// Case title.
  final String title;

  /// Distance string, e.g. "42 m".
  final String distance;

  /// Similarity percentage as whole number, e.g. 86.
  final int similarityPercent;

  /// Number of supporting reports for this case.
  final int reportCount;

  const SimilarCase({
    required this.id,
    required this.initials,
    required this.title,
    required this.distance,
    required this.similarityPercent,
    required this.reportCount,
  });
}

/// Blue banner showing similar/relevant cases found near a report location.
///
/// Matches PantauDesa M-11 design spec:
/// - Background: infoBg (#e5edfd) with infoChartBar (#c7d7fb) border, radius 13px
/// - Expandable to show case details
/// - "Tambahkan bukti ke kasus ini" primary action + "Buat terpisah" secondary action
class SimilarCasesBanner extends StatefulWidget {
  /// List of similar cases to display.
  final List<SimilarCase> cases;

  /// Called when user taps "Tambahkan bukti ke kasus ini" on a case.
  final void Function(SimilarCase selectedCase)? onAddEvidence;

  /// Called when user taps "Buat terpisah".
  final VoidCallback? onCreateSeparate;

  /// Called when user taps "Lihat Semua" to expand/collapse details.
  final VoidCallback? onViewAll;

  const SimilarCasesBanner({
    super.key,
    required this.cases,
    this.onAddEvidence,
    this.onCreateSeparate,
    this.onViewAll,
  });

  @override
  State<SimilarCasesBanner> createState() => _SimilarCasesBannerState();
}

class _SimilarCasesBannerState extends State<SimilarCasesBanner> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final count = widget.cases.length;
    final label = '$count kasus serupa ditemukan di dekat sini';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.infoBg,
        border: Border.all(color: AppColors.infoChartBar),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: title + "Lihat Semua" toggle
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: AppTypography.size12_5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.info,
                  ),
                ),
              ),
              if (widget.onViewAll != null) ...[
                const SizedBox(width: AppSpacing.sm),
                GestureDetector(
                  onTap: () {
                    setState(() => _isExpanded = !_isExpanded);
                    widget.onViewAll?.call();
                  },
                  child: Text(
                    _isExpanded ? 'Tutup' : 'Lihat Semua',
                    style: const TextStyle(
                      fontSize: AppTypography.size12_5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.info,
                    ),
                  ),
                ),
              ],
            ],
          ),

          // Expandable case list
          if (_isExpanded && widget.cases.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            ...widget.cases.map(
              (c) => _CaseCard(
                key: ValueKey(c.id),
                caseItem: c,
                onAddEvidence: () => widget.onAddEvidence?.call(c),
              ),
            ),
          ],

          // Expandable: show first case even when collapsed
          if (!_isExpanded && widget.cases.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            _CaseCard(
              key: ValueKey(widget.cases.first.id),
              caseItem: widget.cases.first,
              onAddEvidence: () =>
                  widget.onAddEvidence?.call(widget.cases.first),
              isSingle: true,
            ),
          ],
        ],
      ),
    );
  }
}

class _CaseCard extends StatelessWidget {
  final SimilarCase caseItem;
  final VoidCallback? onAddEvidence;
  final bool isSingle;

  const _CaseCard({
    super.key,
    required this.caseItem,
    this.onAddEvidence,
    this.isSingle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD5E0FB)),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      padding: const EdgeInsets.all(AppSpacing.x11),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar + info row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  caseItem.initials,
                  style: const TextStyle(
                    fontFamily: 'IBM Plex Mono',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.x10),
              // Title + meta
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      caseItem.title,
                      style: const TextStyle(
                        fontSize: AppTypography.size13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      '${caseItem.distance} · kemiripan ${caseItem.similarityPercent}% · ${caseItem.reportCount} laporan',
                      style: const TextStyle(
                        fontSize: AppTypography.size11,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Action buttons
          const SizedBox(height: AppSpacing.x10),
          Row(
            children: [
              // Primary: Tambahkan bukti
              Expanded(
                child: GestureDetector(
                  onTap: onAddEvidence,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.info,
                      borderRadius: BorderRadius.circular(AppRadius.x9),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Tambahkan bukti ke kasus ini',
                      style: TextStyle(
                        fontSize: AppTypography.size12_5,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              // Secondary: Buat terpisah
              Expanded(
                child: GestureDetector(
                  onTap: onAddEvidence,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: AppSpacing.x12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(color: AppColors.infoChartBar),
                      borderRadius: BorderRadius.circular(AppRadius.x9),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Buat terpisah',
                      style: TextStyle(
                        fontSize: AppTypography.size12_5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.info,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

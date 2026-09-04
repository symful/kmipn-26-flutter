import 'package:flutter/material.dart';
import 'package:sigap/api/client.dart';
import 'package:sigap/theme/tokens.dart';
import 'package:sigap/widgets/design_system/sigap_card.dart';
import 'package:sigap/widgets/design_system/status_pill.dart';

/// Unified list item card for report/case display across all roles.
///
/// Extracts the shared structure from [_QueueEntryCard][_CaseCard]:
/// - `SigapCard` base
/// - Top row: `StatusPill` + category badge + optional severity/priority + ID
/// - Description (max 2 lines)
/// - Bottom row: trailing actions + optional sync indicator
///
/// [_QueueEntryCard]: verifikator_queue_screen.dart
/// [_CaseCard]: operator/case_list_screen.dart
class ReportListItem extends StatelessWidget {
  /// The report data to display.
  final Report report;

  /// Called when the card is tapped. If null, tapping is disabled.
  final VoidCallback? onTap;

  /// Actions shown in the bottom row (e.g. accept/reject/chevron buttons).
  /// Pass an empty list to show only the chevron, or null to hide the row.
  final List<Widget>? trailingActions;

  /// When true, shows the server ID badge (truncated to 8 chars).
  /// Defaults to true.
  final bool showId;

  /// When true, shows the local/synced indicator dot using [syncStatus].
  /// Defaults to false.
  final bool showSyncStatus;

  /// When true, shows the severity badge (only when `report.severity != null`).
  /// Defaults to false.
  final bool showSeverity;

  /// When true, shows the priority score badge (only when `report.priorityScore != null`).
  /// Defaults to false.
  final bool showPriorityScore;

  /// The local sync status (0 = local/pending, 1 = synced, etc.).
  /// Only used when [showSyncStatus] is true.
  final int? syncStatus;

  const ReportListItem({
    super.key,
    required this.report,
    this.onTap,
    this.trailingActions,
    this.showId = true,
    this.showSyncStatus = false,
    this.showSeverity = false,
    this.showPriorityScore = false,
    this.syncStatus,
  });

  // -------------------------------------------------------------------------
  // Status helpers
  // -------------------------------------------------------------------------

  StatusTone get _statusTone {
    final status = report.status?.value ?? '';
    switch (status.toLowerCase()) {
      case 'pending':
      case 'submitted':
        return StatusTone.warning;
      case 'under_review':
        return StatusTone.info;
      case 'in_progress':
        return StatusTone.danger; // diproses maps to danger tone (blue)
      case 'verified':
      case 'completed':
        return StatusTone.success;
      case 'rejected':
        return StatusTone.danger;
      case 'resolved':
        return StatusTone.success;
      case 'duplicate_merged':
        return StatusTone.info;
      default:
        return StatusTone.neutral;
    }
  }

  String get _statusLabel {
    final status = report.status?.value ?? '';
    switch (status.toLowerCase()) {
      case 'pending':
      case 'submitted':
        return 'Menunggu';
      case 'under_review':
        return 'Diproses';
      case 'in_progress':
        return 'Dalam Proses';
      case 'verified':
      case 'completed':
        return 'Diverifikasi';
      case 'rejected':
        return 'Ditolak';
      case 'resolved':
        return 'Selesai';
      case 'duplicate_merged':
        return 'Duplikat';
      case 'needs_survey':
        return 'Perlu Survei';
      default:
        return status.isNotEmpty ? status : '-';
    }
  }

  /// Builds a [StatusPill] from [report.status].
  ///
  /// Call this from the top-left position in the card header.
  Widget _buildStatusBadge() {
    return StatusPill(label: _statusLabel, tone: _statusTone);
  }

  StatusTone get _severityTone {
    final s = report.severity;
    if (s == null) return StatusTone.neutral;
    if (s >= 70) return StatusTone.danger;
    if (s >= 40) return StatusTone.warning;
    return StatusTone.success;
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final id = report.id ?? '';
    final description = report.description ?? report.title ?? '';
    final category = report.category;

    return SigapCard(
      padding: const EdgeInsets.all(SigapSpacing.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SigapRadius.x12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header row ---
            Row(
              children: [
                _buildStatusBadge(),
                const SizedBox(width: SigapSpacing.sm),
                if (category != null && category.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SigapSpacing.sm,
                      vertical: SigapSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: SigapColors.bgSoft,
                      borderRadius: BorderRadius.circular(SigapRadius.sm),
                    ),
                    child: Text(
                      category,
                      style: const TextStyle(
                        fontSize: SigapTypography.captionMedium,
                        color: SigapColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
                if (showSeverity && report.severity != null) ...[
                  const SizedBox(width: SigapSpacing.xs),
                  StatusPill(
                    label: 'Severity: ${report.severity}',
                    tone: _severityTone,
                  ),
                ],
                if (showPriorityScore && report.priorityScore != null) ...[
                  const SizedBox(width: SigapSpacing.xs),
                  StatusPill(
                    label: 'Score: ${report.priorityScore}',
                    tone: StatusTone.warning,
                  ),
                ],
                if (showId && id.isNotEmpty) ...[
                  const Spacer(),
                  Text(
                    '#${id.length > 8 ? id.substring(0, 8) : id}',
                    style: const TextStyle(
                      fontSize: SigapTypography.captionSmall,
                      color: SigapColors.textTertiary,
                      fontFamily: SigapTypography.fontFamilyMono,
                    ),
                  ),
                ] else
                  const Spacer(),
              ],
            ),

            // --- Description ---
            if (description.isNotEmpty) ...[
              const SizedBox(height: SigapSpacing.sm),
              Text(
                description,
                style: const TextStyle(
                  fontSize: SigapTypography.bodyTextWide,
                  fontWeight: FontWeight.w500,
                  color: SigapColors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            // --- Bottom row: actions + sync indicator ---
            if (trailingActions != null && trailingActions!.isNotEmpty ||
                showSyncStatus) ...[
              const SizedBox(height: SigapSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (trailingActions != null) ...trailingActions!,
                  if (showSyncStatus && syncStatus != null) ...[
                    if (trailingActions != null && trailingActions!.isNotEmpty)
                      const SizedBox(width: SigapSpacing.xs),
                    _SyncDot(status: syncStatus!),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Small 8px dot indicating local/sync state.
class _SyncDot extends StatelessWidget {
  final int status;
  const _SyncDot({required this.status});

  @override
  Widget build(BuildContext context) {
    // syncStatus: 0 = local/pending (offline dot), 1+ = synced (no dot shown)
    if (status != 0) return const SizedBox.shrink();
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: SigapColors.offlineDot,
        shape: BoxShape.circle,
      ),
    );
  }
}

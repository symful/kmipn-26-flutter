import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:share_plus/share_plus.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/platform_helper.dart';
import '../../api/client.dart' as api_client;
import '../../capabilities/can.dart';
import '../../providers/providers.dart';
import '../../theme/tokens.dart';
import '../../l10n/generated/app_localizations.dart';

import '../../widgets/design_system/buttons.dart';
import '../../widgets/design_system/design_system.dart';
import '../../widgets/design_system/timeline_event.dart';

/// Provider that fetches a single report from the API by ID.
/// Resolves local idempotency keys to server IDs when possible.
final apiReportProvider = FutureProvider.family<api_client.Report, String>((
  ref,
  id,
) async {
  final apiClient = ref.read(apiClientProvider);

  // First, try to resolve local idempotency key to server ID
  final reportRepo = ref.read(reportRepositoryProvider);
  final localReport = await reportRepo.getByIdempotencyKey(id);
  if (localReport != null) {
    // If it has a server ID, use that for the API call
    if (localReport.serverId != null && localReport.serverId!.isNotEmpty) {
      return apiClient.getReportById(localReport.serverId!);
    }
    // Local-only draft — no server ID yet
    // Throw a specific error so the UI can show local data
    throw LocalDraftException(localReport);
  }

  // Not a local idempotency key — try as server ID
  return apiClient.getReportById(id);
});

/// Exception thrown when a report is a local-only draft (not yet synced).
class LocalDraftException implements Exception {
  final dynamic localReport;
  const LocalDraftException(this.localReport);
  @override
  String toString() => 'LocalDraft: Report not yet synced to server';
}

/// Provider that fetches the timeline for a report.
final reportTimelineProvider =
    FutureProvider.family<api_client.TimelineEnvelope, String>((ref, id) async {
      final apiClient = ref.read(apiClientProvider);
      return apiClient.getReportTimeline(id);
    });

/// Provider that fetches OG meta for share preview.
final shareMetadataProvider =
    FutureProvider.family<api_client.ShareMetadata, String>((ref, id) async {
      final apiClient = ref.read(apiClientProvider);
      return apiClient.getShareMetadata(id);
    });

/// Provider that fetches priority data for a report.
final reportPriorityProvider =
    FutureProvider.family<api_client.PriorityResponse?, String>((
      ref,
      id,
    ) async {
      final apiClient = ref.read(apiClientProvider);
      return apiClient.getReportPriority(id);
    });

/// Provider that fetches AI assessment entries for a report.
final reportAssessmentsProvider =
    FutureProvider.family<List<api_client.AgentAssessmentEntry>, String>((
      ref,
      id,
    ) async {
      final apiClient = ref.read(apiClientProvider);
      return apiClient.getReportAssessments(id);
    });

/// Provider that fetches audit trail for a report.
final reportAuditProvider =
    FutureProvider.family<List<api_client.AuditEntry>, String>((ref, id) async {
      final apiClient = ref.read(apiClientProvider);
      return apiClient.getReportAudit(id);
    });

class ReportDetailScreen extends ConsumerWidget {
  final String id;
  const ReportDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final reportAsync = ref.watch(apiReportProvider(id));

    final subtitleText = reportAsync.when(
      data: (report) {
        final localId = _getLocalId(ref, id, report.id);
        return 'Lokal ${localId ?? '-'} · Server ${report.id ?? '-'}';
      },
      loading: () => null,
      error: (_, __) => null,
    );

    return ResponsiveScaffold(
      appBar: SigapAppBar(
        title: l10n.detailLaporan,
        subtitle: subtitleText,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.share_outlined,
              color: SigapColors.textSecondary,
            ),
            onPressed: () => _onShare(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: SigapColors.textSecondary),
            onPressed: () {},
          ),
        ],
      ),
      body: reportAsync.when(
        data: (report) {
          final photoUrls = report.photos ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(SigapSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Status banner (dynamic, with Lengkapi button inside)
                _buildStatusBanner(context, ref, report),

                // 2. Parent-case card (when merged_into present)
                if (report.mergedInto != null &&
                    report.mergedInto!.isNotEmpty) ...[
                  const SizedBox(height: SigapSpacing.lg),
                  _buildParentCaseCard(context, report),
                ],

                // 3. Photo gallery (compact)
                if (photoUrls.isNotEmpty) ...[
                  const SizedBox(height: SigapSpacing.lg),
                  _buildPhotoGallery(context, photoUrls),
                ],

                // 4. Compact info card (description + category, location,
                //    priority, created at)
                const SizedBox(height: SigapSpacing.lg),
                _buildInfoCard(context, report),

                // 4a. Priority score section with breakdown bars
                _buildPrioritySection(context, ref),

                // 4b. Impact dampak section
                _buildImpactDampakSection(context, report),

                // 4c. Mini map with location marker
                if (report.lat != null && report.lng != null) ...[
                  const SizedBox(height: SigapSpacing.lg),
                  _buildMiniMap(context, report),
                ],

                // 5. Timeline
                const SizedBox(height: SigapSpacing.xl),
                _buildTimelineSection(context, ref),

                // 5a. AI assessment section
                _buildAssessmentSection(context, ref),

                // 5b. Audit trail section
                _buildAuditTrailSection(context, ref),

                // 6. Privacy info
                const SizedBox(height: SigapSpacing.xl),
                _buildPrivacyInfo(context),

                // 7. Sanggahan button (only for rejected status)
                _buildSanggahanButton(context, ref, report, id),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) {
          // Local-only draft — show offline detail
          if (e is LocalDraftException) {
            return _buildLocalDraftDetail(context, ref, e.localReport);
          }
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: SigapColors.perluTindakan,
                ),
                const SizedBox(height: SigapSpacing.md),
                Text(
                  l10n.errorDenganPesan(e.toString()),
                  style: const TextStyle(
                    fontSize: SigapTypography.bodyMedium,
                    color: SigapColors.textSecondary,
                  ),
                ),
                const SizedBox(height: SigapSpacing.md),
                OutlinedButton(
                  onPressed: () => ref.invalidate(apiReportProvider(id)),
                  child: Text(l10n.cobaLagi),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _onShare(BuildContext context, WidgetRef ref) async {
    final shareMeta = await ref.read(shareMetadataProvider(id).future);
    final shareUrl = shareMeta.url ?? 'https://sigap.live/public/cases/$id';
    final shareText = shareMeta.title != null && shareMeta.description != null
        ? '${shareMeta.title}\n\n${shareMeta.description}\n\n$shareUrl'
        : shareUrl;
    await Share.share(shareText, subject: shareMeta.title);
  }

  Widget _buildStatusBanner(
    BuildContext context,
    WidgetRef ref,
    api_client.Report report,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final status = report.status?.value ?? '';

    // Only show banner for statuses that require user action
    if (status != 'needs_completion') return const SizedBox.shrink();

    // Format deadline if present
    String deadlineText = '';
    if (report.deadline != null && report.deadline!.isNotEmpty) {
      try {
        final dt = DateTime.parse(report.deadline!);
        deadlineText = '${dt.day} ${_monthName(dt.month)} ${dt.year}';
      } catch (_) {
        deadlineText = report.deadline!;
      }
    }

    return SigapCard(
      borderLeftColor: SigapColors.offlineDot,
      padding: const EdgeInsets.all(SigapSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // "Perlu tindakan Anda" badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: SigapSpacing.x10,
              vertical: SigapSpacing.x4,
            ),
            decoration: BoxDecoration(
              color: SigapColors.offlineDot,
              borderRadius: BorderRadius.circular(SigapRadius.x7),
            ),
            child: Text(
              l10n.perluTindakanAnda,
              style: const TextStyle(
                color: SigapColors.surface,
                fontSize: SigapTypography.bodySmall,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: SigapSpacing.x9),
          // Description text with optional deadline
          if (deadlineText.isNotEmpty)
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: SigapTypography.bodySmallFine,
                  color: SigapColors.warningTextStrong,
                  height: SigapTypography.lineHeight145,
                ),
                children: [
                  TextSpan(text: '${l10n.verifikatorMemintaInfo} '),
                  TextSpan(
                    text: l10n.tenggatTanggal(deadlineText),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            )
          else
            Text(
              l10n.verifikatorMemintaInfo,
              style: TextStyle(
                fontSize: SigapTypography.bodySmallFine,
                color: SigapColors.warningTextStrong,
                height: SigapTypography.lineHeight145,
              ),
            ),
          const SizedBox(height: SigapSpacing.md),
          // "Lengkapi laporan" button — inline with the banner
          SizedBox(
            width: double.infinity,
            child: Can(
              action: 'report.lengkapi',
              resource: Resource(type: 'report', id: id),
              child: PrimaryButton(
                label: l10n.lengkapiLaporan,
                onPressed: () =>
                    _showLengkapiBottomSheet(context, ref, report, id),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const months = [
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
    return months[month - 1];
  }

  Widget _buildParentCaseCard(BuildContext context, api_client.Report report) {
    final l10n = AppLocalizations.of(context)!;
    final categoryTag = report.category != null && report.category!.length >= 2
        ? report.category!.substring(0, 2).toUpperCase()
        : 'CS';
    final caseTitle = report.title ?? report.mergedInto ?? 'Kasus';

    return GestureDetector(
      onTap: () => context.push('/laporan/${report.mergedInto}'),
      child: SigapCard(
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: SigapColors.bgSoft,
                borderRadius: BorderRadius.circular(SigapRadius.sm),
              ),
              alignment: Alignment.center,
              child: Text(
                categoryTag,
                style: const TextStyle(
                  fontSize: SigapTypography.bodyText,
                  fontWeight: FontWeight.w700,
                  color: SigapColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: SigapSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.bagianDariKasus,
                    style: TextStyle(
                      fontSize: SigapTypography.captionMedium,
                      color: SigapColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: SigapSpacing.xxs),
                  Text(
                    caseTitle,
                    style: const TextStyle(
                      fontSize: SigapTypography.bodyMedium,
                      color: SigapColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Text(
              '${l10n.lihatLabel} ',
              style: TextStyle(
                fontSize: SigapTypography.bodyText,
                color: SigapColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Icon(
              Icons.arrow_forward,
              color: SigapColors.primary,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoGallery(BuildContext context, List<String> photoUrls) {
    if (photoUrls.length == 1) {
      return GestureDetector(
        onTap: () => _showPhotoFullScreen(context, photoUrls, 0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(SigapRadius.md),
          child: Image.network(
            photoUrls.first,
            width: double.infinity,
            height: 160,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              height: 160,
              color: SigapColors.bgSoft,
              child: const Center(child: Icon(Icons.image_not_supported)),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: photoUrls.length,
        separatorBuilder: (_, __) => const SizedBox(width: SigapSpacing.sm),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _showPhotoFullScreen(context, photoUrls, index),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(SigapRadius.sm),
              child: Image.network(
                photoUrls[index],
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 100,
                  height: 100,
                  color: SigapColors.bgSoft,
                  child: const Center(
                    child: Icon(Icons.image_not_supported, size: 28),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showPhotoFullScreen(BuildContext ctx, List<String> photos, int index) {
    PhotoFullScreen.show(ctx, photos, index);
  }

  Widget _buildTimelineSection(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final timelineAsync = ref.watch(reportTimelineProvider(id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(label: l10n.perjalananLaporanHeader),
        const SizedBox(height: SigapSpacing.md),
        timelineAsync.when(
          data: (timelineData) {
            final events = timelineData.events;
            if (events?.isEmpty ?? true) {
              return EmptyState(
                icon: Icons.timeline,
                title: l10n.belumAdaRiwayat,
                subtitle: l10n.perjalananLaporanDitampilkan,
              );
            }
            return _TimelineWidget(events: events ?? []);
          },
          loading: () =>
              const SkeletonBox(height: 100, borderRadius: SigapRadius.md),
          error: (_, __) => ErrorRetryView(
            message: l10n.gagalMemuatRiwayat,
            onRetry: () => ref.invalidate(reportTimelineProvider(id)),
          ),
        ),
      ],
    );
  }

  Widget _buildPrivacyInfo(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(SigapSpacing.md),
      decoration: BoxDecoration(
        color: SigapColors.bgSoft,
        borderRadius: BorderRadius.circular(SigapRadius.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: SigapColors.textTertiary, width: 2),
            ),
            alignment: Alignment.center,
            child: const Text(
              'i',
              style: TextStyle(
                fontSize: SigapTypography.captionMedium,
                fontWeight: FontWeight.w700,
                color: SigapColors.textTertiary,
              ),
            ),
          ),
          const SizedBox(width: SigapSpacing.sm),
          Expanded(
            child: Text(
              l10n.privasiInfo,
              style: const TextStyle(
                fontSize: SigapTypography.captionFine,
                color: SigapColors.textSecondary,
                height: SigapTypography.lineHeight140,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the Sanggahan action button shown when report is rejected (DITOLAK).
  Widget _buildSanggahanButton(
    BuildContext context,
    WidgetRef ref,
    api_client.Report report,
    String reportId,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final status = report.status?.value ?? '';

    // Only show for rejected status (DITOLAK = rejected by verifier)
    if (status != 'rejected') {
      return const SizedBox.shrink();
    }

    return Can(
      action: 'report.sanggah',
      resource: Resource(type: 'report', id: reportId),
      child: Padding(
        padding: const EdgeInsets.only(top: SigapSpacing.md),
        child: DangerButton(
          label: l10n.sanggahKeputusan,
          onPressed: () => _showSanggahanBottomSheet(context, ref, reportId),
        ),
      ),
    );
  }

  void _showLengkapiBottomSheet(
    BuildContext context,
    WidgetRef ref,
    api_client.Report report,
    String reportId,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _LengkapiBottomSheet(
        reportId: reportId,
        onComplete: () {
          // Refresh the report detail after completing
          ref.invalidate(apiReportProvider(reportId));
          ref.invalidate(reportTimelineProvider(reportId));
        },
      ),
    );
  }

  void _showSanggahanBottomSheet(
    BuildContext context,
    WidgetRef ref,
    String reportId,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _SanggahanBottomSheet(
        reportId: reportId,
        onComplete: () {
          // Refresh the report detail after submitting sanggahan
          ref.invalidate(apiReportProvider(reportId));
          ref.invalidate(reportTimelineProvider(reportId));
        },
      ),
    );
  }

  /// Compact info card grouping description, category, location, priority,
  /// and created at — replaces separate labeled sections from the design.
  Widget _buildInfoCard(BuildContext context, api_client.Report report) {
    final l10n = AppLocalizations.of(context)!;
    final createdAtStr = report.createdAt;
    final updatedAtStr = report.updatedAt;
    final locationText =
        report.addressArea ??
        report.address ??
        '${report.location?['lat']?.toStringAsFixed(6) ?? '-'}, ${report.location?['lng']?.toStringAsFixed(6) ?? '-'}';

    // Determine display title: title first, then description
    final displayTitle = report.title?.isNotEmpty == true
        ? report.title!
        : report.description?.isNotEmpty == true
        ? report.description!
        : '-';

    return SigapCard(
      padding: const EdgeInsets.all(SigapSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title (if present)
          if (report.title != null && report.title!.isNotEmpty) ...[
            Text(
              report.title!,
              style: const TextStyle(
                fontSize: SigapTypography.bodyLarge,
                fontWeight: FontWeight.w700,
                color: SigapColors.textPrimary,
                height: SigapTypography.lineHeight150,
              ),
            ),
            const SizedBox(height: SigapSpacing.xs),
          ],
          // Description (if different from title)
          if (report.description != null &&
              report.description!.isNotEmpty &&
              report.description != report.title) ...[
            Text(
              report.description!,
              style: const TextStyle(
                fontSize: SigapTypography.bodyMedium,
                color: SigapColors.textSecondary,
                height: SigapTypography.lineHeight150,
              ),
            ),
            const SizedBox(height: SigapSpacing.md),
            const Divider(height: 1, color: SigapColors.border),
            const SizedBox(height: SigapSpacing.md),
          ] else ...[
            const Divider(height: 1, color: SigapColors.border),
            const SizedBox(height: SigapSpacing.md),
          ],
          // Compact field rows
          _buildInfoRow(
            Icons.category_outlined,
            l10n.kategori,
            report.category ?? '-',
          ),
          const SizedBox(height: SigapSpacing.xs),
          _buildInfoRow(
            Icons.location_on_outlined,
            l10n.lokasi,
            locationText,
            isMono: true,
          ),
          const SizedBox(height: SigapSpacing.xs),
          _buildInfoRow(
            Icons.flag_outlined,
            l10n.labelTingkatPrioritas,
            _formatPriorityLabel(report),
          ),
          if (report.deadline != null && report.deadline!.isNotEmpty) ...[
            const SizedBox(height: SigapSpacing.xs),
            _buildInfoRow(
              Icons.event_outlined,
              'Tenggat',
              _formatApiDate(report.deadline!),
            ),
          ],
          const SizedBox(height: SigapSpacing.xs),
          _buildInfoRow(
            Icons.schedule_outlined,
            l10n.labelDibuat,
            createdAtStr != null ? _formatApiDate(createdAtStr) : '-',
          ),
          if (updatedAtStr != null && updatedAtStr != createdAtStr) ...[
            const SizedBox(height: SigapSpacing.xs),
            _buildInfoRow(
              Icons.update_outlined,
              l10n.labelTerakhirDiperbarui,
              _formatApiDate(updatedAtStr),
            ),
          ],
          if (report.slaDeadline != null && report.slaDeadline!.isNotEmpty) ...[
            const SizedBox(height: SigapSpacing.xs),
            _buildInfoRow(
              Icons.timer_outlined,
              'Batas SLA',
              _formatApiDate(report.slaDeadline!),
            ),
          ],
        ],
      ),
    );
  }

  /// Format priority label with bucket info when available.
  String _formatPriorityLabel(api_client.Report report) {
    final parts = <String>[];
    if (report.priority != null) {
      parts.add(report.priority!.value.toUpperCase());
    }
    if (report.priorityBucket != null) {
      parts.add('(${report.priorityBucket})');
    }
    if (report.severity != null) {
      parts.add('· Severity: ${report.severity}');
    }
    return parts.isEmpty ? '-' : parts.join(' ');
  }

  /// Single row in the info card: icon + label/value column.
  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    bool isMono = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: SigapColors.textMuted),
        const SizedBox(width: SigapSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: SigapTypography.captionMedium,
                  color: SigapColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: SigapSpacing.xxs),
              Text(
                value,
                style: TextStyle(
                  fontSize: SigapTypography.bodySmall,
                  fontFamily: isMono ? SigapTypography.fontFamilyMono : null,
                  color: SigapColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatApiDate(String isoString) {
    try {
      final dt = DateTime.parse(isoString);
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return isoString;
    }
  }

  Widget _buildLocalDraftDetail(
    BuildContext context,
    WidgetRef ref,
    dynamic localReport,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(SigapSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: SigapSpacing.md,
              vertical: SigapSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: SigapColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(SigapRadius.sm),
            ),
            child: Row(
              children: [
                Icon(Icons.cloud_off, size: 16, color: SigapColors.warning),
                const SizedBox(width: SigapSpacing.sm),
                Expanded(
                  child: Text(
                    l10n.belumDisinkronkan,
                    style: TextStyle(
                      fontSize: SigapTypography.bodySmall,
                      color: SigapColors.warning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: SigapSpacing.lg),
          SectionLabel(label: l10n.deskripsi),
          const SizedBox(height: SigapSpacing.xs),
          Text(
            localReport.description ?? '-',
            style: const TextStyle(
              fontSize: SigapTypography.bodyMedium,
              color: SigapColors.textPrimary,
            ),
          ),
          const SizedBox(height: SigapSpacing.lg),
          SectionLabel(label: l10n.lokasi),
          const SizedBox(height: SigapSpacing.xs),
          Text(
            '${localReport.lat?.toStringAsFixed(6) ?? '-'}, ${localReport.lng?.toStringAsFixed(6) ?? '-'}',
            style: const TextStyle(
              fontSize: SigapTypography.bodyMedium,
              fontFamily: SigapTypography.fontFamilyMono,
              color: SigapColors.textPrimary,
            ),
          ),
          const SizedBox(height: SigapSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: SigapColors.primary,
                foregroundColor: SigapColors.surface,
              ),
              child: Text(l10n.kembali),
            ),
          ),
        ],
      ),
    );
  }

  /// Returns the local idempotency key for this report if the route [reportId]
  /// matches a pending local report (not yet synced to server). Returns null if
  /// the report has been synced — the server only stores the server ID.
  String? _getLocalId(WidgetRef ref, String reportId, String? serverId) {
    // If the route ID != server ID, the route ID is the local idempotency key
    if (serverId != null && reportId != serverId) {
      return reportId;
    }
    return null;
  }

  /// Priority score section with breakdown progress bars.
  Widget _buildPrioritySection(BuildContext context, WidgetRef ref) {
    final priorityAsync = ref.watch(reportPriorityProvider(id));

    return priorityAsync.when(
      data: (priority) {
        if (priority == null) return const SizedBox.shrink();
        final score = priority.score ?? 0;
        final level = priority.level ?? '-';
        final breakdown = priority.breakdown;

        // Color for priority level
        Color levelColor;
        switch (level) {
          case 'Kritis':
            levelColor = SigapColors.perluTindakan;
            break;
          case 'Tinggi':
            levelColor = SigapColors.warning;
            break;
          case 'Sedang':
            levelColor = SigapColors.diproses;
            break;
          case 'Rendah':
            levelColor = SigapColors.selesai;
            break;
          default:
            levelColor = SigapColors.textMuted;
        }

        return Padding(
          padding: const EdgeInsets.only(top: SigapSpacing.lg),
          child: SigapCard(
            padding: const EdgeInsets.all(SigapSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '$score',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: levelColor,
                      ),
                    ),
                    const SizedBox(width: SigapSpacing.sm),
                    Text(
                      'Skor prioritas / 100',
                      style: TextStyle(
                        fontSize: SigapTypography.bodySmall,
                        color: SigapColors.textMuted,
                      ),
                    ),
                    const SizedBox(width: SigapSpacing.md),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: SigapSpacing.sm,
                        vertical: SigapSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: levelColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(SigapRadius.sm),
                      ),
                      child: Text(
                        'Prioritas $level',
                        style: TextStyle(
                          fontSize: SigapTypography.captionMedium,
                          fontWeight: FontWeight.w600,
                          color: levelColor,
                        ),
                      ),
                    ),
                  ],
                ),
                if (breakdown != null) ...[
                  const SizedBox(height: SigapSpacing.md),
                  const Divider(height: 1, color: SigapColors.border),
                  const SizedBox(height: SigapSpacing.md),
                  _buildBreakdownBar(
                    'Keselamatan',
                    breakdown.severity ?? 0,
                    SigapColors.primary,
                  ),
                  const SizedBox(height: SigapSpacing.xs),
                  _buildBreakdownBar(
                    'Jumlah terdampak',
                    breakdown.affectedResidents ?? 0,
                    SigapColors.primary,
                  ),
                  if (breakdown.reportCount != null) ...[
                    const SizedBox(height: SigapSpacing.xs),
                    _buildBreakdownBar(
                      'Laporan pendukung',
                      breakdown.reportCount!,
                      SigapColors.primary,
                    ),
                  ],
                  const SizedBox(height: SigapSpacing.xs),
                  _buildBreakdownBar(
                    'Kelewatan SLA',
                    breakdown.slaPressure ?? 0,
                    SigapColors.warning,
                  ),
                  const SizedBox(height: SigapSpacing.sm),
                  Row(
                    children: [
                      Text(
                        'Laporan Pendukung',
                        style: TextStyle(
                          fontSize: SigapTypography.bodySmall,
                          color: SigapColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${_reportSupportingCount(ref) ?? 0}',
                        style: TextStyle(
                          fontSize: SigapTypography.bodySmall,
                          fontWeight: FontWeight.w600,
                          color: SigapColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  /// Helper to get supporting count from the report data.
  int? _reportSupportingCount(WidgetRef ref) {
    try {
      final reportAsync = ref.read(apiReportProvider(id));
      return reportAsync.value?.supportingCount;
    } catch (_) {
      return null;
    }
  }

  /// Single breakdown progress bar row.
  Widget _buildBreakdownBar(String label, int value, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(
              fontSize: SigapTypography.bodySmall,
              color: SigapColors.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: SigapSpacing.sm),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(SigapRadius.x2),
            child: LinearProgressIndicator(
              value: (value / 100).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: SigapColors.bgSoft,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: SigapSpacing.sm),
        SizedBox(
          width: 32,
          child: Text(
            '+$value',
            style: TextStyle(
              fontSize: SigapTypography.bodySmall,
              fontWeight: FontWeight.w600,
              color: SigapColors.textPrimary,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  /// Impact dampak section with icons for the 5 impact types.
  Widget _buildImpactDampakSection(
    BuildContext context,
    api_client.Report report,
  ) {
    final impactStr = report.impactDampak;
    if (impactStr == null || impactStr.isEmpty) return const SizedBox.shrink();

    // Parse impact_dampak JSON string (array of strings)
    List<String> dampakList;
    try {
      dampakList = _parseImpactDampak(impactStr);
    } catch (_) {
      return const SizedBox.shrink();
    }

    if (dampakList.isEmpty) return const SizedBox.shrink();

    const dampakLabels = <String, String>{
      'keselamatan': 'Keselamatan',
      'akses': 'Akses wilayah terganggu',
      'layanan_sekolah': 'Layanan sekolah terhambat',
      'ekonomi': 'Dampak ekonomi',
      'lingkungan': 'Dampak lingkungan',
    };

    const dampakIcons = <String, IconData>{
      'keselamatan': Icons.shield_outlined,
      'akses': Icons.route_outlined,
      'layanan_sekolah': Icons.school_outlined,
      'ekonomi': Icons.account_balance_outlined,
      'lingkungan': Icons.eco_outlined,
    };

    return Padding(
      padding: const EdgeInsets.only(top: SigapSpacing.lg),
      child: SigapCard(
        padding: const EdgeInsets.all(SigapSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dampak',
              style: TextStyle(
                fontSize: SigapTypography.captionMedium,
                fontWeight: FontWeight.w700,
                color: SigapColors.textMuted,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: SigapSpacing.sm),
            ...dampakList.map(
              (key) => Padding(
                padding: const EdgeInsets.only(bottom: SigapSpacing.xs),
                child: Row(
                  children: [
                    Icon(
                      dampakIcons[key] ?? Icons.info_outline,
                      size: 16,
                      color: SigapColors.warning,
                    ),
                    const SizedBox(width: SigapSpacing.sm),
                    Text(
                      dampakLabels[key] ?? key,
                      style: const TextStyle(
                        fontSize: SigapTypography.bodySmall,
                        color: SigapColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: SigapSpacing.sm),
            const Divider(height: 1, color: SigapColors.border),
            const SizedBox(height: SigapSpacing.sm),
            Text(
              'Laporan warga dalam radius terkait.',
              style: TextStyle(
                fontSize: SigapTypography.captionFine,
                color: SigapColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Parse impact_dampak which may be a JSON array string or comma-separated.
  List<String> _parseImpactDampak(String raw) {
    // Try JSON parse first
    try {
      final dynamic decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded.map((e) => e.toString()).toList();
      }
    } catch (_) {}
    // Fallback: comma-separated
    return raw
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  /// Mini map using flutter_map with a single location marker.
  Widget _buildMiniMap(BuildContext context, api_client.Report report) {
    final lat = report.lat!;
    final lng = report.lng!;
    final center = latlong.LatLng(lat, lng);

    return SigapCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 160,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(SigapRadius.md),
              ),
              child: FlutterMap(
                options: MapOptions(initialCenter: center, initialZoom: 14),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                    subdomains: const ['a', 'b', 'c'],
                    userAgentPackageName: 'id.sigap.app',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: center,
                        width: 20,
                        height: 20,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: SigapColors.perluTindakan,
                            border: Border.all(
                              color: SigapColors.surface,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(SigapSpacing.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}',
                  style: TextStyle(
                    fontSize: SigapTypography.captionMedium,
                    fontFamily: SigapTypography.fontFamilyMono,
                    color: SigapColors.textMuted,
                  ),
                ),
                if (report.address != null && report.address!.isNotEmpty)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: SigapSpacing.sm),
                      child: Text(
                        report.address!,
                        style: TextStyle(
                          fontSize: SigapTypography.captionMedium,
                          color: SigapColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// AI assessment viewer section.
  Widget _buildAssessmentSection(BuildContext context, WidgetRef ref) {
    final assessmentsAsync = ref.watch(reportAssessmentsProvider(id));

    return assessmentsAsync.when(
      data: (assessments) {
        if (assessments.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: SigapSpacing.xl),
          child: SigapCard(
            padding: const EdgeInsets.all(SigapSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionLabel(label: 'Penilaian AI'),
                const SizedBox(height: SigapSpacing.md),
                ...assessments.map((a) => _buildAssessmentEntry(a)),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  /// Single assessment entry card.
  Widget _buildAssessmentEntry(api_client.AgentAssessmentEntry entry) {
    final confidence = ((entry.confidence ?? 0) * 100).round();
    final statusColor = entry.status == 'completed'
        ? SigapColors.selesai
        : entry.status == 'failed'
        ? SigapColors.perluTindakan
        : SigapColors.warning;

    return Container(
      margin: const EdgeInsets.only(bottom: SigapSpacing.sm),
      padding: const EdgeInsets.all(SigapSpacing.sm),
      decoration: BoxDecoration(
        border: Border.all(color: SigapColors.borderCard),
        borderRadius: BorderRadius.circular(SigapRadius.sm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                entry.toolName ?? '-',
                style: const TextStyle(
                  fontSize: SigapTypography.bodySmall,
                  fontWeight: FontWeight.w600,
                  color: SigapColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: SigapSpacing.xs,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(SigapRadius.x7),
                ),
                child: Text(
                  entry.status ?? '-',
                  style: TextStyle(
                    fontSize: SigapTypography.captionMedium,
                    fontWeight: FontWeight.w500,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: SigapSpacing.xxs),
          Text(
            'Model: ${entry.modelVersion ?? '-'} - Confidence: $confidence%',
            style: TextStyle(
              fontSize: SigapTypography.captionFine,
              color: SigapColors.textMuted,
            ),
          ),
          if (entry.supportingFactors?.isNotEmpty ?? false) ...[
            const SizedBox(height: SigapSpacing.xs),
            Text(
              'Faktor pendukung:',
              style: TextStyle(
                fontSize: SigapTypography.captionMedium,
                fontWeight: FontWeight.w600,
                color: SigapColors.textSecondary,
              ),
            ),
            ...entry.supportingFactors!.map(
              (f) => Padding(
                padding: const EdgeInsets.only(top: 2, left: SigapSpacing.xs),
                child: Text(
                  '+ $f',
                  style: TextStyle(
                    fontSize: SigapTypography.captionFine,
                    color: SigapColors.textTertiary,
                  ),
                ),
              ),
            ),
          ],
          if (entry.riskFactors?.isNotEmpty ?? false) ...[
            const SizedBox(height: SigapSpacing.xs),
            Text(
              'Faktor risiko:',
              style: TextStyle(
                fontSize: SigapTypography.captionMedium,
                fontWeight: FontWeight.w600,
                color: SigapColors.perluTindakan,
              ),
            ),
            ...entry.riskFactors!.map(
              (f) => Padding(
                padding: const EdgeInsets.only(top: 2, left: SigapSpacing.xs),
                child: Text(
                  '- $f',
                  style: TextStyle(
                    fontSize: SigapTypography.captionFine,
                    color: SigapColors.textTertiary,
                  ),
                ),
              ),
            ),
          ],
          if (entry.createdAt != null) ...[
            const SizedBox(height: SigapSpacing.xs),
            Text(
              _formatApiDate(entry.createdAt!),
              style: TextStyle(
                fontSize: SigapTypography.captionFine,
                color: SigapColors.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Audit trail section.
  Widget _buildAuditTrailSection(BuildContext context, WidgetRef ref) {
    final auditAsync = ref.watch(reportAuditProvider(id));

    return auditAsync.when(
      data: (entries) {
        if (entries.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: SigapSpacing.xl),
          child: SigapCard(
            padding: const EdgeInsets.all(SigapSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionLabel(label: 'Riwayat Audit'),
                const SizedBox(height: SigapSpacing.md),
                ...entries.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final audit = entry.value;
                  final isLast = idx == entries.length - 1;
                  return _buildAuditEntry(audit, isLast);
                }),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  /// Single audit trail entry.
  Widget _buildAuditEntry(api_client.AuditEntry entry, bool isLast) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline dot and line
        Column(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isLast ? SigapColors.primary : SigapColors.borderSoft,
              ),
            ),
            if (!isLast)
              Container(width: 2, height: 32, color: SigapColors.borderSoft),
          ],
        ),
        const SizedBox(width: SigapSpacing.sm),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: SigapSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.action ?? '-',
                  style: const TextStyle(
                    fontSize: SigapTypography.bodySmall,
                    fontWeight: FontWeight.w600,
                    color: SigapColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${entry.timestamp != null ? _formatApiDate(entry.timestamp!) : '-'} - ${entry.userId ?? 'sistem'}',
                  style: TextStyle(
                    fontSize: SigapTypography.captionFine,
                    fontFamily: SigapTypography.fontFamilyMono,
                    color: SigapColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Timeline widget showing report history events.
class _TimelineWidget extends StatelessWidget {
  final List<api_client.TimelineEvent> events;
  const _TimelineWidget({required this.events});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        for (int i = 0; i < events.length; i++)
          TimelineEvent(
            title: events[i].message ?? events[i].type ?? l10n.eventFallback,
            subtitle: _formatDate(events[i].timestamp),
            actor: events[i].userId,
            variant: _getVariant(events[i].type),
            isLast: i == events.length - 1,
          ),
      ],
    );
  }

  TimelineVariant _getVariant(String? eventType) {
    switch (eventType) {
      case 'needs_completion':
        return TimelineVariant.amber;
      default:
        return TimelineVariant.teal;
    }
  }

  String _formatDate(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso);
      return '${dt.day} Jul, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }
}

/// Bottom sheet for completing a report with additional photos and description.
class _LengkapiBottomSheet extends ConsumerStatefulWidget {
  final String reportId;
  final VoidCallback? onComplete;

  const _LengkapiBottomSheet({required this.reportId, this.onComplete});

  @override
  ConsumerState<_LengkapiBottomSheet> createState() =>
      _LengkapiBottomSheetState();
}

class _LengkapiBottomSheetState extends ConsumerState<_LengkapiBottomSheet> {
  final _descriptionController = TextEditingController();
  final _imagePicker = ImagePicker();
  XFile? _selectedPhoto;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final photo = await _imagePicker.pickImage(
      source: cameraSource(),
      imageQuality: 85,
    );
    if (photo != null) {
      setState(() => _selectedPhoto = photo);
    }
  }

  Future<void> _pickFromGallery() async {
    final photo = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (photo != null) {
      setState(() => _selectedPhoto = photo);
    }
  }

  Future<void> _submit() async {
    if (_selectedPhoto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.silakanTambahFotoDahulu),
          backgroundColor: SigapColors.danger,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final client = ref.read(apiClientProvider);

      // Upload photo first to get URL
      final uploadResult = await client.getPhotoUploadUrl(
        widget.reportId,
        'lengkapi-upload-token',
      );

      final putUrl = uploadResult.putUrl;
      if (putUrl == null) {
        throw Exception(AppLocalizations.of(context)!.gagalUrlUpload);
      }

      final bytes = await _selectedPhoto!.readAsBytes();

      await client.putPhoto(
        reportId: widget.reportId,
        putUrl: putUrl,
        bytes: bytes,
        contentType: 'image/jpeg',
      );

      // Call reportAction with lengkapi action
      await client.reportAction(
        reportId: widget.reportId,
        action: 'lengkapi',
        note: _descriptionController.text.isNotEmpty
            ? _descriptionController.text
            : null,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.laporanBerhasilDilengkapi,
          ),
          backgroundColor: SigapColors.primary,
        ),
      );

      widget.onComplete?.call();
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.gagalMelengkapiLaporan(e.toString()),
          ),
          backgroundColor: SigapColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: SigapColors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(SigapRadius.x16),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: SigapSpacing.x12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: SigapColors.border,
                borderRadius: BorderRadius.circular(SigapRadius.x2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(SigapSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.lengkapiLaporan,
                    style: const TextStyle(
                      fontSize: SigapTypography.headlineSmall,
                      fontWeight: FontWeight.w700,
                      color: SigapColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: SigapSpacing.xs),
                  Text(
                    l10n.tambahkanFotoDeskripsi,
                    style: TextStyle(
                      fontSize: SigapTypography.bodyMedium,
                      color: SigapColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(SigapSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Photo selection
                    const Text(
                      'Foto',
                      style: TextStyle(
                        fontSize: SigapTypography.bodyMedium,
                        fontWeight: FontWeight.w600,
                        color: SigapColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: SigapSpacing.sm),
                    if (_selectedPhoto != null)
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(SigapRadius.md),
                            child: Image.network(
                              _selectedPhoto!.path,
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                height: 200,
                                color: SigapColors.bgSoft,
                                child: const Center(
                                  child: Icon(Icons.image_not_supported),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: SigapSpacing.sm,
                            right: SigapSpacing.sm,
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedPhoto = null),
                              child: Container(
                                padding: const EdgeInsets.all(SigapSpacing.x4),
                                decoration: const BoxDecoration(
                                  color: SigapColors.danger,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: SigapColors.surface,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: _PhotoOptionButton(
                              icon: Icons.camera_alt,
                              label: l10n.kamera,
                              onTap: _pickPhoto,
                            ),
                          ),
                          const SizedBox(width: SigapSpacing.sm),
                          Expanded(
                            child: _PhotoOptionButton(
                              icon: Icons.photo_library,
                              label: l10n.galeri,
                              onTap: _pickFromGallery,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: SigapSpacing.xl),

                    // Description
                    Text(
                      l10n.deskripsiOpsional,
                      style: TextStyle(
                        fontSize: SigapTypography.bodyMedium,
                        fontWeight: FontWeight.w600,
                        color: SigapColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: SigapSpacing.sm),
                    TextField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: l10n.jelaskanInfoTambahan,
                        hintStyle: const TextStyle(
                          color: SigapColors.textMuted,
                          fontSize: SigapTypography.bodyMedium,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(SigapRadius.md),
                          borderSide: const BorderSide(
                            color: SigapColors.borderCard,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(SigapRadius.md),
                          borderSide: const BorderSide(
                            color: SigapColors.borderCard,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(SigapRadius.md),
                          borderSide: const BorderSide(
                            color: SigapColors.primary,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Submit button
            Padding(
              padding: EdgeInsets.only(
                left: SigapSpacing.lg,
                right: SigapSpacing.lg,
                bottom:
                    MediaQuery.of(context).viewInsets.bottom + SigapSpacing.lg,
              ),
              child: PrimaryButton(
                label: l10n.kirimLabel,
                isLoading: _isSubmitting,
                onPressed: _isSubmitting ? null : _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoOptionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PhotoOptionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: SigapSpacing.lg),
        decoration: BoxDecoration(
          color: SigapColors.bgSoft,
          borderRadius: BorderRadius.circular(SigapRadius.md),
          border: Border.all(color: SigapColors.borderCard),
        ),
        child: Column(
          children: [
            Icon(icon, color: SigapColors.primary, size: 32),
            const SizedBox(height: SigapSpacing.xs),
            Text(
              label,
              style: const TextStyle(
                fontSize: SigapTypography.bodyText,
                color: SigapColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet for submitting a formal objection (sanggahan) to a rejected report.
class _SanggahanBottomSheet extends ConsumerStatefulWidget {
  final String reportId;
  final VoidCallback? onComplete;

  const _SanggahanBottomSheet({required this.reportId, this.onComplete});

  @override
  ConsumerState<_SanggahanBottomSheet> createState() =>
      _SanggahanBottomSheetState();
}

class _SanggahanBottomSheetState extends ConsumerState<_SanggahanBottomSheet> {
  final _reasonController = TextEditingController();
  final _imagePicker = ImagePicker();
  XFile? _selectedPhoto;
  bool _isSubmitting = false;
  String? _errorMessage;

  static const int _minReasonLength = 30;

  bool get _isReasonValid =>
      _reasonController.text.trim().length >= _minReasonLength;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final photo = await _imagePicker.pickImage(
      source: cameraSource(),
      imageQuality: 85,
    );
    if (photo != null) {
      setState(() => _selectedPhoto = photo);
    }
  }

  Future<void> _pickFromGallery() async {
    final photo = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (photo != null) {
      setState(() => _selectedPhoto = photo);
    }
  }

  Future<void> _submit() async {
    if (!_isReasonValid) {
      setState(() {
        _errorMessage = AppLocalizations.of(
          context,
        )!.alasanMinimalKarakter(_minReasonLength);
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final client = ref.read(apiClientProvider);

      // Upload photo if provided
      if (_selectedPhoto != null) {
        final uploadResult = await client.getPhotoUploadUrl(
          widget.reportId,
          'sanggah-upload-token',
        );

        final putUrl = uploadResult.putUrl;
        if (putUrl == null) {
          throw Exception(AppLocalizations.of(context)!.gagalUrlUpload);
        }

        final bytes = await _selectedPhoto!.readAsBytes();

        await client.putPhoto(
          reportId: widget.reportId,
          putUrl: putUrl,
          bytes: bytes,
          contentType: 'image/jpeg',
        );
      }

      // Call reportAction with sanggah action
      await client.reportAction(
        reportId: widget.reportId,
        action: 'sanggah',
        note: _reasonController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.sanggahanBerhasilDiajukan,
          ),
          backgroundColor: SigapColors.primary,
        ),
      );

      widget.onComplete?.call();
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage = AppLocalizations.of(
          context,
        )!.gagalAjukanSanggahan(e.toString());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final reasonLength = _reasonController.text.trim().length;
    final isValid = _isReasonValid;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: SigapColors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(SigapRadius.x16),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: SigapSpacing.x12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: SigapColors.border,
                borderRadius: BorderRadius.circular(SigapRadius.x2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(SigapSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.sanggahan,
                    style: TextStyle(
                      fontSize: SigapTypography.headlineSmall,
                      fontWeight: FontWeight.w700,
                      color: SigapColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: SigapSpacing.xs),
                  Text(
                    l10n.ajukanKeberatan,
                    style: TextStyle(
                      fontSize: SigapTypography.bodyMedium,
                      color: SigapColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(SigapSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Reason textarea with validation
                    Text(
                      l10n.alasanSanggahan,
                      style: TextStyle(
                        fontSize: SigapTypography.bodyMedium,
                        fontWeight: FontWeight.w600,
                        color: SigapColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: SigapSpacing.xs),
                    Text(
                      l10n.minimalKarakter(_minReasonLength),
                      style: const TextStyle(
                        fontSize: SigapTypography.bodySmall,
                        color: SigapColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: SigapSpacing.sm),
                    TextField(
                      controller: _reasonController,
                      maxLines: 6,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: l10n.jelaskanAlasanKeberatan,
                        hintStyle: const TextStyle(
                          color: SigapColors.textMuted,
                          fontSize: SigapTypography.bodyMedium,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(SigapRadius.md),
                          borderSide: const BorderSide(
                            color: SigapColors.borderCard,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(SigapRadius.md),
                          borderSide: const BorderSide(
                            color: SigapColors.borderCard,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(SigapRadius.md),
                          borderSide: const BorderSide(
                            color: SigapColors.primary,
                            width: 2,
                          ),
                        ),
                        errorText: _errorMessage != null && !isValid
                            ? _errorMessage
                            : null,
                        counterText: '$reasonLength/$_minReasonLength',
                      ),
                    ),
                    const SizedBox(height: SigapSpacing.xl),

                    // Photo evidence (optional)
                    Text(
                      l10n.buktiFotoOpsional,
                      style: TextStyle(
                        fontSize: SigapTypography.bodyMedium,
                        fontWeight: FontWeight.w600,
                        color: SigapColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: SigapSpacing.xs),
                    Text(
                      l10n.tambahkanFotoBukti,
                      style: TextStyle(
                        fontSize: SigapTypography.bodySmall,
                        color: SigapColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: SigapSpacing.sm),
                    if (_selectedPhoto != null)
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(SigapRadius.md),
                            child: Image.network(
                              _selectedPhoto!.path,
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                height: 200,
                                color: SigapColors.bgSoft,
                                child: const Center(
                                  child: Icon(Icons.image_not_supported),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: SigapSpacing.sm,
                            right: SigapSpacing.sm,
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedPhoto = null),
                              child: Container(
                                padding: const EdgeInsets.all(SigapSpacing.x4),
                                decoration: const BoxDecoration(
                                  color: SigapColors.danger,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: SigapColors.surface,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: _PhotoOptionButton(
                              icon: Icons.camera_alt,
                              label: l10n.kamera,
                              onTap: _pickPhoto,
                            ),
                          ),
                          const SizedBox(width: SigapSpacing.sm),
                          Expanded(
                            child: _PhotoOptionButton(
                              icon: Icons.photo_library,
                              label: l10n.galeri,
                              onTap: _pickFromGallery,
                            ),
                          ),
                        ],
                      ),
                    if (_errorMessage != null && isValid) ...[
                      const SizedBox(height: SigapSpacing.md),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(
                          fontSize: SigapTypography.bodySmall,
                          color: SigapColors.perluTindakan,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            // Submit button
            Padding(
              padding: EdgeInsets.only(
                left: SigapSpacing.lg,
                right: SigapSpacing.lg,
                bottom:
                    MediaQuery.of(context).viewInsets.bottom + SigapSpacing.lg,
              ),
              child: PrimaryButton(
                label: l10n.ajukanSanggahanLabel,
                isLoading: _isSubmitting,
                onPressed: _isSubmitting || !isValid ? null : _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

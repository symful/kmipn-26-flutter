import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_picker/image_picker.dart';
import '../../api/client.dart' as api_client;
import '../../capabilities/can.dart';
import '../../providers/providers.dart';
import '../../theme/tokens.dart';

import '../../widgets/design_system/buttons.dart';
import '../../widgets/design_system/design_system.dart';
import '../../widgets/design_system/timeline_event.dart';

/// Provider that fetches a single report from the API by ID.
final apiReportProvider = FutureProvider.family<api_client.Report, String>((
  ref,
  id,
) async {
  final apiClient = ref.read(apiClientProvider);
  return apiClient.getReportById(id);
});

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

class ReportDetailScreen extends ConsumerWidget {
  final String id;
  const ReportDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(apiReportProvider(id));

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: SigapSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Detail Laporan',
                style: TextStyle(
                  fontSize: SigapTypography.size19,
                  fontWeight: FontWeight.w700,
                  color: SigapColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              reportAsync.when(
                data: (report) {
                  // Try to find local ID from Drift DB when route ID is an idempotency key
                  final localId = _getLocalId(ref, id, report.id);
                  return Text(
                    'Lokal ${localId ?? '-'} · Server ${report.id ?? '-'}',
                    style: const TextStyle(
                      fontSize: SigapTypography.size12,
                      color: SigapColors.textSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
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
          final createdAtStr = report.createdAt;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(SigapSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status banner
                _buildStatusBanner(context, report),
                const SizedBox(height: SigapSpacing.lg),

                // Parent-case card (when merged_into is present)
                if (report.mergedInto != null && report.mergedInto!.isNotEmpty)
                  _buildParentCaseCard(context, report),

                // Photo gallery
                if (photoUrls.isNotEmpty) ...[
                  _buildPhotoGallery(context, photoUrls),
                  const SizedBox(height: SigapSpacing.lg),
                ],

                // Description
                SectionLabel(
                  label: 'Deskripsi',
                  style: const TextStyle(
                    fontSize: SigapTypography.size12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: SigapSpacing.xs),
                Text(
                  report.description ?? '-',
                  style: const TextStyle(
                    fontSize: SigapTypography.size14,
                    color: SigapColors.textPrimary,
                  ),
                ),
                const SizedBox(height: SigapSpacing.lg),

                // Location
                SectionLabel(
                  label: 'Lokasi',
                  style: const TextStyle(
                    fontSize: SigapTypography.size12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: SigapSpacing.xs),
                Text(
                  report.addressArea ??
                      report.address ??
                      '${report.location?['lat']?.toStringAsFixed(6) ?? '-'}, ${report.location?['lng']?.toStringAsFixed(6) ?? '-'}',
                  style: const TextStyle(
                    fontSize: SigapTypography.size14,
                    fontFamily: SigapTypography.fontFamilyMono,
                    color: SigapColors.textPrimary,
                  ),
                ),
                const SizedBox(height: SigapSpacing.lg),

                // Category
                SectionLabel(
                  label: 'Kategori',
                  style: const TextStyle(
                    fontSize: SigapTypography.size12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: SigapSpacing.xs),
                Text(
                  report.category ?? '-',
                  style: const TextStyle(
                    fontSize: SigapTypography.size14,
                    color: SigapColors.textPrimary,
                  ),
                ),
                const SizedBox(height: SigapSpacing.lg),

                // Severity / Priority
                SectionLabel(
                  label: 'Tingkat Prioritas',
                  style: const TextStyle(
                    fontSize: SigapTypography.size12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: SigapSpacing.xs),
                Text(
                  report.priority?.value ?? '-',
                  style: const TextStyle(
                    fontSize: SigapTypography.size14,
                    color: SigapColors.textPrimary,
                  ),
                ),
                const SizedBox(height: SigapSpacing.lg),

                // Created at
                SectionLabel(
                  label: 'Dibuat',
                  style: const TextStyle(
                    fontSize: SigapTypography.size12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: SigapSpacing.xs),
                Text(
                  createdAtStr != null ? _formatApiDate(createdAtStr) : '-',
                  style: const TextStyle(
                    fontSize: SigapTypography.size14,
                    color: SigapColors.textPrimary,
                  ),
                ),
                const SizedBox(height: SigapSpacing.xl),

                // Timeline section
                _buildTimelineSection(context, ref),
                const SizedBox(height: SigapSpacing.xl),

                // Privacy info
                _buildPrivacyInfo(),
                const SizedBox(height: SigapSpacing.xl),

                // Action buttons
                _buildActionButtons(context, ref, report, id),
                _buildSanggahanButton(context, ref, report, id),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
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
                'Error: $e',
                style: const TextStyle(
                  fontSize: SigapTypography.size14,
                  color: SigapColors.textSecondary,
                ),
              ),
              const SizedBox(height: SigapSpacing.md),
              OutlinedButton(
                onPressed: () => ref.invalidate(apiReportProvider(id)),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
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

  Widget _buildStatusBanner(BuildContext context, api_client.Report report) {
    final status = report.status?.value ?? '';

    // Only show banner if needs_completion
    if (status == 'needs_completion') {
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
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: SigapSpacing.x10,
                vertical: SigapSpacing.x4,
              ),
              decoration: BoxDecoration(
                color: SigapColors.offlineDot,
                borderRadius: BorderRadius.circular(SigapRadius.x7),
              ),
              child: const Text(
                'Perlu tindakan Anda',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: SigapTypography.size12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: SigapSpacing.x9),
            if (deadlineText.isNotEmpty)
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: SigapTypography.size12_5,
                    color: SigapColors.warningTextStrong,
                    height: SigapTypography.lineHeight145,
                  ),
                  children: [
                    const TextSpan(
                      text:
                          'Verifikator meminta 1 foto tambahan dari sisi yang '
                          'berbeda agar lubang terlihat jelas. ',
                    ),
                    TextSpan(
                      text: 'Tenggat $deadlineText.',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              )
            else
              const Text(
                'Verifikator meminta 1 foto tambahan dari sisi yang berbeda '
                'agar lubang terlihat jelas.',
                style: TextStyle(
                  fontSize: SigapTypography.size12_5,
                  color: SigapColors.warningTextStrong,
                  height: SigapTypography.lineHeight145,
                ),
              ),
            const SizedBox(height: SigapSpacing.x11),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
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
                  fontSize: SigapTypography.size13,
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
                  const Text(
                    'Bagian dari kasus',
                    style: TextStyle(
                      fontSize: SigapTypography.size11,
                      color: SigapColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    caseTitle,
                    style: const TextStyle(
                      fontSize: SigapTypography.size14,
                      color: SigapColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Text(
              'Lihat ',
              style: TextStyle(
                fontSize: SigapTypography.size13,
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
            height: 200,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              height: 200,
              color: SigapColors.bgSoft,
              child: const Center(child: Icon(Icons.image_not_supported)),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: photoUrls.length,
        separatorBuilder: (_, __) => const SizedBox(width: SigapSpacing.sm),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _showPhotoFullScreen(context, photoUrls, index),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(SigapRadius.md),
              child: Image.network(
                photoUrls[index],
                width: 120,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 120,
                  height: 120,
                  color: SigapColors.bgSoft,
                  child: const Center(
                    child: Icon(Icons.image_not_supported, size: 32),
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
    final timelineAsync = ref.watch(reportTimelineProvider(id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PERJALANAN LAPORAN',
          style: TextStyle(
            fontSize: SigapTypography.size11,
            fontWeight: FontWeight.w600,
            color: SigapColors.textMuted,
            letterSpacing: SigapTypography.letterSpacingLabel,
          ),
        ),
        const SizedBox(height: SigapSpacing.md),
        timelineAsync.when(
          data: (timelineData) {
            final events = timelineData.events;
            if (events?.isEmpty ?? true) {
              return const EmptyState(
                icon: Icons.timeline,
                title: 'Belum ada riwayat',
                subtitle: 'Perjalanan laporan akan ditampilkan di sini.',
              );
            }
            return _TimelineWidget(events: events ?? []);
          },
          loading: () =>
              const SkeletonBox(height: 100, borderRadius: SigapRadius.md),
          error: (_, __) => ErrorRetryView(
            message: 'Gagal memuat timeline',
            onRetry: () => ref.invalidate(reportTimelineProvider(id)),
          ),
        ),
      ],
    );
  }

  Widget _buildPrivacyInfo() {
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
                fontSize: SigapTypography.size11,
                fontWeight: FontWeight.w700,
                color: SigapColors.textTertiary,
              ),
            ),
          ),
          const SizedBox(width: SigapSpacing.sm),
          const Expanded(
            child: Text(
              'Identitas & lokasi presisi Anda hanya terlihat oleh petugas terkait. '
              'Publik melihat lokasi yang digeneralisasi.',
              style: TextStyle(
                fontSize: SigapTypography.size11_5,
                color: SigapColors.textSecondary,
                height: SigapTypography.lineHeight140,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    WidgetRef ref,
    api_client.Report report,
    String reportId,
  ) {
    final status = report.status?.value ?? '';

    // Only show when report needs completion (status gate — capability is checked by Can widget)
    if (status != 'needs_completion') {
      return const SizedBox.shrink();
    }

    return Can(
      action: 'report.lengkapi',
      resource: Resource(type: 'report', id: reportId),
      child: Padding(
        padding: const EdgeInsets.only(top: SigapSpacing.md),
        child: SecondaryButton(
          label: 'Lengkapi laporan',
          onPressed: () =>
              _showLengkapiBottomSheet(context, ref, report, reportId),
        ),
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
          label: 'Sanggah Keputusan',
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

  String _formatApiDate(String isoString) {
    try {
      final dt = DateTime.parse(isoString);
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return isoString;
    }
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
}

/// Timeline widget showing report history events.
class _TimelineWidget extends StatelessWidget {
  final List<api_client.TimelineEvent> events;
  const _TimelineWidget({required this.events});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < events.length; i++)
          TimelineEvent(
            title: events[i].message ?? events[i].type ?? 'Event',
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
      source: ImageSource.camera,
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
        const SnackBar(
          content: Text('Silakan tambahkan foto terlebih dahulu'),
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
        throw Exception('Gagal mendapatkan URL upload foto');
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
        const SnackBar(
          content: Text('Laporan berhasil dilengkapi'),
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
          content: Text('Gagal melengkapi laporan: $e'),
          backgroundColor: SigapColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(SigapSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Lengkapi Laporan',
                    style: TextStyle(
                      fontSize: SigapTypography.size20,
                      fontWeight: FontWeight.w700,
                      color: SigapColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: SigapSpacing.xs),
                  const Text(
                    'Tambahkan foto dan deskripsi untuk melengkapi laporan Anda.',
                    style: TextStyle(
                      fontSize: SigapTypography.size14,
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
                        fontSize: SigapTypography.size14,
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
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedPhoto = null),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: SigapColors.danger,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
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
                              label: 'Kamera',
                              onTap: _pickPhoto,
                            ),
                          ),
                          const SizedBox(width: SigapSpacing.sm),
                          Expanded(
                            child: _PhotoOptionButton(
                              icon: Icons.photo_library,
                              label: 'Galeri',
                              onTap: _pickFromGallery,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: SigapSpacing.xl),

                    // Description
                    const Text(
                      'Deskripsi (opsional)',
                      style: TextStyle(
                        fontSize: SigapTypography.size14,
                        fontWeight: FontWeight.w600,
                        color: SigapColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: SigapSpacing.sm),
                    TextField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText:
                            'Jelaskan informasi tambahan yang ingin Anda berikan...',
                        hintStyle: const TextStyle(
                          color: SigapColors.textMuted,
                          fontSize: SigapTypography.size14,
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
                label: 'Kirim',
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
                fontSize: SigapTypography.size13,
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
      source: ImageSource.camera,
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
        _errorMessage = 'Alasan harus minimal $_minReasonLength karakter';
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
          throw Exception('Gagal mendapatkan URL upload foto');
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
        const SnackBar(
          content: Text('Sanggahan berhasil diajukan'),
          backgroundColor: SigapColors.primary,
        ),
      );

      widget.onComplete?.call();
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage = 'Gagal mengajukan sanggahan: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final reasonLength = _reasonController.text.trim().length;
    final isValid = _isReasonValid;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(SigapSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sanggahan',
                    style: TextStyle(
                      fontSize: SigapTypography.size20,
                      fontWeight: FontWeight.w700,
                      color: SigapColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: SigapSpacing.xs),
                  const Text(
                    'Ajukan keberatan atas keputusan penolakan laporan Anda.',
                    style: TextStyle(
                      fontSize: SigapTypography.size14,
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
                    const Text(
                      'Alasan Sanggahan',
                      style: TextStyle(
                        fontSize: SigapTypography.size14,
                        fontWeight: FontWeight.w600,
                        color: SigapColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: SigapSpacing.xs),
                    Text(
                      'Minimal $_minReasonLength karakter',
                      style: const TextStyle(
                        fontSize: SigapTypography.size12,
                        color: SigapColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: SigapSpacing.sm),
                    TextField(
                      controller: _reasonController,
                      maxLines: 6,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText:
                            'Jelaskan alasan keberatan Anda secara detail...',
                        hintStyle: const TextStyle(
                          color: SigapColors.textMuted,
                          fontSize: SigapTypography.size14,
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
                    const Text(
                      'Bukti Foto (opsional)',
                      style: TextStyle(
                        fontSize: SigapTypography.size14,
                        fontWeight: FontWeight.w600,
                        color: SigapColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: SigapSpacing.xs),
                    const Text(
                      'Tambahkan foto sebagai bukti pendukung sanggahan Anda',
                      style: TextStyle(
                        fontSize: SigapTypography.size12,
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
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedPhoto = null),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: SigapColors.danger,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
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
                              label: 'Kamera',
                              onTap: _pickPhoto,
                            ),
                          ),
                          const SizedBox(width: SigapSpacing.sm),
                          Expanded(
                            child: _PhotoOptionButton(
                              icon: Icons.photo_library,
                              label: 'Galeri',
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
                          fontSize: SigapTypography.size12,
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
                label: 'Ajukan Sanggahan',
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

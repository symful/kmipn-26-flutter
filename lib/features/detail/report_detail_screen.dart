import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/tokens.dart';
import '../../providers/providers.dart';
import '../../widgets/skeleton_loaders.dart';

/// Provider that fetches a single report from the API by ID.
final apiReportProvider = FutureProvider.family<Map<String, dynamic>, String>((
  ref,
  id,
) async {
  final apiClient = ref.read(apiClientProvider);
  return apiClient.getReportById(id);
});

/// Provider that fetches the timeline for a report.
final reportTimelineProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, id) async {
      final apiClient = ref.read(apiClientProvider);
      return apiClient.getReportTimeline(id);
    });

/// Provider that fetches supporting reports for a report.
final supportingReportsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((ref, id) async {
      final apiClient = ref.read(apiClientProvider);
      return apiClient.getSupportingReports(id);
    });

class ReportDetailScreen extends ConsumerWidget {
  final String id;
  const ReportDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(apiReportProvider(id));

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Laporan')),
      body: reportAsync.when(
        data: (report) {
          final photoUrls = (report['photo_urls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList();
          final createdAtStr = report['created_at'] as String?;
          final parentCase = report['parent_case'] as Map<String, dynamic>?;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(SigapSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status banner
                _buildStatusBanner(report),
                const SizedBox(height: SigapSpacing.lg),

                // Parent case banner
                if (parentCase != null) ...[
                  _buildParentCaseBanner(context, parentCase),
                  const SizedBox(height: SigapSpacing.lg),
                ],

                // Photo gallery
                if (photoUrls != null && photoUrls.isNotEmpty) ...[
                  _buildPhotoGallery(context, photoUrls),
                  const SizedBox(height: SigapSpacing.lg),
                ],

                // Description
                _SectionLabel(label: 'Deskripsi'),
                const SizedBox(height: SigapSpacing.xs),
                Text(
                  report['description'] as String? ?? '-',
                  style: const TextStyle(fontSize: 15),
                ),
                const SizedBox(height: SigapSpacing.lg),

                // Location
                _SectionLabel(label: 'Lokasi'),
                const SizedBox(height: SigapSpacing.xs),
                Text(
                  '${(report['lat'] as num?)?.toStringAsFixed(6) ?? '-'}, ${(report['lng'] as num?)?.toStringAsFixed(6) ?? '-'}',
                  style: const TextStyle(fontSize: 14, fontFamily: 'monospace'),
                ),
                const SizedBox(height: SigapSpacing.lg),

                // Category
                _SectionLabel(label: 'Kategori'),
                const SizedBox(height: SigapSpacing.xs),
                Text(
                  report['category_id'] as String? ?? '-',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: SigapSpacing.lg),

                // Assigned to
                if (report['assigned_to'] != null) ...[
                  _SectionLabel(label: 'Ditugaskan'),
                  const SizedBox(height: SigapSpacing.xs),
                  Text(
                    report['assigned_to'] as String,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: SigapSpacing.lg),
                ],

                // Severity
                _SectionLabel(label: 'Tingkat Prioritas'),
                const SizedBox(height: SigapSpacing.xs),
                Text(
                  report['severity'] as String? ?? '-',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: SigapSpacing.lg),

                // Created at
                _SectionLabel(label: 'Dibuat'),
                const SizedBox(height: SigapSpacing.xs),
                Text(
                  createdAtStr != null ? _formatApiDate(createdAtStr) : '-',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: SigapSpacing.xl),

                // Timeline section
                _buildTimelineSection(context, ref),
                const SizedBox(height: SigapSpacing.xl),

                // Supporting reports section
                _buildSupportingReportsSection(context, ref),
                const SizedBox(height: SigapSpacing.xl),

                // Privacy info
                _buildPrivacyInfo(),
                const SizedBox(height: SigapSpacing.xl),

                // Action buttons
                _buildActionButtons(
                  context,
                  report['status'] as String? ?? '',
                  report['id'] as String? ?? id,
                ),
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
              Text('Error: $e'),
              const SizedBox(height: SigapSpacing.md),
              ElevatedButton(
                onPressed: () => ref.invalidate(apiReportProvider(id)),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBanner(Map<String, dynamic> report) {
    final status = report['status'] as String? ?? '';
    final statusMessage = report['status_message'] as String?;
    final deadline = report['deadline'] as String?;

    // Only show banner if there's an action required or message
    if (status == 'needs_completion' && statusMessage != null) {
      return Container(
        padding: const EdgeInsets.all(SigapSpacing.md),
        decoration: BoxDecoration(
          color: SigapColors.warningBg,
          border: Border.all(color: SigapColors.warningBorder),
          borderRadius: BorderRadius.circular(SigapRadius.md),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: SigapSpacing.sm,
                vertical: SigapSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: SigapColors.offlineDot,
                borderRadius: BorderRadius.circular(SigapRadius.sm),
              ),
              child: const Text(
                'Perlu tindakan Anda',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: SigapSpacing.sm),
            Text(
              statusMessage,
              style: const TextStyle(
                fontSize: 12.5,
                color: SigapColors.warningTextStrong,
              ),
            ),
            if (deadline != null) ...[
              const SizedBox(height: SigapSpacing.xs),
              Text(
                'Tenggat: ${_formatApiDate(deadline)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: SigapColors.warningText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildParentCaseBanner(
    BuildContext context,
    Map<String, dynamic> parentCase,
  ) {
    final parentId = parentCase['id'] as String?;
    final parentTitle = parentCase['title'] as String? ?? 'Kasus terkait';
    final categoryInitials =
        (parentCase['short_code'] as String?)?.substring(0, 2) ?? 'KC';

    return Container(
      padding: const EdgeInsets.all(SigapSpacing.md),
      decoration: BoxDecoration(
        color: SigapColors.surface,
        border: Border.all(color: SigapColors.border),
        borderRadius: BorderRadius.circular(SigapRadius.md),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: SigapColors.primaryLight,
              borderRadius: BorderRadius.circular(SigapRadius.sm),
            ),
            alignment: Alignment.center,
            child: Text(
              categoryInitials,
              style: const TextStyle(
                color: SigapColors.primaryDark,
                fontWeight: FontWeight.w600,
                fontSize: 12,
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
                    fontSize: 11,
                    color: SigapColors.textSecondary,
                  ),
                ),
                Text(
                  parentTitle,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: parentId != null
                ? () => context.push('/detail/$parentId')
                : null,
            child: const Text(
              'Lihat →',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: SigapColors.primary,
              ),
            ),
          ),
        ],
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
    Navigator.of(ctx).push(
      MaterialPageRoute(
        builder: (_) => _PhotoFullScreen(photos: photos, initialIndex: index),
      ),
    );
  }

  Widget _buildTimelineSection(BuildContext context, WidgetRef ref) {
    final timelineAsync = ref.watch(reportTimelineProvider(id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(label: 'Perjalanan laporan'),
        const SizedBox(height: SigapSpacing.md),
        timelineAsync.when(
          data: (timelineData) {
            final events =
                (timelineData['events'] as List<dynamic>?)
                    ?.cast<Map<String, dynamic>>() ??
                [];
            if (events.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(SigapSpacing.md),
                decoration: BoxDecoration(
                  color: SigapColors.surface,
                  borderRadius: BorderRadius.circular(SigapRadius.md),
                  border: Border.all(color: SigapColors.border),
                ),
                child: const Text(
                  'Belum ada riwayat',
                  style: TextStyle(color: SigapColors.textMuted, fontSize: 13),
                ),
              );
            }
            return _TimelineWidget(events: events);
          },
          loading: () =>
              const SkeletonBox(height: 100, borderRadius: SigapRadius.md),
          error: (_, __) => Container(
            padding: const EdgeInsets.all(SigapSpacing.md),
            decoration: BoxDecoration(
              color: SigapColors.surface,
              borderRadius: BorderRadius.circular(SigapRadius.md),
              border: Border.all(color: SigapColors.border),
            ),
            child: const Text(
              'Gagal memuat timeline',
              style: TextStyle(color: SigapColors.textMuted, fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSupportingReportsSection(BuildContext context, WidgetRef ref) {
    final supportingAsync = ref.watch(supportingReportsProvider(id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(label: 'Laporan pendukung'),
        const SizedBox(height: SigapSpacing.md),
        supportingAsync.when(
          data: (supportingReports) {
            if (supportingReports.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(SigapSpacing.md),
                decoration: BoxDecoration(
                  color: SigapColors.surface,
                  borderRadius: BorderRadius.circular(SigapRadius.md),
                  border: Border.all(color: SigapColors.border),
                ),
                child: const Text(
                  'Belum ada laporan pendukung',
                  style: TextStyle(color: SigapColors.textMuted, fontSize: 13),
                ),
              );
            }
            return Column(
              children: supportingReports
                  .take(5)
                  .map(
                    (sr) => _SupportingReportItem(
                      report: sr,
                      onTap: () {
                        final srId = sr['id']?.toString();
                        if (srId != null) {
                          context.push('/detail/$srId');
                        }
                      },
                    ),
                  )
                  .toList(),
            );
          },
          loading: () =>
              const SkeletonBox(height: 80, borderRadius: SigapRadius.md),
          error: (_, __) => Container(
            padding: const EdgeInsets.all(SigapSpacing.md),
            decoration: BoxDecoration(
              color: SigapColors.surface,
              borderRadius: BorderRadius.circular(SigapRadius.md),
              border: Border.all(color: SigapColors.border),
            ),
            child: const Text(
              'Gagal memuat laporan pendukung',
              style: TextStyle(color: SigapColors.textMuted, fontSize: 13),
            ),
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
                fontSize: 11,
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
                fontSize: 11.5,
                color: SigapColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    String status,
    String reportId,
  ) {
    final bool canFileSanggahan =
        status == 'rejected' ||
        status == 'out_of_scope' ||
        status == 'needs_completion';
    final bool canRequestReopen = status == 'resolved';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (canFileSanggahan) ...[
          OutlinedButton.icon(
            onPressed: () => context.push('/warga/sanggahan/$reportId'),
            icon: const Icon(Icons.thumb_down_outlined, size: 18),
            label: const Text('Ajukan Sanggahan'),
            style: OutlinedButton.styleFrom(
              foregroundColor: SigapColors.perluTindakan,
              side: const BorderSide(color: SigapColors.perluTindakan),
              padding: const EdgeInsets.symmetric(vertical: SigapSpacing.md),
            ),
          ),
          const SizedBox(height: SigapSpacing.sm),
        ],
        if (canRequestReopen) ...[
          OutlinedButton.icon(
            onPressed: () => context.push('/warga/reopen/$reportId'),
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Minta Buka Kembali'),
            style: OutlinedButton.styleFrom(
              foregroundColor: SigapColors.diproses,
              side: const BorderSide(color: SigapColors.diproses),
              padding: const EdgeInsets.symmetric(vertical: SigapSpacing.md),
            ),
          ),
          const SizedBox(height: SigapSpacing.sm),
        ],
        OutlinedButton.icon(
          onPressed: () => context.push('/warga/evidence/$reportId'),
          icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
          label: const Text('Kirim Bukti Tambahan'),
          style: OutlinedButton.styleFrom(
            foregroundColor: SigapColors.primary,
            side: const BorderSide(color: SigapColors.primary),
            padding: const EdgeInsets.symmetric(vertical: SigapSpacing.md),
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
}

/// Section label widget with consistent styling.
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: SigapColors.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

/// Timeline widget showing report history events.
class _TimelineWidget extends StatelessWidget {
  final List<Map<String, dynamic>> events;
  const _TimelineWidget({required this.events});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < events.length; i++) ...[
          _TimelineEventItem(
            event: events[i],
            isFirst: i == 0,
            isLast: i == events.length - 1,
          ),
        ],
      ],
    );
  }
}

/// Individual timeline event item.
class _TimelineEventItem extends StatelessWidget {
  final Map<String, dynamic> event;
  final bool isFirst;
  final bool isLast;

  const _TimelineEventItem({
    required this.event,
    required this.isFirst,
    required this.isLast,
  });

  Color _getEventColor(String? eventType) {
    switch (eventType) {
      case 'submitted':
      case 'created':
        return SigapColors.primary;
      case 'needs_completion':
      case 'rejected':
        return SigapColors.offlineDot;
      case 'verified':
      case 'accepted':
        return SigapColors.diproses;
      case 'resolved':
      case 'completed':
        return SigapColors.selesai;
      default:
        return SigapColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventType =
        event['event_type'] as String? ?? event['type'] as String?;
    final title = event['title'] as String? ?? eventType ?? 'Event';
    final timestamp =
        event['timestamp'] as String? ?? event['created_at'] as String?;
    final actor = event['actor'] as String?;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 13,
                height: 13,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getEventColor(eventType),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: _getEventColor(eventType).withValues(alpha: 0.4),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Expanded(child: Container(width: 2, color: SigapColors.border)),
            ],
          ),
          const SizedBox(width: SigapSpacing.md),
          // Event content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: SigapSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (actor != null || timestamp != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      '${timestamp != null ? _formatDate(timestamp) : ''}${actor != null ? ' · $actor' : ''}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: SigapColors.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return '${dt.day} Jul, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }
}

/// Supporting report item widget.
class _SupportingReportItem extends StatelessWidget {
  final Map<String, dynamic> report;
  final VoidCallback onTap;

  const _SupportingReportItem({required this.report, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final title =
        report['title'] as String? ??
        report['description'] as String? ??
        'Laporan pendukung';
    final status = report['status'] as String?;
    final shortCode = report['short_code'] as String? ?? 'LP';

    return Card(
      margin: const EdgeInsets.only(bottom: SigapSpacing.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SigapRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(SigapSpacing.md),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: SigapColors.primaryLight,
                  borderRadius: BorderRadius.circular(SigapRadius.sm),
                ),
                alignment: Alignment.center,
                child: Text(
                  shortCode.substring(0, 2),
                  style: const TextStyle(
                    color: SigapColors.primaryDark,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: SigapSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (status != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        status,
                        style: const TextStyle(
                          fontSize: 11,
                          color: SigapColors.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: SigapColors.textMuted,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Full screen photo viewer with page navigation.
class _PhotoFullScreen extends StatefulWidget {
  final List<String> photos;
  final int initialIndex;

  const _PhotoFullScreen({required this.photos, required this.initialIndex});

  @override
  State<_PhotoFullScreen> createState() => _PhotoFullScreenState();
}

class _PhotoFullScreenState extends State<_PhotoFullScreen> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SigapColors.textPrimary,
      appBar: AppBar(
        backgroundColor: SigapColors.textPrimary,
        foregroundColor: SigapColors.surface,
        title: Text('${_currentIndex + 1} / ${widget.photos.length}'),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.photos.length,
        onPageChanged: (i) => setState(() => _currentIndex = i),
        itemBuilder: (context, index) {
          return InteractiveViewer(
            child: Center(
              child: Image.network(
                widget.photos[index],
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.broken_image,
                  color: SigapColors.surface,
                  size: 64,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

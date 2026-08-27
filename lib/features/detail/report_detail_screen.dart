import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../api/api_client.dart' show TimelineEnvelope;
import '../../api/types.g.dart';
import '../../theme/tokens.dart';
import '../../providers/providers.dart';
import '../../widgets/skeleton_loaders.dart';

/// Provider that fetches a single report from the API by ID.
final apiReportProvider = FutureProvider.family<Report, String>((
  ref,
  id,
) async {
  final apiClient = ref.read(apiClientProvider);
  return apiClient.getReportById(id);
});

/// Provider that fetches the timeline for a report.
final reportTimelineProvider = FutureProvider.family<TimelineEnvelope, String>((
  ref,
  id,
) async {
  final apiClient = ref.read(apiClientProvider);
  return apiClient.getReportTimeline(id);
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
                data: (report) => Text(
                  'Lokal ${report.id ?? '-'} · Server ${report.id ?? '-'}',
                  style: const TextStyle(
                    fontSize: SigapTypography.size12,
                    color: SigapColors.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: SigapColors.textSecondary),
            onPressed: () {},
          ),
        ],
      ),
      body: reportAsync.when(
        data: (report) {
          final photoUrls =
              report.photos?.map((p) => p.url ?? '').toList() ?? [];
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
                _SectionLabel(label: 'Deskripsi'),
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
                _SectionLabel(label: 'Lokasi'),
                const SizedBox(height: SigapSpacing.xs),
                Text(
                  '${report.location?['lat']?.toStringAsFixed(6) ?? '-'}, ${report.location?['lng']?.toStringAsFixed(6) ?? '-'}',
                  style: const TextStyle(
                    fontSize: SigapTypography.size14,
                    fontFamily: SigapTypography.fontFamilyMono,
                    color: SigapColors.textPrimary,
                  ),
                ),
                const SizedBox(height: SigapSpacing.lg),

                // Category
                _SectionLabel(label: 'Kategori'),
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
                _SectionLabel(label: 'Tingkat Prioritas'),
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
                _SectionLabel(label: 'Dibuat'),
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
                _buildActionButtons(
                  context,
                  report.status?.value ?? '',
                  report.id ?? id,
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

  Widget _buildStatusBanner(BuildContext context, Report report) {
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

      return Container(
        decoration: BoxDecoration(
          color: SigapColors.offlineBg,
          borderRadius: BorderRadius.circular(SigapRadius.md),
          border: Border(
            left: BorderSide(color: SigapColors.offlineDot, width: 4),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(SigapSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(SigapRadius.md),
              bottomRight: Radius.circular(SigapRadius.md),
            ),
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
                    fontSize: SigapTypography.size12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: SigapSpacing.sm),
              if (deadlineText.isNotEmpty)
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: SigapTypography.size14,
                      color: SigapColors.warningTextStrong,
                      height: SigapTypography.lineHeight140,
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
                    fontSize: SigapTypography.size14,
                    color: SigapColors.warningTextStrong,
                    height: SigapTypography.lineHeight140,
                  ),
                ),
              const SizedBox(height: SigapSpacing.md),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.push('/warga/evidence/${report.id}'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SigapColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: SigapSpacing.md,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Lengkapi laporan',
                    style: TextStyle(
                      fontSize: SigapTypography.size15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
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

  Widget _buildParentCaseCard(BuildContext context, Report report) {
    final categoryTag = report.category != null && report.category!.length >= 2
        ? report.category!.substring(0, 2).toUpperCase()
        : 'CS';
    final caseTitle = report.title ?? report.mergedInto ?? 'Kasus';

    return GestureDetector(
      onTap: () => context.push('/warga/report-detail/${report.mergedInto}'),
      child: Container(
        padding: const EdgeInsets.all(SigapSpacing.md),
        decoration: BoxDecoration(
          color: SigapColors.surface,
          borderRadius: BorderRadius.circular(SigapRadius.md),
          border: Border.all(color: SigapColors.border),
        ),
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
              return Container(
                padding: const EdgeInsets.all(SigapSpacing.md),
                decoration: BoxDecoration(
                  color: SigapColors.surface,
                  borderRadius: BorderRadius.circular(SigapRadius.md),
                  border: Border.all(color: SigapColors.border),
                ),
                child: const Text(
                  'Belum ada riwayat',
                  style: TextStyle(
                    color: SigapColors.textMuted,
                    fontSize: SigapTypography.size13,
                  ),
                ),
              );
            }
            return _TimelineWidget(events: events ?? []);
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
              style: TextStyle(
                color: SigapColors.textMuted,
                fontSize: SigapTypography.size13,
              ),
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
        fontSize: SigapTypography.size12,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

/// Timeline widget showing report history events.
class _TimelineWidget extends StatelessWidget {
  final List<TimelineEvent> events;
  const _TimelineWidget({required this.events});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < events.length; i++)
          _TimelineEventItem(
            event: events[i],
            isFirst: i == 0,
            isLast: i == events.length - 1,
          ),
      ],
    );
  }
}

/// Individual timeline event item.
class _TimelineEventItem extends StatelessWidget {
  final TimelineEvent event;
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
      case 'offline':
        return SigapColors.primary;
      case 'needs_completion':
        return SigapColors.offlineDot;
      case 'verified':
      case 'accepted':
      case 'in_review':
        return SigapColors.diproses;
      case 'resolved':
      case 'completed':
        return SigapColors.selesai;
      default:
        return SigapColors.primary;
    }
  }

  bool _isActiveEvent(String? eventType) {
    return eventType == 'needs_completion' ||
        eventType == 'rejected' ||
        eventType == 'offline';
  }

  @override
  Widget build(BuildContext context) {
    final eventType = event.type;
    final title = event.message ?? eventType ?? 'Event';
    final timestamp = event.timestamp;
    final actor = event.userId;
    final eventColor = _getEventColor(eventType);
    final isActive = _isActiveEvent(eventType);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator column with vertical connecting line
          SizedBox(
            width: 16,
            child: Column(
              children: [
                Container(
                  width: isActive ? 13 : 11,
                  height: isActive ? 13 : 11,
                  margin: EdgeInsets.only(top: isActive ? 0 : 2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive ? SigapColors.offlineDot : eventColor,
                    border: isActive
                        ? Border.all(color: Colors.white, width: 2)
                        : null,
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: SigapColors.offlineDot.withValues(
                                alpha: 0.8,
                              ),
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: SigapColors.borderCard,
                      constraints: const BoxConstraints(minHeight: 22),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: SigapSpacing.x11),
          // Event content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: SigapTypography.size13,
                      fontWeight: FontWeight.w600,
                      color: SigapColors.textPrimary,
                    ),
                  ),
                  if (actor != null || timestamp != null) ...[
                    const SizedBox(height: 1),
                    Text(
                      '${timestamp != null ? _formatDate(timestamp) : ''}${actor != null ? ' · $actor' : ''}',
                      style: const TextStyle(
                        fontFamily: SigapTypography.fontFamilyMono,
                        fontSize: SigapTypography.size11,
                        color: SigapColors.textTertiary,
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

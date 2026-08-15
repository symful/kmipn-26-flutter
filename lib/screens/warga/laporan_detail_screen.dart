import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../db/database.dart';
import '../../providers/providers.dart';
import '../../theme/tokens.dart';

/// Status type for laporan progression.
enum LaporanStatus { pending, reviewing, resolved }

extension LaporanStatusExt on LaporanStatus {
  String get label {
    switch (this) {
      case LaporanStatus.pending:
        return 'Menunggu';
      case LaporanStatus.reviewing:
        return 'Diverifikasi';
      case LaporanStatus.resolved:
        return 'Selesai';
    }
  }

  Color get color {
    switch (this) {
      case LaporanStatus.pending:
        return AppColors.warning;
      case LaporanStatus.reviewing:
        return AppColors.info;
      case LaporanStatus.resolved:
        return AppColors.primary;
    }
  }

  Color get backgroundColor {
    switch (this) {
      case LaporanStatus.pending:
        return AppColors.warningBg;
      case LaporanStatus.reviewing:
        return AppColors.infoBg;
      case LaporanStatus.resolved:
        return AppColors.primaryLight;
    }
  }

  IconData get icon {
    switch (this) {
      case LaporanStatus.pending:
        return Icons.schedule;
      case LaporanStatus.reviewing:
        return Icons.visibility;
      case LaporanStatus.resolved:
        return Icons.check_circle;
    }
  }
}

/// Converts API/server status string to LaporanStatus.
LaporanStatus _parseStatus(String? status) {
  switch (status?.toLowerCase()) {
    case 'submitted':
    case 'under_review':
    case 'needs_survey':
    case 'needs_completion':
      return LaporanStatus.pending;
    case 'verified':
    case 'in_progress':
      return LaporanStatus.reviewing;
    case 'resolved':
    case 'rejected':
    case 'duplicate_merged':
    case 'out_of_scope':
      return LaporanStatus.resolved;
    default:
      return LaporanStatus.pending;
  }
}

/// Timeline stage model.
class TimelineStage {
  final String label;
  final String? timestamp;
  final bool isCompleted;
  final bool isCurrent;
  final LaporanStatus status;

  const TimelineStage({
    required this.label,
    this.timestamp,
    required this.isCompleted,
    required this.isCurrent,
    required this.status,
  });
}

/// Builds timeline stages from report data.
List<TimelineStage> _buildTimeline(String? status, DateTime? createdAt) {
  final currentStatus = _parseStatus(status);

  return [
    TimelineStage(
      label: 'Pengajuan',
      timestamp: createdAt != null ? _formatDate(createdAt) : null,
      isCompleted: true,
      isCurrent: currentStatus == LaporanStatus.pending,
      status: LaporanStatus.pending,
    ),
    TimelineStage(
      label: 'Peninjauan',
      timestamp: null,
      isCompleted: currentStatus != LaporanStatus.pending,
      isCurrent: currentStatus == LaporanStatus.reviewing,
      status: LaporanStatus.reviewing,
    ),
    TimelineStage(
      label: 'Verifikasi',
      timestamp: null,
      isCompleted: currentStatus == LaporanStatus.resolved,
      isCurrent: false,
      status: LaporanStatus.reviewing,
    ),
    TimelineStage(
      label: 'Selesai',
      timestamp: null,
      isCompleted: currentStatus == LaporanStatus.resolved,
      isCurrent: currentStatus == LaporanStatus.resolved,
      status: LaporanStatus.resolved,
    ),
  ];
}

String _formatDate(DateTime dt) {
  return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

/// Horizontal timeline widget showing report progression.
class LaporanTimeline extends StatelessWidget {
  final List<TimelineStage> stages;

  const LaporanTimeline({super.key, required this.stages});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(stages.length * 2 - 1, (index) {
        if (index.isOdd) {
          // Connector line between stages
          final stageIndex = index ~/ 2;
          final isCompleted = stages[stageIndex].isCompleted;
          return Expanded(
            child: Container(
              height: 2,
              color: isCompleted ? AppColors.primary : AppColors.borderCard,
            ),
          );
        }

        // Stage node
        final stage = stages[index ~/ 2];
        return _TimelineNode(stage: stage);
      }),
    );
  }
}

class _TimelineNode extends StatelessWidget {
  final TimelineStage stage;

  const _TimelineNode({required this.stage});

  @override
  Widget build(BuildContext context) {
    final color = stage.isCompleted ? stage.status.color : AppColors.borderCard;
    final bgColor = stage.isCurrent
        ? stage.status.backgroundColor
        : Colors.transparent;

    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Icon(
            stage.isCompleted ? Icons.check : Icons.circle,
            size: 16,
            color: stage.isCompleted ? color : AppColors.textTertiary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          stage.label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: stage.isCurrent ? FontWeight.bold : FontWeight.normal,
            color: stage.isCompleted
                ? AppColors.textPrimary
                : AppColors.textTertiary,
          ),
          textAlign: TextAlign.center,
        ),
        if (stage.timestamp != null) ...[
          const SizedBox(height: 2),
          Text(
            stage.timestamp!,
            style: const TextStyle(fontSize: 9, color: AppColors.textTertiary),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

/// Status banner widget at the top of the detail screen.
class StatusBanner extends StatelessWidget {
  final LaporanStatus status;

  const StatusBanner({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: status.backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: status.color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(status.icon, color: status.color, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status: ${status.label}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: status.color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _statusDescription(status),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _statusDescription(LaporanStatus status) {
    switch (status) {
      case LaporanStatus.pending:
        return 'Laporan Anda sedang menunggu untuk ditinjau';
      case LaporanStatus.reviewing:
        return 'Laporan Anda sedang dalam proses peninjauan';
      case LaporanStatus.resolved:
        return 'Laporan telah resolved dan closed';
    }
  }
}

/// Detail item row widget.
class DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const DetailRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: valueColor ?? AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Laporan Detail Screen for warga to view their report status and timeline.
class LaporanDetailScreen extends ConsumerWidget {
  final String? reportId;

  const LaporanDetailScreen({super.key, this.reportId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // If reportId is not provided, show placeholder for testing
    if (reportId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Laporan')),
        body: const Center(child: Text('Report ID is required')),
      );
    }

    // Try to find the report - first check local, then server
    final localReportsAsync = ref.watch(localReportsProvider);
    final serverReportsAsync = ref.watch(wargaReportsProvider);

    return localReportsAsync.when(
      data: (localReports) {
        // Check local reports first
        final localReport = localReports
            .where(
              (r) => r.idempotencyKey == reportId || r.serverId == reportId,
            )
            .firstOrNull;

        if (localReport != null) {
          return _buildDetailScreen(context, ref, _localToMap(localReport));
        }

        // Check server reports
        return serverReportsAsync.when(
          data: (serverReports) {
            final serverReport = serverReports
                .where(
                  (r) =>
                      r['id']?.toString() == reportId ||
                      r['idempotency_key']?.toString() == reportId,
                )
                .firstOrNull;

            if (serverReport != null) {
              return _buildDetailScreen(context, ref, serverReport);
            }

            return _buildNotFoundScreen(context);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => _buildNotFoundScreen(context),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Detail Laporan')),
        body: Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildNotFoundScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Laporan')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search_off,
              size: 64,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Laporan tidak ditemukan',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextButton(
              onPressed: () => context.go('/warga'),
              child: const Text('Kembali ke Beranda'),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _localToMap(LocalReport r) {
    return {
      'id': r.serverId ?? r.idempotencyKey,
      'idempotency_key': r.idempotencyKey,
      'description': r.description,
      'status': r.status,
      'category_id': r.categoryId,
      'lat': r.lat,
      'lng': r.lng,
      'photo_path': r.photoPath,
      'created_at': r.createdAt.toIso8601String(),
      'is_local': true,
    };
  }

  Widget _buildDetailScreen(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> report,
  ) {
    final status = _parseStatus(report['status'] as String?);
    final createdAt = report['created_at'] != null
        ? DateTime.tryParse(report['created_at'].toString())
        : null;
    final timelineStages = _buildTimeline(
      report['status'] as String?,
      createdAt,
    );

    // Get photo URL or path
    final photoPath = report['photo_path'] as String?;
    final photoUrls = (report['photo_urls'] as List?)?.cast<String>() ?? [];
    final hasPhoto = photoPath != null || photoUrls.isNotEmpty;

    // Get location string
    final lat = (report['lat'] as num?)?.toDouble();
    final lng = (report['lng'] as num?)?.toDouble();
    final locationStr = lat != null && lng != null
        ? '${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}'
        : 'Lokasi tidak tersedia';

    // Get category
    final categoryId = report['category_id'] as String?;
    final categoryName =
        report['category_name'] as String? ?? categoryId ?? '-';

    // Get description
    final description = report['description'] as String? ?? '-';

    // Get server-assigned ID for display
    final displayId =
        report['id']?.toString() ??
        report['idempotency_key']?.toString() ??
        reportId ??
        '-';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Laporan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/warga'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Banner
            StatusBanner(status: status),

            const SizedBox(height: AppSpacing.xl),

            // Timeline
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.borderCard),
              ),
              child: Column(
                children: [
                  const Text(
                    'Progres Laporan',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  LaporanTimeline(stages: timelineStages),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Report ID
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.borderCard),
              ),
              child: DetailRow(
                icon: Icons.tag,
                label: 'ID Laporan',
                value: displayId.length > 20
                    ? '${displayId.substring(0, 20)}...'
                    : displayId,
                valueColor: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Photo
            if (hasPhoto)
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: AppColors.borderCard),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const DetailRow(
                      icon: Icons.photo,
                      label: 'Foto',
                      value: '',
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (photoUrls.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        child: Image.network(
                          photoUrls.first,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _buildPhotoPlaceholder(),
                        ),
                      )
                    else if (photoPath != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        child: Image.asset(
                          photoPath,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _buildPhotoPlaceholder(),
                        ),
                      ),
                  ],
                ),
              ),

            if (hasPhoto) const SizedBox(height: AppSpacing.md),

            // Location
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.borderCard),
              ),
              child: Column(
                children: [
                  DetailRow(
                    icon: Icons.location_on,
                    label: 'Lokasi',
                    value: locationStr,
                  ),
                  if (lat != null && lng != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    OutlinedButton.icon(
                      onPressed: () => context.push('/map'),
                      icon: const Icon(Icons.map, size: 16),
                      label: const Text('Lihat di Peta'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Category
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.borderCard),
              ),
              child: DetailRow(
                icon: Icons.category,
                label: 'Kategori',
                value: categoryName,
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Description
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.borderCard),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const DetailRow(
                    icon: Icons.description,
                    label: 'Deskripsi',
                    value: '',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Timestamp
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.borderCard),
              ),
              child: DetailRow(
                icon: Icons.access_time,
                label: 'Diajukan Pada',
                value: createdAt != null ? _formatDate(createdAt) : '-',
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoPlaceholder() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image, size: 48, color: AppColors.textTertiary),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Foto tidak tersedia',
            style: TextStyle(color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }
}

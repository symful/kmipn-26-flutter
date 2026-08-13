import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/tokens.dart';
import '../../providers/providers.dart';

class ReportDetailScreen extends ConsumerWidget {
  final String id;
  const ReportDetailScreen({super.key, required this.id});

  Color _statusColor(String status) {
    switch (status) {
      case 'submitted':
      case 'under_review':
        return SigapColors.perluTindakan;
      case 'verified':
      case 'in_progress':
        return SigapColors.diproses;
      case 'resolved':
        return SigapColors.selesai;
      default:
        return SigapColors.textMuted;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'submitted':
        return 'Perlu Tindakan';
      case 'under_review':
        return 'Perlu Tindakan';
      case 'verified':
        return 'Diproses';
      case 'in_progress':
        return 'Diproses';
      case 'resolved':
        return 'Selesai';
      case 'rejected':
        return 'Ditolak';
      case 'duplicate_merged':
        return 'Duplikat';
      case 'needs_survey':
        return 'Perlu Survei';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(localReportsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Laporan')),
      body: reportsAsync.when(
        data: (reports) {
          final report = reports
              .where((r) => r.idempotencyKey == id)
              .firstOrNull;
          if (report == null) {
            return const Center(child: Text('Laporan tidak ditemukan'));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(SigapSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SigapSpacing.sm,
                    vertical: SigapSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor(report.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(SigapRadius.sm),
                  ),
                  child: Text(
                    _statusLabel(report.status),
                    style: TextStyle(
                      color: _statusColor(report.status),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: SigapSpacing.lg),
                if (report.photoPath != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(SigapRadius.md),
                    child: Image.file(
                      File(report.photoPath!),
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: SigapSpacing.lg),
                ],
                Text(
                  'Deskripsi',
                  style: TextStyle(
                    color: SigapColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: SigapSpacing.xs),
                Text(report.description, style: const TextStyle(fontSize: 15)),
                const SizedBox(height: SigapSpacing.lg),
                Text(
                  'Lokasi',
                  style: TextStyle(
                    color: SigapColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: SigapSpacing.xs),
                Text(
                  '${report.lat.toStringAsFixed(6)}, ${report.lng.toStringAsFixed(6)}',
                  style: const TextStyle(fontSize: 14, fontFamily: 'monospace'),
                ),
                const SizedBox(height: SigapSpacing.lg),
                Text(
                  'Kategori',
                  style: TextStyle(
                    color: SigapColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: SigapSpacing.xs),
                Text(report.categoryId, style: const TextStyle(fontSize: 14)),
                const SizedBox(height: SigapSpacing.lg),
                Text(
                  'Status Sinkron',
                  style: TextStyle(
                    color: SigapColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: SigapSpacing.xs),
                if (report.syncStatus == 2)
                  _SyncFailureBanner(idempotencyKey: report.idempotencyKey)
                else
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: report.syncStatus == 0
                              ? SigapColors.offlineDot
                              : report.syncStatus == 1
                              ? SigapColors.selesai
                              : SigapColors.perluTindakan,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: SigapSpacing.sm),
                      Text(
                        report.syncStatus == 0
                            ? 'Tersimpan lokal (belum sync)'
                            : report.syncStatus == 1
                            ? 'Tersinkron'
                            : 'Gagal sinkron',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                const SizedBox(height: SigapSpacing.lg),
                Text(
                  'Dibuat',
                  style: TextStyle(
                    color: SigapColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: SigapSpacing.xs),
                Text(
                  _formatDate(report.createdAt),
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: SigapSpacing.xl),
                _buildActionButtons(
                  context,
                  report.status,
                  report.idempotencyKey,
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
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
              side: BorderSide(color: SigapColors.perluTindakan),
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
              side: BorderSide(color: SigapColors.diproses),
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
            side: BorderSide(color: SigapColors.primary),
            padding: const EdgeInsets.symmetric(vertical: SigapSpacing.md),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _SyncFailureBanner extends ConsumerWidget {
  final String idempotencyKey;

  const _SyncFailureBanner({required this.idempotencyKey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queueRepo = ref.read(syncQueueRepositoryProvider);

    return FutureBuilder<String?>(
      future: queueRepo
          .getByIdempotencyKey(idempotencyKey)
          .then((item) => item?.lastError),
      builder: (context, snapshot) {
        final error = snapshot.data;
        return Container(
          padding: const EdgeInsets.all(SigapSpacing.md),
          decoration: BoxDecoration(
            color: SigapColors.perluTindakan.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(SigapRadius.sm),
            border: Border.all(
              color: SigapColors.perluTindakan.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: SigapColors.perluTindakan,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: SigapSpacing.sm),
                  Expanded(
                    child: Text(
                      error != null ? 'Gagal sinkron: $error' : 'Gagal sinkron',
                      style: TextStyle(
                        color: SigapColors.perluTindakan,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SigapSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _retryReport(context, ref),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: SigapColors.perluTindakan,
                        side: BorderSide(color: SigapColors.perluTindakan),
                      ),
                      child: const Text('Coba lagi'),
                    ),
                  ),
                  const SizedBox(width: SigapSpacing.sm),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _deleteReport(context, ref),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: SigapColors.textSecondary,
                        side: BorderSide(color: SigapColors.border),
                      ),
                      child: const Text('Hapus'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _retryReport(BuildContext context, WidgetRef ref) async {
    final reportRepo = ref.read(reportRepositoryProvider);
    await reportRepo.retry(idempotencyKey);
    ref.invalidate(localReportsProvider);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sinkronisasi dijadwalkan ulang')),
      );
    }
  }

  Future<void> _deleteReport(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Laporan?'),
        content: const Text(
          'Laporan ini akan dihapus永久. Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: SigapColors.perluTindakan,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final reportRepo = ref.read(reportRepositoryProvider);
      await reportRepo.delete(idempotencyKey);
      ref.invalidate(localReportsProvider);
      if (context.mounted) {
        context.pop();
      }
    }
  }
}

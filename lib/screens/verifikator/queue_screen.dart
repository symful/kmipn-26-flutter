import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/providers.dart';
import '../../theme/tokens.dart';

class QueueItem {
  final String id;
  final String description;
  final String status;
  final int? severity;
  final double? lat;
  final double? lng;
  final String createdAt;

  QueueItem({
    required this.id,
    required this.description,
    required this.status,
    this.severity,
    required this.lat,
    required this.lng,
    required this.createdAt,
  });

  factory QueueItem.fromJson(Map<String, dynamic> json) {
    return QueueItem(
      id: json['id'] as String? ?? '',
      description: json['description'] as String? ?? '',
      status: json['status'] as String? ?? 'unknown',
      severity: (json['severity'] as num?)?.toInt(),
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      createdAt: json['created_at'] as String? ?? '',
    );
  }
}

final verifikatorQueueProvider = FutureProvider<List<QueueItem>>((ref) async {
  final api = ref.watch(apiClientProvider);
  final res = await api.get('/api/verifikator/queue');
  final items = res['items'] as List? ?? [];
  return items
      .map((e) => QueueItem.fromJson(e as Map<String, dynamic>))
      .toList();
});

class VerifikatorQueueScreen extends ConsumerWidget {
  const VerifikatorQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queueAsync = ref.watch(verifikatorQueueProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Antrean Verifikasi'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: queueAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 64, color: SigapColors.textMuted),
                  SizedBox(height: SigapSpacing.lg),
                  Text(
                    'Tidak ada antrean',
                    style: TextStyle(
                      fontSize: 16,
                      color: SigapColors.textMuted,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(SigapSpacing.lg),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return _QueueItemCard(item: item);
            },
          );
        },
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: SigapColors.primary),
              SizedBox(height: SigapSpacing.lg),
              Text('Memuat...', style: TextStyle(color: SigapColors.textMuted)),
            ],
          ),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: SigapColors.perluTindakan,
              ),
              const SizedBox(height: SigapSpacing.lg),
              Text(
                'Gagal memuat data',
                style: TextStyle(
                  fontSize: 16,
                  color: SigapColors.textSecondary,
                ),
              ),
              const SizedBox(height: SigapSpacing.sm),
              Text(
                '$e',
                style: const TextStyle(
                  color: SigapColors.textMuted,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QueueItemCard extends StatelessWidget {
  final QueueItem item;

  const _QueueItemCard({required this.item});

  Color _statusColor() {
    switch (item.status.toLowerCase()) {
      case 'pending':
        return SigapColors.perluTindakan;
      case 'in_progress':
        return SigapColors.diproses;
      case 'completed':
        return SigapColors.selesai;
      default:
        return SigapColors.textMuted;
    }
  }

  String _statusLabel() {
    switch (item.status.toLowerCase()) {
      case 'pending':
        return 'Menunggu';
      case 'in_progress':
        return 'Diproses';
      case 'completed':
        return 'Selesai';
      default:
        return item.status;
    }
  }

  String _truncateDescription(String desc) {
    if (desc.length <= 80) return desc;
    return '${desc.substring(0, 80)}...';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: SigapSpacing.md),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SigapRadius.md),
        side: const BorderSide(color: SigapColors.border),
      ),
      child: InkWell(
        onTap: () => context.push('/verifikator/cases/${item.id}'),
        borderRadius: BorderRadius.circular(SigapRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(SigapSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ID: ${item.id.length > 8 ? item.id.substring(0, 8) : item.id}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(height: SigapSpacing.sm),
                        Text(
                          _truncateDescription(item.description),
                          style: TextStyle(
                            color: SigapColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: SigapSpacing.md),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SigapSpacing.sm,
                      vertical: SigapSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: _statusColor().withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(SigapRadius.sm),
                    ),
                    child: Text(
                      _statusLabel(),
                      style: TextStyle(
                        color: _statusColor(),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SigapSpacing.md),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SigapSpacing.sm,
                      vertical: SigapSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: SigapColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(SigapRadius.sm),
                    ),
                    child: Text(
                      'Prioritas: ${item.severity ?? "-"}',
                      style: const TextStyle(
                        color: SigapColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () =>
                        context.push('/verifikator/cases/${item.id}'),
                    style: TextButton.styleFrom(
                      foregroundColor: SigapColors.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: SigapSpacing.md,
                        vertical: SigapSpacing.xs,
                      ),
                    ),
                    child: const Text('Tinjau'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

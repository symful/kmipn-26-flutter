import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/providers.dart';
import '../../theme/tokens.dart';
import '../../widgets/design_system/phone_frame.dart';
import '../../widgets/design_system/status_bar.dart';

/// S-01 Sinkron Screen
///
/// Displays pending sync count and list of items waiting to be synced.
/// Uses pendingCountProvider for real-time sync count updates.
class SyncCenterScreen extends ConsumerStatefulWidget {
  const SyncCenterScreen({super.key});

  @override
  ConsumerState<SyncCenterScreen> createState() => _SyncCenterScreenState();
}

class _SyncCenterScreenState extends ConsumerState<SyncCenterScreen> {
  List<_PendingItem> _pendingItems = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPendingItems();
  }

  Future<void> _loadPendingItems() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final taskRepo = ref.read(surveyorTaskRepositoryProvider);
      final pendingVisits = await taskRepo.getPendingVisits();

      final items = <_PendingItem>[];
      for (final visit in pendingVisits) {
        final decoded = jsonDecode(visit.visitDataJson);
        final visitData = decoded is Map<String, dynamic>
            ? decoded
            : <String, dynamic>{};
        items.add(
          _PendingItem(
            idempotencyKey: visit.idempotencyKey,
            taskId: visit.taskId,
            visitData: visitData,
            createdAt: visit.createdAt,
          ),
        );
      }

      setState(() {
        _pendingItems = items;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _syncAll() async {
    final worker = ref.read(syncWorkerProvider);
    await worker.syncNow();
    await _loadPendingItems();
  }

  @override
  Widget build(BuildContext context) {
    final pendingCountAsync = ref.watch(pendingCountProvider);

    return PhoneFrame(
      child: Column(
        children: [
          StatusBar(),
          Expanded(
            child: Scaffold(
              backgroundColor: SigapColors.bgSurface,
              appBar: AppBar(
                backgroundColor: SigapColors.bgCard,
                elevation: 0,
                automaticallyImplyLeading: false,
                titleSpacing: 0,
                title: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SigapSpacing.lg,
                  ),
                  child: Row(
                    children: [
                      const Text(
                        'Sinkron',
                        style: TextStyle(
                          fontSize: SigapTypography.size19,
                          fontWeight: FontWeight.w700,
                          color: SigapColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      pendingCountAsync.when(
                        data: (count) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: count > 0
                                ? SigapColors.warning.withValues(alpha: 0.1)
                                : SigapColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '$count menunggu',
                            style: TextStyle(
                              fontFamily: 'IBM Plex Mono',
                              fontSize: SigapTypography.size11,
                              fontWeight: FontWeight.w600,
                              color: count > 0
                                  ? SigapColors.warning
                                  : SigapColors.primary,
                            ),
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
                    icon: const Icon(Icons.sync),
                    onPressed: _syncAll,
                    tooltip: 'Sync all',
                  ),
                ],
              ),
              body: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null && _pendingItems.isEmpty
                  ? _ErrorRetry(error: _error!, onRetry: _loadPendingItems)
                  : _pendingItems.isEmpty
                  ? _buildEmpty()
                  : _buildPendingList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: SigapColors.bgSurface,
              shape: BoxShape.circle,
              border: Border.all(color: SigapColors.borderCard, width: 2),
            ),
            child: const Icon(
              Icons.cloud_done,
              size: 40,
              color: SigapColors.primary,
            ),
          ),
          const SizedBox(height: SigapSpacing.lg),
          const Text(
            'Semua tersinkron',
            style: TextStyle(
              fontSize: SigapTypography.size16,
              fontWeight: FontWeight.w600,
              color: SigapColors.textPrimary,
            ),
          ),
          const SizedBox(height: SigapSpacing.xs),
          const Text(
            'Tidak ada data yang menunggu sinkron',
            style: TextStyle(
              fontSize: SigapTypography.size13,
              color: SigapColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingList() {
    return RefreshIndicator(
      onRefresh: _loadPendingItems,
      color: SigapColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(SigapSpacing.lg),
        itemCount: _pendingItems.length,
        itemBuilder: (context, index) {
          final item = _pendingItems[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: SigapSpacing.md),
            child: _PendingCard(
              item: item,
              onTap: () {
                context.push('/surveyor/tasks/${item.taskId}');
              },
            ),
          );
        },
      ),
    );
  }
}

class _PendingItem {
  final String idempotencyKey;
  final String taskId;
  final Map<String, dynamic> visitData;
  final DateTime createdAt;

  _PendingItem({
    required this.idempotencyKey,
    required this.taskId,
    required this.visitData,
    required this.createdAt,
  });
}

class _PendingCard extends StatelessWidget {
  final _PendingItem item;
  final VoidCallback onTap;

  const _PendingCard({required this.item, required this.onTap});

  String get _taskIdDisplay {
    if (item.taskId.startsWith('TGS-')) {
      return item.taskId;
    }
    return 'TGS-${item.taskId}';
  }

  String get _title {
    final title = item.visitData['title'] as String?;
    if (title != null && title.isNotEmpty) return title;
    return 'Visit #${item.taskId}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: SigapColors.bgCard,
          borderRadius: BorderRadius.circular(SigapRadius.x12),
          border: Border.all(color: SigapColors.borderCard),
        ),
        child: Padding(
          padding: const EdgeInsets.all(SigapSpacing.md),
          child: Row(
            children: [
              // Sync status icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: SigapColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.schedule,
                  color: SigapColors.warning,
                  size: 20,
                ),
              ),
              const SizedBox(width: SigapSpacing.md),
              // Title and task ID
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _title,
                      style: const TextStyle(
                        fontSize: SigapTypography.size13_5,
                        fontWeight: FontWeight.w600,
                        color: SigapColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _taskIdDisplay,
                      style: const TextStyle(
                        fontFamily: 'IBM Plex Mono',
                        fontSize: SigapTypography.size11,
                        color: SigapColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: SigapColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Menunggu',
                  style: TextStyle(
                    fontSize: SigapTypography.size10,
                    fontWeight: FontWeight.w600,
                    color: SigapColors.warning,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorRetry({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SigapSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: SigapColors.perluTindakan,
            ),
            const SizedBox(height: SigapSpacing.lg),
            const Text(
              'Gagal memuat data',
              style: TextStyle(
                fontSize: SigapTypography.size16,
                fontWeight: FontWeight.w600,
                color: SigapColors.textPrimary,
              ),
            ),
            const SizedBox(height: SigapSpacing.sm),
            Text(
              error,
              style: const TextStyle(
                fontSize: SigapTypography.size12,
                color: SigapColors.textTertiary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: SigapSpacing.lg),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: SigapColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

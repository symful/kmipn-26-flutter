import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/providers.dart';
import '../../theme/tokens.dart';
import '../../widgets/design_system/phone_frame.dart';
import '../../widgets/design_system/status_bar.dart';

/// S-01 Sinkron Screen — role-aware unified sync center.
///
/// Serves BOTH warga and surveyor roles:
/// - Warga section (isWargaSection=true): unsent LocalReports + dead-letter queue with Retry
/// - Field section (isWargaSection=false): pending surveyor visits + downloaded tasks summary
///
/// Route /sync-center → warga section (from warga_home banner)
/// Route /surveyor/sinkron → field section (existing surveyor navigation)
class SyncCenterScreen extends ConsumerStatefulWidget {
  /// When true, renders warga report queue (from /sync-center route).
  /// When false, renders surveyor visit queue (from /surveyor/sinkron route).
  final bool isWargaSection;

  const SyncCenterScreen({super.key, this.isWargaSection = false});

  @override
  ConsumerState<SyncCenterScreen> createState() => _SyncCenterScreenState();
}

class _SyncCenterScreenState extends ConsumerState<SyncCenterScreen> {
  // ─── Warga state ────────────────────────────────────────────────────────────
  List<_WargaReportItem> _wargaPending = [];
  List<_WargaReportItem> _wargaDeadLetter = [];
  bool _wargaLoading = true;
  String? _wargaError;

  // ─── Surveyor state ─────────────────────────────────────────────────────────
  List<_PendingItem> _pendingVisits = [];
  bool _surveyorLoading = true;
  String? _surveyorError;
  int _downloadedTaskCount = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (widget.isWargaSection) {
      await _loadWargaSection();
    } else {
      await _loadSurveyorSection();
    }
  }

  // ─── Warga section ──────────────────────────────────────────────────────────

  Future<void> _loadWargaSection() async {
    setState(() {
      _wargaLoading = true;
      _wargaError = null;
    });

    try {
      final reportRepo = ref.read(reportRepositoryProvider);
      final queueRepo = ref.read(syncQueueRepositoryProvider);

      // Get unsent reports (syncStatus == 0)
      final unsentReports = await reportRepo.getPendingReports();
      final pending = unsentReports
          .map(
            (r) => _WargaReportItem(
              idempotencyKey: r.idempotencyKey,
              description: r.description,
              syncStatus: r.syncStatus,
              createdAt: r.createdAt,
              serverId: r.serverId,
            ),
          )
          .toList();

      // Get dead-letter items from sync queue (status == 3)
      final dlqItems = await queueRepo.getDeadLetterItems();
      final deadLetter = <_WargaReportItem>[];

      for (final item in dlqItems) {
        // Find the corresponding report by idempotency key
        final report = await reportRepo.getByIdempotencyKey(
          item.idempotencyKey,
        );
        if (report != null) {
          deadLetter.add(
            _WargaReportItem(
              idempotencyKey: item.idempotencyKey,
              description: report.description,
              syncStatus: item.syncStatus,
              createdAt: report.createdAt,
              serverId: report.serverId,
              lastError: item.lastError,
            ),
          );
        }
      }

      setState(() {
        _wargaPending = pending;
        _wargaDeadLetter = deadLetter;
        _wargaLoading = false;
      });
    } catch (e) {
      setState(() {
        _wargaError = e.toString();
        _wargaLoading = false;
      });
    }
  }

  Future<void> _retryDeadLetter(String idempotencyKey) async {
    final queueRepo = ref.read(syncQueueRepositoryProvider);
    await queueRepo.retryDeadLetter(idempotencyKey);

    // Also reset the report's syncStatus to 0
    final reportRepo = ref.read(reportRepositoryProvider);
    await reportRepo.retry(idempotencyKey);

    // Also reset the SyncQueue entry for this report
    await queueRepo.retryDeadLetter(idempotencyKey);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item dikembalikan ke antrian'),
          backgroundColor: SigapColors.primary,
        ),
      );
      await _loadWargaSection();
    }
  }

  // ─── Surveyor section ───────────────────────────────────────────────────────

  Future<void> _loadSurveyorSection() async {
    setState(() {
      _surveyorLoading = true;
      _surveyorError = null;
    });

    try {
      final taskRepo = ref.read(surveyorTaskRepositoryProvider);
      final pendingVisits = await taskRepo.getPendingVisits();
      final downloadedTasks = await taskRepo.getDownloadedTasks();

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
        _pendingVisits = items;
        _downloadedTaskCount = downloadedTasks.length;
        _surveyorLoading = false;
      });
    } catch (e) {
      setState(() {
        _surveyorError = e.toString();
        _surveyorLoading = false;
      });
    }
  }

  Future<void> _syncAll() async {
    final worker = ref.read(syncWorkerProvider);
    await worker.syncNow();
    await _load();
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
                      Text(
                        widget.isWargaSection ? 'Sinkronisasi' : 'Sinkron',
                        style: const TextStyle(
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
              body: widget.isWargaSection
                  ? _buildWargaBody()
                  : _buildSurveyorBody(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWargaBody() {
    if (_wargaLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_wargaError != null &&
        _wargaPending.isEmpty &&
        _wargaDeadLetter.isEmpty) {
      return _ErrorRetry(error: _wargaError!, onRetry: _loadWargaSection);
    }
    if (_wargaPending.isEmpty && _wargaDeadLetter.isEmpty) {
      return _buildWargaEmpty();
    }
    return _buildWargaList();
  }

  Widget _buildWargaEmpty() {
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

  Widget _buildWargaList() {
    return RefreshIndicator(
      onRefresh: _loadWargaSection,
      color: SigapColors.primary,
      child: ListView(
        padding: const EdgeInsets.all(SigapSpacing.lg),
        children: [
          // Dead-letter section
          if (_wargaDeadLetter.isNotEmpty) ...[
            const _SectionHeader(
              title: 'Gagal dikirim',
              color: SigapColors.perluTindakan,
            ),
            ..._wargaDeadLetter.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: SigapSpacing.md),
                child: _WargaDeadLetterCard(
                  item: item,
                  onRetry: () => _retryDeadLetter(item.idempotencyKey),
                ),
              ),
            ),
            const SizedBox(height: SigapSpacing.md),
          ],

          // Pending section
          if (_wargaPending.isNotEmpty) ...[
            const _SectionHeader(title: 'Menunggu', color: SigapColors.warning),
            ..._wargaPending.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: SigapSpacing.md),
                child: _WargaPendingCard(item: item),
              ),
            ),
          ],

          if (_wargaPending.isEmpty && _wargaDeadLetter.isEmpty)
            _buildWargaEmpty(),
        ],
      ),
    );
  }

  Widget _buildSurveyorBody() {
    if (_surveyorLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_surveyorError != null && _pendingVisits.isEmpty) {
      return _ErrorRetry(error: _surveyorError!, onRetry: _loadSurveyorSection);
    }
    if (_pendingVisits.isEmpty) {
      return _buildSurveyorEmpty();
    }
    return _buildSurveyorList();
  }

  Widget _buildSurveyorEmpty() {
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
          Text(
            '$_downloadedTaskCount tugas tersimpan offline',
            style: const TextStyle(
              fontSize: SigapTypography.size13,
              color: SigapColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSurveyorList() {
    return RefreshIndicator(
      onRefresh: _loadSurveyorSection,
      color: SigapColors.primary,
      child: ListView(
        padding: const EdgeInsets.all(SigapSpacing.lg),
        children: [
          // Downloaded tasks summary
          if (_downloadedTaskCount > 0)
            Container(
              margin: const EdgeInsets.only(bottom: SigapSpacing.md),
              padding: const EdgeInsets.all(SigapSpacing.md),
              decoration: BoxDecoration(
                color: SigapColors.primaryLight,
                borderRadius: BorderRadius.circular(SigapRadius.x12),
                border: Border.all(color: SigapColors.borderCard),
              ),
              child: Row(
                children: [
                  const Icon(Icons.download_done, color: SigapColors.primary),
                  const SizedBox(width: SigapSpacing.sm),
                  Text(
                    '$_downloadedTaskCount tugas tersimpan offline',
                    style: const TextStyle(
                      fontSize: SigapTypography.size13,
                      fontWeight: FontWeight.w600,
                      color: SigapColors.primaryDark,
                    ),
                  ),
                ],
              ),
            ),

          // Pending visits
          ..._pendingVisits.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: SigapSpacing.md),
              child: _PendingCard(
                item: item,
                onTap: () {
                  context.push('/surveyor/tasks/${item.taskId}');
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section header ─────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color color;

  const _SectionHeader({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: SigapSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: SigapSpacing.sm),
          Text(
            title,
            style: TextStyle(
              fontSize: SigapTypography.size13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Warga types ─────────────────────────────────────────────────────────────

class _WargaReportItem {
  final String idempotencyKey;
  final String description;
  final int syncStatus;
  final DateTime createdAt;
  final String? serverId;
  final String? lastError;

  _WargaReportItem({
    required this.idempotencyKey,
    required this.description,
    required this.syncStatus,
    required this.createdAt,
    this.serverId,
    this.lastError,
  });
}

// ─── Surveyor types ──────────────────────────────────────────────────────────

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

  String get _taskIdDisplay {
    if (taskId.startsWith('TGS-')) return taskId;
    return 'TGS-$taskId';
  }

  String get _title {
    final title = visitData['title'] as String?;
    if (title != null && title.isNotEmpty) return title;
    return 'Visit #${visitData['taskId'] ?? taskId}';
  }
}

// ─── Cards ───────────────────────────────────────────────────────────────────

class _WargaPendingCard extends StatelessWidget {
  final _WargaReportItem item;

  const _WargaPendingCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SigapColors.bgCard,
        borderRadius: BorderRadius.circular(SigapRadius.x12),
        border: Border.all(color: SigapColors.borderCard),
      ),
      padding: const EdgeInsets.all(SigapSpacing.md),
      child: Row(
        children: [
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.description,
                  style: const TextStyle(
                    fontSize: SigapTypography.size13_5,
                    fontWeight: FontWeight.w600,
                    color: SigapColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.createdAt.day}/${item.createdAt.month}/${item.createdAt.year}',
                  style: const TextStyle(
                    fontFamily: 'IBM Plex Mono',
                    fontSize: SigapTypography.size11,
                    color: SigapColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
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
    );
  }
}

class _WargaDeadLetterCard extends StatelessWidget {
  final _WargaReportItem item;
  final VoidCallback onRetry;

  const _WargaDeadLetterCard({required this.item, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SigapColors.dangerBg,
        borderRadius: BorderRadius.circular(SigapRadius.x12),
        border: Border.all(color: SigapColors.dangerBorder),
      ),
      padding: const EdgeInsets.all(SigapSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: SigapColors.dangerBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.error_outline,
                  color: SigapColors.perluTindakan,
                  size: 20,
                ),
              ),
              const SizedBox(width: SigapSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.description,
                      style: const TextStyle(
                        fontSize: SigapTypography.size13_5,
                        fontWeight: FontWeight.w600,
                        color: SigapColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (item.lastError != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        item.lastError!,
                        style: const TextStyle(
                          fontSize: SigapTypography.size11,
                          color: SigapColors.dangerTextStrong,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.refresh,
                  color: SigapColors.perluTindakan,
                ),
                tooltip: 'Coba lagi',
                onPressed: onRetry,
              ),
            ],
          ),
          const SizedBox(height: SigapSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: SigapColors.dangerBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Gagal',
                  style: TextStyle(
                    fontSize: SigapTypography.size10,
                    fontWeight: FontWeight.w600,
                    color: SigapColors.dangerTextStrong,
                  ),
                ),
              ),
              Text(
                '${item.createdAt.day}/${item.createdAt.month}/${item.createdAt.year}',
                style: const TextStyle(
                  fontFamily: 'IBM Plex Mono',
                  fontSize: SigapTypography.size10,
                  color: SigapColors.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PendingCard extends StatelessWidget {
  final _PendingItem item;
  final VoidCallback onTap;

  const _PendingCard({required this.item, required this.onTap});

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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item._title,
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
                      item._taskIdDisplay,
                      style: const TextStyle(
                        fontFamily: 'IBM Plex Mono',
                        fontSize: SigapTypography.size11,
                        color: SigapColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
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

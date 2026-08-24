import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../api/api_client.dart';
import '../db/database.dart';
import '../db/repositories/report_repository.dart';
import '../db/repositories/surveyor_task_repository.dart';
import '../db/repositories/sync_queue_repository.dart';
import '../services/notification_service.dart';
import '../utils/logger.dart';

/// Stream-based pending count notifier for real-time UI updates.
/// Uses broadcast StreamController to emit count changes after each sync.
class PendingCountNotifier {
  final StreamController<int> _controller = StreamController<int>.broadcast();

  /// Current pending count - set this to notify listeners.
  int _pendingCount = 0;
  int get pendingCount => _pendingCount;

  /// Broadcast stream of pending counts. Emits after each sync.
  Stream<int> get stream => _controller.stream;

  /// Call after sync to emit updated count.
  void emit(int count) {
    _pendingCount = count;
    _controller.add(count);
  }

  void dispose() {
    _controller.close();
  }
}

class SyncWorker {
  static const int maxRetry = 5;
  static const int batchSize = 50;
  static final _logger = Logger('SyncWorker');

  final ApiClient _api;
  final ReportRepository _reportRepo;
  final SurveyorTaskRepository _surveyorTaskRepo;
  final SyncQueueRepository _queueRepo;
  final Stream<List<ConnectivityResult>> _connectivityStream;
  final String _deviceId;
  final NotificationService _notificationService;
  StreamSubscription<List<ConnectivityResult>>? _sub;
  bool _isSyncing = false;

  /// Broadcasts pending count changes after each sync for StreamProvider.
  final PendingCountNotifier pendingCountNotifier;

  SyncWorker({
    required ApiClient api,
    required ReportRepository reportRepo,
    required SurveyorTaskRepository surveyorTaskRepo,
    required SyncQueueRepository queueRepo,
    Stream<List<ConnectivityResult>>? connectivityStream,
    String? deviceId,
    NotificationService? notificationService,
    PendingCountNotifier? pendingCountNotifier,
  }) : _api = api,
       _reportRepo = reportRepo,
       _surveyorTaskRepo = surveyorTaskRepo,
       _queueRepo = queueRepo,
       _connectivityStream =
           connectivityStream ?? Connectivity().onConnectivityChanged,
       _deviceId = deviceId ?? '',
       _notificationService = notificationService ?? NotificationService(),
       pendingCountNotifier = pendingCountNotifier ?? PendingCountNotifier();

  void start() {
    _sub = _connectivityStream.listen((results) {
      if (results.any((r) => r != ConnectivityResult.none)) {
        unawaited(syncNow());
      }
    });
    // Emit initial pending count for UI before first sync completes.
    unawaited(_emitInitialCount());
  }

  Future<void> _emitInitialCount() async {
    try {
      final count = await _reportRepo.countPending();
      pendingCountNotifier.emit(count);
    } catch (e, st) {
      _logger.error('Failed to emit initial pending count', e, st);
    }
  }

  void stop() {
    _sub?.cancel();
  }

  /// Returns current pending count from repository.
  Future<int> getPendingCount() => _reportRepo.countPending();

  Future<void> syncNow() async {
    if (_isSyncing) return;
    _isSyncing = true;
    bool hasFailure = false;
    String? lastError;
    int itemCount = 0;
    try {
      final dueItems = await _queueRepo.getDueItems();
      itemCount = dueItems.length;

      // Separate items into reports and surveyor visits
      final reportItems = <SyncQueueData>[];
      final surveyorVisitItems = <SyncQueueData>[];
      for (final item in dueItems) {
        if (item.idempotencyKey.startsWith('surveyor_visit_')) {
          surveyorVisitItems.add(item);
        } else {
          reportItems.add(item);
        }
      }

      // Sync surveyor visits individually (different API endpoint)
      for (final item in surveyorVisitItems) {
        try {
          await _syncSurveyorVisit(item.idempotencyKey, item.retryCount);
        } catch (e, st) {
          _logger.error('SyncWorker sync error', e, st);
          hasFailure = true;
          lastError = e.toString();
        }
      }

      // Batch report items - up to batchSize (50) per HTTP call
      for (var i = 0; i < reportItems.length; i += batchSize) {
        final batch = reportItems.sublist(
          i,
          (i + batchSize) < reportItems.length
              ? i + batchSize
              : reportItems.length,
        );
        try {
          await _syncReportBatch(batch);
        } catch (e, st) {
          _logger.error('SyncWorker batch sync error', e, st);
          hasFailure = true;
          lastError = e.toString();
        }
      }
    } finally {
      _isSyncing = false;
      if (itemCount == 1 && hasFailure) {
        await _notificationService.showSyncFailure(error: lastError);
      } else if (itemCount > 0 && !hasFailure) {
        await _notificationService.showSyncSuccess();
        await _reportRepo.clearOfflineQueue();
      }
      // Emit updated pending count for real-time UI updates via StreamProvider.
      final count = await _reportRepo.countPending();
      pendingCountNotifier.emit(count);
    }
  }

  /// Syncs a batch of reports (up to batchSize items) in a single HTTP call.
  /// Handles partial batch failures by retrying individual failed reports.
  Future<void> _syncReportBatch(List<SyncQueueData> batchItems) async {
    // Fetch all reports and their photos for this batch
    final reportsData = <Map<String, dynamic>>[];
    final reportIdempotencyKeys = <String>[];

    for (final item in batchItems) {
      final report = await _reportRepo.getByIdempotencyKey(item.idempotencyKey);
      if (report == null) {
        // Report no longer exists, remove from queue
        await _queueRepo.remove(item.idempotencyKey);
        continue;
      }

      // Get photo URLs for this report - these are R2 URLs (or local paths as fallback)
      final photos = await _reportRepo.getPhotosByReportIdempotencyKey(
        report.idempotencyKey,
      );
      // Filter to only keep URLs (http/https) - exclude local file paths
      final photoUrls = photos
          .map((p) => p.filePath)
          .where((path) => path.startsWith('http'))
          .toList();

      reportsData.add({
        'idempotency_key': report.idempotencyKey,
        'category_id': report.categoryId,
        'description': report.description,
        'lat': report.lat,
        'lng': report.lng,
        if (report.deviceId != null) 'device_id': report.deviceId,
        if (photoUrls.isNotEmpty) 'photo_urls': photoUrls,
      });
      reportIdempotencyKeys.add(report.idempotencyKey);
    }

    if (reportsData.isEmpty) return;

    try {
      final result = await _api.syncBatch(
        reports: reportsData,
        deviceId: _deviceId,
      );

      // Process results - handle partial failures (typed payload from ApiClient DTO)
      final results = result.results ?? [];
      final succeededKeys = <String>{};

      for (final r in results) {
        final map = (r as Map).cast<String, dynamic>();
        final serverId = map['id'] as String?;
        final idempotencyKey = map['idempotency_key'] as String?;
        if (serverId != null && idempotencyKey != null) {
          await _reportRepo.markSynced(idempotencyKey, serverId);
          await _queueRepo.remove(idempotencyKey);
          succeededKeys.add(idempotencyKey);
        }
      }

      // Retry failed items (in batch but not in success response)
      for (final key in reportIdempotencyKeys) {
        if (!succeededKeys.contains(key)) {
          final queueItem = await _queueRepo.getByIdempotencyKey(key);
          if (queueItem != null) {
            await _handleReportSyncFailure(key, queueItem.retryCount);
          }
        }
      }
    } catch (e, st) {
      _logger.error('Batch sync failed, retrying individual items', e, st);
      // Retry all items in batch on total batch failure
      for (final key in reportIdempotencyKeys) {
        final queueItem = await _queueRepo.getByIdempotencyKey(key);
        if (queueItem != null) {
          await _handleReportSyncFailure(key, queueItem.retryCount);
        }
      }
    }
  }

  /// Handles individual report sync failure with retry/backoff logic.
  Future<void> _handleReportSyncFailure(
    String idempotencyKey,
    int retryCount,
  ) async {
    if (retryCount >= maxRetry) {
      await _queueRepo.markAsDeadLetter(idempotencyKey, 'Max retries exceeded');
      await _reportRepo.markFailed(idempotencyKey);
      await _notificationService.showDeadLetter(itemKey: idempotencyKey);
      return;
    }
    final backoff = Duration(seconds: (1 << retryCount).clamp(1, 300));
    await _queueRepo.incrementRetry(
      idempotencyKey,
      'Batch sync failed',
      backoff: backoff,
    );
    await _reportRepo.markFailed(idempotencyKey);
  }

  Future<void> _syncSurveyorVisit(String idempotencyKey, int retryCount) async {
    final visit = await _surveyorTaskRepo.getVisitByIdempotencyKey(
      idempotencyKey,
    );
    if (visit == null) {
      await _queueRepo.remove(idempotencyKey);
      return;
    }

    try {
      final visitData = jsonDecode(visit.visitDataJson) as Map<String, dynamic>;
      // Extract taskId from idempotencyKey (format: surveyor_visit_{taskId}_{timestamp})
      final parts = idempotencyKey.split('_');
      final taskId = parts[2];

      await _api.surveyorSubmitVisit(taskId, visitData);

      await _surveyorTaskRepo.markVisitSynced(idempotencyKey, 'synced');
      await _queueRepo.remove(idempotencyKey);
    } catch (e, st) {
      _logger.error('Failed to sync surveyor visit: $idempotencyKey', e, st);
      if (retryCount >= maxRetry) {
        await _queueRepo.markAsDeadLetter(idempotencyKey, e.toString());
        await _surveyorTaskRepo.markVisitFailed(idempotencyKey);
        await _notificationService.showDeadLetter(itemKey: idempotencyKey);
        return;
      }
      final backoff = Duration(seconds: (1 << retryCount).clamp(1, 300));
      await _queueRepo.incrementRetry(
        idempotencyKey,
        e.toString(),
        backoff: backoff,
      );
      await _surveyorTaskRepo.markVisitFailed(idempotencyKey);
    }
  }
}

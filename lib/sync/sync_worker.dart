import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../api/api_client.dart';
import '../db/repositories/report_repository.dart';
import '../db/repositories/surveyor_task_repository.dart';
import '../db/repositories/sync_queue_repository.dart';
import '../services/notification_service.dart';
import '../utils/logger.dart';

class SyncWorker {
  static const int maxRetry = 5;
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

  SyncWorker({
    required ApiClient api,
    required ReportRepository reportRepo,
    required SurveyorTaskRepository surveyorTaskRepo,
    required SyncQueueRepository queueRepo,
    Stream<List<ConnectivityResult>>? connectivityStream,
    String? deviceId,
    NotificationService? notificationService,
  }) : _api = api,
       _reportRepo = reportRepo,
       _surveyorTaskRepo = surveyorTaskRepo,
       _queueRepo = queueRepo,
       _connectivityStream =
           connectivityStream ?? Connectivity().onConnectivityChanged,
       _deviceId = deviceId ?? '',
       _notificationService = notificationService ?? NotificationService();

  void start() {
    _sub = _connectivityStream.listen((results) {
      if (results.any((r) => r != ConnectivityResult.none)) {
        unawaited(syncNow());
      }
    });
  }

  void stop() {
    _sub?.cancel();
  }

  Future<void> syncNow() async {
    if (_isSyncing) return;
    _isSyncing = true;
    bool hasFailure = false;
    String? lastError;
    int itemCount = 0;
    try {
      final dueItems = await _queueRepo.getDueItems();
      itemCount = dueItems.length;
      for (final item in dueItems) {
        try {
          if (item.idempotencyKey.startsWith('surveyor_visit_')) {
            await _syncSurveyorVisit(item.idempotencyKey, item.retryCount);
          } else {
            await _syncReport(item.idempotencyKey, item.retryCount);
          }
        } catch (e, st) {
          _logger.error('SyncWorker sync error', e, st);
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
      }
      await _reportRepo.clearOfflineQueue();
    }
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
    } catch (e) {
      _logger.error('Failed to sync surveyor visit: $idempotencyKey', e);
      if (retryCount >= maxRetry) {
        await _queueRepo.markAsDeadLetter(idempotencyKey, e.toString());
        await _surveyorTaskRepo.markVisitFailed(idempotencyKey);
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

  Future<void> _syncReport(String idempotencyKey, int retryCount) async {
    final report = await _reportRepo.getByIdempotencyKey(idempotencyKey);
    if (report == null) {
      await _queueRepo.remove(idempotencyKey);
      return;
    }
    try {
      final photos = await _reportRepo.getPhotosByReportIdempotencyKey(
        report.idempotencyKey,
      );
      final result = await _api.syncBatch(
        reports: [
          {
            'idempotency_key': report.idempotencyKey,
            'category_id': report.categoryId,
            'description': report.description,
            'lat': report.lat,
            'lng': report.lng,
            if (report.deviceId != null) 'device_id': report.deviceId,
          },
        ],
        deviceId: _deviceId,
        photos: photos.isEmpty
            ? null
            : photos
                  .map(
                    (p) => {
                      'report_idempotency_key': p.reportIdempotencyKey,
                      'file_path': p.filePath,
                      if (p.exifDataJson != null)
                        'exif_data_json': p.exifDataJson,
                    },
                  )
                  .toList(),
      );
      final results = (result['results'] as List?) ?? [];
      if (results.isNotEmpty) {
        final r = (results.first as Map).cast<String, dynamic>();
        final serverId = r['id'] as String?;
        if (serverId != null) {
          await _reportRepo.markSynced(report.idempotencyKey, serverId);
          await _queueRepo.remove(report.idempotencyKey);
        }
      }
    } catch (e) {
      _logger.error('Failed to sync report: ${report.idempotencyKey}', e);
      if (retryCount >= maxRetry) {
        await _queueRepo.markAsDeadLetter(report.idempotencyKey, e.toString());
        await _reportRepo.markFailed(report.idempotencyKey);
        return;
      }
      final backoff = Duration(seconds: (1 << retryCount).clamp(1, 300));
      await _queueRepo.incrementRetry(
        report.idempotencyKey,
        e.toString(),
        backoff: backoff,
      );
      await _reportRepo.markFailed(report.idempotencyKey);
    }
  }
}

import 'dart:async';
import 'dart:convert';

import '../services/internet_reachability.dart';

import '../api/client.dart';
import '../db/repositories/report_repository.dart';
import '../db/repositories/sync_queue_repository.dart';
import '../services/notification_service.dart';
import '../utils/logger.dart';

final _logger = Logger('SyncEngine');

/// Result of a single sync operation.
class SyncResult {
  final int syncedCount;
  final int failedCount;
  final int deadLetteredCount;
  final List<String> errors;

  const SyncResult({
    required this.syncedCount,
    required this.failedCount,
    required this.deadLetteredCount,
    required this.errors,
  });

  bool get allSynced =>
      errors.isEmpty && failedCount == 0 && deadLetteredCount == 0;
  bool get hasAnyWork => syncedCount + failedCount + deadLetteredCount > 0;
}

/// Shared sync engine used by both the SyncCenterScreen and auto-sync trigger.
/// Handles flushing pending report items via submitReport and visit items via
/// submitVisitReport.
class SyncEngine {
  final Future<void> Function()? onSyncComplete;
  final ApiClient _apiClient;
  final ReportRepository _reportRepo;
  final SyncQueueRepository _queueRepo;
  final Future<void> Function(String itemKey, String reason)?
  _deadLetterNotifier;

  SyncEngine({
    this.onSyncComplete,
    required ApiClient apiClient,
    required ReportRepository reportRepo,
    required SyncQueueRepository queueRepo,
    Future<void> Function(String itemKey, String reason)? deadLetterNotifier,
  }) : _apiClient = apiClient,
       _reportRepo = reportRepo,
       _queueRepo = queueRepo,
       _deadLetterNotifier = deadLetterNotifier;

  /// Whether a sync is currently in progress.
  bool _syncing = false;
  bool get isSyncing => _syncing;

  /// Flush all due report-queue items via individual POST /api/reports calls.
  /// Returns [SyncResult] with real counts.
  Future<SyncResult> flushReports() async {
    final reportItems = await _queueRepo.getDueItemsByKind('report');
    if (reportItems.isEmpty) {
      return const SyncResult(
        syncedCount: 0,
        failedCount: 0,
        deadLetteredCount: 0,
        errors: [],
      );
    }

    int synced = 0;
    int failed = 0;
    int deadLettered = 0;
    final errors = <String>[];

    for (final item in reportItems) {
      final report = await _reportRepo.getByIdempotencyKey(item.idempotencyKey);
      if (report == null) {
        await _queueRepo.markAsDeadLetter(
          item.idempotencyKey,
          'Local report missing; queued payload retained',
        );
        deadLettered++;
        errors.add('Local report missing: ${item.idempotencyKey}');
        await _notifyDeadLetter(
          itemKey: item.idempotencyKey,
          reason: 'Local report missing',
        );
        continue;
      }

      try {
        final payload = item.payloadJson == null
            ? <String, dynamic>{}
            : (jsonDecode(item.payloadJson!) as Map).cast<String, dynamic>();
        final photos = await _reportRepo.getPhotosByReportIdempotencyKey(
          item.idempotencyKey,
        );
        final paths =
            ((payload['photo_paths'] as List?)?.whereType<String>().toList() ??
            photos.map((photo) => photo.filePath).toList());
        if (paths.isEmpty &&
            report.photoPath != null &&
            report.photoPath!.isNotEmpty) {
          paths.add(report.photoPath!);
        }
        final photoUrls = <String>[];
        final originalPaths = payload['original_photo_paths'] as List? ?? [];
        for (var index = 0; index < paths.length; index++) {
          final path = paths[index];
          if (path.startsWith('http://') ||
              path.startsWith('https://') ||
              path.startsWith('/r2/reports/')) {
            photoUrls.add(path);
          } else {
            photoUrls.add(
              await _apiClient.uploadReportPhotoAnon(
                path,
                item.idempotencyKey,
                slot: index,
                originalFilePath: index < originalPaths.length
                    ? originalPaths[index] as String?
                    : null,
              ),
            );
          }
        }
        final result = await _apiClient.submitReport(
          idempotencyKey: report.idempotencyKey,
          categoryId: report.categoryId,
          description: report.description,
          lat: report.lat,
          lng: report.lng,
          photoUrls: photoUrls,
          title:
              payload['title']?.toString() ??
              (report.description.length > 80
                  ? '${report.description.substring(0, 80)}...'
                  : report.description),
          reportedSeverity: payload['reported_severity']?.toString(),
          supportingCaseId: payload['supporting_case_id']?.toString(),
          kelurahan: payload['kelurahan']?.toString(),
          kecamatan: payload['kecamatan']?.toString(),
          kabupaten: payload['kabupaten']?.toString(),
          provinsi: payload['provinsi']?.toString(),
          addressArea: payload['address_area']?.toString(),
          anonymous: payload['anonymous'] == true,
          populationAffected: (payload['population_affected'] as num?)?.toInt(),
          vulnerabilityIndex: (payload['vulnerability_index'] as num?)
              ?.toDouble(),
          deviceId: report.deviceId,
        );

        final serverId = result.id;
        if (serverId == null || serverId.trim().isEmpty) {
          throw StateError('Server did not confirm the report ID');
        }
        await _reportRepo.markSynced(item.idempotencyKey, serverId);
        await _queueRepo.markSynced(item.idempotencyKey);
        synced++;
      } catch (e, st) {
        _logger.error('Report sync failed: ${item.idempotencyKey}', e, st);
        errors.add(e.toString());
        await _queueRepo.incrementRetry(
          item.idempotencyKey,
          e.toString(),
          backoff: const Duration(seconds: 60),
        );

        final queueItem = await _queueRepo.getByIdempotencyKey(
          item.idempotencyKey,
        );
        if (queueItem != null && queueItem.syncStatus == 3) {
          deadLettered++;
          await _notifyDeadLetter(
            itemKey: item.idempotencyKey,
            reason: e.toString(),
          );
        } else {
          failed++;
        }
      }
    }

    return SyncResult(
      syncedCount: synced,
      failedCount: failed,
      deadLetteredCount: deadLettered,
      errors: errors,
    );
  }

  /// Flush all due visit-queue items via submitVisitReport.
  Future<SyncResult> flushVisits() async {
    final visitItems = await _queueRepo.getDueItemsByKind('visit');
    if (visitItems.isEmpty) {
      return const SyncResult(
        syncedCount: 0,
        failedCount: 0,
        deadLetteredCount: 0,
        errors: [],
      );
    }

    int synced = 0;
    int failed = 0;
    int deadLettered = 0;
    final errors = <String>[];

    for (final item in visitItems) {
      if (item.payloadJson == null) {
        // No payload — can't re-submit; move to dead-letter
        await _queueRepo.markAsDeadLetter(
          item.idempotencyKey,
          'Visit payload missing',
        );
        await _notifyDeadLetter(
          itemKey: item.idempotencyKey,
          reason: 'Visit payload missing',
        );
        deadLettered++;
        continue;
      }

      try {
        final payload = jsonDecode(item.payloadJson!) as Map<String, dynamic>;
        final taskId = payload['task_id'] as String?;
        if (taskId == null) {
          await _queueRepo.markAsDeadLetter(
            item.idempotencyKey,
            'Visit payload missing task_id',
          );
          deadLettered++;
          continue;
        }

        final gpsLat = (payload['gps_lat'] as num?)?.toDouble();
        final gpsLng = (payload['gps_lng'] as num?)?.toDouble();
        final accuracy = (payload['accuracy'] as num?)?.toDouble();
        if (gpsLat == null ||
            gpsLng == null ||
            accuracy == null ||
            !gpsLat.isFinite ||
            !gpsLng.isFinite ||
            !accuracy.isFinite ||
            gpsLat.abs() > 90 ||
            gpsLng.abs() > 180 ||
            accuracy < 0) {
          throw StateError(
            'Survey GPS measurement is missing or invalid; capture location again',
          );
        }
        final photoUrls = (payload['photo_urls'] as List? ?? [])
            .map((url) => url.toString())
            .toList();
        final localPaths = (payload['local_photo_paths'] as List? ?? [])
            .map((path) => path.toString())
            .toList();
        if (localPaths.isNotEmpty) {
          final detail = await _apiClient.getTaskDetail(taskId);
          if (detail.reportId == null) {
            throw StateError('ID laporan tugas tidak tersedia');
          }
          for (final path in localPaths) {
            photoUrls.add(
              await _apiClient.uploadTaskPhoto(detail.reportId!, path),
            );
          }
        }
        final visit = await _apiClient.submitVisitReport(
          taskId: taskId,
          idempotencyKey: item.idempotencyKey,
          findings: payload['findings'] as String? ?? '',
          checklist:
              (payload['checklist'] as List?)
                  ?.map(
                    (e) => SurveyChecklistAnswer.fromJson(
                      Map<String, dynamic>.from(e as Map),
                    ),
                  )
                  .toList() ??
              [],
          photoUrls: photoUrls,
          gpsLat: gpsLat,
          gpsLng: gpsLng,
          accuracy: accuracy,
          conditionAssessment: payload['condition_assessment'] as String? ?? '',
          recommendation: payload['recommendation'] as String? ?? '',
          catatan: payload['catatan'] as String?,
          dimensions: payload['dimensions'] as String?,
        );
        if (visit.visitId == null || visit.visitId!.trim().isEmpty) {
          throw StateError('Server did not confirm the survey ID');
        }
        await _apiClient.taskAction(
          taskId,
          action: 'complete',
          note: payload['findings'] as String? ?? 'Survei selesai',
        );

        await _queueRepo.markSynced(item.idempotencyKey);
        synced++;
      } catch (e, st) {
        _logger.error('Visit sync failed: ${item.idempotencyKey}', e, st);
        errors.add(e.toString());
        await _queueRepo.incrementRetry(
          item.idempotencyKey,
          e.toString(),
          backoff: const Duration(seconds: 60),
        );

        final queueItem = await _queueRepo.getByIdempotencyKey(
          item.idempotencyKey,
        );
        if (queueItem != null && queueItem.syncStatus == 3) {
          deadLettered++;
          await _notifyDeadLetter(
            itemKey: item.idempotencyKey,
            reason: e.toString(),
          );
        } else {
          failed++;
        }
      }
    }

    return SyncResult(
      syncedCount: synced,
      failedCount: failed,
      deadLetteredCount: deadLettered,
      errors: errors,
    );
  }

  /// Updates only statuses present in the response; absence is not deletion.
  Future<int> reconcileReportsWithServer() async {
    try {
      final page = await _apiClient.getMyReports();
      return await _reportRepo.updateSyncedStatuses({
        for (final report in page.items)
          if (report.id != null && report.status != null)
            report.id!: report.status!.value,
      });
    } catch (e, st) {
      _logger.warning('Reconciliation with server failed', e, st);
      return 0;
    }
  }

  Future<void> _notifyDeadLetter({
    required String itemKey,
    required String reason,
  }) async {
    try {
      if (_deadLetterNotifier != null) {
        await _deadLetterNotifier(itemKey, reason);
      } else {
        await NotificationService().showDeadLetter(
          itemKey: itemKey,
          reason: reason,
        );
      }
    } catch (e, st) {
      _logger.warning('Unable to display sync notification', e, st);
    }
  }

  /// Full flush: reports + visits + reconciliation with server. Guarded against re-entrancy.
  /// Returns combined [SyncResult].
  Future<SyncResult> flushAll() async {
    if (_syncing) {
      _logger.debug('Sync already in progress, skipping');
      return const SyncResult(
        syncedCount: 0,
        failedCount: 0,
        deadLetteredCount: 0,
        errors: ['Sync already in progress'],
      );
    }
    _syncing = true;
    try {
      final reportResult = await flushReports();
      final visitResult = await flushVisits();
      await reconcileReportsWithServer();
      return SyncResult(
        syncedCount: reportResult.syncedCount + visitResult.syncedCount,
        failedCount: reportResult.failedCount + visitResult.failedCount,
        deadLetteredCount:
            reportResult.deadLetteredCount + visitResult.deadLetteredCount,
        errors: [...reportResult.errors, ...visitResult.errors],
      );
    } finally {
      _syncing = false;
      await onSyncComplete?.call();
    }
  }

  /// Check if device is currently online.
  static Future<bool> isOnline() async {
    return InternetReachability.isOnline();
  }
}

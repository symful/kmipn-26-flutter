import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';

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

  bool get allSynced => failedCount == 0 && deadLetteredCount == 0;
  bool get hasAnyWork => syncedCount + failedCount + deadLetteredCount > 0;
}

/// Shared sync engine used by both the SyncCenterScreen and auto-sync trigger.
/// Handles flushing pending report items via syncBatch and visit items via
/// submitVisitReport.
class SyncEngine {
  final ApiClient _apiClient;
  final ReportRepository _reportRepo;
  final SyncQueueRepository _queueRepo;

  SyncEngine({
    required ApiClient apiClient,
    required ReportRepository reportRepo,
    required SyncQueueRepository queueRepo,
  }) : _apiClient = apiClient,
       _reportRepo = reportRepo,
       _queueRepo = queueRepo;

  /// Whether a sync is currently in progress.
  bool _syncing = false;
  bool get isSyncing => _syncing;

  /// Flush all due report-queue items via POST /api/sync/batch.
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

    final batchPayload = <Map<String, dynamic>>[];
    final keysInBatch = <String>[];

    for (final item in reportItems) {
      final report = await _reportRepo.getByIdempotencyKey(item.idempotencyKey);
      if (report == null) {
        // Queue entry with no matching report — remove stale entry
        await _queueRepo.remove(item.idempotencyKey);
        continue;
      }

      // Build syncBatch item
      // Fetch associated photos for this report
      final photos = await _reportRepo.getPhotosByReportIdempotencyKey(
        item.idempotencyKey,
      );
      final photoUrls = photos.map((p) => p.filePath).toList();

      batchPayload.add({
        'idempotency_key': report.idempotencyKey,
        'description': report.description,
        'lat': report.lat,
        'lng': report.lng,
        'photo_urls': photoUrls,
        'reported_at': report.createdAt.toIso8601String(),
        'title': report.description.length > 80
            ? '${report.description.substring(0, 80)}...'
            : report.description,
        'population_affected': report.populationAffected,
        'vulnerability_index': report.vulnerabilityIndex,
        'category_id': report.categoryId,
        if (report.serverId != null) 'local_id': report.serverId,
        if (report.deviceId != null) 'device_id': report.deviceId,
      });
      keysInBatch.add(item.idempotencyKey);
    }

    if (batchPayload.isEmpty) {
      return const SyncResult(
        syncedCount: 0,
        failedCount: 0,
        deadLetteredCount: 0,
        errors: [],
      );
    }

    try {
      final batchResult = await _apiClient.syncBatch(reports: batchPayload);

      int synced = 0;
      int failed = 0;
      int deadLettered = 0;
      final errors = <String>[];

      for (final resultItem in batchResult.results) {
        final idx = resultItem.index ?? 0;
        if (idx >= keysInBatch.length) continue;
        final key = keysInBatch[idx];

        if (resultItem.error == null) {
          // Success
          final serverId = resultItem.id;
          await _reportRepo.markSynced(key, serverId ?? key);
          await _queueRepo.markSynced(key);
          synced++;
        } else {
          // Failure — increment retry
          final errorMsg = resultItem.error ?? 'Unknown error';
          errors.add('$key: $errorMsg');
          await _queueRepo.incrementRetry(
            key,
            errorMsg,
            backoff: const Duration(seconds: 30),
          );

          // Check if moved to dead-letter by incrementRetry
          final queueItem = await _queueRepo.getByIdempotencyKey(key);
          if (queueItem != null && queueItem.syncStatus == 3) {
            deadLettered++;
            await NotificationService().showDeadLetter(
              itemKey: key,
              reason: errorMsg,
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
    } catch (e, st) {
      _logger.error('syncBatch failed', e, st);
      // Mark all items as failed with backoff
      for (final key in keysInBatch) {
        await _queueRepo.incrementRetry(
          key,
          e.toString(),
          backoff: const Duration(seconds: 60),
        );
      }
      return SyncResult(
        syncedCount: 0,
        failedCount: keysInBatch.length,
        deadLetteredCount: 0,
        errors: ['Batch error: $e'],
      );
    }
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
        await NotificationService().showDeadLetter(
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

        await _apiClient.submitVisitReport(
          taskId: taskId,
          findings: payload['findings'] as String? ?? '',
          checklist:
              (payload['checklist'] as List?)
                  ?.map((e) => Map<String, dynamic>.from(e as Map))
                  .toList() ??
              [],
          photoUrls:
              (payload['photo_urls'] as List?)
                  ?.map((e) => e.toString())
                  .toList() ??
              [],
          gpsLat: (payload['gps_lat'] as num?)?.toDouble() ?? 0,
          gpsLng: (payload['gps_lng'] as num?)?.toDouble() ?? 0,
          accuracy: (payload['accuracy'] as num?)?.toDouble() ?? 6.0,
          conditionAssessment: payload['condition_assessment'] as String? ?? '',
          recommendation: payload['recommendation'] as String? ?? '',
          catatan: payload['catatan'] as String?,
        );

        await _queueRepo.markSynced(item.idempotencyKey);
        synced++;
      } catch (e, st) {
        _logger.error('Visit sync failed: ${item.idempotencyKey}', e, st);
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
          await NotificationService().showDeadLetter(
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

  /// Full flush: reports + visits. Guarded against re-entrancy.
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
      return SyncResult(
        syncedCount: reportResult.syncedCount + visitResult.syncedCount,
        failedCount: reportResult.failedCount + visitResult.failedCount,
        deadLetteredCount:
            reportResult.deadLetteredCount + visitResult.deadLetteredCount,
        errors: [...reportResult.errors, ...visitResult.errors],
      );
    } finally {
      _syncing = false;
    }
  }

  /// Check if device is currently online.
  static Future<bool> isOnline() async {
    final results = await Connectivity().checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }
}

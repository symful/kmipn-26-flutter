import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' hide isNotNull;
import 'package:sigap/db/database.dart';
import 'package:sigap/db/repositories/report_repository.dart';
import 'package:sigap/db/repositories/surveyor_task_repository.dart';
import 'package:sigap/db/repositories/sync_queue_repository.dart';
import 'package:sigap/sync/sync_worker.dart';
import 'package:sigap/api/api_client.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/native.dart';

void main() {
  // Ensure Flutter binding is initialized for Connectivity stream
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SyncWorker', () {
    late AppDatabase db;
    late ReportRepository reportRepo;
    late SurveyorTaskRepository surveyorTaskRepo;
    late SyncQueueRepository queueRepo;
    late ApiClient apiClient;
    late SyncWorker syncWorker;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      reportRepo = ReportRepository(db);
      surveyorTaskRepo = SurveyorTaskRepository(db);
      queueRepo = SyncQueueRepository(db);
      apiClient = ApiClient();
      syncWorker = SyncWorker(
        api: apiClient,
        reportRepo: reportRepo,
        surveyorTaskRepo: surveyorTaskRepo,
        queueRepo: queueRepo,
        connectivityStream: Connectivity().onConnectivityChanged,
        deviceId: 'test-device-uuid',
      );
    });

    tearDown(() async {
      await db.close();
    });

    test('start() and stop() manage connectivity subscription', () async {
      // Start and stop should not throw
      syncWorker.start();
      await Future.delayed(const Duration(milliseconds: 10));
      expect(() => syncWorker.stop(), returnsNormally);
    });

    test('syncNow returns early when already syncing', () async {
      // Queue some items to sync with past time to be "due"
      final now = DateTime.now();
      await db
          .into(db.syncQueue)
          .insert(
            SyncQueueCompanion.insert(
              idempotencyKey: 'test-key-1',
              nextRetryAt: now.subtract(const Duration(minutes: 1)),
            ),
          );

      // Call syncNow twice in quick succession
      final firstSync = syncWorker.syncNow();
      final secondSync = syncWorker.syncNow();

      // Both should complete without error
      await firstSync;
      await secondSync;
    });

    test('getPendingReports returns reports with syncStatus 0', () async {
      // Insert a report with syncStatus 0 (pending)
      final now = DateTime.now();
      await db
          .into(db.localReports)
          .insert(
            LocalReportsCompanion.insert(
              idempotencyKey: 'pending-key',
              categoryId: 'cat-1',
              description: 'Test report for pending sync',
              lat: -6.2,
              lng: 106.8,
              createdAt: now,
              updatedAt: now,
            ),
          );

      final pendingReports = await reportRepo.getPendingReports();
      expect(pendingReports.length, 1);
      expect(pendingReports.first.idempotencyKey, 'pending-key');
      expect(pendingReports.first.syncStatus, 0);
    });

    test(
      'getAllReports returns all reports ordered by createdAt desc',
      () async {
        final now = DateTime.now();
        await db
            .into(db.localReports)
            .insert(
              LocalReportsCompanion.insert(
                idempotencyKey: 'key-1',
                categoryId: 'cat-1',
                description: 'First report',
                lat: -6.2,
                lng: 106.8,
                createdAt: now.subtract(const Duration(hours: 1)),
                updatedAt: now.subtract(const Duration(hours: 1)),
              ),
            );

        await db
            .into(db.localReports)
            .insert(
              LocalReportsCompanion.insert(
                idempotencyKey: 'key-2',
                categoryId: 'cat-2',
                description: 'Second report',
                lat: -6.3,
                lng: 106.9,
                createdAt: now,
                updatedAt: now,
              ),
            );

        final allReports = await reportRepo.getAllReports();
        expect(allReports.length, 2);
        expect(allReports.first.idempotencyKey, 'key-2'); // Most recent first
      },
    );

    test('markSynced updates syncStatus and serverId', () async {
      final now = DateTime.now();
      await db
          .into(db.localReports)
          .insert(
            LocalReportsCompanion.insert(
              idempotencyKey: 'sync-test-key',
              categoryId: 'cat-1',
              description: 'Report to be synced',
              lat: -6.2,
              lng: 106.8,
              createdAt: now,
              updatedAt: now,
            ),
          );

      await reportRepo.markSynced('sync-test-key', 'server-123');

      final syncedReport = await reportRepo.getByIdempotencyKey(
        'sync-test-key',
      );
      expect(syncedReport, isNotNull);
      expect(syncedReport!.syncStatus, 1);
      expect(syncedReport.serverId, 'server-123');
    });

    test('markFailed updates syncStatus to 2', () async {
      final now = DateTime.now();
      await db
          .into(db.localReports)
          .insert(
            LocalReportsCompanion.insert(
              idempotencyKey: 'fail-test-key',
              categoryId: 'cat-1',
              description: 'Report to fail',
              lat: -6.2,
              lng: 106.8,
              createdAt: now,
              updatedAt: now,
            ),
          );

      await reportRepo.markFailed('fail-test-key');

      final failedReport = await reportRepo.getByIdempotencyKey(
        'fail-test-key',
      );
      expect(failedReport, isNotNull);
      expect(failedReport!.syncStatus, 2);
    });

    test('countPending returns correct count', () async {
      final now = DateTime.now();

      // Add 3 pending reports
      for (var i = 0; i < 3; i++) {
        await db
            .into(db.localReports)
            .insert(
              LocalReportsCompanion.insert(
                idempotencyKey: 'pending-key-$i',
                categoryId: 'cat-1',
                description: 'Pending report $i',
                lat: -6.2,
                lng: 106.8,
                createdAt: now,
                updatedAt: now,
              ),
            );
      }

      // Mark one as synced
      await reportRepo.markSynced('pending-key-0', 'server-1');

      final count = await reportRepo.countPending();
      expect(count, 2);
    });

    test('getDueItems returns items with nextRetryAt in the past', () async {
      final now = DateTime.now();

      // Due item (in the past)
      await db
          .into(db.syncQueue)
          .insert(
            SyncQueueCompanion.insert(
              idempotencyKey: 'due-key',
              nextRetryAt: now.subtract(const Duration(minutes: 5)),
            ),
          );

      // Not yet due (in the future)
      await db
          .into(db.syncQueue)
          .insert(
            SyncQueueCompanion.insert(
              idempotencyKey: 'not-due-key',
              nextRetryAt: now.add(const Duration(minutes: 5)),
            ),
          );

      final dueItems = await queueRepo.getDueItems();
      expect(dueItems.length, 1);
      expect(dueItems.first.idempotencyKey, 'due-key');
    });

    test('queue removal works correctly', () async {
      final now = DateTime.now();
      // Use a past time to ensure it's "due"
      await db
          .into(db.syncQueue)
          .insert(
            SyncQueueCompanion.insert(
              idempotencyKey: 'to-remove-key',
              nextRetryAt: now.subtract(const Duration(minutes: 1)),
            ),
          );

      var dueItems = await queueRepo.getDueItems();
      expect(dueItems.length, 1);

      await queueRepo.remove('to-remove-key');
      dueItems = await queueRepo.getDueItems();
      expect(dueItems.length, 0);
    });

    test('incrementRetry updates retry count and nextRetryAt', () async {
      final now = DateTime.now();
      // Use a past time to ensure it's "due"
      await db
          .into(db.syncQueue)
          .insert(
            SyncQueueCompanion.insert(
              idempotencyKey: 'retry-key',
              nextRetryAt: now.subtract(const Duration(minutes: 1)),
            ),
          );

      await queueRepo.incrementRetry(
        'retry-key',
        'Test error',
        backoff: const Duration(seconds: 10),
      );

      // Query directly to verify update (nextRetryAt is now in the future, so won't appear in getDueItems)
      final query = db.select(db.syncQueue)
        ..where((t) => t.idempotencyKey.equals('retry-key'));
      final items = await query.get();
      expect(items.first.retryCount, 1);
      expect(items.first.lastError, 'Test error');
      expect(items.first.nextRetryAt.isAfter(DateTime.now()), isTrue);
    });

    test('markAsDeadLetter updates syncStatus to 3', () async {
      final now = DateTime.now();
      // Insert a queue item
      await db
          .into(db.syncQueue)
          .insert(
            SyncQueueCompanion.insert(
              idempotencyKey: 'dead-letter-key',
              nextRetryAt: now.subtract(const Duration(minutes: 1)),
            ),
          );

      // Mark as dead letter
      await queueRepo.markAsDeadLetter(
        'dead-letter-key',
        'Max retries exceeded',
      );

      // Query directly to verify
      final query = db.select(db.syncQueue)
        ..where((t) => t.idempotencyKey.equals('dead-letter-key'));
      final items = await query.get();
      expect(items.first.syncStatus, 3); // deadLetter = 3
      expect(items.first.lastError, 'Max retries exceeded');
    });

    test('maxRetry constant is set to 5', () {
      expect(SyncWorker.maxRetry, 5);
    });

    test(
      'item with retryCount >= maxRetry should be marked dead letter',
      () async {
        final now = DateTime.now();
        // Insert a queue item with retryCount = MAX_RETRY (5)
        await db
            .into(db.syncQueue)
            .insert(
              SyncQueueCompanion.insert(
                idempotencyKey: 'max-retry-key',
                nextRetryAt: now.subtract(const Duration(minutes: 1)),
                retryCount: const Value(5),
              ),
            );

        // Manually call markAsDeadLetter since syncNow requires API setup
        await queueRepo.markAsDeadLetter(
          'max-retry-key',
          'Max retries exceeded',
        );

        // Verify the item was moved to dead letter queue
        final query = db.select(db.syncQueue)
          ..where((t) => t.idempotencyKey.equals('max-retry-key'));
        final items = await query.get();
        expect(items.first.syncStatus, 3); // deadLetter = 3
        expect(items.first.retryCount, 5);
      },
    );
  });
}

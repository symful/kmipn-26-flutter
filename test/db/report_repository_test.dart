import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sigap/db/database.dart';
import 'package:sigap/db/repositories/report_repository.dart';

void main() {
  late AppDatabase db;
  late ReportRepository repository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = ReportRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('ReportRepository', () {
    final now = DateTime.now();

    LocalReportsCompanion createReport({
      String idempotencyKey = 'test-key-1',
      String categoryId = 'cat-1',
      String description = 'Test report description',
      double lat = -6.2,
      double lng = 106.8,
      int syncStatus = 0,
      DateTime? createdAt,
      DateTime? updatedAt,
    }) {
      return LocalReportsCompanion.insert(
        idempotencyKey: idempotencyKey,
        categoryId: categoryId,
        description: description,
        lat: lat,
        lng: lng,
        createdAt: createdAt ?? now,
        updatedAt: updatedAt ?? now,
        syncStatus: Value(syncStatus),
      );
    }

    test('saveLocal inserts a report and can be retrieved', () async {
      final report = createReport();
      await repository.saveLocal(report);

      final results = await repository.getAllReports();
      expect(results.length, 1);
      expect(results.first.idempotencyKey, 'test-key-1');
      expect(results.first.description, 'Test report description');
    });

    test(
      'saveLocal with insertOnConflictUpdate updates existing report',
      () async {
        final report1 = createReport();
        await repository.saveLocal(report1);

        final report2 = createReport(
          idempotencyKey: 'test-key-1',
          description: 'Updated description',
        );
        await repository.saveLocal(report2);

        final results = await repository.getAllReports();
        expect(results.length, 1);
        expect(results.first.description, 'Updated description');
      },
    );

    test('getPendingReports returns only reports with syncStatus=0', () async {
      await repository.saveLocal(createReport(syncStatus: 0));
      await repository.saveLocal(
        createReport(idempotencyKey: 'test-key-2', syncStatus: 1),
      );
      await repository.saveLocal(
        createReport(idempotencyKey: 'test-key-3', syncStatus: 2),
      );

      final pending = await repository.getPendingReports();
      expect(pending.length, 1);
      expect(pending.first.idempotencyKey, 'test-key-1');
    });

    test(
      'getAllReports returns reports ordered by createdAt descending',
      () async {
        await repository.saveLocal(
          createReport(
            idempotencyKey: 'key-1',
            createdAt: now.subtract(const Duration(days: 2)),
            updatedAt: now.subtract(const Duration(days: 2)),
          ),
        );
        await repository.saveLocal(
          createReport(idempotencyKey: 'key-2', createdAt: now, updatedAt: now),
        );

        final results = await repository.getAllReports();
        expect(results.length, 2);
        expect(results.first.idempotencyKey, 'key-2');
        expect(results.last.idempotencyKey, 'key-1');
      },
    );

    test('getByIdempotencyKey returns correct report', () async {
      await repository.saveLocal(createReport(idempotencyKey: 'unique-key'));

      final result = await repository.getByIdempotencyKey('unique-key');
      expect(result, isNotNull);
      expect(result!.idempotencyKey, 'unique-key');
    });

    test('getByIdempotencyKey returns null for non-existent key', () async {
      final result = await repository.getByIdempotencyKey('non-existent');
      expect(result, isNull);
    });

    test('markSynced updates syncStatus to 1 and sets serverId', () async {
      await repository.saveLocal(createReport());
      await repository.markSynced('test-key-1', 'server-123');

      final report = await repository.getByIdempotencyKey('test-key-1');
      expect(report!.syncStatus, 1);
      expect(report.serverId, 'server-123');
    });

    test('markFailed updates syncStatus to 2', () async {
      await repository.saveLocal(createReport());
      await repository.markFailed('test-key-1');

      final report = await repository.getByIdempotencyKey('test-key-1');
      expect(report!.syncStatus, 2);
    });

    test('countPending returns correct count', () async {
      await repository.saveLocal(createReport(syncStatus: 0));
      await repository.saveLocal(
        createReport(idempotencyKey: 'test-key-2', syncStatus: 0),
      );
      await repository.saveLocal(
        createReport(idempotencyKey: 'test-key-3', syncStatus: 1),
      );

      final count = await repository.countPending();
      expect(count, 2);
    });

    test('retry resets syncStatus to 0 and re-enqueues to syncQueue', () async {
      await repository.saveLocal(createReport(syncStatus: 2));

      await repository.retry('test-key-1');

      final report = await repository.getByIdempotencyKey('test-key-1');
      expect(report!.syncStatus, 0);

      // Verify it was re-enqueued in syncQueue
      final queueItem = await db.select(db.syncQueue).get();
      expect(queueItem.length, 1);
      expect(queueItem.first.idempotencyKey, 'test-key-1');
    });

    test(
      'delete removes report from localReports, syncQueue, and localPhotos',
      () async {
        await repository.saveLocal(createReport());

        // Add a photo entry
        await db
            .into(db.localPhotos)
            .insert(
              LocalPhotosCompanion.insert(
                reportIdempotencyKey: 'test-key-1',
                filePath: '/path/to/photo.jpg',
                capturedAt: 1234567890,
              ),
            );

        await repository.delete('test-key-1');

        final reports = await repository.getAllReports();
        expect(reports.length, 0);

        final queue = await db.select(db.syncQueue).get();
        expect(queue.length, 0);

        final photos = await db
            .customSelect('SELECT * FROM local_photos')
            .get();
        expect(photos.length, 0);
      },
    );

    test(
      'clearOfflineQueue removes synced reports older than 7 days',
      () async {
        final oldDate = now.subtract(const Duration(days: 8));
        await repository.saveLocal(
          createReport(createdAt: oldDate, updatedAt: oldDate, syncStatus: 1),
        );

        final recentDate = now.subtract(const Duration(days: 3));
        await repository.saveLocal(
          createReport(
            idempotencyKey: 'recent-key',
            createdAt: recentDate,
            updatedAt: recentDate,
            syncStatus: 1,
          ),
        );

        final deleted = await repository.clearOfflineQueue();
        expect(deleted, 1);

        final remaining = await repository.getAllReports();
        expect(remaining.length, 1);
        expect(remaining.first.idempotencyKey, 'recent-key');
      },
    );
  });
}

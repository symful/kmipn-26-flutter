import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:sigap/db/database.dart';
import 'package:sigap/db/repositories/report_repository.dart';
import 'package:drift/native.dart';

void main() {
  group('ReportRepository', () {
    late AppDatabase db;
    late ReportRepository reportRepo;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      reportRepo = ReportRepository(db);
    });

    tearDown(() async {
      await db.close();
    });

    group('saveLocal', () {
      test('inserts a new report successfully', () async {
        final now = DateTime.now();
        final report = LocalReportsCompanion.insert(
          idempotencyKey: 'new-key',
          categoryId: 'cat-1',
          description: 'New test report',
          lat: -6.2,
          lng: 106.8,
          createdAt: now,
          updatedAt: now,
        );

        await reportRepo.saveLocal(report);

        final saved = await reportRepo.getByIdempotencyKey('new-key');
        expect(saved, isNotNull);
        expect(saved!.idempotencyKey, 'new-key');
        expect(saved.categoryId, 'cat-1');
        expect(saved.description, 'New test report');
        expect(saved.lat, -6.2);
        expect(saved.lng, 106.8);
      });

      test('insertOnConflictUpdate updates existing report', () async {
        final now = DateTime.now();

        // Insert initial report
        await reportRepo.saveLocal(
          LocalReportsCompanion.insert(
            idempotencyKey: 'conflict-key',
            categoryId: 'cat-1',
            description: 'Original description',
            lat: -6.2,
            lng: 106.8,
            createdAt: now,
            updatedAt: now,
          ),
        );

        // Update with same key
        await reportRepo.saveLocal(
          LocalReportsCompanion.insert(
            idempotencyKey: 'conflict-key',
            categoryId: 'cat-2',
            description: 'Updated description',
            lat: -7.0,
            lng: 107.0,
            createdAt: now,
            updatedAt: now.add(const Duration(seconds: 1)),
          ),
        );

        final updated = await reportRepo.getByIdempotencyKey('conflict-key');
        expect(updated, isNotNull);
        expect(updated!.categoryId, 'cat-2');
        expect(updated.description, 'Updated description');
        expect(updated.lat, -7.0);
      });
    });

    group('getPendingReports', () {
      test('returns only reports with syncStatus 0', () async {
        final now = DateTime.now();

        // Add pending report
        await db
            .into(db.localReports)
            .insert(
              LocalReportsCompanion.insert(
                idempotencyKey: 'pending-1',
                categoryId: 'cat-1',
                description: 'Pending report 1',
                lat: -6.2,
                lng: 106.8,
                createdAt: now,
                updatedAt: now,
              ),
            );

        // Add synced report
        await db
            .into(db.localReports)
            .insert(
              LocalReportsCompanion.insert(
                idempotencyKey: 'synced-1',
                categoryId: 'cat-1',
                description: 'Synced report',
                lat: -6.2,
                lng: 106.8,
                createdAt: now,
                updatedAt: now,
                syncStatus: const Value(1),
              ),
            );

        final pending = await reportRepo.getPendingReports();
        expect(pending.length, 1);
        expect(pending.first.idempotencyKey, 'pending-1');
      });

      test('returns empty list when no pending reports', () async {
        final pending = await reportRepo.getPendingReports();
        expect(pending, isEmpty);
      });
    });

    group('getAllReports', () {
      test('returns reports ordered by createdAt descending', () async {
        final now = DateTime.now();

        await db
            .into(db.localReports)
            .insert(
              LocalReportsCompanion.insert(
                idempotencyKey: 'key-1',
                categoryId: 'cat-1',
                description: 'Older report',
                lat: -6.2,
                lng: 106.8,
                createdAt: now.subtract(const Duration(days: 1)),
                updatedAt: now.subtract(const Duration(days: 1)),
              ),
            );

        await db
            .into(db.localReports)
            .insert(
              LocalReportsCompanion.insert(
                idempotencyKey: 'key-2',
                categoryId: 'cat-1',
                description: 'Newer report',
                lat: -6.2,
                lng: 106.8,
                createdAt: now,
                updatedAt: now,
              ),
            );

        final all = await reportRepo.getAllReports();
        expect(all.length, 2);
        expect(all.first.idempotencyKey, 'key-2'); // Most recent first
        expect(all.last.idempotencyKey, 'key-1');
      });
    });

    group('getByIdempotencyKey', () {
      test('returns report when found', () async {
        final now = DateTime.now();
        await db
            .into(db.localReports)
            .insert(
              LocalReportsCompanion.insert(
                idempotencyKey: 'find-me',
                categoryId: 'cat-1',
                description: 'Report to find',
                lat: -6.2,
                lng: 106.8,
                createdAt: now,
                updatedAt: now,
              ),
            );

        final report = await reportRepo.getByIdempotencyKey('find-me');
        expect(report, isNotNull);
        expect(report!.idempotencyKey, 'find-me');
      });

      test('returns null when not found', () async {
        final report = await reportRepo.getByIdempotencyKey('non-existent');
        expect(report, isNull);
      });
    });

    group('markSynced', () {
      test('updates syncStatus to 1 and sets serverId', () async {
        final now = DateTime.now();
        await db
            .into(db.localReports)
            .insert(
              LocalReportsCompanion.insert(
                idempotencyKey: 'to-sync',
                categoryId: 'cat-1',
                description: 'Report to sync',
                lat: -6.2,
                lng: 106.8,
                createdAt: now,
                updatedAt: now,
              ),
            );

        await reportRepo.markSynced('to-sync', 'server-uuid-123');

        final report = await reportRepo.getByIdempotencyKey('to-sync');
        expect(report!.syncStatus, 1);
        expect(report.serverId, 'server-uuid-123');
      });

      test('does not affect other fields', () async {
        final now = DateTime.now();
        await db
            .into(db.localReports)
            .insert(
              LocalReportsCompanion.insert(
                idempotencyKey: 'keep-fields',
                categoryId: 'cat-1',
                description: 'Keep my description',
                lat: -6.2,
                lng: 106.8,
                createdAt: now,
                updatedAt: now,
              ),
            );

        await reportRepo.markSynced('keep-fields', 'server-xyz');

        final report = await reportRepo.getByIdempotencyKey('keep-fields');
        expect(report!.description, 'Keep my description');
        expect(report.lat, -6.2);
        expect(report.categoryId, 'cat-1');
      });
    });

    group('markFailed', () {
      test('updates syncStatus to 2', () async {
        final now = DateTime.now();
        await db
            .into(db.localReports)
            .insert(
              LocalReportsCompanion.insert(
                idempotencyKey: 'to-fail',
                categoryId: 'cat-1',
                description: 'Report to fail',
                lat: -6.2,
                lng: 106.8,
                createdAt: now,
                updatedAt: now,
              ),
            );

        await reportRepo.markFailed('to-fail');

        final report = await reportRepo.getByIdempotencyKey('to-fail');
        expect(report!.syncStatus, 2);
      });
    });

    group('countPending', () {
      test('returns correct count of pending reports', () async {
        final now = DateTime.now();

        for (var i = 0; i < 5; i++) {
          await db
              .into(db.localReports)
              .insert(
                LocalReportsCompanion.insert(
                  idempotencyKey: 'count-key-$i',
                  categoryId: 'cat-1',
                  description: 'Pending report $i',
                  lat: -6.2,
                  lng: 106.8,
                  createdAt: now,
                  updatedAt: now,
                ),
              );
        }

        final count = await reportRepo.countPending();
        expect(count, 5);
      });

      test('returns 0 when no pending reports', () async {
        final count = await reportRepo.countPending();
        expect(count, 0);
      });

      test('excludes synced and failed reports', () async {
        final now = DateTime.now();

        // Add 3 pending
        for (var i = 0; i < 3; i++) {
          await db
              .into(db.localReports)
              .insert(
                LocalReportsCompanion.insert(
                  idempotencyKey: 'pending-$i',
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
        await reportRepo.markSynced('pending-0', 'server-1');

        // Mark one as failed
        await reportRepo.markFailed('pending-1');

        final count = await reportRepo.countPending();
        expect(count, 1);
      });
    });
  });
}

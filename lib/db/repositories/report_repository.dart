import 'package:drift/drift.dart';
import '../database.dart';

class ReportRepository {
  final AppDatabase _db;
  ReportRepository(this._db);

  Stream<List<LocalReport>> watchAllReports() =>
      _db.select(_db.localReports).watch();

  Future<void> saveLocal(LocalReportsCompanion report) async {
    await _db.into(_db.localReports).insertOnConflictUpdate(report);
  }

  Future<List<LocalReport>> getPendingReports() async {
    final query = _db.select(_db.localReports)
      ..where((t) => t.syncStatus.equals(0));
    return query.get();
  }

  Future<List<LocalReport>> getAllReports() async {
    final query = _db.select(_db.localReports)
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    return query.get();
  }

  Future<LocalReport?> getByIdempotencyKey(String key) async {
    final query = _db.select(_db.localReports)
      ..where((t) => t.idempotencyKey.equals(key));
    return query.getSingleOrNull();
  }

  Future<void> markSynced(String idempotencyKey, String serverId) async {
    final query = _db.update(_db.localReports)
      ..where((t) => t.idempotencyKey.equals(idempotencyKey));
    await query.write(
      LocalReportsCompanion(
        syncStatus: const Value(1),
        serverId: Value(serverId),
      ),
    );
  }

  Future<void> markFailed(String idempotencyKey) async {
    final query = _db.update(_db.localReports)
      ..where((t) => t.idempotencyKey.equals(idempotencyKey));
    await query.write(const LocalReportsCompanion(syncStatus: Value(2)));
  }

  Future<int> countPending() async {
    final query = _db.selectOnly(_db.localReports)
      ..addColumns([_db.localReports.idempotencyKey.count()])
      ..where(_db.localReports.syncStatus.equals(0));
    final rows = await query.get();
    return rows.first.read(_db.localReports.idempotencyKey.count()) ?? 0;
  }

  Future<List<LocalPhotoData>> getPhotosByReportIdempotencyKey(String key) {
    return _db.getPhotosByReportIdempotencyKey(key);
  }

  Future<void> markPhotoSynced(int photoId) async {
    await _db.markPhotoSynced(photoId);
  }

  Future<void> markPhotoFailed(int photoId) async {
    await _db.markPhotoFailed(photoId);
  }

  Future<void> retry(String idempotencyKey) async {
    // Reset syncStatus to 0 (pending)
    final reportQuery = _db.update(_db.localReports)
      ..where((t) => t.idempotencyKey.equals(idempotencyKey));
    await reportQuery.write(const LocalReportsCompanion(syncStatus: Value(0)));

    // Keep the original payload and media references when retrying.
    final existing =
        await (_db.select(_db.syncQueue)
              ..where((item) => item.idempotencyKey.equals(idempotencyKey)))
            .getSingleOrNull();
    if (existing == null) {
      await _db
          .into(_db.syncQueue)
          .insert(
            SyncQueueCompanion.insert(
              idempotencyKey: idempotencyKey,
              kind: const Value('report'),
              nextRetryAt: DateTime.now(),
            ),
          );
    } else {
      await (_db.update(
        _db.syncQueue,
      )..where((item) => item.idempotencyKey.equals(idempotencyKey))).write(
        SyncQueueCompanion(
          syncStatus: const Value(0),
          lastError: const Value(null),
          nextRetryAt: Value(DateTime.now()),
        ),
      );
    }
  }

  Future<void> delete(String idempotencyKey) async {
    // Delete from localReports
    final reportDelete = _db.delete(_db.localReports)
      ..where((t) => t.idempotencyKey.equals(idempotencyKey));
    await reportDelete.go();

    // Delete from syncQueue
    final queueDelete = _db.delete(_db.syncQueue)
      ..where((t) => t.idempotencyKey.equals(idempotencyKey));
    await queueDelete.go();

    // Delete associated photos
    final photosDelete = _db.delete(_db.localPhotos)
      ..where((t) => t.reportIdempotencyKey.equals(idempotencyKey));
    await photosDelete.go();
  }

  /// Removes locally-synced reports (syncStatus=1) older than 7 days.
  /// Called after a successful sync batch to clean up stale synced items.
  Future<int> clearOfflineQueue() async {
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    final query = _db.delete(_db.localReports)
      ..where(
        (t) => t.syncStatus.equals(1) & t.updatedAt.isSmallerThanValue(cutoff),
      );
    return query.go();
  }

  /// Refresh known cached statuses without treating a paginated response as a
  /// deletion list. Reports absent from this page remain available offline.
  Future<int> updateSyncedStatuses(
    Map<String, String> statusesByServerId,
  ) async {
    var updated = 0;
    await _db.transaction(() async {
      for (final entry in statusesByServerId.entries) {
        updated +=
            await (_db.update(_db.localReports)..where(
                  (row) =>
                      row.syncStatus.equals(1) & row.serverId.equals(entry.key),
                ))
                .write(LocalReportsCompanion(status: Value(entry.value)));
      }
    });
    return updated;
  }
}

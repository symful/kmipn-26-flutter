import 'package:drift/drift.dart';
import '../database.dart';

class SyncQueueRepository {
  final AppDatabase _db;
  SyncQueueRepository(this._db);

  Future<void> enqueue(String idempotencyKey, {DateTime? nextRetryAt}) async {
    await _db
        .into(_db.syncQueue)
        .insertOnConflictUpdate(
          SyncQueueCompanion.insert(
            idempotencyKey: idempotencyKey,
            nextRetryAt: nextRetryAt ?? DateTime.now(),
          ),
        );
  }

  Future<List<SyncQueueData>> getDueItems() async {
    final query = _db.select(_db.syncQueue)
      ..where((t) => t.nextRetryAt.isSmallerThanValue(DateTime.now()));
    return query.get();
  }

  Future<void> remove(String idempotencyKey) async {
    final query = _db.delete(_db.syncQueue)
      ..where((t) => t.idempotencyKey.equals(idempotencyKey));
    await query.go();
  }

  Future<void> incrementRetry(
    String idempotencyKey,
    String error, {
    required Duration backoff,
  }) async {
    final query = _db.select(_db.syncQueue)
      ..where((t) => t.idempotencyKey.equals(idempotencyKey));
    final current = await query.getSingleOrNull();
    if (current == null) return;
    final updateQuery = _db.update(_db.syncQueue)
      ..where((t) => t.idempotencyKey.equals(idempotencyKey));
    await updateQuery.write(
      SyncQueueCompanion(
        retryCount: Value(current.retryCount + 1),
        lastError: Value(error),
        nextRetryAt: Value(DateTime.now().add(backoff)),
      ),
    );
  }

  Future<SyncQueueData?> getByIdempotencyKey(String idempotencyKey) async {
    final query = _db.select(_db.syncQueue)
      ..where((t) => t.idempotencyKey.equals(idempotencyKey));
    return query.getSingleOrNull();
  }

  // deadLetter status = 3 (0=pending, 1=synced, 2=failed, 3=deadLetter)
  Future<void> markAsDeadLetter(String idempotencyKey, String error) async {
    final updateQuery = _db.update(_db.syncQueue)
      ..where((t) => t.idempotencyKey.equals(idempotencyKey));
    await updateQuery.write(
      SyncQueueCompanion(
        syncStatus: const Value(3),
        lastError: Value(error),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}

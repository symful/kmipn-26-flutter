import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sigap/db/database.dart';
import 'package:sigap/db/repositories/sync_queue_repository.dart';

void main() {
  late AppDatabase db;
  late SyncQueueRepository repository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = SyncQueueRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('SyncQueueRepository', () {
    test('enqueue inserts a new item into the sync queue', () async {
      await repository.enqueue('key-1');

      final items = await db.select(db.syncQueue).get();
      expect(items.length, 1);
      expect(items.first.idempotencyKey, 'key-1');
      expect(items.first.retryCount, 0);
    });

    test('enqueue with custom nextRetryAt sets the correct time', () async {
      final futureTime = DateTime.now().add(const Duration(hours: 1));
      await repository.enqueue('key-1', nextRetryAt: futureTime);

      final item = await db.select(db.syncQueue).getSingle();
      expect(item.nextRetryAt.isAfter(DateTime.now()), isTrue);
    });

    test('enqueue with insertOnConflictUpdate updates existing item', () async {
      await repository.enqueue('key-1');
      await repository.enqueue('key-1');

      final items = await db.select(db.syncQueue).get();
      expect(items.length, 1);
    });

    test(
      'getDueItems returns items where nextRetryAt is in the past',
      () async {
        // Item due now
        await db
            .into(db.syncQueue)
            .insert(
              SyncQueueCompanion.insert(
                idempotencyKey: 'due-key',
                nextRetryAt: DateTime.now().subtract(
                  const Duration(minutes: 1),
                ),
              ),
            );

        // Item due in future
        await db
            .into(db.syncQueue)
            .insert(
              SyncQueueCompanion.insert(
                idempotencyKey: 'future-key',
                nextRetryAt: DateTime.now().add(const Duration(hours: 1)),
              ),
            );

        final dueItems = await repository.getDueItems();
        expect(dueItems.length, 1);
        expect(dueItems.first.idempotencyKey, 'due-key');
      },
    );

    test('remove deletes item from sync queue', () async {
      await repository.enqueue('key-1');
      await repository.remove('key-1');

      final items = await db.select(db.syncQueue).get();
      expect(items.length, 0);
    });

    test(
      'incrementRetry increases retryCount and updates nextRetryAt',
      () async {
        await repository.enqueue('key-1');

        await repository.incrementRetry(
          'key-1',
          'Network error',
          backoff: const Duration(minutes: 5),
        );

        final item = await db.select(db.syncQueue).getSingle();
        expect(item.retryCount, 1);
        expect(item.lastError, 'Network error');
        expect(
          item.nextRetryAt.isAfter(
            DateTime.now().subtract(const Duration(minutes: 1)),
          ),
          isTrue,
        );
      },
    );

    test(
      'incrementRetry handles non-existent idempotencyKey gracefully',
      () async {
        // Should not throw
        await repository.incrementRetry(
          'non-existent',
          'Error',
          backoff: const Duration(minutes: 5),
        );
      },
    );

    test('getByIdempotencyKey returns correct item', () async {
      await repository.enqueue('unique-key');

      final item = await repository.getByIdempotencyKey('unique-key');
      expect(item, isNotNull);
      expect(item!.idempotencyKey, 'unique-key');
    });

    test('getByIdempotencyKey returns null for non-existent key', () async {
      final item = await repository.getByIdempotencyKey('non-existent');
      expect(item, isNull);
    });

    test('markAsDeadLetter sets syncStatus to 3 and stores error', () async {
      await repository.enqueue('key-1');

      await repository.markAsDeadLetter('key-1', 'Max retries exceeded');

      final item = await db.select(db.syncQueue).getSingle();
      expect(item.syncStatus, 3);
      expect(item.lastError, 'Max retries exceeded');
    });

    test('multiple increments accumulate retryCount correctly', () async {
      await repository.enqueue('key-1');

      await repository.incrementRetry(
        'key-1',
        'Error 1',
        backoff: const Duration(minutes: 1),
      );
      await repository.incrementRetry(
        'key-1',
        'Error 2',
        backoff: const Duration(minutes: 2),
      );
      await repository.incrementRetry(
        'key-1',
        'Error 3',
        backoff: const Duration(minutes: 3),
      );

      final item = await db.select(db.syncQueue).getSingle();
      expect(item.retryCount, 3);
      expect(item.lastError, 'Error 3');
    });
  });
}

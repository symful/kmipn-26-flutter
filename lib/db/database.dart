import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

part 'database.g.dart';

class LocalReports extends Table {
  TextColumn get idempotencyKey => text()();
  TextColumn get categoryId => text()();
  TextColumn get description => text().withLength(min: 10, max: 2000)();
  RealColumn get lat => real()();
  RealColumn get lng => real()();
  TextColumn get photoPath => text().nullable()();
  TextColumn get exifDataJson => text().nullable()();
  TextColumn get deviceId => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('submitted'))();
  IntColumn get syncStatus => integer().withDefault(const Constant(0))();
  IntColumn get populationAffected =>
      integer().withDefault(const Constant(0))();
  RealColumn get vulnerabilityIndex =>
      real().withDefault(const Constant(0.5))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get serverId => text().nullable()();
  TextColumn get addressArea => text().nullable()();

  @override
  Set<Column> get primaryKey => {idempotencyKey};
}

class SyncQueue extends Table {
  TextColumn get idempotencyKey => text()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get nextRetryAt => dateTime()();
  TextColumn get lastError => text().nullable()();
  IntColumn get syncStatus => integer().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  TextColumn get kind => text().nullable()();
  TextColumn get payloadJson => text().nullable()();

  @override
  Set<Column> get primaryKey => {idempotencyKey};
}

class LocalPhotos extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get reportIdempotencyKey =>
      text().references(LocalReports, #idempotencyKey)();
  TextColumn get filePath => text()();
  TextColumn get exifDataJson => text().nullable()();
  IntColumn get capturedAt => integer()();
  IntColumn get syncStatus => integer().withDefault(const Constant(0))();
}

class LocalPhotoData {
  final int id;
  final String reportIdempotencyKey;
  final String filePath;
  final String? exifDataJson;
  final int capturedAt;
  final int syncStatus;

  LocalPhotoData({
    required this.id,
    required this.reportIdempotencyKey,
    required this.filePath,
    this.exifDataJson,
    required this.capturedAt,
    this.syncStatus = 0,
  });
}

class LocalTasks extends Table {
  TextColumn get taskId => text()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get instructions => text().nullable()();
  TextColumn get status => text()();
  TextColumn get checklistTemplateJson => text()();
  DateTimeColumn get downloadedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {taskId};
}

class LocalTaskVisits extends Table {
  TextColumn get idempotencyKey => text()();
  TextColumn get taskId => text()();
  TextColumn get visitDataJson => text()();
  IntColumn get syncStatus => integer().withDefault(const Constant(0))();
  TextColumn get serverId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {idempotencyKey};
}

extension LocalPhotosDao on AppDatabase {
  Future<List<LocalPhotoData>> getPhotosByReportIdempotencyKey(String key) {
    final query = customSelect(
      'SELECT id, report_idempotency_key, file_path, exif_data_json, captured_at, sync_status FROM local_photos WHERE report_idempotency_key = \$1',
      variables: [Variable<String>(key)],
    );
    return query
        .map(
          (row) => LocalPhotoData(
            id: row.read<int>('id'),
            reportIdempotencyKey: row.read<String>('report_idempotency_key'),
            filePath: row.read<String>('file_path'),
            exifDataJson: row.readNullable<String>('exif_data_json'),
            capturedAt: row.read<int>('captured_at'),
            syncStatus: row.read<int>('sync_status'),
          ),
        )
        .get();
  }

  Future<int> insertPhoto({
    required String reportIdempotencyKey,
    required String filePath,
    String? exifDataJson,
    required int capturedAt,
  }) async {
    return into(localPhotos).insert(
      LocalPhotosCompanion.insert(
        reportIdempotencyKey: reportIdempotencyKey,
        filePath: filePath,
        exifDataJson: Value(exifDataJson),
        capturedAt: capturedAt,
      ),
    );
  }

  Future<void> markPhotoSynced(int photoId) async {
    final query = update(localPhotos)..where((t) => t.id.equals(photoId));
    await query.write(const LocalPhotosCompanion(syncStatus: Value(1)));
  }

  Future<void> markPhotoFailed(int photoId) async {
    final query = update(localPhotos)..where((t) => t.id.equals(photoId));
    await query.write(const LocalPhotosCompanion(syncStatus: Value(2)));
  }
}

@DriftDatabase(
  // Categories use the typed preferences catalog. Existing installations may
  // retain an unused local_categories table until a deliberate cache reset;
  // removing its model requires no destructive upgrade of queued reports.
  tables: [LocalReports, SyncQueue, LocalPhotos, LocalTasks, LocalTaskVisits],
)
class AppDatabase extends _$AppDatabase {
  static String nameForAccount(String? accountId) => accountId == null
      ? 'sigap_guest'
      : 'sigap_${sha256.convert(utf8.encode(accountId))}';

  AppDatabase({String? accountId})
    : super(driftDatabase(name: nameForAccount(accountId)));
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 9;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      if (from < 4) {
        await m.addColumn(localPhotos, localPhotos.syncStatus);
      }
      if (from < 5) {
        await m.addColumn(syncQueue, syncQueue.syncStatus);
      }
      if (from < 6) {
        await m.addColumn(localReports, localReports.populationAffected);
        await m.addColumn(localReports, localReports.vulnerabilityIndex);
      }
      if (from < 8) {
        await m.addColumn(syncQueue, syncQueue.kind);
        await m.addColumn(syncQueue, syncQueue.payloadJson);
      }
      if (from < 9) {
        // Drop old capabilities_cache table (capability system removed)
        await m.deleteTable('capabilities_cache');
        // Rename old surveyor tables to new names via raw SQL
        await customStatement(
          'ALTER TABLE local_surveyor_tasks RENAME TO local_tasks',
        );
        await customStatement(
          'ALTER TABLE local_surveyor_visits RENAME TO local_task_visits',
        );
      }
    },
  );
}

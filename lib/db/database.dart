import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

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

class LocalCategories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get iconName => text().nullable()();
  IntColumn get sortOrder => integer()();
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

class LocalSurveyorTasks extends Table {
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

class LocalSurveyorVisits extends Table {
  TextColumn get idempotencyKey => text()();
  TextColumn get taskId => text()();
  TextColumn get visitDataJson => text()();
  IntColumn get syncStatus => integer().withDefault(const Constant(0))();
  TextColumn get serverId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {idempotencyKey};
}

class CapabilitiesCache extends Table {
  TextColumn get userId => text()();
  TextColumn get role => text()();
  TextColumn get version => text()();
  TextColumn get payload => text()();
  DateTimeColumn get fetchedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {userId};
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
  tables: [
    LocalReports,
    SyncQueue,
    LocalCategories,
    LocalPhotos,
    LocalSurveyorTasks,
    LocalSurveyorVisits,
    CapabilitiesCache,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'sigap_db'));
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 8;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      if (from < 3) {
        await m.createTable(localSurveyorTasks);
        await m.createTable(localSurveyorVisits);
      }
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
      if (from < 7) {
        await m.createTable(capabilitiesCache);
      }
      if (from < 8) {
        await m.addColumn(syncQueue, syncQueue.kind);
        await m.addColumn(syncQueue, syncQueue.payloadJson);
      }
    },
  );
}

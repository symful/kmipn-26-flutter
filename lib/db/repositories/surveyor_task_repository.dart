import 'dart:convert';
import 'package:drift/drift.dart';
import '../database.dart';

class SurveyorTaskRepository {
  final AppDatabase _db;
  SurveyorTaskRepository(this._db);

  // ─── Downloaded Tasks ────────────────────────────────────────────────────────

  Future<void> saveDownloadedTask({
    required String taskId,
    required String title,
    String? description,
    String? instructions,
    required String status,
    required List<Map<String, dynamic>> checklistTemplate,
  }) async {
    await _db
        .into(_db.localSurveyorTasks)
        .insertOnConflictUpdate(
          LocalSurveyorTasksCompanion.insert(
            taskId: taskId,
            title: title,
            description: Value(description),
            instructions: Value(instructions),
            status: status,
            checklistTemplateJson: jsonEncode(checklistTemplate),
            downloadedAt: DateTime.now(),
          ),
        );
  }

  Future<List<LocalSurveyorTask>> getDownloadedTasks() {
    final query = _db.select(_db.localSurveyorTasks)
      ..orderBy([(t) => OrderingTerm.desc(t.downloadedAt)]);
    return query.get();
  }

  Future<LocalSurveyorTask?> getDownloadedTask(String taskId) {
    final query = _db.select(_db.localSurveyorTasks)
      ..where((t) => t.taskId.equals(taskId));
    return query.getSingleOrNull();
  }

  Future<bool> isTaskDownloaded(String taskId) async {
    final task = await getDownloadedTask(taskId);
    return task != null;
  }

  Future<void> removeDownloadedTask(String taskId) async {
    final query = _db.delete(_db.localSurveyorTasks)
      ..where((t) => t.taskId.equals(taskId));
    await query.go();
  }

  // ─── Visits ─────────────────────────────────────────────────────────────────

  Future<void> saveVisit({
    required String idempotencyKey,
    required String taskId,
    required Map<String, dynamic> visitData,
  }) async {
    await _db
        .into(_db.localSurveyorVisits)
        .insertOnConflictUpdate(
          LocalSurveyorVisitsCompanion.insert(
            idempotencyKey: idempotencyKey,
            taskId: taskId,
            visitDataJson: jsonEncode(visitData),
            createdAt: DateTime.now(),
          ),
        );
  }

  Future<List<LocalSurveyorVisit>> getPendingVisits() {
    final query = _db.select(_db.localSurveyorVisits)
      ..where((t) => t.syncStatus.equals(0));
    return query.get();
  }

  Future<List<LocalSurveyorVisit>> getAllVisits() {
    final query = _db.select(_db.localSurveyorVisits)
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    return query.get();
  }

  Future<LocalSurveyorVisit?> getVisitByIdempotencyKey(String key) {
    final query = _db.select(_db.localSurveyorVisits)
      ..where((t) => t.idempotencyKey.equals(key));
    return query.getSingleOrNull();
  }

  Future<void> markVisitSynced(String idempotencyKey, String serverId) {
    final query = _db.update(_db.localSurveyorVisits)
      ..where((t) => t.idempotencyKey.equals(idempotencyKey));
    return query.write(
      LocalSurveyorVisitsCompanion(
        syncStatus: const Value(1),
        serverId: Value(serverId),
      ),
    );
  }

  Future<void> markVisitFailed(String idempotencyKey) {
    final query = _db.update(_db.localSurveyorVisits)
      ..where((t) => t.idempotencyKey.equals(idempotencyKey));
    return query.write(
      const LocalSurveyorVisitsCompanion(syncStatus: Value(2)),
    );
  }

  Future<int> countPendingVisits() async {
    final query = _db.selectOnly(_db.localSurveyorVisits)
      ..addColumns([_db.localSurveyorVisits.idempotencyKey.count()])
      ..where(_db.localSurveyorVisits.syncStatus.equals(0));
    final rows = await query.get();
    return rows.first.read(_db.localSurveyorVisits.idempotencyKey.count()) ?? 0;
  }
}

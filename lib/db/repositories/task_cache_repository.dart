import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api/client.dart' show TaskDetail;
import '../database.dart';

/// An account's downloaded tasks. Legacy unscoped data is never adopted.
class TaskCacheRepository {
  TaskCacheRepository({required String? accountId})
    : _prefix = 'task_cache_${AppDatabase.nameForAccount(accountId)}';
  final String _prefix;
  String _key(String kind, String id) =>
      '${_prefix}_${kind}_${Uri.encodeComponent(id)}';
  Future<List<TaskDetail>> readTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final result = <TaskDetail>[];
    for (final id in prefs.getStringList('${_prefix}_ids') ?? <String>[]) {
      final raw = prefs.getString(_key('task', id));
      if (raw == null) continue;
      try {
        result.add(
          TaskDetail.fromJson(
            Map<String, dynamic>.from(jsonDecode(raw) as Map),
          ),
        );
      } on FormatException {
        continue;
      }
    }
    return result;
  }

  Future<TaskDetail?> readTask(String id) async {
    final tasks = await readTasks();
    for (final task in tasks) {
      if (task.taskId == id) return task;
    }
    return null;
  }

  Future<void> saveTask(TaskDetail task) async {
    final id = task.taskId;
    if (id == null || id.isEmpty) throw ArgumentError('Task ID required');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key('task', id), jsonEncode(task.toJson()));
    final ids = (prefs.getStringList('${_prefix}_ids') ?? <String>[]).toSet()
      ..add(id);
    await prefs.setStringList('${_prefix}_ids', ids.toList());
  }

  Future<Set<int>> readChecklist(String id) async =>
      ((await SharedPreferences.getInstance()).getStringList(
                _key('checks', id),
              ) ??
              <String>[])
          .map(int.tryParse)
          .whereType<int>()
          .toSet();
  Future<void> saveChecklist(String id, Set<int> checks) async {
    await (await SharedPreferences.getInstance()).setStringList(
      _key('checks', id),
      checks.map((value) => value.toString()).toList(),
    );
  }

  Future<String?> readSurveyDraft(String id) async =>
      (await SharedPreferences.getInstance()).getString(_key('survey', id));
  Future<void> saveSurveyDraft(String id, String json) async {
    await (await SharedPreferences.getInstance()).setString(
      _key('survey', id),
      json,
    );
  }

  Future<void> removeSurveyDraft(String id) async {
    await (await SharedPreferences.getInstance()).remove(_key('survey', id));
  }
}

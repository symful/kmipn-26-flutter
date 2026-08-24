import 'dart:developer';
import 'package:sigap/api/api_client.dart';
import 'package:sigap/api/types.g.dart';
import 'api_client_builder.dart';

/// Thrown when seed data cannot be retrieved from the backend.
/// This distinguishes an environment gap (no seeded data) from a bug.
class SeedUnavailableException implements Exception {
  final String reason;
  const SeedUnavailableException(this.reason);

  @override
  String toString() => 'SeedUnavailableException: $reason';
}

void _warn(String message) {
  log(message, name: 'seed_data', level: 900); // warning level
}

/// Fetches a real category ID from the API.
Future<String> getRealCategoryId() async {
  final client = await buildTestApiClient(role: Role.admin);
  final resp = await client.getCategories();
  if (resp.isEmpty) {
    const msg = 'No categories found';
    _warn(msg);
    throw const SeedUnavailableException(msg);
  }
  return resp.first.id ?? "";
}

/// Fetches a real wilayah ID from the API.
Future<String> getRealWilayahId() async {
  final client = await buildTestApiClient(role: Role.admin);
  final resp = await client.getWilayahList();
  if (resp.isEmpty) {
    const msg = 'No wilayah found';
    _warn(msg);
    throw const SeedUnavailableException(msg);
  }
  return resp.first.id ?? "";
}

/// Fetches a real report ID for the current warga user from the API.
Future<String> getRealReportId() async {
  final client = await buildTestApiClient(role: Role.warga);
  final resp = await client.getWargaReports();
  if (resp.items.isEmpty) {
    const msg = 'No reports found';
    _warn(msg);
    throw const SeedUnavailableException(msg);
  }
  return resp.items.first.id ?? "";
}

/// Fetches a real operator case ID from the API.
Future<String> getRealCaseId() async {
  final client = await buildTestApiClient(role: Role.operator);
  final resp = await client.getOperatorCases();
  final items = resp.items;
  if (items.isEmpty) {
    const msg = 'No operator cases found';
    _warn(msg);
    throw const SeedUnavailableException(msg);
  }
  return items.first.id ?? "";
}

/// Fetches a real unit ID from the API.
Future<String> getRealUnitId() async {
  final client = await buildTestApiClient(role: Role.adminDaerah);
  final resp = await client.getAdminUnits();
  final items = resp.entries;
  if (items.isEmpty) {
    const msg = 'No units found';
    _warn(msg);
    throw const SeedUnavailableException(msg);
  }
  return items.first['id'] as String;
}

/// Fetches a real verifikator case queue item ID from the API.
Future<String> getRealVerifikatorCaseId() async {
  final client = await buildTestApiClient(role: Role.verifikator);
  final resp = await client.getVerifikatorQueue();
  final items = resp.items;
  if (items.isEmpty) {
    const msg = 'No verifikator cases found';
    _warn(msg);
    throw const SeedUnavailableException(msg);
  }
  return items.first.id ?? "";
}

/// Fetches a real verifikator case queue item ID filtered by case status.
Future<String> getRealVerifikatorCaseIdByStatus(
  ApiClient client, {
  required List<String> statuses,
  int page = 1,
  int limit = 50,
}) async {
  final resp = await client.getVerifikatorQueue();
  final items = resp.items;
  for (final item in items) {
    final m = item as Map<String, dynamic>;
    final status = m['status'] as String?;
    if (status != null && statuses.contains(status)) {
      return m['id'] as String;
    }
  }
  throw SeedUnavailableException(
    'No verifikator case found in statuses: $statuses (page=$page)',
  );
}

/// Fetches a real petugas task ID from the API.
Future<String> getRealpetugasTaskId() async {
  final client = await buildTestApiClient(role: Role.petugas);
  final resp = await client.petugasGetTasks();
  if (resp.tasks.isEmpty) {
    const msg = 'No petugas tasks found';
    _warn(msg);
    throw const SeedUnavailableException(msg);
  }
  return resp.tasks.first.id ?? "";
}

/// Fetches a real petugas task ID filtered by task status.
Future<String> getRealpetugasTaskIdByStatus(
  ApiClient client, {
  required List<String> statuses,
  int page = 1,
  int limit = 50,
}) async {
  final resp = await client.petugasGetTasks();
  for (final task in resp.tasks) {
    final m = task;
    final status = m.status;
    if (status != null && statuses.contains(status)) {
      return m.id ?? "";
    }
  }
  throw SeedUnavailableException(
    'No petugas task found in statuses: $statuses (page=$page)',
  );
}

/// Fetches a real surveyor task ID from the API.
Future<String> getRealSurveyorTaskId() async {
  final client = await buildTestApiClient(role: Role.surveyor);
  final resp = await client.surveyorGetTasks();
  if (resp.tasks.isEmpty) {
    const msg = 'No surveyor tasks found';
    _warn(msg);
    throw const SeedUnavailableException(msg);
  }
  return resp.tasks.first.id ?? "";
}

/// Fetches a real surveyor task ID filtered by task status.
/// Scans pages until a match is found or pages are exhausted.
///
/// Example: getRealSurveyorTaskByStatus(client, statuses: ['assigned', 'in_progress'])
Future<String> getRealSurveyorTaskByStatus(
  ApiClient client, {
  required List<String> statuses,
  int page = 1,
  int limit = 50,
}) async {
  final resp = await client.surveyorGetTasks();
  for (final task in resp.tasks) {
    final m = task;
    final status = m.status;
    if (status != null && statuses.contains(status)) {
      return m.id ?? "";
    }
  }
  throw SeedUnavailableException(
    'No surveyor task found in statuses: $statuses (page=$page)',
  );
}

/// Pick a case from the operator's case list whose status is in [eligibleStatuses].
/// Returns the first match, or throws SeedUnavailableException if none found.
/// Used by tests that exercise backend endpoints with status guards.
Future<String> pickCaseInStatus(
  ApiClient client, {
  required List<String> eligibleStatuses,
  int page = 1,
  int limit = 50,
}) async {
  final res = await client.getOperatorCases(page: page, limit: limit);
  final items = res.items;
  for (final c in items) {
    final status = (c as Map<String, dynamic>)['status'] as String?;
    if (status != null && eligibleStatuses.contains(status)) {
      return c.id ?? "";
    }
  }
  throw SeedUnavailableException(
    'No case found in eligible statuses: $eligibleStatuses',
  );
}

import 'test_jwt.dart';
import 'api_client_builder.dart';

/// Fetches a real category ID from the API.
Future<String> getRealCategoryId() async {
  final client = await buildTestApiClient(role: Role.ADMIN);
  final resp = await client.getCategories();
  if (resp.isEmpty) throw StateError('No categories found');
  return resp.first['id'] as String;
}

/// Fetches a real wilayah ID from the API.
Future<String> getRealWilayahId() async {
  final client = await buildTestApiClient(role: Role.ADMIN);
  final resp = await client.getWilayahList();
  if (resp.isEmpty) throw StateError('No wilayah found');
  return resp.first['id'] as String;
}

/// Fetches a real report ID for the current warga user from the API.
Future<String> getRealReportId() async {
  final client = await buildTestApiClient(role: Role.WARGA);
  final resp = await client.getWargaReports();
  if (resp.isEmpty) throw StateError('No reports found');
  return resp.first['id'] as String;
}

/// Fetches a real operator case ID from the API.
Future<String> getRealCaseId() async {
  final client = await buildTestApiClient(role: Role.OPERATOR);
  final resp = await client.getOperatorCases();
  final items = resp['items'] as List?;
  if (items == null || items.isEmpty) {
    throw StateError('No operator cases found');
  }
  return items.first['id'] as String;
}

/// Fetches a real unit ID from the API.
Future<String> getRealUnitId() async {
  final client = await buildTestApiClient(role: Role.ADMIN_DAERAH);
  final resp = await client.getAdminUnits();
  final items = resp['items'] as List?;
  if (items == null || items.isEmpty) {
    throw StateError('No units found');
  }
  return items.first['id'] as String;
}

/// Fetches a real verifikator case queue item ID from the API.
Future<String> getRealVerifikatorCaseId() async {
  final client = await buildTestApiClient(role: Role.VERIFIKATOR);
  final resp = await client.getVerifikatorQueue();
  final items = resp['items'] as List?;
  if (items == null || items.isEmpty) {
    throw StateError('No verifikator cases found');
  }
  return items.first['id'] as String;
}

/// Fetches a real petugas task ID from the API.
Future<String> getRealPetugasTaskId() async {
  final client = await buildTestApiClient(role: Role.PETUGAS);
  final resp = await client.petugasGetTasks();
  if (resp.isEmpty) throw StateError('No petugas tasks found');
  return resp.first['id'] as String;
}

/// Fetches a real surveyor task ID from the API.
Future<String> getRealSurveyorTaskId() async {
  final client = await buildTestApiClient(role: Role.SURVEYOR);
  final resp = await client.surveyorGetTasks();
  if (resp.isEmpty) throw StateError('No surveyor tasks found');
  return resp.first['id'] as String;
}

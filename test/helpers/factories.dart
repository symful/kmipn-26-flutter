import 'dart:math';
import 'package:sigap_mobile/api/client.dart';
import 'test_env.dart';

/// Generates a test-unique ID string.
String _testId(String resource, [String? suffix]) {
  final nanos = DateTime.now().microsecondsSinceEpoch;
  final parts = ['TEST', testRunId, resource, '$nanos'];
  if (suffix != null) parts.insert(2, suffix);
  return parts.join('_');
}

/// Creates a test report map with unique TEST_ prefixed ID.
Map<String, dynamic> makeTestReport({
  String? id,
  String? categoryId,
  String? description,
  String? status,
  int? severity,
  double? lat,
  double? lng,
  String? title,
  String? deviceId,
  List<String>? photoUrls,
  String? idempotencyKey,
}) {
  final random = Random();
  return {
    'id': id ?? _testId('report'),
    'category_id': categoryId ?? _testId('cat'),
    'description': description ?? 'Test report description',
    'status': status ?? 'submitted',
    'severity': severity ?? 1,
    'created_at': DateTime.now().toIso8601String(),
    'generalized_location': 'Test Location',
    'lat': lat ?? -6.2 + random.nextDouble() * 0.1,
    'lng': lng ?? 106.8 + random.nextDouble() * 0.1,
    'title': title ?? 'Test Report',
    'device_id': deviceId ?? _testId('device'),
    'photo_urls': photoUrls ?? [],
    'idempotency_key': idempotencyKey ?? _testId('idem'),
  };
}

/// Creates a test user map with unique TEST_ prefixed ID.
Map<String, dynamic> makeTestUser({
  String? id,
  String? email,
  String? name,
  String? role,
  String? wilayahId,
  String? unitId,
}) {
  final nanos = DateTime.now().microsecondsSinceEpoch;
  return {
    'id': id ?? _testId('user'),
    'email': email ?? 'test-$nanos@test.local',
    'name': name ?? 'Test User',
    'role': role ?? 'warga',
    'wilayah_id': wilayahId ?? null,
    'unit_id': unitId ?? null,
    'created_at': DateTime.now().toIso8601String(),
  };
}

/// Creates a test category map with unique TEST_ prefixed ID.
Map<String, dynamic> makeTestCategory({
  String? id,
  String? name,
  String? slug,
  String? icon,
  String? description,
  String? parentId,
  int? reportCount,
}) {
  final nanos = DateTime.now().microsecondsSinceEpoch;
  return {
    'id': id ?? _testId('cat'),
    'name': name ?? 'Test Category',
    'slug': slug ?? 'test-cat-$nanos',
    'icon': icon ?? null,
    'description': description ?? null,
    'parent_id': parentId ?? null,
    'report_count': reportCount ?? 0,
  };
}

/// Creates a test wilayah (administrative region) map.
Map<String, dynamic> makeTestWilayah({
  String? id,
  String? name,
  String? code,
  String? level,
  String? parentId,
}) {
  final nanos = DateTime.now().microsecondsSinceEpoch;
  return {
    'id': id ?? _testId('wil'),
    'name': name ?? 'Test Wilayah',
    'code': code ?? 'TEST-$nanos',
    'level': level ?? 'village',
    'parent_id': parentId ?? null,
  };
}

/// Creates a test case (verifikator case) map.
Map<String, dynamic> makeTestCase({
  String? id,
  String? categoryId,
  String? description,
  String? status,
  int? severity,
  String? reportId,
  String? assignedTo,
  String? deadline,
  int? priorityScore,
  String? wilayahId,
}) {
  final random = Random();
  return {
    'id': id ?? _testId('case'),
    'category_id': categoryId ?? _testId('cat'),
    'description': description ?? 'Test case description',
    'status': status ?? 'pending_verification',
    'severity': severity ?? 1,
    'report_id': reportId ?? _testId('report'),
    'assigned_to': assignedTo ?? null,
    'deadline': deadline ?? null,
    'priority_score': priorityScore ?? null,
    'wilayah_id': wilayahId ?? null,
    'created_at': DateTime.now().toIso8601String(),
    'updated_at': DateTime.now().toIso8601String(),
    'lng': 106.8 + random.nextDouble() * 0.1,
    'lat': -6.2 + random.nextDouble() * 0.1,
    'photo_urls': <String>[],
    'category_name': null,
    'category_slug': null,
    'wilayah_name': null,
  };
}

/// Creates a test audit log entry map.
Map<String, dynamic> makeTestAuditEntry({
  String? id,
  String? actor,
  String? action,
  String? objectType,
  String? objectId,
  dynamic before,
  dynamic after,
  String? createdAt,
}) {
  return {
    'id': id ?? _testId('audit'),
    'actor': actor ?? null,
    'action': action ?? 'test_action',
    'object_type': objectType ?? 'report',
    'object_id': objectId ?? null,
    'before': before ?? null,
    'after': after ?? null,
    'created_at': createdAt ?? DateTime.now().toIso8601String(),
  };
}

/// Creates a test AI assessment result map.
Map<String, dynamic> makeTestAiAssessment({
  String? id,
  String? reportId,
  String? toolName,
  String? modelVersion,
  String? ruleVersion,
  double? confidence,
  List<String>? supportingFactors,
  List<String>? riskFactors,
  List<String>? correlationIds,
  String? status,
  Map<String, dynamic>? result,
  String? overallStatus,
}) {
  return {
    'id': id ?? _testId('assess'),
    'report_id': reportId ?? _testId('report'),
    'tool_name': toolName ?? 'test_tool',
    'model_version': modelVersion ?? 'gpt-4o',
    'rule_version': ruleVersion ?? 'v1',
    'confidence': confidence ?? 0.85,
    'supporting_factors': supportingFactors ?? ['factor_a', 'factor_b'],
    'risk_factors': riskFactors ?? <String>[],
    'correlation_ids': correlationIds ?? <String>[],
    'status': status ?? 'completed',
    'result': result ?? {'score': 75},
    'created_at': DateTime.now().toIso8601String(),
    'overall_status': overallStatus ?? 'completed',
  };
}

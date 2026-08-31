import 'package:flutter_test/flutter_test.dart';
import 'package:sigap_mobile/api/client.dart';
import 'test_env.dart';

/// Asserts that a value is a map with the expected keys.
void assertShape(
  Map<String, dynamic>? actual,
  Map<String, dynamic> expected, [
  String? message,
]) {
  expect(actual, isNotNull, reason: message ?? 'Expected map, got null');
  for (final key in expected.keys) {
    expect(
      actual!.containsKey(key),
      isTrue,
      reason: message ?? 'Missing expected key: "$key"',
    );
  }
}

/// Asserts that a response conforms to the SIGAP error envelope shape:
/// { error: string, message?: string, details?: unknown }
void assertErrorEnvelope(Map<String, dynamic>? actual, [String? message]) {
  assertShape(actual, {
    'error': isA<String>(),
  }, message ?? 'Error envelope validation failed');
  expect(
    actual!['error'],
    isA<String>(),
    reason: message ?? 'Expected error to be string',
  );
}

/// Asserts that a response contains R2 upload URL fields.
void assertR2Upload(Map<String, dynamic>? actual, [String? message]) {
  expect(
    actual,
    isNotNull,
    reason: message ?? 'Expected R2 upload response, got null',
  );
  final hasPublicUrl = actual!['public_url'] is String;
  final hasUploadUrl = actual['upload_url'] is String;
  final hasPhotoUrl = actual['photo_url'] is String;
  expect(
    hasPublicUrl || (hasUploadUrl && hasPhotoUrl),
    isTrue,
    reason:
        message ??
        'Expected R2 upload shape with public_url or (upload_url + photo_url)',
  );
}

/// Asserts that an audit log entry conforms to the expected shape.
void assertAuditEntry(
  Map<String, dynamic>? actual, [
  Map<String, dynamic>? expectedFields,
]) {
  expect(actual, isNotNull, reason: 'Audit entry cannot be null');
  expect(
    actual!['id'],
    isA<String>(),
    reason: 'Audit entry id should be String',
  );
  expect(
    actual['action'],
    isA<String>(),
    reason: 'Audit entry action should be String',
  );
  expect(
    actual['object_type'],
    isA<String>(),
    reason: 'Audit entry object_type should be String',
  );
  expect(
    actual['created_at'],
    isA<String>(),
    reason: 'Audit entry created_at should be String',
  );

  if (expectedFields != null) {
    for (final entry in expectedFields.entries) {
      expect(
        actual[entry.key],
        entry.value,
        reason: 'Audit entry field "${entry.key}" mismatch',
      );
    }
  }
}

/// JWT claim validation result.
class JwtClaimResult {
  final bool valid;
  final String? error;
  JwtClaimResult({required this.valid, this.error});
}

/// Asserts that a JWT payload contains the expected claims.
/// P1 found: sub, role, roles[], wilayah_id, email, type, jti, exp
void assertJwtClaims(
  Map<String, dynamic>? actual,
  Map<String, dynamic>? expected,
) {
  expect(actual, isNotNull, reason: 'JWT claims cannot be null');

  final claims = actual!;

  // Validate known string claims
  final stringClaims = ['sub', 'role', 'email', 'type', 'jti'];
  for (final claim in stringClaims) {
    if (expected?[claim] != null) {
      expect(
        claims[claim],
        isA<String>(),
        reason: 'JWT claim "$claim" should be String',
      );
    }
  }

  // Validate roles array
  if (expected?['roles'] != null) {
    expect(
      claims['roles'],
      isA<List>(),
      reason: 'JWT claim "roles" should be List',
    );
  }

  // Validate wilayah_id (can be null or string)
  if (expected?['wilayah_id'] != null) {
    expect(
      claims['wilayah_id'] == null || claims['wilayah_id'] is String,
      isTrue,
      reason: 'JWT claim "wilayah_id" should be String or null',
    );
  }

  // Validate exp is a Unix timestamp
  if (expected?['exp'] != null) {
    expect(
      claims['exp'],
      isA<num>(),
      reason: 'JWT claim "exp" should be number',
    );
    final exp = (claims['exp'] as num).toInt();
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    expect(
      exp > now,
      isTrue,
      reason: 'JWT token appears expired: exp=$exp, now=$now',
    );
  }

  // Apply expected values
  if (expected != null) {
    for (final entry in expected.entries) {
      if (entry.value != null) {
        expect(
          claims[entry.key],
          entry.value,
          reason: 'JWT claim "${entry.key}" mismatch',
        );
      }
    }
  }
}

/// Asserts that a token is a valid JWT string format (header.payload.signature).
void assertJwtFormat(String? token, [String? message]) {
  expect(token, isNotNull, reason: message ?? 'JWT token cannot be null');
  final parts = token!.split('.');
  expect(
    parts.length,
    3,
    reason:
        message ?? 'Invalid JWT format: expected 3 parts, got ${parts.length}',
  );
}

/// Asserts that an AI assessment result conforms to the expected shape.
/// P1 found: report_id, overall_status, tool_results
void assertAiAssessmentShape(
  Map<String, dynamic>? actual, [
  Map<String, dynamic>? expectedFields,
]) {
  expect(actual, isNotNull, reason: 'AI assessment cannot be null');

  // Validate top-level required fields
  expect(
    actual!['report_id'],
    isA<String>(),
    reason: 'report_id should be String',
  );
  expect(
    actual['overall_status'],
    isA<String>(),
    reason: 'overall_status should be String',
  );
  expect(
    actual['tool_results'],
    isA<List>(),
    reason: 'tool_results should be List',
  );

  // Validate each tool result entry
  for (int i = 0; i < (actual['tool_results'] as List).length; i++) {
    final result = (actual['tool_results'] as List)[i] as Map<String, dynamic>;
    expect(
      result['id'],
      isA<String>(),
      reason: 'tool_results[$i].id should be String',
    );
    expect(
      result['tool_name'],
      isA<String>(),
      reason: 'tool_results[$i].tool_name should be String',
    );
    expect(
      result['confidence'],
      isA<num>(),
      reason: 'tool_results[$i].confidence should be num',
    );
    expect(
      result['status'],
      isA<String>(),
      reason: 'tool_results[$i].status should be String',
    );
    expect(
      result['result'],
      isA<Map>(),
      reason: 'tool_results[$i].result should be Map',
    );
  }

  // Apply expected field values
  if (expectedFields != null) {
    for (final entry in expectedFields.entries) {
      if (entry.value != null) {
        expect(
          actual[entry.key],
          entry.value,
          reason: 'AI assessment field "${entry.key}" mismatch',
        );
      }
    }
  }
}

/// Asserts that a paginated response has the expected pagination metadata.
void assertPagination(
  Map<String, dynamic>? actual, [
  Map<String, dynamic>? expectedFields,
]) {
  expect(actual, isNotNull, reason: 'Pagination cannot be null');
  expect(actual!['page'], isA<num>(), reason: 'pagination.page should be num');
  expect(actual['limit'], isA<num>(), reason: 'pagination.limit should be num');
  expect(actual['total'], isA<num>(), reason: 'pagination.total should be num');
  expect(
    actual['total_pages'],
    isA<num>(),
    reason: 'pagination.total_pages should be num',
  );

  if (expectedFields != null) {
    for (final entry in expectedFields.entries) {
      if (entry.value != null) {
        expect(
          actual[entry.key],
          entry.value,
          reason: 'Pagination field "${entry.key}" mismatch',
        );
      }
    }
  }
}

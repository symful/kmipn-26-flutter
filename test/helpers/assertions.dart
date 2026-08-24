import 'package:flutter_test/flutter_test.dart';
import 'package:sigap/api/exceptions.dart';

/// Matches a UUID v4 string (8-4-4-4-12 hex digits).
final _uuidRegex = RegExp(
  r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
);

/// Asserts that [s] is a valid UUID-formatted string.
void expectUuid(String s) {
  expect(
    s,
    isA<String>().having(
      (v) => _uuidRegex.hasMatch(v),
      'matches UUID regex',
      true,
    ),
  );
}

/// Asserts that [s] is a valid ISO-8601 date-time string parseable by DateTime.parse.
void expectIsoDate(String s) {
  expect(s, isA<String>());
  expect(
    () => DateTime.parse(s),
    returnsNormally,
    reason: '"$s" should be parseable as ISO-8601 date-time',
  );
}

/// Asserts that [data] is a Map with a [primaryKey] entry that holds a List.
/// Use for envelope assertions like {items: [...]} or {tasks: [...]}.
///
/// Example: expectListEnvelope(response.data, 'items');
void expectListEnvelope(dynamic data, String primaryKey) {
  expect(
    data,
    isA<Map>().having(
      (m) => m.containsKey(primaryKey),
      'contains key "$primaryKey"',
      true,
    ),
  );
  final list = (data as Map)[primaryKey];
  expect(
    list,
    isA<List>(),
    reason: 'Envelope key "$primaryKey" should hold a List',
  );
}

/// Awaits [future], catches [ApiException], and asserts the caught exception
/// matches the given constraints.
///
/// Example:
///   await expectApiException(
///     client.createReport(badBody),
///     status: 400,
///     userMessageContains: 'valid',
///   );
Future<void> expectApiException(
  Future future, {
  int? status,
  String? userMessageContains,
  String? fieldContains,
}) async {
  Object? caught;
  try {
    await future;
    fail('Expected ApiException to be thrown but nothing was thrown');
  } on ApiException catch (e) {
    caught = e;
  } catch (e) {
    fail('Expected ApiException but got ${e.runtimeType}: $e');
  }

  final exc = caught as ApiException;
  if (status != null) {
    expect(
      exc.statusCode,
      status,
      reason: 'ApiException statusCode should be $status',
    );
  }
  if (userMessageContains != null) {
    expect(
      exc.userMessage?.toLowerCase(),
      contains(userMessageContains.toLowerCase()),
      reason: 'ApiException userMessage should contain "$userMessageContains"',
    );
  }
  if (fieldContains != null) {
    expect(
      exc.body?.toLowerCase(),
      contains(fieldContains.toLowerCase()),
      reason: 'ApiException body should contain "$fieldContains"',
    );
  }
}

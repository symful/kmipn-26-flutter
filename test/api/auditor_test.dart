import 'package:flutter_test/flutter_test.dart';
import 'package:sigap/api/api_client.dart';
import '../helpers/test_jwt.dart';
import '../helpers/api_client_builder.dart';

void main() {
  late ApiClient client;

  setUpAll(() async {
    TestJwtCache.clearCache();
    client = await buildTestApiClient(role: Role.AUDITOR);
  });

  group('Auditor API', () {
    test('getAuditorAuditSearch returns audit entries', () async {
      final result = await client.getAuditorAuditSearch(page: 1, limit: 50);
      expect(result, isA<Map<String, dynamic>>());
      expect(
        result.containsKey('entries') ||
            result.containsKey('data') ||
            result.containsKey('total'),
        isTrue,
      );
    });

    test('getAuditorAuditSearch with action filter works', () async {
      final result = await client.getAuditorAuditSearch(
        page: 1,
        limit: 50,
        action: 'report_create',
      );
      expect(result, isA<Map<String, dynamic>>());
    });

    test('getAuditorAuditSearch with actorId filter works', () async {
      final result = await client.getAuditorAuditSearch(
        page: 1,
        limit: 50,
        actorId: 'some-actor-id',
      );
      expect(result, isA<Map<String, dynamic>>());
    });

    test('getAuditorAuditSearch with date range filter works', () async {
      final result = await client.getAuditorAuditSearch(
        page: 1,
        limit: 50,
        from: '2026-01-01',
        to: '2026-08-20',
      );
      expect(result, isA<Map<String, dynamic>>());
    });

    test('getAuditorAuditExport returns export content', () async {
      final result = await client.getAuditorAuditExport(format: 'csv');
      expect(result, isA<String>());
      expect(result.isNotEmpty, isTrue);
    });

    test('getAuditorAuditExport with filters works', () async {
      final result = await client.getAuditorAuditExport(
        format: 'csv',
        action: 'report_create',
        from: '2026-01-01',
        to: '2026-08-20',
      );
      expect(result, isA<String>());
    });

    test('getAuditorAuditExport with json format works', () async {
      final result = await client.getAuditorAuditExport(format: 'json');
      expect(result, isA<String>());
    });

    test('getAuditorSystemLogs returns system log entries', () async {
      final result = await client.getAuditorSystemLogs(page: 1, limit: 50);
      expect(result, isA<Map<String, dynamic>>());
      expect(
        result.containsKey('entries') ||
            result.containsKey('data') ||
            result.containsKey('total'),
        isTrue,
      );
    });

    test('getAuditorSystemLogs with level filter works', () async {
      final result = await client.getAuditorSystemLogs(
        page: 1,
        limit: 50,
        level: 'error',
      );
      expect(result, isA<Map<String, dynamic>>());
    });

    test('getAuditorSystemLogs with date range filter works', () async {
      final result = await client.getAuditorSystemLogs(
        page: 1,
        limit: 50,
        from: '2026-01-01',
        to: '2026-08-20',
      );
      expect(result, isA<Map<String, dynamic>>());
    });

    test('getAuditorStats returns auditor statistics', () async {
      final result = await client.getAuditorStats();
      expect(result, isA<Map<String, dynamic>>());
      expect(
        result.containsKey('counts') || result.containsKey('total'),
        isTrue,
      );
    });
  });
}

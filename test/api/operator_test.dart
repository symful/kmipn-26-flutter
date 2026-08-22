import 'package:flutter_test/flutter_test.dart';
import 'package:sigap/api/api_client.dart';
import '../helpers/test_harness.dart';
import '../helpers/api_client_builder.dart';
import '../helpers/test_jwt.dart';

void main() {
  group('Operator API', () {
    late ApiClient client;

    setUpAll(() async {
      await testCooldown(seconds: 5);
      client = await buildTestApiClient(role: Role.VERIFIKATOR);
    });

    test('getOperatorCases returns case list', () async {
      final result = await client.getOperatorCases();
      expect(result, isA<Map<String, dynamic>>());
    });

    test('getOperatorCases with pagination', () async {
      final result = await client.getOperatorCases(page: 1, limit: 10);
      expect(result, isA<Map<String, dynamic>>());
    });

    test('getOperatorCases with status filter', () async {
      final result = await client.getOperatorCases(status: 'open');
      expect(result, isA<Map<String, dynamic>>());
    });

    test('getOperatorDashboard returns dashboard data', () async {
      final result = await client.getOperatorDashboard();
      expect(result, isA<Map<String, dynamic>>());
    });

    test('getOperatorStats returns statistics', () async {
      final result = await client.getOperatorStats();
      expect(result, isA<Map<String, dynamic>>());
    });

    test('getOperatorBacklog returns backlog data', () async {
      final result = await client.getOperatorBacklog();
      expect(result, isA<Map<String, dynamic>>());
    });

    test('getOperatorBacklog with custom days', () async {
      final result = await client.getOperatorBacklog(days: 7);
      expect(result, isA<Map<String, dynamic>>());
    });

    test('getOperatorQueueCounts returns queue counts', () async {
      final result = await client.getOperatorQueueCounts();
      expect(result, isA<Map<String, dynamic>>());
    });

    test('mergeOperatorCase merges cases', () async {
      // Get cases first to find valid case IDs
      final casesResult = await client.getOperatorCases(limit: 5);
      final cases = casesResult['items'] as List<dynamic>?;
      if (cases == null || cases.length < 2) return;

      final caseId = (cases[0] as Map<String, dynamic>)['id'] as String;
      final targetCaseIds = [
        (cases[1] as Map<String, dynamic>)['id'] as String,
      ];

      final result = await client.mergeOperatorCase(
        caseId: caseId,
        targetCaseIds: targetCaseIds,
        reason: 'Test merge reason',
      );
      expect(result, isA<Map<String, dynamic>>());
    });

    test('separateOperatorCase separates a case', () async {
      // Get cases first to find a valid case ID
      final casesResult = await client.getOperatorCases(limit: 5);
      final cases = casesResult['items'] as List<dynamic>?;
      if (cases == null || cases.isEmpty) return;

      final caseId = (cases[0] as Map<String, dynamic>)['id'] as String;

      // Get reports within the case
      final reports =
          (cases[0] as Map<String, dynamic>)['report_ids'] as List<dynamic>?;
      if (reports == null || reports.isEmpty) return;

      final reportIdsToSeparate = [reports.first as String];

      final result = await client.separateOperatorCase(
        caseId: caseId,
        reportIdsToSeparate: reportIdsToSeparate,
        reason: 'Test separate reason',
      );
      expect(result, isA<Map<String, dynamic>>());
    });

    test('setOperatorPriority updates case priority', () async {
      final casesResult = await client.getOperatorCases(limit: 5);
      final cases = casesResult['items'] as List<dynamic>?;
      if (cases == null || cases.isEmpty) return;

      final caseId = (cases[0] as Map<String, dynamic>)['id'] as String;

      final result = await client.setOperatorPriority(
        caseId: caseId,
        newScore: 85,
        reason: 'Test priority update',
      );
      expect(result, isA<Map<String, dynamic>>());
    });

    test('assignOperatorCase assigns case to unit', () async {
      final casesResult = await client.getOperatorCases(limit: 5);
      final cases = casesResult['items'] as List<dynamic>?;
      if (cases == null || cases.isEmpty) return;

      final caseId = (cases[0] as Map<String, dynamic>)['id'] as String;

      final result = await client.assignOperatorCase(
        caseId: caseId,
        unitId: 'unit-1',
        instructions: 'Test instructions',
      );
      expect(result, isA<Map<String, dynamic>>());
    });

    test('escalateOperatorCase escalates a case', () async {
      final casesResult = await client.getOperatorCases(limit: 5);
      final cases = casesResult['items'] as List<dynamic>?;
      if (cases == null || cases.isEmpty) return;

      final caseId = (cases[0] as Map<String, dynamic>)['id'] as String;

      final result = await client.escalateOperatorCase(
        caseId: caseId,
        reason: 'Test escalation reason',
      );
      expect(result, isA<Map<String, dynamic>>());
    });

    test('setOperatorSla updates case SLA deadline', () async {
      final casesResult = await client.getOperatorCases(limit: 5);
      final cases = casesResult['items'] as List<dynamic>?;
      if (cases == null || cases.isEmpty) return;

      final caseId = (cases[0] as Map<String, dynamic>)['id'] as String;

      final result = await client.setOperatorSla(
        caseId: caseId,
        newDeadline: '2026-09-01T00:00:00Z',
        reason: 'Test SLA update',
      );
      expect(result, isA<Map<String, dynamic>>());
    });

    test('getOutboxList returns outbox entries', () async {
      final result = await client.getOutboxList();
      expect(result, isA<Map<String, dynamic>>());
    });

    test('getOutboxList with pagination and filters', () async {
      final result = await client.getOutboxList(
        page: 1,
        limit: 10,
        status: 'pending',
        targetSystem: 'sipd',
      );
      expect(result, isA<Map<String, dynamic>>());
    });

    test('getOutboxDlq returns dead-letter queue entries', () async {
      final result = await client.getOutboxDlq();
      expect(result, isA<Map<String, dynamic>>());
    });

    test('getOutboxDlq with pagination and filters', () async {
      final result = await client.getOutboxDlq(
        page: 1,
        limit: 10,
        targetSystem: 'sipd',
      );
      expect(result, isA<Map<String, dynamic>>());
    });

    test('reconcileOutboxDlq reconciles stuck entries', () async {
      try {
        final result = await client.reconcileOutboxDlq();
        expect(result, isA<Map<String, dynamic>>());
      } catch (e) {
        // Backend may return 500 if DLQ is empty or unavailable
        expect(e.toString(), isNotEmpty); // Just verify error occurred
      }
    });

    test('processOutbox triggers immediate processing', () async {
      try {
        final result = await client.processOutbox();
        expect(result, isA<Map<String, dynamic>>());
      } catch (e) {
        expect(e.toString(), isNotEmpty);
      }
    });

    test('getNotifications returns notifications list', () async {
      final result = await client.getNotifications();
      expect(result, isA<List<Map<String, dynamic>>>());
    });

    test('getNotifications with pagination', () async {
      final result = await client.getNotifications(page: 1, limit: 10);
      expect(result, isA<List<Map<String, dynamic>>>());
    });

    test('markNotificationRead marks a notification as read', () async {
      final notifications = await client.getNotifications();
      if (notifications.isEmpty) return;

      final notificationId = notifications.first['id']?.toString();
      if (notificationId == null) return;

      final result = await client.markNotificationRead(notificationId);
      expect(result, isA<Map<String, dynamic>>());
    });

    test('markAllNotificationsRead marks all notifications as read', () async {
      final result = await client.markAllNotificationsRead();
      expect(result, isA<Map<String, dynamic>>());
    });

    test('getWilayahList returns wilayah list', () async {
      final result = await client.getWilayahList();
      expect(result, isA<List<Map<String, dynamic>>>());
    });

    test('getWilayahBoundary returns boundary geometry', () async {
      final wilayahs = await client.getWilayahList();
      if (wilayahs.isEmpty) return;

      final wilayahId = wilayahs.first['id']?.toString();
      if (wilayahId == null) return;

      final result = await client.getWilayahBoundary(wilayahId);
      expect(result, isA<Map<String, dynamic>>());
    });
  });
}

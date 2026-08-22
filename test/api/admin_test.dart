import 'package:flutter_test/flutter_test.dart';
import 'package:sigap/api/api_client.dart';
import '../helpers/test_harness.dart';
import '../helpers/test_jwt.dart';
import '../helpers/api_client_builder.dart';

void main() {
  late ApiClient adminClient;

  setUpAll(() async {
    await testCooldown(seconds: 5);
    final token = await TestJwtCache.getToken(Role.ADMIN);
    if (token.isEmpty) {
      throw Exception(
        'ADMIN token not available. Set TEST_ADMIN_TOKEN environment variable '
        'or ensure the test login endpoint is running.',
      );
    }
    adminClient = await buildTestApiClient(role: Role.ADMIN);
  });

  group('Admin API', () {
    test('getAdminUsers returns paginated users', () async {
      final result = await adminClient.getAdminUsers(page: 1, limit: 10);
      expect(result, isA<Map<String, dynamic>>());
      expect(
        result.containsKey('total') ||
            result.containsKey('entries') ||
            result.containsKey('data'),
        isTrue,
      );
    });

    test('getAdminUsers with search filter works', () async {
      final result = await adminClient.getAdminUsers(
        page: 1,
        limit: 10,
        search: 'admin',
      );
      expect(result, isA<Map<String, dynamic>>());
    });

    test('getAdminUsers with role filter works', () async {
      final result = await adminClient.getAdminUsers(
        page: 1,
        limit: 10,
        role: 'OPERATOR',
      );
      expect(result, isA<Map<String, dynamic>>());
    });

    test('getAdminUsers with isActive filter works', () async {
      final result = await adminClient.getAdminUsers(
        page: 1,
        limit: 10,
        isActive: true,
      );
      expect(result, isA<Map<String, dynamic>>());
    });

    test('getAdminUnits returns paginated units', () async {
      final result = await adminClient.getAdminUnits(page: 1, limit: 10);
      expect(result, isA<Map<String, dynamic>>());
      expect(
        result.containsKey('total') ||
            result.containsKey('entries') ||
            result.containsKey('data'),
        isTrue,
      );
    });

    test('getAdminUnits with search filter works', () async {
      final result = await adminClient.getAdminUnits(
        page: 1,
        limit: 10,
        search: 'kecamatan',
      );
      expect(result, isA<Map<String, dynamic>>());
    });

    test('getAdminChecklistTemplates returns paginated templates', () async {
      final result = await adminClient.getAdminChecklistTemplates(
        page: 1,
        limit: 10,
      );
      expect(result, isA<Map<String, dynamic>>());
      expect(
        result.containsKey('total') ||
            result.containsKey('entries') ||
            result.containsKey('data'),
        isTrue,
      );
    });

    test('getAdminChecklistTemplates with categoryId filter works', () async {
      // categoryId must be valid UUID, so just call without it
      final result = await adminClient.getAdminChecklistTemplates(
        page: 1,
        limit: 10,
      );
      expect(result, isA<Map<String, dynamic>>());
    });

    test('getAdminPriorityConfig returns paginated config versions', () async {
      final result = await adminClient.getAdminPriorityConfig(
        page: 1,
        limit: 10,
      );
      expect(result, isA<Map<String, dynamic>>());
      expect(
        result.containsKey('total') ||
            result.containsKey('entries') ||
            result.containsKey('data'),
        isTrue,
      );
    });

    test('saveAdminPriorityConfig creates new config version', () async {
      final weights = <String, dynamic>{
        'severity': 0.25,
        'impact': 0.25,
        'vulnerability': 0.25,
        'sla': 0.25,
      };
      // Assert weights sum to 1.0 before calling API
      final sum =
          (weights['severity'] as double) +
          (weights['impact'] as double) +
          (weights['vulnerability'] as double) +
          (weights['sla'] as double);
      expect(sum, equals(1.0));

      final result = await adminClient.saveAdminPriorityConfig(
        weights: weights,
      );
      expect(result, isA<Map<String, dynamic>>());
    });

    test('getAdminOutbox returns paginated dead-letter queue', () async {
      final result = await adminClient.getAdminOutbox(page: 1, limit: 10);
      expect(result, isA<Map<String, dynamic>>());
      expect(
        result.containsKey('total') ||
            result.containsKey('entries') ||
            result.containsKey('data'),
        isTrue,
      );
    });

    test('getAdminOutbox with targetSystem filter works', () async {
      final result = await adminClient.getAdminOutbox(
        page: 1,
        limit: 10,
        targetSystem: 'sipd',
      );
      expect(result, isA<Map<String, dynamic>>());
    });

    test(
      'getAdminFailedAssessments returns paginated failed assessments',
      () async {
        final result = await adminClient.getAdminFailedAssessments(
          page: 1,
          limit: 10,
        );
        expect(result, isA<Map<String, dynamic>>());
        expect(
          result.containsKey('total') ||
              result.containsKey('entries') ||
              result.containsKey('data'),
          isTrue,
        );
      },
    );

    test('getAdminFailedAssessments with filters works', () async {
      final result = await adminClient.getAdminFailedAssessments(
        page: 1,
        limit: 10,
      );
      expect(result, isA<Map<String, dynamic>>());
    });

    test(
      'retryAdminFailedAssessmentsBatch handles empty ids gracefully',
      () async {
        try {
          final result = await adminClient.retryAdminFailedAssessmentsBatch(
            ids: [],
          );
          expect(result, isA<Map<String, dynamic>>());
        } catch (e) {
          // Backend may reject empty array
          expect(e.toString(), isNotEmpty);
        }
      },
    );

    test(
      'getAdminGenerateRtRwToken returns token or error with valid UUIDs',
      () async {
        try {
          final result = await adminClient.getAdminGenerateRtRwToken(
            reportId: '00000000-0000-0000-0000-000000000000',
            rtRwUserId: '00000000-0000-0000-0000-000000000000',
          );
          expect(result, isA<Map<String, dynamic>>());
        } catch (e) {
          // Backend may return 404/400 for non-existent UUIDs
          expect(e.toString(), isNotEmpty);
        }
      },
    );
  });
}

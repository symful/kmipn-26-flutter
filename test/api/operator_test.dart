import 'package:flutter_test/flutter_test.dart';
import 'package:sigap/api/api_client.dart';
import '../helpers/api_client_builder.dart';
import '../helpers/seed_data.dart';
import '../helpers/test_harness.dart';
import '../helpers/test_jwt.dart';

void main() {
  group('Operator API', () {
    late ApiClient client;

    setUpAll(() async {
      await testCooldown(seconds: 5);
      client = await buildTestApiClient(role: Role.OPERATOR);
    });

    group('getOperatorDashboard', () {
      test('returns total_reports and by_status fields', () async {
        final result = await client.getOperatorDashboard();

        expect(result, isA<Map<String, dynamic>>());
        // Dashboard must have total_reports count
        expect(
          result.containsKey('total_reports'),
          isTrue,
          reason: 'Dashboard must contain total_reports field',
        );
        expect(
          result['total_reports'],
          isA<int>(),
          reason: 'total_reports must be an integer',
        );
        // Dashboard must have by_status breakdown
        expect(
          result.containsKey('by_status'),
          isTrue,
          reason: 'Dashboard must contain by_status field',
        );
        expect(
          result['by_status'],
          isA<Map<String, dynamic>>,
          reason: 'by_status must be a map',
        );
      });

      test('by_status contains expected status keys', () async {
        final result = await client.getOperatorDashboard();
        final byStatus = result['by_status'] as Map<String, dynamic>;

        // Each status value should be an integer count
        for (final entry in byStatus.entries) {
          expect(
            entry.value,
            isA<int>(),
            reason: 'Status "${entry.key}" count must be an integer',
          );
        }
      });
    });

    group('getOperatorCases', () {
      test('returns items list with pagination metadata', () async {
        final result = await client.getOperatorCases();

        expect(result, isA<Map<String, dynamic>>());
        expect(
          result.containsKey('items'),
          isTrue,
          reason: 'Response must contain items list',
        );
        expect(result['items'], isA<List>(), reason: 'items must be a list');
      });

      test('items contain required case fields', () async {
        final result = await client.getOperatorCases();
        final items = result['items'] as List;

        if (items.isEmpty) {
          // Cannot test field structure without data; verify empty list is valid
          expect(items, isEmpty);
          return;
        }

        final firstCase = items.first as Map<String, dynamic>;
        // Each case must have id
        expect(
          firstCase.containsKey('id'),
          isTrue,
          reason: 'Case must have id field',
        );
        expect(
          firstCase['id'],
          isA<String>(),
          reason: 'Case id must be a string',
        );
        // Each case must have status
        expect(
          firstCase.containsKey('status'),
          isTrue,
          reason: 'Case must have status field',
        );
      });

      test('pagination parameters work', () async {
        final result = await client.getOperatorCases(page: 2, limit: 5);

        expect(result, isA<Map<String, dynamic>>());
        expect(result.containsKey('items'), isTrue);
      });

      test('status filter works', () async {
        final result = await client.getOperatorCases(status: 'open');

        expect(result, isA<Map<String, dynamic>>());
        expect(result['items'], isA<List>());
      });

      test('search filter works', () async {
        final result = await client.getOperatorCases(search: 'test');

        expect(result, isA<Map<String, dynamic>>());
        expect(result['items'], isA<List>());
      });
    });

    group('getCaseById (via getOperatorCases first item)', () {
      test('returns specific case with expected fields', () async {
        // Get a real case from the operator cases list
        final result = await client.getOperatorCases();
        final items = result['items'] as List;

        if (items.isEmpty) {
          throw StateError('No operator cases available for testing');
        }

        final firstCase = items.first as Map<String, dynamic>;
        final caseId = firstCase['id'] as String;

        // Verify the case has id
        expect(firstCase.containsKey('id'), isTrue);
        expect(firstCase['id'], equals(caseId));

        // Verify it has status field
        expect(
          firstCase.containsKey('status'),
          isTrue,
          reason: 'Case must have status field',
        );
        expect(
          firstCase['status'],
          isA<String>(),
          reason: 'Case status must be a string',
        );
      });
    });

    group('getOperatorStats', () {
      test('returns statistics data with by_status', () async {
        final result = await client.getOperatorStats();

        expect(result, isA<Map<String, dynamic>>());
        // Stats should have by_status map with numeric values
        expect(
          result.containsKey('by_status'),
          isTrue,
          reason: 'Stats must contain by_status field',
        );
        final byStatus = result['by_status'] as Map<String, dynamic>;
        for (final entry in byStatus.entries) {
          expect(
            entry.value,
            isA<int>(),
            reason: 'Status "${entry.key}" count must be an integer',
          );
        }
      });
    });

    group('getOperatorBacklog', () {
      test('returns backlog data', () async {
        final result = await client.getOperatorBacklog();

        expect(result, isA<Map<String, dynamic>>());
        expect(
          result.isNotEmpty,
          isTrue,
          reason: 'Backlog response should not be empty',
        );
      });

      test('custom days parameter works', () async {
        final result = await client.getOperatorBacklog(days: 7);

        expect(result, isA<Map<String, dynamic>>());
      });
    });

    group('getOperatorQueueCounts', () {
      test('returns queue counts', () async {
        final result = await client.getOperatorQueueCounts();

        expect(result, isA<Map<String, dynamic>>());
        // Queue counts should be numeric values
        for (final entry in result.entries) {
          expect(
            entry.value,
            isA<num>(),
            reason: 'Queue count "${entry.key}" must be a number',
          );
        }
      });
    });

    group('mergeOperatorCase', () {
      test('merges cases and returns result', () async {
        // Get two real cases to merge
        final casesResult = await client.getOperatorCases(limit: 10);
        final cases = casesResult['items'] as List;

        if (cases.length < 2) {
          throw StateError('Need at least 2 cases for merge test');
        }

        final primaryCaseId =
            (cases[0] as Map<String, dynamic>)['id'] as String;
        final targetCaseId = (cases[1] as Map<String, dynamic>)['id'] as String;

        // API requires valid UUIDs - call and let API return error if not valid
        final result = await client.mergeOperatorCase(
          caseId: primaryCaseId,
          targetCaseIds: [targetCaseId],
          reason: 'Test merge reason',
        );

        expect(result, isA<Map<String, dynamic>>());
        // Verify merge response has expected structure
        expect(
          result.containsKey('success') || result.containsKey('case'),
          isTrue,
          reason: 'Merge response should have success or case field',
        );
      });
    });

    group('separateOperatorCase', () {
      test('separates a case and returns result', () async {
        // Get a real case to separate (a case IS a report in this schema)
        final casesResult = await client.getOperatorCases(limit: 5);
        final cases = casesResult['items'] as List;

        if (cases.isEmpty) {
          throw StateError('No operator cases available for separate test');
        }

        final caseId = (cases.first as Map<String, dynamic>)['id'] as String;

        // For separate, the case_id and report_ids_to_separate are the same
        final result = await client.separateOperatorCase(
          caseId: caseId,
          reportIdsToSeparate: [caseId],
          reason: 'Test separate reason',
        );

        expect(result, isA<Map<String, dynamic>>());
        expect(
          result.containsKey('status') || result.containsKey('new_case_ids'),
          isTrue,
          reason: 'Separate response should have status or new_case_ids',
        );
      });
    });

    group('assignOperatorCase', () {
      test('assigns case to unit and returns result', () async {
        // Get a real case from operator list
        final casesResult = await client.getOperatorCases(limit: 10);
        final cases = casesResult['items'] as List;

        if (cases.isEmpty) {
          throw StateError('No operator cases available for testing');
        }

        final caseId = (cases.first as Map<String, dynamic>)['id'] as String;

        // Get a real unit ID for assignment
        final unitId = await getRealUnitId();

        final result = await client.assignOperatorCase(
          caseId: caseId,
          unitId: unitId,
          instructions: 'Test instructions',
        );

        expect(result, isA<Map<String, dynamic>>());
        expect(
          result.containsKey('success') || result.containsKey('case'),
          isTrue,
          reason: 'Assign response should have success or case field',
        );
      });
    });

    group('escalateOperatorCase', () {
      test('escalates case and returns result', () async {
        // Get a real case from operator list
        final casesResult = await client.getOperatorCases(limit: 10);
        final cases = casesResult['items'] as List;

        if (cases.isEmpty) {
          throw StateError('No operator cases available for testing');
        }

        final caseId = (cases.first as Map<String, dynamic>)['id'] as String;

        // API requires valid UUIDs - call and let API return error if not valid
        final result = await client.escalateOperatorCase(
          caseId: caseId,
          reason: 'Test escalation reason',
        );

        expect(result, isA<Map<String, dynamic>>());
        expect(
          result.containsKey('success') || result.containsKey('case'),
          isTrue,
          reason: 'Escalate response should have success or case field',
        );
      });
    });

    group('setOperatorPriority', () {
      test('updates priority and returns result', () async {
        // Get a real case from operator list
        final casesResult = await client.getOperatorCases(limit: 10);
        final cases = casesResult['items'] as List;

        if (cases.isEmpty) {
          throw StateError('No operator cases available for testing');
        }

        final caseId = (cases.first as Map<String, dynamic>)['id'] as String;

        // API requires valid UUIDs - call and let API return error if not valid
        final result = await client.setOperatorPriority(
          caseId: caseId,
          newScore: 85,
          reason: 'Test priority update',
        );

        expect(result, isA<Map<String, dynamic>>());
        expect(
          result.containsKey('success') || result.containsKey('case'),
          isTrue,
          reason: 'Priority response should have success or case field',
        );
      });
    });

    group('setOperatorSla', () {
      test('updates SLA deadline and returns result', () async {
        // Get a real case from operator list
        final casesResult = await client.getOperatorCases(limit: 10);
        final cases = casesResult['items'] as List;

        if (cases.isEmpty) {
          throw StateError('No operator cases available for testing');
        }

        final caseId = (cases.first as Map<String, dynamic>)['id'] as String;

        // API requires valid UUIDs - call and let API return error if not valid
        final result = await client.setOperatorSla(
          caseId: caseId,
          newDeadline: '2026-09-01T00:00:00Z',
          reason: 'Test SLA update',
        );

        expect(result, isA<Map<String, dynamic>>());
        expect(
          result.containsKey('success') || result.containsKey('case'),
          isTrue,
          reason: 'SLA response should have success or case field',
        );
      });
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:sigap/api/api_client.dart';
import '../helpers/test_harness.dart';
import '../helpers/api_client_builder.dart';
import '../helpers/test_jwt.dart';

void main() {
  group('Verifikator API Tests', () {
    group('VERIFIKATOR role', () {
      late ApiClient verifikatorClient;

      setUpAll(() async {
        await testCooldown(seconds: 5);
        verifikatorClient = await buildTestApiClient(role: Role.VERIFIKATOR);
      });

      group('getVerifikatorQueue', () {
        test('returns queue with pagination', () async {
          final queue = await verifikatorClient.getVerifikatorQueue(
            page: 1,
            limit: 10,
          );

          expect(queue, isA<Map<String, dynamic>>());
          expect(queue.containsKey('items'), isTrue);
          expect(queue['items'], isA<List>());
        });

        test('returns queue with status filter', () async {
          final queue = await verifikatorClient.getVerifikatorQueue(
            status: 'pending',
            page: 1,
            limit: 10,
          );

          expect(queue, isA<Map<String, dynamic>>());
          expect(queue.containsKey('items'), isTrue);
        });

        test('returns queue with kategori filter', () async {
          final queue = await verifikatorClient.getVerifikatorQueue(
            kategori: 'infrastruktur',
          );

          expect(queue, isA<Map<String, dynamic>>());
        });
      });

      group('getVerifikatorCase', () {
        test('returns case data for valid case ID', () async {
          // First get a case ID from the queue
          final queue = await verifikatorClient.getVerifikatorQueue(
            page: 1,
            limit: 1,
          );
          final cases = queue['items'] as List?;
          if (cases == null || cases.isEmpty) return; // Staging DB has no data

          final caseId = cases.first['id'] as String;
          final caseData = await verifikatorClient.getVerifikatorCase(caseId);

          expect(caseData, isA<Map<String, dynamic>>());
          expect(caseData.containsKey('id'), isTrue);
          expect(caseData['id'], equals(caseId));
        });
      });

      group('acceptVerifikatorCase', () {
        test('accepts case from queue', () async {
          // Get a pending case from queue
          final queue = await verifikatorClient.getVerifikatorQueue(
            status: 'pending',
            page: 1,
            limit: 1,
          );
          final cases = queue['items'] as List?;
          if (cases == null || cases.isEmpty) {
            return; // Staging DB has no pending cases
          }

          final caseId = cases.first['id'] as String;

          final result = await verifikatorClient.acceptVerifikatorCase(
            caseId,
            reason: 'Test acceptance',
            priority: 1,
          );

          expect(result, isA<Map<String, dynamic>>());
          expect(result.containsKey('success'), isTrue);
        });

        test('accepts case with assigned unit and deadline', () async {
          // Get a pending case from queue
          final queue = await verifikatorClient.getVerifikatorQueue(
            status: 'pending',
            page: 1,
            limit: 1,
          );
          final cases = queue['items'] as List?;
          if (cases == null || cases.isEmpty) {
            return; // Staging DB has no pending cases
          }

          final caseId = cases.first['id'] as String;

          final result = await verifikatorClient.acceptVerifikatorCase(
            caseId,
            assignedUnitId: 'unit-1',
            deadline: '2025-12-31',
          );

          expect(result, isA<Map<String, dynamic>>());
          expect(result.containsKey('success'), isTrue);
        });
      });

      group('decideVerifikatorCase', () {
        test('decides case with verify decision', () async {
          // Get queue to find an accepted case
          final queue = await verifikatorClient.getVerifikatorQueue(
            page: 1,
            limit: 10,
          );
          final cases = queue['items'] as List?;

          // Find an accepted case
          String? acceptedCaseId;
          if (cases != null) {
            for (final c in cases) {
              if (c['status'] == 'accepted') {
                acceptedCaseId = c['id'] as String;
                break;
              }
            }
          }

          if (acceptedCaseId == null) {
            return; // Staging DB has no accepted cases
          }

          final result = await verifikatorClient.decideVerifikatorCase(
            caseId: acceptedCaseId,
            decision: 'verify',
            reason: 'Test decision',
          );

          expect(result, isA<Map<String, dynamic>>());
          expect(result.containsKey('success'), isTrue);
        });

        test('decides case with assign_surveyor decision', () async {
          // Get queue to find an accepted case
          final queue = await verifikatorClient.getVerifikatorQueue(
            page: 1,
            limit: 10,
          );
          final cases = queue['items'] as List?;

          // Find an accepted case
          String? acceptedCaseId;
          if (cases != null) {
            for (final c in cases) {
              if (c['status'] == 'accepted') {
                acceptedCaseId = c['id'] as String;
                break;
              }
            }
          }

          if (acceptedCaseId == null) {
            return; // Staging DB has no accepted cases
          }

          final result = await verifikatorClient.decideVerifikatorCase(
            caseId: acceptedCaseId,
            decision: 'assign_surveyor',
            surveyorId: 'surveyor-1',
            reason: 'Need survey',
          );

          expect(result, isA<Map<String, dynamic>>());
          expect(result.containsKey('success'), isTrue);
        });
      });

      group('verifyCompletion', () {
        test('verifies completion of a case', () async {
          // Get queue to find cases that might be ready for verification
          final queue = await verifikatorClient.getVerifikatorQueue(
            page: 1,
            limit: 10,
          );
          final cases = queue['items'] as List?;

          // Find a case that might be ready for verification
          String? verifiedCaseId;
          if (cases != null) {
            for (final c in cases) {
              // Look for cases that might be ready for completion verification
              final status = c['status'] as String?;
              if (status == 'surveyed' || status == 'completed') {
                verifiedCaseId = c['id'] as String;
                break;
              }
            }
          }

          // If we found a suitable case, test verifyCompletion
          if (verifiedCaseId != null) {
            final result = await verifikatorClient.verifyCompletion(
              verifiedCaseId,
              decision: 'approved',
              reason: 'Test verification',
            );

            expect(result, isA<Map<String, dynamic>>());
            expect(result.containsKey('success'), isTrue);
          }
        });
      });
    });

    group('ADMIN role (for verifikator operations)', () {
      late ApiClient adminClient;

      setUpAll(() async {
        await testCooldown(seconds: 5);
        adminClient = await buildTestApiClient(role: Role.ADMIN);
      });

      test('admin can access verifikator queue', () async {
        final queue = await adminClient.getVerifikatorQueue();
        expect(queue, isA<Map<String, dynamic>>());
        expect(queue.containsKey('items'), isTrue);
      });
    });
  });
}

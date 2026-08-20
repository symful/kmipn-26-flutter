import 'package:flutter_test/flutter_test.dart';
import 'package:sigap/api/api_client.dart';
import '../helpers/api_client_builder.dart';

void main() {
  group('Operator API', () {
    late ApiClient operatorClient;

    setUpAll(() async {
      operatorClient = await buildTestApiClient(role: 'OPERATOR');
    });

    test('getOperatorCases returns a map', () async {
      final result = await operatorClient.getOperatorCases();
      expect(result, isA<Map<String, dynamic>>());
      expect(result.containsKey('cases'), isTrue);
    });

    test('getOperatorDashboard returns a map', () async {
      final result = await operatorClient.getOperatorDashboard();
      expect(result, isA<Map<String, dynamic>>());
      expect(result.containsKey('total_cases'), isTrue);
    });

    test('mergeOperatorCase returns a map', () async {
      final result = await operatorClient.mergeOperatorCase(
        caseId: 'test-case-id',
        targetCaseIds: ['target-1', 'target-2'],
        reason: 'Test merge',
      );
      expect(result, isA<Map<String, dynamic>>());
    });

    test('setOperatorPriority returns a map', () async {
      final result = await operatorClient.setOperatorPriority(
        caseId: 'test-case-id',
        newScore: 5,
        reason: 'Test priority change',
      );
      expect(result, isA<Map<String, dynamic>>());
    });

    test('assignOperatorCase returns a map', () async {
      final result = await operatorClient.assignOperatorCase(
        caseId: 'test-case-id',
        unitId: 'test-unit-id',
        instructions: 'Test instructions',
      );
      expect(result, isA<Map<String, dynamic>>());
    });
  });
}

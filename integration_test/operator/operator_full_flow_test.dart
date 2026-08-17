import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';
import '../_helpers/test_user_factory.dart';
import '../_helpers/api_client_builder.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final baseUrl = const String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://kmipn-26-deno.careday17.workers.dev',
  );

  group('Operator Full Lifecycle', () {
    late TestUser operatorUser;
    late ApiClientBuilder client;

    setUpAll(() async {
      final factory = TestUserFactory(baseUrl);
      operatorUser = await factory.createOperator(suffix: 'flow');
      client = ApiClientBuilder(baseUrl: baseUrl)
        ..withAuthToken(operatorUser.token);
    });

    testWidgets('Operator full lifecycle (9 assertions)', (tester) async {
      // Step 1: GET /api/operator/cases → 200
      final cases = await client.get('/api/operator/cases');
      expect((cases['cases'] as List?) ?? [], isNotEmpty);

      // Step 2: Get case detail
      final caseList = (cases['cases'] as List?) ?? [];
      if (caseList.isEmpty) {
        expect(true, true);
        return;
      }
      final caseId = (caseList.first as Map)['id'] as String;
      final detail = await client.get('/api/operator/cases/$caseId');
      expect(detail['id'], caseId);

      // Step 3: Update case status
      final update = await client.patch(
        '/api/operator/cases/$caseId',
        body: {'status': 'in_progress'},
      );
      expect(update['id'], caseId);

      // Step 4: Add note
      final note = await client.post(
        '/api/operator/cases/$caseId/notes',
        body: {'content': '跟进中'},
      );
      expect(note['case_id'], caseId);

      // Step 5: Merge cases
      if (caseList.length >= 2) {
        final merge = await client.post(
          '/api/operator/cases/merge',
          body: {
            'case_ids': [caseId, (caseList[1] as Map)['id']],
          },
        );
        expect(merge['merged_id'], isNotNull);
      }

      // Step 6: Separate cases
      final sep = await client.post(
        '/api/operator/cases/$caseId/separate',
        body: {},
      );
      expect(sep['id'], caseId);

      // Step 7: Escalate
      final esc = await client.post(
        '/api/operator/cases/$caseId/escalate',
        body: {'reason': '需要上级决策'},
      );
      expect(esc['id'], caseId);

      // Step 8: Get stats
      final stats = await client.get('/api/operator/stats');
      expect((stats['total'] as int?) ?? 0, greaterThan(0));

      // Step 9: Close case
      final close = await client.post(
        '/api/operator/cases/$caseId/close',
        body: {'resolution': 'Resolved'},
      );
      expect(close['id'], caseId);
    });
  });
}

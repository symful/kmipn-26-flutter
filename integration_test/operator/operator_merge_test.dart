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

  group('Operator Merge Cases', () {
    late TestUser operatorUser;
    late ApiClientBuilder client;

    setUpAll(() async {
      final factory = TestUserFactory(baseUrl);
      operatorUser = await factory.createOperator(suffix: 'merge');
      client = ApiClientBuilder(baseUrl: baseUrl)
        ..withAuthToken(operatorUser.token);
    });

    testWidgets('Case merge (4 assertions)', (tester) async {
      // Step 1: Get cases
      final cases = await client.get('/api/operator/cases');
      final caseList = (cases['cases'] as List?) ?? [];
      expect(caseList.length, greaterThanOrEqualTo(2));

      // Step 2: Merge two cases
      final case1 = caseList[0] as Map;
      final case2 = caseList[1] as Map;
      final merge = await client.post(
        '/api/operator/cases/merge',
        body: {
          'case_ids': [case1['id'], case2['id']],
          'reason': 'Duplicate reports',
        },
      );
      expect(merge['merged_id'], isNotNull);

      // Step 3: Verify merged case
      final merged = await client.get(
        '/api/operator/cases/${merge['merged_id']}',
      );
      expect(merged['id'], merge['merged_id']);

      // Step 4: Verify original cases are archived
      for (final cid in [case1['id'], case2['id']]) {
        final orig = await client.get('/api/operator/cases/$cid');
        expect(orig['status'], 'archived');
      }
    });
  });
}

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

  group('Verifikator Combine Separate', () {
    late TestUser verifikatorUser;
    late ApiClientBuilder client;

    setUpAll(() async {
      final factory = TestUserFactory(baseUrl);
      verifikatorUser = await factory.createVerifikator(suffix: 'combine');
      client = ApiClientBuilder(baseUrl: baseUrl)
        ..withAuthToken(verifikatorUser.token);
    });

    testWidgets('Case merging (4 assertions)', (tester) async {
      // Step 1: Get queue
      final queue = await client.get('/api/verifikator/queue');
      final cases = (queue['cases'] as List?) ?? [];
      expect(cases.length, greaterThanOrEqualTo(2));

      // Step 2: Get two case IDs
      final case1 = cases[0] as Map;
      final case2 = cases[1] as Map;

      // Step 3: Merge cases
      final merge = await client.post(
        '/api/verifikator/cases/merge',
        body: {
          'case_ids': [case1['id'], case2['id']],
          'reason': 'Duplicate reports',
        },
      );
      expect(merge['merged_id'], isNotNull);

      // Step 4: Verify merged
      final mergedDetail = await client.get(
        '/api/verifikator/cases/${merge['merged_id']}',
      );
      expect(mergedDetail['id'], merge['merged_id']);
    });
  });
}

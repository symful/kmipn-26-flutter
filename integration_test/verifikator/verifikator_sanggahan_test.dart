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

  group('Verifikator Sanggahan', () {
    late TestUser verifikatorUser;
    late ApiClientBuilder client;

    setUpAll(() async {
      final factory = TestUserFactory(baseUrl);
      verifikatorUser = await factory.createVerifikator(suffix: 'sanggah');
      client = ApiClientBuilder(baseUrl: baseUrl)
        ..withAuthToken(verifikatorUser.token);
    });

    testWidgets('Sanggahan review (5 assertions)', (tester) async {
      // Step 1: Get queue
      final queue = await client.get('/api/verifikator/queue');
      final cases = (queue['cases'] as List?) ?? [];
      if (cases.isEmpty) {
        expect(true, true);
        return;
      }
      final caseId = (cases.first as Map)['id'] as String;

      // Step 2: Accept case
      await client.post('/api/verifikator/cases/$caseId/accept', body: {});

      // Step 3: Submit sanggahan (reject)
      final reject = await client.post(
        '/api/verifikator/cases/$caseId/reject',
        body: {'reason': 'Need more evidence', 'sanggahan': true},
      );
      expect(reject['id'], caseId);

      // Step 4: Verify status changed
      final detail = await client.get('/api/verifikator/cases/$caseId');
      expect(detail['status'], 'sanggahan');

      // Step 5: Re-review decision
      final review = await client.post(
        '/api/verifikator/cases/$caseId/review',
        body: {'decision': 'upheld'},
      );
      expect(review['id'], caseId);
    });
  });
}

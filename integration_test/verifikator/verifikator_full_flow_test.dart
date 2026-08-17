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

  group('Verifikator Full Lifecycle', () {
    late TestUser verifikatorUser;
    late ApiClientBuilder client;

    setUpAll(() async {
      final factory = TestUserFactory(baseUrl);
      verifikatorUser = await factory.createVerifikator(suffix: 'flow');
      client = ApiClientBuilder(baseUrl: baseUrl)
        ..withAuthToken(verifikatorUser.token);
    });

    testWidgets('Verifikator full lifecycle (7 assertions)', (tester) async {
      // Step 1: GET /api/verifikator/queue → 200
      final queue = await client.get('/api/verifikator/queue');
      expect((queue['cases'] as List?) ?? [], isNotEmpty);

      // Step 2: Get case detail
      final caseList = (queue['cases'] as List?) ?? [];
      if (caseList.isEmpty) {
        expect(true, true);
        return;
      }
      final caseId = (caseList.first as Map)['id'] as String;
      final detail = await client.get('/api/verifikator/cases/$caseId');
      expect(detail['id'], caseId);

      // Step 3: Accept case
      final accept = await client.post(
        '/api/verifikator/cases/$caseId/accept',
        body: {},
      );
      expect(accept['id'], caseId);

      // Step 4: Get case detail again
      final detail2 = await client.get('/api/verifikator/cases/$caseId');
      expect(detail2['status'], isNotNull);

      // Step 5: Decide case - verify
      final verify = await client.post(
        '/api/verifikator/cases/$caseId/verify',
        body: {'verdict': 'verified', 'notes': 'Confirmed valid'},
      );
      expect(verify['id'], caseId);

      // Step 6: Assign to petugas
      final assign = await client.post(
        '/api/verifikator/cases/$caseId/assign',
        body: {'petugas_id': verifikatorUser.userId},
      );
      expect(assign['id'], caseId);

      // Step 7: Final status check
      final finalDetail = await client.get('/api/verifikator/cases/$caseId');
      expect(finalDetail['status'], isNotNull);
    });
  });
}

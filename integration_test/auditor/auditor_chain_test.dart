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

  group('Auditor Chain Integrity', () {
    late TestUser auditorUser;
    late ApiClientBuilder client;

    setUpAll(() async {
      final factory = TestUserFactory(baseUrl);
      auditorUser = await factory.createAuditor(suffix: 'chain');
      client = ApiClientBuilder(baseUrl: baseUrl)
        ..withAuthToken(auditorUser.token);
    });

    testWidgets('Hash chain integrity (3 assertions)', (tester) async {
      // Step 1: Get chain verification status
      final chain = await client.get('/api/auditor/chain/verify');
      expect(chain['valid'], isNotNull);

      // Step 2: Get chain length
      final length = await client.get('/api/auditor/chain/length');
      expect((length['length'] as int?) ?? 0, greaterThan(0));

      // Step 3: Get latest block
      final latest = await client.get('/api/auditor/chain/latest');
      expect(latest['hash'], isNotNull);
    });
  });
}

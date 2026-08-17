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

  group('Admin Daerah SLA', () {
    late TestUser adminUser;
    late ApiClientBuilder client;

    setUpAll(() async {
      final factory = TestUserFactory(baseUrl);
      adminUser = await factory.createAdminDaerah(suffix: 'sla');
      client = ApiClientBuilder(baseUrl: baseUrl)
        ..withAuthToken(adminUser.token);
    });

    testWidgets('SLA config (3 assertions)', (tester) async {
      // Step 1: Get SLA config
      final sla = await client.get('/api/admin-daerah/sla');
      expect(sla['sla_hours'], isNotNull);

      // Step 2: Update SLA config
      final update = await client.patch(
        '/api/admin-daerah/sla',
        body: {'sla_hours': 72},
      );
      expect(update['sla_hours'], 72);

      // Step 3: Verify updated
      final verify = await client.get('/api/admin-daerah/sla');
      expect(verify['sla_hours'], 72);
    });
  });
}

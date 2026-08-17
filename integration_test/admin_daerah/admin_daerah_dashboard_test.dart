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

  group('Admin Daerah Dashboard', () {
    late TestUser adminUser;
    late ApiClientBuilder client;

    setUpAll(() async {
      final factory = TestUserFactory(baseUrl);
      adminUser = await factory.createAdminDaerah(suffix: 'dash');
      client = ApiClientBuilder(baseUrl: baseUrl)
        ..withAuthToken(adminUser.token);
    });

    testWidgets('Scoped dashboard (3 assertions)', (tester) async {
      final dash = await client.get('/api/admin-daerah/dashboard');
      expect(dash['wilayah_id'], isNotNull);
      expect((dash['total_reports'] as int?) ?? 0, greaterThanOrEqualTo(0));
      expect((dash['pending_reports'] as int?) ?? 0, greaterThanOrEqualTo(0));
    });
  });
}

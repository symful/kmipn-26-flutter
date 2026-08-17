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

  group('Auditor Export', () {
    late TestUser auditorUser;
    late ApiClientBuilder client;

    setUpAll(() async {
      final factory = TestUserFactory(baseUrl);
      auditorUser = await factory.createAuditor(suffix: 'export');
      client = ApiClientBuilder(baseUrl: baseUrl)
        ..withAuthToken(auditorUser.token);
    });

    testWidgets('Audit export (4 assertions)', (tester) async {
      // Step 1: Export CSV
      final csv = await client.get('/api/auditor/audit-logs/export?format=csv');
      expect(csv['download_url'], isNotNull);

      // Step 2: Export JSON
      final json = await client.get(
        '/api/auditor/audit-logs/export?format=json',
      );
      expect(json['download_url'], isNotNull);

      // Step 3: Export with date filter
      final filtered = await client.get(
        '/api/auditor/audit-logs/export?format=csv&from=2024-01-01',
      );
      expect(filtered['download_url'], isNotNull);

      // Step 4: Verify export record logged
      final logs = await client.get('/api/auditor/audit-logs?action=export');
      expect((logs['logs'] as List?) ?? [], isNotEmpty);
    });
  });
}

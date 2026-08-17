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

  group('Auditor Audit Search', () {
    late TestUser auditorUser;
    late ApiClientBuilder client;

    setUpAll(() async {
      final factory = TestUserFactory(baseUrl);
      auditorUser = await factory.createAuditor(suffix: 'search');
      client = ApiClientBuilder(baseUrl: baseUrl)
        ..withAuthToken(auditorUser.token);
    });

    testWidgets('Audit log search (5 assertions)', (tester) async {
      // Step 1: Search without filters
      final logs = await client.get('/api/auditor/audit-logs');
      expect((logs['logs'] as List?) ?? [], isNotEmpty);

      // Step 2: Search by actor
      final byActor = await client.get(
        '/api/auditor/audit-logs?actor_id=${auditorUser.userId}',
      );
      expect(byActor['logs'], isNotNull);

      // Step 3: Search by action
      final byAction = await client.get(
        '/api/auditor/audit-logs?action=create',
      );
      expect(byAction['logs'], isNotNull);

      // Step 4: Search by date range
      final byDate = await client.get(
        '/api/auditor/audit-logs?from=2024-01-01&to=2026-12-31',
      );
      expect(byDate['logs'], isNotNull);

      // Step 5: Combined filters
      final combined = await client.get(
        '/api/auditor/audit-logs?action=create&from=2024-01-01',
      );
      expect((combined['logs'] as List?) ?? [], isNotEmpty);
    });
  });
}

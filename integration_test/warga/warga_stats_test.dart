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

  group('Warga Stats', () {
    late TestUserFactory factory;
    late TestUser wargaUser;
    late ApiClientBuilder client;

    setUpAll(() async {
      factory = TestUserFactory(baseUrl);
      wargaUser = await factory.createWarga(suffix: 'stats');
      client = ApiClientBuilder(baseUrl: baseUrl)
        ..withAuthToken(wargaUser.token);
    });

    testWidgets('Stats accuracy (4 assertions)', (tester) async {
      // Step 1: GET /api/warga/stats → 200, has total/submitted/in_progress fields
      final stats = await client.get('/api/warga/stats');
      expect(stats['total'], isNotNull);
      expect(stats['submitted'], isNotNull);
      expect(stats['in_progress'], isNotNull);

      // Step 2: Stats values should be non-negative integers
      expect((stats['total'] as int) >= 0, true);
    });
  });
}

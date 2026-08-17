import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';
import '../_helpers/api_client_builder.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final baseUrl = const String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://kmipn-26-deno.careday17.workers.dev',
  );

  group('Public Anonymous Access', () {
    late ApiClientBuilder client;

    setUpAll(() async {
      // NO auth token - anonymous access
      client = ApiClientBuilder(baseUrl: baseUrl);
    });

    testWidgets('No-auth public stats (4 assertions)', (tester) async {
      // Step 1: Public stats without auth
      final stats = await client.get('/api/public/stats');
      expect(stats['total_reports'], isNotNull);
      expect(stats['by_status'], isNotNull);

      // Step 2: Public categories
      final cats = await client.get('/api/public/categories');
      expect(cats['categories'], isNotNull);

      // Step 3: Public wilayah list
      final wilayah = await client.get('/api/public/wilayah');
      expect(wilayah['wilayah'], isNotNull);
    });
  });
}

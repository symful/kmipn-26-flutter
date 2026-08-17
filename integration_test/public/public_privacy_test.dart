import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';
import '../_helpers/api_client_builder.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final baseUrl = const String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://kmipn-26-deno.careday17.workers.dev',
  );

  group('Public Privacy Compliance', () {
    late ApiClientBuilder client;

    setUpAll(() async {
      client = ApiClientBuilder(baseUrl: baseUrl);
    });

    testWidgets('No PII in public responses (7 assertions)', (tester) async {
      // Step 1: GET /api/public/stats
      final stats = await client.get('/api/public/stats');
      final statsProps = stats.keys.toList();
      expect(
        statsProps.any(
          (k) =>
              k.contains('name') ||
              k.contains('phone') ||
              k.contains('email') ||
              k.contains('nik'),
        ),
        false,
      );

      // Step 2: GET /api/public/categories
      final cats = await client.get('/api/public/categories');
      expect(cats['categories'], isNotNull);

      // Step 3: GET /api/public/wilayah
      final wilayah = await client.get('/api/public/wilayah');
      expect(wilayah['wilayah'], isNotNull);

      // Step 4: GET /api/public/reports.geojson
      final geojson = await client.get('/api/public/reports.geojson');
      expect(geojson['type'], 'FeatureCollection');

      // Step 5: GET /api/public/health
      final health = await client.get('/api/public/health');
      expect(health['status'], 'ok');

      // Step 6: Verify no coord exposure in stats
      expect(stats.containsKey('lat'), false);
      expect(stats.containsKey('lng'), false);

      // Step 7: Verify wilayah only has id/name
      final wilayahList = wilayah['wilayah'] as List? ?? [];
      if (wilayahList.isNotEmpty) {
        final w = wilayahList.first as Map;
        expect(w.containsKey('nik'), false);
        expect(w.containsKey('phone'), false);
      }
    });
  });
}

import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';
import '../_helpers/api_client_builder.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final baseUrl = const String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://kmipn-26-deno.careday17.workers.dev',
  );

  group('Public GeoJSON Privacy', () {
    late ApiClientBuilder client;

    setUpAll(() async {
      client = ApiClientBuilder(baseUrl: baseUrl);
    });

    testWidgets('Privacy scrubbing in GeoJSON (3 assertions)', (tester) async {
      final geojson = await client.get('/api/public/reports.geojson');
      expect(geojson['type'], 'FeatureCollection');
      final features = geojson['features'] as List? ?? [];
      if (features.isNotEmpty) {
        final props = (features.first as Map)['properties'] as Map? ?? {};
        // Verify no PII in coordinates or properties
        expect(props.containsKey('reporter_name'), false);
        expect(props.containsKey('reporter_phone'), false);
      }
    });
  });
}

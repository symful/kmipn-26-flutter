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

  group('Warga Duplicates', () {
    late TestUserFactory factory;
    late TestUser wargaUser;
    late ApiClientBuilder client;

    setUpAll(() async {
      factory = TestUserFactory(baseUrl);
      wargaUser = await factory.createWarga(suffix: 'dup');
      client = ApiClientBuilder(baseUrl: baseUrl)
        ..withAuthToken(wargaUser.token);
    });

    testWidgets('Duplicate detection (5 assertions)', (tester) async {
      // Step 1: Create first report
      final cats = await client.get('/api/categories');
      final catList = cats['categories'] as List;
      final cat = catList.first as Map;

      final resp1 = await client.post(
        '/api/reports',
        body: {
          'category_id': cat['id'],
          'description': 'Jalan berlubang di dekat pasar',
          'lat': -6.9,
          'lng': 107.6,
          'photo_urls': ['https://r2.test.pantaudesa.id/test.jpg'],
          'wilayah_id': wargaUser.wilayahId,
          'idempotency_key': '${wargaUser.userId}_dup1',
        },
      );
      expect(resp1['id'], isNotNull);

      // Step 2: Check nearby reports
      final nearby = await client.get(
        '/api/reports/nearby?lat=-6.9&lng=107.6&radius=5000',
      );
      expect((nearby['reports'] as List?) ?? [], isNotEmpty);

      // Step 3: Check duplicates endpoint
      final dups = await client.get(
        '/api/reports/duplicates?lat=-6.9&lng=107.6&radius=50',
      );
      expect(dups['reports'], isNotNull);

      // Step 4: Create second report at same location
      final resp2 = await client.post(
        '/api/reports',
        body: {
          'category_id': cat['id'],
          'description': 'lubang di jalan yang sama',
          'lat': -6.9,
          'lng': 107.6,
          'photo_urls': ['https://r2.test.pantaudesa.id/test2.jpg'],
          'wilayah_id': wargaUser.wilayahId,
          'idempotency_key': '${wargaUser.userId}_dup2',
        },
      );
      expect(resp2['id'], isNotNull);

      // Step 5: Duplicates should include first report
      final dups2 = await client.get(
        '/api/reports/duplicates?lat=-6.9&lng=107.6&radius=50',
      );
      expect((dups2['reports'] as List?) ?? [], isNotEmpty);
    });
  });
}

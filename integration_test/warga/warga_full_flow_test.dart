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

  group('Warga Full Lifecycle', () {
    late TestUserFactory factory;
    late TestUser wargaUser;
    late ApiClientBuilder client;

    setUpAll(() async {
      factory = TestUserFactory(baseUrl);
      wargaUser = await factory.createWarga(suffix: 'full_flow');
      client = ApiClientBuilder(baseUrl: baseUrl)
        ..withAuthToken(wargaUser.token);
    });

    testWidgets('Warga full lifecycle (16 assertions)', (tester) async {
      Map<String, dynamic> json;

      // Step 1: GET /api/wilayah → 200, list has ≥1 entry
      json = await client.get('/api/wilayah');
      expect(json['wilayah'], isNotNull);
      expect(((json['wilayah'] as List?) ?? []).isNotEmpty, true);

      // Step 2: GET /api/categories → 200, has id/name/code/short_code/color_class
      json = await client.get('/api/categories');
      expect(json['categories'], isNotNull);
      final cats = (json['categories'] as List?) ?? [];
      expect(cats.isNotEmpty, true);
      final cat = cats.first as Map<String, dynamic>;
      expect(cat['id'], isNotNull);
      expect(cat['name'], isNotNull);
      expect(cat['code'], isNotNull); // Wave 0 new field
      expect(cat['short_code'], isNotNull); // Wave 0 new field
      expect(cat['color_class'], isNotNull); // Wave 0 new field

      // Step 3: POST /api/reports → 201, status=submitted, reporter_id set
      final photoUrl =
          'https://r2.test.pantaudesa.id/uploads/test_${DateTime.now().millisecondsSinceEpoch}.jpg';
      json = await client.post(
        '/api/reports',
        body: {
          'category_id': cat['id'],
          'description': 'Test jalan berlubang dekat pasar',
          'lat': -6.9,
          'lng': 107.6,
          'photo_urls': [photoUrl],
          'wilayah_id': wargaUser.wilayahId,
          'idempotency_key':
              '${wargaUser.userId}_${DateTime.now().millisecondsSinceEpoch}',
        },
      );
      final reportId = json['id'] as String;
      expect(json['status'], 'submitted');
      expect(json['reporter_id'], wargaUser.userId); // Wave 0 fix

      // Step 4: GET /api/reports?creator_id=me → list contains reportId
      json = await client.get('/api/reports?creator_id=me');
      final myIds = ((json['reports'] as List?) ?? [])
          .map((r) => r['id'] as String)
          .toList();
      expect(myIds.contains(reportId), true);

      // Step 5: GET /api/reports/:id → 200, fields match
      json = await client.get('/api/reports/$reportId');
      expect(json['id'], reportId);
      expect(json['category_id'], cat['id']);

      // Step 6: PATCH /api/reports/:id/priority → 200, priority updated
      json = await client.patch(
        '/api/reports/$reportId/priority',
        body: {'priority': 3},
      );
      expect(json['priority'], 3);

      // Step 7: POST /api/reports/:id/evidence → 201
      json = await client.post(
        '/api/reports/$reportId/evidence',
        body: {
          'photo_urls': [photoUrl],
          'notes': 'Bukti tambahan',
        },
      );

      // Step 8: GET /api/warga/stats → 200, positive numbers
      json = await client.get('/api/warga/stats');
      expect((json['total'] as int?) ?? 0, greaterThan(0));

      // Step 9: GET /api/reports/nearby → 200, list
      json = await client.get(
        '/api/reports/nearby?lat=-6.9&lng=107.6&radius=5000',
      );
      expect((json['reports'] as List?) ?? [], isNotEmpty);

      // Step 10: GET /api/reports/duplicates?lat=-6.9&lng=107.6&radius=50 → 200
      json = await client.get(
        '/api/reports/duplicates?lat=-6.9&lng=107.6&radius=50',
      );

      // Step 11: POST /api/reports/:id/share → 201
      json = await client.post(
        '/api/reports/$reportId/share',
        body: {'channel': 'whatsapp'},
      );

      // Step 12: GET /api/reports?status=submitted → 200
      json = await client.get('/api/reports?status=submitted');

      // Step 13: GET /api/wilayah/:id → 200
      json = await client.get('/api/wilayah/${wargaUser.wilayahId}');

      // Step 14: GET /api/categories/:id → 200
      json = await client.get('/api/categories/${cat['id']}');

      // Step 15: GET /api/notifications → 200 (no auth required)
      json = await ApiClientBuilder(baseUrl: baseUrl).get('/api/notifications');

      // Step 16: GET /api/health → 200 (public)
      json = await ApiClientBuilder(baseUrl: baseUrl).get('/api/health');
    });
  });
}

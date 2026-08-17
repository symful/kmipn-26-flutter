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

  group('Admin Daerah Units', () {
    late TestUser adminUser;
    late ApiClientBuilder client;

    setUpAll(() async {
      final factory = TestUserFactory(baseUrl);
      adminUser = await factory.createAdminDaerah(suffix: 'units');
      client = ApiClientBuilder(baseUrl: baseUrl)
        ..withAuthToken(adminUser.token);
    });

    testWidgets('Units CRUD (4 assertions)', (tester) async {
      // Step 1: List units
      final units = await client.get('/api/admin-daerah/units');
      expect((units['units'] as List?) ?? [], isNotEmpty);

      // Step 2: Create unit
      final create = await client.post(
        '/api/admin-daerah/units',
        body: {'name': 'Unit Test CRUD', 'type': 'field_office'},
      );
      expect(create['name'], 'Unit Test CRUD');

      // Step 3: Update unit
      final unitId = create['id'] as String;
      final update = await client.patch(
        '/api/admin-daerah/units/$unitId',
        body: {'name': 'Unit Test Updated'},
      );
      expect(update['name'], 'Unit Test Updated');

      // Step 4: Delete unit
      final del = await client.delete('/api/admin-daerah/units/$unitId');
      expect(del['id'], unitId);
    });
  });
}

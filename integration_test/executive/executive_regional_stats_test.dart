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

  group('Executive Regional Stats', () {
    late TestUser execUser;
    late ApiClientBuilder client;

    setUpAll(() async {
      final factory = TestUserFactory(baseUrl);
      execUser = await factory.createExecutive(suffix: 'regional');
      client = ApiClientBuilder(baseUrl: baseUrl)
        ..withAuthToken(execUser.token);
    });

    testWidgets('Regional breakdown (4 assertions)', (tester) async {
      final stats = await client.get('/api/executive/regional-stats');
      expect(stats['regions'], isNotNull);
      final regions = stats['regions'] as List;
      expect(regions.length, greaterThan(0));
      if (regions.isNotEmpty) {
        expect((regions.first as Map)['region_id'], isNotNull);
        expect((regions.first as Map)['count'], isNotNull);
      }
    });
  });
}

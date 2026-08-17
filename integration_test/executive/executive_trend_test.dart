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

  group('Executive Trend', () {
    late TestUser execUser;
    late ApiClientBuilder client;

    setUpAll(() async {
      final factory = TestUserFactory(baseUrl);
      execUser = await factory.createExecutive(suffix: 'trend');
      client = ApiClientBuilder(baseUrl: baseUrl)
        ..withAuthToken(execUser.token);
    });

    testWidgets('Trend over time (3 assertions)', (tester) async {
      final trend = await client.get('/api/executive/trend');
      expect(trend['data'], isNotNull);
      final data = trend['data'] as List;
      expect(data.length, greaterThan(0));
      if (data.isNotEmpty) {
        expect((data.first as Map)['date'], isNotNull);
      }
    });
  });
}

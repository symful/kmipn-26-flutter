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

  group('Operator Stats', () {
    late TestUser operatorUser;
    late ApiClientBuilder client;

    setUpAll(() async {
      final factory = TestUserFactory(baseUrl);
      operatorUser = await factory.createOperator(suffix: 'stats');
      client = ApiClientBuilder(baseUrl: baseUrl)
        ..withAuthToken(operatorUser.token);
    });

    testWidgets('Stats accuracy (6 assertions)', (tester) async {
      final stats = await client.get('/api/operator/stats');
      expect(stats['total'], isNotNull);
      expect(stats['in_progress'], isNotNull);
      expect(stats['resolved'], isNotNull);
      expect(stats['closed'], isNotNull);
      expect((stats['total'] as int) >= 0, true);
      expect((stats['in_progress'] as int) >= 0, true);
    });
  });
}

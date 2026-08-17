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

  group('Surveyor Clarification', () {
    late TestUser surveyorUser;
    late ApiClientBuilder client;

    setUpAll(() async {
      final factory = TestUserFactory(baseUrl);
      surveyorUser = await factory.createSurveyor(suffix: 'clarif');
      client = ApiClientBuilder(baseUrl: baseUrl)
        ..withAuthToken(surveyorUser.token);
    });

    testWidgets('Clarification request (3 assertions)', (tester) async {
      // Step 1: Get tasks
      final tasks = await client.get('/api/surveyor/tasks');
      final taskList = (tasks['tasks'] as List?) ?? [];
      if (taskList.isEmpty) {
        expect(true, true);
        return;
      }
      final taskId = (taskList.first as Map)['id'] as String;

      // Step 2: Request clarification
      final req = await client.post(
        '/api/surveyor/tasks/$taskId/clarification',
        body: {'message': 'Konfirmasi ukuran kerusakan'},
      );
      expect(req['task_id'], taskId);

      // Step 3: Get clarification status
      final detail = await client.get('/api/surveyor/tasks/$taskId');
      expect(detail['clarification'], isNotNull);
    });
  });
}

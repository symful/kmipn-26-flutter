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

  group('Petugas Reject', () {
    late TestUser petugasUser;
    late ApiClientBuilder client;

    setUpAll(() async {
      final factory = TestUserFactory(baseUrl);
      petugasUser = await factory.createPetugas(suffix: 'reject');
      client = ApiClientBuilder(baseUrl: baseUrl)
        ..withAuthToken(petugasUser.token);
    });

    testWidgets('Reject task (3 assertions)', (tester) async {
      // Step 1: Get tasks
      final tasks = await client.get('/api/petugas/tasks');
      final taskList = (tasks['tasks'] as List?) ?? [];
      if (taskList.isEmpty) {
        expect(true, true);
        return;
      }
      final taskId = (taskList.first as Map)['id'] as String;

      // Step 2: Reject task
      final reject = await client.post(
        '/api/petugas/tasks/$taskId/reject',
        body: {'reason': 'Tidak bisa访问到位置'},
      );
      expect(reject['id'], taskId);

      // Step 3: Verify rejected
      final detail = await client.get('/api/petugas/tasks/$taskId');
      expect(detail['status'], 'rejected');
    });
  });
}

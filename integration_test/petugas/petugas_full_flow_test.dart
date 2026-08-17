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

  group('Petugas Full Lifecycle', () {
    late TestUser petugasUser;
    late ApiClientBuilder client;

    setUpAll(() async {
      final factory = TestUserFactory(baseUrl);
      petugasUser = await factory.createPetugas(suffix: 'flow');
      client = ApiClientBuilder(baseUrl: baseUrl)
        ..withAuthToken(petugasUser.token);
    });

    testWidgets('Petugas full lifecycle (6 assertions)', (tester) async {
      // Step 1: Get petugas tasks
      final tasks = await client.get('/api/petugas/tasks');
      expect((tasks['tasks'] as List?) ?? [], isNotEmpty);

      // Step 2: Accept a task
      final taskList = (tasks['tasks'] as List?) ?? [];
      if (taskList.isEmpty) {
        expect(true, true);
        return;
      }
      final taskId = (taskList.first as Map)['id'] as String;
      final accept = await client.post(
        '/api/petugas/tasks/$taskId/accept',
        body: {},
      );
      expect(accept['id'], taskId);

      // Step 3: Get task details
      final detail = await client.get('/api/petugas/tasks/$taskId');
      expect(detail['id'], taskId);

      // Step 4: Add evidence
      final evidence = await client.post(
        '/api/petugas/tasks/$taskId/evidence',
        body: {
          'photo_urls': ['https://r2.test.pantaudesa.id/test.jpg'],
          'notes': 'Kerusakan confirmed',
        },
      );
      expect(evidence['task_id'], taskId);

      // Step 5: Complete task
      final complete = await client.post(
        '/api/petugas/tasks/$taskId/complete',
        body: {'summary': 'Tugas selesai'},
      );
      expect(complete['id'], taskId);

      // Step 6: Verify completed
      final updated = await client.get('/api/petugas/tasks/$taskId');
      expect(updated['status'], 'completed');
    });
  });
}

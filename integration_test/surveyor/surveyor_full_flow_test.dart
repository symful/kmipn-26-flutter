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

  group('Surveyor Full Lifecycle', () {
    late TestUserFactory factory;
    late TestUser wargaUser;
    late TestUser surveyorUser;
    late ApiClientBuilder wargaClient;
    late ApiClientBuilder surveyorClient;

    setUpAll(() async {
      factory = TestUserFactory(baseUrl);
      wargaUser = await factory.createWarga(suffix: 'survey_flow');
      surveyorUser = await factory.createSurveyor(suffix: 'survey_flow');
      wargaClient = ApiClientBuilder(baseUrl: baseUrl)
        ..withAuthToken(wargaUser.token);
      surveyorClient = ApiClientBuilder(baseUrl: baseUrl)
        ..withAuthToken(surveyorUser.token);
    });

    testWidgets('Surveyor full lifecycle (8 assertions)', (tester) async {
      // Step 1: Warga creates a report
      final cats = await wargaClient.get('/api/categories');
      final catList = cats['categories'] as List;
      final cat = catList.first as Map;

      final report = await wargaClient.post(
        '/api/reports',
        body: {
          'category_id': cat['id'],
          'description': 'Jalan rusak parah',
          'lat': -6.9,
          'lng': 107.6,
          'photo_urls': ['https://r2.test.pantaudesa.id/test.jpg'],
          'wilayah_id': wargaUser.wilayahId,
          'idempotency_key': '${wargaUser.userId}_survey1',
        },
      );
      expect(report['id'], isNotNull);
      expect(report['status'], 'submitted');

      // Step 2: Surveyor gets assigned task (verifikator assigns)
      // Skip to getting task queue
      final tasks = await surveyorClient.get('/api/surveyor/tasks');
      expect((tasks['tasks'] as List?) ?? [], isNotEmpty);

      // Step 3: Surveyor accepts a task
      final taskId = ((tasks['tasks'] as List).first as Map)['id'] as String;
      final accept = await surveyorClient.post(
        '/api/surveyor/tasks/$taskId/accept',
        body: {},
      );
      expect(accept['id'], taskId);

      // Step 4: Surveyor gets task details
      final taskDetail = await surveyorClient.get(
        '/api/surveyor/tasks/$taskId',
      );
      expect(taskDetail['id'], taskId);
      expect(taskDetail['status'], isNotNull);

      // Step 5: Surveyor updates checklist
      final checklist = await surveyorClient.patch(
        '/api/surveyor/tasks/$taskId/checklist',
        body: {
          'items': [
            {
              'question': 'Kondisi jalan?',
              'answer': 'Rusak parah',
              'photo_urls': [],
            },
            {
              'question': 'Lebaran kerusakan?',
              'answer': '> 5 meter',
              'photo_urls': [],
            },
          ],
        },
      );
      expect(checklist['task_id'], taskId);

      // Step 6: Surveyor sets progress
      final progress = await surveyorClient.patch(
        '/api/surveyor/tasks/$taskId/progress',
        body: {'progress_percent': 50, 'progress_notes': 'Sedang survei'},
      );
      expect(progress['progress_percent'], 50);

      // Step 7: Surveyor requests clarification
      final clarification = await surveyorClient.post(
        '/api/surveyor/tasks/$taskId/clarification',
        body: {'message': 'Butuh konfirmasi ukuran'},
      );
      expect(clarification['task_id'], taskId);

      // Step 8: Surveyor completes task
      final complete = await surveyorClient.post(
        '/api/surveyor/tasks/$taskId/complete',
        body: {
          'summary': 'Survei selesai',
          'completion_proof': 'Photo evidence',
        },
      );
      expect(complete['id'], taskId);
    });
  });
}

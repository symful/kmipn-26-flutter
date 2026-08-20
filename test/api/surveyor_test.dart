import 'package:flutter_test/flutter_test.dart';
import 'package:sigap/api/api_client.dart';
import '../helpers/api_client_builder.dart';

void main() {
  group('Surveyor API', () {
    late ApiClient surveyorClient;

    setUpAll(() async {
      surveyorClient = await buildTestApiClient(role: 'SURVEYOR');
    });

    test('surveyorGetTasks returns a list', () async {
      final result = await surveyorClient.surveyorGetTasks();
      expect(result, isA<List<Map<String, dynamic>>>());
    });

    test('surveyorGetTaskDetail returns a map', () async {
      // First get the task list to get a valid task ID
      final tasks = await surveyorClient.surveyorGetTasks();
      if (tasks.isEmpty) {
        // If no tasks available, skip or expect empty
        return;
      }
      final taskId = tasks.first['id'] as String;
      final result = await surveyorClient.surveyorGetTaskDetail(taskId);
      expect(result, isA<Map<String, dynamic>>());
      expect(result['id'], equals(taskId));
    });

    test('getSurveyorChecklistTemplate returns a map', () async {
      final tasks = await surveyorClient.surveyorGetTasks();
      if (tasks.isEmpty) {
        return;
      }
      final taskId = tasks.first['id'] as String;
      final result = await surveyorClient.getSurveyorChecklistTemplate(taskId);
      expect(result, isA<Map<String, dynamic>>());
      expect(result.containsKey('items'), isTrue);
    });

    test('surveyorAcceptTask returns a map', () async {
      final tasks = await surveyorClient.surveyorGetTasks();
      if (tasks.isEmpty) {
        return;
      }
      final taskId = tasks.first['id'] as String;
      final result = await surveyorClient.surveyorAcceptTask(taskId);
      expect(result, isA<Map<String, dynamic>>());
    });

    test('surveyorSubmitVisit returns a map', () async {
      final tasks = await surveyorClient.surveyorGetTasks();
      if (tasks.isEmpty) {
        return;
      }
      final taskId = tasks.first['id'] as String;
      final result = await surveyorClient.surveyorSubmitVisit(taskId, {
        'notes': 'Test visit notes',
      });
      expect(result, isA<Map<String, dynamic>>());
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:sigap/api/api_client.dart';
import '../helpers/test_harness.dart';
import '../helpers/api_client_builder.dart';
import '../helpers/test_jwt.dart';

void main() {
  group('Surveyor API', () {
    late ApiClient client;

    setUpAll(() async {
      await testCooldown(seconds: 5);
      client = await buildTestApiClient(role: Role.SURVEYOR);
    });

    test('surveyorGetTasks returns task list', () async {
      final result = await client.surveyorGetTasks();
      expect(result, isA<List<Map<String, dynamic>>>());
    });

    test('surveyorGetTaskDetail returns task detail', () async {
      final tasks = await client.surveyorGetTasks();
      if (tasks.isEmpty) return;

      final taskId = tasks.first['id'] as String;
      final result = await client.surveyorGetTaskDetail(taskId);
      expect(result, isA<Map<String, dynamic>>());
      expect(result['id'], equals(taskId));
    });

    test('getSurveyorChecklistTemplate returns template', () async {
      final tasks = await client.surveyorGetTasks();
      if (tasks.isEmpty) return;

      final taskId = tasks.first['id'] as String;
      final result = await client.getSurveyorChecklistTemplate(taskId);
      expect(result, isA<Map<String, dynamic>>());
    });

    test('surveyorAcceptTask accepts a task', () async {
      final tasks = await client.surveyorGetTasks();
      if (tasks.isEmpty) return;

      final task = tasks.first;
      final taskId = task['id'] as String;
      final status = task['status'] as String;

      if (status != 'assigned' && status != 'pending') return;

      final result = await client.surveyorAcceptTask(taskId);
      expect(result, isA<Map<String, dynamic>>());
    });

    test('surveyorStartTask starts a task', () async {
      final tasks = await client.surveyorGetTasks();
      if (tasks.isEmpty) return;

      final task = tasks.first;
      final taskId = task['id'] as String;
      final status = task['status'] as String;

      if (status != 'accepted') return;

      final result = await client.surveyorStartTask(taskId);
      expect(result, isA<Map<String, dynamic>>());
    });

    test('surveyorRejectTask rejects a task with reason', () async {
      final tasks = await client.surveyorGetTasks();
      if (tasks.isEmpty) return;

      final task = tasks.first;
      final taskId = task['id'] as String;
      final status = task['status'] as String;

      if (status != 'assigned' && status != 'pending') return;

      final result = await client.surveyorRejectTask(
        taskId,
        'Test rejection reason',
      );
      expect(result, isA<Map<String, dynamic>>());
    });

    test('surveyorRequestClarification sends clarification question', () async {
      final tasks = await client.surveyorGetTasks();
      if (tasks.isEmpty) return;

      final taskId = tasks.first['id'] as String;

      final result = await client.surveyorRequestClarification(
        taskId,
        question: 'Can you provide more details about the location?',
      );
      expect(result, isA<Map<String, dynamic>>());
    });

    test('surveyorSubmitVisit submits visit data', () async {
      final tasks = await client.surveyorGetTasks();
      if (tasks.isEmpty) return;

      final taskId = tasks.first['id'] as String;

      final result = await client.surveyorSubmitVisit(taskId, {
        'gps_lat': -6.2088,
        'gps_lng': 106.8456,
        'kondisi': 'baik',
        'rekomendasi': 'perbaikan',
      });
      expect(result, isA<Map<String, dynamic>>());
    });

    test('submitVisitReport submits structured visit report', () async {
      final tasks = await client.surveyorGetTasks();
      if (tasks.isEmpty) return;

      final taskId = tasks.first['id'] as String;

      final result = await client.submitVisitReport(
        taskId: taskId,
        photos: {'depan': '', 'belakang': '', 'kiri': '', 'kanan': ''},
        gpsLat: -6.2088,
        gpsLng: 106.8456,
        accuracy: 5.0,
        kondisi: 'baik',
        rekomendasi: 'perbaikan',
        catatan: 'Test visit report',
      );
      expect(result, isA<Map<String, dynamic>>());
    });
  });
}

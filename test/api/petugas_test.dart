import 'package:flutter_test/flutter_test.dart';
import 'package:sigap/api/api_client.dart';
import '../helpers/api_client_builder.dart';

void main() {
  group('Petugas API Tests', () {
    group('PETUGAS role', () {
      late ApiClient petugasClient;

      setUpAll(() async {
        petugasClient = await buildTestApiClient(role: 'PETUGAS');
      });

      group('petugasGetTasks', () {
        test('returns list of tasks', () async {
          final tasks = await petugasClient.petugasGetTasks();

          expect(tasks, isA<List<Map<String, dynamic>>>());
        });
      });

      group('getPetugasTaskDetail', () {
        test('returns task detail for valid task ID', () async {
          // First get the task list
          final tasks = await petugasClient.petugasGetTasks();

          if (tasks.isEmpty) {
            // No tasks available - skip this test
            return;
          }

          final taskId = tasks.first['id'].toString();
          final taskDetail = await petugasClient.getPetugasTaskDetail(taskId);

          expect(taskDetail, isA<Map<String, dynamic>>());
          expect(taskDetail.containsKey('id'), isTrue);
          expect(taskDetail['id'], equals(taskId));
        });
      });

      group('petugasAcceptTask', () {
        test('accepts task with valid ID', () async {
          // First get the task list
          final tasks = await petugasClient.petugasGetTasks();

          if (tasks.isEmpty) {
            // No tasks available - skip this test
            return;
          }

          // Find a task that can be accepted
          final assignedTask = tasks.firstWhere(
            (t) => t['status'] == 'assigned' || t['status'] == 'pending',
            orElse: () => tasks.first,
          );

          final taskId = assignedTask['id'].toString();
          final result = await petugasClient.petugasAcceptTask(taskId);

          expect(result, isA<Map<String, dynamic>>());
          expect(result['success'], isTrue);
        });
      });

      group('petugasUpdateProgress', () {
        test('updates progress for a task', () async {
          // First get the task list
          final tasks = await petugasClient.petugasGetTasks();

          if (tasks.isEmpty) {
            // No tasks available - skip this test
            return;
          }

          // Find an in-progress or accepted task
          final task = tasks.firstWhere(
            (t) =>
                t['status'] == 'in_progress' ||
                t['status'] == 'accepted' ||
                t['status'] == 'assigned',
            orElse: () => tasks.first,
          );

          final taskId = task['id'].toString();
          final result = await petugasClient.petugasUpdateProgress(
            taskId: taskId,
            progressPercent: 50,
            notes: 'Work in progress',
          );

          expect(result, isA<Map<String, dynamic>>());
          expect(result['progress_percent'], equals(50));
        });
      });

      group('petugasUploadEvidence', () {
        test('uploads evidence for a task', () async {
          // First get the task list
          final tasks = await petugasClient.petugasGetTasks();

          if (tasks.isEmpty) {
            // No tasks available - skip this test
            return;
          }

          // Find an in-progress task
          final task = tasks.firstWhere(
            (t) => t['status'] == 'in_progress',
            orElse: () => tasks.first,
          );

          final taskId = task['id'].toString();

          // Call with empty photo paths - evidence can be uploaded without photos
          final result = await petugasClient.petugasUploadEvidence(
            taskId,
            [],
            notes: 'Test evidence upload',
          );

          expect(result, isA<Map<String, dynamic>>());
        });
      });

      group('petugasCompleteTask', () {
        test('completes task with summary', () async {
          // First get the task list
          final tasks = await petugasClient.petugasGetTasks();

          if (tasks.isEmpty) {
            // No tasks available - skip this test
            return;
          }

          // Find a task that can be completed (in_progress)
          final task = tasks.firstWhere(
            (t) => t['status'] == 'in_progress',
            orElse: () => tasks.first,
          );

          final taskId = task['id'].toString();
          final result = await petugasClient.petugasCompleteTask(
            taskId,
            summary: 'Task completed successfully',
            photoPaths: [],
          );

          expect(result, isA<Map<String, dynamic>>());
          expect(result['success'], isTrue);
        });
      });
    });
  });
}

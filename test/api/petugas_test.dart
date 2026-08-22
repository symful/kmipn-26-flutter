import 'package:flutter_test/flutter_test.dart';
import 'package:sigap/api/api_client.dart';
import '../helpers/test_jwt.dart';
import '../helpers/api_client_builder.dart';

void main() {
  late ApiClient client;

  setUpAll(() async {
    // Ensure we have a valid token before any test runs
    await TestJwtCache.getToken(Role.PETUGAS);
  });

  setUp(() async {
    client = await buildTestApiClient(role: Role.PETUGAS);
  });

  group('Petugas API', () {
    test('petugasGetTasks returns a List', () async {
      final result = await client.petugasGetTasks();
      expect(result, isA<List<Map<String, dynamic>>>());
    });

    test('getPetugasTaskDetail returns a Map', () async {
      // First get tasks to find a task ID
      final tasks = await client.petugasGetTasks();
      if (tasks.isNotEmpty) {
        final taskId = tasks.first['id']?.toString();
        if (taskId != null) {
          final result = await client.getPetugasTaskDetail(taskId);
          expect(result, isA<Map<String, dynamic>>());
        }
      }
      // Even if no tasks, the call should not throw
    });

    test('petugasAcceptTask returns a Map', () async {
      final tasks = await client.petugasGetTasks();
      if (tasks.isNotEmpty) {
        final taskId = tasks.first['id']?.toString();
        if (taskId != null) {
          final result = await client.petugasAcceptTask(taskId);
          expect(result, isA<Map<String, dynamic>>());
        }
      }
    });

    test('petugasRejectTask returns a Map', () async {
      final tasks = await client.petugasGetTasks();
      if (tasks.isNotEmpty) {
        final taskId = tasks.first['id']?.toString();
        if (taskId != null) {
          final result = await client.petugasRejectTask(
            taskId,
            'Test rejection reason',
          );
          expect(result, isA<Map<String, dynamic>>());
        }
      }
    });

    test('petugasUpdateProgress returns a Map', () async {
      final tasks = await client.petugasGetTasks();
      if (tasks.isNotEmpty) {
        final taskId = tasks.first['id']?.toString();
        if (taskId != null) {
          final result = await client.petugasUpdateProgress(
            taskId: taskId,
            progressPercent: 50,
          );
          expect(result, isA<Map<String, dynamic>>());
        }
      }
    });

    test('petugasUploadEvidence returns a Map', () async {
      final tasks = await client.petugasGetTasks();
      if (tasks.isNotEmpty) {
        final taskId = tasks.first['id']?.toString();
        if (taskId != null) {
          // Pass empty list since we don't have real photo files in tests
          final result = await client.petugasUploadEvidence(taskId, []);
          expect(result, isA<Map<String, dynamic>>());
        }
      }
    });

    test('petugasCompleteTask returns a Map', () async {
      final tasks = await client.petugasGetTasks();
      if (tasks.isNotEmpty) {
        final taskId = tasks.first['id']?.toString();
        if (taskId != null) {
          // Pass empty photo list since we don't have real files in tests
          final result = await client.petugasCompleteTask(
            taskId,
            summary: 'Test completion summary',
            photoPaths: [],
          );
          expect(result, isA<Map<String, dynamic>>());
        }
      }
    });

    test('petugasRequestClarification returns a Map', () async {
      final tasks = await client.petugasGetTasks();
      if (tasks.isNotEmpty) {
        final taskId = tasks.first['id']?.toString();
        if (taskId != null) {
          final result = await client.petugasRequestClarification(
            taskId,
            question: 'Test clarification question',
          );
          expect(result, isA<Map<String, dynamic>>());
        }
      }
    });
  });
}

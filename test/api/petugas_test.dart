import 'package:flutter_test/flutter_test.dart';
import 'package:sigap/api/api_client.dart';
import '../helpers/test_jwt.dart';
import '../helpers/api_client_builder.dart';

void main() {
  late ApiClient client;

  setUpAll(() async {
    // Pre-fetch token so first test isn't slowed by auth
    await TestJwtCache.getToken(Role.PETUGAS);
  });

  setUp(() async {
    client = await buildTestApiClient(role: Role.PETUGAS);
  });

  group('Petugas API', () {
    test('GET /api/petugas/tasks returns tugas list', () async {
      final result = await client.petugasGetTasks();
      expect(result, isA<List<Map<String, dynamic>>>());
    });

    test('GET /api/petugas/tasks/{realId} returns task detail', () async {
      final tasks = await client.petugasGetTasks();
      if (tasks.isEmpty) fail('No petugas tasks seeded');
      final taskId = tasks.first['id'] as String;

      final result = await client.getPetugasTaskDetail(taskId);
      expect(result, isA<Map<String, dynamic>>());
      // Task detail should have instructions and location fields
      expect(
        result.containsKey('instructions') || result.containsKey('task'),
        true,
        reason: 'Task detail should have instructions or task key',
      );
    });

    test('POST /api/petugas/tasks/{realId}/accept accepts task', () async {
      final tasks = await client.petugasGetTasks();
      if (tasks.isEmpty) fail('No petugas tasks seeded');
      final taskId = tasks.first['id'] as String;

      final result = await client.petugasAcceptTask(taskId);
      expect(result, isA<Map<String, dynamic>>());
      expect(
        result.containsKey('accepted_at'),
        true,
        reason: 'Accept response should have accepted_at',
      );
    });

    test(
      'POST /api/petugas/tasks/{realId}/progress updates progress',
      () async {
        final tasks = await client.petugasGetTasks();
        if (tasks.isEmpty) fail('No petugas tasks seeded');
        final taskId = tasks.first['id'] as String;

        // Use the client's progress update method with correct params
        final result = await client.petugasUpdateProgress(
          taskId: taskId,
          progressPercent: 50,
          notes: 'In progress',
        );
        expect(result, isA<Map<String, dynamic>>());
        expect(
          result.containsKey('updated_at'),
          true,
          reason: 'Progress update response should have updated_at',
        );
      },
    );

    test('POST /api/petugas/tasks/{realId}/evidence uploads proof', () async {
      final tasks = await client.petugasGetTasks();
      if (tasks.isEmpty) fail('No petugas tasks seeded');
      final taskId = tasks.first['id'] as String;

      // Upload with empty photo list to test the endpoint structure
      final result = await client.petugasUploadEvidence(taskId, []);
      expect(result, isA<Map<String, dynamic>>());
      expect(
        result.containsKey('evidence_id') || result.containsKey('id'),
        true,
        reason: 'Evidence upload response should have evidence_id or id',
      );
    });

    test(
      'POST /api/petugas/tasks/{realId}/complete marks task complete',
      () async {
        final tasks = await client.petugasGetTasks();
        if (tasks.isEmpty) fail('No petugas tasks seeded');
        final taskId = tasks.first['id'] as String;

        final result = await client.petugasCompleteTask(
          taskId,
          summary: 'Test completion',
          photoPaths: [],
        );
        expect(result, isA<Map<String, dynamic>>());
        expect(
          result.containsKey('completed_at'),
          true,
          reason: 'Complete response should have completed_at',
        );
      },
    );
  });
}

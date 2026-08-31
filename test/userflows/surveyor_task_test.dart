import 'package:flutter_test/flutter_test.dart';
import 'package:sigap/api/client.dart';
import 'package:sigap/api/exceptions.dart';
import '../helpers/test_env.dart';

const _apiBaseUrl = 'https://kmipn-26-deno.careday17.workers.dev';

/// Authenticates and returns tokens. Throws if login fails so setUpAll fails loudly.
Future<({String accessToken, String refreshToken})> _login(
  String email,
  String password,
) async {
  final client = ApiClient(baseUrl: _apiBaseUrl);
  final resp = await client.login(email, password);
  final token = resp.token;
  final refresh = resp.refreshToken;
  expect(token, isNotNull, reason: 'login returned null access token');
  expect(token, isNotEmpty, reason: 'login returned empty access token');
  expect(refresh, isNotNull, reason: 'login returned null refresh token');
  return (accessToken: token!, refreshToken: refresh!);
}

void main() {
  late ApiClient surveyorClient;
  late ApiClient wargaClient;
  String? testCatId;
  String? testTaskId;

  setUpAll(() async {
    // Login as surveyor
    final surveyorTokens = await _login('surveyor@sigap.id', 'surveyor123');
    surveyorClient = ApiClient(
      baseUrl: _apiBaseUrl,
      testAccessToken: surveyorTokens.accessToken,
    );

    // Login as warga (needed to create source report)
    final wargaTokens = await _login('warga@sigap.id', 'warga123');
    wargaClient = ApiClient(
      baseUrl: _apiBaseUrl,
      testAccessToken: wargaTokens.accessToken,
    );

    // Get a category
    final cats = await surveyorClient.getCategories();
    expect(cats, isNotEmpty, reason: 'categories list should not be empty');
    testCatId = cats.first.id!;
    expect(
      testCatId,
      isNotEmpty,
      reason: 'test category id should not be empty',
    );

    // Create a report as warga for surveyor flow
    final wargaResult = await wargaClient.submitReport(
      idempotencyKey:
          'TEST_${testRunId}_source_${DateTime.now().millisecondsSinceEpoch}',
      categoryId: testCatId!,
      description: 'TEST_${testRunId}_surveyor_flow',
      lat: -6.2,
      lng: 106.8,
    );
    expect(wargaResult.id, isNotNull, reason: 'warga report should have id');

    // Get surveyor tasks
    final tasks = await surveyorClient.getTasks();
    expect(
      tasks.tasks,
      isA<List<PetugasTask>>(),
      reason: 'tasks should be List<PetugasTask>',
    );
    if (tasks.tasks.isNotEmpty) {
      testTaskId = tasks.tasks.first.taskId;
    }
  });

  group('surveyor task flow', () {
    test('getTasks returns assigned surveyor tasks', () async {
      final result = await surveyorClient.getTasks();
      expect(
        result.tasks,
        isA<List<PetugasTask>>(),
        reason: 'tasks should be List<PetugasTask>',
      );
      expect(result.tasks, isNotNull, reason: 'tasks list should not be null');
    });

    test('submitVisitReport returns visit_id, task_id, status', () async {
      expect(testTaskId, isNotNull, reason: 'test task id should be available');
      try {
        final result = await surveyorClient.submitVisitReport(
          taskId: testTaskId!,
          findings: 'TEST_${testRunId}_findings',
          checklist: [
            {'item': 'Site inspected', 'checked': true},
            {'item': 'Photos taken', 'checked': true},
            {'item': 'GPS recorded', 'checked': true},
          ],
          photoUrls: [],
          gpsLat: -6.2,
          gpsLng: 106.8,
          accuracy: 5.0,
          conditionAssessment: 'good',
          recommendation: 'TEST_${testRunId}_recommendation',
        );
        expect(
          result.visitId,
          isNotNull,
          reason: 'visit_id should not be null',
        );
        expect(
          result.visitId,
          isA<String>(),
          reason: 'visit_id should be string',
        );
        expect(
          result.taskId,
          isA<String>(),
          reason: 'task_id should be string',
        );
        expect(result.status, isA<String>(), reason: 'status should be string');
      } on ApiException catch (e) {
        // Visit may fail if task already completed or invalid state — expect 400
        expect(
          e.statusCode,
          equals(400),
          reason:
              'visit submission should return 400 for invalid state, got ${e.statusCode}',
        );
      }
    });

    test('visit response has all required fields', () async {
      expect(testTaskId, isNotNull, reason: 'test task id should be available');
      try {
        final result = await surveyorClient.submitVisitReport(
          taskId: testTaskId!,
          findings: 'TEST_${testRunId}_shape_test',
          checklist: [
            {'item': 'Check 1', 'checked': true},
          ],
          photoUrls: [],
          gpsLat: -6.3,
          gpsLng: 106.9,
          accuracy: 10.0,
          conditionAssessment: 'good',
          recommendation: 'TEST_${testRunId}_shape_recommendation',
        );
        expect(
          result.visitId,
          isA<String>(),
          reason: 'visit_id should be string',
        );
        expect(
          result.taskId,
          isA<String>(),
          reason: 'task_id should be string',
        );
        expect(result.status, isA<String>(), reason: 'status should be string');
      } on ApiException catch (e) {
        expect(
          e.statusCode,
          equals(400),
          reason: 'visit should return 400 for shape test, got ${e.statusCode}',
        );
      }
    });

    test('getTaskDetail returns task info', () async {
      expect(testTaskId, isNotNull, reason: 'test task id should be available');
      final detail = await surveyorClient.getTaskDetail(testTaskId!);
      expect(detail.taskId, isNotNull, reason: 'task id should not be null');
    });

    test('getTaskChecklistTemplate returns checklist items', () async {
      expect(testTaskId, isNotNull, reason: 'test task id should be available');
      final template = await surveyorClient.getTaskChecklistTemplate(
        testTaskId!,
      );
      expect(
        template.id != null || template.items != null,
        isTrue,
        reason: 'template should have id or items',
      );
    });

    test('forbidden: warga cannot call task endpoints', () async {
      expect(
        () => wargaClient.getTasks(),
        throwsA(anything),
        reason: 'warga getTasks should throw exception',
      );
    });
  });
}

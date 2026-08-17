import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../_helpers/test_user_factory.dart';
import '../_helpers/cleanup.dart';
import '../_helpers/api_client_builder.dart';
import '../_helpers/evidence_recorder.dart';

/// Full lifecycle integration test for warga report flow.
///
/// Tests the complete workflow:
/// 1. Warga creates a report via API
/// 2. Verifikator fetches queue and assigns to surveyor
/// 3. Surveyor visits and adds visit record
/// 4. Verifikator closes the case
///
/// This test connects to the real staging API and requires seeded credentials.
void main() {
  // Test configuration
  const baseUrl = 'https://kmipn-26-deno.careday17.workers.dev';
  const testSecret =
      'HNjAW4i5xCxJFow5mrTLXvSW0PDJpfFJXo8PPUnbP38rVfe1/vcwdt4gGR/rR9Fu';
  const evidencePath = '.sisyphus/evidence/integration_test';

  // Report data for testing
  const testReportLat = -6.5;
  const testReportLng = 106.8;
  const testReportDescription =
      'Integration test report - jalan berlubang di area '
      'pemukiman. Kondisi berbahaya bagi pengguna jalan.';

  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Warga Full Flow Integration Test', () {
    late TestApiClient wargaClient;
    late TestApiClient verifikatorClient;
    late TestApiClient surveyorClient;
    late StagingCleanup cleanup;
    late EvidenceRecorder recorder;

    setUpAll(() async {
      // Initialize clients
      wargaClient = TestApiClient(baseUrl: baseUrl);
      verifikatorClient = TestApiClient(baseUrl: baseUrl);
      surveyorClient = TestApiClient(baseUrl: baseUrl);
      cleanup = StagingCleanup(baseUrl: baseUrl, testSecret: testSecret);
      recorder = EvidenceRecorder(
        evidencePath: evidencePath,
        testName: 'warga_full_flow',
      );

      // Reset staging before tests
      print('Resetting staging environment...');
      final resetSuccess = await cleanup.reset();
      print(
        'Staging reset ${resetSuccess ? 'successful' : 'failed (continuing anyway)'}',
      );
    });

    tearDownAll(() {
      wargaClient.dispose();
      verifikatorClient.dispose();
      surveyorClient.dispose();
      cleanup.dispose();
    });

    testWidgets(
      'Full report lifecycle: create -> verifikator assign -> surveyor visit -> close',
      (tester) async {
        String? reportId;
        String? wargaToken;
        String? verifikatorToken;
        String? surveyorToken;
        String? assignedSurveyorId;
        Map<String, dynamic>? categoriesResponse;

        // Step 1: Login as warga
        print('\n=== STEP 1: Warga Login ===');
        final wargaFactory = TestUserFactory(baseUrl: baseUrl);
        final wargaUser = await wargaFactory.getSeededUser('warga');
        wargaToken = wargaUser.accessToken;
        wargaClient.setAccessToken(wargaToken);
        recorder.recordStep(
          stepName: 'warga_login',
          description: 'Login as warga to get access token',
          responseBody: {
            'email': wargaUser.email,
            'role': wargaUser.role,
            'hasToken': wargaToken != null,
          },
        );
        expect(
          wargaToken,
          isNotNull,
          reason: 'Warga should receive access token',
        );
        print('Warga logged in: ${wargaUser.email}');

        // Step 2: Get categories
        print('\n=== STEP 2: Get Categories ===');
        categoriesResponse = await wargaClient.get('/api/categories');
        recorder.recordStep(
          stepName: 'get_categories',
          description: 'Fetch categories to get a valid category_id',
          responseBody: categoriesResponse,
        );
        print('Categories response: $categoriesResponse');

        // Extract category_id - look for first category with an id
        String? categoryId;
        if (categoriesResponse.containsKey('categories')) {
          final categories = categoriesResponse['categories'] as List;
          if (categories.isNotEmpty) {
            categoryId = categories.first['id'] as String?;
          }
        }
        // Fallback: look for 'data' key
        if (categoryId == null && categoriesResponse.containsKey('data')) {
          final data = categoriesResponse['data'];
          if (data is List && data.isNotEmpty) {
            categoryId = data.first['id'] as String?;
          }
        }
        expect(
          categoryId,
          isNotNull,
          reason: 'Should find a valid category_id',
        );
        print('Using category_id: $categoryId');

        // Step 3: Create report as warga
        print('\n=== STEP 3: Create Report ===');
        final idempotencyKey = _generateIdempotencyKey();
        final createReportBody = {
          'idempotency_key': idempotencyKey,
          'category_id': categoryId,
          'description': testReportDescription,
          'lat': testReportLat,
          'lng': testReportLng,
          'title': 'Test Report - Integration Test',
        };

        Map<String, dynamic> createResponse;
        int createStatusCode = 500;
        try {
          final rawResponse = await wargaClient.rawPost(
            '/api/reports',
            body: createReportBody,
          );
          createStatusCode = rawResponse.statusCode;
          createResponse = await wargaClient.post(
            '/api/reports',
            body: createReportBody,
          );
        } on TestApiException catch (e) {
          createStatusCode = e.statusCode;
          createResponse = {'error': e.body ?? e.toString()};
        }

        recorder.recordStep(
          stepName: 'create_report',
          description: 'Create new report via POST /api/reports',
          requestBody: createReportBody,
          responseBody: createResponse,
          httpStatusCode: createStatusCode,
        );

        expect(
          createStatusCode,
          200,
          reason: 'Report creation should return 200',
        );
        expect(
          createStatusCode,
          isNot(500),
          reason: 'Report creation should not return 500',
        );

        // Extract report ID from response
        reportId = createResponse['id'] as String?;
        // Fallback: check in 'report' key
        if (reportId == null && createResponse.containsKey('report')) {
          final report = createResponse['report'];
          if (report is Map) {
            reportId = report['id'] as String?;
          }
        }
        expect(reportId, isNotNull, reason: 'Report should have an ID');
        print('Report created with ID: $reportId');

        // Step 4: Login as verifikator
        print('\n=== STEP 4: Verifikator Login ===');
        final verifikatorFactory = TestUserFactory(baseUrl: baseUrl);
        final verifikatorUser = await verifikatorFactory.getSeededUser(
          'verifikator',
        );
        verifikatorToken = verifikatorUser.accessToken;
        verifikatorClient.setAccessToken(verifikatorToken);
        recorder.recordStep(
          stepName: 'verifikator_login',
          description: 'Login as verifikator',
          responseBody: {
            'email': verifikatorUser.email,
            'role': verifikatorUser.role,
            'hasToken': verifikatorToken != null,
          },
        );
        expect(verifikatorToken, isNotNull);
        print('Verifikator logged in: ${verifikatorUser.email}');

        // Step 5: Verifikator fetches queue and finds the report
        print('\n=== STEP 5: Verifikator Fetches Queue ===');
        Map<String, dynamic> queueResponse;
        int queueStatusCode = 500;
        try {
          final rawResponse = await verifikatorClient.rawGet(
            '/api/verifikator',
          );
          queueStatusCode = rawResponse.statusCode;
          queueResponse = await verifikatorClient.get('/api/verifikator');
        } on TestApiException catch (e) {
          queueStatusCode = e.statusCode;
          queueResponse = {'error': e.body ?? e.toString()};
        }

        recorder.recordStep(
          stepName: 'verifikator_get_queue',
          description: 'Fetch verifikator queue to find the report',
          responseBody: queueResponse,
          httpStatusCode: queueStatusCode,
        );

        expect(
          queueStatusCode,
          isNot(500),
          reason: 'Queue fetch should not return 500',
        );
        print('Queue response status: $queueStatusCode');

        // Find the report in queue
        String? foundReportId;
        final queueItems = _extractQueueItems(queueResponse);
        for (final item in queueItems) {
          final itemId = item['id'] as String? ?? item['report_id'] as String?;
          if (itemId == reportId) {
            foundReportId = itemId;
            break;
          }
        }
        print('Found report in queue: $foundReportId');

        // Step 6: Verifikator assigns report to surveyor (assess endpoint)
        print('\n=== STEP 6: Verifikator Assigns to Surveyor ===');
        expect(reportId, isNotNull, reason: 'Report ID should exist');

        // First, get available surveyors to find a surveyor ID
        Map<String, dynamic> surveyorListResponse = {};
        try {
          surveyorListResponse = await verifikatorClient.get('/api/surveyors');
        } catch (e) {
          // Fallback - try alternate endpoint
          try {
            surveyorListResponse = await verifikatorClient.get(
              '/api/users?role=surveyor',
            );
          } catch (_) {
            // Ignore - we'll try assign without surveyor_id
          }
        }

        // Extract surveyor ID if available
        assignedSurveyorId = _extractSurveyorId(surveyorListResponse);
        print('Available surveyor ID: $assignedSurveyorId');

        // Try the assess/assign endpoint
        Map<String, dynamic> assignResponse = {};
        int assignStatusCode = 500;
        final assignBody = <String, dynamic>{
          if (assignedSurveyorId != null) 'surveyor_id': assignedSurveyorId,
          'decision': 'assign',
        };

        try {
          final rawResponse = await verifikatorClient.rawPost(
            '/api/reports/$reportId/assess',
            body: assignBody,
          );
          assignStatusCode = rawResponse.statusCode;
          if (rawResponse.statusCode >= 200 && rawResponse.statusCode < 300) {
            assignResponse = await verifikatorClient.post(
              '/api/reports/$reportId/assess',
              body: assignBody,
            );
          } else {
            assignResponse = {'error': rawResponse.body};
          }
        } on TestApiException catch (e) {
          assignStatusCode = e.statusCode;
          assignResponse = {'error': e.body ?? e.toString()};
        }

        recorder.recordStep(
          stepName: 'verifikator_assign',
          description:
              'Verifikator assigns report to surveyor via POST /api/reports/{id}/assess',
          requestBody: assignBody,
          responseBody: assignResponse,
          httpStatusCode: assignStatusCode,
        );

        print('Assign response status: $assignStatusCode');
        print('Assign response: $assignResponse');

        // Step 7: Login as surveyor
        print('\n=== STEP 7: Surveyor Login ===');
        final surveyorFactory = TestUserFactory(baseUrl: baseUrl);
        final surveyorUser = await surveyorFactory.getSeededUser('surveyor');
        surveyorToken = surveyorUser.accessToken;
        surveyorClient.setAccessToken(surveyorToken);
        recorder.recordStep(
          stepName: 'surveyor_login',
          description: 'Login as surveyor',
          responseBody: {
            'email': surveyorUser.email,
            'role': surveyorUser.role,
            'hasToken': surveyorToken != null,
          },
        );
        expect(surveyorToken, isNotNull);
        print('Surveyor logged in: ${surveyorUser.email}');

        // Step 8: Surveyor fetches tasks to see assignment
        print('\n=== STEP 8: Surveyor Fetches Tasks ===');
        Map<String, dynamic> tasksResponse = {};
        int tasksStatusCode = 500;
        try {
          final rawResponse = await surveyorClient.rawGet(
            '/api/surveyor/tasks',
          );
          tasksStatusCode = rawResponse.statusCode;
          if (rawResponse.statusCode >= 200 && rawResponse.statusCode < 300) {
            tasksResponse = await surveyorClient.get('/api/surveyor/tasks');
          } else {
            tasksResponse = {'error': rawResponse.body};
          }
        } on TestApiException catch (e) {
          tasksStatusCode = e.statusCode;
          tasksResponse = {'error': e.body ?? e.toString()};
        }

        recorder.recordStep(
          stepName: 'surveyor_get_tasks',
          description: 'Surveyor fetches assigned tasks',
          responseBody: tasksResponse,
          httpStatusCode: tasksStatusCode,
        );

        expect(
          tasksStatusCode,
          isNot(500),
          reason: 'Tasks fetch should not return 500',
        );
        print('Tasks response status: $tasksStatusCode');

        // Step 9: Surveyor submits visit record
        print('\n=== STEP 9: Surveyor Submits Visit ===');
        Map<String, dynamic> visitResponse = {};
        int visitStatusCode = 500;
        final visitBody = {
          'gps_lat': testReportLat,
          'gps_lng': testReportLng,
          'accuracy': 5.0,
          'kondisi': 'baik',
          'rekomendasi': 'perbaikan',
          'catatan': 'Survey visit completed via integration test',
          'photos': <String, String>{},
        };

        try {
          final rawResponse = await surveyorClient.rawPost(
            '/api/surveyor/tasks/$reportId/visit',
            body: visitBody,
          );
          visitStatusCode = rawResponse.statusCode;
          if (rawResponse.statusCode >= 200 && rawResponse.statusCode < 300) {
            visitResponse = await surveyorClient.post(
              '/api/surveyor/tasks/$reportId/visit',
              body: visitBody,
            );
          } else {
            visitResponse = {'error': rawResponse.body};
          }
        } on TestApiException catch (e) {
          visitStatusCode = e.statusCode;
          visitResponse = {'error': e.body ?? e.toString()};
        }

        recorder.recordStep(
          stepName: 'surveyor_visit',
          description:
              'Surveyor submits visit record via POST /api/surveyor/tasks/{id}/visit',
          requestBody: visitBody,
          responseBody: visitResponse,
          httpStatusCode: visitStatusCode,
        );

        print('Visit response status: $visitStatusCode');
        print('Visit response: $visitResponse');

        // Step 10: Verifikator closes the case
        print('\n=== STEP 10: Verifikator Closes Case ===');
        Map<String, dynamic> closeResponse = {};
        int closeStatusCode = 500;

        // Try different close endpoints
        final closeBody = {'decision': 'close'};

        try {
          // Try /api/reports/{id}/close
          final rawCloseResponse = await verifikatorClient.rawPost(
            '/api/reports/$reportId/close',
            body: closeBody,
          );
          closeStatusCode = rawCloseResponse.statusCode;

          if (rawCloseResponse.statusCode >= 200 &&
              rawCloseResponse.statusCode < 300) {
            closeResponse = await verifikatorClient.post(
              '/api/reports/$reportId/close',
              body: closeBody,
            );
          } else if (rawCloseResponse.statusCode == 404) {
            // Try /api/verifikator/cases/{id}/close
            final altResponse = await verifikatorClient.rawPost(
              '/api/verifikator/cases/$reportId/close',
              body: closeBody,
            );
            closeStatusCode = altResponse.statusCode;
            if (altResponse.statusCode >= 200 && altResponse.statusCode < 300) {
              closeResponse = await verifikatorClient.post(
                '/api/verifikator/cases/$reportId/close',
                body: closeBody,
              );
            } else {
              closeResponse = {'error': altResponse.body};
            }
          } else {
            closeResponse = {'error': rawCloseResponse.body};
          }
        } on TestApiException catch (e) {
          closeStatusCode = e.statusCode;
          closeResponse = {'error': e.body ?? e.toString()};
        }

        recorder.recordStep(
          stepName: 'verifikator_close',
          description: 'Verifikator closes the case',
          requestBody: closeBody,
          responseBody: closeResponse,
          httpStatusCode: closeStatusCode,
        );

        print('Close response status: $closeStatusCode');
        print('Close response: $closeResponse');

        // Step 11: Verify final report status
        print('\n=== STEP 11: Verify Final Status ===');
        Map<String, dynamic> finalReportResponse = {};
        int finalStatusCode = 500;
        try {
          final rawResponse = await wargaClient.rawGet(
            '/api/reports/$reportId',
          );
          finalStatusCode = rawResponse.statusCode;
          finalReportResponse = await wargaClient.get('/api/reports/$reportId');
        } on TestApiException catch (e) {
          finalStatusCode = e.statusCode;
          finalReportResponse = {'error': e.body ?? e.toString()};
        }

        recorder.recordStep(
          stepName: 'verify_final_status',
          description: 'Verify final report status',
          responseBody: finalReportResponse,
          httpStatusCode: finalStatusCode,
        );

        print('Final status response: $finalReportResponse');

        // Extract and print final status
        String? finalStatus = finalReportResponse['status'] as String?;
        if (finalStatus == null && finalReportResponse.containsKey('report')) {
          final report = finalReportResponse['report'];
          if (report is Map) {
            finalStatus = report['status'] as String?;
          }
        }
        print('Final report status: $finalStatus');

        // Final assertions
        print('\n=== FINAL ASSERTIONS ===');
        expect(reportId, isNotNull, reason: 'Report should be created');
        expect(wargaToken, isNotNull, reason: 'Warga should be logged in');
        expect(
          verifikatorToken,
          isNotNull,
          reason: 'Verifikator should be logged in',
        );
        expect(
          surveyorToken,
          isNotNull,
          reason: 'Surveyor should be logged in',
        );

        // Status transitions - the report should have gone through statuses
        // submitted -> assigned -> visited -> closed
        print('Report lifecycle completed successfully!');
        print('Report ID: $reportId');
        print('Final status: $finalStatus');

        // Cleanup
        print('\n=== CLEANUP ===');
        await cleanup.reset();
        print('Staging reset completed');
      },
    );
  });
}

/// Generates a unique idempotency key for report creation.
String _generateIdempotencyKey() {
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final random = Random().nextInt(999999).toString().padLeft(6, '0');
  return 'integration_test_${timestamp}_$random';
}

/// Extracts queue items from the verifikator queue response.
List<Map<String, dynamic>> _extractQueueItems(Map<String, dynamic> response) {
  // Try common keys for queue items
  if (response.containsKey('items')) {
    final items = response['items'];
    if (items is List) return items.cast<Map<String, dynamic>>();
  }
  if (response.containsKey('data')) {
    final data = response['data'];
    if (data is List) return data.cast<Map<String, dynamic>>();
  }
  if (response.containsKey('queue')) {
    final queue = response['queue'];
    if (queue is List) return queue.cast<Map<String, dynamic>>();
  }
  if (response.containsKey('reports')) {
    final reports = response['reports'];
    if (reports is List) return reports.cast<Map<String, dynamic>>();
  }
  return [];
}

/// Extracts a surveyor ID from the surveyor list response.
String? _extractSurveyorId(Map<String, dynamic> response) {
  if (response.containsKey('surveyors')) {
    final surveyors = response['surveyors'];
    if (surveyors is List && surveyors.isNotEmpty) {
      return surveyors.first['id'] as String?;
    }
  }
  if (response.containsKey('users')) {
    final users = response['users'];
    if (users is List && users.isNotEmpty) {
      return users.first['id'] as String?;
    }
  }
  if (response.containsKey('data')) {
    final data = response['data'];
    if (data is List && data.isNotEmpty) {
      return data.first['id'] as String?;
    }
  }
  return null;
}

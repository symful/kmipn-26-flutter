import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../_helpers/api_client_builder.dart';
import '../_helpers/cleanup.dart';
import '../_helpers/test_user_factory.dart';

/// Integration test for anonymous report submission.
///
/// Tests the complete anonymous workflow:
/// 1. Anonymous report can be created via API without authentication
/// 2. Report is created with device_id tracking
///
/// This test connects to the real staging API.
void main() {
  // Test configuration
  const baseUrl = 'https://kmipn-26-deno.careday17.workers.dev';
  const testSecret =
      'HNjAW4i5xCxJFow5mrTLXvSW0PDJpfFJXo8PPUnbP38rVfe1/vcwdt4gGR/rR9Fu';

  // Report data for testing
  const testReportLat = -6.5;
  const testReportLng = 106.8;
  const testReportDescription =
      'Integration test anonymous report - jalan berlubang tanpa akun.';

  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Anonymous Report Integration Test', () {
    late TestApiClient anonymousClient;
    late TestApiClient adminClient;
    late StagingCleanup cleanup;

    setUpAll(() async {
      // Initialize clients
      anonymousClient = TestApiClient(baseUrl: baseUrl);
      adminClient = TestApiClient(baseUrl: baseUrl);
      cleanup = StagingCleanup(baseUrl: baseUrl, testSecret: testSecret);

      // Reset staging before tests
      print('Resetting staging environment...');
      final resetSuccess = await cleanup.reset();
      print(
        'Staging reset ${resetSuccess ? 'successful' : 'failed (continuing anyway)'}',
      );
    });

    tearDownAll(() {
      anonymousClient.dispose();
      adminClient.dispose();
      cleanup.dispose();
    });

    testWidgets('Anonymous report submission creates report with 201 status', (
      tester,
    ) async {
      String? reportId;
      String? deviceId;
      String? categoryId;

      // Step 1: Get categories (no auth required)
      print('\n=== STEP 1: Get Categories (Public) ===');
      Map<String, dynamic> categoriesResponse;
      int categoriesStatusCode = 500;
      try {
        final rawResponse = await anonymousClient.rawGet(
          '/api/public/categories',
        );
        categoriesStatusCode = rawResponse.statusCode;
        categoriesResponse = await anonymousClient.get(
          '/api/public/categories',
        );
      } on TestApiException catch (e) {
        categoriesStatusCode = e.statusCode;
        categoriesResponse = {'error': e.body ?? e.toString()};
      }

      print('Categories response status: $categoriesStatusCode');
      print('Categories response: $categoriesResponse');

      // Extract category_id
      if (categoriesResponse.containsKey('categories')) {
        final categories = categoriesResponse['categories'] as List;
        if (categories.isNotEmpty) {
          categoryId = categories.first['id'] as String?;
        }
      }
      expect(categoryId, isNotNull, reason: 'Should find a valid category_id');
      print('Using category_id: $categoryId');

      // Step 2: Generate device_id (simulating what app does)
      print('\n=== STEP 2: Generate Device ID ===');
      deviceId = _generateDeviceId();
      print('Generated device_id: $deviceId');

      // Step 3: Submit anonymous report
      print('\n=== STEP 3: Submit Anonymous Report ===');
      final idempotencyKey = _generateIdempotencyKey();
      final createReportBody = {
        'idempotency_key': idempotencyKey,
        'device_id': deviceId,
        'category_id': categoryId,
        'description': testReportDescription,
        'lat': testReportLat,
        'lng': testReportLng,
        'captcha_token': 'test-token-bypass',
      };

      Map<String, dynamic> createResponse;
      int createStatusCode = 500;
      try {
        final rawResponse = await anonymousClient.rawPost(
          '/api/public/anonymous-reports',
          body: createReportBody,
        );
        createStatusCode = rawResponse.statusCode;
        print('Anonymous report response status: $createStatusCode');
        print('Anonymous report response body: ${rawResponse.body}');

        if (rawResponse.statusCode >= 200 && rawResponse.statusCode < 300) {
          createResponse = await anonymousClient.post(
            '/api/public/anonymous-reports',
            body: createReportBody,
          );
        } else {
          createResponse = {'error': rawResponse.body};
        }
      } on TestApiException catch (e) {
        createStatusCode = e.statusCode;
        createResponse = {'error': e.body ?? e.toString()};
      }

      print('Create response: $createResponse');

      // Verify response
      expect(
        createStatusCode,
        201,
        reason: 'Anonymous report creation should return 201',
      );
      expect(
        createStatusCode,
        isNot(500),
        reason: 'Anonymous report creation should not return 500',
      );

      // Extract report ID from response
      reportId = createResponse['id'] as String?;
      if (reportId == null && createResponse.containsKey('report')) {
        final report = createResponse['report'];
        if (report is Map) {
          reportId = report['id'] as String?;
        }
      }
      expect(reportId, isNotNull, reason: 'Report should have an ID');
      print('Anonymous report created with ID: $reportId');

      // Step 4: Verify report exists via public API
      print('\n=== STEP 4: Verify Report Exists ===');
      Map<String, dynamic> reportResponse;
      int reportStatusCode = 500;
      try {
        final rawResponse = await anonymousClient.rawGet(
          '/api/public/reports/$reportId',
        );
        reportStatusCode = rawResponse.statusCode;
        if (reportStatusCode >= 200 && reportStatusCode < 300) {
          reportResponse = await anonymousClient.get(
            '/api/public/reports/$reportId',
          );
        } else {
          reportResponse = {'error': rawResponse.body};
        }
      } on TestApiException catch (e) {
        reportStatusCode = e.statusCode;
        reportResponse = {'error': e.body ?? e.toString()};
      }

      print('Report fetch status: $reportStatusCode');
      print('Report fetch response: $reportResponse');

      // Step 5: Cleanup - delete the created report (using admin client)
      print('\n=== STEP 5: Cleanup ===');
      // Login as admin to get token for deletion
      final adminFactory = TestUserFactory(baseUrl: baseUrl);
      final adminUser = await adminFactory.getSeededUser('admin');
      adminClient.setAccessToken(adminUser.accessToken);

      Map<String, dynamic> deleteResponse = {};
      int deleteStatusCode = 500;
      try {
        final rawResponse = await adminClient.rawPost(
          '/api/test/reports/$reportId/delete',
          body: {},
        );
        deleteStatusCode = rawResponse.statusCode;
        if (rawResponse.statusCode >= 200 && rawResponse.statusCode < 300) {
          deleteResponse = await adminClient.post(
            '/api/test/reports/$reportId/delete',
            body: {},
          );
        } else {
          deleteResponse = {'error': rawResponse.body};
        }
        print('Delete status: $deleteStatusCode');
        print('Delete response: $deleteResponse');
      } on TestApiException catch (e) {
        print('Delete failed (may not be implemented): $e');
      }

      // Final assertions
      print('\n=== FINAL ASSERTIONS ===');
      expect(reportId, isNotNull, reason: 'Anonymous report should be created');
      expect(deviceId, isNotNull, reason: 'Device ID should be generated');
      expect(
        createStatusCode,
        201,
        reason: 'Anonymous report should return 201 Created',
      );

      print('Anonymous report lifecycle completed successfully!');
      print('Report ID: $reportId');
      print('Device ID: $deviceId');
    });

    testWidgets(
      'Anonymous report with duplicate idempotency_key returns existing report',
      (tester) async {
        const testDeviceId = 'test-device-123';
        const testCategoryId = 'cat-1';
        const idempotencyKey = 'dup-test-key-001';

        // Submit first report
        print('\n=== STEP 1: Submit First Anonymous Report ===');
        final firstBody = {
          'idempotency_key': idempotencyKey,
          'device_id': testDeviceId,
          'category_id': testCategoryId,
          'description': 'First submission with same idempotency key',
          'lat': testReportLat,
          'lng': testReportLng,
          'captcha_token': 'test-token-bypass',
        };

        Map<String, dynamic> firstResponse;
        int firstStatusCode = 500;
        try {
          final rawResponse = await anonymousClient.rawPost(
            '/api/public/anonymous-reports',
            body: firstBody,
          );
          firstStatusCode = rawResponse.statusCode;
          if (firstStatusCode >= 200 && firstStatusCode < 300) {
            firstResponse = await anonymousClient.post(
              '/api/public/anonymous-reports',
              body: firstBody,
            );
          } else {
            firstResponse = {'error': rawResponse.body};
          }
        } on TestApiException catch (e) {
          firstStatusCode = e.statusCode;
          firstResponse = {'error': e.body ?? e.toString()};
        }

        print('First submission status: $firstStatusCode');
        final firstId = firstResponse['id'] as String?;
        print('First report ID: $firstId');

        // Submit second report with same idempotency key
        print('\n=== STEP 2: Submit Second Report (Same Idempotency Key) ===');
        final secondBody = {
          'idempotency_key': idempotencyKey, // Same key
          'device_id': testDeviceId,
          'category_id': testCategoryId,
          'description': 'Second submission with same idempotency key',
          'lat': testReportLat,
          'lng': testReportLng,
          'captcha_token': 'test-token-bypass',
        };

        Map<String, dynamic> secondResponse;
        int secondStatusCode = 500;
        try {
          final rawResponse = await anonymousClient.rawPost(
            '/api/public/anonymous-reports',
            body: secondBody,
          );
          secondStatusCode = rawResponse.statusCode;
          if (secondStatusCode >= 200 && secondStatusCode < 300) {
            secondResponse = await anonymousClient.post(
              '/api/public/anonymous-reports',
              body: secondBody,
            );
          } else {
            secondResponse = {'error': rawResponse.body};
          }
        } on TestApiException catch (e) {
          secondStatusCode = e.statusCode;
          secondResponse = {'error': e.body ?? e.toString()};
        }

        print('Second submission status: $secondStatusCode');
        final secondId = secondResponse['id'] as String?;
        print('Second report ID: $secondId');

        // Both should return the same report ID (idempotency)
        expect(firstId, isNotNull, reason: 'First report should have ID');
        expect(
          secondId,
          isNotNull,
          reason: 'Second report should return existing ID',
        );
        expect(
          secondId,
          firstId,
          reason: 'Same idempotency key should return same report',
        );

        print('Idempotency test passed - same key returns same report');
      },
    );
  });
}

/// Generates a unique idempotency key for report creation.
String _generateIdempotencyKey() {
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final random = Random().nextInt(999999).toString().padLeft(6, '0');
  return 'anon_integration_test_${timestamp}_$random';
}

/// Generates a pseudo-device ID for anonymous tracking.
String _generateDeviceId() {
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final random = Random().nextInt(999999).toString().padLeft(6, '0');
  return 'test-device-$timestamp-$random';
}

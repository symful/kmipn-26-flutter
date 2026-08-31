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
  late ApiClient wargaClient;
  late String testCatId;

  setUpAll(() async {
    // Login as warga — fail loudly if this doesn't work
    final tokens = await _login('warga@sigap.id', 'warga123');
    wargaClient = ApiClient(
      baseUrl: _apiBaseUrl,
      testAccessToken: tokens.accessToken,
    );

    // Fetch a category to use in tests
    final cats = await wargaClient.getCategories();
    expect(cats, isNotEmpty, reason: 'categories list should not be empty');
    testCatId = cats.first.id!;
    expect(
      testCatId,
      isNotEmpty,
      reason: 'test category id should not be empty',
    );
  });

  group('warga report flow', () {
    test('submitReport returns id and status', () async {
      final result = await wargaClient.submitReport(
        idempotencyKey:
            'TEST_${testRunId}_create_${DateTime.now().millisecondsSinceEpoch}',
        categoryId: testCatId,
        description: 'TEST_${testRunId}_warga_desc',
        lat: -6.2,
        lng: 106.8,
      );
      expect(result.id, isNotNull, reason: 'report id should not be null');
      expect(result.id, isNotEmpty, reason: 'report id should not be empty');
      expect(
        result.status,
        isA<String>(),
        reason: 'report status should be string',
      );
    });

    test('getReports returns paginated list of reports', () async {
      final result = await wargaClient.getReports();
      expect(
        result.data,
        isA<List<Report>>(),
        reason: 'result data should be List<Report>',
      );
      expect(
        result.data,
        isNotEmpty,
        reason: 'reports list should not be empty',
      );
      final first = result.data.first;
      expect(first.id, isNotNull, reason: 'report id should not be null');
    });

    test('getMyReports returns warga reports', () async {
      final result = await wargaClient.getMyReports();
      expect(
        result.items,
        isA<List<Report>>(),
        reason: 'result items should be List<Report>',
      );
    });

    test('getReportTimeline returns timeline events', () async {
      // First create a report to get its id
      final createRes = await wargaClient.submitReport(
        idempotencyKey:
            'TEST_${testRunId}_timeline_${DateTime.now().millisecondsSinceEpoch}',
        categoryId: testCatId,
        description: 'TEST_${testRunId}_timeline_desc',
        lat: -6.2,
        lng: 106.8,
      );
      expect(createRes.id, isNotNull, reason: 'created report should have id');

      final timeline = await wargaClient.getReportTimeline(createRes.id!);
      expect(
        timeline.events,
        isNotNull,
        reason: 'timeline events should not be null',
      );
      expect(
        timeline.events,
        isA<List<TimelineEvent>>(),
        reason: 'timeline events should be List<TimelineEvent>',
      );
    });

    test('getNearbyReports returns reports near coordinates', () async {
      final nearby = await wargaClient.getNearbyReports(lat: -6.2, lng: 106.8);
      expect(
        nearby,
        isA<List<NearbyReport>>(),
        reason: 'nearby should be List<NearbyReport>',
      );
      for (final r in nearby) {
        expect(r.id, isNotNull, reason: 'nearby report id should not be null');
        expect(r.distance, isNotNull, reason: 'distance should not be null');
      }
    });

    test('getSimilarReports returns similar report candidates', () async {
      final cats = await wargaClient.getCategories();
      expect(cats, isNotEmpty, reason: 'categories should not be empty');
      final similar = await wargaClient.getSimilarReports(
        lat: -6.2,
        lng: 106.8,
        categoryId: cats.first.id!,
      );
      expect(
        similar,
        isA<List<SimilarReport>>(),
        reason: 'similar reports should be List<SimilarReport>',
      );
    });

    test('submitReport with invalid coordinates throws', () async {
      expect(
        () => wargaClient.submitReport(
          idempotencyKey:
              'TEST_${testRunId}_badcoord_${DateTime.now().millisecondsSinceEpoch}',
          categoryId: testCatId,
          description: 'TEST_${testRunId}_badcoord_desc',
          lat: 999, // invalid latitude
          lng: 999, // invalid longitude
        ),
        throwsA(anything),
        reason: 'invalid coordinates should throw exception',
      );
    });

    test('reportAction(close) returns status or 404 for warga role', () async {
      final createRes = await wargaClient.submitReport(
        idempotencyKey:
            'TEST_${testRunId}_close_${DateTime.now().millisecondsSinceEpoch}',
        categoryId: testCatId,
        description: 'TEST_${testRunId}_close_desc',
        lat: -6.2,
        lng: 106.8,
      );
      expect(createRes.id, isNotNull, reason: 'created report should have id');

      // warga role may get 404 for close action — both are acceptable
      try {
        final closeRes = await wargaClient.reportAction(
          reportId: createRes.id!,
          action: 'close',
        );
        expect(
          closeRes.status,
          isA<String>(),
          reason: 'close action status should be string',
        );
      } on ApiException catch (e) {
        // 404 is expected for warga role; allow it
        expect(
          e.statusCode,
          equals(404),
          reason: 'expected 404 for warga close action, got ${e.statusCode}',
        );
      }
    });
  });
}

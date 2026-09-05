import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sigap/api/client.dart';
import '../helpers/api_expect.dart';
import '../helpers/test_env.dart';

const _apiBaseUrl = 'https://sigap.live';

/// HTTP client helper using dart:io HttpClient (works in Flutter test on Windows).
Future<Map<String, dynamic>> _httpJson(
  String method,
  String path, {
  Object? body,
  Map<String, String>? headers,
}) async {
  final uri = Uri.parse('$_apiBaseUrl$path');
  final client = HttpClient();
  HttpClientRequest req;
  if (method == 'POST') {
    req = await client.postUrl(uri);
  } else {
    req = await client.getUrl(uri);
  }
  req.headers.set('Content-Type', 'application/json');
  if (headers != null) {
    headers.forEach((k, v) => req.headers.set(k, v));
  }
  if (body != null) {
    req.write(jsonEncode(body));
  }
  final resp = await req.close();
  final bodyStr = await resp.transform(utf8.decoder).join();
  if (resp.statusCode >= 400) {
    throw Exception('HTTP ${resp.statusCode}: $bodyStr');
  }
  return jsonDecode(bodyStr) as Map<String, dynamic>;
}

/// Authenticates and returns tokens. Throws if login fails so setUpAll fails loudly.
Future<({String accessToken, String refreshToken})> _login(
  String email,
  String password,
) async {
  // Use dart:io HttpClient directly - Dio has issues in Flutter test on Windows
  final delays = [2000, 3000, 5000, 7000, 8000];
  String? lastError;
  for (int attempt = 0; attempt < 5; attempt++) {
    try {
      final data = await _httpJson(
        'POST',
        '/api/auth/login',
        body: {'email': email, 'password': password},
      );
      final token = data['accessToken'] ?? data['access_token'];
      final refresh = data['refreshToken'] ?? data['refresh_token'];
      expect(token, isNotNull, reason: 'login returned null access token');
      expect(token, isNotEmpty, reason: 'login returned empty access token');
      expect(refresh, isNotNull, reason: 'login returned null refresh token');
      return (accessToken: token as String, refreshToken: refresh as String);
    } catch (e) {
      lastError = e.toString();
      // Check if it's a rate limit error
      if (lastError.contains('429') && attempt < delays.length) {
        final jitter = DateTime.now().millisecondsSinceEpoch % 500;
        await Future.delayed(Duration(milliseconds: delays[attempt] + jitter));
        continue;
      }
      rethrow;
    }
  }
  throw Exception(
    'loginWithBackoff: rate-limited after 5 attempts. Last error: $lastError',
  );
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
      checkConnectivity: () async {}, // skip connectivity check in tests
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
    test('submitReport returns id and duplicate', () async {
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
        result.duplicate,
        isA<bool>(),
        reason: 'duplicate flag should be bool',
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

    test('reportAction(close) returns 403 FORBIDDEN for warga role', () async {
      final createRes = await wargaClient.submitReport(
        idempotencyKey:
            'TEST_${testRunId}_close_${DateTime.now().millisecondsSinceEpoch}',
        categoryId: testCatId,
        description: 'TEST_${testRunId}_close_desc',
        lat: -6.2,
        lng: 106.8,
      );
      expect(createRes.id, isNotNull, reason: 'created report should have id');

      await expectApiError(
        () =>
            wargaClient.reportAction(reportId: createRes.id!, action: 'close'),
        403,
        context: 'warga close via reportAction',
      );
    });
  });
}

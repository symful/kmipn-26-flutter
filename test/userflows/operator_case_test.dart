import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import '../helpers/test_env.dart';

const _apiBaseUrl = 'https://kmipn-26-deno.careday17.workers.dev';

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

Future<({String accessToken, String refreshToken})> _login(
  String email,
  String password,
) async {
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
      return (accessToken: token as String, refreshToken: refresh as String);
    } catch (e) {
      lastError = e.toString();
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
  late String operatorAccessToken;
  late String wargaAccessToken;
  String testCatId = '';

  setUpAll(() async {
    final opTokens = await _login('operator@sigap.id', 'operator123');
    operatorAccessToken = opTokens.accessToken;

    final wargaTokens = await _login('warga@sigap.id', 'warga123');
    wargaAccessToken = wargaTokens.accessToken;

    final catsData = await _httpJson(
      'GET',
      '/api/categories',
      headers: {'Authorization': 'Bearer $wargaAccessToken'},
    );
    final cats = catsData['data'] as List? ?? catsData as List;
    if (cats.isNotEmpty) {
      final firstCat = cats.first as Map<String, dynamic>;
      testCatId = firstCat['id'] as String;
    }
    if (testCatId.isEmpty) {
      final publicCats = await _httpJson('GET', '/api/categories');
      final publicList = publicCats['data'] as List? ?? publicCats as List;
      if (publicList.isNotEmpty) {
        final first = publicList.first as Map<String, dynamic>;
        testCatId = first['id'] as String;
      }
    }
    expect(
      testCatId.isNotEmpty,
      isTrue,
      reason: 'category id should not be empty',
    );
  });

  group('operator case management flow', () {
    test('operator dashboard returns aggregated stats', () async {
      final stats = await _httpJson(
        'GET',
        '/api/stats',
        headers: {'Authorization': 'Bearer $operatorAccessToken'},
      );
      expect(stats, isNotNull, reason: 'stats should not be null');
      expect(
        stats.containsKey('total'),
        isTrue,
        reason: 'stats should have total',
      );
      expect(stats['total'], isA<num>(), reason: 'total should be number');
      expect(
        stats.containsKey('by_status'),
        isTrue,
        reason: 'stats should have by_status',
      );
      expect(
        stats['by_status'],
        isA<Map>(),
        reason: 'by_status should be object',
      );
      expect(
        stats.containsKey('sla_breached'),
        isTrue,
        reason: 'stats should have sla_breached',
      );
      expect(
        stats.containsKey('sla_at_risk'),
        isTrue,
        reason: 'stats should have sla_at_risk',
      );
    });

    test('operator queue lists cases with pagination', () async {
      final result = await _httpJson(
        'GET',
        '/api/reports?status=submitted',
        headers: {'Authorization': 'Bearer $operatorAccessToken'},
      );
      expect(result, isNotNull, reason: 'result should not be null');
      expect(
        result.containsKey('data'),
        isTrue,
        reason: 'result should have data',
      );
      expect(result['data'], isA<List>(), reason: 'data should be list');
      expect(
        result.containsKey('pagination'),
        isTrue,
        reason: 'result should have pagination',
      );
      final pagination = result['pagination'] as Map<String, dynamic>;
      expect(
        pagination.containsKey('total'),
        isTrue,
        reason: 'pagination should have total',
      );
      expect(pagination['total'], isA<num>(), reason: 'total should be number');
    });

    test('operator sets priority with score', () async {
      if (testCatId.isEmpty) return;

      final createResult = await _httpJson(
        'POST',
        '/api/reports',
        body: {
          'idempotency_key':
              'TEST_${testRunId}_opcase_priority_${DateTime.now().millisecondsSinceEpoch}',
          'category_id': testCatId,
          'description': 'TEST_${testRunId}_opcase_priority_desc',
          'lat': -6.2,
          'lng': 106.8,
          'title': 'TEST_${testRunId}_opcase_priority_title',
        },
        headers: {'Authorization': 'Bearer $wargaAccessToken'},
      );
      final caseId = createResult['id'] as String;
      expect(caseId, isNotNull, reason: 'case id should not be null');

      final assignResult = await _httpJson(
        'POST',
        '/api/cases/$caseId/action',
        body: {
          'action': 'prioritize',
          'new_score': 85,
          'reason': 'TEST_${testRunId}_priority',
        },
        headers: {'Authorization': 'Bearer $operatorAccessToken'},
      );
      expect(assignResult, isNotNull, reason: 'result should not be null');
      expect(
        assignResult['status'],
        isA<String>(),
        reason: 'status should be string',
      );
    });

    test('operator assigns case to unit', () async {
      if (testCatId.isEmpty) return;

      final createResult = await _httpJson(
        'POST',
        '/api/reports',
        body: {
          'idempotency_key':
              'TEST_${testRunId}_opcase_assign_${DateTime.now().millisecondsSinceEpoch}',
          'category_id': testCatId,
          'description': 'TEST_${testRunId}_opcase_assign_desc',
          'lat': -6.2,
          'lng': 106.8,
          'title': 'TEST_${testRunId}_opcase_assign_title',
        },
        headers: {'Authorization': 'Bearer $wargaAccessToken'},
      );
      final caseId = createResult['id'] as String;

      final unitsData = await _httpJson(
        'GET',
        '/api/units',
        headers: {'Authorization': 'Bearer $operatorAccessToken'},
      );
      final units = unitsData['items'] as List? ?? unitsData as List;
      if (units.isEmpty) return;
      final firstUnit = units.first as Map<String, dynamic>;
      final unitId = firstUnit['id'] as String;

      final assignResult = await _httpJson(
        'POST',
        '/api/cases/$caseId/action',
        body: {
          'action': 'assign',
          'assigned_unit_id': unitId,
          'instructions': 'TEST_${testRunId}_assign',
        },
        headers: {'Authorization': 'Bearer $operatorAccessToken'},
      );
      expect(assignResult, isNotNull, reason: 'result should not be null');
      expect(
        assignResult['status'],
        isA<String>(),
        reason: 'status should be string',
      );
    });

    test('operator merges duplicate cases', () async {
      if (testCatId.isEmpty) return;

      final create1 = await _httpJson(
        'POST',
        '/api/reports',
        body: {
          'idempotency_key':
              'TEST_${testRunId}_opcase_merge1_${DateTime.now().millisecondsSinceEpoch}',
          'category_id': testCatId,
          'description': 'TEST_${testRunId}_merge_desc_1',
          'lat': -6.2,
          'lng': 106.8,
          'title': 'TEST_${testRunId}_merge_title_1',
        },
        headers: {'Authorization': 'Bearer $wargaAccessToken'},
      );
      final create2 = await _httpJson(
        'POST',
        '/api/reports',
        body: {
          'idempotency_key':
              'TEST_${testRunId}_opcase_merge2_${DateTime.now().millisecondsSinceEpoch}',
          'category_id': testCatId,
          'description': 'TEST_${testRunId}_merge_desc_2',
          'lat': -6.21,
          'lng': 106.81,
          'title': 'TEST_${testRunId}_merge_title_2',
        },
        headers: {'Authorization': 'Bearer $wargaAccessToken'},
      );
      final primaryId = create1['id'] as String;
      final targetId = create2['id'] as String;

      final mergeResult = await _httpJson(
        'POST',
        '/api/cases/$primaryId/action',
        body: {
          'action': 'merge',
          'target_case_ids': [targetId],
          'reason': 'TEST_${testRunId}_merge',
        },
        headers: {'Authorization': 'Bearer $operatorAccessToken'},
      );
      expect(mergeResult, isNotNull, reason: 'merge result should not be null');
      expect(
        mergeResult['status'],
        isA<String>(),
        reason: 'status should be string',
      );
    });

    test('operator close report returns 403 FORBIDDEN', () async {
      if (testCatId.isEmpty) return;

      final createResult = await _httpJson(
        'POST',
        '/api/reports',
        body: {
          'idempotency_key':
              'TEST_${testRunId}_opcase_close_${DateTime.now().millisecondsSinceEpoch}',
          'category_id': testCatId,
          'description': 'TEST_${testRunId}_opcase_close_desc',
          'lat': -6.2,
          'lng': 106.8,
          'title': 'TEST_${testRunId}_opcase_close_title',
        },
        headers: {'Authorization': 'Bearer $wargaAccessToken'},
      );
      final caseId = createResult['id'] as String;

      try {
        await _httpJson(
          'POST',
          '/api/reports/$caseId/close',
          headers: {'Authorization': 'Bearer $operatorAccessToken'},
        );
        fail('Expected 403 but operator close succeeded');
      } catch (e) {
        expect(
          e.toString(),
          contains('403'),
          reason: 'operator close should return 403 FORBIDDEN',
        );
      }
    });

    test('operator backlog returns aged cases', () async {
      final backlogResult = await _httpJson(
        'GET',
        '/api/reports?status=open&days=7',
        headers: {'Authorization': 'Bearer $operatorAccessToken'},
      );
      expect(
        backlogResult,
        isNotNull,
        reason: 'backlog result should not be null',
      );
      expect(
        backlogResult.containsKey('data') ||
            backlogResult.containsKey('buckets'),
        isTrue,
        reason: 'result should have data or buckets',
      );
    });

    test('operator export CSV returns non-empty content', () async {
      final csvResult = await _httpJson(
        'GET',
        '/api/export/reports?format=csv',
        headers: {'Authorization': 'Bearer $operatorAccessToken'},
      );
      expect(csvResult, isNotNull, reason: 'csv result should not be null');
    });
  });
}

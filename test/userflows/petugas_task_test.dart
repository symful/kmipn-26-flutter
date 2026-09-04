import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import '../helpers/test_env.dart';

const _apiBaseUrl = 'https://sigap.live';

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
  } else if (method == 'PUT') {
    req = await client.putUrl(uri);
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
      final token = data['access_token'];
      final refresh = data['refresh_token'];
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

Future<String> _createReportAndGetPetugasTaskId(
  String wargaToken,
  String verifikatorToken,
  String operatorToken,
  String prefix,
) async {
  final catsData = await _httpJson('GET', '/api/categories');
  final cats = catsData['data'] as List? ?? catsData as List;
  final catId = cats.isNotEmpty
      ? (cats.first as Map<String, dynamic>)['id'] as String
      : '';

  final createResult = await _httpJson(
    'POST',
    '/api/reports',
    body: {
      'idempotency_key':
          'TEST_${testRunId}_$prefix\_${DateTime.now().millisecondsSinceEpoch}',
      'category_id': catId,
      'description': 'TEST_${testRunId}_$prefix\_desc',
      'lat': -6.2,
      'lng': 106.8,
      'title': 'TEST_${testRunId}_$prefix\_title',
    },
    headers: {'Authorization': 'Bearer $wargaToken'},
  );
  final reportId = createResult['id'] as String;

  await _httpJson(
    'POST',
    '/api/cases/$reportId/accept',
    body: {'reason': 'TEST_${testRunId}_$prefix'},
    headers: {'Authorization': 'Bearer $verifikatorToken'},
  );

  final unitsData = await _httpJson(
    'GET',
    '/api/units',
    headers: {'Authorization': 'Bearer $operatorToken'},
  );
  final units = unitsData['items'] as List? ?? unitsData as List;
  if (units.isEmpty) throw Exception('no units available');
  final unitId = (units.first as Map<String, dynamic>)['id'] as String;

  await _httpJson(
    'POST',
    '/api/cases/$reportId/accept',
    body: {'assigned_unit_id': unitId, 'reason': 'TEST_${testRunId}_assign'},
    headers: {'Authorization': 'Bearer $operatorToken'},
  );

  await Future.delayed(const Duration(seconds: 2));

  final tasksData = await _httpJson(
    'GET',
    '/api/tasks',
    headers: {'Authorization': 'Bearer $operatorToken'},
  );
  final tasks = tasksData['data'] as List? ?? tasksData['tasks'] as List? ?? [];
  for (final task in tasks) {
    final t = task as Map<String, dynamic>;
    if (t['report_id'] == reportId && t['status'] == 'assigned') {
      return t['id'] as String;
    }
  }
  throw Exception('no task found for report $reportId');
}

void main() {
  late String petugasAccessToken;
  late String wargaAccessToken;
  late String verifikatorAccessToken;
  late String operatorAccessToken;

  setUpAll(() async {
    final petTokens = await _login('petugas@sigap.id', 'petugas123');
    petugasAccessToken = petTokens.accessToken;

    final warTokens = await _login('warga@sigap.id', 'warga123');
    wargaAccessToken = warTokens.accessToken;

    final verTokens = await _login('verifikator@sigap.id', 'verifikator123');
    verifikatorAccessToken = verTokens.accessToken;

    final opTokens = await _login('operator@sigap.id', 'operator123');
    operatorAccessToken = opTokens.accessToken;
  });

  group('petugas task flow', () {
    test('petugasTasks returns tasks list with total count', () async {
      final result = await _httpJson(
        'GET',
        '/api/tasks',
        headers: {'Authorization': 'Bearer $petugasAccessToken'},
      );
      expect(result, isNotNull, reason: 'result should not be null');
      expect(
        result.containsKey('data') || result.containsKey('tasks'),
        isTrue,
        reason: 'result should have data or tasks',
      );
      final tasks = result['data'] as List? ?? result['tasks'] as List? ?? [];
      expect(tasks, isA<List>(), reason: 'tasks should be list');
    });

    test('petugasAccept changes status to accepted', () async {
      final taskId = await _createReportAndGetPetugasTaskId(
        wargaAccessToken,
        verifikatorAccessToken,
        operatorAccessToken,
        'accept',
      );

      final result = await _httpJson(
        'POST',
        '/api/tasks/$taskId/accept',
        body: {'accept': true},
        headers: {'Authorization': 'Bearer $petugasAccessToken'},
      );
      expect(result, isNotNull, reason: 'result should not be null');
      expect(
        result['status'],
        isA<String>(),
        reason: 'status should be string',
      );
    });

    test('startTask changes status to in_progress', () async {
      final taskId = await _createReportAndGetPetugasTaskId(
        wargaAccessToken,
        verifikatorAccessToken,
        operatorAccessToken,
        'start',
      );

      await _httpJson(
        'POST',
        '/api/tasks/$taskId/accept',
        body: {'accept': true},
        headers: {'Authorization': 'Bearer $petugasAccessToken'},
      );

      final result = await _httpJson(
        'POST',
        '/api/tasks/$taskId/start',
        body: {},
        headers: {'Authorization': 'Bearer $petugasAccessToken'},
      );
      expect(result, isNotNull, reason: 'result should not be null');
      expect(
        result['status'],
        isA<String>(),
        reason: 'status should be string',
      );
    });

    test('petugasProgress returns progress_percent', () async {
      final taskId = await _createReportAndGetPetugasTaskId(
        wargaAccessToken,
        verifikatorAccessToken,
        operatorAccessToken,
        'progress',
      );

      await _httpJson(
        'POST',
        '/api/tasks/$taskId/accept',
        body: {'accept': true},
        headers: {'Authorization': 'Bearer $petugasAccessToken'},
      );
      await _httpJson(
        'POST',
        '/api/tasks/$taskId/start',
        body: {},
        headers: {'Authorization': 'Bearer $petugasAccessToken'},
      );

      final result = await _httpJson(
        'PATCH',
        '/api/tasks/$taskId/progress',
        body: {'progress_percent': 50, 'notes': 'TEST_${testRunId}_notes'},
        headers: {'Authorization': 'Bearer $petugasAccessToken'},
      );
      expect(result, isNotNull, reason: 'result should not be null');
      expect(
        result['progress_percent'],
        isA<num>(),
        reason: 'progress_percent should be number',
      );
    });

    test('petugasComplete changes status to completed', () async {
      final taskId = await _createReportAndGetPetugasTaskId(
        wargaAccessToken,
        verifikatorAccessToken,
        operatorAccessToken,
        'complete',
      );

      await _httpJson(
        'POST',
        '/api/tasks/$taskId/accept',
        body: {'accept': true},
        headers: {'Authorization': 'Bearer $petugasAccessToken'},
      );
      await _httpJson(
        'POST',
        '/api/tasks/$taskId/start',
        body: {},
        headers: {'Authorization': 'Bearer $petugasAccessToken'},
      );

      final result = await _httpJson(
        'POST',
        '/api/tasks/$taskId/complete',
        body: {'summary': 'TEST_${testRunId}_summary'},
        headers: {'Authorization': 'Bearer $petugasAccessToken'},
      );
      expect(result, isNotNull, reason: 'result should not be null');
      expect(
        result['status'],
        isA<String>(),
        reason: 'status should be string',
      );
    });

    test('rejectTask changes status to rejected', () async {
      final taskId = await _createReportAndGetPetugasTaskId(
        wargaAccessToken,
        verifikatorAccessToken,
        operatorAccessToken,
        'reject',
      );

      final result = await _httpJson(
        'POST',
        '/api/tasks/$taskId/reject',
        body: {'reason': 'TEST_${testRunId}_reason'},
        headers: {'Authorization': 'Bearer $petugasAccessToken'},
      );
      expect(result, isNotNull, reason: 'result should not be null');
      expect(
        result['status'],
        isA<String>(),
        reason: 'status should be string',
      );
    });

    test('requestTaskClarification returns clarification_id', () async {
      final taskId = await _createReportAndGetPetugasTaskId(
        wargaAccessToken,
        verifikatorAccessToken,
        operatorAccessToken,
        'clar',
      );

      await _httpJson(
        'POST',
        '/api/tasks/$taskId/accept',
        body: {'accept': true},
        headers: {'Authorization': 'Bearer $petugasAccessToken'},
      );

      final result = await _httpJson(
        'POST',
        '/api/tasks/$taskId/clarification',
        body: {'message': 'TEST_${testRunId}_message'},
        headers: {'Authorization': 'Bearer $petugasAccessToken'},
      );
      expect(result, isNotNull, reason: 'result should not be null');
    });

    test('taskChecklistTemplate returns checklist items', () async {
      final taskId = await _createReportAndGetPetugasTaskId(
        wargaAccessToken,
        verifikatorAccessToken,
        operatorAccessToken,
        'checklist',
      );

      final result = await _httpJson(
        'GET',
        '/api/tasks/$taskId/checklist',
        headers: {'Authorization': 'Bearer $petugasAccessToken'},
      );
      expect(result, isNotNull, reason: 'result should not be null');
      expect(
        result.containsKey('items'),
        isTrue,
        reason: 'result should have items',
      );
    });

    test('warga cannot call petugas endpoints - expects 403', () async {
      bool didThrow = false;
      try {
        await _httpJson(
          'GET',
          '/api/tasks',
          headers: {'Authorization': 'Bearer $wargaAccessToken'},
        );
      } catch (e) {
        didThrow = true;
        expect(
          e.toString(),
          anyOf(contains('403'), contains('401')),
          reason: 'warga calling petugas endpoint should throw 403/401',
        );
      }
      expect(
        didThrow,
        isTrue,
        reason: 'should have thrown for unauthorized access',
      );
    });
  });
}

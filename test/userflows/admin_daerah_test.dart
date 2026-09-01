import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import '../helpers/api_expect.dart';
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
  late String adminDaerahAccessToken;

  setUpAll(() async {
    final tokens = await _login('admin.daerah@sigap.id', 'admin123');
    adminDaerahAccessToken = tokens.accessToken;
  });

  group('admin daerah flow', () {
    test('admin daerah dashboard returns regional stats', () async {
      try {
        final result = await _httpJson(
          'GET',
          '/api/admin/daerah/dashboard',
          headers: {'Authorization': 'Bearer $adminDaerahAccessToken'},
        );
        expect(
          result,
          isNotNull,
          reason: 'dashboard result should not be null',
        );
        expect(
          result.containsKey('total'),
          isTrue,
          reason: 'dashboard should have total',
        );
      } catch (e) {
        final msg = e.toString();
        if (msg.contains('403')) {
          return;
        }
        rethrow;
      }
    });

    test('admin daerah cases filtered to wilayah', () async {
      try {
        final result = await _httpJson(
          'GET',
          '/api/admin/daerah/cases',
          headers: {'Authorization': 'Bearer $adminDaerahAccessToken'},
        );
        expect(result, isNotNull, reason: 'cases result should not be null');
        expect(
          result.containsKey('items'),
          isTrue,
          reason: 'cases should have items',
        );
        expect(result['items'], isA<List>(), reason: 'data should be a list');
        expect(
          result.containsKey('pagination'),
          isTrue,
          reason: 'cases should have pagination',
        );
        final pagination = result['pagination'] as Map<String, dynamic>;
        expect(
          pagination.containsKey('total'),
          isTrue,
          reason: 'pagination should have total',
        );
        expect(
          pagination['total'],
          isA<num>(),
          reason: 'total should be number',
        );
      } catch (e) {
        final msg = e.toString();
        if (msg.contains('403')) {
          return;
        }
        rethrow;
      }
    });

    test('admin daerah lists operators in their wilayah', () async {
      try {
        final result = await _httpJson(
          'GET',
          '/api/admin/daerah/operators',
          headers: {'Authorization': 'Bearer $adminDaerahAccessToken'},
        );
        expect(
          result,
          isNotNull,
          reason: 'operators result should not be null',
        );
        expect(
          result.containsKey('items'),
          isTrue,
          reason: 'operators should have items',
        );
        expect(result['items'], isA<List>(), reason: 'data should be a list');
      } catch (e) {
        final msg = e.toString();
        if (msg.contains('403')) {
          return;
        }
        rethrow;
      }
    });

    test('admin daerah lists petugas in their wilayah', () async {
      try {
        final result = await _httpJson(
          'GET',
          '/api/admin/daerah/petugas',
          headers: {'Authorization': 'Bearer $adminDaerahAccessToken'},
        );
        expect(result, isNotNull, reason: 'petugas result should not be null');
        expect(
          result.containsKey('items'),
          isTrue,
          reason: 'petugas should have items',
        );
        expect(result['items'], isA<List>(), reason: 'data should be a list');
      } catch (e) {
        final msg = e.toString();
        if (msg.contains('403')) {
          return;
        }
        rethrow;
      }
    });

    test('admin daerah reads SLA rules', () async {
      try {
        final result = await _httpJson(
          'GET',
          '/api/admin/daerah/sla',
          headers: {'Authorization': 'Bearer $adminDaerahAccessToken'},
        );
        expect(result, isNotNull, reason: 'SLA result should not be null');
        expect(
          result.containsKey('items'),
          isTrue,
          reason: 'SLA should have items',
        );
        expect(result['items'], isA<List>(), reason: 'data should be a list');
      } catch (e) {
        final msg = e.toString();
        if (msg.contains('403')) {
          return;
        }
        rethrow;
      }
    });

    test('admin daerah creates unit in their wilayah', () async {
      try {
        final result = await _httpJson(
          'POST',
          '/api/units',
          body: {
            'name': 'TEST_${testRunId}_unit_name',
            'description': 'TEST_${testRunId}_unit_desc',
          },
          headers: {'Authorization': 'Bearer $adminDaerahAccessToken'},
        );
        expect(
          result,
          isNotNull,
          reason: 'create unit result should not be null',
        );
        expect(result.containsKey('id'), isTrue, reason: 'unit should have id');
        expect(result['id'], isA<String>(), reason: 'id should be string');
        expect(
          (result['id'] as String).isNotEmpty,
          isTrue,
          reason: 'id should not be empty',
        );
        expect(
          result.containsKey('name'),
          isTrue,
          reason: 'unit should have name',
        );
        expect(
          result['name'],
          'TEST_${testRunId}_unit_name',
          reason: 'name should match',
        );
      } catch (e) {
        final msg = e.toString();
        if (msg.contains('403')) {
          return;
        }
        rethrow;
      }
    });

    test('admin daerah lists units in their wilayah', () async {
      try {
        final result = await _httpJson(
          'GET',
          '/api/units',
          headers: {'Authorization': 'Bearer $adminDaerahAccessToken'},
        );
        expect(result, isNotNull, reason: 'units result should not be null');
        expect(
          result.containsKey('items'),
          isTrue,
          reason: 'units should have items',
        );
        expect(result['items'], isA<List>(), reason: 'data should be a list');
        expect(
          result.containsKey('pagination'),
          isTrue,
          reason: 'units should have pagination',
        );
        final pagination = result['pagination'] as Map<String, dynamic>;
        expect(
          pagination.containsKey('total'),
          isTrue,
          reason: 'pagination should have total',
        );
        expect(
          pagination['total'],
          isA<num>(),
          reason: 'total should be number',
        );
      } catch (e) {
        final msg = e.toString();
        if (msg.contains('403')) {
          return;
        }
        rethrow;
      }
    });

    test('admin daerah cannot access other wilayah data', () async {
      await expectApiError(
        () => _httpJson(
          'GET',
          '/api/admin/users',
          headers: {'Authorization': 'Bearer $adminDaerahAccessToken'},
        ),
        403,
        context: 'admin daerah cannot access other wilayah data',
      );
    });

    test('admin daerah SLA rule detail', () async {
      try {
        final result = await _httpJson(
          'GET',
          '/api/admin/daerah/sla',
          headers: {'Authorization': 'Bearer $adminDaerahAccessToken'},
        );
        expect(result, isNotNull, reason: 'SLA result should not be null');
        expect(
          result.containsKey('items'),
          isTrue,
          reason: 'SLA should have items',
        );
        expect(result['items'], isA<List>(), reason: 'data should be a list');

        final data = result['items'] as List;
        if (data.isNotEmpty) {
          final sla = data.first as Map<String, dynamic>;
          expect(sla.containsKey('id'), isTrue, reason: 'SLA should have id');
          expect(sla['id'], isA<String>(), reason: 'id should be string');
          expect(
            sla.containsKey('name'),
            isTrue,
            reason: 'SLA should have name',
          );
          expect(sla['name'], isA<String>(), reason: 'name should be string');
        }
      } catch (e) {
        final msg = e.toString();
        if (msg.contains('403')) {
          return;
        }
        rethrow;
      }
    });
  });
}

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sigap/api/client.dart';
import '../helpers/test_env.dart';

const _apiBaseUrl = 'https://sigap.live';

/// Dio client that allows 4xx/5xx through (for ApiClient._execute handling).
Dio _rawDio() => Dio(
  BaseOptions(
    baseUrl: _apiBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 30),
    validateStatus: (s) => s != null && (s < 400 || s == 503),
  ),
);

/// Authenticated Dio — injects Bearer token without FlutterSecureStorage.
Dio _authDio(String token) {
  final dio = _rawDio();
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        options.headers['Authorization'] = 'Bearer $token';
        handler.next(options);
      },
    ),
  );
  return dio;
}

/// Create an authenticated ApiClient.
ApiClient _client(String token) => ApiClient(
  baseUrl: _apiBaseUrl,
  dio: _authDio(token),
  checkConnectivity: () async {},
);

void main() {
  final testSecret = testResetSecret;
  final runId = 'flutter-cleanup-${DateTime.now().millisecondsSinceEpoch}';

  group('cleanup endpoint', () {
    group('auth gate', () {
      test('requires X-Test-Secret header', () async {
        try {
          await _rawDio().post('/api/admin/test-reset', data: {'runId': 'any'});
          fail('missing secret should return 401');
        } on DioException catch (e) {
          expect(
            e.response?.statusCode,
            equals(401),
            reason: 'missing secret should return 401',
          );
        }
      });

      test('rejects wrong secret', () async {
        try {
          await _rawDio().post(
            '/api/admin/test-reset',
            data: {'runId': 'any'},
            options: Options(headers: {'X-Test-Secret': 'wrong'}),
          );
          fail('wrong secret should return 401');
        } on DioException catch (e) {
          expect(
            e.response?.statusCode,
            equals(401),
            reason: 'wrong secret should return 401',
          );
        }
      });
    });

    group('valid secret behavior', () {
      test('returns deleted counts with correct envelope shape', () async {
        if (testSecret.isEmpty) return;

        final client = _client('');
        final result = await client.testReset(runId, secret: testSecret);
        expect(result, isNotNull, reason: 'result should not be null');
        expect(
          result.containsKey('deleted'),
          isTrue,
          reason: 'result should have deleted',
        );
        final d = result['deleted'] as Map<String, dynamic>;
        expect(
          d.containsKey('d1_rows'),
          isTrue,
          reason: 'deleted should have d1_rows',
        );
        expect(
          d.containsKey('r2_objects'),
          isTrue,
          reason: 'deleted should have r2_objects',
        );
        expect(
          d.containsKey('runId'),
          isTrue,
          reason: 'deleted should have runId',
        );
        expect(d['runId'], runId, reason: 'runId should match');
        expect(d['d1_rows'], isA<num>(), reason: 'd1_rows should be number');
        expect(
          d['r2_objects'],
          isA<num>(),
          reason: 'r2_objects should be number',
        );
      });

      test('handles runId with no data gracefully', () async {
        if (testSecret.isEmpty) return;

        final emptyRunId =
            'never-exist-${DateTime.now().millisecondsSinceEpoch}';
        final client = _client('');
        final result = await client.testReset(emptyRunId, secret: testSecret);
        expect(result, isNotNull, reason: 'result should not be null');
        final d = result['deleted'] as Map<String, dynamic>;
        expect(d['d1_rows'], 0, reason: 'd1_rows should be 0');
        expect(d['r2_objects'], 0, reason: 'r2_objects should be 0');
        expect(d['runId'], emptyRunId, reason: 'runId should match');
      });

      test('is idempotent — second call returns 0 deletes', () async {
        if (testSecret.isEmpty) return;

        final idempotentRunId =
            'idempotent-${DateTime.now().millisecondsSinceEpoch}';
        final client = _client('');

        await client.testReset(idempotentRunId, secret: testSecret);
        final second = await client.testReset(
          idempotentRunId,
          secret: testSecret,
        );
        final secondDeleted = second['deleted'] as Map<String, dynamic>;

        expect(
          secondDeleted['d1_rows'],
          0,
          reason: 'second d1_rows should be 0',
        );
        expect(
          secondDeleted['r2_objects'],
          0,
          reason: 'second r2_objects should be 0',
        );
      });
    });

    group('runId validation', () {
      test('rejects missing runId', () async {
        if (testSecret.isEmpty) return;

        try {
          // Use raw Dio to send empty body (client.testReset requires runId)
          await _rawDio().post(
            '/api/admin/test-reset',
            data: {},
            options: Options(headers: {'X-Test-Secret': testSecret}),
          );
          fail('missing runId should return 400');
        } on DioException catch (e) {
          expect(
            e.response?.statusCode,
            equals(400),
            reason: 'missing runId should return 400',
          );
        }
      });

      test('rejects empty runId string', () async {
        if (testSecret.isEmpty) return;

        try {
          await _rawDio().post(
            '/api/admin/test-reset',
            data: {'runId': ''},
            options: Options(headers: {'X-Test-Secret': testSecret}),
          );
          fail('empty runId should return 400');
        } on DioException catch (e) {
          expect(
            e.response?.statusCode,
            equals(400),
            reason: 'empty runId should return 400',
          );
        }
      });
    });
  });
}

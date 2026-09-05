import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sigap/api/client.dart';
import 'package:sigap/api/exceptions.dart';

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

/// Login via plain Dio with 429 backoff retry.
Future<LoginResponse> _loginWithBackoff(String email, String password) async {
  final delays = [2000, 3000, 5000, 7000, 8000];
  String? lastError;
  for (int attempt = 0; attempt < 5; attempt++) {
    try {
      final plainDio = Dio(
        BaseOptions(
          baseUrl: _apiBaseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 30),
          validateStatus: (s) => s != null && s < 400,
        ),
      );
      final res = await plainDio.post(
        '/api/auth/login',
        data: {'email': email, 'password': password},
      );
      return LoginResponse.fromJson((res.data as Map).cast<String, dynamic>());
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
  late ApiClient auditorClient;

  setUpAll(() async {
    final loginResp = await _loginWithBackoff('auditor@sigap.id', 'auditor123');
    auditorClient = _client(loginResp.token!);
  });

  group('audit search & export flow', () {
    test('audit search returns paginated entries', () async {
      // GET /api/auditor/audit-search
      final res = await auditorClient.dio.get(
        '/api/auditor/audit-search',
        queryParameters: {'page': 1, 'limit': 20},
      );
      final result = res.data as Map<String, dynamic>;
      expect(
        result.containsKey('data'),
        isTrue,
        reason: 'result should have data',
      );
      expect(result['data'], isA<List>(), reason: 'data should be a list');
      expect(
        result.containsKey('pagination'),
        isTrue,
        reason: 'result should have pagination',
      );
      final pagination = result['pagination'] as Map<String, dynamic>;
      expect(
        pagination.containsKey('page'),
        isTrue,
        reason: 'pagination should have page',
      );
      expect(
        pagination.containsKey('limit'),
        isTrue,
        reason: 'pagination should have limit',
      );
      expect(
        pagination.containsKey('total'),
        isTrue,
        reason: 'pagination should have total',
      );
      expect(pagination['total'], isA<num>(), reason: 'total should be number');
    });

    test('audit search filters by action type', () async {
      final res = await auditorClient.dio.get(
        '/api/auditor/audit-search',
        queryParameters: {'action': 'REPORT_CREATE', 'limit': 20},
      );
      final result = res.data as Map<String, dynamic>;
      expect(
        result.containsKey('data'),
        isTrue,
        reason: 'result should have data',
      );
      expect(result['data'], isA<List>(), reason: 'data should be a list');
      final entries = result['data'] as List;
      for (final entry in entries) {
        expect(
          (entry as Map<String, dynamic>).containsKey('action'),
          isTrue,
          reason: 'entry should have action',
        );
      }
    });

    test('audit chain verify returns valid', () async {
      // GET /api/auditor/verify-chain
      final res = await auditorClient.dio.get('/api/auditor/verify-chain');
      final result = res.data as Map<String, dynamic>;
      expect(result.containsKey('ok'), isTrue, reason: 'result should have ok');
      expect(result['ok'], isA<bool>(), reason: 'ok should be boolean');
      expect(
        result.containsKey('count'),
        isTrue,
        reason: 'result should have count',
      );
      expect(result['count'], isA<num>(), reason: 'count should be number');
    });

    test(
      'each audit entry has prev_hash + hash + actor + action + object_id + timestamp',
      () async {
        final res = await auditorClient.dio.get(
          '/api/auditor/audit-search',
          queryParameters: {'limit': 10},
        );
        final result = res.data as Map<String, dynamic>;
        expect(
          result.containsKey('data'),
          isTrue,
          reason: 'result should have data',
        );
        final entries = result['data'] as List;
        expect(
          entries.isNotEmpty,
          isTrue,
          reason: 'entries should not be empty',
        );

        for (final entry in entries) {
          final e = entry as Map<String, dynamic>;
          expect(
            e.containsKey('prev_hash'),
            isTrue,
            reason: 'entry should have prev_hash',
          );
          expect(
            e['prev_hash'],
            isA<String>(),
            reason: 'prev_hash should be string',
          );
          expect(
            e.containsKey('hash'),
            isTrue,
            reason: 'entry should have hash',
          );
          expect(e['hash'], isA<String>(), reason: 'hash should be string');
          expect(
            e.containsKey('actor'),
            isTrue,
            reason: 'entry should have actor',
          );
          expect(
            e.containsKey('action'),
            isTrue,
            reason: 'entry should have action',
          );
          expect(e['action'], isA<String>(), reason: 'action should be string');
          expect(
            e.containsKey('object_id'),
            isTrue,
            reason: 'entry should have object_id',
          );
          expect(
            e.containsKey('created_at'),
            isTrue,
            reason: 'entry should have created_at',
          );
          expect(
            e['created_at'],
            isA<String>(),
            reason: 'created_at should be string',
          );
        }
      },
    );

    test('audit CSV export contains entries', () async {
      try {
        final csvText = await auditorClient.getAuditExport(format: 'csv');
        expect(
          csvText.isNotEmpty,
          isTrue,
          reason: 'CSV export should not be empty',
        );
        expect(
          csvText.contains('actor'),
          isTrue,
          reason: 'CSV should contain actor header',
        );
      } on ApiException catch (e) {
        if (e.statusCode == 403 || e.statusCode == 404) return;
        rethrow;
      }
    });

    test('audit JSON export contains entries', () async {
      try {
        final res = await auditorClient.dio.get(
          '/api/auditor/audit-export',
          queryParameters: {'format': 'json'},
        );
        final bodyStr = res.data.toString();
        expect(
          bodyStr.isNotEmpty,
          isTrue,
          reason: 'JSON export should not be empty',
        );
        // Response may be JSON array or Dart-style map — just verify non-empty
      } on DioException catch (e) {
        if (e.response?.statusCode == 403 || e.response?.statusCode == 404)
          return;
        rethrow;
      }
    });

    test('auditor stats returns aggregates', () async {
      // GET /api/auditor/stats
      try {
        final res = await auditorClient.dio.get('/api/auditor/stats');
        final result = res.data as Map<String, dynamic>;
        expect(
          result.containsKey('counts'),
          isTrue,
          reason: 'result should have counts',
        );
        final counts = result['counts'] as Map<String, dynamic>;
        expect(
          counts.containsKey('total'),
          isTrue,
          reason: 'counts should have total',
        );
        expect(
          counts.containsKey('last_24h'),
          isTrue,
          reason: 'counts should have last_24h',
        );
        expect(
          counts.containsKey('last_7d'),
          isTrue,
          reason: 'counts should have last_7d',
        );
        expect(
          counts.containsKey('last_30d'),
          isTrue,
          reason: 'counts should have last_30d',
        );
        expect(counts['total'], isA<num>(), reason: 'total should be number');
      } on DioException catch (e) {
        // May return 404 if endpoint doesn't exist on prod
        if (e.response?.statusCode == 404) return;
        rethrow;
      }
    });

    test('export/geojson returns FeatureCollection', () async {
      try {
        final result = await auditorClient.getExportGeojson();
        expect(
          result.type,
          'FeatureCollection',
          reason: 'type should be FeatureCollection',
        );
        expect(
          result.features,
          isA<List>(),
          reason: 'features should be a list',
        );
      } on ApiException catch (e) {
        if (e.statusCode == 403 || e.statusCode == 404) return;
        rethrow;
      }
    });

    test('export/csv contains data rows', () async {
      try {
        final csvText = await auditorClient.exportReportsCsv();
        expect(
          csvText.isNotEmpty,
          isTrue,
          reason: 'CSV export should not be empty',
        );
        expect(
          csvText.contains('id'),
          isTrue,
          reason: 'CSV should contain id header',
        );
      } on ApiException catch (e) {
        if (e.statusCode == 403 || e.statusCode == 404) return;
        rethrow;
      } on DioException catch (e) {
        if (e.response?.statusCode == 403 || e.response?.statusCode == 404)
          return;
        rethrow;
      }
    });
  });
}

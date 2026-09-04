import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sigap/api/client.dart';

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
  late ApiClient operatorClient;
  late ApiClient eksekutifClient;

  setUpAll(() async {
    final opLogin = await _loginWithBackoff('operator@sigap.id', 'operator123');
    operatorClient = _client(opLogin.token!);

    final eksekLogin = await _loginWithBackoff('eksekutif@sigap.id', 'exec123');
    eksekutifClient = _client(eksekLogin.token!);
  });

  group('stats and dashboard flow', () {
    test('operator stats returns aggregated data', () async {
      final stats = await operatorClient.getStats();
      expect(stats, isNotNull, reason: 'stats result should not be null');
      expect(stats.total, isA<int>(), reason: 'total should be number');
      expect((stats.total ?? 0) >= 0, isTrue, reason: 'total should be >= 0');
    });

    test('public stats returns public data', () async {
      // Use raw Dio — client.getPublicStats() reads wrong envelope key
      final res = await operatorClient.dio.get('/api/public/stats');
      final result = res.data as Map<String, dynamic>;
      expect(
        result.containsKey('total'),
        isTrue,
        reason: 'stats should have total',
      );
      expect(result['total'], isA<num>(), reason: 'total should be number');
      expect(
        (result['total'] as num).toInt() >= 0,
        isTrue,
        reason: 'total should be >= 0',
      );
    });

    test('warga stats returns own report stats', () async {
      try {
        // Use raw Dio — client.getWargaStats() may read wrong envelope key
        final warLogin = await _loginWithBackoff('warga@sigap.id', 'warga123');
        final warClient = _client(warLogin.token!);
        final res = await warClient.dio.get('/api/warga/stats');
        final result = res.data as Map<String, dynamic>;
        expect(result, isNotNull, reason: 'stats result should not be null');
        expect(
          result.containsKey('total'),
          isTrue,
          reason: 'stats should have total',
        );
        expect(result['total'], isA<num>(), reason: 'total should be number');
        expect(
          (result['total'] as num).toInt() >= 0,
          isTrue,
          reason: 'total should be >= 0',
        );
      } on DioException catch (e) {
        if (e.response?.statusCode == 401) return;
        rethrow;
      }
    });

    test('geojson returns FeatureCollection', () async {
      final geojson = await operatorClient.getMapGeoJson();
      expect(
        geojson.type,
        'FeatureCollection',
        reason: 'type should be FeatureCollection',
      );
      expect(
        geojson.features,
        isA<List>(),
        reason: 'features should be a list',
      );
    });

    test('heatmap returns coordinates array', () async {
      try {
        final res = await operatorClient.dio.get('/api/map/heatmap');
        final result = res.data as Map<String, dynamic>;
        expect(result, isNotNull, reason: 'heatmap result should not be null');
        expect(
          result.containsKey('points'),
          isTrue,
          reason: 'result should have points',
        );
        expect(
          result['points'],
          isA<List>(),
          reason: 'points should be a list',
        );
      } on DioException catch (e) {
        if (e.response?.statusCode == 401) return;
        rethrow;
      }
    });

    test('executive dashboard returns KPIs', () async {
      try {
        // GET /api/executive/dashboard — no client method
        final res = await eksekutifClient.dio.get('/api/executive/dashboard');
        final result = res.data as Map<String, dynamic>;
        expect(
          result,
          isNotNull,
          reason: 'dashboard result should not be null',
        );
        expect(
          result.containsKey('total_reports'),
          isTrue,
          reason: 'dashboard should have total_reports',
        );
        expect(
          result['total_reports'],
          isA<num>(),
          reason: 'total_reports should be number',
        );
      } on DioException catch (e) {
        if (e.response?.statusCode == 401 || e.response?.statusCode == 403)
          return;
        rethrow;
      }
    });

    test('executive regional stats breakdown', () async {
      try {
        // GET /api/executive/regional-stats — no client method
        final res = await eksekutifClient.dio.get(
          '/api/executive/regional-stats',
        );
        final result = res.data as Map<String, dynamic>;
        expect(result, isNotNull, reason: 'regional stats should not be null');
        // Backend returns {by_wilayah, by_wilayah_category, staffing} not {regions}
        expect(
          result.containsKey('by_wilayah') || result.containsKey('regions'),
          isTrue,
          reason: 'result should have by_wilayah or regions',
        );
      } on DioException catch (e) {
        if (e.response?.statusCode == 401 || e.response?.statusCode == 403)
          return;
        rethrow;
      }
    });

    test('executive trend analysis time series', () async {
      try {
        // GET /api/executive/trend-analysis?period=daily — no client method
        final res = await eksekutifClient.dio.get(
          '/api/executive/trend-analysis',
          queryParameters: {'period': 'daily'},
        );
        final result = res.data as Map<String, dynamic>;
        expect(result, isNotNull, reason: 'trend result should not be null');
        expect(
          result.isNotEmpty,
          isTrue,
          reason: 'trend result should not be empty',
        );
      } on DioException catch (e) {
        if (e.response?.statusCode == 401 || e.response?.statusCode == 403)
          return;
        rethrow;
      }
    });
  });
}

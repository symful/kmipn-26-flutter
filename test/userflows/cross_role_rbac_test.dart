import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sigap/api/client.dart';

const _apiBaseUrl = 'https://sigap.live';

const _roles = [
  {'email': 'warga@sigap.id', 'password': 'warga123', 'role': 'WARGA'},
  {'email': 'surveyor@sigap.id', 'password': 'surveyor123', 'role': 'SURVEYOR'},
  {'email': 'operator@sigap.id', 'password': 'operator123', 'role': 'OPERATOR'},
  {
    'email': 'verifikator@sigap.id',
    'password': 'verifikator123',
    'role': 'VERIFIKATOR',
  },
  {
    'email': 'admin.daerah@sigap.id',
    'password': 'admin123',
    'role': 'ADMIN_DAERAH',
  },
];

const _protectedEndpoints = <Map<String, dynamic>>[
  {
    'method': 'GET',
    'path': '/api/admin/users',
    'requiresAny': <String>['ADMIN_DAERAH'],
  },
  {
    'method': 'GET',
    'path': '/api/audit/search',
    'requiresAny': <String>['AUDITOR', 'ADMIN_DAERAH', 'VERIFIKATOR'],
  },
  {
    'method': 'GET',
    'path': '/api/admin-daerah/dashboard',
    'requiresAny': <String>['ADMIN_DAERAH'],
  },
];

/// Lightweight Dio for test-only endpoints (login).
Dio _plainDio() => Dio(
  BaseOptions(
    baseUrl: _apiBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 30),
    validateStatus: (s) => s != null && s < 400,
  ),
);

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

/// Login via plain Dio with 429 backoff retry.
Future<LoginResponse> _loginWithBackoff(String email, String password) async {
  final delays = [2000, 3000, 5000, 7000, 8000];
  String? lastError;
  for (int attempt = 0; attempt < 5; attempt++) {
    try {
      final dio = _plainDio();
      final res = await dio.post(
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

/// Create an authenticated ApiClient for a given token.
ApiClient _client(String token) => ApiClient(
  baseUrl: _apiBaseUrl,
  dio: _authDio(token),
  checkConnectivity: () async {},
);

void main() {
  group('cross-role RBAC matrix', () {
    test(
      'unauthenticated request to protected endpoints returns 401/403',
      () async {
        for (final ep in _protectedEndpoints) {
          bool threw = false;
          int? statusCode;
          try {
            await _rawDio().get(ep['path']! as String);
          } on DioException catch (e) {
            threw = true;
            statusCode = e.response?.statusCode;
          }
          expect(
            threw,
            isTrue,
            reason:
                'unauthenticated ${ep['method']} ${ep['path']} should throw',
          );
          expect(statusCode, isNotNull, reason: 'should have status code');
          expect(
            statusCode,
            anyOf(equals(401), equals(403)),
            reason: 'unauthenticated should get 401 or 403',
          );
        }
      },
    );

    for (final ep in _protectedEndpoints) {
      for (final r in _roles) {
        test("${r['role']} → ${ep['method']} ${ep['path']}", () async {
          final loginResp = await _loginWithBackoff(
            r['email']!,
            r['password']!,
          );
          final client = _client(loginResp.token!);
          final allowed = (ep['requiresAny'] as List).contains(r['role']);

          try {
            await client.dio.get(ep['path']! as String);
            expect(
              allowed,
              isTrue,
              reason:
                  "${r['role']} should be allowed ${ep['method']} ${ep['path']}",
            );
          } on DioException catch (e) {
            final statusCode = e.response?.statusCode;
            expect(
              allowed,
              isFalse,
              reason:
                  "${r['role']} should be denied ${ep['method']} ${ep['path']}",
            );
            expect(
              statusCode,
              anyOf(equals(401), equals(403)),
              reason: 'denied request should return 401 or 403',
            );
          }
        });
      }
    }
  });
}

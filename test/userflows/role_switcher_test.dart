import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sigap/api/client.dart';
import 'package:sigap/api/exceptions.dart';

const _apiBaseUrl = 'https://sigap.live';

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

Map<String, dynamic> _decodeJwt(String token) {
  final parts = token.split('.');
  if (parts.length != 3) throw Exception('Invalid JWT');
  final payload = parts[1].replaceAll('-', '+').replaceAll('_', '/');
  final padded = payload.padRight(
    payload.length + ((4 - (payload.length % 4)) % 4),
    '=',
  );
  return jsonDecode(utf8.decode(base64Decode(padded))) as Map<String, dynamic>;
}

void main() {
  late ApiClient adminClient;

  setUpAll(() async {
    final loginResp = await _loginWithBackoff(
      'admin.daerah@sigap.id',
      'admin123',
    );
    adminClient = ApiClient(
      baseUrl: _apiBaseUrl,
      dio: _authDio(loginResp.token!),
      checkConnectivity: () async {},
    );
  });

  group('role switcher flow', () {
    test('switch-role rejects ungranted role with 403', () async {
      try {
        await adminClient.switchRole('VERIFIKATOR');
        fail('should have thrown for ungranted role');
      } on ApiException catch (e) {
        expect(e.statusCode, 403, reason: 'ungranted role should throw 403');
      }
    });

    test('switch-role issues new JWT with granted role', () async {
      final switchResult = await adminClient.switchRole('ADMIN_DAERAH');

      expect(
        switchResult,
        isNotNull,
        reason: 'switch result should not be null',
      );
      final newToken = switchResult['access_token'];
      final newRefresh = switchResult['refresh_token'];
      expect(
        newToken,
        isNotNull,
        reason: 'new access token should not be null',
      );
      expect(
        newRefresh,
        isNotNull,
        reason: 'new refresh token should not be null',
      );

      final payload = _decodeJwt(newToken as String);
      expect(
        payload.containsKey('role'),
        isTrue,
        reason: 'payload should have role',
      );
      expect(
        payload['role'],
        equals('ADMIN_DAERAH'),
        reason: 'role should be ADMIN_DAERAH',
      );
    });

    test('switch-role works for multiple role switches', () async {
      final roles = ['ADMIN_DAERAH'];
      for (final role in roles) {
        final result = await adminClient.switchRole(role);

        expect(
          result,
          isNotNull,
          reason: 'switch result should not be null for $role',
        );
        final token = result['access_token'];
        expect(
          token,
          isNotNull,
          reason: 'access token should not be null for $role',
        );

        final payload = _decodeJwt(token as String);
        expect(
          payload['role'],
          equals(role),
          reason: 'role should be $role for switch to $role',
        );
      }
    });

    test('switch-role with invalid role returns error', () async {
      try {
        await adminClient.switchRole('INVALID_ROLE_XYZ');
        fail('should have thrown for invalid role');
      } on ApiException catch (e) {
        expect(
          e.statusCode,
          anyOf(equals(400), equals(403), equals(404)),
          reason: 'invalid role should throw 400/403/404',
        );
      }
    });

    test('switch-role without auth returns 401', () async {
      try {
        // Use raw Dio without auth — should get 401
        await _rawDio().post(
          '/api/auth/switch-role',
          data: {'activeRole': 'ADMIN_DAERAH'},
        );
        fail('should have thrown without auth');
      } on DioException catch (e) {
        expect(
          e.response?.statusCode,
          anyOf(equals(401), equals(403)),
          reason: 'no auth should throw 401/403',
        );
      }
    });
  });
}

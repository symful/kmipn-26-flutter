import 'dart:math';
import 'package:dio/dio.dart';

/// Available roles for test authentication.
enum Role {
  ADMIN,
  ADMIN_DAERAH,
  PETUGAS,
  SURVEYOR,
  WARGA,
  VERIFIKATOR,
  PENGAMBIL_KEPUTUSAN,
  OPERATOR,
  AUDITOR,
  RT_RW,
}

class TestJwtCache {
  static final Map<Role, String> _cache = {};
  static final Map<Role, DateTime> _cooldowns = {};
  static const _baseUrl = 'https://kmipn-26-deno.careday17.workers.dev';

  /// Fetches a real JWT token from the production server for the given role.
  /// Tokens are cached for 30 minutes to avoid unnecessary API calls.
  ///
  /// Throws if token fetch fails after retries.
  static Future<String> getToken(Role role) async {
    final cached = _cache[role];
    final lastFetch = _cooldowns[role];
    if (cached != null && lastFetch != null) {
      final age = DateTime.now().difference(lastFetch).inMinutes;
      if (age < 30) return cached;
    }

    final dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    int attempt = 0;
    const maxRetries = 5;

    while (true) {
      try {
        final resp = await dio.post(
          '/api/test/login-as',
          data: {'role': role.name},
        );

        if (resp.statusCode == 429 && attempt < maxRetries - 1) {
          attempt++;
          final delay = Duration(
            milliseconds: (1000 * (1 << attempt)) + Random().nextInt(1000),
          );
          await Future.delayed(delay);
          continue;
        }

        if (resp.statusCode != 200) {
          throw DioException(
            requestOptions: resp.requestOptions,
            response: resp,
            message:
                'Failed to get test token: ${resp.statusCode} ${resp.data}',
          );
        }

        // Server returns access_token, but spec pattern shows token
        final token =
            (resp.data['token'] ?? resp.data['access_token']) as String;
        _cache[role] = token;
        _cooldowns[role] = DateTime.now();
        return token;
      } on DioException catch (e) {
        // Only retry on network timeouts, not on response errors (401, 500, etc)
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout ||
            e.type == DioExceptionType.connectionError) {
          if (attempt >= maxRetries - 1) rethrow;
          attempt++;
          await Future.delayed(Duration(seconds: attempt));
          continue;
        }
        rethrow;
      }
    }
  }

  static void clearCache() {
    _cache.clear();
    _cooldowns.clear();
  }
}

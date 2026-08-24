import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:dio/dio.dart';

import 'package:sigap/api/types.g.dart';

class TestJwtCache {
  static final Map<Role, String> _cache = {};
  static final Map<Role, DateTime> _cooldowns = {};
  static const _baseUrl = 'https://kmipn-26-deno.careday17.workers.dev';

  // Disk cache path for persistent cache across flutter test invocations
  static String get _cacheFilePath {
    final toolDir = Directory('.dart_tool');
    if (!toolDir.existsSync()) {
      toolDir.createSync(recursive: true);
    }
    return '${toolDir.path}/test_jwt_cache.json';
  }

  // 429 counter for prewarm phase
  static int _prewarm429Count = 0;

  /// Loads persisted cache from disk (25-min TTL per entry).
  /// Called automatically on first access.
  static void _loadFromDisk() {
    try {
      final file = File(_cacheFilePath);
      if (!file.existsSync()) return;

      final raw = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      for (final entry in raw.entries) {
        final role = Role.values.where((r) => r.value == entry.key).firstOrNull;
        if (role == null) continue;

        final data = entry.value as Map<String, dynamic>;
        final token = data['token'] as String?;
        final fetchedAtMs = data['fetchedAt'] as int?;
        if (token == null || fetchedAtMs == null) continue;

        final fetchedAt = DateTime.fromMillisecondsSinceEpoch(fetchedAtMs);
        final age = DateTime.now().difference(fetchedAt).inMinutes;
        if (age < 25) {
          _cache[role] = token;
          _cooldowns[role] = fetchedAt;
        }
      }
    } catch (_) {
      // Ignore disk read errors — cache will be rebuilt from network.
    }
  }

  /// Persists current in-memory cache to disk.
  static void _saveToDisk() {
    try {
      final Map<String, dynamic> data = {};
      for (final role in _cache.keys) {
        data[role.value] = {
          'token': _cache[role],
          'fetchedAt': _cooldowns[role]?.millisecondsSinceEpoch,
        };
      }
      File(_cacheFilePath).writeAsStringSync(jsonEncode(data));
    } catch (_) {
      // Ignore disk write errors — cache is still valid in memory.
    }
  }

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
          data: {'role': role.value},
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
        _saveToDisk();
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

  /// Pwarms the cache by fetching tokens for [requiredRoles] sequentially
  /// with 1.5-second gaps to respect the server's 5/min login-as rate limit.
  ///
  /// Persists to disk cache after each fetch and loads existing cache on start.
  ///
  /// Throws [PrewarmException] if any 429 is encountered during prewarm
  /// (indicating rate limit was already hit before prewarm could complete).
  static Future<void> prewarmRoles(List<Role> requiredRoles) async {
    // Load persisted cache on startup
    _loadFromDisk();

    _prewarm429Count = 0;

    final dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    for (final role in requiredRoles) {
      // Skip if already cached with valid TTL (25 min from disk)
      final cached = _cache[role];
      final lastFetch = _cooldowns[role];
      if (cached != null && lastFetch != null) {
        final age = DateTime.now().difference(lastFetch).inMinutes;
        if (age < 25) {
          print(
            '[TestJwtCache] prewarm SKIP ${role.value} (cache HIT, ${age}min old)',
          );
          continue;
        }
      }

      // Fetch fresh token with 429 tracking
      print('[TestJwtCache] prewarm FETCH ${role.value}...');
      try {
        final resp = await dio.post(
          '/api/test/login-as',
          data: {'role': role.value},
        );

        if (resp.statusCode == 429) {
          _prewarm429Count++;
          print('[TestJwtCache] prewarm 429 for ${role.value}');
        } else if (resp.statusCode != 200) {
          throw DioException(
            requestOptions: resp.requestOptions,
            response: resp,
            message:
                'Prewarm token fetch failed: ${resp.statusCode} ${resp.data}',
          );
        } else {
          final token =
              (resp.data['token'] ?? resp.data['access_token']) as String;
          _cache[role] = token;
          _cooldowns[role] = DateTime.now();
          _saveToDisk();
          print('[TestJwtCache] prewarm OK ${role.value}');
        }
      } on DioException catch (e) {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout ||
            e.type == DioExceptionType.connectionError) {
          print(
            '[TestJwtCache] prewarm network error for ${role.value}: ${e.message}',
          );
          rethrow;
        }
        rethrow;
      }

      // 1.5s gap between fetches to mitigate 5/min rate limit
      await Future.delayed(const Duration(milliseconds: 1500));
    }

    if (_prewarm429Count > 0) {
      throw PrewarmException(
        'Prewarm encountered $_prewarm429Count HTTP 429(s) — rate limit was hit. '
        'Wait before re-running tests.',
      );
    }
  }

  static void clearCache() {
    _cache.clear();
    _cooldowns.clear();
    try {
      final file = File(_cacheFilePath);
      if (file.existsSync()) file.deleteSync();
    } catch (_) {}
  }
}

/// Exception thrown when prewarm encounters one or more 429 rate-limit responses.
class PrewarmException implements Exception {
  final String message;
  const PrewarmException(this.message);
  @override
  String toString() => message;
}

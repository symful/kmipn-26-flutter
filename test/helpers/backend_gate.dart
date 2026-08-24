import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'test_jwt.dart';

/// Exception thrown when a test suite should be skipped due to environment
/// (e.g. backend unreachable).
class BackendUnavailableException implements Exception {
  final String reason;
  const BackendUnavailableException(this.reason);
  @override
  String toString() => 'BackendUnavailableException: $reason';
}

const _baseUrl = 'https://kmipn-26-deno.careday17.workers.dev';

/// Health-check result details for debugging.
class HealthCheckResult {
  final int? statusCode;
  final String? error;
  final bool isOffline;

  HealthCheckResult.ok(this.statusCode) : error = null, isOffline = false;
  HealthCheckResult.connectionError(this.error)
    : statusCode = null,
      isOffline = true;
  HealthCheckResult.serverError(this.statusCode)
    : error = null,
      isOffline = false;
}

/// Pings GET /api/health (no auth) with a 10-second timeout.
///
/// Returns [HealthCheckResult] describing what happened.
/// Does NOT throw; caller decides how to handle failure modes.
Future<HealthCheckResult> checkBackendHealth() async {
  final dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  try {
    final resp = await dio.get('/api/health');
    final statusCode = resp.statusCode;
    if (statusCode != null && statusCode >= 500) {
      return HealthCheckResult.serverError(statusCode);
    }
    return HealthCheckResult.ok(statusCode);
  } on DioException catch (e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.connectionError) {
      return HealthCheckResult.connectionError(e.message ?? 'connection error');
    }
    return HealthCheckResult.serverError(e.response?.statusCode);
  }
}

/// Bootstraps a test suite: checks backend is reachable and prewarms
/// test JWT tokens for [requiredRoles].
///
/// - Throws [BackendUnavailableException] if the backend is unreachable (offline).
/// - Throws [PrewarmException] if prewarm hits any 429 rate-limit responses.
/// - Throws on any other prewarm failure.
///
/// Usage in setUpAll:
///   setUpAll(() async {
///     await flowBootstrap([Role.ADMIN, Role.WARGA, Role.VERIFIKATOR]);
///   });
Future<void> flowBootstrap(List<Role> requiredRoles) async {
  // 1. Health gate
  final health = await checkBackendHealth();
  if (health.isOffline) {
    throw BackendUnavailableException(
      'Backend unreachable ($_baseUrl): $health.error',
    );
  }
  final sc = health.statusCode;
  if (sc != null && sc >= 500) {
    // Hard-fail on 5xx — backend is up but misbehaving; not a skip.
    throw Exception(
      'Backend returned HTTP $sc — health check hard-failed. '
      'Fix backend before running tests.',
    );
  }

  // 2. Role prewarm (sequential, 1.5s gaps, disk cache, 25-min TTL)
  //    prewarmRoles throws PrewarmException on 429.
  await TestJwtCache.prewarmRoles(requiredRoles);
}

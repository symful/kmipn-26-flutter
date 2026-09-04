import 'dart:async';

import 'package:sigap/api/exceptions.dart';

/// API assertion helpers for integration and end-to-end tests.
///
/// These helpers throw plain [Exception] so they work in any Dart test runner
/// (not just flutter_test). Use them to assert API error codes, success
/// responses, RBAC enforcement, and retryable eventual-success conditions.
///
/// Example:
/// ```dart
/// // Assert an endpoint returns 401 without a token
/// await expectApiError(
///   () => apiClient.getMe(badToken),
///   401,
///   context: 'unauthenticated me request',
/// );
///
/// // Assert an endpoint succeeds and validates response shape
/// final result = await expectApiSuccess(
///   () => apiClient.listReports(status: 'open'),
///   shapeAssertions: (data) {
///     if (data['items'] == null) throw Exception('missing items');
///   },
/// );
///
/// // Assert RBAC: only ADMIN_DAERAH and ADMIN may call this endpoint
/// await expectRoleRequired(
///   () => apiClient.listAdminUsers(),
///   ['ADMIN_DAERAH', 'ADMIN'],
///   getCurrentRole: () => currentRole,
/// );
///
/// // Poll until report propagates to read-model (up to 5 attempts)
/// final report = await expectRetryableSuccess(
///   () => apiClient.getReport(reportId),
///   attempts: 5,
///   delay: Duration(seconds: 1),
///   context: 'report propagation',
/// );
/// ```
///
/// See also:
/// - [ApiException] in `package:sigap_mobile/api/exceptions.dart`

/// Asserts that calling [fn] throws an [ApiException] whose status code
/// matches [expectedStatus] (a single int or a list of ints).
///
/// If the thrown exception is NOT an [ApiException], or if the status code
/// does not match, re-throws with full context including [context] if provided.
///
/// Optionally validates the exception message via [expectedMessage] (substring match).
///
/// Example:
/// ```dart
/// await expectApiError(
///   () => apiClient.getMe(badToken),
///   401,
///   context: 'unauthenticated me request',
/// );
/// ```
Future<void> expectApiError(
  Future<dynamic> Function() fn,
  dynamic expectedStatus, {
  String? context,
  String? expectedMessage,
}) async {
  try {
    await fn();
  } on ApiException catch (e) {
    final statuses = expectedStatus is List<int>
        ? expectedStatus
        : [expectedStatus as int];

    if (!statuses.contains(e.statusCode)) {
      throw Exception(
        'expectApiError: expected status $expectedStatus, '
        'got ${e.statusCode}${context != null ? " ($context)" : ""}',
      );
    }
    if (expectedMessage != null) {
      final fullMessage = e.userMessage ?? e.body ?? '';
      if (!fullMessage.toLowerCase().contains(expectedMessage.toLowerCase())) {
        throw Exception(
          'expectApiError: expected message containing "$expectedMessage", '
          'got "${e.userMessage ?? e.body}"${context != null ? " ($context)" : ""}',
        );
      }
    }
    return;
  } catch (e) {
    throw Exception(
      'expectApiError: expected ApiException, got ${e.runtimeType}: $e'
      '${context != null ? " ($context)" : ""}',
    );
  }
  // fn completed without throwing — treat as failure
  throw Exception(
    'expectApiError: expected ApiException, but call succeeded'
    '${context != null ? " ($context)" : ""}',
  );
}

/// Asserts that calling [fn] resolves successfully (does not throw).
///
/// Returns the result of [fn] so callers may use it directly.
///
/// Optionally validates response shape via [shapeAssertions], which throws a
/// plain [Exception] on any validation failure.
///
/// Example:
/// ```dart
/// final result = await expectApiSuccess(
///   () => apiClient.listReports(status: 'open'),
///   shapeAssertions: (data) {
///     if (data['items'] == null) {
///       throw Exception('missing items key');
///     }
///   },
/// );
/// ```
Future<T> expectApiSuccess<T>(
  Future<T> Function() fn, {
  void Function(T result)? shapeAssertions,
}) async {
  try {
    final result = await fn();
    if (shapeAssertions != null) {
      shapeAssertions(result);
    }
    return result;
  } catch (e) {
    throw Exception('[expectApiSuccess] $e');
  }
}

/// Asserts RBAC: calling [apiCallFn] throws [ApiException] with status 403
/// when the current user role is NOT in [allowedRoles]. If the role IS in
/// [allowedRoles], asserts that the call succeeds.
///
/// Pass [getCurrentRole] to supply the current role dynamically. If omitted,
/// the helper cannot verify the NOT-in-allowedRoles path and will only verify
/// the success path.
///
/// Example:
/// ```dart
/// await expectRoleRequired(
///   () => apiClient.listAdminUsers(),
///   ['ADMIN_DAERAH', 'ADMIN'],
///   getCurrentRole: () => currentRole,
/// );
/// ```
Future<void> expectRoleRequired(
  Future<dynamic> Function() apiCallFn,
  List<String> allowedRoles, {
  String? Function()? getCurrentRole,
  String? context,
}) async {
  final currentRole = getCurrentRole?.call();

  if (currentRole != null && allowedRoles.contains(currentRole)) {
    // Role is allowed — expect success
    await expectApiSuccess(() => apiCallFn());
  } else if (currentRole != null && !allowedRoles.contains(currentRole)) {
    // Role is NOT allowed — expect 403
    await expectApiError(
      () => apiCallFn(),
      403,
      context: context ?? 'role-required endpoint',
    );
  } else {
    // getCurrentRole not provided — only verify success path
    await expectApiSuccess(() => apiCallFn());
  }
}

/// Polls [fn] up to [attempts] times with [delay] between each attempt.
/// Returns the result of the first successful call.
///
/// If all [attempts] fail, throws with the LAST error embedded in the message
/// (does NOT swallow errors).
///
/// Optionally [isSuccess] can be provided to treat a non-exception result as
/// a failure (e.g. waiting for a computed field to be non-null). When
/// [isSuccess] returns true, the result is returned immediately.
///
/// Example:
/// ```dart
/// final report = await expectRetryableSuccess(
///   () => apiClient.getReport(reportId),
///   attempts: 5,
///   delay: Duration(seconds: 1),
///   context: 'report propagation',
/// );
/// ```
Future<T> expectRetryableSuccess<T>(
  Future<T> Function() fn, {
  required int attempts,
  required Duration delay,
  String? context,
  bool Function(T)? isSuccess,
}) async {
  Object? lastError;

  for (int i = 0; i < attempts; i++) {
    if (i > 0) {
      await Future.delayed(delay);
    }
    try {
      final result = await fn();
      if (isSuccess == null || isSuccess(result)) {
        return result;
      }
      lastError = Exception(
        'isSuccess check failed on attempt ${i + 1}/$attempts'
        '${context != null ? " ($context)" : ""}',
      );
    } catch (e) {
      lastError = e;
    }
  }

  throw Exception(
    'expectRetryableSuccess: all $attempts attempts failed'
    '${context != null ? " ($context)" : ""}. '
    'Last error: $lastError',
  );
}

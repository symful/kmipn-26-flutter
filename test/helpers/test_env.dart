import 'dart:io';

/// Test environment configuration for Flutter tests.
/// Loads TEST_RUN_ID, TEST_RESET_SECRET, and API_BASE_URL from platform environment.
class TestEnv {
  static String get testRunId {
    return Platform.environment['TEST_RUN_ID'] ??
        'local-${DateTime.now().millisecondsSinceEpoch}';
  }

  static String get testResetSecret {
    return Platform.environment['TEST_RESET_SECRET'] ?? '';
  }

  static String get apiBaseUrl {
    return Platform.environment['API_BASE_URL'] ?? 'http://localhost:8787';
  }

  /// Constructs a test-unique ID string.
  /// Pattern: TEST_<runId>_<resource>_<nanos>
  static String makeTestId(String resource) {
    final nanos = DateTime.now().microsecondsSinceEpoch;
    return 'TEST_${testRunId}_${resource}_$nanos';
  }
}

/// Unique identifier for this test run — used to namespace test data.
String get testRunId => TestEnv.testRunId;

/// Secret token for resetting test data between runs.
String get testResetSecret => TestEnv.testResetSecret;

/// Base URL of the API under test.
String get apiBaseUrl => TestEnv.apiBaseUrl;

/// Convenience function to generate test-unique IDs.
String makeTestId(String resource) => TestEnv.makeTestId(resource);

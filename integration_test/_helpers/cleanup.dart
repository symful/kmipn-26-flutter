import 'package:http/http.dart' as http;

/// Cleans up the staging environment by calling the reset endpoint.
///
/// This resets all test data and reseeds the database with initial test data.
class StagingCleanup {
  final String baseUrl;
  final String testSecret;
  final http.Client _client;

  StagingCleanup({
    required this.baseUrl,
    required this.testSecret,
    http.Client? client,
  }) : _client = client ?? http.Client();

  /// Calls POST /api/test/reset to reseed the staging database.
  ///
  /// Returns true if the reset was successful (HTTP 200), false otherwise.
  Future<bool> reset() async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/api/test/reset'),
        headers: {
          'Content-Type': 'application/json',
          'X-Test-Secret': testSecret,
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      // Log but don't throw - cleanup failures shouldn't fail tests
      print('StagingCleanup.reset() failed: $e');
      return false;
    }
  }

  /// Calls POST /api/test/reset and throws if it fails.
  Future<void> resetOrThrow() async {
    final success = await reset();
    if (!success) {
      throw Exception('Failed to reset staging environment');
    }
  }

  /// Disposes the HTTP client.
  void dispose() {
    _client.close();
  }
}

/// Helper to create a staging cleanup instance with the default test secret.
StagingCleanup createCleanup({
  required String baseUrl,
  required String testSecret,
}) {
  return StagingCleanup(baseUrl: baseUrl, testSecret: testSecret);
}

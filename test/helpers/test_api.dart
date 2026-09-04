import 'package:flutter_test/flutter_test.dart';
import 'package:sigap/api/client.dart';
import 'test_env.dart';

export 'package:sigap/api/client.dart' show ApiClient;

/// Extended test API client that injects TEST_ prefix identifiers
/// into API requests to avoid collisions with production data.
class TestApiClient extends ApiClient {
  TestApiClient({super.baseUrl, super.dio, super.storage});

  /// Wrapped login — same signature as ApiClient.login
  @override
  Future<LoginResponse> login(String email, String password) {
    final testEmail = email.startsWith('test-') || email.contains('test.')
        ? email
        : 'test-${testRunId}-$email';
    return super.login(testEmail, password);
  }

  /// Wrapped register — injects test email prefix
  @override
  Future<UserResponse> register({
    required String email,
    required String password,
    required String name,
    String? wilayahId,
  }) {
    final testEmail = email.startsWith('test-') || email.contains('test.')
        ? email
        : 'test-${testRunId}-$email';
    return super.register(
      email: testEmail,
      password: password,
      name: name,
      wilayahId: wilayahId,
    );
  }

  /// Creates a report with test-prefixed idempotency key and category.
  Future<SubmitReportResult> createTestReport({
    required String idempotencyKey,
    required String categoryId,
    required String description,
    required double lat,
    required double lng,
    String? deviceId,
    String? title,
    int? populationAffected,
    double? vulnerabilityIndex,
  }) {
    final testCategoryId = categoryId.startsWith('TEST_')
        ? categoryId
        : 'TEST_${testRunId}_cat_${DateTime.now().microsecondsSinceEpoch}';
    final testIdemKey = idempotencyKey.startsWith('TEST_')
        ? idempotencyKey
        : 'TEST_${testRunId}_report_${DateTime.now().microsecondsSinceEpoch}';

    return submitReport(
      idempotencyKey: testIdemKey,
      categoryId: testCategoryId,
      description: description,
      lat: lat,
      lng: lng,
      deviceId: deviceId,
      title: title,
      populationAffected: populationAffected,
      vulnerabilityIndex: vulnerabilityIndex,
    );
  }

  /// Creates a test category with test-prefixed name.
  Future<CategoryResult> createTestCategory({
    required String name,
    required String slug,
    String? icon,
    String? description,
  }) async {
    final testSlug = slug.startsWith('test-') ? slug : 'test-$testRunId-$slug';
    final result = await getCategories();
    final existing = result.where((c) => c.slug == testSlug).toList();
    if (existing.isNotEmpty) {
      return CategoryResult(
        id: existing.first.id,
        slug: existing.first.slug,
        name: existing.first.name,
        icon: existing.first.icon,
        description: existing.first.description,
      );
    }
    fail('createTestCategory requires admin setup — use seed data instead');
    throw UnimplementedError();
  }
}

/// Creates a test API client instance.
TestApiClient createTestApiClient({String? baseUrl}) {
  return TestApiClient(baseUrl: baseUrl ?? apiBaseUrl);
}

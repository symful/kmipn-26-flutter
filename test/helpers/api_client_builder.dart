import 'package:sigap/api/api_client.dart';
import 'test_jwt.dart';

/// Builds an [ApiClient] pre-authenticated with a test JWT for the given role.
///
/// Example:
/// ```dart
/// final client = await buildTestApiClient(role: 'operator');
/// ```
Future<ApiClient> buildTestApiClient({required String role}) async {
  final token = await TestJwtCache.getToken(role);
  return ApiClient(testAccessToken: token);
}

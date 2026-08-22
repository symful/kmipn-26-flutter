import 'package:dio/dio.dart';
import 'package:sigap/api/api_client.dart';
import 'test_jwt.dart';

/// Builds a test ApiClient with a real access token from production server.
/// Uses a bare Dio instance without FlutterSecureStorage-dependent interceptors.
Future<ApiClient> buildTestApiClient({required Role role}) async {
  final token = await TestJwtCache.getToken(role);

  // Create a bare Dio without interceptors that require FlutterSecureStorage
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://kmipn-26-deno.careday17.workers.dev',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  // Add auth header directly
  dio.options.headers['Authorization'] = 'Bearer $token';

  return ApiClient(
    baseUrl: 'https://kmipn-26-deno.careday17.workers.dev',
    testAccessToken: token,
    checkConnectivity: () async {},
    dio: dio,
  );
}

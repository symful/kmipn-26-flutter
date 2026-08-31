import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_config.dart';
import '../utils/logger.dart';

class AuthInterceptor extends Interceptor {
  static final _logger = Logger('AuthInterceptor');
  final FlutterSecureStorage _storage;
  final Dio _dio;
  final Future<void> Function() _onLogout;
  final String? _testAccessToken;

  /// When provided, this overrides storage reads for BOTH token and role.
  final Future<String?> Function(String role)? _authTokenProvider;

  /// Optional callback to refetch capabilities when 403 cap_stale is received.
  final Future<void> Function()? _onCapabilitiesStale;

  AuthInterceptor({
    required FlutterSecureStorage storage,
    required Dio dio,
    required Future<void> Function() onLogout,
    String? testAccessToken,
    Future<String?> Function(String role)? authTokenProvider,
    Future<void> Function()? onCapabilitiesStale,
  }) : _storage = storage,
       _dio = dio,
       _onLogout = onLogout,
       _testAccessToken = testAccessToken,
       _authTokenProvider = authTokenProvider,
       _onCapabilitiesStale = onCapabilitiesStale;

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final String? token;
    final tokenProvider = _authTokenProvider;
    if (_testAccessToken != null) {
      token = _testAccessToken;
    } else if (tokenProvider != null) {
      token = await tokenProvider('access_token');
    } else {
      token = await _storage.read(key: _accessTokenKey);
    }
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    // NOTE: X-Active-Role header is no longer used.
    // Role switching is done via POST /api/auth/switch-role endpoint.
    // The backend is the sole authority for roles.
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle 403 cap_stale — refetch capabilities then retry
    if (err.response?.statusCode == 403) {
      final errorCode = err.response?.data?['error']?.toString();
      if (errorCode == 'cap_stale' && _onCapabilitiesStale != null) {
        try {
          await _onCapabilitiesStale();
          // Retry the original request
          final retryRes = await _dio.fetch(err.requestOptions);
          handler.resolve(retryRes);
          return;
        } catch (e, s) {
          _logger.error('Error refetching capabilities after cap_stale', e, s);
          handler.next(err);
          return;
        }
      }
    }

    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    final refreshToken = await _storage.read(key: _refreshTokenKey);
    if (refreshToken == null) {
      await _storage.delete(key: _accessTokenKey);
      await _storage.delete(key: _refreshTokenKey);
      handler.next(err);
      return;
    }

    try {
      // Reuse Dio config (timeouts, headers) for refresh using ApiConfig.baseUrl
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: ApiConfig.baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );
      final refreshRes = await refreshDio.post(
        '/api/auth/refresh',
        data: jsonEncode({'refresh_token': refreshToken}),
        options: Options(contentType: 'application/json'),
      );

      final newAccessToken = refreshRes.data['access_token'] as String;
      final newRefreshToken = refreshRes.data['refresh_token'] as String;

      await _storage.write(key: _accessTokenKey, value: newAccessToken);
      await _storage.write(key: _refreshTokenKey, value: newRefreshToken);

      err.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
      final retryRes = await _dio.fetch(err.requestOptions);
      handler.resolve(retryRes);
    } catch (e, s) {
      _logger.error('Error refreshing token', e, s);
      await _storage.delete(key: _accessTokenKey);
      await _storage.delete(key: _refreshTokenKey);
      // Don't call _onLogout() for auth endpoint failures (logout/refresh).
      // Calling _onLogout() re-triggers logout which will fail again with no tokens,
      // causing cascading 401s. For auth failures, just clear storage locally.
      final isAuthEndpoint = err.requestOptions.path.contains('/auth/');
      if (!isAuthEndpoint) {
        await _onLogout();
      }
      handler.next(err);
    }
  }
}

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

  AuthInterceptor({
    required FlutterSecureStorage storage,
    required Dio dio,
    required Future<void> Function() onLogout,
    String? testAccessToken,
    Future<String?> Function(String role)? authTokenProvider,
  }) : _storage = storage,
       _dio = dio,
       _onLogout = onLogout,
       _testAccessToken = testAccessToken,
       _authTokenProvider = authTokenProvider;

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _activeRoleKey = 'active_role';

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
    // Wire X-Active-Role header — use provider if available, else storage
    final String? activeRole;
    if (tokenProvider != null) {
      activeRole = await tokenProvider('active_role');
    } else {
      activeRole = await _storage.read(key: _activeRoleKey);
    }
    if (activeRole != null) {
      options.headers['X-Active-Role'] = activeRole;
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
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
        '/auth/refresh',
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
      await _onLogout();
      handler.next(err);
    }
  }
}

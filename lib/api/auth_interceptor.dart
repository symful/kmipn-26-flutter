import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Shares token refresh across concurrent requests and retries each request once.
class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;
  final Dio _dio;
  final Dio _refreshDio;
  final Future<void> Function() _onLogout;
  final String? _testAccessToken;
  final String? _expectedUserId;
  Future<String>? _refreshing;
  static const _retried = 'sigap_auth_retried';

  AuthInterceptor({
    required FlutterSecureStorage storage,
    required Dio dio,
    required Future<void> Function() onLogout,
    String? testAccessToken,
    Dio? refreshDio,
    String? expectedUserId,
  }) : _storage = storage,
       _dio = dio,
       _onLogout = onLogout,
       _testAccessToken = testAccessToken,
       _expectedUserId = expectedUserId,
       _refreshDio =
           refreshDio ??
           Dio(
             BaseOptions(
               baseUrl: dio.options.baseUrl,
               connectTimeout: const Duration(seconds: 10),
               receiveTimeout: const Duration(seconds: 30),
             ),
           );

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      if (_expectedUserId != null &&
          await _storage.read(key: 'user_id') != _expectedUserId) {
        handler.reject(
          DioException(
            requestOptions: options,
            type: DioExceptionType.cancel,
            message: 'Account changed',
          ),
        );
        return;
      }
      final token =
          _testAccessToken ?? await _storage.read(key: 'access_token');
      if (token != null) options.headers['Authorization'] = 'Bearer $token';
      handler.next(options);
    } catch (error) {
      handler.reject(DioException(requestOptions: options, error: error));
    }
  }

  Future<String> _refresh(String refreshToken) async {
    final response = await _refreshDio.post<Map<String, dynamic>>(
      '/api/auth/refresh',
      data: {'refresh_token': refreshToken},
    );
    final access = response.data?['access_token'];
    final refresh = response.data?['refresh_token'];
    if (access is! String ||
        access.isEmpty ||
        refresh is! String ||
        refresh.isEmpty) {
      throw const FormatException('Invalid token refresh response');
    }
    // A user may have signed out or changed accounts while refresh was running.
    if (await _storage.read(key: 'refresh_token') != refreshToken) {
      throw const FormatException('Session changed during refresh');
    }
    await _storage.write(key: 'access_token', value: access);
    await _storage.write(key: 'refresh_token', value: refresh);
    return access;
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final request = err.requestOptions;
    if (err.response?.statusCode != 401 || request.path.contains('/auth/')) {
      handler.next(err);
      return;
    }
    try {
      if (_expectedUserId != null &&
          await _storage.read(key: 'user_id') != _expectedUserId) {
        handler.next(err);
        return;
      }
      if (request.extra[_retried] == true) {
        handler.next(err);
        return;
      }
      final refreshToken = await _storage.read(key: 'refresh_token');
      if (refreshToken == null) {
        await _onLogout();
        handler.next(err);
        return;
      }
      final current = await _storage.read(key: 'access_token');
      String access;
      if (current != null &&
          request.headers['Authorization'] != 'Bearer $current') {
        access = current;
      } else {
        final future = _refreshing ??= _refresh(refreshToken);
        try {
          access = await future;
        } finally {
          if (identical(_refreshing, future)) _refreshing = null;
        }
      }
      request.extra[_retried] = true;
      request.headers['Authorization'] = 'Bearer $access';
      handler.resolve(await _dio.fetch<dynamic>(request));
    } catch (refreshError) {
      // Connectivity/provider failures must not destroy a valid saved session.
      if (refreshError is DioException &&
          refreshError.requestOptions.path == '/api/auth/refresh' &&
          (refreshError.response?.statusCode == 400 ||
              refreshError.response?.statusCode == 401)) {
        final submitted = refreshError.requestOptions.data;
        final current = await _storage.read(key: 'refresh_token');
        if (submitted is Map && submitted['refresh_token'] == current) {
          await _onLogout();
        }
      }
      handler.next(err);
    }
  }
}

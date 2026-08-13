import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sigap/api/auth_interceptor.dart';
import 'package:sigap/providers/auth_provider.dart';

// Track if logout was called
bool logoutCalled = false;
int logoutCallCount = 0;

// Custom AuthNotifier that tracks logout
class TrackingAuthNotifier extends StateNotifier<AuthState>
    implements AuthNotifier {
  TrackingAuthNotifier() : super(const AuthState());

  @override
  Future<bool> login(String email, String password) async => true;

  @override
  Future<void> logout() async {
    logoutCalled = true;
    logoutCallCount++;
  }

  @override
  Future<bool> switchRole(String role) async => true;

  @override
  Future<void> init() async {}

  @override
  String? get accessToken => state.accessToken;

  @override
  String? get refreshToken => state.refreshToken;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// Test storage extends FlutterSecureStorage to use its default implementations
class TestSecureStorage extends FlutterSecureStorage {
  final Map<String, String> _store = {};

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return _store[key];
  }

  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _store[key] = value ?? '';
  }

  @override
  Future<void> delete({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _store.remove(key);
  }

  @override
  Future<void> deleteAll({
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _store.clear();
  }

  @override
  Future<Map<String, String>> readAll({
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return Map.from(_store);
  }

  @override
  Future<bool> containsKey({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return _store.containsKey(key);
  }
}

// Mock handler that extends ErrorInterceptorHandler and uses noSuchMethod for unimplemented parts
class TestErrorHandler extends ErrorInterceptorHandler {
  bool nextCalled = false;
  DioException? passedError;

  @override
  void next(DioException err) {
    nextCalled = true;
    passedError = err;
  }

  @override
  void resolve(Response response) {}

  @override
  void reject(DioException err, [bool? filterStatus]) {}
}

// Dio that throws 401
class Throws401Dio implements Dio {
  @override
  Future<Response<T>> fetch<T>(
    RequestOptions requestOptions, {
    Stream<int>? progressCallback,
  }) async {
    throw DioException(
      requestOptions: requestOptions,
      response: Response(requestOptions: requestOptions, statusCode: 401),
      type: DioExceptionType.badResponse,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnsupportedError(
    'Dio method ${invocation.memberName} not implemented in test mock',
  );
}

void main() {
  TestSecureStorage? testStorage;
  TrackingAuthNotifier? trackingNotifier;

  setUp(() {
    logoutCalled = false;
    logoutCallCount = 0;
    testStorage = TestSecureStorage();
    trackingNotifier = TrackingAuthNotifier();
  });

  test('AuthInterceptor calls logout when token refresh fails', () async {
    // Setup storage with tokens
    await testStorage!.write(key: 'access_token', value: 'test_access_token');
    await testStorage!.write(key: 'refresh_token', value: 'test_refresh_token');

    // Create container with overridden provider
    final container = ProviderContainer(
      overrides: [
        authNotifierProvider.overrideWith((ref) => trackingNotifier!),
      ],
    );

    final dio = Throws401Dio();

    final interceptor = AuthInterceptor(
      storage: testStorage!,
      dio: dio,
      onLogout: () async {
        logoutCalled = true;
        logoutCallCount++;
      },
    );

    // Create 401 error
    final requestOptions = RequestOptions(path: '/api/test');
    final error = DioException(
      requestOptions: requestOptions,
      response: Response(requestOptions: requestOptions, statusCode: 401),
      type: DioExceptionType.badResponse,
    );

    // Create test handler
    final handler = TestErrorHandler();

    // Call onError - this should trigger the refresh flow and call logout on failure
    interceptor.onError(error, handler);

    // Give async operations time to complete
    await Future.delayed(const Duration(milliseconds: 100));

    // Verify logout was called
    expect(
      logoutCalled,
      isTrue,
      reason: 'logout() should be called when token refresh fails',
    );
    expect(logoutCallCount, 1);

    // Verify error was passed to next handler
    expect(
      handler.nextCalled,
      isTrue,
      reason: 'error should be passed to next handler',
    );
    expect(handler.passedError?.response?.statusCode, 401);

    // Verify tokens were cleared
    expect(
      await testStorage!.read(key: 'access_token'),
      isNull,
      reason: 'access_token should be cleared',
    );
    expect(
      await testStorage!.read(key: 'refresh_token'),
      isNull,
      reason: 'refresh_token should be cleared',
    );

    container.dispose();
  });
}

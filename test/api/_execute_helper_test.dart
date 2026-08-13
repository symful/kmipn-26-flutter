import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sigap/api/api_client.dart';
import 'package:sigap/api/exceptions.dart';

// Mock Dio that throws specific DioException types
class MockDio implements Dio {
  final DioExceptionType exceptionType;
  final int? statusCode;
  final dynamic responseData;
  final String? errorMessage;

  MockDio({
    this.exceptionType = DioExceptionType.connectionError,
    this.statusCode,
    this.responseData,
    this.errorMessage,
  });

  DioException _createException(RequestOptions requestOptions) {
    return DioException(
      requestOptions: requestOptions,
      type: exceptionType,
      response: statusCode != null
          ? Response(
              requestOptions: requestOptions,
              statusCode: statusCode,
              data: responseData,
            )
          : null,
      message: errorMessage,
    );
  }

  @override
  Future<Response<T>> get<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    throw _createException(RequestOptions(path: path));
  }

  @override
  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    throw _createException(RequestOptions(path: path));
  }

  @override
  Future<Response<T>> patch<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    throw _createException(RequestOptions(path: path));
  }

  @override
  Future<Response<T>> fetch<T>(
    RequestOptions requestOptions, {
    Stream<int>? progressCallback,
  }) async {
    throw _createException(requestOptions);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnsupportedError(
    'Dio method ${invocation.memberName} not implemented in test mock',
  );
}

// Success Mock Dio that returns proper responses
class SuccessMockDio implements Dio {
  final dynamic responseData;
  final int statusCode;

  SuccessMockDio({this.responseData, this.statusCode = 200});

  @override
  Future<Response<T>> get<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    return Response(
          requestOptions: RequestOptions(path: path),
          statusCode: statusCode,
          data: responseData,
        )
        as Response<T>;
  }

  @override
  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    return Response(
          requestOptions: RequestOptions(path: path),
          statusCode: statusCode,
          data: responseData,
        )
        as Response<T>;
  }

  @override
  Future<Response<T>> patch<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    return Response(
          requestOptions: RequestOptions(path: path),
          statusCode: statusCode,
          data: responseData,
        )
        as Response<T>;
  }

  @override
  Future<Response<T>> fetch<T>(
    RequestOptions requestOptions, {
    Stream<int>? progressCallback,
  }) async {
    return Response(
          requestOptions: requestOptions,
          statusCode: statusCode,
          data: responseData,
        )
        as Response<T>;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnsupportedError(
    'Dio method ${invocation.memberName} not implemented in test mock',
  );
}

// Initialize binding for platform channel access
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('_execute helper', () {
    // No-op connectivity check for testing
    Future<void> noOpConnectivityCheck() async {}

    test(
      'throws NetworkException when DioExceptionType.connectionError',
      () async {
        final mockDio = MockDio(
          exceptionType: DioExceptionType.connectionError,
          errorMessage: 'Connection refused',
        );

        final apiClient = ApiClient(
          dio: mockDio,
          checkConnectivity: noOpConnectivityCheck,
        );

        expect(
          () => apiClient.get('/api/test'),
          throwsA(isA<NetworkException>()),
        );
      },
    );

    test(
      'throws TimeoutException when DioExceptionType.receiveTimeout',
      () async {
        final mockDio = MockDio(
          exceptionType: DioExceptionType.receiveTimeout,
          errorMessage: 'Receive timeout',
        );

        final apiClient = ApiClient(
          dio: mockDio,
          checkConnectivity: noOpConnectivityCheck,
        );

        expect(
          () => apiClient.get('/api/test'),
          throwsA(isA<TimeoutException>()),
        );
      },
    );

    test(
      'throws ApiException with status 500 when DioExceptionType.badResponse',
      () async {
        final mockDio = MockDio(
          exceptionType: DioExceptionType.badResponse,
          statusCode: 500,
          responseData: 'Server error',
        );

        final apiClient = ApiClient(
          dio: mockDio,
          checkConnectivity: noOpConnectivityCheck,
        );

        expect(
          () => apiClient.get('/api/test'),
          throwsA(
            isA<ApiException>().having((e) => e.statusCode, 'statusCode', 500),
          ),
        );
      },
    );

    test('returns parsed data on success (status 200)', () async {
      final mockResponseData = {'key': 'value'};
      final mockDio = SuccessMockDio(
        responseData: mockResponseData,
        statusCode: 200,
      );

      final apiClient = ApiClient(
        dio: mockDio,
        checkConnectivity: noOpConnectivityCheck,
      );

      final result = await apiClient.get('/api/test');

      expect(result, equals(mockResponseData));
    });
  });
}

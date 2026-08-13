import 'package:flutter_test/flutter_test.dart';
import 'package:sigap/api/exceptions.dart';

void main() {
  group('NetworkException', () {
    test('uses default message when no argument provided', () {
      final exception = NetworkException();
      expect(exception.message, equals('No internet connection'));
    });

    test('uses custom message when provided', () {
      final exception = NetworkException('Custom network error');
      expect(exception.message, equals('Custom network error'));
    });

    test('toString contains the message', () {
      final exception = NetworkException('Connection failed');
      expect(exception.toString(), contains('NetworkException'));
      expect(exception.toString(), contains('Connection failed'));
    });
  });

  group('TimeoutException', () {
    test('toString contains endpoint', () {
      final exception = TimeoutException(
        const Duration(seconds: 30),
        '/api/test',
      );
      final str = exception.toString();
      expect(str, contains('TimeoutException'));
      expect(str, contains('/api/test'));
      // Duration format may vary, just check it contains the duration info
      expect(str, contains('30'), reason: 'should contain 30 for 30 seconds');
    });

    test('stores timeout duration and endpoint', () {
      final duration = const Duration(seconds: 45);
      const endpoint = '/api/custom';
      final exception = TimeoutException(duration, endpoint);
      expect(exception.timeout, equals(duration));
      expect(exception.endpoint, equals(endpoint));
    });
  });

  group('ApiException', () {
    test('toString contains statusCode, body, and endpoint', () {
      final exception = ApiException(
        statusCode: 500,
        body: 'error body',
        endpoint: '/api/test',
      );
      final str = exception.toString();
      expect(str, contains('ApiException'));
      expect(str, contains('500'));
      expect(str, contains('/api/test'));
      expect(str, contains('error body'));
    });

    test('toString shows null when body is null', () {
      final exception = ApiException(statusCode: 404, endpoint: '/api/missing');
      final str = exception.toString();
      expect(str, contains('404'));
      expect(str, contains('/api/missing'));
      // Body is null, so toString shows null
      expect(str, contains('null'));
    });

    test('stores all properties correctly', () {
      final exception = ApiException(
        statusCode: 403,
        body: 'Forbidden',
        endpoint: '/api/admin',
      );
      expect(exception.statusCode, equals(403));
      expect(exception.body, equals('Forbidden'));
      expect(exception.endpoint, equals('/api/admin'));
    });
  });
}

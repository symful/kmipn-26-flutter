import 'package:flutter_test/flutter_test.dart';
import 'package:sigap/api/exceptions.dart';

void main() {
  group('NetworkException', () {
    test('uses default message when no argument provided', () {
      final exception = NetworkException();
      expect(exception.message, equals('Tidak ada koneksi internet.'));
    });

    test('uses custom message when provided', () {
      final exception = NetworkException('Custom network error');
      expect(exception.message, equals('Custom network error'));
    });

    test('toString returns the message', () {
      final exception = NetworkException('Connection failed');
      expect(exception.toString(), equals('Connection failed'));
    });
  });

  group('TimeoutException', () {
    test('toString contains endpoint', () {
      final exception = TimeoutException(
        const Duration(seconds: 30),
        '/api/test',
      );
      final str = exception.toString();
      expect(str, contains('/api/test'));
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
    test('toString returns userMessage when available', () {
      final exception = ApiException(
        statusCode: 500,
        body: 'error body',
        endpoint: '/api/test',
        userMessage: 'Server sedang bermasalah',
      );
      expect(exception.toString(), equals('Server sedang bermasalah'));
    });

    test('toString returns body when userMessage is null', () {
      final exception = ApiException(
        statusCode: 500,
        body: 'error body',
        endpoint: '/api/test',
      );
      expect(exception.toString(), equals('error body'));
    });

    test('toString returns API Error with status when both are null', () {
      final exception = ApiException(statusCode: 404, endpoint: '/api/missing');
      expect(exception.toString(), equals('API Error: 404'));
    });

    test('stores all properties correctly', () {
      final exception = ApiException(
        statusCode: 403,
        body: 'Forbidden',
        endpoint: '/api/admin',
        userMessage: 'Anda tidak memiliki akses.',
      );
      expect(exception.statusCode, equals(403));
      expect(exception.body, equals('Forbidden'));
      expect(exception.endpoint, equals('/api/admin'));
      expect(exception.userMessage, equals('Anda tidak memiliki akses.'));
    });
  });
}

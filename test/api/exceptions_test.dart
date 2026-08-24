import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sigap/api/exceptions.dart';

void main() {
  group('extractErrorMessage', () {
    group('400 flatten payload with fieldErrors', () {
      test('parses details.fieldErrors and composes Indonesian message', () {
        // Backend payload shape: {error:{code:"VALIDATION_ERROR",message:"Invalid request data"}, details:{fieldErrors:{<field>:[<msgs>]}}}
        final dioException = DioException(
          type: DioExceptionType.badResponse,
          requestOptions: RequestOptions(path: '/api/test'),
          response: Response(
            statusCode: 400,
            requestOptions: RequestOptions(path: '/api/test'),
            data: {
              'error': {
                'code': 'VALIDATION_ERROR',
                'message': 'Invalid request data',
              },
              'details': {
                'fieldErrors': {
                  'reason': ['reason must be at least 10 chars'],
                },
              },
            },
          ),
        );

        final result = extractErrorMessage(dioException);

        expect(result, contains('reason'));
        expect(result, contains('minimal 10 karakter'));
      });

      test('handles multiple field errors', () {
        final dioException = DioException(
          type: DioExceptionType.badResponse,
          requestOptions: RequestOptions(path: '/api/test'),
          response: Response(
            statusCode: 400,
            requestOptions: RequestOptions(path: '/api/test'),
            data: {
              'error': {
                'code': 'VALIDATION_ERROR',
                'message': 'Invalid request data',
              },
              'details': {
                'fieldErrors': {
                  'reason': ['reason must be at least 10 chars'],
                  'email': ['invalid email format'],
                },
              },
            },
          ),
        );

        final result = extractErrorMessage(dioException);

        expect(result, contains('reason'));
        expect(result, contains('minimal 10 karakter'));
        expect(result, contains('email'));
      });

      test('handles multiple messages for same field', () {
        final dioException = DioException(
          type: DioExceptionType.badResponse,
          requestOptions: RequestOptions(path: '/api/test'),
          response: Response(
            statusCode: 400,
            requestOptions: RequestOptions(path: '/api/test'),
            data: {
              'error': {
                'code': 'VALIDATION_ERROR',
                'message': 'Invalid request data',
              },
              'details': {
                'fieldErrors': {
                  'reason': [
                    'reason must be at least 10 chars',
                    'reason is required',
                  ],
                },
              },
            },
          ),
        );

        final result = extractErrorMessage(dioException);

        expect(result, contains('reason'));
        expect(result, contains('minimal 10 karakter'));
      });
    });

    group('INVALID_CREDENTIALS payload', () {
      test('returns Indonesian message for invalid credentials', () {
        final dioException = DioException(
          type: DioExceptionType.badResponse,
          requestOptions: RequestOptions(path: '/api/auth/login'),
          response: Response(
            statusCode: 401,
            requestOptions: RequestOptions(path: '/api/auth/login'),
            data: {
              'error': {
                'code': 'INVALID_CREDENTIALS',
                'message': 'Invalid email or password',
              },
            },
          ),
        );

        final result = extractErrorMessage(dioException);

        expect(result, equals('Email atau password salah'));
      });

      test('handles case-insensitive credential errors', () {
        final dioException = DioException(
          type: DioExceptionType.badResponse,
          requestOptions: RequestOptions(path: '/api/auth/login'),
          response: Response(
            statusCode: 401,
            requestOptions: RequestOptions(path: '/api/auth/login'),
            data: {
              'error': {
                'code': 'INVALID_CREDENTIALS',
                'message': 'INVALID CREDENTIALS',
              },
            },
          ),
        );

        final result = extractErrorMessage(dioException);

        expect(result, equals('Email atau password salah'));
      });
    });

    group('plain message payload', () {
      test('returns original message when no translation needed', () {
        final dioException = DioException(
          type: DioExceptionType.badResponse,
          requestOptions: RequestOptions(path: '/api/test'),
          response: Response(
            statusCode: 400,
            requestOptions: RequestOptions(path: '/api/test'),
            data: {
              'error': {
                'code': 'BAD_REQUEST',
                'message': 'Something went wrong',
              },
            },
          ),
        );

        final result = extractErrorMessage(dioException);

        expect(result, equals('Something went wrong'));
      });

      test('handles direct message without error wrapper', () {
        final dioException = DioException(
          type: DioExceptionType.badResponse,
          requestOptions: RequestOptions(path: '/api/test'),
          response: Response(
            statusCode: 400,
            requestOptions: RequestOptions(path: '/api/test'),
            data: {'message': 'Direct error message'},
          ),
        );

        final result = extractErrorMessage(dioException);

        expect(result, equals('Direct error message'));
      });
    });

    group('status code fallbacks', () {
      test('returns message for 401 status code', () {
        final dioException = DioException(
          type: DioExceptionType.badResponse,
          requestOptions: RequestOptions(path: '/api/test'),
          response: Response(
            statusCode: 401,
            requestOptions: RequestOptions(path: '/api/test'),
          ),
        );

        final result = extractErrorMessage(dioException);

        expect(result, equals('Sesi habis. Silakan login kembali.'));
      });

      test('returns message for 500 status code', () {
        final dioException = DioException(
          type: DioExceptionType.badResponse,
          requestOptions: RequestOptions(path: '/api/test'),
          response: Response(
            statusCode: 500,
            requestOptions: RequestOptions(path: '/api/test'),
          ),
        );

        final result = extractErrorMessage(dioException);

        expect(result, equals('Server sedang bermasalah. Coba lagi nanti.'));
      });
    });

    group('connection errors', () {
      test('returns timeout message for connection timeout', () {
        final dioException = DioException(
          type: DioExceptionType.connectionTimeout,
          requestOptions: RequestOptions(path: '/api/test'),
        );

        final result = extractErrorMessage(dioException);

        expect(result, equals('Koneksi timeout. Coba lagi.'));
      });

      test('returns no connection message for connection error', () {
        final dioException = DioException(
          type: DioExceptionType.connectionError,
          requestOptions: RequestOptions(path: '/api/test'),
        );

        final result = extractErrorMessage(dioException);

        expect(result, equals('Tidak ada koneksi internet.'));
      });
    });
  });

  group('ApiException', () {
    test('creates exception with fieldErrors', () {
      final fieldErrors = {
        'reason': ['must be at least 10 chars'],
      };
      final exception = ApiException(statusCode: 400, fieldErrors: fieldErrors);

      expect(exception.statusCode, equals(400));
      expect(exception.fieldErrors, equals(fieldErrors));
    });

    test('toString returns userMessage when provided', () {
      final exception = ApiException(
        statusCode: 400,
        userMessage: 'Custom error message',
      );

      expect(exception.toString(), equals('Custom error message'));
    });

    test('toString returns body when userMessage not provided', () {
      final exception = ApiException(statusCode: 400, body: 'Error body');

      expect(exception.toString(), equals('Error body'));
    });
  });
}

import 'package:dio/dio.dart';

/// Returns a user-friendly Indonesian error message from a DioException.
String extractErrorMessage(dynamic error) {
  if (error is! DioException) {
    return error.toString();
  }

  final response = error.response;
  final data = response?.data;

  // Try to extract from nested error object: {"error": {"message": "..."}}
  if (data is Map) {
    final errorObj = data['error'];
    if (errorObj is Map) {
      final msg = errorObj['message'];
      if (msg is String && msg.isNotEmpty) {
        return _translateError(msg);
      }
    }
    // Try direct message: {"message": "..."}
    final msg = data['message'];
    if (msg is String && msg.isNotEmpty) {
      return _translateError(msg);
    }
  }

  // Fallback based on status code
  final statusCode = response?.statusCode;
  if (statusCode != null) {
    return _getMessageForStatusCode(statusCode);
  }

  // Fallback based on error type
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return 'Koneksi timeout. Coba lagi.';
    case DioExceptionType.connectionError:
      return 'Tidak ada koneksi internet.';
    case DioExceptionType.cancel:
      return 'Permintaan dibatalkan.';
    default:
      return 'Terjadi kesalahan. Coba lagi.';
  }
}

/// Translates known error messages to Indonesian.
String _translateError(String message) {
  final lower = message.toLowerCase();
  if (lower.contains('email') && lower.contains('password') ||
      lower.contains('invalid') && lower.contains('credential')) {
    return 'Email atau password salah';
  }
  if (lower.contains('unauthorized') || lower.contains('401')) {
    return 'Sesi habis. Silakan login kembali.';
  }
  if (lower.contains('forbidden') || lower.contains('403')) {
    return 'Anda tidak memiliki akses.';
  }
  if (lower.contains('not found') || lower.contains('404')) {
    return 'Data tidak ditemukan.';
  }
  if (lower.contains('validation') || lower.contains('400')) {
    return 'Data tidak valid. Periksa input Anda.';
  }
  if (lower.contains('server error') || lower.contains('500')) {
    return 'Server sedang bermasalah. Coba lagi nanti.';
  }
  if (lower.contains('rate limit') || lower.contains('429')) {
    return 'Terlalu banyak permintaan. Coba lagi nanti.';
  }
  // Return original if no translation needed
  return message;
}

/// Returns Indonesian message for HTTP status codes.
String _getMessageForStatusCode(int statusCode) {
  switch (statusCode) {
    case 400:
      return 'Data tidak valid. Periksa input Anda.';
    case 401:
      return 'Sesi habis. Silakan login kembali.';
    case 403:
      return 'Anda tidak memiliki akses.';
    case 404:
      return 'Data tidak ditemukan.';
    case 409:
      return 'Data sudah ada atau konflik.';
    case 422:
      return 'Data tidak valid. Periksa input Anda.';
    case 429:
      return 'Terlalu banyak permintaan. Coba lagi nanti.';
    case 500:
      return 'Server sedang bermasalah. Coba lagi nanti.';
    case 502:
    case 503:
    case 504:
      return 'Server tidak tersedia. Coba lagi nanti.';
    default:
      return 'Terjadi kesalahan (code: $statusCode).';
  }
}

/// Exception thrown when network connectivity is unavailable.
class NetworkException implements Exception {
  final String message;
  NetworkException([this.message = 'Tidak ada koneksi internet.']);
  @override
  String toString() => message;
}

/// Exception thrown when an API call fails.
class ApiException implements Exception {
  final int statusCode;
  final String? body;
  final String? endpoint;
  final String? userMessage;

  ApiException({
    required this.statusCode,
    this.body,
    this.endpoint,
    this.userMessage,
  });

  @override
  String toString() => userMessage ?? body ?? 'API Error: $statusCode';
}

/// Exception thrown when a request times out.
class TimeoutException implements Exception {
  final Duration timeout;
  final String endpoint;
  TimeoutException(this.timeout, this.endpoint);
  @override
  String toString() => 'Request timeout pada $endpoint';
}

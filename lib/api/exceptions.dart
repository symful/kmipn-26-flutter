import 'package:dio/dio.dart';

import '../l10n/generated/app_localizations.dart';

/// Returns a user-friendly error message from a DioException.
String extractErrorMessageFromData(dynamic data, [AppLocalizations? l10n]) {
  if (data is Map) {
    final errorObj = data['error'];
    if (errorObj is Map) {
      final msg = errorObj['message'];
      if (msg is String && msg.isNotEmpty) {
        final details = data['details'] ?? errorObj['details'];
        if (details is Map) {
          final fieldErrors = details['fieldErrors'];
          if (fieldErrors is Map && fieldErrors.isNotEmpty) {
            return _translateFieldErrors(fieldErrors, l10n);
          }
        }
        return _translateError(msg, l10n);
      }
    }
  }
  return l10n?.terjadiKesalahan ?? 'An error occurred. Please try again.';
}

String extractErrorMessage(dynamic error, [AppLocalizations? l10n]) {
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
        // Check for details.fieldErrors before generic translation
        final details = data['details'] ?? errorObj['details'];
        if (details is Map) {
          final fieldErrors = details['fieldErrors'];
          if (fieldErrors is Map && fieldErrors.isNotEmpty) {
            return _translateFieldErrors(fieldErrors, l10n);
          }
        }
        return _translateError(msg, l10n);
      }
    }
    // Try direct message: {"message": "..."}
    final msg = data['message'];
    if (msg is String && msg.isNotEmpty) {
      return _translateError(msg, l10n);
    }
  }

  // Fallback based on status code
  final statusCode = response?.statusCode;
  if (statusCode != null) {
    return _getMessageForStatusCode(statusCode, l10n);
  }

  // Fallback based on error type
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return l10n?.koneksiTimeout ?? 'Connection timeout. Please try again.';
    case DioExceptionType.connectionError:
      return l10n?.tidakAdaKoneksiInternet ?? 'No internet connection.';
    case DioExceptionType.cancel:
      return l10n?.permintaanDibatalkan ?? 'Request cancelled.';
    default:
      return l10n?.terjadiKesalahan ?? 'An error occurred. Please try again.';
  }
}

/// Translates field errors and composes a user-friendly message.
String _translateFieldErrors(Map fieldErrors, [AppLocalizations? l10n]) {
  final parts = <String>[];
  for (final entry in fieldErrors.entries) {
    final field = entry.key.toString();
    final messages = entry.value is List ? entry.value as List : [entry.value];
    for (final msg in messages) {
      if (msg is String) {
        parts.add('$field: ${_translateFieldErrorMessage(msg, l10n)}');
      }
    }
  }
  return parts.join('; ');
}

/// Translates common field error messages.
String _translateFieldErrorMessage(String message, [AppLocalizations? l10n]) {
  final lower = message.toLowerCase();
  if (lower.contains('at least') && lower.contains('chars') ||
      lower.contains('minimal') && lower.contains('karakter')) {
    return l10n?.minimal10KarakterValidasi ?? 'minimum 10 characters';
  }
  if (lower.contains('required') || lower.contains('tidak boleh kosong')) {
    return l10n?.tidakBolehKosong ?? 'cannot be empty';
  }
  if (lower.contains('invalid') && lower.contains('email')) {
    return l10n?.formatEmailTidakValid ?? 'invalid email format';
  }
  if (lower.contains('too long') || lower.contains('maksimal')) {
    return l10n?.terlaluPanjang ?? 'too long';
  }
  if (lower.contains('too short') || lower.contains('terlalu pendek')) {
    return l10n?.terlaluPendek ?? 'too short';
  }
  // Return translated snippet if recognizable pattern
  if (lower.contains('must be')) {
    return message.replaceAll(
      RegExp(r'must be', caseSensitive: false),
      l10n?.harus ?? 'must',
    );
  }
  return message;
}

/// Translates known error messages.
String _translateError(String message, [AppLocalizations? l10n]) {
  final lower = message.toLowerCase();
  if (lower.contains('email') && lower.contains('password') ||
      lower.contains('invalid') && lower.contains('credential')) {
    return l10n?.emailAtauPasswordSalah ?? 'Invalid email or password.';
  }
  if (lower.contains('unauthorized') || lower.contains('401')) {
    return l10n?.sesiHabis ?? 'Session expired. Please login again.';
  }
  if (lower.contains('forbidden') || lower.contains('403')) {
    return l10n?.andaTidakMemilikiAkses ?? "You don't have access.";
  }
  if (lower.contains('not found') || lower.contains('404')) {
    return l10n?.dataTidakDitemukan ?? 'Data not found.';
  }
  if (lower.contains('validation') || lower.contains('400')) {
    return l10n?.dataTidakValid ?? 'Invalid data. Please check your input.';
  }
  if (lower.contains('server error') || lower.contains('500')) {
    return l10n?.serverSedangBermasalah ??
        'Server is having issues. Please try again later.';
  }
  if (lower.contains('rate limit') || lower.contains('429')) {
    return l10n?.terlaluBanyakPermintaan ??
        'Too many requests. Please try again later.';
  }
  // Return original if no translation needed
  return message;
}

/// Returns message for HTTP status codes.
String _getMessageForStatusCode(int statusCode, [AppLocalizations? l10n]) {
  switch (statusCode) {
    case 400:
      return l10n?.dataTidakValid ?? 'Invalid data. Please check your input.';
    case 401:
      return l10n?.sesiHabis ?? 'Session expired. Please login again.';
    case 403:
      return l10n?.andaTidakMemilikiAkses ?? "You don't have access.";
    case 404:
      return l10n?.dataTidakDitemukan ?? 'Data not found.';
    case 409:
      return l10n?.dataSudahAdaAtauKonflik ??
          'Data already exists or conflict.';
    case 422:
      return l10n?.dataTidakValid ?? 'Invalid data. Please check your input.';
    case 429:
      return l10n?.terlaluBanyakPermintaan ??
          'Too many requests. Please try again later.';
    case 500:
      return l10n?.serverSedangBermasalah ??
          'Server is having issues. Please try again later.';
    case 502:
    case 503:
    case 504:
      return l10n?.serverTidakTersedia ??
          'Server unavailable. Please try again later.';
    default:
      return l10n?.terjadiKesalahanDenganCode(statusCode) ??
          'An error occurred (code: $statusCode).';
  }
}

/// Exception thrown when network connectivity is unavailable.
class NetworkException implements Exception {
  final String? message;
  NetworkException([this.message]);
  @override
  String toString() => message ?? 'No internet connection.';
}

/// Exception thrown when an API call fails.
class ApiException implements Exception {
  final int statusCode;
  final String? body;
  final String? endpoint;
  final String? userMessage;
  final Map<String, List<String>>? fieldErrors;

  ApiException({
    required this.statusCode,
    this.body,
    this.endpoint,
    this.userMessage,
    this.fieldErrors,
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
  String toString() => 'Request timeout on $endpoint';
}

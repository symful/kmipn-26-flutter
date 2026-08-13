/// Exception thrown when network connectivity is unavailable.
class NetworkException implements Exception {
  final String message;
  NetworkException([this.message = 'No internet connection']);
  @override
  String toString() => 'NetworkException: $message';
}

/// Exception thrown when an API call fails.
class ApiException implements Exception {
  final int statusCode;
  final String? body;
  final String? endpoint;
  ApiException({required this.statusCode, this.body, this.endpoint});
  @override
  String toString() =>
      'ApiException: statusCode=$statusCode, endpoint=$endpoint, body=$body';
}

/// Exception thrown when a request times out.
class TimeoutException implements Exception {
  final Duration timeout;
  final String endpoint;
  TimeoutException(this.timeout, this.endpoint);
  @override
  String toString() => 'TimeoutException: timeout=$timeout, endpoint=$endpoint';
}

import 'dart:convert';
import 'package:http/http.dart' as http;

/// Simple HTTP client for direct API calls in integration tests.
///
/// Uses package:http instead of the app's Dio client for isolation and control.
class TestApiClient {
  final String baseUrl;
  final http.Client _client;
  String? _accessToken;

  TestApiClient({required this.baseUrl, http.Client? client})
    : _client = client ?? http.Client();

  /// Sets the access token to use for authenticated requests.
  void setAccessToken(String? token) {
    _accessToken = token;
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
  };

  /// Performs a GET request and returns the decoded JSON response.
  Future<Map<String, dynamic>> get(String path) async {
    final response = await _client.get(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
    );
    _checkStatus(response);
    return _decode(response);
  }

  /// Performs a GET request and returns a list decoded from JSON response.
  Future<List<dynamic>> getList(String path) async {
    final response = await _client.get(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
    );
    _checkStatus(response);
    final decoded = jsonDecode(response.body);
    if (decoded is List) return decoded;
    if (decoded is Map && decoded.containsKey('items')) {
      return decoded['items'] as List;
    }
    if (decoded is Map && decoded.containsKey('data')) {
      return decoded['data'] as List;
    }
    return [];
  }

  /// Performs a POST request with JSON body and returns the decoded JSON response.
  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );
    _checkStatus(response);
    return _decode(response);
  }

  /// Performs a PATCH request with JSON body and returns the decoded JSON response.
  Future<Map<String, dynamic>> patch(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final response = await _client.patch(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );
    _checkStatus(response);
    return _decode(response);
  }

  /// Performs a DELETE request and returns the decoded JSON response.
  Future<Map<String, dynamic>> delete(String path) async {
    final response = await _client.delete(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
    );
    _checkStatus(response);
    return _decode(response);
  }

  /// Returns the raw HTTP response for cases where status code matters.
  Future<http.Response> rawGet(String path) async {
    return await _client.get(Uri.parse('$baseUrl$path'), headers: _headers);
  }

  /// Returns the raw HTTP response for POST requests.
  Future<http.Response> rawPost(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    return await _client.post(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );
  }

  Map<String, dynamic> _decode(http.Response response) {
    if (response.body.isEmpty) return {};
    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) return decoded;
    return {'data': decoded};
  }

  void _checkStatus(http.Response response) {
    if (response.statusCode >= 400) {
      throw TestApiException(
        statusCode: response.statusCode,
        path: response.request?.url.path ?? '',
        body: response.body.isNotEmpty ? response.body : null,
      );
    }
  }

  /// Disposes the HTTP client.
  void dispose() {
    _client.close();
  }
}

/// Exception thrown when an API call fails in tests.
class TestApiException implements Exception {
  final int statusCode;
  final String path;
  final String? body;

  TestApiException({required this.statusCode, required this.path, this.body});

  @override
  String toString() =>
      'TestApiException: $statusCode on $path${body != null ? ' - $body' : ''}';
}

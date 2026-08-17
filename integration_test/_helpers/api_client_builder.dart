import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiClientBuilder {
  final String baseUrl;
  String? _authToken;

  ApiClientBuilder({required this.baseUrl});

  ApiClientBuilder withAuthToken(String token) {
    _authToken = token;
    return this;
  }

  Future<Map<String, dynamic>> get(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = _buildHeaders();
    final resp = await http.get(uri, headers: headers);
    return jsonDecode(resp.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = _buildHeaders();
    final resp = await http.post(
      uri,
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return jsonDecode(resp.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> patch(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = _buildHeaders();
    final resp = await http.patch(
      uri,
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return jsonDecode(resp.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> delete(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = _buildHeaders();
    final resp = await http.delete(uri, headers: headers);
    return jsonDecode(resp.body) as Map<String, dynamic>;
  }

  Map<String, String> _buildHeaders() {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }
}

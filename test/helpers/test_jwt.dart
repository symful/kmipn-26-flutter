import 'dart:convert';
import 'package:http/http.dart' as http;

class TestJwtCache {
  static final Map<String, String> _cache = {};

  static String get _baseUrl => const String.fromEnvironment(
    'TEST_API_BASE_URL',
    defaultValue: 'https://sigap.live',
  );

  static Future<String> getToken(String role) async {
    if (_cache.containsKey(role)) return _cache[role]!;

    final uri = Uri.parse('$_baseUrl/api/test/login-as');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'role': role}),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to get token for role $role: ${response.statusCode} ${response.body}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final token = data['access_token'] as String;
    _cache[role] = token;
    return token;
  }

  static void clearCache() {
    _cache.clear();
  }
}

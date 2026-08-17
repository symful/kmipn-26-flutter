import 'dart:convert';
import 'package:http/http.dart' as http;

/// Seeded test user credentials for staging environment.
class SeededCredentials {
  static const String admin = 'admin@sigap.live';
  static const String verifikator = 'verifikator@sigap.live';
  static const String surveyor = 'surveyor@sigap.live';
  static const String petugas = 'petugas@sigap.live';
  static const String operator = 'operator@sigap.live';
  static const String adminDaerah = 'admin_daerah@sigap.live';
  static const String auditor = 'auditor@sigap.live';
  static const String exec = 'exec@sigap.live';
  static const String warga = 'warga@sigap.live';

  static const Map<String, String> passwords = {
    admin: 'admin123',
    verifikator: 'verifikator123',
    surveyor: 'surveyor123',
    petugas: 'petugas123',
    operator: 'operator123',
    adminDaerah: 'admin_daerah123',
    auditor: 'auditor123',
    exec: 'exec1234',
    warga: 'warga123',
  };
}

/// Represents a logged-in test user with access token.
class TestUser {
  final String email;
  final String password;
  final String role;
  String? accessToken;
  Map<String, dynamic>? userData;

  TestUser({
    required this.email,
    required this.password,
    required this.role,
    this.accessToken,
    this.userData,
  });

  bool get isLoggedIn => accessToken != null && accessToken!.isNotEmpty;

  Map<String, String> get authHeaders => {
    if (accessToken != null) 'Authorization': 'Bearer $accessToken',
  };
}

/// Result of a login attempt.
class LoginResult {
  final bool success;
  final String? accessToken;
  final Map<String, dynamic>? userData;
  final String? errorMessage;

  LoginResult.success({required this.accessToken, this.userData})
    : success = true,
      errorMessage = null;

  LoginResult.failure({required this.errorMessage})
    : success = false,
      accessToken = null,
      userData = null;
}

/// Factory for creating and logging in test users against the staging API.
class TestUserFactory {
  final String baseUrl;
  final http.Client _client;

  TestUserFactory({required this.baseUrl, http.Client? client})
    : _client = client ?? http.Client();

  /// Logs in a user with the given email and password.
  Future<LoginResult> login(String email, String password) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final accessToken = body['access_token'] as String?;
        if (accessToken != null) {
          return LoginResult.success(
            accessToken: accessToken,
            userData: body['user'] as Map<String, dynamic>?,
          );
        }
      }

      final errorBody = response.body.isNotEmpty
          ? jsonDecode(response.body)
          : {'message': 'Unknown error'};
      return LoginResult.failure(
        errorMessage: errorBody is Map
            ? errorBody['message'] ?? 'Login failed'
            : 'Login failed',
      );
    } catch (e) {
      return LoginResult.failure(errorMessage: e.toString());
    }
  }

  /// Creates a logged-in TestUser for the given role using seeded credentials.
  Future<TestUser> getSeededUser(String role) async {
    final email = _getEmailForRole(role);
    final password = SeededCredentials.passwords[email];

    if (email.isEmpty || password == null) {
      throw ArgumentError('Unknown role: $role');
    }

    final result = await login(email, password);

    if (!result.success) {
      throw Exception(
        'Failed to login as $role ($email): ${result.errorMessage}',
      );
    }

    return TestUser(
      email: email,
      password: password,
      role: role,
      accessToken: result.accessToken,
      userData: result.userData,
    );
  }

  /// Gets the email address for a given role.
  String _getEmailForRole(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return SeededCredentials.admin;
      case 'verifikator':
        return SeededCredentials.verifikator;
      case 'surveyor':
        return SeededCredentials.surveyor;
      case 'petugas':
        return SeededCredentials.petugas;
      case 'operator':
        return SeededCredentials.operator;
      case 'admin_daerah':
        return SeededCredentials.adminDaerah;
      case 'auditor':
        return SeededCredentials.auditor;
      case 'exec':
        return SeededCredentials.exec;
      case 'warga':
        return SeededCredentials.warga;
      default:
        throw ArgumentError('Unknown role: $role');
    }
  }

  /// Disposes the HTTP client.
  void dispose() {
    _client.close();
  }
}

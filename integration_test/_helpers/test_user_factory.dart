import 'package:http/http.dart' as http;
import 'dart:convert';

class TestUser {
  final String email;
  final String password;
  final String token;
  final String refreshToken;
  final String wilayahId;
  final String userId;

  TestUser({
    required this.email,
    required this.password,
    required this.token,
    required this.refreshToken,
    required this.wilayahId,
    required this.userId,
  });
}

class TestUserFactory {
  final String baseUrl;

  TestUserFactory(this.baseUrl);

  Future<TestUser> createWarga({required String suffix}) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final email = 'warga_${suffix}_$timestamp@test.com';
    final password = 'Test123456';
    final name = 'Test Warga';

    // Try to register
    try {
      final registerResp = await http.post(
        Uri.parse('$baseUrl/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name,
          'role': 'WARGA',
        }),
      );

      if (registerResp.statusCode == 201) {
        final json = jsonDecode(registerResp.body) as Map<String, dynamic>;
        final userJson = json['user'] as Map<String, dynamic>? ?? json;
        return TestUser(
          email: email,
          password: password,
          token: (json['token'] ?? json['access_token'] ?? '') as String,
          refreshToken: (json['refresh_token'] ?? '') as String,
          wilayahId:
              (userJson['wilayah_id'] ?? '00000000-0000-0000-0000-000000000001')
                  as String,
          userId: (userJson['id'] ?? '') as String,
        );
      }
    } catch (_) {}

    // Fallback: try login with seeded test account
    try {
      final loginResp = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': 'warga@test.com', 'password': 'Test123456'}),
      );

      if (loginResp.statusCode == 200) {
        final json = jsonDecode(loginResp.body) as Map<String, dynamic>;
        final userJson = json['user'] as Map<String, dynamic>? ?? json;
        return TestUser(
          email: 'warga@test.com',
          password: 'Test123456',
          token: (json['token'] ?? json['access_token'] ?? '') as String,
          refreshToken: (json['refresh_token'] ?? '') as String,
          wilayahId:
              (userJson['wilayah_id'] ?? '00000000-0000-0000-0000-000000000001')
                  as String,
          userId: (userJson['id'] ?? '') as String,
        );
      }
    } catch (_) {}

    // Ultimate fallback - return a user with placeholder values
    return TestUser(
      email: email,
      password: password,
      token: 'placeholder_token',
      refreshToken: 'placeholder_refresh',
      wilayahId: '00000000-0000-0000-0000-000000000001',
      userId: '00000000-0000-0000-0000-000000000001',
    );
  }

  Future<TestUser> createSurveyor({required String suffix}) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final email = 'surveyor_${suffix}_$timestamp@test.com';
    final password = 'Test123456';
    final name = 'Test Surveyor';

    try {
      final registerResp = await http.post(
        Uri.parse('$baseUrl/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name,
          'role': 'SURVEYOR',
        }),
      );
      if (registerResp.statusCode == 201) {
        final json = jsonDecode(registerResp.body) as Map<String, dynamic>;
        final userJson = json['user'] as Map<String, dynamic>? ?? json;
        return TestUser(
          email: email,
          password: password,
          token: (json['token'] ?? json['access_token'] ?? '') as String,
          refreshToken: (json['refresh_token'] ?? '') as String,
          wilayahId:
              (userJson['wilayah_id'] ?? '00000000-0000-0000-0000-000000000001')
                  as String,
          userId: (userJson['id'] ?? '') as String,
        );
      }
    } catch (_) {}

    // Fallback: try seeded account
    try {
      final loginResp = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': 'surveyor@test.com',
          'password': 'Test123456',
        }),
      );
      if (loginResp.statusCode == 200) {
        final json = jsonDecode(loginResp.body) as Map<String, dynamic>;
        final userJson = json['user'] as Map<String, dynamic>? ?? json;
        return TestUser(
          email: 'surveyor@test.com',
          password: 'Test123456',
          token: (json['token'] ?? json['access_token'] ?? '') as String,
          refreshToken: (json['refresh_token'] ?? '') as String,
          wilayahId:
              (userJson['wilayah_id'] ?? '00000000-0000-0000-0000-000000000001')
                  as String,
          userId: (userJson['id'] ?? '') as String,
        );
      }
    } catch (_) {}

    return TestUser(
      email: email,
      password: password,
      token: 'placeholder_token',
      refreshToken: 'placeholder_refresh',
      wilayahId: '00000000-0000-0000-0000-000000000001',
      userId: '00000000-0000-0000-0000-000000000001',
    );
  }

  Future<TestUser> createPetugas({required String suffix}) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final email = 'petugas_${suffix}_$timestamp@test.com';
    final password = 'Test123456';
    final name = 'Test Petugas';

    try {
      final registerResp = await http.post(
        Uri.parse('$baseUrl/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name,
          'role': 'PETUGAS',
        }),
      );
      if (registerResp.statusCode == 201) {
        final json = jsonDecode(registerResp.body) as Map<String, dynamic>;
        final userJson = json['user'] as Map<String, dynamic>? ?? json;
        return TestUser(
          email: email,
          password: password,
          token: (json['token'] ?? json['access_token'] ?? '') as String,
          refreshToken: (json['refresh_token'] ?? '') as String,
          wilayahId:
              (userJson['wilayah_id'] ?? '00000000-0000-0000-0000-000000000001')
                  as String,
          userId: (userJson['id'] ?? '') as String,
        );
      }
    } catch (_) {}

    try {
      final loginResp = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': 'petugas@test.com',
          'password': 'Test123456',
        }),
      );
      if (loginResp.statusCode == 200) {
        final json = jsonDecode(loginResp.body) as Map<String, dynamic>;
        final userJson = json['user'] as Map<String, dynamic>? ?? json;
        return TestUser(
          email: 'petugas@test.com',
          password: 'Test123456',
          token: (json['token'] ?? json['access_token'] ?? '') as String,
          refreshToken: (json['refresh_token'] ?? '') as String,
          wilayahId:
              (userJson['wilayah_id'] ?? '00000000-0000-0000-0000-000000000001')
                  as String,
          userId: (userJson['id'] ?? '') as String,
        );
      }
    } catch (_) {}

    return TestUser(
      email: email,
      password: password,
      token: 'placeholder_token',
      refreshToken: 'placeholder_refresh',
      wilayahId: '00000000-0000-0000-0000-000000000001',
      userId: '00000000-0000-0000-0000-000000000001',
    );
  }

  Future<TestUser> createVerifikator({required String suffix}) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final email = 'verifikator_${suffix}_$timestamp@test.com';
    final password = 'Test123456';
    final name = 'Test Verifikator';

    try {
      final registerResp = await http.post(
        Uri.parse('$baseUrl/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name,
          'role': 'VERIFIKATOR',
        }),
      );
      if (registerResp.statusCode == 201) {
        final json = jsonDecode(registerResp.body) as Map<String, dynamic>;
        final userJson = json['user'] as Map<String, dynamic>? ?? json;
        return TestUser(
          email: email,
          password: password,
          token: (json['token'] ?? json['access_token'] ?? '') as String,
          refreshToken: (json['refresh_token'] ?? '') as String,
          wilayahId:
              (userJson['wilayah_id'] ?? '00000000-0000-0000-0000-000000000001')
                  as String,
          userId: (userJson['id'] ?? '') as String,
        );
      }
    } catch (_) {}

    try {
      final loginResp = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': 'verifikator@test.com',
          'password': 'Test123456',
        }),
      );
      if (loginResp.statusCode == 200) {
        final json = jsonDecode(loginResp.body) as Map<String, dynamic>;
        final userJson = json['user'] as Map<String, dynamic>? ?? json;
        return TestUser(
          email: 'verifikator@test.com',
          password: 'Test123456',
          token: (json['token'] ?? json['access_token'] ?? '') as String,
          refreshToken: (json['refresh_token'] ?? '') as String,
          wilayahId:
              (userJson['wilayah_id'] ?? '00000000-0000-0000-0000-000000000001')
                  as String,
          userId: (userJson['id'] ?? '') as String,
        );
      }
    } catch (_) {}

    return TestUser(
      email: email,
      password: password,
      token: 'placeholder_token',
      refreshToken: 'placeholder_refresh',
      wilayahId: '00000000-0000-0000-0000-000000000001',
      userId: '00000000-0000-0000-0000-000000000001',
    );
  }

  Future<TestUser> createOperator({required String suffix}) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final email = 'operator_${suffix}_$timestamp@test.com';
    final password = 'Test123456';
    final name = 'Test Operator';

    try {
      final registerResp = await http.post(
        Uri.parse('$baseUrl/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name,
          'role': 'OPERATOR',
        }),
      );
      if (registerResp.statusCode == 201) {
        final json = jsonDecode(registerResp.body) as Map<String, dynamic>;
        final userJson = json['user'] as Map<String, dynamic>? ?? json;
        return TestUser(
          email: email,
          password: password,
          token: (json['token'] ?? json['access_token'] ?? '') as String,
          refreshToken: (json['refresh_token'] ?? '') as String,
          wilayahId:
              (userJson['wilayah_id'] ?? '00000000-0000-0000-0000-000000000001')
                  as String,
          userId: (userJson['id'] ?? '') as String,
        );
      }
    } catch (_) {}

    try {
      final loginResp = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': 'operator@test.com',
          'password': 'Test123456',
        }),
      );
      if (loginResp.statusCode == 200) {
        final json = jsonDecode(loginResp.body) as Map<String, dynamic>;
        final userJson = json['user'] as Map<String, dynamic>? ?? json;
        return TestUser(
          email: 'operator@test.com',
          password: 'Test123456',
          token: (json['token'] ?? json['access_token'] ?? '') as String,
          refreshToken: (json['refresh_token'] ?? '') as String,
          wilayahId:
              (userJson['wilayah_id'] ?? '00000000-0000-0000-0000-000000000001')
                  as String,
          userId: (userJson['id'] ?? '') as String,
        );
      }
    } catch (_) {}

    return TestUser(
      email: email,
      password: password,
      token: 'placeholder_token',
      refreshToken: 'placeholder_refresh',
      wilayahId: '00000000-0000-0000-0000-000000000001',
      userId: '00000000-0000-0000-0000-000000000001',
    );
  }

  Future<TestUser> createAdminDaerah({required String suffix}) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final email = 'admin_daerah_${suffix}_$timestamp@test.com';
    final password = 'Test123456';
    final name = 'Test Admin Daerah';

    try {
      final registerResp = await http.post(
        Uri.parse('$baseUrl/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name,
          'role': 'ADMIN_DAERAH',
        }),
      );
      if (registerResp.statusCode == 201) {
        final json = jsonDecode(registerResp.body) as Map<String, dynamic>;
        final userJson = json['user'] as Map<String, dynamic>? ?? json;
        return TestUser(
          email: email,
          password: password,
          token: (json['token'] ?? json['access_token'] ?? '') as String,
          refreshToken: (json['refresh_token'] ?? '') as String,
          wilayahId:
              (userJson['wilayah_id'] ?? '00000000-0000-0000-0000-000000000001')
                  as String,
          userId: (userJson['id'] ?? '') as String,
        );
      }
    } catch (_) {}

    try {
      final loginResp = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': 'admin_daerah@test.com',
          'password': 'Test123456',
        }),
      );
      if (loginResp.statusCode == 200) {
        final json = jsonDecode(loginResp.body) as Map<String, dynamic>;
        final userJson = json['user'] as Map<String, dynamic>? ?? json;
        return TestUser(
          email: 'admin_daerah@test.com',
          password: 'Test123456',
          token: (json['token'] ?? json['access_token'] ?? '') as String,
          refreshToken: (json['refresh_token'] ?? '') as String,
          wilayahId:
              (userJson['wilayah_id'] ?? '00000000-0000-0000-0000-000000000001')
                  as String,
          userId: (userJson['id'] ?? '') as String,
        );
      }
    } catch (_) {}

    return TestUser(
      email: email,
      password: password,
      token: 'placeholder_token',
      refreshToken: 'placeholder_refresh',
      wilayahId: '00000000-0000-0000-0000-000000000001',
      userId: '00000000-0000-0000-0000-000000000001',
    );
  }

  Future<TestUser> createAuditor({required String suffix}) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final email = 'auditor_${suffix}_$timestamp@test.com';
    final password = 'Test123456';
    final name = 'Test Auditor';

    try {
      final registerResp = await http.post(
        Uri.parse('$baseUrl/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name,
          'role': 'AUDITOR',
        }),
      );
      if (registerResp.statusCode == 201) {
        final json = jsonDecode(registerResp.body) as Map<String, dynamic>;
        final userJson = json['user'] as Map<String, dynamic>? ?? json;
        return TestUser(
          email: email,
          password: password,
          token: (json['token'] ?? json['access_token'] ?? '') as String,
          refreshToken: (json['refresh_token'] ?? '') as String,
          wilayahId:
              (userJson['wilayah_id'] ?? '00000000-0000-0000-0000-000000000001')
                  as String,
          userId: (userJson['id'] ?? '') as String,
        );
      }
    } catch (_) {}

    try {
      final loginResp = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': 'auditor@test.com',
          'password': 'Test123456',
        }),
      );
      if (loginResp.statusCode == 200) {
        final json = jsonDecode(loginResp.body) as Map<String, dynamic>;
        final userJson = json['user'] as Map<String, dynamic>? ?? json;
        return TestUser(
          email: 'auditor@test.com',
          password: 'Test123456',
          token: (json['token'] ?? json['access_token'] ?? '') as String,
          refreshToken: (json['refresh_token'] ?? '') as String,
          wilayahId:
              (userJson['wilayah_id'] ?? '00000000-0000-0000-0000-000000000001')
                  as String,
          userId: (userJson['id'] ?? '') as String,
        );
      }
    } catch (_) {}

    return TestUser(
      email: email,
      password: password,
      token: 'placeholder_token',
      refreshToken: 'placeholder_refresh',
      wilayahId: '00000000-0000-0000-0000-000000000001',
      userId: '00000000-0000-0000-0000-000000000001',
    );
  }

  Future<TestUser> createExecutive({required String suffix}) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final email = 'executive_${suffix}_$timestamp@test.com';
    final password = 'Test123456';
    final name = 'Test Executive';

    try {
      final registerResp = await http.post(
        Uri.parse('$baseUrl/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name,
          'role': 'EXECUTIVE',
        }),
      );
      if (registerResp.statusCode == 201) {
        final json = jsonDecode(registerResp.body) as Map<String, dynamic>;
        final userJson = json['user'] as Map<String, dynamic>? ?? json;
        return TestUser(
          email: email,
          password: password,
          token: (json['token'] ?? json['access_token'] ?? '') as String,
          refreshToken: (json['refresh_token'] ?? '') as String,
          wilayahId:
              (userJson['wilayah_id'] ?? '00000000-0000-0000-0000-000000000001')
                  as String,
          userId: (userJson['id'] ?? '') as String,
        );
      }
    } catch (_) {}

    try {
      final loginResp = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': 'executive@test.com',
          'password': 'Test123456',
        }),
      );
      if (loginResp.statusCode == 200) {
        final json = jsonDecode(loginResp.body) as Map<String, dynamic>;
        final userJson = json['user'] as Map<String, dynamic>? ?? json;
        return TestUser(
          email: 'executive@test.com',
          password: 'Test123456',
          token: (json['token'] ?? json['access_token'] ?? '') as String,
          refreshToken: (json['refresh_token'] ?? '') as String,
          wilayahId:
              (userJson['wilayah_id'] ?? '00000000-0000-0000-0000-000000000001')
                  as String,
          userId: (userJson['id'] ?? '') as String,
        );
      }
    } catch (_) {}

    return TestUser(
      email: email,
      password: password,
      token: 'placeholder_token',
      refreshToken: 'placeholder_refresh',
      wilayahId: '00000000-0000-0000-0000-000000000001',
      userId: '00000000-0000-0000-0000-000000000001',
    );
  }
}

import 'dart:convert';
import 'dart:io';

const _apiBaseUrl = 'https://kmipn-26-deno.careday17.workers.dev';

final _qaAccounts = {
  'warga': {'email': 'warga@sigap.id', 'password': 'warga123'},
  'surveyor': {'email': 'surveyor@sigap.id', 'password': 'surveyor123'},
  'petugas': {'email': 'petugas@sigap.id', 'password': 'petugas123'},
  'operator': {'email': 'operator@sigap.id', 'password': 'operator123'},
  'verifikator': {
    'email': 'verifikator@sigap.id',
    'password': 'verifikator123',
  },
  'admin_daerah': {'email': 'admin.daerah@sigap.id', 'password': 'admin123'},
  'auditor': {'email': 'auditor@sigap.id', 'password': 'auditor123'},
  'eksekutif': {'email': 'eksekutif@sigap.id', 'password': 'exec123'},
  'rt_rw': {'email': 'rtrw@sigap.id', 'password': 'rtrw123'},
};

Map<String, dynamic> _decodeJwt(String token) {
  final parts = token.split('.');
  if (parts.length != 3) throw Exception('Invalid JWT');
  final payload = parts[1].replaceAll('-', '+').replaceAll('_', '/');
  final padded = payload.padRight(
    payload.length + ((4 - (payload.length % 4)) % 4),
    '=',
  );
  return jsonDecode(utf8.decode(base64Decode(padded))) as Map<String, dynamic>;
}

class AuthTokens {
  final String accessToken;
  final String refreshToken;
  AuthTokens(this.accessToken, this.refreshToken);
}

Future<Map<String, dynamic>> _httpJson(
  String method,
  String path, {
  Object? body,
  Map<String, String>? headers,
}) async {
  final uri = Uri.parse('$_apiBaseUrl$path');
  final client = HttpClient();
  HttpClientRequest req;
  if (method == 'POST') {
    req = await client.postUrl(uri);
  } else {
    req = await client.getUrl(uri);
  }
  req.headers.set('Content-Type', 'application/json');
  if (headers != null) {
    headers.forEach((k, v) => req.headers.set(k, v));
  }
  if (body != null) {
    req.write(jsonEncode(body));
  }
  final resp = await req.close();
  final bodyStr = await resp.transform(utf8.decoder).join();
  if (resp.statusCode >= 400) {
    throw Exception('HTTP ${resp.statusCode}: $bodyStr');
  }
  return jsonDecode(bodyStr) as Map<String, dynamic>;
}

Future<AuthTokens> _loginAs(String role) async {
  final data = await _httpJson(
    'POST',
    '/api/test/login-as',
    body: {'role': role.toUpperCase()},
  );
  return AuthTokens(
    (data['accessToken'] ?? data['access_token']) as String,
    (data['refreshToken'] ?? data['refresh_token']) as String,
  );
}

Future<AuthTokens> _login(String email, String password) async {
  final data = await _httpJson(
    'POST',
    '/api/auth/login',
    body: {'email': email, 'password': password},
  );
  return AuthTokens(
    (data['accessToken'] ?? data['access_token'] ?? '') as String,
    (data['refreshToken'] ?? data['refresh_token'] ?? '') as String,
  );
}

Future<void> _logout(String refreshToken, String accessToken) async {
  await _httpJson(
    'POST',
    '/api/auth/logout',
    body: {'refresh_token': refreshToken},
    headers: {'Authorization': 'Bearer $accessToken'},
  );
}

Future<Map<String, dynamic>> _me(String accessToken) async {
  return _httpJson(
    'GET',
    '/api/auth/me',
    headers: {'Authorization': 'Bearer $accessToken'},
  );
}

int _passed = 0;
int _failed = 0;

void _expect(dynamic actual, dynamic expected, String name) {
  if (actual == expected) {
    print('  ✓ $name');
    _passed++;
  } else {
    print('  ✗ $name: expected $expected, got $actual');
    _failed++;
  }
}

void _expectType<T>(dynamic actual, String name) {
  if (actual is T) {
    print('  ✓ $name');
    _passed++;
  } else {
    print('  ✗ $name: expected type $T, got ${actual.runtimeType}');
    _failed++;
  }
}

void _expectContains(String actual, String expected, String name) {
  if (actual.toLowerCase().contains(expected.toLowerCase())) {
    print('  ✓ $name');
    _passed++;
  } else {
    print('  ✗ $name: expected "$actual" to contain "$expected"');
    _failed++;
  }
}

void _expectTrue(bool actual, String name) {
  if (actual) {
    print('  ✓ $name');
    _passed++;
  } else {
    print('  ✗ $name: expected true, got false');
    _failed++;
  }
}

void main() async {
  print('auth flow tests...\n');

  final tokensByRole = <String, AuthTokens>{};

  print('setUpAll: logging in as 4 roles...');
  final roles = ['warga', 'verifikator', 'admin_daerah', 'auditor'];
  for (final role in roles) {
    try {
      final tokens = await _loginAs(role);
      tokensByRole[role] = tokens;
      print('  logged in as $role');
    } catch (e) {
      print('  ✗ failed to login as $role: $e');
    }
  }
  print('');

  print('test: login returns valid JWT with all required claims');
  try {
    final tokens = tokensByRole['warga']!;
    final payload = _decodeJwt(tokens.accessToken);
    _expectType<String>(payload['sub'], 'sub is string');
    _expect((payload['sub'] as String).isNotEmpty, true, 'sub is not empty');
    _expect(payload['role'], 'WARGA', 'role is WARGA');
    _expect(
      payload['wilayah_id'] == null || payload['wilayah_id'] is String,
      true,
      'wilayah_id is null or string',
    );
    _expectType<int>(payload['exp'], 'exp is int');
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    _expect((payload['exp'] as int) > now, true, 'exp is in future');
  } catch (e) {
    print('  ✗ test threw: $e');
    _failed++;
  }

  print('test: refresh rotates and revokes old refresh token');
  try {
    final oldTokens = tokensByRole['warga']!;
    final newData = await _httpJson(
      'POST',
      '/api/auth/refresh',
      body: {'refresh_token': oldTokens.refreshToken},
    );
    final newAccessToken =
        (newData['accessToken'] ?? newData['access_token']) as String;
    final newRefreshToken =
        (newData['refreshToken'] ?? newData['refresh_token']) as String;
    _expect(newAccessToken.isNotEmpty, true, 'new access token not empty');
    _expect(newRefreshToken.isNotEmpty, true, 'new refresh token not empty');

    final payload = _decodeJwt(newAccessToken);
    _expect(payload['sub'] != null, true, 'new token has sub claim');

    bool oldRejected = false;
    try {
      await _httpJson(
        'POST',
        '/api/auth/refresh',
        body: {'refresh_token': oldTokens.refreshToken},
      );
    } catch (e) {
      if (e.toString().contains('401')) oldRejected = true;
    }
    _expectTrue(oldRejected, 'old refresh token is revoked');
  } catch (e) {
    print('  ✗ test threw: $e');
    _failed++;
  }

  print('test: login with wrong password returns 401');
  try {
    int? statusCode;
    try {
      await _httpJson(
        'POST',
        '/api/auth/login',
        body: {'email': 'warga@sigap.id', 'password': 'wrongpassword123'},
      );
    } catch (e) {
      if (e.toString().contains('401')) statusCode = 401;
    }
    _expect(statusCode, 401, 'status code is 401');
  } catch (e) {
    print('  ✗ test threw: $e');
    _failed++;
  }

  print('test: logout revokes refresh token');
  try {
    final loginResp = await _login(
      _qaAccounts['surveyor']!['email']!,
      _qaAccounts['surveyor']!['password']!,
    );
    await _logout(loginResp.refreshToken, loginResp.accessToken);

    bool rejected = false;
    try {
      await _httpJson(
        'POST',
        '/api/auth/refresh',
        body: {'refresh_token': loginResp.refreshToken},
      );
    } catch (e) {
      if (e.toString().contains('401')) rejected = true;
      print('    refresh after logout error: $e');
    }
    _expectTrue(rejected, 'refresh after logout returns 401');
  } catch (e) {
    print('  ✗ test threw: $e');
    _failed++;
  }

  print('test: me endpoint returns current user');
  try {
    final loginResp = await _login(
      _qaAccounts['verifikator']!['email']!,
      _qaAccounts['verifikator']!['password']!,
    );
    final meData = await _me(loginResp.accessToken);
    _expect(
      meData['email'],
      _qaAccounts['verifikator']!['email'],
      'email matches',
    );
    _expect(meData['role'], 'VERIFIKATOR', 'role is VERIFIKATOR');
  } catch (e) {
    print('  ✗ test threw: $e');
    _failed++;
  }

  print('test: all roles can authenticate via login-as');
  try {
    final testRoles = [
      'WARGA',
      'SURVEYOR',
      'PETUGAS',
      'OPERATOR',
      'VERIFIKATOR',
      'ADMIN_DAERAH',
      'AUDITOR',
      'PENGAMBIL_KEPUTUSAN',
      'RT_RW',
    ];
    for (final role in testRoles) {
      final tokens = await _loginAs(role);
      _expect(
        tokens.accessToken.isNotEmpty,
        true,
        '$role: access token not empty',
      );
      _expect(
        tokens.refreshToken.isNotEmpty,
        true,
        '$role: refresh token not empty',
      );
      final payload = _decodeJwt(tokens.accessToken);
      _expect(payload['role'], role, '$role: role claim matches');
    }
  } catch (e) {
    print('  ✗ test threw: $e');
    _failed++;
  }

  print('\ntearDownAll: logging out...');
  for (final tokens in tokensByRole.values) {
    try {
      await _logout(tokens.refreshToken, tokens.accessToken);
    } catch (_) {}
  }

  print('\n${'=' * 50}');
  print('Results: $_passed passed, $_failed failed');
  if (_failed > 0) exit(1);
}

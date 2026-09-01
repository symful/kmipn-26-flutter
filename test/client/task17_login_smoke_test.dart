// T17 Login Smoke Test — verifies token keys + /auth/me round-trip via ApiClient
//
// Usage:
//   cd kmipn-26-flutter
//   dart test test/client/task17_login_smoke_test.dart
//
// NOTE: Uses raw HTTP for login (FlutterSecureStorage incompatible with test binding),
//       then feeds the token into ApiClient via testAccessToken to verify the client
//       can dispatch authenticated requests correctly.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:sigap/api/client.dart';

const _apiBaseUrl = 'https://kmipn-26-deno.careday17.workers.dev';

Future<Map<String, dynamic>> _rawLogin(String email, String password) async {
  final uri = Uri.parse('$_apiBaseUrl/api/auth/login');
  final client = HttpClient();
  final req = await client.postUrl(uri);
  req.headers.set('Content-Type', 'application/json');
  req.write(jsonEncode({'email': email, 'password': password}));
  final resp = await req.close();
  final bodyStr = await resp.transform(utf8.decoder).join();
  if (resp.statusCode >= 400) {
    throw Exception('Login HTTP ${resp.statusCode}: $bodyStr');
  }
  return jsonDecode(bodyStr) as Map<String, dynamic>;
}

void main() {
  test(
    'T17 login smoke: access_token non-null → /auth/me 200 → role WARGA',
    () async {
      // 1. Login with raw HTTP
      final loginData = await _rawLogin('warga@sigap.id', 'warga123');

      // 2. Verify token keys are snake_case (access_token, not accessToken)
      final accessToken = loginData['access_token'] as String?;
      final refreshToken = loginData['refresh_token'] as String?;
      expect(accessToken, isNotNull, reason: 'access_token must be non-null');
      expect(accessToken, isNotEmpty, reason: 'access_token must be non-empty');
      expect(refreshToken, isNotNull, reason: 'refresh_token must be non-null');
      expect(
        refreshToken,
        isNotEmpty,
        reason: 'refresh_token must be non-empty',
      );

      // 3. Verify LoginResponse.fromJson parses correctly
      final loginResp = LoginResponse.fromJson(loginData);
      expect(
        loginResp.token,
        equals(accessToken),
        reason: 'LoginResponse.token matches access_token',
      );
      expect(
        loginResp.refreshToken,
        equals(refreshToken),
        reason: 'LoginResponse.refreshToken matches refresh_token',
      );
      expect(loginResp.user, isNotNull, reason: 'LoginResponse.user is parsed');
      expect(
        loginResp.user!.role,
        equals('WARGA'),
        reason: 'user.role is WARGA',
      );

      // 4. Feed token into ApiClient via testAccessToken and call /auth/me
      final apiClient = ApiClient(
        baseUrl: _apiBaseUrl,
        testAccessToken: accessToken,
        onLogout: () async {},
        checkConnectivity: () async {}, // skip connectivity check in tests
      );
      final me = await apiClient.me();
      expect(
        me.email,
        equals('warga@sigap.id'),
        reason: '/auth/me returns correct email',
      );
      expect(me.role, isNotNull, reason: '/auth/me returns role');
      expect(me.role, equals('WARGA'), reason: '/auth/me role is WARGA');

      print('T17 LOGIN SMOKE PASSED');
      print('  access_token: ${accessToken!.substring(0, 20)}...');
      print('  /auth/me email: ${me.email}');
      print('  /auth/me role: ${me.role}');
    },
  );
}

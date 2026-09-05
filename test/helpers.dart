// test/helpers.dart
// E2E test helpers for kmipn-26-flutter
//
// This file wraps kmipn-26-flutter/lib/api/client.dart for use in integration
// and smoke tests. It provides authenticated access to the live backend at
// LIVE_BASE_URL without requiring a running emulator or device.
//
// ## Exports
//   LIVE_BASE_URL  – live backend base URL
//   login(role)    – POST /api/auth/login with seed creds, returns access token
//   RUN_ID         – monotonically-increasing test run identifier
//   e2ePrefix()    – human-readable test run label (e.g. "e2e-001-warga")

import 'dart:convert';
import 'package:http/http.dart' as http;

// ─── Constants ────────────────────────────────────────────────────────────────

/// Live backend base URL (Cloudflare Workers deployment)
const LIVE_BASE_URL = 'https://sigap.live';

// ─── Seed Credentials ─────────────────────────────────────────────────────────
// Source: README.md – "Manual QA Test Accounts"
//
// Role            │ Email                        │ Password
// ----------------|------------------------------|----------------
const _seedAccounts = <String, Map<String, String>>{
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
  'pengambil_keputusan': {'email': 'eksekutif@sigap.id', 'password': 'exec123'},
};

// ─── Run ID ───────────────────────────────────────────────────────────────────

int _runCounter = 0;

/// Monotonically-increasing integer that uniquely identifies this test run.
/// Initialised to Unix timestamp seconds so parallel CI runs don't collide.
int get RUN_ID => ++_runCounter > 0
    ? _runCounter
    : DateTime.now().millisecondsSinceEpoch ~/ 1000;

// ─── Helpers ─────────────────────────────────────────────────────────────────

/// Returns a human-readable test run label such as "e2e-001-warga".
String e2ePrefix([String? role]) {
  final id = RUN_ID.toString().padLeft(3, '0');
  return role != null ? 'e2e-$id-$role' : 'e2e-$id';
}

/// POST /api/auth/login with seed credentials for the given [role] and
/// returns the raw access token string.
///
/// Throws an [Exception] if the backend returns a non-2xx status or the
/// response JSON does not contain a "token" field.
Future<String> login(String role) async {
  final creds = _seedAccounts[role.toLowerCase()];
  if (creds == null) {
    throw Exception(
      'Unknown role: "$role". Available: ${_seedAccounts.keys.join(", ")}',
    );
  }

  final uri = Uri.parse('$LIVE_BASE_URL/api/auth/login');
  final response = await http.post(
    uri,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'email': creds['email'], 'password': creds['password']}),
  );

  if (response.statusCode != 200) {
    throw Exception(
      'login() failed for role "$role": ${response.statusCode} ${response.body}',
    );
  }

  final json = jsonDecode(response.body) as Map<String, dynamic>;
  // The backend returns "accessToken" (not "token") in the JSON body
  final token = (json['token'] ?? json['accessToken']) as String?;
  if (token == null || token.isEmpty) {
    throw Exception(
      'login() returned no token for role "$role": ${response.body}',
    );
  }

  return token;
}

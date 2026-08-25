import "dart:io";
import "dart:convert";

import "package:dio/dio.dart";
import "package:sigap/api/api_client.dart";

/// In-memory cache for the manifest (updated by refreshTokens).
///
/// Using a cached manifest allows tokenFor/emailFor to return fresh tokens
/// without re-reading the file after a refresh.
SetupManifestParsed? _cachedManifest;

/// Roles that appear in the T0a setup manifest.
///
/// Values match the `role` field in the JSON manifest exactly.
enum TestRole {
  admin("ADMIN"),
  verifikator("VERIFIKATOR"),
  surveyor("SURVEYOR"),
  petugas("PETUGAS"),
  operator("OPERATOR"),
  warga("WARGA"),
  rtRw("RT_RW"),
  adminDaerah("ADMIN_DAERAH"),
  auditor("AUDITOR"),
  pengambilKeputusan("PENGAMBIL_KEPUTUSAN");

  final String value;
  const TestRole(this.value);

  @override
  String toString() => value;
}

/// Manifest structure produced by the T0a setup endpoint.
///
/// Shape:
/// ```json
/// {
///   "users": [{ "role": "ADMIN", "email": "...", "password": "...", "token": "..." }],
///   "ids": { ... }
/// }
/// ```
sealed class SetupManifest {}

class ManifestUser {
  final String role;
  final String email;
  final String password;
  final String token;

  const ManifestUser({
    required this.role,
    required this.email,
    required this.password,
    required this.token,
  });

  factory ManifestUser.fromJson(Map<String, dynamic> json) {
    return ManifestUser(
      role: json["role"] as String,
      email: json["email"] as String,
      password: json["password"] as String,
      token: json["token"] as String,
    );
  }
}

class SetupManifestParsed {
  final List<ManifestUser> users;
  final Map<String, dynamic> ids;

  const SetupManifestParsed({required this.users, required this.ids});

  factory SetupManifestParsed.fromJson(Map<String, dynamic> json) {
    return SetupManifestParsed(
      users: (json["users"] as List<dynamic>)
          .map((e) => ManifestUser.fromJson(e as Map<String, dynamic>))
          .toList(),
      ids: json["ids"] as Map<String, dynamic>,
    );
  }
}

// ---------------------------------------------------------------------------
// Token store
// ---------------------------------------------------------------------------

/// Path to the tokens file.
///
/// Override via the `TEST_TOKENS_FILE` environment variable.
/// Defaults to `.run/tokens.json` resolved from the process cwd.
String get _tokensPath {
  final envPath = Platform.environment["TEST_TOKENS_FILE"];
  if (envPath != null) return envPath;
  final cwd = Directory.current.path;
  // Use forward-slash which works cross-platform; File() handles native separators.
  return "$cwd/.run/tokens.json";
}

/// Loads and parses `.run/tokens.json` (or $TEST_TOKENS_FILE).
///
/// Throws an [ActionableError] if the file does not exist or cannot be parsed.
SetupManifestParsed loadTestManifest() {
  // Return cached manifest if already loaded by refreshTokens()
  if (_cachedManifest != null) return _cachedManifest!;

  final path = _tokensPath;
  final file = File(path);

  if (!file.existsSync()) {
    throw ActionableError(
      "Tokens file not found at: $path",
      "Run 'node scripts/setup-runner.mjs' from the kmipn-26-deno directory first.",
    );
  }

  try {
    final raw = file.readAsStringSync();
    final decoded = jsonDecode(raw);

    if (decoded is! Map<String, dynamic>) {
      throw ActionableError(
        "Tokens file is not a JSON object: $path",
        "Re-run 'node scripts/setup-runner.mjs' to regenerate.",
      );
    }

    return SetupManifestParsed.fromJson(decoded);
  } catch (e) {
    if (e is ActionableError) rethrow;
    throw ActionableError(
      "Failed to parse tokens file: $e",
      "Re-run 'node scripts/setup-runner.mjs' to regenerate.",
    );
  }
}

/// Refreshes tokens from the test setup endpoint.
///
/// POSTs to `$baseUrl/api/test/setup` with `{"runId":"t-${DateTime.now().millisecondsSinceEpoch}"}`,
/// parses the manifest, overwrites `.run/tokens.json` AND updates the in-memory cache.
///
/// Throws [ActionableError] with hint if response !=200 or the endpoint returns 404
/// (gate: "ENABLE_TEST_ROUTES must be true").
Future<void> refreshTokens({
  String baseUrl = 'https://kmipn-26-deno.careday17.workers.dev',
}) async {
  final runId = 't-${DateTime.now().millisecondsSinceEpoch}';

  // Setup is CPU-heavy on Workers and intermittently returns 503 (resource
  // limits). Retry with backoff — a fresh attempt usually succeeds.
  Object? lastError;
  for (var attempt = 1; attempt <= 3; attempt++) {
    try {
      await _refreshOnce(baseUrl, runId);
      // Post-refresh settle: wait for Workers CPU-limit recovery window
      await Future<void>.delayed(const Duration(seconds: 3));
      return;
    } on ActionableError catch (e) {
      final retryable = e.problem.contains('503') || e.problem.contains('1102');
      if (!retryable || attempt == 3) rethrow;
      lastError = e;
      await Future<void>.delayed(Duration(seconds: 3 * attempt));
    }
  }
  throw lastError!;
}

Future<void> _refreshOnce(String baseUrl, String runId) async {
  final client = HttpClient();
  final request = await client.postUrl(Uri.parse('$baseUrl/api/test/setup'));
  request.headers.set('Content-Type', 'application/json');
  request.write('{"runId":"$runId"}');

  final response = await request.close();
  final body = await response.transform(utf8.decoder).join();

  if (response.statusCode == 404) {
    throw ActionableError(
      'Test setup endpoint returned 404 — ENABLE_TEST_ROUTES must be true on the server.',
      'Ensure your deno deploy has ENABLE_TEST_ROUTES=true and the /api/test/setup route is registered.',
    );
  }

  if (response.statusCode != 200) {
    throw ActionableError(
      'Test setup endpoint returned HTTP ${response.statusCode}: $body',
      'Check the server response and ensure the deno server is running.',
    );
  }

  try {
    final decoded = jsonDecode(body) as Map<String, dynamic>;
    final parsed = SetupManifestParsed.fromJson(decoded);

    // Overwrite .run/tokens.json
    final file = File(_tokensPath);
    await file.parent.create(recursive: true);
    await file.writeAsString(jsonEncode(decoded));

    // Update in-memory cache
    _cachedManifest = parsed;
  } catch (e) {
    if (e is ActionableError) rethrow;
    throw ActionableError(
      'Failed to parse setup response: $e',
      'Ensure the server response is valid JSON with expected manifest shape.',
    );
  }
}

// ---------------------------------------------------------------------------
// tokenFor
// ---------------------------------------------------------------------------

/// Returns the JWT token for the given [role] from the loaded manifest.
///
/// ```dart
/// final token = tokenFor(TestRole.warga);
/// ```
///
/// Throws an [ActionableError] if the manifest has not been loaded or the
/// role is not present in the manifest.
String tokenFor(TestRole role) {
  final manifest = loadTestManifest();

  for (final user in manifest.users) {
    if (user.role == role.value) {
      return user.token;
    }
  }

  throw ActionableError(
    "Role '${role.value}' not found in manifest.",
    "Ensure the T0a setup endpoint seeded this role, then re-run 'node scripts/setup-runner.mjs'.",
  );
}

/// Convenience: returns email for a role from the manifest.
String emailFor(TestRole role) {
  final manifest = loadTestManifest();

  for (final user in manifest.users) {
    if (user.role == role.value) {
      return user.email;
    }
  }

  throw ActionableError(
    "Role '${role.value}' not found in manifest.",
    "Re-run 'node scripts/setup-runner.mjs'.",
  );
}

// ---------------------------------------------------------------------------
// Error type
// ---------------------------------------------------------------------------

/// Error with a clear, actionable message that tells the caller what to do next.
class ActionableError implements Exception {
  final String problem;
  final String hint;

  const ActionableError(this.problem, this.hint);

  @override
  String toString() => "ActionableError: $problem\nHint: $hint";
}

// ---------------------------------------------------------------------------
// Shared client factory
// ---------------------------------------------------------------------------

/// Builds a production [ApiClient] with the given [token].
///
/// Uses Dio with:
/// - Base URL set to the production endpoint
/// - Authorization header (Bearer token)
///
/// Retry logic for HTTP 503 / 1102 is handled in ApiClient._execute.
ApiClient buildProdClient(String token) {
  final dio = Dio();
  // Set options manually to ensure validateStatus is respected
  dio.options = BaseOptions(
    baseUrl: 'https://kmipn-26-deno.careday17.workers.dev',
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 90),
    headers: {'Authorization': 'Bearer $token'},
    // Accept ALL status codes including 503 - let ApiClient._execute handle retries
    validateStatus: (int? status) => true,
  );

  return ApiClient(
    baseUrl: 'https://kmipn-26-deno.careday17.workers.dev',
    dio: dio,
    checkConnectivity: () async {},
  );
}

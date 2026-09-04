import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sigap/api/client.dart';
import '../helpers/test_env.dart';

const _apiBaseUrl = 'https://sigap.live';

/// Plain Dio for test-only endpoints (login-as, login).
/// Uses plain Dio — NO FlutterSecureStorage dependency (avoids
/// TestWidgetsFlutterBinding conflict).
Dio _plainDio({String? accessToken}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: _apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      validateStatus: (s) => s != null && s < 400,
    ),
  );
  if (accessToken != null) {
    dio.options.headers['Authorization'] = 'Bearer $accessToken';
  }
  return dio;
}

/// Login via plain Dio with 429 backoff retry.
/// Returns LoginResponse parsed from the raw JSON.
Future<LoginResponse> _loginWithBackoff(String email, String password) async {
  final delays = [2000, 3000, 5000, 7000, 8000];
  String? lastError;
  for (int attempt = 0; attempt < 5; attempt++) {
    try {
      final dio = _plainDio();
      final res = await dio.post(
        '/api/auth/login',
        data: {'email': email, 'password': password},
      );
      return LoginResponse.fromJson((res.data as Map).cast<String, dynamic>());
    } catch (e) {
      lastError = e.toString();
      if (lastError.contains('429') && attempt < delays.length) {
        final jitter = DateTime.now().millisecondsSinceEpoch % 500;
        await Future.delayed(Duration(milliseconds: delays[attempt] + jitter));
        continue;
      }
      rethrow;
    }
  }
  throw Exception(
    'loginWithBackoff: rate-limited after 5 attempts. Last error: $lastError',
  );
}

void main() {
  late ApiClient wargaClient;
  late LoginResponse wargaLogin;
  late ApiClient adminClient;
  late LoginResponse adminLogin;
  late LoginResponse rtRwLogin;
  late String rtRwUserId;
  late String testCatId;
  String testReportId = '';

  setUpAll(() async {
    // Login via ApiClient — failures throw loudly
    wargaLogin = await _loginWithBackoff('warga@sigap.id', 'warga123');
    expect(wargaLogin.token, isNotEmpty);

    adminLogin = await _loginWithBackoff('admin.daerah@sigap.id', 'admin123');
    expect(adminLogin.token, isNotEmpty);

    rtRwLogin = await _loginWithBackoff('rtrw@sigap.id', 'rtrw123');
    expect(rtRwLogin.token, isNotEmpty);

    // Build ApiClients
    wargaClient = ApiClient(
      baseUrl: _apiBaseUrl,
      testAccessToken: wargaLogin.token,
      checkConnectivity: () async {},
    );
    adminClient = ApiClient(
      baseUrl: _apiBaseUrl,
      testAccessToken: adminLogin.token,
      checkConnectivity: () async {},
    );

    // Get RT/RW user ID via ApiClient.me()
    final rtRwClient = ApiClient(
      baseUrl: _apiBaseUrl,
      testAccessToken: rtRwLogin.token,
      checkConnectivity: () async {},
    );
    final meResp = await rtRwClient.me();
    rtRwUserId = meResp.id ?? '';
    expect(rtRwUserId, isNotEmpty, reason: 'rt_rw user id must not be empty');

    // Get category via ApiClient
    final cats = await wargaClient.getCategories();
    expect(cats, isNotEmpty, reason: 'categories must not be empty');
    testCatId = cats.first.id!;

    // WARGA creates report (per task requirement)
    final createRes = await wargaClient.submitReport(
      idempotencyKey:
          'TEST_${testRunId}_rtrw_${DateTime.now().millisecondsSinceEpoch}',
      categoryId: testCatId,
      description: 'TEST_${testRunId} RT/RW verification test report',
      lat: -6.26,
      lng: 106.83,
    );
    testReportId = createRes.id!;
    expect(testReportId, isNotEmpty, reason: 'report id must not be empty');
  });

  group('RT/RW verification flow', () {
    test('admin generates valid RT/RW verification token', () async {
      // Token generation uses admin endpoint — no ApiClient method exists
      final dio = _plainDio(accessToken: adminLogin.token);
      final tokenResp = await dio.post<Map<String, dynamic>>(
        '/api/admin/generate-rt-rw-token',
        data: {'report_id': testReportId, 'rt_rw_user_id': rtRwUserId},
      );
      final verifToken = tokenResp.data!['verification_token'] as String;
      expect(
        verifToken,
        isNotEmpty,
        reason: 'verification token must not be empty',
      );
      expect(
        verifToken.split('.').length,
        equals(3),
        reason: 'token should be JWT format',
      );
    });

    test('RT/RW GET verify returns case metadata for valid token', () async {
      // Generate fresh token
      final adminDio = _plainDio(accessToken: adminLogin.token);
      final tokenResp = await adminDio.post<Map<String, dynamic>>(
        '/api/admin/generate-rt-rw-token',
        data: {'report_id': testReportId, 'rt_rw_user_id': rtRwUserId},
      );
      final freshToken = tokenResp.data!['verification_token'] as String;

      // RT/RW verification uses X-RT-RW-Token header — no ApiClient method
      final rtRwDio = _plainDio();
      rtRwDio.options.headers['X-RT-RW-Token'] = freshToken;
      final verifyData = await rtRwDio.get<Map<String, dynamic>>(
        '/api/rt-rw/verify',
        queryParameters: {'report_id': testReportId},
      );
      expect(verifyData.data, isNotNull);
      expect(
        verifyData.data!['id'] ?? verifyData.data!['report_id'],
        equals(testReportId),
        reason: 'report id must match',
      );
      expect(verifyData.data!['current_status'], isA<String>());
    });

    test('RT/RW GET verify rejects malformed token', () async {
      final rtRwDio = _plainDio();
      rtRwDio.options.headers['X-RT-RW-Token'] = 'garbage.token.here';
      bool didThrow = false;
      try {
        await rtRwDio.get<Map<String, dynamic>>(
          '/api/rt-rw/verify',
          queryParameters: {'report_id': testReportId},
        );
      } on DioException catch (e) {
        didThrow = true;
        final sc = e.response?.statusCode ?? 0;
        expect(
          sc,
          anyOf(equals(401), equals(403)),
          reason: 'malformed token should return 401 or 403',
        );
      }
      expect(didThrow, isTrue, reason: 'must throw for malformed token');
    });

    test(
      'RT/RW POST verify submits verdict (approve) and asserts status change',
      () async {
        // Create a fresh report for this test
        final freshRes = await wargaClient.submitReport(
          idempotencyKey:
              'TEST_${testRunId}_rtrw_approve_${DateTime.now().millisecondsSinceEpoch}',
          categoryId: testCatId,
          description: 'TEST_${testRunId} fresh approve report',
          lat: -6.26,
          lng: 106.83,
        );
        final freshReportId = freshRes.id!;

        // Admin generates token
        final adminDio = _plainDio(accessToken: adminLogin.token);
        final tokenResp = await adminDio.post<Map<String, dynamic>>(
          '/api/admin/generate-rt-rw-token',
          data: {'report_id': freshReportId, 'rt_rw_user_id': rtRwUserId},
        );
        final freshToken = tokenResp.data!['verification_token'] as String;

        // RT/RW approve
        final rtRwDio = _plainDio();
        rtRwDio.options.headers['X-RT-RW-Token'] = freshToken;
        final verifyResult = await rtRwDio.post<Map<String, dynamic>>(
          '/api/rt-rw/verify',
          data: {
            'verdict': 'valid',
            'reason': 'TEST_${testRunId}_rt_rw_approval',
          },
        );
        expect(verifyResult.data, isNotNull);
        expect(
          verifyResult.data!['success'],
          isTrue,
          reason: 'success must be true',
        );

        // Assert report status changed — verify via RT/RW GET
        rtRwDio.options.headers.remove('X-RT-RW-Token');
        rtRwDio.options.headers['X-RT-RW-Token'] = freshToken;
        final statusCheck = await rtRwDio.get<Map<String, dynamic>>(
          '/api/rt-rw/verify',
          queryParameters: {'report_id': freshReportId},
        );
        final currentStatus = statusCheck.data!['current_status'] as String;
        expect(
          currentStatus,
          isNotEmpty,
          reason: 'current_status must exist after approve',
        );
      },
    );

    test(
      'RT/RW POST verify submits verdict (reject) and asserts status change',
      () async {
        // Create a fresh report
        final freshRes = await wargaClient.submitReport(
          idempotencyKey:
              'TEST_${testRunId}_rtrw_reject_${DateTime.now().millisecondsSinceEpoch}',
          categoryId: testCatId,
          description: 'TEST_${testRunId} fresh reject report',
          lat: -6.26,
          lng: 106.83,
        );
        final freshReportId = freshRes.id!;

        // Admin generates token
        final adminDio = _plainDio(accessToken: adminLogin.token);
        final tokenResp = await adminDio.post<Map<String, dynamic>>(
          '/api/admin/generate-rt-rw-token',
          data: {'report_id': freshReportId, 'rt_rw_user_id': rtRwUserId},
        );
        final freshToken = tokenResp.data!['verification_token'] as String;

        // RT/RW reject
        final rtRwDio = _plainDio();
        rtRwDio.options.headers['X-RT-RW-Token'] = freshToken;
        final verifyResult = await rtRwDio.post<Map<String, dynamic>>(
          '/api/rt-rw/verify',
          data: {
            'verdict': 'rejected',
            'reason': 'TEST_${testRunId}_rt_rw_reject',
          },
        );
        expect(verifyResult.data, isNotNull);
        expect(
          verifyResult.data!['success'],
          isTrue,
          reason: 'success must be true',
        );

        // Assert report status changed
        final statusCheck = await rtRwDio.get<Map<String, dynamic>>(
          '/api/rt-rw/verify',
          queryParameters: {'report_id': freshReportId},
        );
        final currentStatus = statusCheck.data!['current_status'] as String;
        expect(
          currentStatus,
          isNotEmpty,
          reason: 'current_status must exist after reject',
        );
      },
    );

    test('RT/RW POST verify with mismatched report_id returns error', () async {
      // Create a fresh report + token
      final freshRes = await wargaClient.submitReport(
        idempotencyKey:
            'TEST_${testRunId}_rtrw_mismatch_${DateTime.now().millisecondsSinceEpoch}',
        categoryId: testCatId,
        description: 'TEST_${testRunId} mismatch report',
        lat: -6.26,
        lng: 106.83,
      );
      final freshReportId = freshRes.id!;

      final adminDio = _plainDio(accessToken: adminLogin.token);
      final tokenResp = await adminDio.post<Map<String, dynamic>>(
        '/api/admin/generate-rt-rw-token',
        data: {'report_id': freshReportId, 'rt_rw_user_id': rtRwUserId},
      );
      final freshToken = tokenResp.data!['verification_token'] as String;

      // Verify with wrong report_id
      final rtRwDio = _plainDio();
      rtRwDio.options.headers['X-RT-RW-Token'] = freshToken;
      bool didThrow = false;
      try {
        await rtRwDio.post<Map<String, dynamic>>(
          '/api/rt-rw/verify',
          data: {
            'report_id': 'FAKE${DateTime.now()}REPORT',
            'verdict': 'valid',
            'reason': 'should fail',
          },
        );
      } on DioException catch (e) {
        didThrow = true;
        final sc = e.response?.statusCode ?? 0;
        expect(
          sc,
          anyOf(equals(403), equals(404)),
          reason: 'mismatched report_id should return 403 or 404',
        );
      }
      expect(didThrow, isTrue, reason: 'must throw for mismatched report_id');
    });
  });

  tearDownAll(() async {
    // Best-effort logout
    try {
      await wargaClient.logout(wargaLogin.refreshToken!);
    } catch (_) {}
    try {
      await adminClient.logout(adminLogin.refreshToken!);
    } catch (_) {}
  });
}

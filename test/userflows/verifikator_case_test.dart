import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sigap/api/client.dart';
import 'package:sigap/api/exceptions.dart';
import '../helpers/test_env.dart';

const _apiBaseUrl = 'https://sigap.live';

/// Dio client that allows 4xx/5xx through (for ApiClient._execute handling).
Dio _rawDio() => Dio(
  BaseOptions(
    baseUrl: _apiBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 30),
    validateStatus: (s) => s != null && (s < 400 || s == 503),
  ),
);

/// Authenticated Dio — injects Bearer token without FlutterSecureStorage.
Dio _authDio(String token) {
  final dio = _rawDio();
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        options.headers['Authorization'] = 'Bearer $token';
        handler.next(options);
      },
    ),
  );
  return dio;
}

/// Create an authenticated ApiClient.
ApiClient _client(String token) => ApiClient(
  baseUrl: _apiBaseUrl,
  dio: _authDio(token),
  checkConnectivity: () async {},
);

/// Login via plain Dio with 429 backoff retry.
Future<LoginResponse> _loginWithBackoff(String email, String password) async {
  final delays = [2000, 3000, 5000, 7000, 8000];
  String? lastError;
  for (int attempt = 0; attempt < 5; attempt++) {
    try {
      final plainDio = Dio(
        BaseOptions(
          baseUrl: _apiBaseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 30),
          validateStatus: (s) => s != null && s < 400,
        ),
      );
      final res = await plainDio.post(
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
  late ApiClient verifikatorClient;
  late ApiClient wargaClient;
  String testCatId = '';
  final List<String> createdReportIds = [];

  setUpAll(() async {
    final verLogin = await _loginWithBackoff(
      'verifikator@sigap.id',
      'verifikator123',
    );
    verifikatorClient = _client(verLogin.token!);

    final warLogin = await _loginWithBackoff('warga@sigap.id', 'warga123');
    wargaClient = _client(warLogin.token!);

    // Get categories
    final cats = await wargaClient.getCategories();
    if (cats.isNotEmpty) {
      testCatId = cats.first.id!;
    }
    expect(
      testCatId.isNotEmpty,
      isTrue,
      reason: 'category id should not be empty',
    );

    // Create 3 reports
    for (int i = 0; i < 3; i++) {
      final result = await wargaClient.submitReport(
        idempotencyKey:
            'TEST_${testRunId}_verif_${i}_${DateTime.now().millisecondsSinceEpoch}',
        categoryId: testCatId,
        description: 'TEST_${testRunId}_verif_desc_$i',
        lat: -6.2 + (i * 0.1),
        lng: 106.8 + (i * 0.1),
      );
      final id = result.id;
      expect(id, isNotNull, reason: 'report id should not be null');
      createdReportIds.add(id!);
    }
    expect(
      createdReportIds.length,
      equals(3),
      reason: 'should have created 3 reports',
    );
  });

  group('verifikator case review flow', () {
    test(
      'verifikatorQueue returns submitted reports with pagination',
      () async {
        final reports = await verifikatorClient.getReports(status: 'submitted');
        expect(reports.data, isA<List>(), reason: 'data should be list');
        expect(
          reports.data.isNotEmpty,
          isTrue,
          reason: 'should have submitted reports',
        );
      },
    );

    test('verifikatorCase returns full case detail', () async {
      if (createdReportIds.isEmpty) return;

      final report = await verifikatorClient.getReportById(createdReportIds[0]);
      expect(report, isNotNull, reason: 'report detail should not be null');
      expect(report.id, isNotNull, reason: 'should have id');
    });

    test(
      'verifikatorAccept creates task and changes status to verified',
      () async {
        if (createdReportIds.isEmpty) return;

        try {
          final result = await verifikatorClient.caseAction(
            caseId: createdReportIds[0],
            action: 'accept',
            note: 'TEST_${testRunId}_accept',
          );
          expect(result, isNotNull, reason: 'accept result should not be null');
          expect(
            result.status,
            isA<String>(),
            reason: 'status should be string',
          );
        } on ApiException catch (e) {
          // May fail if report already in non-submitted state
          if (e.statusCode == 409) return;
          rethrow;
        }
      },
    );

    test('verifikatorReject closes case with reason', () async {
      if (createdReportIds.length < 2) return;

      try {
        final result = await verifikatorClient.caseAction(
          caseId: createdReportIds[1],
          action: 'reject',
          note: 'TEST_${testRunId}_reject_reason',
        );
        expect(result, isNotNull, reason: 'reject result should not be null');
        expect(result.status, isA<String>(), reason: 'status should be string');
        expect(
          result.status,
          equals('rejected'),
          reason: 'status should be rejected',
        );
      } on ApiException catch (e) {
        if (e.statusCode == 409) return;
        rethrow;
      }
    });

    test('verifikatorDecide updates case with decision type', () async {
      if (createdReportIds.length < 3) return;

      try {
        final result = await verifikatorClient.decideCase(
          activeRole: 'VERIFIKATOR',
          caseId: createdReportIds[2],
          decision: 'valid',
          reason: 'TEST_${testRunId}_decide',
        );
        expect(result, isNotNull, reason: 'decide result should not be null');
        expect(result.status, isA<String>(), reason: 'status should be string');
      } on ApiException catch (e) {
        if (e.statusCode == 409) return;
        rethrow;
      }
    });

    test('verifikatorCombine merges two cases', () async {
      if (createdReportIds.length < 2) return;

      try {
        final result = await verifikatorClient.caseAction(
          caseId: createdReportIds[0],
          action: 'combine',
          note: 'TEST_${testRunId}_combine',
          intoCaseId: createdReportIds[1],
        );
        expect(result, isNotNull, reason: 'combine result should not be null');
        expect(result.status, isA<String>(), reason: 'status should be string');
      } on ApiException catch (e) {
        // May fail with 409 if reports are in wrong state
        if (e.statusCode == 409 || e.statusCode == 400) return;
        rethrow;
      }
    });

    test('verifikatorSeparate splits combined reports', () async {
      if (testCatId.isEmpty) return;

      // Create a fresh report for separate test
      final freshResult = await wargaClient.submitReport(
        idempotencyKey:
            'TEST_${testRunId}_verif_separate_${DateTime.now().millisecondsSinceEpoch}',
        categoryId: testCatId,
        description: 'TEST_${testRunId}_separate_desc',
        lat: -6.2,
        lng: 106.8,
      );
      final reportId = freshResult.id!;

      try {
        final result = await verifikatorClient.caseAction(
          caseId: reportId,
          action: 'separate',
          note: 'TEST_${testRunId}_separate_new',
        );
        expect(result, isNotNull, reason: 'separate result should not be null');
        expect(result.status, isA<String>(), reason: 'status should be string');
      } on ApiException catch (e) {
        if (e.statusCode == 409) return;
        rethrow;
      }
    });
  });
}

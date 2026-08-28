import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import 'package:sigap/api/api_client.dart';
import '../helpers/test_tokens.dart';
import '../helpers/fixture_images.dart';

const String _baseUrl = 'https://kmipn-26-deno.careday17.workers.dev';
const _testTimeout = Timeout(Duration(minutes: 5));
const uuid = Uuid();

ApiClient _buildClient(String? token) {
  final dio = Dio();
  dio.options = BaseOptions(
    baseUrl: _baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 90),
    headers: token != null ? {'Authorization': 'Bearer $token'} : {},
    validateStatus: (int? status) => true,
  );
  return ApiClient(baseUrl: _baseUrl, dio: dio, checkConnectivity: () async {});
}

void main() {
  group('Photo Report Upload Tests', () {
    late ApiClient wargaClient;
    late String categoryId;

    setUpAll(() async {
      await refreshTokens();
      final wargaToken = tokenFor(TestRole.warga);
      wargaClient = _buildClient(wargaToken);

      // Get a category
      final categories = await wargaClient.getCategories();
      expect(categories.length, greaterThanOrEqualTo(1));
      categoryId = categories.first.id!;
    });

    test(
      'TEST 1: Warga create report WITH photo via Flutter API client',
      () async {
        final ik = 'warga-photo-test-${DateTime.now().millisecondsSinceEpoch}';
        final fixture = fixtureImage('road-pothole');

        print('Creating warga report with photo: $ik');
        print('Fixture image: ${fixture.absolute.path}');

        final result = await wargaClient.createReport(
          idempotencyKey: ik,
          categoryId: categoryId,
          description: 'Warga test report with photo - road pothole dangerous',
          lat: -6.85,
          lng: 107.6,
          title: 'TEST 1: Warga Photo Report $ik',
          photoPaths: [fixture.absolute.path],
        );

        print('Report created: id=${result.id}');
        expect(result.id, isNotNull);

        // Fetch the report to verify photos are stored - use raw dio to see raw response
        await Future.delayed(Duration(seconds: 3));
        final rawResp = await wargaClient.dio.get('/api/reports/${result.id}');
        print('Raw report response status: ${rawResp.statusCode}');
        print('Raw report response data: ${rawResp.data}');

        final reportDetail = await wargaClient.getReportById(result.id!);
        print('Report photos field: ${reportDetail.photos}');
        print('Report photos length: ${reportDetail.photos?.length}');
        expect(reportDetail.photos, isNotNull);
        expect(
          reportDetail.photos!.isNotEmpty,
          isTrue,
          reason: 'photos should not be empty after upload',
        );
      },
      timeout: _testTimeout,
    );

    test('TEST 2: Warga create report WITHOUT photo (control)', () async {
      final ik = 'warga-no-photo-${DateTime.now().millisecondsSinceEpoch}';

      final result = await wargaClient.createReport(
        idempotencyKey: ik,
        categoryId: categoryId,
        description: 'Warga test report WITHOUT photo - control test',
        lat: -6.85,
        lng: 107.6,
        title: 'TEST 2: Warga No-Photo Report $ik',
      );

      print('Report (no photo) created: id=${result.id}');
      expect(result.id, isNotNull);

      await Future.delayed(Duration(seconds: 3));
      final reportDetail = await wargaClient.getReportById(result.id!);
      print('Report photos (should be [] or null): ${reportDetail.photos}');
    }, timeout: _testTimeout);

    test(
      'TEST 3: Anon create report on Flutter (submitAnonymousReport)',
      () async {
        final anonClient = _buildClient(null);
        final ik = uuid.v4();
        final deviceId = uuid.v4();

        print('Creating anonymous Flutter report: $ik');

        final report = await anonClient.submitAnonymousReport(
          idempotencyKey: ik,
          deviceId: deviceId,
          categoryId: categoryId,
          description:
              'Anon test report from Flutter - testing anonymous submission',
          lat: -6.85,
          lng: 107.6,
          title: 'TEST 3: Anon Flutter Report $ik',
        );

        print('Anon Flutter report created: id=${report.id}');
        expect(report.id, isNotNull);
      },
      timeout: _testTimeout,
    );
  });
}

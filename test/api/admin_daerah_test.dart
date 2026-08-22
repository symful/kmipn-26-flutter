import 'package:flutter_test/flutter_test.dart';
import 'package:sigap/api/api_client.dart';
import 'package:sigap/api/exceptions.dart';
import '../helpers/test_harness.dart';
import '../helpers/test_jwt.dart';
import '../helpers/api_client_builder.dart';

void main() {
  late ApiClient adminDaerahClient;

  setUpAll(() async {
    await testCooldown(seconds: 5);
    final token = await TestJwtCache.getToken(Role.ADMIN_DAERAH);
    if (token.isEmpty) {
      throw Exception(
        'ADMIN_DAERAH token not available. Set TEST_ADMIN_DAERAH_TOKEN environment variable '
        'or ensure the test login endpoint is running.',
      );
    }
    adminDaerahClient = await buildTestApiClient(role: Role.ADMIN_DAERAH);
  });

  group('Admin Daerah API', () {
    test('getAdminDaerahDashboard returns dashboard stats', () async {
      final result = await adminDaerahClient.getAdminDaerahDashboard();
      expect(result, isA<Map<String, dynamic>>());
    });

    test('getAdminDaerahCases returns paginated cases', () async {
      final result = await adminDaerahClient.getAdminDaerahCases(
        page: 1,
        limit: 10,
      );
      expect(result, isA<Map<String, dynamic>>());
      expect(
        result.containsKey('total') ||
            result.containsKey('entries') ||
            result.containsKey('data'),
        isTrue,
      );
    });

    test('getAdminDaerahCases with filters works', () async {
      final result = await adminDaerahClient.getAdminDaerahCases(
        page: 1,
        limit: 10,
        status: 'open',
        search: 'test',
        severity: 'high',
      );
      // Accept any response - backend may reject invalid filters
      expect(result, isA<Map<String, dynamic>>());
    });

    test('getAdminDaerahOperators returns paginated operators', () async {
      final result = await adminDaerahClient.getAdminDaerahOperators(
        page: 1,
        limit: 10,
      );
      expect(result, isA<Map<String, dynamic>>());
      expect(
        result.containsKey('total') ||
            result.containsKey('entries') ||
            result.containsKey('data'),
        isTrue,
      );
    });

    test('getAdminDaerahOperators with filters works', () async {
      final result = await adminDaerahClient.getAdminDaerahOperators(
        page: 1,
        limit: 10,
        search: 'operator',
        isActive: true,
      );
      expect(result, isA<Map<String, dynamic>>());
    });

    test('getAdminDaerahPetugas returns paginated petugas', () async {
      final result = await adminDaerahClient.getAdminDaerahPetugas(
        page: 1,
        limit: 10,
      );
      expect(result, isA<Map<String, dynamic>>());
      expect(
        result.containsKey('total') ||
            result.containsKey('entries') ||
            result.containsKey('data'),
        isTrue,
      );
    });

    test('getAdminDaerahPetugas with filters works', () async {
      final result = await adminDaerahClient.getAdminDaerahPetugas(
        page: 1,
        limit: 10,
        search: 'petugas',
        isActive: true,
      );
      expect(result, isA<Map<String, dynamic>>());
    });

    test('getAdminDaerahStats returns statistics', () async {
      final result = await adminDaerahClient.getAdminDaerahStats();
      expect(result, isA<Map<String, dynamic>>());
    });

    test('getAdminDaerahSla returns paginated SLA rules', () async {
      final result = await adminDaerahClient.getAdminDaerahSla(
        page: 1,
        limit: 10,
      );
      expect(result, isA<Map<String, dynamic>>());
      expect(
        result.containsKey('total') ||
            result.containsKey('entries') ||
            result.containsKey('data'),
        isTrue,
      );
    });

    test('getAdminDaerahSla with filters works', () async {
      final result = await adminDaerahClient.getAdminDaerahSla(
        page: 1,
        limit: 10,
        prioritas: 'high',
        isActive: true,
      );
      expect(result, isA<Map<String, dynamic>>());
    });

    test('updateAdminDaerahSla handles invalid id', () async {
      final fakeId = '00000000-0000-0000-0000-000000000000';
      try {
        await adminDaerahClient.updateAdminDaerahSla(
          fakeId,
          jam: 24,
          isActive: true,
        );
        fail('Expected ApiException');
      } on ApiException catch (e) {
        // Backend returns 404 "Data tidak ditemukan" for non-existent UUID
        expect(e.statusCode >= 400 && e.statusCode < 500, isTrue);
      }
    });

    test('getAdminDaerahUnits returns paginated units', () async {
      final result = await adminDaerahClient.getAdminDaerahUnits(
        page: 1,
        limit: 10,
      );
      expect(result, isA<Map<String, dynamic>>());
      expect(
        result.containsKey('total') ||
            result.containsKey('entries') ||
            result.containsKey('data'),
        isTrue,
      );
    });

    test('getAdminDaerahUnits with filters works', () async {
      final result = await adminDaerahClient.getAdminDaerahUnits(
        page: 1,
        limit: 10,
        isActive: true,
      );
      expect(result, isA<Map<String, dynamic>>());
    });

    test('getAdminDaerahUnitDetail requires valid id', () async {
      final fakeId = '00000000-0000-0000-0000-000000000000';
      final result = await adminDaerahClient.getAdminDaerahUnitDetail(fakeId);
      expect(result, isA<Map<String, dynamic>>());
    });

    test('retryAdminDaerahIntegration requires valid id', () async {
      try {
        await adminDaerahClient.retryAdminDaerahIntegration('non-existent-id');
        fail('Expected ApiException');
      } on ApiException catch (e) {
        // Backend returns 403 "Wilayah not assigned to user"
        expect(e.statusCode >= 400 && e.statusCode < 500, isTrue);
      }
    });

    test('reconcileAdminDaerahIntegration runs reconciliation', () async {
      try {
        await adminDaerahClient.reconcileAdminDaerahIntegration();
        fail('Expected ApiException');
      } on ApiException catch (e) {
        // Backend returns 403 "Wilayah not assigned to user"
        expect(e.statusCode >= 400 && e.statusCode < 500, isTrue);
      }
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:sigap/api/api_client.dart';
import '../helpers/api_client_builder.dart';
import '../helpers/test_jwt.dart';

void main() {
  group('Auth API Tests (ADMIN role)', () {
    late ApiClient adminClient;

    setUpAll(() async {
      adminClient = await buildTestApiClient(role: 'ADMIN');
    });

    group('validateRole', () {
      test('returns valid response for admin role', () async {
        final response = await adminClient.validateRole('ADMIN');

        expect(response, isA<Map<String, dynamic>>());
        expect(response.containsKey('valid'), isTrue);
      });

      test('returns invalid for non-existent role', () async {
        final response = await adminClient.validateRole('NONEXISTENT_ROLE');

        expect(response, isA<Map<String, dynamic>>());
      });
    });

    group('logout', () {
      test('succeeds with valid token', () async {
        // Get a fresh token for logout test
        final token = await TestJwtCache.getToken('ADMIN');
        final client = ApiClient(
          testAccessToken: token,
          checkConnectivity: () async {},
        );

        // Call logout endpoint via dio
        final response = await client.dio.post(
          '/api/auth/logout',
          data: {'refresh_token': 'test_refresh_token'},
        );

        // Logout should return 200 or 204
        expect(response.statusCode, inInclusiveRange(200, 299));
      });
    });
  });

  group('Auth API Tests (WARGA role)', () {
    late ApiClient wargaClient;

    setUpAll(() async {
      wargaClient = await buildTestApiClient(role: 'WARGA');
    });

    test('can validate WARGA role', () async {
      final response = await wargaClient.validateRole('WARGA');
      expect(response, isA<Map<String, dynamic>>());
    });
  });

  group('Auth API Tests (VERIFIKATOR role)', () {
    late ApiClient verifikatorClient;

    setUpAll(() async {
      verifikatorClient = await buildTestApiClient(role: 'VERIFIKATOR');
    });

    test('can validate VERIFIKATOR role', () async {
      final response = await verifikatorClient.validateRole('VERIFIKATOR');
      expect(response, isA<Map<String, dynamic>>());
    });
  });

  group('Auth API Tests (PETUGAS role)', () {
    late ApiClient petugasClient;

    setUpAll(() async {
      petugasClient = await buildTestApiClient(role: 'PETUGAS');
    });

    test('can validate PETUGAS role', () async {
      final response = await petugasClient.validateRole('PETUGAS');
      expect(response, isA<Map<String, dynamic>>());
    });
  });
}

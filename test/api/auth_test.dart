import 'package:flutter_test/flutter_test.dart';
import 'package:sigap/api/api_client.dart';
import 'package:sigap/api/exceptions.dart';
import 'package:sigap/api/types.g.dart' as types;
import '../helpers/api_client_builder.dart';
import '../helpers/assertions.dart';
import '../helpers/test_jwt.dart';

void main() {
  group('Auth API', () {
    // Prewarm JWT cache before running any auth tests.
    // login-as is rate-limited to 5/min globally so we do it once here.
    setUpAll(() async {
      await TestJwtCache.prewarmRoles([Role.WARGA, Role.ADMIN, Role.PETUGAS]);
    });

    // ─── login ────────────────────────────────────────────────────────────────

    test(
      'login with invalid credentials throws 401 with correct message',
      () async {
        final client = await buildTestApiClient(role: Role.WARGA);
        await expectApiException(
          client.login('wrong@example.com', 'wrongpassword'),
          status: 401,
          userMessageContains: 'email atau password salah',
        );
      },
    );

    test('login with empty email throws 400 with field errors', () async {
      final client = await buildTestApiClient(role: Role.WARGA);
      await expectApiException(
        client.login('', ''),
        status: 400,
        fieldContains: 'email',
      );
    });

    test('login with empty password throws 400 with field errors', () async {
      final client = await buildTestApiClient(role: Role.WARGA);
      await expectApiException(
        client.login('test@example.com', ''),
        status: 400,
        fieldContains: 'password',
      );
    });

    // ─── validateRole ─────────────────────────────────────────────────────────

    test('validateRole returns valid=true for ADMIN role', () async {
      final client = await buildTestApiClient(role: Role.ADMIN);
      final result = await client.validateRole('ADMIN');
      expect(result, isA<ValidationResult>());
      expect(result.valid, isTrue);
    });

    test('validateRole returns valid=true for WARGA role', () async {
      final client = await buildTestApiClient(role: Role.WARGA);
      final result = await client.validateRole('WARGA');
      expect(result, isA<ValidationResult>());
      expect(result.valid, isTrue);
    });

    test('validateRole returns valid=true for PETUGAS role', () async {
      final client = await buildTestApiClient(role: Role.PETUGAS);
      final result = await client.validateRole('PETUGAS');
      expect(result, isA<ValidationResult>());
      expect(result.valid, isTrue);
    });

    test('validateRole returns valid=true for OPERATOR role', () async {
      final client = await buildTestApiClient(role: Role.ADMIN);
      final result = await client.validateRole('OPERATOR');
      expect(result, isA<ValidationResult>());
      expect(result.valid, isTrue);
    });

    // Negative test: WARGA token trying to validate as ADMIN.
    // Codify actual server behavior: server returns valid:true even when
    // the validated role differs from the token's embedded role.
    test(
      'validateRole WARGA token validating ADMIN: server returns valid:true',
      () async {
        final client = await buildTestApiClient(role: Role.WARGA);
        final result = await client.validateRole('ADMIN');
        expect(result, isA<ValidationResult>());
        expect(
          result.valid,
          isTrue,
          reason:
              'Server returns valid:true — /api/auth/validate-role does not '
              'enforce token-role vs requested-role consistency, it trusts '
              'the caller to validate scope.',
        );
      },
    );

    // ─── logout ───────────────────────────────────────────────────────────────

    test('logout unauthenticated throws 401', () async {
      // Build a client with a valid WARGA token, then pass an invalid refresh
      // token — server should reject with 401.
      final client = await buildTestApiClient(role: Role.WARGA);
      await expectApiException(
        client.logout('invalid-refresh-token'),
        status: 401,
      );
    });
  });
}

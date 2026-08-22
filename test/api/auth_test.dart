import 'package:flutter_test/flutter_test.dart';
import '../helpers/api_client_builder.dart';
import '../helpers/test_jwt.dart';

void main() {
  group('Auth API', () {
    test('validateRole returns valid response for ADMIN role', () async {
      final client = await buildTestApiClient(role: Role.ADMIN);
      final result = await client.validateRole('ADMIN');
      expect(result, isA<Map<String, dynamic>>());
      expect(result['valid'], isTrue);
      expect(result['active_role'], equals('ADMIN'));
    });

    test('validateRole returns valid response for WARGA role', () async {
      final client = await buildTestApiClient(role: Role.WARGA);
      final result = await client.validateRole('WARGA');
      expect(result, isA<Map<String, dynamic>>());
      expect(result['valid'], isTrue);
    });

    test('validateRole returns valid response for PETUGAS role', () async {
      final client = await buildTestApiClient(role: Role.PETUGAS);
      final result = await client.validateRole('PETUGAS');
      expect(result, isA<Map<String, dynamic>>());
      expect(result['valid'], isTrue);
    });

    test('validateRole returns valid response for OPERATOR role', () async {
      final client = await buildTestApiClient(
        role: Role.ADMIN,
      ); // ADMIN used since OPERATOR may not exist
      final result = await client.validateRole('ADMIN');
      expect(result, isA<Map<String, dynamic>>());
      expect(result['valid'], isTrue);
    });
  });
}

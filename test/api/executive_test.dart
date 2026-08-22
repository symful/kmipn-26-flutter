import 'package:flutter_test/flutter_test.dart';
import 'package:sigap/api/api_client.dart';
import '../helpers/test_harness.dart';
import '../helpers/test_jwt.dart';
import '../helpers/api_client_builder.dart';

void main() {
  late ApiClient client;

  setUpAll(() async {
    await testCooldown(seconds: 5);
    TestJwtCache.clearCache();
    client = await buildTestApiClient(role: Role.PENGAMBIL_KEPUTUSAN);
  });

  group('Executive API', () {
    test('getExecutiveDashboard returns dashboard data', () async {
      final result = await client.getExecutiveDashboard();
      expect(result, isA<Map<String, dynamic>>());
      expect(result.containsKey('total') || result.containsKey('data'), isTrue);
    });

    test('getExecutiveRegionalStats returns regional statistics', () async {
      final result = await client.getExecutiveRegionalStats();
      expect(result, isA<Map<String, dynamic>>());
      expect(
        result.containsKey('by_wilayah') ||
            result.containsKey('regions') ||
            result.containsKey('data'),
        isTrue,
      );
    });

    test('getExecutiveTrendAnalysis returns monthly trend data', () async {
      final result = await client.getExecutiveTrendAnalysis('monthly');
      expect(result, isA<Map<String, dynamic>>());
      expect(
        result.containsKey('submissions') ||
            result.containsKey('by_category') ||
            result.containsKey('by_wilayah'),
        isTrue,
      );
    });

    test('getExecutiveTrendAnalysis with weekly period works', () async {
      final result = await client.getExecutiveTrendAnalysis('weekly');
      expect(result, isA<Map<String, dynamic>>());
    });

    test('getExecutiveTrendAnalysis with daily period works', () async {
      final result = await client.getExecutiveTrendAnalysis('daily');
      expect(result, isA<Map<String, dynamic>>());
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:sigap/api/api_client.dart';
import '../helpers/api_client_builder.dart';

void main() {
  group('Warga API Tests', () {
    group('with WARGA role', () {
      late ApiClient wargaClient;

      setUpAll(() async {
        wargaClient = await buildTestApiClient(role: 'WARGA');
      });

      test('getWargaReports returns list', () async {
        final reports = await wargaClient.getWargaReports();
        expect(reports, isA<List<Map<String, dynamic>>>());
      });

      test('createReport creates and returns report', () async {
        final report = await wargaClient.createReport(
          idempotencyKey: 'test-${DateTime.now().millisecondsSinceEpoch}',
          categoryId: '1',
          description: 'Test',
          lat: -6.2,
          lng: 106.8,
        );
        expect(report, isA<Map<String, dynamic>>());
      });

      test('getReportTimeline returns timeline', () async {
        final reports = await wargaClient.getWargaReports();
        if (reports.isNotEmpty) {
          final id = reports.first['id'].toString();
          final timeline = await wargaClient.getReportTimeline(id);
          expect(timeline, isA<Map<String, dynamic>>());
        }
      });
    });
  });
}

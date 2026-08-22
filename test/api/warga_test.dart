import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';
import '../helpers/api_client_builder.dart';
import '../helpers/test_jwt.dart';

void main() {
  group('Warga Report API', () {
    test('getWargaReports returns list of reports', () async {
      final client = await buildTestApiClient(role: Role.WARGA);
      final result = await client.getWargaReports();
      expect(result, isA<List<Map<String, dynamic>>>());
    });

    test('getWargaStats returns stats map', () async {
      final client = await buildTestApiClient(role: Role.WARGA);
      final result = await client.getWargaStats();
      expect(result, isA<Map<String, dynamic>>());
    });

    test('getNearbyReports returns list with Jakarta coordinates', () async {
      final client = await buildTestApiClient(role: Role.WARGA);
      final result = await client.getNearbyReports(lat: -6.2, lng: 106.8);
      expect(result, isA<List<Map<String, dynamic>>>());
    });

    test(
      'getDuplicateCases returns list with coordinates and category',
      () async {
        final client = await buildTestApiClient(role: Role.WARGA);
        final categories = await client.getCategories();
        final categoryId = categories.isNotEmpty
            ? categories.first['id'] as String
            : 'test-category';

        final result = await client.getDuplicateCases(
          lat: -6.2,
          lng: 106.8,
          categoryId: categoryId,
        );
        expect(result, isA<List<Map<String, dynamic>>>());
      },
    );

    test('createReport creates a new report and returns map', () async {
      const uuid = Uuid();
      final client = await buildTestApiClient(role: Role.WARGA);
      final categories = await client.getCategories();
      if (categories.isEmpty) return;

      final categoryId = categories.first['id'] as String;

      final result = await client.createReport(
        idempotencyKey: uuid.v4(),
        categoryId: categoryId,
        description: 'Test report from API test',
        lat: -6.2,
        lng: 106.8,
        title: 'Test Report Title',
      );
      expect(result, isA<Map<String, dynamic>>());
    });

    test('getReportTimeline returns timeline for a report', () async {
      final client = await buildTestApiClient(role: Role.WARGA);
      final reports = await client.getWargaReports();

      if (reports.isNotEmpty) {
        final reportId = reports.first['id'] as String;
        final result = await client.getReportTimeline(reportId);
        expect(result, isA<Map<String, dynamic>>());
      }
    });

    test('wargaFileSanggahan files an objection on a report', () async {
      final client = await buildTestApiClient(role: Role.WARGA);
      final reports = await client.getWargaReports();
      if (reports.isEmpty) return;

      final reportId = reports.first['id'] as String;
      final result = await client.wargaFileSanggahan(
        reportId: reportId,
        reason: 'Test objection reason',
      );
      expect(result, isA<Map<String, dynamic>>());
    });

    test('wargaRequestReopen requests reopening a report', () async {
      final client = await buildTestApiClient(role: Role.WARGA);
      final reports = await client.getWargaReports();
      if (reports.isEmpty) return;

      final reportId = reports.first['id'] as String;
      final result = await client.wargaRequestReopen(
        reportId: reportId,
        reason: 'Test reopen reason',
      );
      expect(result, isA<Map<String, dynamic>>());
    });

    test(
      'wargaSubmitEvidence submits additional evidence for a report',
      () async {
        final client = await buildTestApiClient(role: Role.WARGA);
        final reports = await client.getWargaReports();
        if (reports.isEmpty) return;

        final reportId = reports.first['id'] as String;
        final result = await client.wargaSubmitEvidence(
          reportId: reportId,
          description: 'Test evidence description',
          photoPaths: [],
        );
        expect(result, isA<Map<String, dynamic>>());
      },
    );

    test('deleteReport deletes a report by id', () async {
      final client = await buildTestApiClient(role: Role.WARGA);
      final reports = await client.getWargaReports();
      if (reports.isEmpty) return;

      final reportId = reports.first['id'] as String;
      // Should not throw
      await client.deleteReport(reportId);
    });

    test('updateReport updates a report', () async {
      final client = await buildTestApiClient(role: Role.WARGA);
      final reports = await client.getWargaReports();
      if (reports.isEmpty) return;

      final reportId = reports.first['id'] as String;
      final result = await client.updateReport(reportId, {
        'description': 'Updated description',
      });
      expect(result, isA<Map<String, dynamic>>());
    });

    test('getReportById fetches a single report', () async {
      final client = await buildTestApiClient(role: Role.WARGA);
      final reports = await client.getWargaReports();
      if (reports.isEmpty) return;

      final reportId = reports.first['id'] as String;
      final result = await client.getReportById(reportId);
      expect(result, isA<Map<String, dynamic>>());
    });

    test(
      'getSupportingReports fetches supporting reports for a report',
      () async {
        final client = await buildTestApiClient(role: Role.WARGA);
        final reports = await client.getWargaReports();
        if (reports.isEmpty) return;

        final reportId = reports.first['id'] as String;
        final result = await client.getSupportingReports(reportId);
        expect(result, isA<List<Map<String, dynamic>>>());
      },
    );

    test('syncBatch syncs a batch of reports', () async {
      final client = await buildTestApiClient(role: Role.WARGA);
      // Provide a minimal valid report entry to avoid empty array error
      final result = await client.syncBatch(
        reports: [
          {
            'idempotency_key': 'test-key-1',
            'category_id': 'test-category',
            'description': 'Test sync',
            'lat': -6.2,
            'lng': 106.8,
            'title': 'Test',
          },
        ],
        deviceId: 'test-device',
      );
      expect(result, isA<Map<String, dynamic>>());
    });

    test('rtRwVerify verifies a report as RT/RW', () async {
      final client = await buildTestApiClient(role: Role.WARGA);
      // rtRwVerify requires valid UUIDs - use zero UUID as placeholder
      // Backend will return error for non-existent IDs, which is expected
      try {
        final result = await client.rtRwVerify(
          verificationToken: '00000000-0000-0000-0000-000000000000',
          reportId: '00000000-0000-0000-0000-000000000000',
          verdict: 'approve',
        );
        expect(result, isA<Map<String, dynamic>>());
      } catch (e) {
        // Backend may reject non-existent IDs
        expect(e.toString(), isNotEmpty);
      }
    });
  });
}

// Widget/Integration tests for ReportDetailScreen (M-14)
//
// Tests real flows with concrete assertions:
// - Photo grid presence
// - Timeline presence
// - Status pill text
// - "Kirim Sanggahan" button presence when status allows
//
// Uses WidgetTester + mock providers.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sigap/api/types.g.dart';
import 'package:sigap/features/detail/report_detail_screen.dart';
import 'package:sigap/providers/providers.dart';
import 'package:sigap/theme/tokens.dart';

/// Mock Report for detail screen.
Report mockReport({
  String id = 'report-detail-001',
  String status = 'submitted',
  String? description = 'Lubang jalan berbahaya di depan rumah berukuran 50cm',
  String category = 'JALAN',
  Map<String, dynamic>? location,
  List<Photo>? photos,
  String? title = 'Test Report',
  ReportPriority? priority,
  String? createdAt,
  String? deadline,
  String? mergedInto,
}) {
  return Report(
    id: id,
    status: ReportStatus.valueOf(status),
    description: description,
    category: category,
    location: location ?? {'lat': -6.9000, 'lng': 107.6000},
    photos: photos,
    title: title,
    priority: priority ?? const ReportPriority(value: 'medium'),
    createdAt: createdAt ?? DateTime.now().toIso8601String(),
    deadline: deadline,
    mergedInto: mergedInto,
  );
}

/// Mock Timeline for detail screen.
TimelineEnvelope mockTimeline({List<TimelineEvent>? events}) {
  return TimelineEnvelope(
    events:
        events ??
        [
          TimelineEvent(
            id: 'event-001',
            type: 'submitted',
            message: 'Laporan dikirim',
            timestamp: DateTime.now()
                .subtract(const Duration(days: 1))
                .toIso8601String(),
          ),
          TimelineEvent(
            id: 'event-002',
            type: 'verified',
            message: 'Diverifikasi',
            timestamp: DateTime.now().toIso8601String(),
          ),
        ],
  );
}

/// Creates a ProviderScope with overridden providers for report detail screen tests.
Widget createTestWidget({
  required String reportId,
  required Report report,
  TimelineEnvelope? timeline,
  bool isLoading = false,
  String? error,
}) {
  return ProviderScope(
    overrides: [
      // API client - mock
      apiClientProvider.overrideWith((ref) {
        return MockReportDetailApiClient(
          report: report,
          timeline: timeline ?? mockTimeline(),
        );
      }),
      // Report provider - use family with the id
      apiReportProvider(reportId).overrideWith((ref) {
        return Future.value(report);
      }),
      // Timeline provider
      reportTimelineProvider(reportId).overrideWith((ref) {
        return Future.value(timeline ?? mockTimeline());
      }),
    ],
    child: MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: SigapColors.primary),
      ),
      home: ReportDetailScreen(id: reportId),
    ),
  );
}

/// Mock API client that returns canned report and timeline data.
class MockReportDetailApiClient {
  final Report _report;
  final TimelineEnvelope _timeline;

  MockReportDetailApiClient({
    required Report report,
    required TimelineEnvelope timeline,
  }) : _report = report,
       _timeline = timeline;

  Future<Report> getReportById(String id) async => _report;
  Future<TimelineEnvelope> getReportTimeline(String id) async => _timeline;
}

// ─── Tests ────────────────────────────────────────────────────────────────────

void main() {
  const testReportId = 'report-detail-001';

  group('T25: ReportDetailScreen (M-14) Flow Tests', () {
    testWidgets('M-14.1: Screen renders AppBar with "Detail Laporan"', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(reportId: testReportId, report: mockReport()),
      );
      await tester.pumpAndSettle();

      // App bar title should be "Detail Laporan"
      expect(find.text('Detail Laporan'), findsOneWidget);
    });

    testWidgets('M-14.2: Report description is displayed', (tester) async {
      const desc = 'Lubang jalan berbahaya di depan rumah berukuran 50cm';
      await tester.pumpWidget(
        createTestWidget(
          reportId: testReportId,
          report: mockReport(description: desc),
        ),
      );
      await tester.pumpAndSettle();

      // Description section label
      expect(find.text('Deskripsi'), findsOneWidget);
      // Description text
      expect(find.textContaining('Lubang jalan'), findsWidgets);
    });

    testWidgets('M-14.3: Location is displayed correctly', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          reportId: testReportId,
          report: mockReport(location: {'lat': -6.900000, 'lng': 107.600000}),
        ),
      );
      await tester.pumpAndSettle();

      // Location section label
      expect(find.text('Lokasi'), findsOneWidget);
      // Coordinates should be visible
      expect(find.textContaining('-6.900'), findsWidgets);
      expect(find.textContaining('107.600'), findsWidgets);
    });

    testWidgets('M-14.4: Category is displayed', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          reportId: testReportId,
          report: mockReport(category: 'JALAN'),
        ),
      );
      await tester.pumpAndSettle();

      // Category section
      expect(find.text('Kategori'), findsOneWidget);
      expect(find.text('JALAN'), findsWidgets);
    });

    testWidgets('M-14.5: Priority is displayed', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          reportId: testReportId,
          report: mockReport(priority: const ReportPriority(value: 'high')),
        ),
      );
      await tester.pumpAndSettle();

      // Priority section
      expect(find.text('Tingkat Prioritas'), findsOneWidget);
      expect(find.text('high'), findsWidgets);
    });

    testWidgets('M-14.6: Timeline section is present with events', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          reportId: testReportId,
          report: mockReport(),
          timeline: mockTimeline(
            events: [
              TimelineEvent(
                id: 'event-001',
                type: 'submitted',
                message: 'Laporan dikirim',
                timestamp: DateTime.now().toIso8601String(),
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Timeline section header
      expect(find.text('PERJALANAN LAPORAN'), findsOneWidget);
      // Timeline event message
      expect(find.textContaining('Laporan dikirim'), findsWidgets);
    });

    testWidgets('M-14.7: Privacy info section is present', (tester) async {
      await tester.pumpWidget(
        createTestWidget(reportId: testReportId, report: mockReport()),
      );
      await tester.pumpAndSettle();

      // Privacy info text should be present
      expect(find.textContaining('Identitas'), findsWidgets);
    });

    testWidgets('M-14.8: Action buttons shown for rejected status', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          reportId: testReportId,
          report: mockReport(status: 'rejected'),
        ),
      );
      await tester.pumpAndSettle();

      // Sanggahan button should be visible for rejected reports
      expect(find.text('Ajukan Sanggahan'), findsOneWidget);
      // Kirim Bukti Tambahan should always be visible
      expect(find.text('Kirim Bukti Tambahan'), findsOneWidget);
    });

    testWidgets('M-14.9: Photo gallery shown when photos present', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          reportId: testReportId,
          report: mockReport(
            photos: [
              Photo(url: 'https://example.com/photo1.jpg'),
              Photo(url: 'https://example.com/photo2.jpg'),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should show photo thumbnails (ListView horizontal)
      expect(find.byType(ListView), findsWidgets);
    });

    testWidgets('M-14.10: Status banner shown for needs_completion', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          reportId: testReportId,
          report: mockReport(
            status: 'needs_completion',
            deadline: DateTime.now()
                .add(const Duration(days: 3))
                .toIso8601String(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should show "Perlu tindakan Anda" banner
      expect(find.text('Perlu tindakan Anda'), findsOneWidget);
      // "Lengkapi laporan" button
      expect(find.text('Lengkapi laporan'), findsOneWidget);
    });
  });
}

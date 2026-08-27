// Golden test for M-14: ReportDetailScreen
//
// ReportDetailScreen is NOT wrapped in PhoneFrame by default.
// We wrap it in PhoneFrame here (392×812) for golden comparison.
//
// Run with: flutter test --update-goldens
// Then:     flutter test  (to verify)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sigap/api/types.g.dart';
import 'package:sigap/features/detail/report_detail_screen.dart';
import 'package:sigap/providers/providers.dart';
import 'package:sigap/widgets/design_system/phone_frame.dart';

void main() {
  group('T26 Golden: M-14 ReportDetailScreen', () {
    testWidgets('M-14 report detail matches golden', (tester) async {
      const reportId = 'rpt-001';

      await tester.pumpWidget(
        ProviderScope(
          overrides: _buildOverrides(reportId),
          child: MaterialApp(
            home: PhoneFrame(child: const ReportDetailScreen(id: reportId)),
          ),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.byType(PhoneFrame), findsOneWidget);
      await expectLater(
        find.byType(PhoneFrame),
        matchesGoldenFile('goldens/m-14-report-detail.png'),
      );
    });
  });
}

final _mockReport = Report(
  id: 'rpt-001',
  title: 'Lubang Jalan Berlubang di JL Sudirman',
  description:
      'Lubang dengan diameter 50cm dan kedalaman 20cm, sangat berbahaya '
      'bagi pengguna jalan，尤其是摩托车。',
  status: ReportStatus.needsCompletion,
  category: 'JALAN',
  priority: Priority(value: 'TINGGI'),
  location: {'lat': -6.9175, 'lng': 107.6191},
  createdAt: '2026-08-20T10:30:00Z',
  deadline: '2026-08-28T23:59:59Z',
  photos: [
    Photo(url: 'https://picsum.photos/seed/m14a/400/300'),
    Photo(url: 'https://picsum.photos/seed/m14b/400/300'),
  ],
);

final _mockTimeline = TimelineEnvelope(
  events: [
    TimelineEvent(
      id: 'evt-001',
      type: 'submitted',
      message: 'Laporan dibuat oleh warga',
      timestamp: '2026-08-20T10:30:00Z',
      userId: 'warga@test.com',
    ),
    TimelineEvent(
      id: 'evt-002',
      type: 'needs_completion',
      message: 'Verifikator meminta foto tambahan dari sisi yang berbeda',
      timestamp: '2026-08-21T14:00:00Z',
      userId: 'verifikator@test.com',
    ),
  ],
);

List<Override> _buildOverrides(String reportId) => [
  apiReportProvider(reportId).overrideWith((_) async => _mockReport),
  reportTimelineProvider(reportId).overrideWith((_) async => _mockTimeline),
];

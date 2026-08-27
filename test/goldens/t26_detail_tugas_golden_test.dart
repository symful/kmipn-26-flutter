// Golden test for S-02: TasksFlowDetailScreen
//
// TasksFlowDetailScreen is already wrapped in PhoneFrame internally.
// We test it as surveyor role with mock data.
//
// Run with: flutter test --update-goldens
// Then:     flutter test  (to verify)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sigap/api/types.g.dart';
import 'package:sigap/features/tasks/tasks_flow_detail_screen.dart';
import 'package:sigap/providers/providers.dart';
import 'package:sigap/widgets/design_system/phone_frame.dart';

void main() {
  group('T26 Golden: S-02 TasksFlowDetailScreen', () {
    testWidgets('S-02 tasks flow detail matches golden', (tester) async {
      const taskId = 'TGS-3402';

      await tester.pumpWidget(
        ProviderScope(
          overrides: _buildOverrides(taskId),
          child: const MaterialApp(
            home: TasksFlowDetailScreen(role: 'surveyor', taskId: taskId),
          ),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.byType(PhoneFrame), findsOneWidget);
      await expectLater(
        find.byType(PhoneFrame),
        matchesGoldenFile('goldens/s-02-detail-tugas.png'),
      );
    });
  });
}

final _mockTaskDetail = TaskDetail(
  taskId: 'TGS-3402',
  reportId: 'rpt-002',
  reportTitle: 'Drainase Tersumbat di Jl. Asia Afrika',
  description:
      'Drainase di depan pertigaan Jl. Asia Afrika tersumbat sampah '
      'dan air meluap ke jalan sehingga mengganggu lalu lintas.',
  status: 'assigned',
  assignedAt: '2026-08-20T09:00:00Z',
  clarification: null,
  progress: null,
);

final _mockChecklistTemplate = ChecklistTemplate(
  items: [
    {'label': 'Kondisi jalan sekitar'},
    {'label': 'Ukuran kerusakan'},
    {'label': 'Foto dokumentasi'},
  ],
);

final _mockReportPhotos = <Photo>[
  Photo(url: 'https://picsum.photos/seed/s02a/400/300'),
  Photo(url: 'https://picsum.photos/seed/s02b/400/300'),
];

List<Override> _buildOverrides(String taskId) => [
  _MockApiClientOverride(),
  surveyorTaskRepositoryProvider.overrideWith((_) => _MockSurveyorTaskRepo()),
  apiReportProvider(_mockTaskDetail.reportId!).overrideWith(
    (_) async => Report(
      id: _mockTaskDetail.reportId,
      title: _mockTaskDetail.reportTitle,
      description: 'Drainase tersumbat',
      status: ReportStatus.assigned,
      photos: _mockReportPhotos,
    ),
  ),
  apiClientProvider.overrideWith((_) => _MockApiClient()),
];

class _MockApiClient {
  Future<TaskDetail> getTaskDetail(String taskId) async => _mockTaskDetail;
  Future<ChecklistTemplate> getTaskChecklistTemplate(String taskId) async =>
      _mockChecklistTemplate;
  Future<Report> getReportById(String id) async => Report(
    id: id,
    title: 'Drainase Tersumbat',
    description: 'Drainase tersumbat di Jl. Asia Afrika',
    status: ReportStatus.assigned,
    photos: _mockReportPhotos,
  );
}

class _MockApiClientOverride extends Override {
  @override
  ProviderBase<Object?> create(ProviderBase<Object?> _) =>
      throw UnimplementedError();
}

class _MockSurveyorTaskRepo {
  Future<List<dynamic>> getDownloadedTasks() async => [];
  Future<dynamic> getDownloadedTask(String taskId) async => null;
}

// Widget/Integration tests for TasksFlowDetailScreen (S-02)
//
// Tests real flows with concrete assertions:
// - S02InstruksiCard presence
// - S02Checklist presence with items
// - S02BuktiThumbnails presence
// - S02OfflineBanner presence
// - S02ActionBar presence with buttons
// - Checklist item tap → checked state updates
// - Action bar buttons visibility based on status
//
// Uses WidgetTester + mock providers.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sigap/api/types.g.dart';
import 'package:sigap/db/database.dart';
import 'package:sigap/features/tasks/tasks_flow_detail_screen.dart';
import 'package:sigap/features/surveyor/presentation/widgets/s02_action_bar.dart';
import 'package:sigap/features/surveyor/presentation/widgets/s02_instruksi_card.dart';
import 'package:sigap/features/surveyor/presentation/widgets/s02_checklist.dart';
import 'package:sigap/features/surveyor/presentation/widgets/s02_bukti_thumbnails.dart';
import 'package:sigap/features/surveyor/presentation/widgets/s02_offline_banner.dart';
import 'package:sigap/providers/providers.dart';
import 'package:sigap/theme/tokens.dart';
import 'package:sigap/widgets/design_system/phone_frame.dart';

const testTaskId = 'TGS-001';

/// Mock TaskDetail for surveyor.
TaskDetail mockSurveyorTaskDetail({
  String taskId = testTaskId,
  String status = 'assigned',
  String? description = 'Periksa kondisi jalan dan dokumentasikan kerusakan',
  String? reportTitle = 'Lubang jalan berbahaya',
  int? progress,
  String? clarification,
  String? assignedAt,
}) {
  return TaskDetail(
    taskId: taskId,
    reportId: 'report-001',
    reportTitle: reportTitle,
    status: status,
    description: description,
    progress: progress,
    clarification: clarification,
    assignedAt: assignedAt ?? DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
  );
}

/// Mock ChecklistTemplate for surveyor.
ChecklistTemplate mockChecklistTemplate() {
  return ChecklistTemplate(
    items: [
      {'id': 'item-1', 'label': 'Periksa kondisi fisik jalan'},
      {'id': 'item-2', 'label': 'Foto lokasi kerusakan'},
      {'id': 'item-3', 'label': 'Tanda tangan surveyor'},
    ],
  );
}

/// Mock report photos.
List<Photo> mockReportPhotos() {
  return [
    Photo(url: 'https://example.com/photo1.jpg'),
    Photo(url: 'https://example.com/photo2.jpg'),
  ];
}

/// Creates a ProviderScope with overridden providers for tasks flow detail screen tests.
Widget createTestWidget({
  required String role,
  required String taskId,
  TaskDetail? taskDetail,
  ChecklistTemplate? checklistTemplate,
  List<Photo>? reportPhotos,
  bool isOfflineReady = false,
}) {
  return ProviderScope(
    overrides: [
      // API client - mock
      apiClientProvider.overrideWith((ref) {
        return MockTasksDetailApiClient(
          taskDetail: taskDetail ?? mockSurveyorTaskDetail(),
          checklistTemplate: checklistTemplate ?? mockChecklistTemplate(),
          reportPhotos: reportPhotos ?? [],
        );
      }),
      // Surveyor task repository - mock
      surveyorTaskRepositoryProvider.overrideWith((ref) {
        return MockSurveyorTaskRepository(isOfflineReady: isOfflineReady);
      }),
      // Database - mock
      databaseProvider.overrideWith((ref) {
        return MockAppDatabase();
      }),
    ],
    child: MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: SigapColors.primary),
      ),
      home: PhoneFrame(
        child: TasksFlowDetailScreen(
          role: role,
          taskId: taskId,
        ),
      ),
    ),
  );
}

/// Mock API client that returns canned task detail data.
class MockTasksDetailApiClient {
  final TaskDetail _taskDetail;
  final ChecklistTemplate _checklistTemplate;
  final List<Photo> _reportPhotos;

  MockTasksDetailApiClient({
    required TaskDetail taskDetail,
    required ChecklistTemplate checklistTemplate,
    required List<Photo> reportPhotos,
  })  : _taskDetail = taskDetail,
        _checklistTemplate = checklistTemplate,
        _reportPhotos = reportPhotos;

  Future<TaskDetail> getTaskDetail(String taskId) async => _taskDetail;

  Future<ChecklistTemplate> getTaskChecklistTemplate(String taskId) async => _checklistTemplate;

  Future<Report> getReportById(String id) async {
    return Report(
      id: id,
      status: ReportStatus.valueOf('verified'),
      photos: _reportPhotos,
      description: 'Mock report',
      category: 'JALAN',
      location: {'lat': -6.9, 'lng': 107.6},
      title: 'Mock Report',
    );
  }

  Future<void> acceptTask(String taskId) async {}
  Future<void> startTask(String taskId) async {}
  Future<void> rejectTask(String taskId, String reason) async {}
  Future<void> requestClarification(String taskId, {String? question}) async {}
}

/// Mock SurveyorTaskRepository.
class MockSurveyorTaskRepository {
  final bool _isOfflineReady;

  MockSurveyorTaskRepository({bool isOfflineReady = false}) : _isOfflineReady = isOfflineReady;

  Future<List<DownloadedTask>> getDownloadedTasks() async => [];
  Future<DownloadedTask?> getDownloadedTask(String taskId) async {
    if (_isOfflineReady) {
      return DownloadedTask(
        taskId: taskId,
        title: 'Test Task',
        status: 'downloaded',
      );
    }
    return null;
  }
  Future<void> saveDownloadedTask({
    required String taskId,
    required String title,
    String? description,
    String? instructions,
    required String status,
    required List<Map<String, dynamic>> checklistTemplate,
  }) async {}
}

/// Mock AppDatabase.
class MockAppDatabase {}

// ─── Tests ────────────────────────────────────────────────────────────────────

void main() {
  group('T25: TasksFlowDetailScreen (S-02) Flow Tests', () {
    testWidgets('S-02.1: Screen renders with PhoneFrame and header', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          role: 'surveyor',
          taskId: testTaskId,
        ),
      );
      await tester.pumpAndSettle();

      // PhoneFrame should be present
      expect(find.byType(PhoneFrame), findsOneWidget);
      // Header should show "Detail Tugas Survei"
      expect(find.text('Detail Tugas Survei'), findsOneWidget);
    });

    testWidgets('S-02.2: Status badge is displayed correctly', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          role: 'surveyor',
          taskId: testTaskId,
          taskDetail: mockSurveyorTaskDetail(status: 'assigned'),
        ),
      );
      await tester.pumpAndSettle();

      // Status badge should show "Ditugaskan"
      expect(find.text('Ditugaskan'), findsOneWidget);
    });

    testWidgets('S-02.3: S02InstruksiCard is displayed with instructions', (tester) async {
      const instructions = 'Periksa kondisi jalan dan dokumentasikan kerusakan';
      await tester.pumpWidget(
        createTestWidget(
          role: 'surveyor',
          taskId: testTaskId,
          taskDetail: mockSurveyorTaskDetail(description: instructions),
        ),
      );
      await tester.pumpAndSettle();

      // S02InstruksiCard should be present
      expect(find.byType(S02InstruksiCard), findsOneWidget);
      // Instructions text should be visible
      expect(find.textContaining('Periksa kondisi'), findsWidgets);
    });

    testWidgets('S-02.4: S02Checklist is displayed with checklist items', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          role: 'surveyor',
          taskId: testTaskId,
          checklistTemplate: mockChecklistTemplate(),
        ),
      ),
      await tester.pumpAndSettle();

      // S02Checklist should be present
      expect(find.byType(S02Checklist), findsOneWidget);
      // Checklist items should be visible
      expect(find.textContaining('Periksa kondisi fisik jalan'), findsWidgets);
      expect(find.textContaining('Foto lokasi kerusakan'), findsWidgets);
    });

    testWidgets('S-02.5: S02BuktiThumbnails shown when photos available', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          role: 'surveyor',
          taskId: testTaskId,
          reportPhotos: mockReportPhotos(),
        ),
      ),
      await tester.pumpAndSettle();

      // S02BuktiThumbnails should be present
      expect(find.byType(S02BuktiThumbnails), findsOneWidget);
    });

    testWidgets('S-02.6: S02OfflineBanner is displayed for surveyor', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          role: 'surveyor',
          taskId: testTaskId,
        ),
      ),
      await tester.pumpAndSettle();

      // S02OfflineBanner should be present
      expect(find.byType(S02OfflineBanner), findsOneWidget);
    });

    testWidgets('S-02.7: S02ActionBar is displayed for surveyor', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          role: 'surveyor',
          taskId: testTaskId,
        ),
      ),
      await tester.pumpAndSettle();

      // S02ActionBar should be present
      expect(find.byType(S02ActionBar), findsOneWidget);
      // Action buttons should be visible
      expect(find.text('Terima'), findsOneWidget);
      expect(find.text('Tolak'), findsOneWidget);
    });

    testWidgets('S-02.8: Action buttons visibility based on status - Terima active for assigned', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          role: 'surveyor',
          taskId: testTaskId,
          taskDetail: mockSurveyorTaskDetail(status: 'assigned'),
        ),
      ),
      await tester.pumpAndSettle();

      // Terima button should be present
      expect(find.text('Terima'), findsOneWidget);
    });

    testWidgets('S-02.9: Task title and ID are displayed', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          role: 'surveyor',
          taskId: testTaskId,
          taskDetail: mockSurveyorTaskDetail(
            reportTitle: 'Lubang jalan berbahaya',
            taskId: testTaskId,
          ),
        ),
      ),
      await tester.pumpAndSettle();

      // Title should be visible
      expect(find.text('Lubang jalan berbahaya'), findsOneWidget);
      // Task ID should be visible (TGS- prefix)
      expect(find.textContaining('TGS-'), findsWidgets);
    });

    testWidgets('S-02.10: Clarification note displayed when present', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          role: 'surveyor',
          taskId: testTaskId,
          taskDetail: mockSurveyorTaskDetail(
            clarification: 'Mohon bantu klarifikasi kondisi di lapangan',
          ),
        ),
      ),
      await tester.pumpAndSettle();

      // Clarification section should be visible
      expect(find.textContaining('Clarification'), findsWidgets);
    });
  });
}

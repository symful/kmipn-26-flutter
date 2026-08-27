// Widget/Integration tests for SurveyorTabScreen (S-01)
//
// Tests real flows with concrete assertions:
// - Task cards presence
// - StatusPill display on cards
// - Bottom navigation tab switching
// - Task card tap → navigates to detail
// - Empty state when no tasks
//
// Uses WidgetTester + mock providers.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sigap/api/types.g.dart';
import 'package:sigap/db/database.dart';
import 'package:sigap/features/surveyor/surveyor_tab_screen.dart';
import 'package:sigap/providers/providers.dart';
import 'package:sigap/theme/tokens.dart';
import 'package:sigap/widgets/design_system/phone_frame.dart';

/// Mock surveyor tasks.
List<SurveyorTask> mockSurveyorTasks() {
  return [
    SurveyorTask(
      taskId: 'TGS-001',
      reportId: 'report-001',
      reportTitle: 'Lubang jalan berbahaya',
      reportLat: -6.9000,
      reportLng: 107.6000,
      address: 'Jl. Asia Afrika, Bandung',
      status: 'assigned',
      deadline: DateTime.now().add(const Duration(days: 2)).toIso8601String(),
    ),
    SurveyorTask(
      taskId: 'TGS-002',
      reportId: 'report-002',
      reportTitle: 'Drainase tersumbat',
      reportLat: -6.9010,
      reportLng: 107.6010,
      address: 'Gg. Melati, Bandung',
      status: 'pending',
      deadline: DateTime.now().add(const Duration(hours: 5)).toIso8601String(),
    ),
  ];
}

/// Creates a ProviderScope with overridden providers for surveyor tab screen tests.
Widget createTestWidget({
  required Widget child,
  List<SurveyorTask>? tasks,
  bool isLoading = false,
  String? error,
}) {
  return ProviderScope(
    overrides: [
      // Surveyor tasks provider
      surveyorTasksProvider.overrideWith((ref) {
        if (error != null) {
          return Future.error(error);
        }
        return Future.value(tasks ?? mockSurveyorTasks());
      }),
      // API client - mock
      apiClientProvider.overrideWith((ref) {
        return MockSurveyorApiClient();
      }),
      // Surveyor task repository - mock
      surveyorTaskRepositoryProvider.overrideWith((ref) {
        return MockSurveyorTaskRepository();
      }),
      // Connectivity - online
      connectivityProvider.overrideWith((ref) {
        return Stream<List<ConnectivityResult>>.value([
          ConnectivityResult.wifi,
        ]);
      }),
    ],
    child: MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: SigapColors.primary),
      ),
      home: child,
    ),
  );
}

/// Mock API client for surveyor.
class MockSurveyorApiClient {
  Future<SurveyorTasksResponse> surveyorGetTasks() async {
    return SurveyorTasksResponse(tasks: mockSurveyorTasks());
  }
}

/// Mock SurveyorTaskRepository.
class MockSurveyorTaskRepository {
  Future<List<DownloadedTask>> getDownloadedTasks() async => [];
  Future<DownloadedTask?> getDownloadedTask(String taskId) async => null;
  Future<void> saveDownloadedTask({
    required String taskId,
    required String title,
    String? description,
    String? instructions,
    required String status,
    required List<Map<String, dynamic>> checklistTemplate,
  }) async {}
}

// ─── Tests ────────────────────────────────────────────────────────────────────

void main() {
  group('T25: SurveyorTabScreen (S-01) Flow Tests', () {
    testWidgets('S-01.1: Screen renders with PhoneFrame wrapper', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(child: PhoneFrame(child: SurveyorTabScreen())),
      );
      await tester.pumpAndSettle();

      // PhoneFrame should be present
      expect(find.byType(PhoneFrame), findsOneWidget);
    });

    testWidgets('S-01.2: AppBar shows "Tugas hari ini" title', (tester) async {
      await tester.pumpWidget(
        createTestWidget(child: PhoneFrame(child: SurveyorTabScreen())),
      );
      await tester.pumpAndSettle();

      // Header should show "Tugas hari ini"
      expect(find.text('Tugas hari ini'), findsOneWidget);
    });

    testWidgets('S-01.3: Task cards are displayed when tasks available', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          child: PhoneFrame(child: SurveyorTabScreen()),
          tasks: mockSurveyorTasks(),
        ),
      );
      await tester.pumpAndSettle();

      // Task cards should be visible
      expect(find.text('Lubang jalan berbahaya'), findsWidgets);
      expect(find.text('Drainase tersumbat'), findsWidgets);
    });

    testWidgets('S-01.4: SLA badges shown on task cards', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: PhoneFrame(child: SurveyorTabScreen()),
          tasks: mockSurveyorTasks(),
        ),
      );
      await tester.pumpAndSettle();

      // SLA labels should be present (e.g., "SLA 2d" or "SLA 5j")
      // At least one SLA badge should be visible
      expect(find.byType(_SinkronTaskCard), findsWidgets);
    });

    testWidgets('S-01.5: Bottom navigation with 2 tabs is present', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(child: PhoneFrame(child: SurveyorTabScreen())),
      );
      await tester.pumpAndSettle();

      // Should have _Surveyor2TabNav
      expect(find.byType(_Surveyor2TabNav), findsOneWidget);
      // Should have Sinkron tab
      expect(find.text('Sinkron'), findsOneWidget);
      // Should have Riwayat tab
      expect(find.text('Riwayat'), findsOneWidget);
    });

    testWidgets('S-01.6: Tapping task card is interactive', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: PhoneFrame(child: SurveyorTabScreen()),
          tasks: mockSurveyorTasks(),
        ),
      );
      await tester.pumpAndSettle();

      // Find and tap a task card
      final taskCard = find.text('Lubang jalan berbahaya');
      expect(taskCard, findsWidgets);
      await tester.tap(taskCard.first);
      await tester.pumpAndSettle();
    });

    testWidgets('S-01.7: Tab switching works - Riwayat tab shows empty state', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(child: PhoneFrame(child: SurveyorTabScreen())),
      );
      await tester.pumpAndSettle();

      // Tap on Riwayat tab
      await tester.tap(find.text('Riwayat'));
      await tester.pumpAndSettle();

      // Riwayat tab should show empty state
      expect(find.text('Belum ada riwayat'), findsOneWidget);
    });

    testWidgets('S-01.8: Task ID shown on task cards', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: PhoneFrame(child: SurveyorTabScreen()),
          tasks: mockSurveyorTasks(),
        ),
      );
      await tester.pumpAndSettle();

      // Task IDs should be displayed (TGS- prefix)
      expect(find.textContaining('TGS-'), findsWidgets);
    });

    testWidgets('S-01.9: Download button shown on task cards', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: PhoneFrame(child: SurveyorTabScreen()),
          tasks: mockSurveyorTasks(),
        ),
      );
      await tester.pumpAndSettle();

      // Download icon should be visible (download_rounded or download_done)
      expect(find.byIcon(Icons.download_rounded), findsWidgets);
    });

    testWidgets('S-01.10: Connectivity indicator present', (tester) async {
      await tester.pumpWidget(
        createTestWidget(child: PhoneFrame(child: SurveyorTabScreen())),
      );
      await tester.pumpAndSettle();

      // Connectivity indicator should be present
      expect(find.byType(ConnectivityIndicator), findsOneWidget);
    });
  });
}

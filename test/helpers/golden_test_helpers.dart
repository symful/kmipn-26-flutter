// Golden test helpers — mock providers for all 6 screens (T17-T22)
//
// Each screen gets realistic mock data so the golden renders show the full UI
// (not empty/loading states). Provider overrides are applied via
// ProviderScope.overrides in each test file.

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sigap/api/types.g.dart';
import 'package:sigap/db/database.dart';
import 'package:sigap/providers/auth_provider.dart';
import 'package:sigap/providers/providers.dart';
import 'package:sigap/widgets/design_system/phone_frame.dart';

// ─── Mock AuthState ──────────────────────────────────────────────────────────

const _mockWargaAuthState = AuthState(
  accessToken: 'test-token-warga',
  userId: 'user-warga-001',
  userRole: 'WARGA',
  activeRole: 'WARGA',
  userEmail: 'warga@test.com',
  userName: 'Warga Tester',
  roles: ['WARGA'],
);

const _mockSurveyorAuthState = AuthState(
  accessToken: 'test-token-surveyor',
  userId: 'user-surveyor-001',
  userRole: 'SURVEYOR',
  activeRole: 'SURVEYOR',
  userEmail: 'surveyor@test.com',
  userName: 'Surveyor Tester',
  roles: ['SURVEYOR'],
);

// ─── Mock LocalReports ───────────────────────────────────────────────────────

final _mockLocalReports = <LocalReport>[
  LocalReport(
    idempotencyKey: 'local-001',
    serverId: 'srv-001',
    categoryId: 'cat-001',
    description: 'Lubang di jalan utama dengan diameter 50cm',
    lat: -6.9175,
    lng: 107.6191,
    syncStatus: 1,
    status: 'submitted',
    createdAt: DateTime(2026, 8, 20),
    updatedAt: DateTime(2026, 8, 20),
  ),
  LocalReport(
    idempotencyKey: 'local-002',
    serverId: 'srv-002',
    categoryId: 'cat-002',
    description: 'Drainase tersumbat di depan Masjid Al-Hidayah',
    lat: -6.9200,
    lng: 107.6100,
    syncStatus: 2,
    status: 'failed',
    createdAt: DateTime(2026, 8, 18),
    updatedAt: DateTime(2026, 8, 18),
  ),
];

// ─── Mock WargaStats ─────────────────────────────────────────────────────────

const _mockWargaStats = WargaStats(
  total: 5,
  submitted: 2,
  inProgress: 1,
  verified: 1,
  resolved: 1,
);

// ─── Mock SurveyorTasks ──────────────────────────────────────────────────────

final _mockSurveyorTasks = <SurveyorTask>[
  SurveyorTask(
    taskId: 'TGS-3401',
    reportId: 'rpt-001',
    reportTitle: 'Lubang jalan di JL Sudirman',
    reportLat: -6.9175,
    reportLng: 107.6191,
    reportAddress: 'Jl. Sudirman No. 10, Bandung',
    status: 'assigned',
    deadline: DateTime(2026, 8, 28).toIso8601String(),
  ),
  SurveyorTask(
    taskId: 'TGS-3402',
    reportId: 'rpt-002',
    reportTitle: 'Drainase tersumbat靠近小学',
    reportLat: -6.9200,
    reportLng: 107.6100,
    reportAddress: 'Jl. Asia Afrika',
    status: 'pending',
    deadline: DateTime(2026, 8, 29).toIso8601String(),
  ),
];

// ─── Mock Report Detail ───────────────────────────────────────────────────────

final _mockReportDetail = Report(
  id: 'rpt-detail-001',
  title: 'Lubang Jalan Berlubang di JL Sudirman',
  description:
      'Lubang dengan diameter 50cm dan kedalaman 20cm, sangat berbahaya bagi pengguna jalan，尤其是摩托车。',
  status: ReportStatus.needsCompletion,
  category: 'JALAN',
  priority: Priority(value: 'TINGGI'),
  location: {'lat': -6.9175, 'lng': 107.6191},
  createdAt: '2026-08-20T10:30:00Z',
  deadline: '2026-08-28T23:59:59Z',
  photos: [
    Photo(url: 'https://picsum.photos/seed/1/400/300'),
    Photo(url: 'https://picsum.photos/seed/2/400/300'),
  ],
);

final _mockTimelineEnvelope = TimelineEnvelope(
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
      message: 'Verifikator meminta foto tambahan',
      timestamp: '2026-08-21T14:00:00Z',
      userId: 'verifikator@test.com',
    ),
  ],
);

// ─── Mock Task Detail (S-02) ─────────────────────────────────────────────────

final _mockTaskDetail = TaskDetail(
  taskId: 'TGS-3402',
  reportId: 'rpt-002',
  reportTitle: 'Drainase Tersumbat di Jl. Asia Afrika',
  description:
      'Drainase di depan pertigaan Jl. Asia Afrika tersumbat sampah dan air meluap ke jalan.',
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

// ─── Helper: build Widget wrapped in PhoneFrame ───────────────────────────────

/// Wraps [child] in a PhoneFrame with fixed 392×812 dimensions.
/// Use this for screens that are NOT already wrapped in PhoneFrame.
Widget wrapInPhoneFrame(Widget child) {
  return MaterialApp(home: PhoneFrame(child: child));
}

/// Golden test widget: wraps [child] in PhoneFrame inside a MaterialApp,
/// rendered at 392×812 for pixel-exact comparison.
Widget goldenTestFrame(Widget child) {
  return MediaQuery(
    data: const MediaQueryData(size: Size(392, 812)),
    child: MaterialApp(home: PhoneFrame(child: child)),
  );
}

// ─── Provider Override Bundles ────────────────────────────────────────────────

/// Complete override bundle for WargaHomeScreen (M-05).
List<Override> wargaHomeOverrides() => [
  authNotifierProvider.overrideWith((_) {
    final notifier = MockAuthNotifier(_mockWargaAuthState);
    return notifier;
  }),
  connectivityProvider.overrideWith(
    (_) => Stream.value([ConnectivityResult.wifi]),
  ),
  localReportsProvider.overrideWith((_) async => _mockLocalReports),
  wargaReportsProvider.overrideWith((_) async => []),
  pendingCountProvider.overrideWith((_) => Stream.value(0)),
  wargaStatsProvider.overrideWith((_) async => _mockWargaStats),
  selectedWilayahNameProvider.overrideWith((_) => 'Bandung'),
  unreadCountProvider.overrideWith((_) => Stream.value(3)),
];

/// Override bundle for ReviewKirimanScreen (M-11).
List<Override> reviewKirimanOverrides() => [
  connectivityProvider.overrideWith(
    (_) => Stream.value([ConnectivityResult.wifi]),
  ),
];

/// Override bundle for ReportDetailScreen (M-14).
List<Override> reportDetailOverrides(String reportId) => [
  apiReportProvider(reportId).overrideWith((_) async => _mockReportDetail),
  reportTimelineProvider(
    reportId,
  ).overrideWith((_) async => _mockTimelineEnvelope),
];

/// Override bundle for SurveyorTabScreen (S-01).
List<Override> surveyorTabOverrides() => [
  authNotifierProvider.overrideWith((_) {
    final notifier = MockAuthNotifier(_mockSurveyorAuthState);
    return notifier;
  }),
  surveyorTasksProvider.overrideWith((_) async => _mockSurveyorTasks),
  connectivityProvider.overrideWith(
    (_) => Stream.value([ConnectivityResult.wifi]),
  ),
];

/// Override bundle for TasksFlowDetailScreen (S-02).
List<Override> tasksFlowDetailOverrides(String taskId) => [
  apiClientProvider.overrideWith((_) => MockApiClient()),
  surveyorTaskRepositoryProvider.overrideWith(
    (_) => MockSurveyorTaskRepository(),
  ),
  databaseProvider.overrideWith((_) => MockAppDatabase()),
];

/// Override bundle for FormSurveiScreen (S-04).
List<Override> formSurveiOverrides() => [
  databaseProvider.overrideWith((_) => MockAppDatabase()),
  surveyorTaskRepositoryProvider.overrideWith(
    (_) => MockSurveyorTaskRepository(),
  ),
  syncQueueRepositoryProvider.overrideWith((_) => MockSyncQueueRepository()),
  apiClientProvider.overrideWith((_) => MockApiClient()),
];

// ─── Mock Implementations ─────────────────────────────────────────────────────

class MockAuthNotifier extends StateNotifier<AuthState> {
  MockAuthNotifier(AuthState initialState) : super(initialState);

  void updateState(AuthState newState) => state = newState;
}

class MockApiClient {}

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
  Future<List<SyncedVisit>> getSyncedVisits() async => [];
  Future<void> saveVisit({
    required String idempotencyKey,
    required String taskId,
    required Map<String, dynamic> visitData,
  }) async {}
}

class MockSyncQueueRepository {
  Future<void> enqueue(String idempotencyKey) async {}
}

class MockAppDatabase {}

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../api/api_client.dart';
import '../api/types.g.dart';
import '../db/database.dart';
import '../db/repositories/report_repository.dart';
import '../db/repositories/category_repository.dart';
import '../db/repositories/sync_queue_repository.dart';
import '../db/repositories/surveyor_task_repository.dart';
import '../sync/background_sync.dart';
import '../sync/sync_worker.dart';
import '../utils/logger.dart';
import 'auth_provider.dart';

final _logger = Logger('Providers');

// ─── Location Picking Providers ───────────────────────────────────────────────

final pickLocationModeProvider = StateProvider<bool>((ref) => false);

final pickLocationCallbackProvider = StateProvider<void Function(LatLng)?>(
  (ref) => null,
);

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return ReportRepository(ref.watch(databaseProvider));
});

final syncQueueRepositoryProvider = Provider<SyncQueueRepository>((ref) {
  return SyncQueueRepository(ref.watch(databaseProvider));
});

final surveyorTaskRepositoryProvider = Provider<SurveyorTaskRepository>((ref) {
  return SurveyorTaskRepository(ref.watch(databaseProvider));
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository(ref.watch(databaseProvider));
});

final apiClientProvider = Provider<ApiClient>((ref) {
  ref.keepAlive();
  return ApiClient(
    onLogout: () => ref.read(authNotifierProvider.notifier).logout(),
  );
});

final syncWorkerProvider = Provider<SyncWorker>((ref) {
  final worker = SyncWorker(
    api: ref.watch(apiClientProvider),
    reportRepo: ref.watch(reportRepositoryProvider),
    surveyorTaskRepo: ref.watch(surveyorTaskRepositoryProvider),
    queueRepo: ref.watch(syncQueueRepositoryProvider),
  );
  ref.onDispose(() => worker.stop());
  return worker;
});

final connectivityProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
});

final localReportsProvider = FutureProvider<List<LocalReport>>((ref) async {
  final repo = ref.watch(reportRepositoryProvider);
  ref.watch(syncWorkerProvider);
  return repo.getAllReports();
});

/// Stream-based pending count provider for real-time UI updates.
///
/// Uses PendingCountNotifier from SyncWorker to emit count changes after each
/// sync operation. Backed by a broadcast StreamController in dart:async.
///
/// - Initial value: fetched from repository on first watch
/// - Updates: emitted by SyncWorker.syncNow() after each sync completes
/// - Consumers: warga_home_screen.dart pending banner, etc.
final pendingCountProvider = StreamProvider<int>((ref) {
  final worker = ref.watch(syncWorkerProvider);
  // Trigger initial count fetch by watching syncWorkerProvider
  // The worker loads initial count and emits it on first sync
  ref.watch(syncWorkerProvider);
  return worker.pendingCountNotifier.stream;
});

/// Tracks whether wargaReportsProvider is serving stale (offline-cached) data.
final isStaleWargaReportsProvider = StateProvider<bool>((ref) => false);

/// Fetches server-side reports created by the current warga user.
/// On NetworkException/ConnectivityException with cached Drift rows available,
/// emits cached data and marks it stale via [isStaleWargaReportsProvider].
final wargaReportsProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final api = ref.watch(apiClientProvider);
  ref.watch(syncWorkerProvider); // react to sync state changes
  try {
    final page = await api.getWargaReports();
    isStaleWargaReportsProvider.state = false;
    return page.items.map((r) => r.toJson()).toList();
  } on NetworkException catch (e, st) {
    _logger.warning('wargaReportsProvider network error, trying cache', e, st);
    // Try offline cache
    final localReports = await ref.read(localReportsProvider.future);
    if (localReports.isNotEmpty) {
      isStaleWargaReportsProvider.state = true;
      return localReports
          .map(
            (r) => {
              'id': r.serverId ?? r.idempotencyKey,
              'idempotency_key': r.idempotencyKey,
              'category_id': r.categoryId,
              'description': r.description,
              'lat': r.lat,
              'lng': r.lng,
              'status': r.status,
              'created_at': r.createdAt.toIso8601String(),
              'updated_at': r.updatedAt.toIso8601String(),
              'device_id': r.deviceId,
            },
          )
          .toList();
    }
    rethrow;
  } on ConnectivityException catch (e, st) {
    _logger.warning('wargaReportsProvider offline, trying cache', e, st);
    final localReports = await ref.read(localReportsProvider.future);
    if (localReports.isNotEmpty) {
      isStaleWargaReportsProvider.state = true;
      return localReports
          .map(
            (r) => {
              'id': r.serverId ?? r.idempotencyKey,
              'idempotency_key': r.idempotencyKey,
              'category_id': r.categoryId,
              'description': r.description,
              'lat': r.lat,
              'lng': r.lng,
              'status': r.status,
              'created_at': r.createdAt.toIso8601String(),
              'updated_at': r.updatedAt.toIso8601String(),
              'device_id': r.deviceId,
            },
          )
          .toList();
    }
    rethrow;
  }
});

final categoriesProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final api = ref.watch(apiClientProvider);
  return await api.getCategories();
});

/// Fetches warga statistics (submitted, verified, in_progress, resolved).
final wargaStatsProvider = FutureProvider<WargaStats>((ref) async {
  final api = ref.watch(apiClientProvider);
  return await api.getWargaStats();
});

/// Fetches nearby reports based on user location.
final nearbyReportsProvider =
    FutureProvider.family<
      List<Map<String, dynamic>>,
      ({double lat, double lng})
    >((ref, location) async {
      final api = ref.watch(apiClientProvider);
      final reports = await api.getNearbyReports(
        lat: location.lat,
        lng: location.lng,
      );
      return reports.map((r) => r.toJson()).toList();
    });

/// Fetches duplicate case candidates for a given location and category.
/// Used by SimilarCasesBanner (M-11) during report creation.
final duplicateCasesProvider =
    FutureProvider.family<
      List<Map<String, dynamic>>,
      ({double lat, double lng, String? categoryId})
    >((ref, params) async {
      final api = ref.watch(apiClientProvider);
      final candidates = await api.getDuplicateCases(
        lat: params.lat,
        lng: params.lng,
        categoryId: params.categoryId,
      );
      return candidates.map((c) => c.toJson()).toList();
    });

/// Fetches the timeline/history events for a given report.
final reportTimelineProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, reportId) async {
      final api = ref.watch(apiClientProvider);
      final timeline = await api.getReportTimeline(reportId);
      return timeline.toJson();
    });

final syncManagerProvider = AsyncNotifierProvider<SyncManager, void>(() {
  return SyncManager();
});

class SyncManager extends AsyncNotifier<void> {
  Timer? _periodicTimer;

  @override
  Future<void> build() async {
    final worker = ref.read(syncWorkerProvider);

    worker.start();

    // Get token from auth state to initialize background sync
    final authState = ref.read(authNotifierProvider);
    await initializeBackgroundSync(accessToken: authState.accessToken);

    _periodicTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      worker.syncNow();
    });

    ref.onDispose(() {
      _periodicTimer?.cancel();
    });
  }
}

/// Provider that triggers sync initialization on first watch.
/// Watches [syncManagerProvider] to ensure SyncWorker.start() and
/// initializeBackgroundSync() are called on app startup.
final syncInitProvider = Provider<void>((ref) {
  ref.watch(syncManagerProvider);
});

// ─── Surveyor S-01 Filter & Sort Providers ─────────────────────────────────

/// Tracks selected filter index for surveyor S-01 screen.
/// 0 = Hari ini, 1 = Terlambat, 2 = Belum diunduh, null = all
final surveyorFilterProvider = StateProvider<int?>((ref) => null);

/// Tracks selected sort option for surveyor S-01 screen.
/// Values: 'terbaru', 'sla', 'prioritas'
final surveyorSortProvider = StateProvider<String>((ref) => 'terbaru');

/// Fetches surveyor tasks from the server for S-01 screen.
final surveyorTasksProvider = FutureProvider<List<SurveyorTask>>((ref) async {
  final api = ref.watch(apiClientProvider);
  final page = await api.surveyorGetTasks();
  return page.tasks;
});

// ─── Surveyor Task Action Providers ─────────────────────────────────────────

/// Accepts a surveyor task by ID.
final surveyorAcceptTaskProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, taskId) async {
      final api = ref.watch(apiClientProvider);
      return await api.surveyorAcceptTask(taskId);
    });

/// Rejects a surveyor task with a reason.
final surveyorRejectTaskProvider =
    FutureProvider.family<
      Map<String, dynamic>,
      ({String taskId, String reason})
    >((ref, params) async {
      final api = ref.watch(apiClientProvider);
      return await api.surveyorRejectTask(params.taskId, params.reason);
    });

/// Requests clarification for a surveyor task.
final surveyorRequestClarificationProvider =
    FutureProvider.family<
      Map<String, dynamic>,
      ({String taskId, String question})
    >((ref, params) async {
      final api = ref.watch(apiClientProvider);
      return await api.surveyorRequestClarification(
        params.taskId,
        question: params.question,
      );
    });

// ─── Surveyor S-04 Visit Report Submission ─────────────────────────────────────

/// Parameters for submitting a structured visit report.
class SurveyorVisitParams {
  final String taskId;
  final Map<String, String> photos;
  final double gpsLat;
  final double gpsLng;
  final double accuracy;
  final String kondisi;
  final String rekomendasi;
  final String? catatan;

  /// Survey findings summary from form state (required, non-empty).
  final String findings;

  /// Checklist items from form state (required, non-empty list).
  final List<Map<String, dynamic>> checklist;

  const SurveyorVisitParams({
    required this.taskId,
    required this.photos,
    required this.gpsLat,
    required this.gpsLng,
    required this.accuracy,
    required this.kondisi,
    required this.rekomendasi,
    this.catatan,
    required this.findings,
    required this.checklist,
  });
}

/// Submits a structured visit report for a surveyor task.
/// Structured fields: findings, checklist, photos, GPS coordinates, accuracy, kondisi, rekomendasi, catatan.
/// Throws ArgumentError if findings or checklist is empty (API contract).
final surveyorSubmitVisitProvider =
    FutureProvider.family<Map<String, dynamic>, SurveyorVisitParams>((
      ref,
      params,
    ) async {
      final api = ref.watch(apiClientProvider);
      final result = await api.submitVisitReport(
        taskId: params.taskId,
        findings: params.findings,
        checklist: params.checklist,
        photoUrls: params.photos.values.toList(),
        gpsLat: params.gpsLat,
        gpsLng: params.gpsLng,
        accuracy: params.accuracy,
        conditionAssessment: params.kondisi,
        recommendation: params.rekomendasi,
        catatan: params.catatan,
      );
      return result.toJson();
    });

// ─── Notifications ─────────────────────────────────────────────────────────────

/// Fetches notifications from the server.
final notificationsProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final api = ref.watch(apiClientProvider);
  final page = await api.getNotifications();
  return page.entries.map((e) => e.toJson()).toList();
});

/// Computed provider that returns the count of unread notifications.
/// Returns 0 if notifications are loading or on error.
final unreadCountProvider = Provider<int>((ref) {
  final notificationsAsync = ref.watch(notificationsProvider);
  return notificationsAsync.whenOrNull(
        data: (notifications) => notifications
            .where((n) => n['is_read'] == false || n['is_read'] == null)
            .length,
      ) ??
      0;
});

// ─── Wilayah ─────────────────────────────────────────────────────────────────

/// Fetches wilayah (region/village) list from /api/wilayah.
/// Returns a list of wilayah objects with id, name, district, city, etc.
final wilayahProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final api = ref.watch(apiClientProvider);
  final wilayahs = await api.getWilayahList();
  return wilayahs.map((w) => w.toJson()).toList();
});

/// Returns the first available wilayah name, or a fallback string if none.
final selectedWilayahNameProvider = Provider<String>((ref) {
  final wilayahAsync = ref.watch(wilayahProvider);
  return wilayahAsync.whenOrNull(
        data: (wilayahList) {
          if (wilayahList.isEmpty) return 'Pilih Wilayah';
          final first = wilayahList.first;
          return first['name']?.toString() ??
              first['village_name']?.toString() ??
              'Pilih Wilayah';
        },
      ) ??
      'Pilih Wilayah';
});

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:sigap/api/exceptions.dart';
import '../api/client.dart';
import '../db/database.dart';
import '../db/repositories/report_repository.dart';
import '../db/repositories/category_repository.dart';
import '../db/repositories/sync_queue_repository.dart';
import '../db/repositories/surveyor_task_repository.dart';
import '../utils/logger.dart';
import 'auth_provider.dart';
export 'auth_provider.dart';

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

final connectivityProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
});

/// Returns locally cached reports from Drift database.
/// Note: background sync feature removed — this provides offline-cached data only.
final localReportsProvider = FutureProvider<List<LocalReport>>((ref) async {
  final repo = ref.watch(reportRepositoryProvider);
  return repo.getAllReports();
});

/// Pending sync count — always 0 since background sync feature was removed.
final pendingCountProvider = FutureProvider<int>((ref) async => 0);

/// Tracks whether wargaReportsProvider is serving stale (offline-cached) data.
final isStaleWargaReportsProvider = StateProvider<bool>((ref) => false);

/// Fetches server-side reports created by the current warga user.
/// On NetworkException/ConnectivityException with cached Drift rows available,
/// emits cached data and marks it stale via [isStaleWargaReportsProvider].
final wargaReportsProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final api = ref.watch(apiClientProvider);
  try {
    final page = await api.getMyReports();

    ref.read(isStaleWargaReportsProvider.notifier).state = false;
    return page.items.map((r) => r.toJson()).toList();
  } on NetworkException catch (e, st) {
    _logger.warning('wargaReportsProvider network error, trying cache', e, st);
    // Try offline cache
    final localReports = await ref.read(localReportsProvider.future);
    if (localReports.isNotEmpty) {
      ref.read(isStaleWargaReportsProvider.notifier).state = true;
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

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final api = ref.watch(apiClientProvider);
  return await api.getCategories();
});

/// Fetches categories with slugs for map filtering.
/// Returns a list of maps with 'slug' and 'name' keys.
final mapCategoriesProvider = FutureProvider<List<Map<String, String>>>((
  ref,
) async {
  final api = ref.watch(apiClientProvider);
  final categories = await api.getCategories();
  return categories
      .map(
        (c) => {'slug': c.slug ?? c.id ?? '', 'name': c.name ?? c.slug ?? ''},
      )
      .toList();
});

/// Fetches warga statistics (submitted, verified, in_progress, resolved).
final wargaStatsProvider = FutureProvider<StatsResponse>((ref) async {
  final api = ref.watch(apiClientProvider);
  return await api.getStats();
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
      return reports
          .map(
            (r) => {
              'id': r.id,
              'title': r.title,
              'category': r.category,
              'status': r.status,
              'location': r.location,
              'distance': r.distance,
            },
          )
          .toList();
    });

/// Fetches duplicate case candidates for a given report.
/// Returns empty list if reportId is null (report not yet created).
/// Used by SimilarCasesBanner (M-11) to show AI-detected duplicates.
final duplicateCasesProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String?>((
      ref,
      reportId,
    ) async {
      if (reportId == null) return [];
      final api = ref.watch(apiClientProvider);
      final candidates = await api.getDuplicateCases(reportId);
      return candidates
          .map(
            (c) => {
              'report_id': c.reportId,
              'description': c.description,
              'status': c.status,
              'distance_m': c.distanceM,
              'report_count': c.reportCount,
              'similarity_score': c.similarityScore,
            },
          )
          .toList();
    });

/// Parameters for the similar cases query during report creation.
class SimilarCasesParams {
  final double lat;
  final double lng;
  final String categoryId;
  const SimilarCasesParams({
    required this.lat,
    required this.lng,
    required this.categoryId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SimilarCasesParams &&
          runtimeType == other.runtimeType &&
          lat == other.lat &&
          lng == other.lng &&
          categoryId == other.categoryId;

  @override
  int get hashCode => lat.hashCode ^ lng.hashCode ^ categoryId.hashCode;
}

/// Fetches similar report candidates from GET /api/reports/similar.
/// Called during report creation (M-11) after user enters location + category.
final similarCasesProvider =
    FutureProvider.family<List<Map<String, dynamic>>, SimilarCasesParams>((
      ref,
      params,
    ) async {
      final api = ref.watch(apiClientProvider);
      final similar = await api.getSimilarReports(
        lat: params.lat,
        lng: params.lng,
        categoryId: params.categoryId,
      );
      return similar
          .map(
            (c) => {
              'report_id': c.reportId,
              'title': c.title,
              'initials': c.initials,
              'distance_m': c.distanceM,
              'report_count': c.reportCount,
              'similarity_score': c.similarityScore,
            },
          )
          .toList();
    });

/// Fetches the timeline/history events for a given report.
final reportTimelineProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, reportId) async {
      final api = ref.watch(apiClientProvider);
      final timeline = await api.getReportTimeline(reportId);
      return {
        'events': timeline.events
            ?.map(
              (e) => {
                'id': e.id,
                'type': e.type,
                'message': e.message,
                'timestamp': e.timestamp,
                'userId': e.userId,
              },
            )
            .toList(),
      };
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
  final page = await api.getTasks();
  return page.tasks.cast<SurveyorTask>();
});

// ─── Surveyor Task Action Providers ─────────────────────────────────────────

/// Accepts a surveyor task by ID.
final surveyorAcceptTaskProvider =
    FutureProvider.family<TaskActionResult, String>((ref, taskId) async {
      final api = ref.watch(apiClientProvider);
      return await api.taskAction(taskId, action: 'accept');
    });

/// Rejects a surveyor task with a reason.
final surveyorRejectTaskProvider =
    FutureProvider.family<TaskActionResult, ({String taskId, String reason})>((
      ref,
      params,
    ) async {
      final api = ref.watch(apiClientProvider);
      return await api.taskAction(
        params.taskId,
        action: 'reject',
        note: params.reason,
      );
    });

/// Requests clarification for a surveyor task.
final surveyorRequestClarificationProvider =
    FutureProvider.family<TaskActionResult, ({String taskId, String question})>(
      (ref, params) async {
        final api = ref.watch(apiClientProvider);
        return await api.taskAction(
          params.taskId,
          action: 'clarify',
          note: params.question,
        );
      },
    );

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
      return {
        'visit_id': result.visitId,
        'task_id': result.taskId,
        'status': result.status,
      };
    });

// ─── Notifications ─────────────────────────────────────────────────────────────

/// Fetches notifications from the server.
final notificationsProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final api = ref.watch(apiClientProvider);
  final page = await api.getNotifications();
  return page.entries.map((e) {
    final map = e.toJson();
    // Derive is_read from the read field (backend uses read_at)
    map['is_read'] = e.read == true;
    map['read_at'] = e.read == true
        ? (map['created_at'] ?? DateTime.now().toIso8601String())
        : null;
    map['kind'] = map['kind'] ?? 'general';
    map['related_case_id'] = map['related_case_id'];
    return map;
  }).toList();
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
  return wilayahs
      .map(
        (w) => {
          'id': w.id,
          'name': w.name,
          'level': w.level,
          'parent_id': w.parentId,
        },
      )
      .toList();
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

/// Fetches the current user's assigned wilayah name from /api/auth/me.
/// Returns the user's wilayahName or 'Kab. Bandung' as fallback for backward compatibility.
final userWilayahProvider = FutureProvider<String>((ref) async {
  final api = ref.watch(apiClientProvider);
  try {
    final profile = await api.me();
    // Use name as fallback since UserResponse doesn't include wilayahName
    return profile.name ?? 'Kab. Bandung';
  } catch (e) {
    // Fallback to 'Kab. Bandung' if profile fetch fails
    return 'Kab. Bandung';
  }
});

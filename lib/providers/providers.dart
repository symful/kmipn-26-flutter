import 'dart:async';
import 'package:flutter/widgets.dart'
    show AppLifecycleListener, AppLifecycleState, WidgetsBinding;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sigap/api/exceptions.dart';
import '../api/client.dart';
import '../db/database.dart';
import '../db/repositories/report_repository.dart';
import '../db/repositories/category_repository.dart';
import '../db/repositories/task_cache_repository.dart';
import '../db/repositories/sync_queue_repository.dart';
import '../sync/sync_engine.dart';
import '../sync/sync_telemetry.dart';
import '../services/internet_reachability.dart';

import '../utils/logger.dart';
import 'auth_provider.dart';
export 'auth_provider.dart';

final _logger = Logger('Providers');

final taskCacheRepositoryProvider = Provider<TaskCacheRepository>(
  (ref) => TaskCacheRepository(
    accountId: ref.watch(authNotifierProvider.select((state) => state.userId)),
  ),
);

final databaseProvider = Provider<AppDatabase>((ref) {
  final accountId = ref.watch(
    authNotifierProvider.select((state) => state.userId),
  );
  final db = AppDatabase(accountId: accountId);
  ref.onDispose(() => db.close());
  return db;
});

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return ReportRepository(ref.watch(databaseProvider));
});

final syncQueueRepositoryProvider = Provider<SyncQueueRepository>((ref) {
  return SyncQueueRepository(ref.watch(databaseProvider));
});

final syncEngineProvider = Provider<SyncEngine>((ref) {
  final telemetry = ref.watch(syncTelemetryProvider);
  return SyncEngine(
    onSyncComplete: telemetry?.publish,
    apiClient: ref.watch(apiClientProvider),
    reportRepo: ref.watch(reportRepositoryProvider),
    queueRepo: ref.watch(syncQueueRepositoryProvider),
  );
});

final syncTelemetryProvider = Provider<SyncTelemetry?>((ref) {
  final auth = ref.watch(authNotifierProvider);
  if (!auth.isAuthenticated || auth.userId == null) return null;
  final offline = ref.watch(offlineModeProvider);
  final telemetry = SyncTelemetry(
    api: ref.watch(apiClientProvider),
    reports: ref.watch(reportRepositoryProvider),
    isOnline: () async => !offline && await SyncEngine.isOnline(),
  );
  telemetry.start(
    offline ? const Stream.empty() : Connectivity().onConnectivityChanged,
  );
  ref.onDispose(telemetry.dispose);
  return telemetry;
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository(
    accountId: ref.watch(authNotifierProvider.select((state) => state.userId)),
  );
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final accountId = ref.watch(
    authNotifierProvider.select((state) => state.userId),
  );
  ref.keepAlive();
  final client = ApiClient(
    accountId: accountId,
    onLogout: () => ref.read(authNotifierProvider.notifier).logout(),
  );
  ref.onDispose(client.close);
  return client;
});

/// Public (unauthenticated) API client for anonymous/public endpoints.
/// Does not carry auth tokens — safe for unauthenticated screens.
final publicApiClientProvider = Provider<ApiClient>((ref) {
  ref.keepAlive();
  final client = ApiClient(authenticated: false);
  ref.onDispose(client.close);
  return client;
});

final offlineModeProvider = Provider<bool>((ref) {
  final status = ref.watch(connectivityProvider);
  return status.valueOrNull?.contains(ConnectivityResult.none) ?? true;
});
final connectivityProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  return InternetReachability.watch().map(
    (online) => [online ? ConnectivityResult.other : ConnectivityResult.none],
  );
});

/// Returns locally cached reports from Drift database.
/// Note: background sync feature removed — this provides offline-cached data only.
final localReportsProvider = FutureProvider<List<LocalReport>>((ref) async {
  final repo = ref.watch(reportRepositoryProvider);
  return repo.getAllReports();
});

/// Pending sync count — counts items in sync queue with syncStatus == 0.
final pendingCountProvider = FutureProvider<int>((ref) async {
  final queueRepo = ref.watch(syncQueueRepositoryProvider);
  return (await queueRepo.getPendingItems()).length;
});

/// Tracks whether wargaReportsProvider is serving stale (offline-cached) data.
final isStaleWargaReportsProvider = StateProvider<bool>((ref) => false);

List<Report> _cachedReports(List<LocalReport> reports) => reports
    .map(
      (r) => Report(
        id: r.serverId ?? r.idempotencyKey,
        idempotencyKey: r.idempotencyKey,
        title: r.description,
        description: r.description,
        category: r.categoryId,
        status: ReportStatus.fromJson(r.status),
        lat: r.lat,
        lng: r.lng,
        createdAt: r.createdAt.toIso8601String(),
        updatedAt: r.updatedAt.toIso8601String(),
      ),
    )
    .toList();

/// Read the local cache in explicit offline mode; otherwise fetch server data
/// and retain cached reports when the network is unavailable.
final wargaReportsProvider = FutureProvider<List<Report>>((ref) async {
  final offline = ref.watch(offlineModeProvider);
  if (offline) {
    final cached = await ref.watch(localReportsProvider.future);
    ref.read(isStaleWargaReportsProvider.notifier).state = true;
    return _cachedReports(cached);
  }
  final api = ref.watch(apiClientProvider);
  try {
    final page = await api.getMyReports();
    ref.read(isStaleWargaReportsProvider.notifier).state = false;
    return page.items;
  } on NetworkException catch (e, st) {
    _logger.warning('wargaReportsProvider network error, trying cache', e, st);
    final cached = await ref.read(localReportsProvider.future);
    if (cached.isEmpty) rethrow;
    ref.read(isStaleWargaReportsProvider.notifier).state = true;
    return _cachedReports(cached);
  }
});
final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final cache = ref.watch(categoryRepositoryProvider);
  if (ref.watch(offlineModeProvider)) return cache.getCachedCategories();
  final api = ref.watch(apiClientProvider);
  try {
    final categories = await api.getCategories();
    try {
      await cache.saveCategories(categories);
    } catch (error, stack) {
      _logger.warning('Category cache write failed', error, stack);
    }
    return categories;
  } on NetworkException {
    final categories = await cache.getCachedCategories();
    if (categories.isEmpty) rethrow;
    return categories;
  }
});

/// Fetches warga statistics (submitted, verified, in_progress, resolved).
final wargaStatsProvider = FutureProvider<WargaStats>((ref) async {
  final api = ref.watch(apiClientProvider);
  return await api.getWargaStats();
});

/// Fetches nearby reports based on user location.
final nearbyReportsProvider =
    FutureProvider.family<List<NearbyReport>, ({double lat, double lng})>((
      ref,
      location,
    ) async {
      final api = ref.watch(apiClientProvider);
      return await api.getNearbyReports(lat: location.lat, lng: location.lng);
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

/// Fetches similar report candidates from GET /api/reports/duplicates.
/// Called during report creation (M-11) after user enters location + category.
final similarCasesProvider =
    FutureProvider.family<List<SimilarReport>, SimilarCasesParams>((
      ref,
      params,
    ) async {
      final api = ref.watch(apiClientProvider);
      final similar = await api.getSimilarReports(
        lat: params.lat,
        lng: params.lng,
        categoryId: params.categoryId,
      );
      return similar;
    });

/// Fetches the timeline/history events for a given report.
final reportTimelineProvider = FutureProvider.family<TimelineEnvelope, String>((
  ref,
  reportId,
) async {
  final api = ref.watch(apiClientProvider);
  return api.getReportTimeline(reportId);
});

// ─── Gamification ─────────────────────────────────────────────────────────────

/// Fetches the current user's gamification profile from the server.
final gamificationProvider = FutureProvider<GamificationProfile>((ref) async {
  final api = ref.watch(apiClientProvider);
  return api.getGamificationProfile();
});

// ─── Notifications ─────────────────────────────────────────────────────────────

/// Fetches notifications from the server.
final notificationsProvider = FutureProvider.autoDispose<List<Notification>>((
  ref,
) async {
  final api = ref.watch(apiClientProvider);
  final lifecycle = AppLifecycleListener(onResume: ref.invalidateSelf);
  final timer = Timer.periodic(const Duration(seconds: 30), (_) {
    final state = WidgetsBinding.instance.lifecycleState;
    if (state == null || state == AppLifecycleState.resumed) {
      ref.invalidateSelf();
    }
  });
  ref.onDispose(() {
    timer.cancel();
    lifecycle.dispose();
  });
  final page = await api.getNotifications();
  return page.entries;
});

/// Computed provider that returns the count of unread notifications.
/// Returns 0 if notifications are loading or on error.
final unreadCountProvider = Provider.autoDispose<int>((ref) {
  final notificationsAsync = ref.watch(notificationsProvider);
  return notificationsAsync.whenOrNull(
        data: (notifications) => notifications
            .where((n) => n.readAt == null || n.readAt!.isEmpty)
            .length,
      ) ??
      0;
});

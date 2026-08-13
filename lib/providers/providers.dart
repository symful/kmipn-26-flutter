import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../api/api_client.dart';
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

final pendingCountProvider = FutureProvider<int>((ref) async {
  final repo = ref.watch(reportRepositoryProvider);
  ref.watch(syncWorkerProvider);
  return repo.countPending();
});

/// Fetches server-side reports created by the current warga user.
final wargaReportsProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final api = ref.watch(apiClientProvider);
  ref.watch(syncWorkerProvider); // react to sync state changes
  try {
    return await api.getWargaReports();
  } catch (e, st) {
    _logger.warning('wargaReportsProvider failed', e, st);
    return [];
  }
});

final categoriesProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final api = ref.watch(apiClientProvider);
  return await api.getCategories();
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

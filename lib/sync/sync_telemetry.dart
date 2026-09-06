import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../api/client.dart';
import '../db/repositories/report_repository.dart';
import '../utils/logger.dart';

/// Publishes an observed snapshot, never an estimated queue size.
class SyncTelemetry {
  final ApiClient api;
  final ReportRepository reports;
  final Future<bool> Function() isOnline;
  final Future<String> Function() deviceId;
  StreamSubscription<Object?>? _reportsSubscription;
  StreamSubscription<Object?>? _connectivitySubscription;
  Timer? _debounce;
  bool _publishing = false;
  bool _dirty = false;
  bool _disposed = false;

  SyncTelemetry({
    required this.api,
    required this.reports,
    required this.isOnline,
    Future<String> Function()? deviceId,
  }) : deviceId = deviceId ?? _deviceId;

  static Future<String> _deviceId() async {
    final preferences = await SharedPreferences.getInstance();
    final existing = preferences.getString('sync_device_id');
    if (existing != null) return existing;
    final id = const Uuid().v4();
    await preferences.setString('sync_device_id', id);
    return id;
  }

  void start(Stream<List<ConnectivityResult>> connectivity) {
    _reportsSubscription = reports.watchAllReports().listen(
      (_) => _schedule(),
      onError: (Object error) {
        Logger('SyncTelemetry').warning('Local sync counts unavailable', error);
      },
    );
    _connectivitySubscription = connectivity.listen((results) {
      if (results.any((result) => result != ConnectivityResult.none)) {
        _schedule();
      }
    });
  }

  void _schedule() {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 500),
      () => unawaited(publish()),
    );
  }

  Future<void> publish() async {
    if (_disposed) return;
    if (_publishing) {
      _dirty = true;
      return;
    }
    _publishing = true;
    try {
      if (!await isOnline() || _disposed) return;
      final rows = await reports.getAllReports();
      final id = await deviceId();
      if (_disposed) return;
      await api.reportSyncStatus(
        deviceId: id,
        totalCount: rows.length,
        pendingCount: rows.where((row) => row.syncStatus != 1).length,
        failedCount: rows.where((row) => row.syncStatus == 2).length,
      );
    } catch (error, stack) {
      Logger(
        'SyncTelemetry',
      ).warning('Sync status upload deferred', error, stack);
    } finally {
      _publishing = false;
      if (_dirty && !_disposed) {
        _dirty = false;
        _schedule();
      }
    }
  }

  void dispose() {
    _disposed = true;
    _debounce?.cancel();
    unawaited(_reportsSubscription?.cancel());
    unawaited(_connectivitySubscription?.cancel());
  }
}

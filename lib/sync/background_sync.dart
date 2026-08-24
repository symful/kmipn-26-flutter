import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:workmanager/workmanager.dart';
import '../api/api_client.dart';
import '../db/database.dart';
import '../db/repositories/report_repository.dart';
import '../db/repositories/surveyor_task_repository.dart';
import '../db/repositories/sync_queue_repository.dart';
import '../utils/device_id.dart';
import 'sync_worker.dart';

const String backgroundSyncTaskName = 'com.sigap.background.sync';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == backgroundSyncTaskName) {
      try {
        await _runBackgroundSync(inputData: inputData);
        return true;
      } catch (e) {
        // Return false so WorkManager treats this as a failure
        // enabling its internal backoff/retry mechanism
        return false;
      }
    }
    return true;
  });
}

Future<void> _runBackgroundSync({Map<String, dynamic>? inputData}) async {
  final db = AppDatabase();
  final api = ApiClient();
  final reportRepo = ReportRepository(db);
  final surveyorTaskRepo = SurveyorTaskRepository(db);
  final queueRepo = SyncQueueRepository(db);

  final deviceId = inputData?['deviceId'] ?? 'unknown';

  final controller = StreamController<List<ConnectivityResult>>.broadcast();
  final worker = SyncWorker(
    api: api,
    reportRepo: reportRepo,
    surveyorTaskRepo: surveyorTaskRepo,
    queueRepo: queueRepo,
    connectivityStream: controller.stream,
    deviceId: deviceId,
  );

  await worker.syncNow();
  await controller.close();
}

Future<void> initializeBackgroundSync({String? accessToken}) async {
  // Don't schedule background sync without authentication
  if (accessToken == null || accessToken.isEmpty) {
    return;
  }
  final deviceId = await DeviceId.current();
  Workmanager().initialize(callbackDispatcher);
  await Workmanager().registerPeriodicTask(
    backgroundSyncTaskName,
    backgroundSyncTaskName,
    frequency: const Duration(minutes: 15),
    constraints: Constraints(networkType: NetworkType.connected),
    inputData: {'deviceId': deviceId},
  );
}

Future<void> cancelBackgroundSync() async {
  await Workmanager().cancelByUniqueName(backgroundSyncTaskName);
}

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _syncChannelId = 'sync_channel';
  static const String _syncChannelName = 'Sync Notifications';
  static const int _syncSuccessId = 1;
  static const int _syncFailureId = 2;

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(initSettings);
    await _createNotificationChannels();
  }

  Future<void> _createNotificationChannels() async {
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      const syncChannel = AndroidNotificationChannel(
        _syncChannelId,
        _syncChannelName,
        description: 'Notifications for sync events',
        importance: Importance.defaultImportance,
      );

      await androidPlugin.createNotificationChannel(syncChannel);
    }
  }

  Future<void> showSyncSuccess({String? subtitle}) async {
    const androidDetails = AndroidNotificationDetails(
      _syncChannelId,
      _syncChannelName,
      channelDescription: 'Notifications for sync events',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
    );

    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      _syncSuccessId,
      'Sinkronisasi Berhasil',
      subtitle ?? 'Data berhasil disinkronkan ke server',
      details,
    );
  }

  Future<void> showSyncFailure({String? error}) async {
    const androidDetails = AndroidNotificationDetails(
      _syncChannelId,
      _syncChannelName,
      channelDescription: 'Notifications for sync events',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      _syncFailureId,
      'Sinkronisasi Gagal',
      error ?? 'Gagal menyinkronkan data. Silakan coba lagi.',
      details,
    );
  }
}

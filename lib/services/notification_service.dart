import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../l10n/generated/app_localizations.dart';

/// Local alerts for failed offline uploads. Server notifications use the inbox.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  Locale locale = const Locale('id');
  bool _initialized = false;
  VoidCallback? onOpen;
  bool pendingOpen = false;
  static const _channelId = 'sync_channel';

  Future<void> initialize() async {
    if (_initialized ||
        kIsWeb ||
        defaultTargetPlatform != TargetPlatform.android) {
      return;
    }
    await _plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
      onDidReceiveNotificationResponse: (_) {
        pendingOpen = true;
        onOpen?.call();
      },
    );
    final launch = await _plugin.getNotificationAppLaunchDetails();
    pendingOpen = launch?.didNotificationLaunchApp ?? false;
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            'report_updates',
            'SIGAP',
            importance: Importance.high,
          ),
        );
    _initialized = true;
  }

  Future<void> showReportUpdate(String notificationId) async {
    if (!_initialized) return;
    await _plugin.show(
      notificationId.hashCode & 0x7fffffff,
      'SIGAP',
      locale.languageCode == 'en'
          ? 'Open SIGAP to view your update.'
          : 'Buka SIGAP untuk melihat pembaruan Anda.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'report_updates',
          'SIGAP',
          icon: 'ic_notification',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      payload: notificationId,
    );
  }

  Future<void> clearReportUpdates() async {
    if (_initialized) await _plugin.cancelAll();
    pendingOpen = false;
  }

  Future<void> showDeadLetter({String? itemKey, String? reason}) async {
    if (!_initialized) return;
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (await android?.requestNotificationsPermission() == false) return;
    final l = lookupAppLocalizations(
      Locale(locale.languageCode == 'en' ? 'en' : 'id'),
    );
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        l.syncChannelName,
        channelDescription: l.syncChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
    );
    await _plugin.show(
      3,
      l.itemGagalDisinkronkan,
      itemKey == null
          ? l.beberapaItemTidakDisinkronkan
          : l.itemTidakDisinkronkanPercobaan(itemKey),
      details,
    );
  }
}

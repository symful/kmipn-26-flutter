import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show AppLifecycleListener;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../api/client.dart';
import 'notification_service.dart';

enum PushState { unavailable, disabled, enabling, enabled, denied, failed }

/// Background notification payloads are displayed by Android itself. Data-only
/// messages need a local notification; never display one for a different account.
@pragma('vm:entry-point')
Future<void> sigapBackgroundMessage(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (message.notification != null) return;
  const storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  final userId = await storage.read(key: 'user_id');
  final preferences = await SharedPreferences.getInstance();
  if (preferences.getBool('push_enabled') != true ||
      !pushBelongsToUser(message.data, userId)) {
    return;
  }
  await NotificationService().initialize();
  await NotificationService().showReportUpdate(
    message.data['notification_id']?.toString() ??
        message.messageId ??
        'update',
  );
}

bool pushBelongsToUser(Map<String, dynamic> data, String? userId) =>
    userId != null && userId.isNotEmpty && data['recipient_user_id'] == userId;

class PushNotificationService {
  PushNotificationService._();
  static final instance = PushNotificationService._();
  final state = ValueNotifier<PushState>(PushState.unavailable);
  final updates = StreamController<void>.broadcast();
  VoidCallback? onOpen;
  bool _ready = false;
  bool _wanted = false;
  String? _userId;
  int _sessionGeneration = 0;
  ApiClient? _api;
  RemoteMessage? _pendingOpen;
  StreamSubscription<String>? _tokenSubscription;
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _openSubscription;
  AppLifecycleListener? _lifecycle;

  Future<void> initialize() async {
    if (_ready || kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return;
    }
    try {
      await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(sigapBackgroundMessage);
      final prefs = await SharedPreferences.getInstance();
      _wanted = prefs.getBool('push_enabled') ?? false;
      _ready = true;
      state.value = PushState.disabled;
      _tokenSubscription = FirebaseMessaging.instance.onTokenRefresh.listen(
        (token) {
          unawaited(_register(token));
        },
        onError: (_) {
          state.value = PushState.failed;
        },
      );
      _foregroundSubscription = FirebaseMessaging.onMessage.listen((message) {
        if (!_wanted || !pushBelongsToUser(message.data, _userId)) return;
        updates.add(null);
        unawaited(
          NotificationService().showReportUpdate(
            message.data['notification_id']?.toString() ??
                message.messageId ??
                'update',
          ),
        );
      });
      _openSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
        _openMessage,
      );
      _pendingOpen = await FirebaseMessaging.instance.getInitialMessage();
      NotificationService().onOpen = openInbox;
      _lifecycle = AppLifecycleListener(
        onResume: () {
          if (_wanted && _userId != null) {
            unawaited(enable(requestPermission: false));
          }
        },
      );
    } catch (_) {
      state.value = PushState.unavailable;
    }
  }

  Future<String> _deviceId() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString('sync_device_id');
    if (existing != null) return existing;
    final value = const Uuid().v4();
    await prefs.setString('sync_device_id', value);
    return value;
  }

  Future<void> syncSession(ApiClient api, String? userId) async {
    if (_userId != userId) _sessionGeneration++;
    _api = api;
    _userId = userId;
    if (!_ready || userId == null) return;
    final pending = _pendingOpen;
    if (pending != null) {
      _pendingOpen = null;
      _openMessage(pending);
    } else if (NotificationService().pendingOpen) {
      openInbox();
    }
    if (_wanted) await enable(requestPermission: false);
  }

  Future<void> enable({bool requestPermission = true}) async {
    if (!_ready || _userId == null) return;
    final generation = _sessionGeneration;
    state.value = PushState.enabling;
    try {
      final settings = requestPermission
          ? await FirebaseMessaging.instance.requestPermission(
              alert: true,
              badge: true,
              sound: true,
            )
          : await FirebaseMessaging.instance.getNotificationSettings();
      if (generation != _sessionGeneration || _userId == null) return;
      if (settings.authorizationStatus != AuthorizationStatus.authorized &&
          settings.authorizationStatus != AuthorizationStatus.provisional) {
        await disable();
        state.value = PushState.denied;
        return;
      }
      _wanted = true;
      await (await SharedPreferences.getInstance()).setBool(
        'push_enabled',
        true,
      );
      await FirebaseMessaging.instance.setAutoInitEnabled(true);
      final token = await FirebaseMessaging.instance.getToken();
      if (generation != _sessionGeneration || !_wanted) return;
      if (token == null || token.isEmpty) {
        state.value = PushState.failed;
        return;
      }
      await _register(token);
    } catch (_) {
      state.value = PushState.failed;
    }
  }

  Future<void> _register(String token) async {
    final userId = _userId;
    final api = _api;
    if (!_wanted || userId == null || api == null) return;
    try {
      final deviceId = await _deviceId();
      if (_userId != userId || !_wanted) return;
      await api.registerPushDevice(deviceId: deviceId, token: token);
      if (_userId == userId && _wanted) state.value = PushState.enabled;
    } catch (_) {
      if (_userId == userId) state.value = PushState.failed;
    }
  }

  Future<void> disable({ApiClient? authenticatedApi}) async {
    _sessionGeneration++;
    _wanted = false;
    if (!_ready) return;
    await (await SharedPreferences.getInstance()).setBool(
      'push_enabled',
      false,
    );
    try {
      await (authenticatedApi ?? _api)?.unregisterPushDevice(await _deviceId());
    } catch (_) {
      // Token deletion also revokes delivery when deregistration is offline.
    }
    try {
      await FirebaseMessaging.instance.setAutoInitEnabled(false);
      await FirebaseMessaging.instance.deleteToken();
    } catch (_) {}
    await NotificationService().clearReportUpdates();
    state.value = PushState.disabled;
  }

  Future<void> logout(ApiClient authenticatedApi) async {
    await disable(authenticatedApi: authenticatedApi);
    _userId = null;
    _api = null;
    _pendingOpen = null;
  }

  void _openMessage(RemoteMessage message) {
    if (_userId == null) {
      _pendingOpen = message;
      return;
    }
    if (!pushBelongsToUser(message.data, _userId)) return;
    openInbox();
  }

  void openInbox() {
    if (_userId == null) return;
    NotificationService().pendingOpen = false;
    updates.add(null);
    onOpen?.call();
  }

  Future<void> dispose() async {
    _lifecycle?.dispose();
    await _tokenSubscription?.cancel();
    await _foregroundSubscription?.cancel();
    await _openSubscription?.cancel();
  }
}

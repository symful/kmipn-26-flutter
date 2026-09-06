import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Public internet validation is independent from the SIGAP server's health.
class InternetReachability {
  static const _method = MethodChannel('sigap/internet');
  static const _events = EventChannel('sigap/internet/events');

  static Future<bool> isOnline() async {
    try {
      return await _method
              .invokeMethod<bool>('isValidated')
              .timeout(const Duration(seconds: 4)) ??
          false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    } on TimeoutException {
      return false;
    }
  }

  static Stream<bool> watch() {
    late StreamController<bool> controller;
    StreamSubscription<dynamic>? subscription;
    AppLifecycleListener? lifecycle;
    Timer? probeTimeout;
    var generation = 0;
    var cancelled = false;
    void refresh() {
      final request = ++generation;
      probeTimeout?.cancel();
      void complete(bool online) {
        if (cancelled || request != generation || controller.isClosed) return;
        probeTimeout?.cancel();
        generation++;
        controller.add(online);
      }

      probeTimeout = Timer(const Duration(seconds: 4), () => complete(false));
      unawaited(
        _method
            .invokeMethod<bool>('isValidated')
            .then(
              (online) => complete(online ?? false),
              onError: (Object _) => complete(false),
            ),
      );
    }

    controller = StreamController<bool>(
      onListen: () {
        refresh();
        subscription = _events.receiveBroadcastStream().listen(
          (value) {
            generation++;
            probeTimeout?.cancel();
            if (!cancelled && value is bool) controller.add(value);
          },
          onError: (_) {
            generation++;
            probeTimeout?.cancel();
            if (!cancelled && !controller.isClosed) controller.add(false);
          },
        );
        lifecycle = AppLifecycleListener(onResume: refresh);
      },
      onCancel: () async {
        cancelled = true;
        generation++;
        probeTimeout?.cancel();
        lifecycle?.dispose();
        await subscription?.cancel();
      },
    );
    return controller.stream.distinct();
  }
}

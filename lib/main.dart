import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/generated/app_localizations.dart';
import 'providers/providers.dart';
import 'providers/settings_provider.dart';
import 'router.dart';
import 'services/notification_service.dart';
import 'services/push_notification_service.dart';
import 'theme/app_theme.dart';
import 'widgets/mobile_viewport.dart';
import 'utils/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await NotificationService().initialize();
  } catch (error, stack) {
    Logger('Startup').warning('Local notifications unavailable', error, stack);
  }

  await PushNotificationService.instance.initialize();

  runApp(const ProviderScope(child: SigapApp()));
}

class SigapApp extends ConsumerStatefulWidget {
  const SigapApp({super.key});

  @override
  ConsumerState<SigapApp> createState() => _SigapAppState();
}

class _SigapAppState extends ConsumerState<SigapApp> {
  bool _settingsInitialized = false;
  String? _pushUserId;
  StreamSubscription<void>? _pushUpdates;

  @override
  void initState() {
    super.initState();
    _initSettings();
    _pushUpdates = PushNotificationService.instance.updates.stream.listen((_) {
      ref.invalidate(notificationsProvider);
      ref.invalidate(wargaReportsProvider);
    });
  }

  @override
  void dispose() {
    unawaited(_pushUpdates?.cancel());
    PushNotificationService.instance.onOpen = null;
    super.dispose();
  }

  Future<void> _initSettings() async {
    try {
      await Future.wait([
        ref.read(settingsProvider.notifier).init(),
        ref.read(authNotifierProvider.notifier).init(),
      ]);
    } catch (error, stack) {
      // Storage failures must not leave the app on a permanent loading screen.
      // Defaults remain usable and the login form can show subsequent errors.
      Logger(
        'Startup',
      ).warning('Saved session/settings unavailable', error, stack);
    }
    if (mounted) {
      setState(() => _settingsInitialized = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_settingsInitialized) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: SigapTheme.light(),
        home: const Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    final settings = ref.watch(settingsProvider);
    final userId = ref.watch(
      authNotifierProvider.select((auth) => auth.userId),
    );
    PushNotificationService.instance.onOpen = () {
      if (mounted) ref.read(appRouterProvider).go('/notifications');
    };
    if (_pushUserId != userId) {
      _pushUserId = userId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          unawaited(
            PushNotificationService.instance.syncSession(
              ref.read(apiClientProvider),
              userId,
            ),
          );
        }
      });
    }
    ref.watch(syncTelemetryProvider);
    NotificationService().locale = settings.locale;

    return MaterialApp.router(
      builder: (context, child) =>
          MobileViewport(child: child ?? const SizedBox.shrink()),
      title: 'SIGAP',
      theme: SigapTheme.light(),
      darkTheme: SigapTheme.dark(),
      themeMode: settings.themeMode,
      locale: settings.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: ref.watch(appRouterProvider),
      debugShowCheckedModeBanner: false,
    );
  }
}

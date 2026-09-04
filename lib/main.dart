import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'db/database.dart';
import 'l10n/generated/app_localizations.dart';
import 'providers/providers.dart';
import 'providers/settings_provider.dart';
import 'router.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService().initialize();

  final database = AppDatabase();

  runApp(
    ProviderScope(
      overrides: [databaseProvider.overrideWithValue(database)],
      child: SigapApp(database: database),
    ),
  );
}

class SigapApp extends ConsumerStatefulWidget {
  final AppDatabase database;

  const SigapApp({super.key, required this.database});

  @override
  ConsumerState<SigapApp> createState() => _SigapAppState();
}

class _SigapAppState extends ConsumerState<SigapApp> {
  bool _settingsInitialized = false;

  @override
  void initState() {
    super.initState();
    _initSettings();
  }

  Future<void> _initSettings() async {
    await ref.read(settingsProvider.notifier).init();
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

    return MaterialApp.router(
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
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'db/database.dart';
import 'providers/providers.dart';
import 'providers/settings_provider.dart';
import 'router.dart';
import 'services/notification_service.dart';
import 'sync/background_sync.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService().initialize();

  final database = AppDatabase();

  const storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  const accessTokenKey = 'access_token';
  final token = await storage.read(key: accessTokenKey);

  await initializeBackgroundSync(accessToken: token);

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

    ref.watch(syncInitProvider);

    return MaterialApp.router(
      title: 'SIGAP',
      theme: SigapTheme.light(),
      darkTheme: SigapTheme.light(),
      themeMode: settings.themeMode,
      locale: settings.locale,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}

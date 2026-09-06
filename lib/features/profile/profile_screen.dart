import 'package:sigap/theme/sigap_color_scheme.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sigap/l10n/generated/app_localizations.dart';
import 'package:sigap/providers/providers.dart';
import 'package:sigap/providers/settings_provider.dart';
import 'package:sigap/widgets/push_notification_settings.dart';
import 'package:sigap/widgets/design_system/mobile_title_bar.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authNotifierProvider);
    final name = auth.userName ?? 'Pengguna';
    final initials = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0])
        .join()
        .toUpperCase();
    final offline = ref.watch(offlineModeProvider);
    final checking = !ref.watch(connectivityProvider).hasValue;
    final settings = ref.watch(settingsProvider);
    return Scaffold(
      backgroundColor: SigapColorScheme.of(context).bgSurface,
      appBar: MobileTitleBar(
        title: AppLocalizations.of(context)!.mobileAccountDevice,
        subtitle: AppLocalizations.of(context)!.mobileUserContext,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          _card(
            context,
            Column(
              children: [
                SizedBox(height: 8),
                CircleAvatar(
                  radius: 32.5,
                  backgroundColor: SigapColorScheme.of(context).primaryLight,
                  foregroundColor: SigapColorScheme.of(context).primaryDark,
                  child: Text((initials), style: TextStyle(fontSize: 24)),
                ),
                SizedBox(height: 15),
                Text(
                  (name),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 7),
                Text(
                  (auth.userRole == 'WARGA'
                      ? AppLocalizations.of(context)!.mobileResident
                      : auth.userRole == 'PETUGAS'
                      ? AppLocalizations.of(context)!.mobileSurveyor
                      : AppLocalizations.of(context)!.mobileAdministrator),
                  style: TextStyle(
                    fontSize: 12,
                    color: SigapColorScheme.of(context).textTertiary,
                  ),
                ),
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: SigapColorScheme.of(context).primaryLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.mobileAuthenticatedAccount,
                    style: TextStyle(
                      fontSize: 10,
                      color: SigapColorScheme.of(context).primaryDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 18),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: Text(AppLocalizations.of(context)!.notifikasi),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/notifications'),
          ),
          SizedBox(height: 18),
          _card(
            context,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.mobileConnectionStatus,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 10),
                Text(
                  AppLocalizations.of(
                    context,
                  )!.mobileSaveReportsOnThisDeviceWhileDisconnected,
                  style: TextStyle(
                    fontSize: 12,
                    color: SigapColorScheme.of(context).textTertiary,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  (checking
                      ? AppLocalizations.of(context)!.mobileCheckingConnection
                      : offline
                      ? AppLocalizations.of(context)!.mobileNoInternetAccess
                      : AppLocalizations.of(context)!.mobileInternetConnected),
                ),
              ],
            ),
          ),
          SizedBox(height: 18),
          _card(
            context,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.mobileAppearanceLanguage,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<ThemeMode>(
                  key: ValueKey(settings.themeMode),
                  initialValue: settings.themeMode,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.mobileTheme,
                  ),
                  items: ThemeMode.values
                      .map(
                        (mode) => DropdownMenuItem(
                          value: mode,
                          child: Text(
                            (mode == ThemeMode.system
                                ? AppLocalizations.of(
                                    context,
                                  )!.mobileSystemDefault
                                : mode == ThemeMode.dark
                                ? AppLocalizations.of(context)!.mobileDark
                                : AppLocalizations.of(context)!.mobileLight),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (mode) {
                    if (mode != null) {
                      ref.read(settingsProvider.notifier).setThemeMode(mode);
                    }
                  },
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  key: ValueKey(settings.locale.languageCode),
                  initialValue: settings.locale.languageCode,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.mobileLanguage,
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'id',
                      child: Text(
                        'Bahasa Indonesia',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'en',
                      child: Text(
                        'English',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  onChanged: (language) {
                    if (language != null) {
                      ref
                          .read(settingsProvider.notifier)
                          .setLocale(Locale(language));
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const PushNotificationSettings(),
          const SizedBox(height: 18),
          OutlinedButton(
            onPressed: () async =>
                ref.read(authNotifierProvider.notifier).logout(),
            child: Text(AppLocalizations.of(context)!.mobileSignOut),
          ),
          SizedBox(height: 18),
          Text(
            ('SIGAP / PantauDesa · KMIPN 2026'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: SigapColorScheme.of(context).textMuted,
              height: 1.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(BuildContext context, Widget child) => Container(
    padding: EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: SigapColorScheme.of(context).surface,
      border: Border.all(color: SigapColorScheme.of(context).border),
      borderRadius: BorderRadius.circular(12),
    ),
    child: child,
  );
}

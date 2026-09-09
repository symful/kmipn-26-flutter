import 'package:sigap/theme/sigap_color_scheme.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sigap/api/client.dart';
import 'package:sigap/l10n/generated/app_localizations.dart';
import 'package:sigap/providers/providers.dart';
import 'package:sigap/providers/settings_provider.dart';
import 'package:sigap/widgets/push_notification_settings.dart';
import 'package:sigap/widgets/design_system/mobile_title_bar.dart';
import 'package:sigap/widgets/request_error_details.dart';

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
          const _GamificationSection(),
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

class _GamificationSection extends ConsumerStatefulWidget {
  const _GamificationSection();

  @override
  ConsumerState<_GamificationSection> createState() =>
      _GamificationSectionState();
}

class _GamificationSectionState extends ConsumerState<_GamificationSection> {
  bool _toggling = false;

  static const _badgeLabels = <String, String>{
    'first_accepted': 'Kontribusi Valid Pertama',
    'active_contributor': 'Kontributor Aktif',
    'evidence_strength': 'Penguat Bukti',
    'condition_updater': 'Pemutakhir Kondisi',
    'high_reliability': 'Reliabilitas Tinggi',
  };

  String _badgeLabel(String key) =>
      _badgeLabels[key] ??
      key
          .replaceAll('_', ' ')
          .split(' ')
          .map((w) => w[0].toUpperCase() + w.substring(1))
          .join(' ');

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = SigapColorScheme.of(context);
    final gamificationAsync = ref.watch(gamificationProvider);

    return _card(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.gamificationSectionTitle,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          gamificationAsync.when(
            loading: () => SizedBox(
              height: 60,
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: colors.primary,
                  ),
                ),
              ),
            ),
            error: (e, _) => SizedBox(
              height: 60,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.gamificationLoadError,
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.textTertiary,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => ref.invalidate(gamificationProvider),
                    child: Text(l10n.cobaLagi),
                  ),
                ],
              ),
            ),
            data: (profile) => _buildData(l10n, colors, profile),
          ),
        ],
      ),
    );
  }

  Widget _buildData(
    AppLocalizations l10n,
    SigapColorScheme colors,
    GamificationProfile profile,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${profile.xp ?? 0}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: colors.primary,
                    ),
                  ),
                  Text(
                    l10n.gamificationXpLabel,
                    style: TextStyle(fontSize: 11, color: colors.textTertiary),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${profile.level ?? 1}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: colors.primary,
                    ),
                  ),
                  Text(
                    l10n.gamificationLevelLabel,
                    style: TextStyle(fontSize: 11, color: colors.textTertiary),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildReputation(l10n, colors, profile),
        const SizedBox(height: 12),
        _buildCounts(l10n, colors, profile),
        const SizedBox(height: 12),
        _buildBadges(l10n, colors, profile),
        const SizedBox(height: 8),
        _buildLeaderboardToggle(l10n, colors, profile),
      ],
    );
  }

  Widget _buildReputation(
    AppLocalizations l10n,
    SigapColorScheme colors,
    GamificationProfile profile,
  ) {
    final rep = profile.reputation;
    if (rep == null || (rep.total ?? 0) < 5) {
      return Text(
        l10n.gamificationReputationUnavailable,
        style: TextStyle(fontSize: 12, color: colors.textTertiary),
      );
    }
    final pct = ((rep.value ?? 0) * 100).toStringAsFixed(0);
    return Text(
      l10n.gamificationReputationValue(pct, rep.accepted ?? 0, rep.total ?? 0),
      style: TextStyle(fontSize: 12, color: colors.textSecondary),
    );
  }

  Widget _buildCounts(
    AppLocalizations l10n,
    SigapColorScheme colors,
    GamificationProfile profile,
  ) {
    final cc = profile.contributionCounts;
    final items = [
      (l10n.gamificationCountNewReport, cc?.newReportAccepted ?? 0),
      (l10n.gamificationCountCorroboration, cc?.corroborationAccepted ?? 0),
      (l10n.gamificationCountStatusChange, cc?.statusChangingAccepted ?? 0),
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: items.map((item) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: colors.primaryLight,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            '${item.$1}: ${item.$2}',
            style: TextStyle(
              fontSize: 11,
              color: colors.primaryDark,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBadges(
    AppLocalizations l10n,
    SigapColorScheme colors,
    GamificationProfile profile,
  ) {
    if (profile.badges.isEmpty) {
      return Text(
        l10n.gamificationBadgesEmpty,
        style: TextStyle(fontSize: 12, color: colors.textTertiary),
      );
    }
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: profile.badges.map((badge) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: colors.primaryLight,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.emoji_events_outlined,
                size: 14,
                color: colors.primary,
              ),
              const SizedBox(width: 4),
              Text(
                _badgeLabel(badge.badgeKey ?? ''),
                style: TextStyle(
                  fontSize: 11,
                  color: colors.primaryDark,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLeaderboardToggle(
    AppLocalizations l10n,
    SigapColorScheme colors,
    GamificationProfile profile,
  ) {
    return SwitchListTile(
      title: Text(
        l10n.gamificationLeaderboardOptInTitle,
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        l10n.gamificationLeaderboardOptInSubtitle,
        style: TextStyle(fontSize: 11, color: colors.textTertiary),
      ),
      value: profile.leaderboardOptIn ?? false,
      contentPadding: EdgeInsets.zero,
      activeThumbColor: colors.primary,
      activeTrackColor: colors.primary,
      onChanged: _toggling
          ? null
          : (v) async {
              setState(() => _toggling = true);
              try {
                final api = ref.read(apiClientProvider);
                await api.setGamificationOptIn(optIn: v);
                ref.invalidate(gamificationProvider);
              } catch (e) {
                if (mounted) showRequestFailure(context, e);
                ref.invalidate(gamificationProvider);
              } finally {
                if (mounted) setState(() => _toggling = false);
              }
            },
    );
  }
}

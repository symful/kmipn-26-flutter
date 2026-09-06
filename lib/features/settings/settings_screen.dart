import 'package:sigap/providers/providers.dart'
    show connectivityProvider, offlineModeProvider;
import 'package:sigap/theme/sigap_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sigap/l10n/generated/app_localizations.dart';
import 'package:sigap/providers/auth_provider.dart';
import 'package:sigap/theme/tokens.dart';
import 'package:sigap/widgets/design_system/authenticated_shell.dart';
import 'package:sigap/widgets/design_system/section_label.dart';
import 'package:sigap/widgets/design_system/sigap_app_bar.dart';
import 'package:sigap/widgets/design_system/sigap_card.dart';
import 'package:sigap/providers/settings_provider.dart';
import 'package:sigap/widgets/push_notification_settings.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeRole = ref.watch(authNotifierProvider).userRole ?? '';

    return AuthenticatedShell(
      activeRole: activeRole,
      backgroundColor: SigapColorScheme.of(context).bgScreen,
      appBar: SigapAppBar(title: AppLocalizations.of(context)!.pengaturan),
      body: ListView(
        padding: const EdgeInsets.all(SigapSpacing.lg),
        children: [
          SectionLabel(
            label: AppLocalizations.of(context)!.sectionTampilanTema,
          ),
          const _ThemeToggle(),
          SizedBox(height: SigapSpacing.lg),
          SectionLabel(
            label: AppLocalizations.of(context)!.sectionBahasaLokalisasi,
          ),
          const _LanguageSelector(),
          SizedBox(height: SigapSpacing.lg),
          const PushNotificationSettings(),
          SizedBox(height: SigapSpacing.xl),
          SectionLabel(
            label: AppLocalizations.of(context)!.sectionInformasiAplikasi,
          ),
          const _AppInfoCard(),
        ],
      ),
    );
  }
}

class _ThemeToggle extends ConsumerWidget {
  const _ThemeToggle();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final isDark = settings.themeMode == ThemeMode.dark;

    return Container(
      decoration: BoxDecoration(
        color: SigapColorScheme.of(context).surface,
        borderRadius: BorderRadius.circular(SigapRadius.md),
        border: Border.all(color: SigapColorScheme.of(context).border),
      ),
      child: SwitchListTile(
        secondary: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: SigapColorScheme.of(context).primaryLight,
            borderRadius: BorderRadius.circular(SigapRadius.sm),
          ),
          child: Icon(
            isDark ? Icons.dark_mode : Icons.light_mode,
            size: 20,
            color: SigapColorScheme.of(context).primary,
          ),
        ),
        title: Text(
          AppLocalizations.of(context)!.modeGelap,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: SigapTypography.bodyMedium,
            color: SigapColorScheme.of(context).textPrimary,
          ),
        ),
        subtitle: Text(
          AppLocalizations.of(context)!.modeGelapSubtitle,
          style: TextStyle(
            fontSize: SigapTypography.bodySmall,
            color: SigapColorScheme.of(context).textSecondary,
          ),
        ),
        value: isDark,
        activeThumbColor: SigapColorScheme.of(context).primary,
        onChanged: (value) {
          ref.read(settingsProvider.notifier).setDarkMode(value);
        },
      ),
    );
  }
}

class _LanguageSelector extends ConsumerWidget {
  const _LanguageSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final currentLocale = settings.locale;
    final l10n = AppLocalizations.of(context)!;
    final displayName = currentLocale.languageCode == 'id'
        ? l10n.bahasaIndonesiaLabel
        : l10n.englishUs;

    return Container(
      decoration: BoxDecoration(
        color: SigapColorScheme.of(context).surface,
        borderRadius: BorderRadius.circular(SigapRadius.md),
        border: Border.all(color: SigapColorScheme.of(context).border),
      ),
      child: ListTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: SigapColorScheme.of(context).primaryLight,
            borderRadius: BorderRadius.circular(SigapRadius.sm),
          ),
          child: Icon(
            Icons.language,
            size: 20,
            color: SigapColorScheme.of(context).primary,
          ),
        ),
        title: Text(
          AppLocalizations.of(context)!.bahasaAplikasi,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: SigapTypography.bodyMedium,
            color: SigapColorScheme.of(context).textPrimary,
          ),
        ),
        subtitle: Text(
          displayName,
          style: TextStyle(
            fontSize: SigapTypography.bodySmall,
            color: SigapColorScheme.of(context).textSecondary,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: SigapColorScheme.of(context).textMuted,
        ),
        onTap: () {
          _showLanguageDialog(context, ref);
        },
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    final settings = ref.read(settingsProvider);
    String selectedValue = settings.locale.languageCode;

    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(SigapRadius.lg),
            ),
            backgroundColor: SigapColorScheme.of(context).surface,
            title: Row(
              children: [
                Icon(
                  Icons.language,
                  color: SigapColorScheme.of(context).primary,
                ),
                SizedBox(width: SigapSpacing.sm),
                Text(
                  AppLocalizations.of(context)!.pilihBahasa,
                  style: TextStyle(
                    fontSize: SigapTypography.bodyLarge,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioGroup<String>(
                  groupValue: selectedValue,
                  onChanged: (value) {
                    setDialogState(
                      () => selectedValue = value ?? selectedValue,
                    );
                  },
                  child: Column(
                    children: [
                      ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(SigapRadius.md),
                        ),
                        title: Text(
                          AppLocalizations.of(context)!.bahasaIndonesiaLabel,
                          style: TextStyle(
                            fontSize: SigapTypography.bodyMedium,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        leading: Radio<String>(
                          value: 'id',
                          activeColor: SigapColorScheme.of(context).primary,
                        ),
                        onTap: () {
                          setDialogState(() => selectedValue = 'id');
                        },
                      ),
                      ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(SigapRadius.md),
                        ),
                        title: Text(
                          AppLocalizations.of(context)!.english,
                          style: TextStyle(
                            fontSize: SigapTypography.bodyMedium,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        leading: Radio<String>(
                          value: 'en',
                          activeColor: SigapColorScheme.of(context).primary,
                        ),
                        onTap: () {
                          setDialogState(() => selectedValue = 'en');
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(
                  AppLocalizations.of(context)!.batal,
                  style: TextStyle(
                    color: SigapColorScheme.of(context).textSecondary,
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: SigapColorScheme.of(context).primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(SigapRadius.sm),
                  ),
                ),
                onPressed: () {
                  final locale = selectedValue == 'id'
                      ? const Locale('id')
                      : const Locale('en');
                  ref.read(settingsProvider.notifier).setLocale(locale);
                  Navigator.pop(dialogContext);
                },
                child: Text(AppLocalizations.of(context)!.simpan),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AppInfoCard extends ConsumerWidget {
  const _AppInfoCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checking = !ref.watch(connectivityProvider).hasValue;
    final offline = ref.watch(offlineModeProvider);
    final connectionLabel = checking
        ? AppLocalizations.of(context)!.mobileCheckingConnection
        : offline
        ? AppLocalizations.of(context)!.mobileNoInternetAccess
        : AppLocalizations.of(context)!.mobileInternetConnected;
    final connectionColor = offline || checking
        ? SigapColorScheme.of(context).textMuted
        : SigapColorScheme.of(context).primary;
    return SigapCard(
      padding: const EdgeInsets.all(SigapSpacing.md),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: SigapColorScheme.of(context).primaryLight,
                  borderRadius: BorderRadius.circular(SigapRadius.sm),
                ),
                child: Icon(
                  Icons.shield_outlined,
                  color: SigapColorScheme.of(context).primary,
                  size: 22,
                ),
              ),
              SizedBox(width: SigapSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.sigapMobile,
                      style: TextStyle(
                        fontSize: SigapTypography.bodyMedium,
                        fontWeight: FontWeight.bold,
                        color: SigapColorScheme.of(context).textPrimary,
                      ),
                    ),
                    Text(
                      AppLocalizations.of(context)!.sistemInformasiGerakAduan,
                      style: TextStyle(
                        fontSize: SigapTypography.captionMedium,
                        color: SigapColorScheme.of(context).textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: SigapSpacing.sm),
          Divider(height: 1, color: SigapColorScheme.of(context).border),
          SizedBox(height: SigapSpacing.sm),
          Text(AppLocalizations.of(context)!.mobileConnectionStatus),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.circle, size: 8, color: connectionColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  connectionLabel,
                  style: TextStyle(color: connectionColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

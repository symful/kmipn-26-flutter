import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../theme/tokens.dart';
import '../../widgets/design_system/authenticated_shell.dart';
import '../../widgets/design_system/section_label.dart';
import '../../widgets/design_system/sigap_app_bar.dart';
import '../../widgets/design_system/sigap_card.dart';
import '../../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeRole = ref.watch(authNotifierProvider).activeRole ?? '';

    return AuthenticatedShell(
      activeRole: activeRole,
      backgroundColor: SigapColors.bgScreen,
      appBar: SigapAppBar(title: AppLocalizations.of(context)!.pengaturan),
      body: ListView(
        padding: const EdgeInsets.all(SigapSpacing.lg),
        children: [
          SectionLabel(
            label: AppLocalizations.of(context)!.sectionTampilanTema,
          ),
          const _ThemeToggle(),
          const SizedBox(height: SigapSpacing.lg),
          SectionLabel(
            label: AppLocalizations.of(context)!.sectionBahasaLokalisasi,
          ),
          const _LanguageSelector(),
          const SizedBox(height: SigapSpacing.xl),
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
        color: SigapColors.surface,
        borderRadius: BorderRadius.circular(SigapRadius.md),
        border: Border.all(color: SigapColors.border),
      ),
      child: SwitchListTile(
        secondary: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: SigapColors.primaryLight,
            borderRadius: BorderRadius.circular(SigapRadius.sm),
          ),
          child: Icon(
            isDark ? Icons.dark_mode : Icons.light_mode,
            size: 20,
            color: SigapColors.primary,
          ),
        ),
        title: Text(
          AppLocalizations.of(context)!.modeGelap,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: SigapTypography.bodyMedium,
            color: SigapColors.textPrimary,
          ),
        ),
        subtitle: Text(
          AppLocalizations.of(context)!.modeGelapSubtitle,
          style: const TextStyle(
            fontSize: SigapTypography.bodySmall,
            color: SigapColors.textSecondary,
          ),
        ),
        value: isDark,
        activeThumbColor: SigapColors.primary,
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
        color: SigapColors.surface,
        borderRadius: BorderRadius.circular(SigapRadius.md),
        border: Border.all(color: SigapColors.border),
      ),
      child: ListTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: SigapColors.primaryLight,
            borderRadius: BorderRadius.circular(SigapRadius.sm),
          ),
          child: const Icon(
            Icons.language,
            size: 20,
            color: SigapColors.primary,
          ),
        ),
        title: Text(
          AppLocalizations.of(context)!.bahasaAplikasi,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: SigapTypography.bodyMedium,
            color: SigapColors.textPrimary,
          ),
        ),
        subtitle: Text(
          displayName,
          style: const TextStyle(
            fontSize: SigapTypography.bodySmall,
            color: SigapColors.textSecondary,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: SigapColors.textMuted),
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
            backgroundColor: SigapColors.surface,
            title: Row(
              children: [
                Icon(Icons.language, color: SigapColors.primary),
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
                          style: const TextStyle(
                            fontSize: SigapTypography.bodyMedium,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        leading: Radio<String>(
                          value: 'id',
                          activeColor: SigapColors.primary,
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
                          style: const TextStyle(
                            fontSize: SigapTypography.bodyMedium,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        leading: Radio<String>(
                          value: 'en',
                          activeColor: SigapColors.primary,
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
                  style: const TextStyle(color: SigapColors.textSecondary),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: SigapColors.primary,
                  foregroundColor: SigapColors.surface,
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

class _AppInfoCard extends StatelessWidget {
  const _AppInfoCard();

  @override
  Widget build(BuildContext context) {
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
                  color: SigapColors.primaryLight,
                  borderRadius: BorderRadius.circular(SigapRadius.sm),
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  color: SigapColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: SigapSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.sigapMobile,
                      style: TextStyle(
                        fontSize: SigapTypography.bodyMedium,
                        fontWeight: FontWeight.bold,
                        color: SigapColors.textPrimary,
                      ),
                    ),
                    Text(
                      AppLocalizations.of(context)!.sistemInformasiGerakAduan,
                      style: TextStyle(
                        fontSize: SigapTypography.captionMedium,
                        color: SigapColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: SigapSpacing.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: SigapColors.bgSurface,
                  borderRadius: BorderRadius.circular(SigapRadius.pill),
                  border: Border.all(color: SigapColors.border),
                ),
                child: Text(
                  AppLocalizations.of(context)!.versiAplikasi,
                  style: const TextStyle(
                    fontSize: SigapTypography.captionMedium,
                    fontWeight: FontWeight.bold,
                    color: SigapColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: SigapSpacing.sm),
          const Divider(height: 1, color: SigapColors.border),
          const SizedBox(height: SigapSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.statusServer,
                style: TextStyle(
                  fontSize: SigapTypography.bodySmall,
                  color: SigapColors.textSecondary,
                ),
              ),
              Row(
                children: [
                  Icon(Icons.circle, size: 8, color: SigapColors.selesai),
                  SizedBox(width: 4),
                  Text(
                    AppLocalizations.of(context)!.onlineTersambung,
                    style: TextStyle(
                      fontSize: SigapTypography.bodySmall,
                      fontWeight: FontWeight.w500,
                      color: SigapColors.selesai,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

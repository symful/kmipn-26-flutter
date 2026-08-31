import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/strings.dart';
import '../../theme/tokens.dart';
import '../../widgets/design_system/section_label.dart';
import '../../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: SigapColors.bgScreen,
      appBar: AppBar(title: const Text('Pengaturan')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(SigapSpacing.lg),
          children: const [
            SectionLabel(label: 'Tampilan & Tema'),
            _ThemeToggle(),
            SizedBox(height: SigapSpacing.lg),
            SectionLabel(label: 'Bahasa & Lokalisasi'),
            _LanguageSelector(),
            SizedBox(height: SigapSpacing.xl),
            SectionLabel(label: 'Informasi Aplikasi'),
            _AppInfoCard(),
          ],
        ),
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
        title: const Text(
          'Mode Gelap',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: SigapTypography.size14,
            color: SigapColors.textPrimary,
          ),
        ),
        subtitle: const Text(
          'Aktifkan tema gelap untuk kenyamanan mata di malam hari',
          style: TextStyle(
            fontSize: SigapTypography.size12,
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
    final displayName = currentLocale.languageCode == 'id'
        ? 'Bahasa Indonesia'
        : 'English (US)';

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
        title: const Text(
          'Bahasa Aplikasi',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: SigapTypography.size14,
            color: SigapColors.textPrimary,
          ),
        ),
        subtitle: Text(
          displayName,
          style: const TextStyle(
            fontSize: SigapTypography.size12,
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
            title: const Row(
              children: [
                Icon(Icons.language, color: SigapColors.primary),
                SizedBox(width: SigapSpacing.sm),
                Text(
                  'Pilih Bahasa',
                  style: TextStyle(
                    fontSize: SigapTypography.size16,
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
                        title: const Text(
                          'Bahasa Indonesia',
                          style: TextStyle(
                            fontSize: SigapTypography.size14,
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
                        title: const Text(
                          'English',
                          style: TextStyle(
                            fontSize: SigapTypography.size14,
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
                child: const Text(
                  Strings.batal,
                  style: TextStyle(color: SigapColors.textSecondary),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: SigapColors.primary,
                  foregroundColor: Colors.white,
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
                child: const Text('Simpan'),
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
    return Container(
      padding: const EdgeInsets.all(SigapSpacing.md),
      decoration: BoxDecoration(
        color: SigapColors.surface,
        borderRadius: BorderRadius.circular(SigapRadius.md),
        border: Border.all(color: SigapColors.border),
      ),
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
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SIGAP Mobile',
                      style: TextStyle(
                        fontSize: SigapTypography.size14,
                        fontWeight: FontWeight.bold,
                        color: SigapColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Sistem Informasi & Gerak Aduan Publik',
                      style: TextStyle(
                        fontSize: SigapTypography.size11,
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
                child: const Text(
                  'v1.0.0',
                  style: TextStyle(
                    fontSize: SigapTypography.size11,
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
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Status Server',
                style: TextStyle(
                  fontSize: SigapTypography.size12,
                  color: SigapColors.textSecondary,
                ),
              ),
              Row(
                children: [
                  Icon(Icons.circle, size: 8, color: SigapColors.selesai),
                  SizedBox(width: 4),
                  Text(
                    'Online (Tersambung)',
                    style: TextStyle(
                      fontSize: SigapTypography.size12,
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

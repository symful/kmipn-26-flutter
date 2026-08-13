import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/tokens.dart';
import '../../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(SigapSpacing.lg),
          children: const [
            _SectionHeader(title: 'Tampilan'),
            _ThemeToggle(),
            SizedBox(height: SigapSpacing.lg),
            _SectionHeader(title: 'Bahasa'),
            _LanguageSelector(),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: SigapSpacing.sm),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: SigapColors.textSecondary,
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
        title: const Text('Mode Gelap'),
        subtitle: const Text('Aktifkan tema gelap untuk aplikasi'),
        value: isDark,
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
        ? 'Indonesia'
        : 'English';

    return Container(
      decoration: BoxDecoration(
        color: SigapColors.surface,
        borderRadius: BorderRadius.circular(SigapRadius.md),
        border: Border.all(color: SigapColors.border),
      ),
      child: ListTile(
        title: const Text('Bahasa'),
        subtitle: Text(displayName),
        trailing: const Icon(Icons.chevron_right),
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
            title: const Text('Pilih Bahasa'),
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
                        title: const Text('Indonesia'),
                        leading: Radio<String>(value: 'id'),
                        onTap: () {
                          setDialogState(() => selectedValue = 'id');
                        },
                      ),
                      ListTile(
                        title: const Text('English'),
                        leading: Radio<String>(value: 'en'),
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
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () {
                  final locale = selectedValue == 'id'
                      ? const Locale('id')
                      : const Locale('en');
                  ref.read(settingsProvider.notifier).setLocale(locale);
                  Navigator.pop(dialogContext);
                },
                child: const Text('Pilih'),
              ),
            ],
          );
        },
      ),
    );
  }
}

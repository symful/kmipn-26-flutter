import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'auth_provider.dart';

// ─── Storage Keys ───────────────────────────────────────────────────────────
const _darkModeKey = 'dark_mode';
const _localeKey = 'locale';

// ─── Settings State ─────────────────────────────────────────────────────────
class SettingsState {
  final ThemeMode themeMode;
  final Locale locale;

  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.locale = const Locale('id'),
  });

  SettingsState copyWith({ThemeMode? themeMode, Locale? locale}) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
    );
  }
}

// ─── Settings Notifier ──────────────────────────────────────────────────────
class SettingsNotifier extends StateNotifier<SettingsState> {
  final FlutterSecureStorage _storage;

  SettingsNotifier(this._storage) : super(const SettingsState());

  Future<void> init() async {
    // Load dark mode
    final darkModeStr = await _storage.read(key: _darkModeKey);
    final isDark = darkModeStr == 'true';

    // Load locale
    final localeStr = await _storage.read(key: _localeKey);
    final locale = localeStr != null && localeStr.isNotEmpty
        ? _parseLocale(localeStr)
        : const Locale('id');

    state = SettingsState(
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      locale: locale,
    );
  }

  Locale _parseLocale(String str) {
    // Handle formats like "id_ID", "id", "en_US", "en"
    final parts = str.split('_');
    if (parts.length >= 2) {
      return Locale(parts[0], parts[1]);
    }
    return Locale(parts[0]);
  }

  Future<void> setDarkMode(bool isDark) async {
    await _storage.write(key: _darkModeKey, value: isDark.toString());
    state = state.copyWith(
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
    );
  }

  Future<void> setLocale(Locale locale) async {
    final localeStr = locale.countryCode != null
        ? '${locale.languageCode}_${locale.countryCode}'
        : locale.languageCode;
    await _storage.write(key: _localeKey, value: localeStr);
    state = state.copyWith(locale: locale);
  }
}

// ─── Provider ───────────────────────────────────────────────────────────────
final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) {
    final storage = ref.watch(secureStorageProvider);
    return SettingsNotifier(storage);
  },
);

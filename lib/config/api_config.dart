import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    const configured = String.fromEnvironment('API_BASE_URL');
    if (configured.isNotEmpty) {
      return configured.replaceFirst(RegExp(r'/$'), '');
    }
    // Android emulators reach the development computer through this address.
    // Physical devices require API_BASE_URL pointing to its LAN address or HTTPS deployment.
    return !kIsWeb && defaultTargetPlatform == TargetPlatform.android
        ? 'http://10.0.2.2:8787'
        : 'http://localhost:8787';
  }
}

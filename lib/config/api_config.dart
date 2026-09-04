class ApiConfig {
  static String get baseUrl => const String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8787',
  );
}

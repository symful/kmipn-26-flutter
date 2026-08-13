class ApiConfig {
  static String get baseUrl => const String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://sigap.live',
  );
}

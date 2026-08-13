import 'dart:developer' as developer;

/// Production-safe logger using dart:developer.log()
///
/// Unlike debugPrint, this works in release builds and production.
class Logger {
  final String name;

  const Logger(this.name);

  /// Log debug-level message (dev only, stripped in release if desired)
  void debug(String message, [Object? error, StackTrace? stackTrace]) {
    _log('DEBUG', message, error: error, stackTrace: stackTrace);
  }

  /// Log info-level message
  void info(String message, [Object? error, StackTrace? stackTrace]) {
    _log('INFO', message, error: error, stackTrace: stackTrace);
  }

  /// Log warning-level message
  void warning(String message, [Object? error, StackTrace? stackTrace]) {
    _log('WARNING', message, error: error, stackTrace: stackTrace);
  }

  /// Log error-level message
  void error(String message, [Object? error, StackTrace? stackTrace]) {
    _log('ERROR', message, error: error, stackTrace: stackTrace);
  }

  void _log(
    String level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      '[$level][$name] $message',
      error: error,
      stackTrace: stackTrace,
      name: name,
    );
  }
}

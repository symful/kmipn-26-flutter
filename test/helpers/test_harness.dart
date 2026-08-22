import 'dart:math';

/// Cooldown between test suites to avoid rate limiting.
Future<void> testCooldown({int seconds = 5}) async {
  await Future.delayed(Duration(seconds: seconds));
}

/// Retries a function with jittered exponential backoff on 429 errors.
Future<T> withRetry<T>(Future<T> Function() fn, {int maxRetries = 5}) async {
  int attempt = 0;
  while (true) {
    try {
      return await fn();
    } catch (e) {
      if (attempt >= maxRetries) rethrow;
      final msg = e.toString();
      if (msg.contains('429') && attempt < maxRetries) {
        attempt++;
        final delay = (1000 * pow(2, attempt) + Random().nextInt(1000)).toInt();
        await Future.delayed(Duration(milliseconds: delay));
        continue;
      }
      rethrow;
    }
  }
}

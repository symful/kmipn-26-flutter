/// Cooldown between test suites to avoid rate limiting.
Future<void> testCooldown({int seconds = 5}) async {
  await Future.delayed(Duration(seconds: seconds));
}

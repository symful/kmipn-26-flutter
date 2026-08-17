import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'auth_provider.dart';

/// Provider that checks if onboarding has been completed.
/// Reads the onboarding_complete flag from FlutterSecureStorage.
final onboardingCompleteProvider = FutureProvider<bool>((ref) async {
  final storage = ref.watch(secureStorageProvider);
  final value = await storage.read(key: 'onboarding_complete');
  return value == 'true';
});

/// Notifier for managing onboarding state.
class OnboardingNotifier extends StateNotifier<bool> {
  final FlutterSecureStorage _storage;

  OnboardingNotifier(this._storage) : super(false);

  Future<void> completeOnboarding() async {
    await _storage.write(key: 'onboarding_complete', value: 'true');
    state = true;
  }

  Future<void> resetOnboarding() async {
    await _storage.delete(key: 'onboarding_complete');
    state = false;
  }
}

final onboardingNotifierProvider =
    StateNotifierProvider<OnboardingNotifier, bool>((ref) {
      final storage = ref.watch(secureStorageProvider);
      return OnboardingNotifier(storage);
    });

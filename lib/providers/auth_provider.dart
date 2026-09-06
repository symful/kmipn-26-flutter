import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/client.dart';
import '../api/exceptions.dart';
import '../utils/logger.dart';
import '../core/roles.dart';
import '../services/push_notification_service.dart';

class AuthState {
  final String? accessToken;
  final String? refreshToken;
  final String? userId;
  final String? userRole;
  final String? userEmail;
  final String? userName;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.accessToken,
    this.refreshToken,
    this.userId,
    this.userRole,
    this.userEmail,
    this.userName,
    this.isLoading = false,
    this.error,
  });

  bool get isAuthenticated => accessToken != null;
  String? get activeRole => userRole;

  AuthState copyWith({
    String? accessToken,
    String? refreshToken,
    String? userId,
    String? userRole,
    String? userEmail,
    String? userName,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      userId: userId ?? this.userId,
      userRole: userRole ?? this.userRole,
      userEmail: userEmail ?? this.userEmail,
      userName: userName ?? this.userName,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiClient _client;
  final FlutterSecureStorage _storage;

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userIdKey = 'user_id';
  static const _userRoleKey = 'user_role';
  static const _userEmailKey = 'user_email';
  static const _userNameKey = 'user_name';
  static final _logger = Logger('AuthNotifier');

  AuthNotifier(this._client, this._storage) : super(const AuthState());

  Future<void> init() async {
    final accessToken = await _storage.read(key: _accessTokenKey);
    final refreshToken = await _storage.read(key: _refreshTokenKey);
    final userId = await _storage.read(key: _userIdKey);
    final userRole = await _storage.read(key: _userRoleKey);
    final userEmail = await _storage.read(key: _userEmailKey);
    final userName = await _storage.read(key: _userNameKey);

    if (accessToken != null) {
      if (!mobileRoles.contains(userRole)) {
        await _clearSavedSession();
        state = const AuthState(
          error:
              'Aplikasi seluler hanya untuk Warga dan Petugas. Admin menggunakan aplikasi web.',
        );
        return;
      }
      state = AuthState(
        accessToken: accessToken,
        refreshToken: refreshToken,
        userId: userId,
        userRole: userRole,
        userEmail: userEmail,
        userName: userName,
      );
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final loginResponse = await _client.login(email, password);
      final accessToken = loginResponse.token;
      final refreshToken = loginResponse.refreshToken;
      final user = loginResponse.user;

      if (accessToken == null || user == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'Login failed: invalid response',
        );
        return false;
      }
      if (!mobileRoles.contains(user.role)) {
        await _clearSavedSession();
        state = const AuthState(
          error:
              'Aplikasi seluler hanya untuk Warga dan Petugas. Admin menggunakan aplikasi web.',
        );
        return false;
      }

      await _storage.write(key: _accessTokenKey, value: accessToken);
      await _storage.write(key: _refreshTokenKey, value: refreshToken);

      final userId = user.id;
      final userRole = user.role;
      final userEmail = user.email;
      final userName = user.name;

      await _storage.write(key: _userIdKey, value: userId);
      await _storage.write(key: _userRoleKey, value: userRole);
      await _storage.write(key: _userEmailKey, value: userEmail);
      await _storage.write(key: _userNameKey, value: userName);

      state = AuthState(
        accessToken: accessToken,
        refreshToken: refreshToken,
        userId: userId,
        userRole: userRole,
        userEmail: userEmail,
        userName: userName,
      );

      return true;
    } catch (e) {
      final detail = extractErrorMessage(e);
      state = state.copyWith(isLoading: false, error: detail);
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await PushNotificationService.instance.logout(_client);
    } catch (_) {
      _logger.warning('Push deregistration unavailable during logout');
    }
    try {
      final refreshToken = await _storage.read(key: _refreshTokenKey);
      if (refreshToken != null) {
        await _client.logout(refreshToken);
      }
    } catch (e, st) {
      _logger.warning('logout failed', e, st);
    }
    await _clearSavedSession();
    state = const AuthState();
  }

  Future<void> _clearSavedSession() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _userIdKey);
    await _storage.delete(key: _userRoleKey);
    await _storage.delete(key: _userEmailKey);
    await _storage.delete(key: _userNameKey);
  }

  String? get accessToken => state.accessToken;
  String? get refreshToken => state.refreshToken;
}

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
});

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((
  ref,
) {
  final storage = ref.watch(secureStorageProvider);
  final client = ApiClient(storage: storage);
  return AuthNotifier(client, storage);
});

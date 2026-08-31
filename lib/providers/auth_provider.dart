import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/client.dart';
import '../api/exceptions.dart';
import '../utils/logger.dart';
import 'capability_provider.dart';

class AuthState {
  final String? accessToken;
  final String? refreshToken;
  final String? userId;
  final String? userRole;
  final String? activeRole;
  final String? userEmail;
  final String? userName;
  final List<String> roles;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.accessToken,
    this.refreshToken,
    this.userId,
    this.userRole,
    this.activeRole,
    this.userEmail,
    this.userName,
    this.roles = const [],
    this.isLoading = false,
    this.error,
  });

  bool get isAuthenticated => accessToken != null;

  AuthState copyWith({
    String? accessToken,
    String? refreshToken,
    String? userId,
    String? userRole,
    String? activeRole,
    String? userEmail,
    String? userName,
    List<String>? roles,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      userId: userId ?? this.userId,
      userRole: userRole ?? this.userRole,
      activeRole: activeRole ?? this.activeRole,
      userEmail: userEmail ?? this.userEmail,
      userName: userName ?? this.userName,
      roles: roles ?? this.roles,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiClient _client;
  final FlutterSecureStorage _storage;
  final Ref _ref;

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userIdKey = 'user_id';
  static const _userRoleKey = 'user_role';
  static const _activeRoleKey = 'active_role';
  static const _rolesKey = 'roles';
  static const _userEmailKey = 'user_email';
  static const _userNameKey = 'user_name';
  static final _logger = Logger('AuthNotifier');

  AuthNotifier(this._client, this._storage, this._ref)
    : super(const AuthState());

  Future<void> init() async {
    final accessToken = await _storage.read(key: _accessTokenKey);
    final refreshToken = await _storage.read(key: _refreshTokenKey);
    final userId = await _storage.read(key: _userIdKey);
    final userRole = await _storage.read(key: _userRoleKey);
    final activeRole = await _storage.read(key: _activeRoleKey);
    final userEmail = await _storage.read(key: _userEmailKey);
    final userName = await _storage.read(key: _userNameKey);
    final rolesString = await _storage.read(key: _rolesKey);
    final roles = rolesString != null && rolesString.isNotEmpty
        ? rolesString.split(',')
        : <String>[];

    if (accessToken != null) {
      state = AuthState(
        accessToken: accessToken,
        refreshToken: refreshToken,
        userId: userId,
        userRole: userRole,
        activeRole: activeRole ?? userRole,
        userEmail: userEmail,
        userName: userName,
        roles: roles.isNotEmpty ? roles : (userRole != null ? [userRole] : []),
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

      await _storage.write(key: _accessTokenKey, value: accessToken);
      await _storage.write(key: _refreshTokenKey, value: refreshToken);

      final userId = user.id;
      final userRole = user.role;
      final userEmail = user.email;
      final userName = user.name;

      await _storage.write(key: _userIdKey, value: userId);
      await _storage.write(key: _userRoleKey, value: userRole);
      await _storage.write(key: _activeRoleKey, value: userRole);
      await _storage.write(key: _rolesKey, value: userRole);
      await _storage.write(key: _userEmailKey, value: userEmail);
      await _storage.write(key: _userNameKey, value: userName);

      state = AuthState(
        accessToken: accessToken,
        refreshToken: refreshToken,
        userId: userId,
        userRole: userRole,
        activeRole: userRole,
        userEmail: userEmail,
        userName: userName,
        roles: userRole != null ? [userRole] : [],
      );

      // Hydrate capability state from login response
      try {
        await _ref
            .read(capabilityNotifierProvider.notifier)
            .hydrateFromLogin(loginResponse);
      } catch (e, st) {
        _logger.warning('Failed to hydrate capabilities after login', e, st);
      }

      return true;
    } catch (e) {
      final detail = extractErrorMessage(e);
      state = state.copyWith(isLoading: false, error: detail);
      return false;
    }
  }

  Future<bool> switchRole(String role) async {
    if (!state.roles.contains(role)) {
      return false;
    }
    await _storage.write(key: _activeRoleKey, value: role);
    state = state.copyWith(activeRole: role);
    return true;
  }

  Future<void> logout() async {
    try {
      final refreshToken = await _storage.read(key: _refreshTokenKey);
      if (refreshToken != null) {
        await _client.logout(refreshToken);
      }
    } catch (e, st) {
      _logger.warning('logout failed', e, st);
    }
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _userIdKey);
    await _storage.delete(key: _userRoleKey);
    await _storage.delete(key: _activeRoleKey);
    await _storage.delete(key: _rolesKey);
    await _storage.delete(key: _userEmailKey);
    await _storage.delete(key: _userNameKey);
    state = const AuthState();

    // Clear capability cache on logout
    try {
      await _ref.read(capabilityNotifierProvider.notifier).clearCache();
    } catch (e, st) {
      _logger.warning('Failed to clear capability cache on logout', e, st);
    }
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
  return AuthNotifier(client, storage, ref);
});

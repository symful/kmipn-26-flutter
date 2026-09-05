import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/capabilities.g.dart';
import '../api/client.dart';
import '../capabilities/can.dart';
import '../db/database.dart';
import '../utils/logger.dart';
import 'providers.dart';

/// Immutable state holder for capabilities.
/// Uses stable Set references so that `select()` on individual capabilities
/// only triggers rebuilds when that specific capability changes.
class CapabilityState {
  /// The active actor derived from the current user's role.
  /// Null if not authenticated.
  final CapabilityActor? actor;

  /// Full set of capability IDs for the current actor.
  /// Stored as a stable reference for efficient `select()`.
  final Set<String> capabilities;

  /// Manifest version from the server (ETag-based).
  final String? version;

  /// Timestamp when capabilities were last fetched from the server.
  final DateTime? fetchedAt;

  /// Error message if the last fetch failed.
  final String? error;

  /// Whether the server indicated capabilities are stale (403 cap_stale).
  /// Banner should be shown when true.
  final bool isStale;

  const CapabilityState({
    this.actor,
    this.capabilities = const {},
    this.version,
    this.fetchedAt,
    this.error,
    this.isStale = false,
  });

  CapabilityState copyWith({
    CapabilityActor? actor,
    Set<String>? capabilities,
    String? version,
    DateTime? fetchedAt,
    String? error,
    bool? isStale,
  }) {
    return CapabilityState(
      actor: actor ?? this.actor,
      capabilities: capabilities ?? this.capabilities,
      version: version ?? this.version,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      error: error,
      isStale: isStale ?? this.isStale,
    );
  }

  /// Returns true if the current actor has the given capability.
  bool can(String key, {Resource? resource, Scope? scope}) {
    return CapabilityCan.can(actor, key, resource: resource, scope: scope);
  }
}

/// Convenience wrapper that exposes the same signature as the standalone [can()]
/// but delegates to [CapabilityState.can()].
extension CapabilityStateCan on CapabilityState {
  bool can(String key, {Resource? resource, Scope? scope}) {
    return CapabilityCan.can(actor, key, resource: resource, scope: scope);
  }
}

/// Standalone capability checker using the same rules as web's `can()`:
/// - `public.*` keys are true for any actor (including null).
/// - null actor + non-public key → false.
/// - Otherwise → actor.capabilities.contains(key).
class CapabilityCan {
  static bool can(
    CapabilityActor? actor,
    String key, {
    Resource? resource,
    Scope? scope,
  }) {
    // public.* keys are allowed by anyone (including unauthenticated)
    if (key.startsWith('public.')) return true;

    // null actor cannot access privileged capabilities
    if (actor == null) return false;

    // Check if actor has the exact key
    return actor.capabilities.contains(key);
  }
}

/// Notifier that manages capability state for the authenticated user.
/// Fetches from `/auth/capabilities` on demand and caches results in Drift.
class CapabilityNotifier extends AsyncNotifier<CapabilityState> {
  static final _logger = Logger('CapabilityNotifier');
  @override
  Future<CapabilityState> build() async {
    // Try to load from cache first
    final cached = await _loadFromCache();
    if (cached != null) {
      return cached;
    }

    // Use static capability matrix based on role if available
    final authState = ref.read(authNotifierProvider);
    final role = authState.activeRole ?? authState.userRole ?? '';
    final staticCaps = Capabilities.roleCapabilityMatrix[role];
    if (staticCaps != null && staticCaps.isNotEmpty) {
      final actor = CapabilityActor(role: role, capabilities: staticCaps);
      return CapabilityState(
        actor: actor,
        capabilities: staticCaps,
        version: 'static',
        fetchedAt: null,
      );
    }

    // Fall back to bootstrap manifest for unauthenticated/public
    return _loadBootstrap();
  }

  /// Fetches capabilities from the server and caches them.
  Future<CapabilityState> fetch() async {
    final api = ref.read(apiClientProvider);
    final authState = ref.read(authNotifierProvider);

    if (!authState.isAuthenticated) {
      return const CapabilityState();
    }

    try {
      final response = await api.getCapabilities();
      final capabilities = Set<String>.from(response.capabilities ?? []);
      final version = response.version ?? 'unknown';
      final now = DateTime.now();

      // Cache to Drift
      await _saveToCache(
        userId: authState.userId ?? '',
        role: authState.activeRole ?? authState.userRole ?? '',
        version: version,
        capabilities: capabilities,
        fetchedAt: now,
      );

      final actor = CapabilityActor(
        role: authState.activeRole ?? authState.userRole ?? '',
        capabilities: capabilities,
      );

      return CapabilityState(
        actor: actor,
        capabilities: capabilities,
        version: version,
        fetchedAt: now,
      );
    } catch (e) {
      // Try to return cached data even on error
      final cached = await _loadFromCache();
      if (cached != null) {
        return cached.copyWith(error: e.toString());
      }
      rethrow;
    }
  }

  /// Refetches capabilities (used by interceptor on 403 cap_stale).
  /// Clears stale flag on success.
  Future<void> refetch() async {
    state = const AsyncLoading();
    final fetched = await fetch();
    // Clear stale flag on successful refetch
    state = AsyncData(fetched.copyWith(isStale: false));
  }

  /// Marks capabilities as stale (called when server returns 403 cap_stale).
  /// Does NOT refetch — caller should call refetch() separately.
  void markStale() {
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncData(current.copyWith(isStale: true));
    }
  }

  /// Clears the stale flag (e.g., after user-initiated refresh).
  void clearStale() {
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncData(current.copyWith(isStale: false));
    }
  }

  /// Hydrates capabilities directly from a login response.
  /// Called by AuthNotifier after successful login.
  Future<void> hydrateFromLogin(LoginResponse loginResponse) async {
    final authState = ref.read(authNotifierProvider);
    final capabilities = Set<String>.from(loginResponse.capabilities ?? []);

    // If server provided capabilities, use them
    if (loginResponse.capabilities != null &&
        loginResponse.capabilities!.isNotEmpty) {
      final actor = CapabilityActor(
        role: authState.activeRole ?? authState.userRole ?? '',
        capabilities: capabilities,
      );

      // Cache for offline use
      await _saveToCache(
        userId: authState.userId ?? '',
        role: authState.activeRole ?? authState.userRole ?? '',
        version: 'login',
        capabilities: capabilities,
        fetchedAt: DateTime.now(),
      );

      state = AsyncData(
        CapabilityState(
          actor: actor,
          capabilities: capabilities,
          version: 'login',
          fetchedAt: DateTime.now(),
        ),
      );
    } else {
      // Server didn't include capabilities in login response.
      // Use the static capability matrix immediately so nav items render,
      // then fetch from server in the background.
      final role = authState.activeRole ?? authState.userRole ?? '';
      final staticCaps = Capabilities.roleCapabilityMatrix[role] ?? {};
      if (staticCaps.isNotEmpty) {
        final actor = CapabilityActor(role: role, capabilities: staticCaps);
        state = AsyncData(
          CapabilityState(
            actor: actor,
            capabilities: staticCaps,
            version: 'static',
            fetchedAt: DateTime.now(),
          ),
        );
        await _saveToCache(
          userId: authState.userId ?? '',
          role: role,
          version: 'static',
          capabilities: staticCaps,
          fetchedAt: DateTime.now(),
        );
      }
      // Fetch fresh from server (non-blocking, updates state when done)
      fetch().catchError((e) {
        _logger.warning('Background capability fetch failed', e);
      });
    }
  }

  /// Clears cached capabilities on logout.
  Future<void> clearCache() async {
    final db = ref.read(databaseProvider);
    await db.delete(db.capabilitiesCache).go();
    state = const AsyncData(CapabilityState());
  }

  Future<CapabilityState?> _loadFromCache() async {
    final db = ref.read(databaseProvider);
    final authState = ref.read(authNotifierProvider);
    final userId = authState.userId;

    if (userId == null) return null;

    final rows = await (db.select(
      db.capabilitiesCache,
    )..where((t) => t.userId.equals(userId))).get();

    if (rows.isEmpty) return null;

    final row = rows.first;
    final capabilities = (jsonDecode(row.payload) as List)
        .map((e) => e.toString())
        .toSet();
    final actor = CapabilityActor(role: row.role, capabilities: capabilities);

    return CapabilityState(
      actor: actor,
      capabilities: capabilities,
      version: row.version,
      fetchedAt: row.fetchedAt,
    );
  }

  Future<void> _saveToCache({
    required String userId,
    required String role,
    required String version,
    required Set<String> capabilities,
    required DateTime fetchedAt,
  }) async {
    final db = ref.read(databaseProvider);
    await db
        .into(db.capabilitiesCache)
        .insertOnConflictUpdate(
          CapabilitiesCacheCompanion.insert(
            userId: userId,
            role: role,
            version: version,
            payload: jsonEncode(capabilities.toList()),
            fetchedAt: fetchedAt,
          ),
        );
  }

  CapabilityState _loadBootstrap() {
    // Bootstrap provides public.* capabilities for unauthenticated users
    const actor = CapabilityActor(
      role: 'PUBLIC',
      capabilities: {'public.read', 'report.submit.public'},
    );

    return const CapabilityState(
      actor: actor,
      capabilities: {'public.read', 'report.submit.public'},
      version: 'bootstrap',
      fetchedAt: null,
    );
  }
}

/// Provider for CapabilityNotifier.
/// Use `ref.watch(capabilityNotifierProvider.select(...))` for granular rebuilds
/// based on specific capability changes.
final capabilityNotifierProvider =
    AsyncNotifierProvider<CapabilityNotifier, CapabilityState>(() {
      return CapabilityNotifier();
    });

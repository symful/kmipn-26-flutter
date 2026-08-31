import '../api/capabilities.g.dart';

/// Represents an actor (user) with a role and capabilities for permission checks.
class CapabilityActor {
  /// The canonical role string (e.g. "VERIFIKATOR", "WARGA").
  final String role;

  /// Pre-compiled set of capability IDs granted to this actor.
  final Set<String> capabilities;

  const CapabilityActor({required this.role, required this.capabilities});

  /// Builds a CapabilityActor from a canonical role string.
  /// Returns null if the role is not recognized.
  factory CapabilityActor.fromRole(String role) {
    final caps = compileRole(role);
    if (caps.isEmpty) return CapabilityActor(role: role, capabilities: {});
    return CapabilityActor(role: role, capabilities: caps);
  }
}

/// Compiles the full set of capability IDs granted to a given canonical role.
/// Reads from the generated [Capabilities.roleCapabilityMatrix] produced by T3.
/// Returns an empty set for unknown roles.
Set<String> compileRole(String role) {
  return Capabilities.roleCapabilityMatrix[role] ?? {};
}

/// Checks whether [actor] is permitted to perform [key] capability.
///
/// Rules:
/// - `public.*` keys are true for any actor (including null).
/// - null actor + non-public key → false.
/// - Otherwise → actor.capabilities contains key.
bool can(
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

/// Optional resource context for capability checks (reserved for future use).
class Resource {
  final String type;
  final String id;
  const Resource({required this.type, required this.id});
}

/// Optional scope context for capability checks (reserved for future use).
class Scope {
  final String wilayahId;
  const Scope({required this.wilayahId});
}

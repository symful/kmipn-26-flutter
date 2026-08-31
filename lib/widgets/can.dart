import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../capabilities/can.dart';
import '../providers/capability_provider.dart';

/// A capability-gated widget that renders [child] only when the current actor
/// has the specified capability, otherwise renders [fallback].
///
/// Uses [ref.watch] with [select] so only the specific capability being checked
/// triggers rebuilds — avoiding full-tree rebuilds on any capability change.
///
/// Example:
/// ```dart
/// Can(
///   action: 'case.verify',
///   resource: Resource(type: 'case', id: '123'),
///   fallback: const SizedBox.shrink(),
///   child: const VerifyButton(),
/// )
/// ```
class Can extends ConsumerWidget {
  /// The capability action key to check (e.g. `'case.verify'`).
  final String action;

  /// Optional list of additional actions that must ALL be granted (AND semantics).
  /// If null, no additional checks are performed.
  final List<String>? requireAll;

  /// Optional resource context for the capability check.
  final Resource? resource;

  /// Optional scope context for the capability check.
  final Scope? scope;

  /// Widget to render when the capability is granted. Required.
  final Widget child;

  /// Widget to render when the capability is denied.
  /// Defaults to [SizedBox.shrink].
  final Widget fallback;

  /// Boolean gate — when false, always renders [fallback].
  /// Defaults to true.
  final bool when;

  const Can({
    super.key,
    required this.action,
    this.requireAll,
    this.resource,
    this.scope,
    required this.child,
    this.fallback = const SizedBox.shrink(),
    this.when = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Gate: when=false always falls back
    if (!when) return fallback;

    final capabilityState = ref.watch(
      capabilityNotifierProvider.select((state) => state.valueOrNull),
    );

    // While loading, treat as denied (no capability yet)
    if (capabilityState == null) {
      return fallback;
    }

    // Check primary action
    final hasPrimary = capabilityState.can(
      action,
      resource: resource,
      scope: scope,
    );

    // Check requireAll (AND semantics — all must be present)
    final hasAll =
        requireAll?.every(
          (a) => capabilityState.can(a, resource: resource, scope: scope),
        ) ??
        true;

    return (hasPrimary && hasAll) ? child : fallback;
  }
}

/// Extension on [Widget] to provide a fluent `whenCan` builder.
///
/// Example:
/// ```dart
/// MyButton().whenCan(
///   'admin.users.manage',
///   fallback: Text('No permission'),
/// )
/// ```
extension CanX on Widget {
  /// Wraps this widget in a [Can] that gates it behind [action].
  ///
  /// Renders this widget iff [CapabilityState.can] returns true for the
  /// current actor, otherwise renders [fallback].
  Widget whenCan(
    String action, {
    List<String>? requireAll,
    Resource? resource,
    Scope? scope,
    Widget? fallback,
    bool when = true,
  }) {
    return Can(
      action: action,
      requireAll: requireAll,
      resource: resource,
      scope: scope,
      fallback: fallback ?? const SizedBox.shrink(),
      when: when,
      child: this,
    );
  }
}

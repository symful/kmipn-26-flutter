import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sigap/theme/tokens.dart';
import 'package:sigap/widgets/can.dart';
import 'package:sigap/widgets/design_system/sync_status_indicator.dart';
import 'package:sigap/widgets/stale_permissions_banner.dart';

/// Canonical shell for authenticated screens.
///
/// Replaces the PhoneFrame → StatusBar → Scaffold → SafeArea → Padding pattern.
///
/// Usage with child content:
/// ```dart
/// AuthenticatedShell(
///   activeRole: 'WARGA',
///   child: MyDashboardContent(),
/// )
/// ```
///
/// Usage with scaffold body (for AppBar/BottomNav):
/// ```dart
/// AuthenticatedShell(
///   activeRole: 'SURVEYOR',
///   useScaffold: true,
///   body: MyBody(),
///   appBar: AppBar(title: Text('Title')),
/// )
/// ```
class AuthenticatedShell extends ConsumerWidget {
  /// The currently active role (determines RoleBanner color, etc.)
  final String activeRole;

  /// The main content - rendered inside SafeArea + Padding(lg).
  /// Use this when screen is primarily a single scrollable column.
  final Widget? child;

  /// Optional custom padding. Default: EdgeInsets.all(SigapSpacing.lg)
  final EdgeInsets? padding;

  /// If true (default), wraps body in a Scaffold.
  /// Set to false when you need to provide your own scaffold structure.
  final bool useScaffold;

  /// Background color for the Scaffold. Default: SigapColors.bgSurface
  final Color? backgroundColor;

  /// Use instead of [child] when you need AppBar, Drawer, or BottomNav.
  final Widget? body;

  /// AppBar for the scaffold. Use with [body].
  final PreferredSizeWidget? appBar;

  /// Bottom navigation bar. Use with [body].
  final Widget? bottomNavigationBar;

  /// If provided and true, shows offline indicator and sync button.
  final bool isOffline;

  /// Optional callback to invoke sync button press when offline.
  final VoidCallback? onSyncPressed;

  /// Optional FAB shown only when the actor has `admin.*.manage` capability.
  /// Demo application of the [Can] widget.
  final Widget? floatingActionButton;

  const AuthenticatedShell({
    super.key,
    required this.activeRole,
    this.child,
    this.padding,
    this.useScaffold = true,
    this.backgroundColor,
    this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.isOffline = false,
    this.onSyncPressed,
    this.floatingActionButton,
  }) : assert(
         child != null || body != null,
         'Provide either child or body, not both',
       );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Expanded(
          child: useScaffold ? _buildScaffold(context) : _buildPaddedChild(),
        ),
      ],
    );
  }

  Widget _buildScaffold(BuildContext context) {
    final effectiveBackgroundColor = backgroundColor ?? SigapColors.bgSurface;

    final effectiveBody = body ?? _buildPaddedChild();

    return Scaffold(
      backgroundColor: effectiveBackgroundColor,
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      body: Column(
        children: [
          const StalePermissionsBanner(),
          Expanded(child: effectiveBody),
        ],
      ),
      floatingActionButton: floatingActionButton != null
          ? Can(
              action: 'admin.users.manage',
              fallback: const SizedBox.shrink(),
              child: floatingActionButton!,
            )
          : null,
    );
  }

  Widget _buildPaddedChild() {
    return SafeArea(
      child: Column(
        children: [
          const StalePermissionsBanner(),
          Expanded(
            child: Padding(
              padding: padding ?? const EdgeInsets.all(SigapSpacing.lg),
              child: child ?? const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Mixin that provides offline-state helpers for home screens.
///
/// Use this in StatefulWidgets that need to compute isOffline and SyncState.
mixin OfflineStateMixin {
  /// Computes isOffline from connectivity AsyncValue.
  bool isOfflineFromConnectivity(
    AsyncValue<List<ConnectivityResult>>? results,
  ) {
    return results?.whenOrNull(
          data: (result) =>
              result.isEmpty ||
              result.every((r) => r == ConnectivityResult.none),
        ) ??
        false;
  }

  /// Computes SyncState from isOffline boolean.
  SyncState syncStateFromOffline(bool isOffline) {
    return isOffline ? SyncState.offline : SyncState.online;
  }
}

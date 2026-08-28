import 'package:flutter/material.dart';
import 'package:sigap/theme/tokens.dart';
import 'package:sigap/widgets/design_system/responsive.dart';

/// ResponsiveScaffold — canonical SIGAP shell that adapts navigation
/// geometry to the current breakpoint.
///
/// Layout spec (guide.txt §3, §M-05):
/// - Mobile (<600):        Scaffold.drawer + optional BottomNav
/// - Tablet (600–1024):    Scaffold with persistent NavigationRail on left
/// - Desktop (>1024):       Scaffold with wider NavigationRail (extended labels)
///
/// The body is constrained to a max readable width with SigapSpacing padding.
class ResponsiveScaffold extends StatelessWidget {
  const ResponsiveScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.drawer,
    this.bottomNavigationBar,
    this.navigationIndex,
    this.onNavigationChanged,
    this.navigationItems,
    this.maxBodyWidth,
  });

  /// AppBar passed through to [Scaffold.appBar].
  final PreferredSizeWidget? appBar;

  /// Main body content.
  final Widget body;

  /// FAB passed through to [Scaffold.floatingActionButton].
  final Widget? floatingActionButton;

  /// Optional custom drawer (used on mobile as override).
  final Widget? drawer;

  /// Bottom navigation bar (mobile only; hidden when rail is shown).
  final Widget? bottomNavigationBar;

  /// Current navigation index (for rail / bottom nav selected state).
  final int? navigationIndex;

  /// Callback when user selects a navigation item.
  final ValueChanged<int>? onNavigationChanged;

  /// Navigation items for the rail / bottom nav.
  /// If null, no adaptive navigation shell is built.
  final List<NavigationDestination>? navigationItems;

  /// Max width of the body content area (default: 600).
  final double? maxBodyWidth;

  // -------------------------------------------------------------------------
  // Internal
  // -------------------------------------------------------------------------

  double get _defaultMaxBodyWidth => maxBodyWidth ?? 600;

  @override
  Widget build(BuildContext context) {
    if (navigationItems == null || navigationItems!.isEmpty) {
      return Scaffold(
        appBar: appBar,
        body: _BodyConstrainer(maxWidth: _defaultMaxBodyWidth, child: body),
        floatingActionButton: floatingActionButton,
        drawer: drawer,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;

        if (isMobile(w)) {
          return _MobileShell(
            appBar: appBar,
            body: _BodyConstrainer(maxWidth: _defaultMaxBodyWidth, child: body),
            floatingActionButton: floatingActionButton,
            drawer: drawer,
            bottomNavigationBar: bottomNavigationBar,
            navigationItems: navigationItems!,
            navigationIndex: navigationIndex,
            onNavigationChanged: onNavigationChanged,
          );
        }

        if (isTablet(w)) {
          return _TabletShell(
            appBar: appBar,
            body: _BodyConstrainer(maxWidth: _defaultMaxBodyWidth, child: body),
            floatingActionButton: floatingActionButton,
            navigationItems: navigationItems!,
            navigationIndex: navigationIndex,
            onNavigationChanged: onNavigationChanged,
          );
        }

        // Desktop
        return _DesktopShell(
          appBar: appBar,
          body: _BodyConstrainer(maxWidth: _defaultMaxBodyWidth, child: body),
          floatingActionButton: floatingActionButton,
          navigationItems: navigationItems!,
          navigationIndex: navigationIndex,
          onNavigationChanged: onNavigationChanged,
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Shells
// ---------------------------------------------------------------------------

class _MobileShell extends StatelessWidget {
  const _MobileShell({
    required this.appBar,
    required this.body,
    required this.floatingActionButton,
    required this.drawer,
    required this.bottomNavigationBar,
    required this.navigationItems,
    required this.navigationIndex,
    required this.onNavigationChanged,
  });

  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final Widget? drawer;
  final Widget? bottomNavigationBar;
  final List<NavigationDestination> navigationItems;
  final int? navigationIndex;
  final ValueChanged<int>? onNavigationChanged;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: body,
      floatingActionButton: floatingActionButton,
      drawer: drawer,
      bottomNavigationBar:
          bottomNavigationBar ??
          NavigationBar(
            selectedIndex: navigationIndex ?? 0,
            onDestinationSelected: onNavigationChanged,
            backgroundColor: SigapColors.surface,
            indicatorColor: SigapColors.primaryLight,
            destinations: navigationItems,
          ),
    );
  }
}

class _TabletShell extends StatelessWidget {
  const _TabletShell({
    required this.appBar,
    required this.body,
    required this.floatingActionButton,
    required this.navigationItems,
    required this.navigationIndex,
    required this.onNavigationChanged,
  });

  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final List<NavigationDestination> navigationItems;
  final int? navigationIndex;
  final ValueChanged<int>? onNavigationChanged;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: navigationIndex ?? 0,
            onDestinationSelected: onNavigationChanged,
            backgroundColor: SigapColors.sidebarBg,
            indicatorColor: SigapColors.primary,
            labelType: NavigationRailLabelType.selected,
            leading: const SizedBox(height: 8),
            destinations: navigationItems
                .map(
                  (dest) => NavigationRailDestination(
                    icon: dest.icon,
                    selectedIcon: dest.selectedIcon,
                    label: Text(dest.label),
                  ),
                )
                .toList(),
          ),
          const VerticalDivider(
            thickness: 1,
            width: 1,
            color: SigapColors.border,
          ),
          Expanded(child: body),
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}

class _DesktopShell extends StatelessWidget {
  const _DesktopShell({
    required this.appBar,
    required this.body,
    required this.floatingActionButton,
    required this.navigationItems,
    required this.navigationIndex,
    required this.onNavigationChanged,
  });

  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final List<NavigationDestination> navigationItems;
  final int? navigationIndex;
  final ValueChanged<int>? onNavigationChanged;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: navigationIndex ?? 0,
            onDestinationSelected: onNavigationChanged,
            backgroundColor: SigapColors.sidebarBg,
            indicatorColor: SigapColors.primary,
            extended: true,
            minExtendedWidth: 220,
            leading: const SizedBox(height: 8),
            destinations: navigationItems
                .map(
                  (dest) => NavigationRailDestination(
                    icon: dest.icon,
                    selectedIcon: dest.selectedIcon,
                    label: Text(dest.label),
                  ),
                )
                .toList(),
          ),
          const VerticalDivider(
            thickness: 1,
            width: 1,
            color: SigapColors.border,
          ),
          Expanded(child: body),
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}

// ---------------------------------------------------------------------------
// Body constrainer
// ---------------------------------------------------------------------------

/// Centers and constrains body content to [maxWidth] with SigapSpacing padding.
class _BodyConstrainer extends StatelessWidget {
  const _BodyConstrainer({required this.maxWidth, required this.child});

  final double maxWidth;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: SigapSpacing.lg,
            vertical: SigapSpacing.md,
          ),
          child: child,
        ),
      ),
    );
  }
}

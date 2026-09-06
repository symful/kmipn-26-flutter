import 'package:sigap/theme/sigap_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:sigap/theme/tokens.dart';
import 'package:sigap/widgets/design_system/responsive.dart';

// ---------------------------------------------------------------------------
// Navigation section model
// ---------------------------------------------------------------------------

/// A group of [NavigationDestination]s under a section label header.
///
/// Used by [ResponsiveScaffold] to render section labels ("RUANG KERJA",
/// "TATA KELOLA") in the tablet/desktop sidebar, matching the Sigap
/// web sidebar design.
class NavSection {
  /// Section header label (e.g. "RUANG KERJA", "TATA KELOLA").
  final String label;

  /// Navigation destinations belonging to this section.
  final List<NavigationDestination> items;

  const NavSection({required this.label, required this.items});
}

// ---------------------------------------------------------------------------
// ResponsiveScaffold
// ---------------------------------------------------------------------------

/// ResponsiveScaffold — canonical SIGAP shell that adapts navigation
/// geometry to the current breakpoint.
///
/// Layout spec (guide.txt §3, §M-05):
/// - Mobile (<600):        Scaffold.drawer + optional BottomNav
/// - Tablet (600–1024):    Scaffold with persistent sidebar on left
/// - Desktop (>1024):       Scaffold with wider sidebar (extended labels)
///
/// The body is constrained to a max readable width with SigapSpacing padding.
///
/// For tablet/desktop sidebars, prefer [navigationSections] over flat
/// [navigationItems] to get section header labels matching the Sigap
/// web design (e.g. "RUANG KERJA", "TATA KELOLA").
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
    this.navigationSections,
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

  /// Flat navigation items for the rail / bottom nav.
  /// If null and [navigationSections] is also null, no adaptive navigation
  /// shell is built.
  final List<NavigationDestination>? navigationItems;

  /// Sectioned navigation items for the tablet/desktop sidebar.
  ///
  /// When provided, renders section header labels (e.g. "RUANG KERJA",
  /// "TATA KELOLA") above each group of destinations, matching the Sigap
  /// web sidebar design.
  ///
  /// Overrides flat [navigationItems] for tablet/desktop layouts.
  final List<NavSection>? navigationSections;

  /// Max width of the body content area (default: 600).
  final double? maxBodyWidth;

  // -------------------------------------------------------------------------
  // Internal
  // -------------------------------------------------------------------------

  double get _defaultMaxBodyWidth => maxBodyWidth ?? 600;

  /// Whether this scaffold has navigation to display.
  bool get _hasNavigation =>
      (navigationItems != null && navigationItems!.isNotEmpty) ||
      (navigationSections != null && navigationSections!.isNotEmpty);

  /// Flat list of all navigation destinations (used for index mapping).
  List<NavigationDestination> get _allDestinations {
    if (navigationSections != null && navigationSections!.isNotEmpty) {
      return [for (final section in navigationSections!) ...section.items];
    }
    return navigationItems ?? [];
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasNavigation) {
      return Scaffold(
        appBar: appBar,
        body: _BodyConstrainer(maxWidth: _defaultMaxBodyWidth, child: body),
        floatingActionButton: floatingActionButton,
        drawer: drawer,
      );
    }

    final flatItems = _allDestinations;

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
            navigationItems: flatItems,
            navigationIndex: navigationIndex,
            onNavigationChanged: onNavigationChanged,
          );
        }

        if (isTablet(w)) {
          return _TabletShell(
            appBar: appBar,
            body: _BodyConstrainer(maxWidth: _defaultMaxBodyWidth, child: body),
            floatingActionButton: floatingActionButton,
            navigationSections: navigationSections,
            navigationItems: flatItems,
            navigationIndex: navigationIndex,
            onNavigationChanged: onNavigationChanged,
          );
        }

        // Desktop
        return _DesktopShell(
          appBar: appBar,
          body: _BodyConstrainer(maxWidth: _defaultMaxBodyWidth, child: body),
          floatingActionButton: floatingActionButton,
          navigationSections: navigationSections,
          navigationItems: flatItems,
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
            backgroundColor: SigapColorScheme.of(context).surface,
            indicatorColor: SigapColorScheme.of(context).primaryLight,
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
    required this.navigationSections,
    required this.navigationItems,
    required this.navigationIndex,
    required this.onNavigationChanged,
  });

  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final List<NavSection>? navigationSections;
  final List<NavigationDestination> navigationItems;
  final int? navigationIndex;
  final ValueChanged<int>? onNavigationChanged;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: Row(
        children: [
          _SigapNavSidebar(
            sections: navigationSections,
            flatItems: navigationItems,
            selectedIndex: navigationIndex,
            onDestinationSelected: onNavigationChanged,
            extended: false,
          ),
          VerticalDivider(
            thickness: 1,
            width: 1,
            color: SigapColorScheme.of(context).border,
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
    required this.navigationSections,
    required this.navigationItems,
    required this.navigationIndex,
    required this.onNavigationChanged,
  });

  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final List<NavSection>? navigationSections;
  final List<NavigationDestination> navigationItems;
  final int? navigationIndex;
  final ValueChanged<int>? onNavigationChanged;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: Row(
        children: [
          _SigapNavSidebar(
            sections: navigationSections,
            flatItems: navigationItems,
            selectedIndex: navigationIndex,
            onDestinationSelected: onNavigationChanged,
            extended: true,
          ),
          VerticalDivider(
            thickness: 1,
            width: 1,
            color: SigapColorScheme.of(context).border,
          ),
          Expanded(child: body),
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}

// ---------------------------------------------------------------------------
// Sigap custom sidebar with section labels
// ---------------------------------------------------------------------------

/// Custom sidebar that renders section header labels (e.g. "RUANG KERJA",
/// "TATA KELOLA") above groups of navigation items, matching the Sigap
/// web sidebar design (style.css `.nav-label`).
///
/// Falls back to a flat list when no sections are provided.
class _SigapNavSidebar extends StatelessWidget {
  const _SigapNavSidebar({
    required this.flatItems,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.sections,
    this.extended = false,
  });

  /// Sectioned navigation items (preferred).
  final List<NavSection>? sections;

  /// Flat navigation items (fallback when sections is null).
  final List<NavigationDestination> flatItems;

  /// Currently selected destination index (global across all sections).
  final int? selectedIndex;

  /// Callback when a destination is selected.
  final ValueChanged<int>? onDestinationSelected;

  /// Whether to show labels beside icons (true = desktop, false = tablet).
  final bool extended;

  @override
  Widget build(BuildContext context) {
    final hasSections = sections != null && sections!.isNotEmpty;
    final items = hasSections
        ? sections!
        : [NavSection(label: '', items: flatItems)];

    return Container(
      width: extended ? 220 : 72,
      color: SigapColorScheme.of(context).sidebarBg,
      child: Column(
        children: [
          // Top spacer (matches NavigationRail leading: SizedBox(height: 8))
          SizedBox(height: 8),

          // Scrollable nav items
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: _totalItems(items),
              itemBuilder: (context, globalIndex) {
                return _buildItem(context, items, globalIndex);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Total number of nav items across all sections.
  int _totalItems(List<NavSection> sections) {
    int count = 0;
    for (final section in sections) {
      count += section.items.length;
    }
    return count;
  }

  /// Build a nav item or section label for the given global index.
  Widget _buildItem(
    BuildContext context,
    List<NavSection> sections,
    int globalIndex,
  ) {
    int currentIndex = 0;

    for (int s = 0; s < sections.length; s++) {
      final section = sections[s];

      for (int i = 0; i < section.items.length; i++) {
        if (currentIndex == globalIndex) {
          final dest = section.items[i];
          final isSelected = selectedIndex == currentIndex;

          // Show section label before the first item of each section
          if (i == 0 && section.label.isNotEmpty) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Section label
                Padding(
                  padding: const EdgeInsets.only(
                    left: SigapSpacing.x12,
                    right: SigapSpacing.x12,
                    top: SigapSpacing.x12,
                    bottom: SigapSpacing.x6,
                  ),
                  child: Text(
                    section.label,
                    style: TextStyle(
                      fontSize: SigapTypography.captionMicro, // 9px
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.7,
                      color: SigapColorScheme.of(context).sidebarTextMuted,
                    ),
                  ),
                ),
                // The nav item itself
                _buildNavItem(context, dest, isSelected, currentIndex),
              ],
            );
          }

          return _buildNavItem(context, dest, isSelected, currentIndex);
        }
        currentIndex++;
      }
    }

    return SizedBox.shrink();
  }

  /// Build a single navigation item.
  Widget _buildNavItem(
    BuildContext context,
    NavigationDestination dest,
    bool isSelected,
    int index,
  ) {
    final iconColor = isSelected
        ? SigapColorScheme.of(context).primary
        : SigapColorScheme.of(context).sidebarTextMuted;
    final textColor = isSelected
        ? Colors.white
        : SigapColorScheme.of(context).sidebarText;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onDestinationSelected != null
            ? () => onDestinationSelected!(index)
            : null,
        hoverColor: SigapColorScheme.of(context).sidebarDivider,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: SigapSpacing.x12,
            vertical: SigapSpacing.x9,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? SigapColorScheme.of(context).primary.withValues(alpha: 0.18)
                : Colors.transparent,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              SizedBox(
                width: 24,
                height: 24,
                child: IconTheme(
                  data: IconThemeData(color: iconColor, size: 22),
                  child: isSelected
                      ? (dest.selectedIcon ?? dest.icon)
                      : dest.icon,
                ),
              ),
              if (extended) ...[
                SizedBox(width: SigapSpacing.x12),
                Expanded(
                  child: Text(
                    dest.label.toString(),
                    style: TextStyle(
                      fontSize: SigapTypography.bodySmall, // 12px
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: textColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
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

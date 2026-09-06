import 'package:sigap/theme/sigap_color_scheme.dart';

import 'package:flutter/material.dart';
import 'package:sigap/l10n/generated/app_localizations.dart';
import 'package:sigap/theme/tokens.dart';

/// Role-based bottom navigation for PETUGAS role.
///
/// Items are filtered by role, not by capabilities.
class AdaptiveNav extends StatelessWidget {
  const AdaptiveNav({
    super.key,
    required this.activeIndex,
    required this.onTap,
  });

  /// Index of the currently active nav item.
  final int activeIndex;

  /// Callback fired when a nav item is tapped. Passes the item's index and its route.
  final void Function(int index, String route) onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final items = _buildNavItems(l10n);
    final routes = navRoutesForRole(null); // PETUGAS use same routes

    return _SigapBottomNav(
      items: items,
      routes: routes,
      activeIndex: activeIndex,
      onTap: onTap,
    );
  }

  List<_SigapBottomNavItem> _buildNavItems(AppLocalizations l10n) {
    return [
      _tugasItem(l10n),
      _petaItem(l10n),
      _sinkronItem(l10n),
      _riwayatItem(l10n),
      _profileItem(l10n),
    ];
  }

  _SigapBottomNavItem _tugasItem(AppLocalizations l10n) => _SigapBottomNavItem(
    icon: Icons.assignment_outlined,
    activeIcon: Icons.assignment,
    label: l10n.tugas,
    semanticsLabel: l10n.tugas,
  );

  _SigapBottomNavItem _petaItem(AppLocalizations l10n) => _SigapBottomNavItem(
    icon: Icons.map_outlined,
    activeIcon: Icons.map,
    label: l10n.peta,
    semanticsLabel: l10n.peta,
  );

  _SigapBottomNavItem _sinkronItem(AppLocalizations l10n) =>
      _SigapBottomNavItem(
        icon: Icons.sync_outlined,
        activeIcon: Icons.sync,
        label: l10n.sinkronNav,
        semanticsLabel: l10n.sinkronNav,
      );

  _SigapBottomNavItem _riwayatItem(AppLocalizations l10n) =>
      _SigapBottomNavItem(
        icon: Icons.history_outlined,
        activeIcon: Icons.history,
        label: l10n.riwayatNav,
        semanticsLabel: l10n.riwayatNav,
      );

  _SigapBottomNavItem _profileItem(AppLocalizations l10n) =>
      _SigapBottomNavItem(
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: l10n.akunNav,
        semanticsLabel: l10n.akunNav,
      );
}

/// Provides the nav item routes for a given role.
List<String> navRoutesForRole(String? role) {
  return ['/tasks', '/map', '/sync', '/tasks?filter=completed', '/profile'];
}

// ---------------------------------------------------------------------------
// Inlined SigapBottomNav / SigapBottomNavItem
// ---------------------------------------------------------------------------

class _SigapBottomNavItem {
  const _SigapBottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.semanticsLabel,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String? semanticsLabel;
}

class _SigapBottomNav extends StatelessWidget {
  const _SigapBottomNav({
    required this.items,
    required this.routes,
    required this.activeIndex,
    required this.onTap,
  });

  final List<_SigapBottomNavItem> items;
  final List<String> routes;
  final int activeIndex;
  final void Function(int index, String route) onTap;

  @override
  Widget build(BuildContext context) {
    final background = SigapColorScheme.of(context).surface;
    final height = 64.0;
    final iconSize = 24.0;

    return SafeArea(
      top: false,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: background,
          border: Border(
            top: BorderSide(
              color: SigapColorScheme.of(context).border,
              width: 1,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (index) {
            final item = items[index];
            final isActive = index == activeIndex;
            final route = index < routes.length ? routes[index] : '/dashboard';

            return _SigapNavItem(
              item: item,
              isActive: isActive,
              onTap: () => onTap(index, route),
              iconSize: iconSize,
            );
          }),
        ),
      ),
    );
  }
}

class _SigapNavItem extends StatelessWidget {
  const _SigapNavItem({
    required this.item,
    required this.isActive,
    required this.onTap,
    required this.iconSize,
  });

  final _SigapBottomNavItem item;
  final bool isActive;
  final VoidCallback onTap;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final activeColor = SigapColorScheme.of(context).primary;
    final inactiveColor = SigapColorScheme.of(context).textMuted;

    final color = isActive ? activeColor : inactiveColor;

    return Semantics(
      label: item.semanticsLabel ?? item.label,
      button: true,
      selected: isActive,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SigapRadius.sm),
        child: Container(
          constraints: BoxConstraints(minWidth: 48, minHeight: 48),
          padding: EdgeInsets.symmetric(
            horizontal: SigapSpacing.sm,
            vertical: SigapSpacing.xs,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isActive ? item.activeIcon : item.icon,
                size: iconSize,
                color: color,
              ),
              SizedBox(height: SigapSpacing.xxs),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: SigapTypography.captionMedium,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// FixedWargaBottomNav — M-05 DC contract for WARGA role
// ---------------------------------------------------------------------------

/// Fixed 5-tab bottom navigation for the WARGA role, matching the DC (M-05).
///
/// Reference mobile tabs: Beranda, Laporan, Peta, Sinkron, Akun.
class FixedWargaBottomNav extends StatelessWidget {
  const FixedWargaBottomNav({
    super.key,
    required this.activeIndex,
    required this.onTabTap,
    required this.onFabTap,
  });

  /// Index of the currently active tab (0–4).
  final int activeIndex;

  /// Callback when a tab is tapped.
  final ValueChanged<int> onTabTap;

  /// Retained for callers migrating from the former central report button.
  final VoidCallback onFabTap;

  /// Fixed routes for each tab index.
  static const List<String> fixedRoutes = [
    '/dashboard', // 0 - Beranda
    '/laporan', // 1 - Laporan
    '/map', // 2 - Peta
    '/sync-center', // 3 - Sinkron
    '/profile', // 4 - Akun
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final activeColor = SigapColorScheme.of(context).primary;
    final inactiveColor = SigapColorScheme.of(context).textMuted;

    return SafeArea(
      top: false,
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: SigapColorScheme.of(context).surface,
          border: Border(
            top: BorderSide(
              color: SigapColorScheme.of(context).borderCard,
              width: 1,
            ),
          ),
        ),
        padding: EdgeInsets.only(
          top: SigapSpacing.x9,
          left: 5,
          right: 5,
          bottom: 15,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _WargaNavItem(
              isActive: activeIndex == 0,
              color: activeIndex == 0 ? activeColor : inactiveColor,
              label: l10n.beranda,
              fontWeight: activeIndex == 0 ? FontWeight.w600 : FontWeight.w500,
              icon: Icon(
                Icons.home_outlined,
                size: 19,
                color: activeIndex == 0 ? activeColor : inactiveColor,
              ),
              onTap: () => onTabTap(0),
            ),
            _WargaNavItem(
              isActive: activeIndex == 1,
              color: activeIndex == 1 ? activeColor : inactiveColor,
              label: l10n.laporanNav,
              fontWeight: activeIndex == 1 ? FontWeight.w600 : FontWeight.w500,
              icon: Icon(
                Icons.assignment_outlined,
                size: 19,
                color: activeIndex == 1 ? activeColor : inactiveColor,
              ),
              onTap: () => onTabTap(1),
            ),
            _WargaNavItem(
              isActive: activeIndex == 2,
              color: activeIndex == 2 ? activeColor : inactiveColor,
              label: l10n.peta,
              fontWeight: activeIndex == 2 ? FontWeight.w600 : FontWeight.w400,
              icon: Icon(
                Icons.map_outlined,
                size: 19,
                color: activeIndex == 2 ? activeColor : inactiveColor,
              ),
              onTap: () => onTabTap(2),
            ),
            _WargaNavItem(
              isActive: activeIndex == 3,
              color: activeIndex == 3 ? activeColor : inactiveColor,
              label: l10n.sinkronNav,
              fontWeight: activeIndex == 3 ? FontWeight.w600 : FontWeight.w500,
              icon: Icon(
                Icons.sync,
                size: 19,
                color: activeIndex == 3 ? activeColor : inactiveColor,
              ),
              onTap: () => onTabTap(3),
            ),
            _WargaNavItem(
              isActive: activeIndex == 4,
              color: activeIndex == 4 ? activeColor : inactiveColor,
              label: l10n.akunNav,
              fontWeight: activeIndex == 4 ? FontWeight.w600 : FontWeight.w500,
              icon: Icon(
                Icons.person_outline,
                size: 19,
                color: activeIndex == 4 ? activeColor : inactiveColor,
              ),
              onTap: () => onTabTap(4),
            ),
          ],
        ),
      ),
    );
  }
}

class _WargaNavItem extends StatelessWidget {
  const _WargaNavItem({
    required this.isActive,
    required this.color,
    required this.label,
    required this.fontWeight,
    required this.icon,
    required this.onTap,
  });

  final bool isActive;
  final Color color;
  final String label;
  final FontWeight fontWeight;
  final Widget icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      selected: isActive,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: 48, minHeight: 44),
          child: SizedBox(
            width: 56,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 3,
                  width: 20,
                  margin: EdgeInsets.only(bottom: 7),
                  decoration: BoxDecoration(
                    color: isActive
                        ? SigapColorScheme.of(context).primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                icon,
                SizedBox(height: SigapSpacing.x4),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: fontWeight,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

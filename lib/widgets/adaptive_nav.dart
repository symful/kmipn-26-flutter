import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sigap/l10n/strings.dart';
import 'package:sigap/providers/capability_provider.dart';
import 'package:sigap/theme/tokens.dart';

/// A capability-driven bottom navigation that maps capabilities to nav items.
///
/// Derives nav items from [CapabilityState] capabilities, not a hardcoded per-role list.
///
/// Capability → Nav item mapping:
/// - `report.submit` → "Beranda" / "Laporan"
/// - `task.accept` → "Tugas" / "Sinkron"
/// - `case.verify` / `case.read` → "Antrean"
/// - `audit.read` → "Audit"
/// - `analytics.read` → "Analitik"
/// - `public.read` → "Peta"
///
/// Covers 9 authenticated human roles:
/// Warga, Surveyor, Petugas, Operator, Verifikator, RT_RW,
/// Admin_Daerah, Auditor, Pengambil_Keputusan.
///
/// ADMIN is dropped (no contract basis).
/// Public/Warga Pemantau (no-login) and Sistem Eksternal (API-only) are excluded.
class AdaptiveNav extends ConsumerWidget {
  const AdaptiveNav({
    super.key,
    required this.activeIndex,
    required this.onTap,
  });

  /// Index of the currently active nav item.
  final int activeIndex;

  /// Callback fired when a nav item is tapped. Passes the item's index.
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final capabilityState = ref.watch(
      capabilityNotifierProvider.select((state) => state.valueOrNull),
    );

    // While loading or unauthenticated, show minimal nav (empty).
    if (capabilityState == null) {
      return const SizedBox.shrink();
    }

    final caps = capabilityState.capabilities;
    final items = _buildNavItems(caps);

    // Empty nav: nothing to show for this capability set.
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return _SigapBottomNav(
      items: items,
      activeIndex: activeIndex,
      onTap: onTap,
    );
  }

  /// Builds the list of [_SigapBottomNavItem] based on the given [capabilities].
  ///
  /// Items are ordered left-to-right. The FIRST item is the default landing
  /// route — derived from capabilities, not hardcoded per-role.
  ///
  /// Capability → Nav item mapping (mobile-specific):
  /// - Dashboard — always shown to any authenticated user (always first).
  /// - Peta — `public.read`.
  /// - Antrean — `case.verify` (verifikator triage queue).
  /// - AI Console — `case.verify` (AI assessment console, same cap as Antrean).
  /// - Export — `case.export` (report/case export).
  /// - Audit — `audit.read`.
  /// - Analitik — `analytics.read`.
  /// - Tugas — `task.accept`.
  /// - Laporan — `report.submit`.
  List<_SigapBottomNavItem> _buildNavItems(Set<String> capabilities) {
    final items = <_SigapBottomNavItem>[];

    // Dashboard — always first; available to all authenticated users.
    items.add(_dashboardItem());

    // Peta — available if public.read is present.
    if (capabilities.contains('public.read')) {
      items.add(_petaItem());
    }

    // Antrean — available if case.read OR case.verify is present.
    if (capabilities.contains('case.read') ||
        capabilities.contains('case.verify')) {
      items.add(_antreanItem());
    }

    // AI Console — available if case.verify is present.
    // Shown alongside Antrean for verifikator role (same cap gates both).
    if (capabilities.contains('case.verify')) {
      items.add(_aiConsoleItem());
    }

    // Export — available if case.export is present.
    if (capabilities.contains('case.export')) {
      items.add(_exportItem());
    }

    // Audit — available only if audit.read is present.
    if (capabilities.contains('audit.read')) {
      items.add(_auditItem());
    }

    // Analitik — available only if analytics.read is present.
    if (capabilities.contains('analytics.read')) {
      items.add(_analitikItem());
    }

    // Tugas / Sinkron — available if task.accept is present.
    if (capabilities.contains('task.accept')) {
      items.add(_tugasItem());
    }

    // Laporan — available if report.submit is present (warga).
    if (capabilities.contains('report.submit')) {
      items.add(_laporanItem());
    }

    return items;
  }

  _SigapBottomNavItem _dashboardItem() => _SigapBottomNavItem(
    icon: Icons.home_outlined,
    activeIcon: Icons.home,
    label: 'Dashboard',
    semanticsLabel: 'Dashboard',
  );

  _SigapBottomNavItem _petaItem() => _SigapBottomNavItem(
    icon: Icons.map_outlined,
    activeIcon: Icons.map,
    label: Strings.peta,
    semanticsLabel: 'Peta',
  );

  _SigapBottomNavItem _antreanItem() => _SigapBottomNavItem(
    icon: Icons.queue_outlined,
    activeIcon: Icons.queue,
    label: 'Antrean',
    semanticsLabel: 'Antrean',
  );

  _SigapBottomNavItem _aiConsoleItem() => _SigapBottomNavItem(
    icon: Icons.psychology_outlined,
    activeIcon: Icons.psychology,
    label: 'AI Console',
    semanticsLabel: 'AI Console',
  );

  _SigapBottomNavItem _exportItem() => _SigapBottomNavItem(
    icon: Icons.file_download_outlined,
    activeIcon: Icons.file_download,
    label: 'Export',
    semanticsLabel: 'Export',
  );

  _SigapBottomNavItem _auditItem() => _SigapBottomNavItem(
    icon: Icons.fact_check_outlined,
    activeIcon: Icons.fact_check,
    label: 'Audit',
    semanticsLabel: 'Audit',
  );

  _SigapBottomNavItem _analitikItem() => _SigapBottomNavItem(
    icon: Icons.analytics_outlined,
    activeIcon: Icons.analytics,
    label: 'Analitik',
    semanticsLabel: 'Analitik',
  );

  _SigapBottomNavItem _tugasItem() => _SigapBottomNavItem(
    icon: Icons.assignment_outlined,
    activeIcon: Icons.assignment,
    label: Strings.tugas,
    semanticsLabel: 'Tugas',
  );

  _SigapBottomNavItem _laporanItem() => _SigapBottomNavItem(
    icon: Icons.description_outlined,
    activeIcon: Icons.description,
    label: Strings.laporan,
    semanticsLabel: 'Laporan',
  );
}

/// Provides the nav item labels for a given set of capabilities.
/// Useful for tests that need to assert which nav items appear per role.
///
/// Returns a list of nav item labels in left-to-right order.
List<String> navItemsForCapabilities(Set<String> capabilities) {
  final items = <String>[];

  // Dashboard — always first for authenticated users.
  items.add('Dashboard');

  if (capabilities.contains('public.read')) {
    items.add('Peta');
  }

  if (capabilities.contains('case.read') ||
      capabilities.contains('case.verify')) {
    items.add('Antrean');
  }

  if (capabilities.contains('case.verify')) {
    items.add('AI Console');
  }

  if (capabilities.contains('case.export')) {
    items.add('Export');
  }

  if (capabilities.contains('audit.read')) {
    items.add('Audit');
  }

  if (capabilities.contains('analytics.read')) {
    items.add('Analitik');
  }

  if (capabilities.contains('task.accept')) {
    items.add('Tugas');
  }

  if (capabilities.contains('report.submit')) {
    items.add('Laporan');
  }

  return items;
}

/// Provides the nav item routes for a given set of capabilities.
/// Matches the same ordering as [navItemsForCapabilities].
///
/// Returns a list of route paths in left-to-right order.
List<String> navRoutesForCapabilities(Set<String> capabilities) {
  final routes = <String>[];

  // Dashboard — always first for authenticated users.
  routes.add('/dashboard');

  if (capabilities.contains('public.read')) {
    routes.add('/map');
  }

  if (capabilities.contains('case.read') ||
      capabilities.contains('case.verify')) {
    routes.add('/queue');
  }

  if (capabilities.contains('case.verify')) {
    routes.add('/ai-console');
  }

  if (capabilities.contains('case.export')) {
    routes.add('/export');
  }

  if (capabilities.contains('audit.read')) {
    routes.add('/audit');
  }

  if (capabilities.contains('analytics.read')) {
    routes.add('/stats');
  }

  if (capabilities.contains('task.accept')) {
    routes.add('/tasks');
  }

  if (capabilities.contains('report.submit')) {
    routes.add('/laporan');
  }

  return routes;
}

// ---------------------------------------------------------------------------
// Inlined SigapBottomNav / SigapBottomNavItem (formerly sigap_bottom_nav.dart)
// ---------------------------------------------------------------------------

/// A bottom navigation item used by [_SigapBottomNav].
class _SigapBottomNavItem {
  const _SigapBottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.semanticsLabel,
  });

  /// Icon displayed when the item is inactive.
  final IconData icon;

  /// Icon displayed when the item is in the active state.
  final IconData activeIcon;

  /// Text label displayed below the icon.
  final String label;

  /// Optional custom semantics label. Falls back to [label] if not provided.
  final String? semanticsLabel;
}

/// Canonical SIGAP bottom navigation bar.
///
/// Features:
/// - [items] list of icon + label pairs
/// - [activeIndex] drives which item is visually active
/// - [onTap] callback fired with the tapped item index
/// - Minimum 48px tap targets per accessibility requirements
/// - [Semantics] labels on every item for screen readers
/// - Active state uses [SigapColors.primary]; inactive is muted
/// - Safe-area / notch handling via [SafeArea] wrapper
class _SigapBottomNav extends StatelessWidget {
  const _SigapBottomNav({
    required this.items,
    required this.activeIndex,
    required this.onTap,
  });

  /// List of navigation items.
  final List<_SigapBottomNavItem> items;

  /// Index of the currently active item.
  final int activeIndex;

  /// Callback fired when an item is tapped.
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    const background = SigapColors.surface;
    const height = 64.0;
    const iconSize = 24.0;

    return SafeArea(
      top: false,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: background,
          border: Border(top: BorderSide(color: SigapColors.border, width: 1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (index) {
            final item = items[index];
            final isActive = index == activeIndex;

            return _SigapNavItem(
              item: item,
              isActive: isActive,
              onTap: () => onTap(index),
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
    final activeColor = SigapColors.primary;
    final inactiveColor = SigapColors.textMuted;

    final color = isActive ? activeColor : inactiveColor;

    return Semantics(
      label: item.semanticsLabel ?? item.label,
      button: true,
      selected: isActive,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SigapRadius.sm),
        child: Container(
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          padding: const EdgeInsets.symmetric(
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
              const SizedBox(height: SigapSpacing.xxs),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: SigapTypography.size11,
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

// ─────────────────────────────────────────────────────────────────────────────
// SurveyorBottomNav — role-specific 5-tab nav matching DC S-01
// ─────────────────────────────────────────────────────────────────────────────

/// Fixed 5-tab bottom nav for the SURVEYOR role.
///
/// Tabs: Tugas, Peta, Sinkron, Riwayat, Akun.
/// Uses border-based custom icons (not Material icons) to match the DC spec.
class SurveyorBottomNav extends StatelessWidget {
  const SurveyorBottomNav({
    super.key,
    required this.activeIndex,
    required this.onTap,
  });

  /// Index of the currently active tab (0–4).
  final int activeIndex;

  /// Callback fired when a tab is tapped.
  final ValueChanged<int> onTap;

  static const _activeColor = SigapColors.primary; // #0f7a6b
  static const _inactiveColor = SigapColors.textMuted; // #8a9099

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 9, 12, 20),
        decoration: const BoxDecoration(
          color: SigapColors.surface,
          border: Border(
            top: BorderSide(color: SigapColors.borderCard, width: 1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _NavItem(
              label: 'Tugas',
              isActive: activeIndex == 0,
              onTap: () => onTap(0),
              child: _TugasIcon(
                color: activeIndex == 0 ? _activeColor : _inactiveColor,
              ),
            ),
            _NavItem(
              label: 'Peta',
              isActive: activeIndex == 1,
              onTap: () => onTap(1),
              child: _PetaIcon(
                color: activeIndex == 1 ? _activeColor : _inactiveColor,
              ),
            ),
            _NavItem(
              label: 'Sinkron',
              isActive: activeIndex == 2,
              onTap: () => onTap(2),
              child: _SinkronIcon(
                color: activeIndex == 2 ? _activeColor : _inactiveColor,
              ),
            ),
            _NavItem(
              label: 'Riwayat',
              isActive: activeIndex == 3,
              onTap: () => onTap(3),
              child: _RiwayatIcon(
                color: activeIndex == 3 ? _activeColor : _inactiveColor,
              ),
            ),
            _NavItem(
              label: 'Akun',
              isActive: activeIndex == 4,
              onTap: () => onTap(4),
              child: _AkunIcon(
                color: activeIndex == 4 ? _activeColor : _inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared nav item wrapper ────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.child,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final color = isActive
        ? SurveyorBottomNav._activeColor
        : SurveyorBottomNav._inactiveColor;

    return Semantics(
      label: label,
      button: true,
      selected: isActive,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SigapRadius.sm),
        child: SizedBox(
          width: 60,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              child,
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: SigapTypography.size10,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── DC S-01 border-based icons ─────────────────────────────────────────────

/// Tugas: document — 16×18 rounded rectangle (border-radius 3px).
class _TugasIcon extends StatelessWidget {
  const _TugasIcon({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 18,
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

/// Peta: diamond — 16×16 square rotated 45°.
class _PetaIcon extends StatelessWidget {
  const _PetaIcon({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 45 * 3.14159265359 / 180,
      child: Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 2),
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }
}

/// Sinkron: circle + horizontal line — 18×18 circle with centered line.
class _SinkronIcon extends StatelessWidget {
  const _SinkronIcon({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 18,
      height: 18,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              border: Border.all(color: color, width: 2),
              shape: BoxShape.circle,
            ),
          ),
          Container(width: 12, height: 2, color: color),
        ],
      ),
    );
  }
}

/// Riwayat: document with thick top — 16×16 rounded rectangle, top border 5px.
class _RiwayatIcon extends StatelessWidget {
  const _RiwayatIcon({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: color, width: 5),
          left: BorderSide(color: color, width: 2),
          right: BorderSide(color: color, width: 2),
          bottom: BorderSide(color: color, width: 2),
        ),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

/// Akun: circle — 17×17 circular border.
class _AkunIcon extends StatelessWidget {
  const _AkunIcon({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 17,
      height: 17,
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 2),
        shape: BoxShape.circle,
      ),
    );
  }
}

// ── Surveyor nav route/label helpers ───────────────────────────────────────

/// Route paths for the surveyor 5-tab nav, left-to-right.
const List<String> surveyorNavRoutes = [
  '/tasks',
  '/map',
  '/sync-center',
  '/riwayat',
  '/profile',
];

/// Label strings for the surveyor 5-tab nav, left-to-right.
const List<String> surveyorNavLabels = [
  'Tugas',
  'Peta',
  'Sinkron',
  'Riwayat',
  'Akun',
];

// ---------------------------------------------------------------------------
// FixedWargaBottomNav — M-05 DC contract for WARGA role
// ---------------------------------------------------------------------------

/// Fixed 5-tab bottom navigation for the WARGA role, matching the DC (M-05).
///
/// Tabs: Beranda, Peta, Buat (center FAB), Laporan, Akun.
/// The center FAB triggers the /create route instead of switching tabs.
class FixedWargaBottomNav extends StatelessWidget {
  const FixedWargaBottomNav({
    super.key,
    required this.activeIndex,
    required this.onTabTap,
    required this.onFabTap,
  });

  /// Index of the currently active tab (0–4, excluding FAB at index 2).
  final int activeIndex;

  /// Callback when a regular tab is tapped (indices 0, 1, 3, 4).
  final ValueChanged<int> onTabTap;

  /// Callback when the center FAB is tapped.
  final VoidCallback onFabTap;

  /// Fixed routes for each tab index.
  static const List<String> fixedRoutes = [
    '/dashboard', // 0 - Beranda
    '/map', // 1 - Peta
    '/create', // 2 - Buat (FAB)
    '/laporan', // 3 - Laporan
    '/profile', // 4 - Akun
  ];

  @override
  Widget build(BuildContext context) {
    const activeColor = SigapColors.primary;
    const inactiveColor = SigapColors.textMuted;

    return SafeArea(
      top: false,
      child: Container(
        height: 84, // 64px nav + 20px bottom padding
        decoration: const BoxDecoration(
          color: SigapColors.surface,
          border: Border(
            top: BorderSide(color: SigapColors.borderCard, width: 1),
          ),
        ),
        padding: const EdgeInsets.only(
          top: SigapSpacing.x9,
          left: SigapSpacing.x12,
          right: SigapSpacing.x12,
          bottom: SigapSpacing.x20,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // 0 — Beranda (home bordered square)
            _WargaNavItem(
              isActive: activeIndex == 0,
              color: activeIndex == 0 ? activeColor : inactiveColor,
              label: 'Beranda',
              fontWeight: activeIndex == 0 ? FontWeight.w600 : FontWeight.w500,
              icon: _HomeIcon(
                color: activeIndex == 0 ? activeColor : inactiveColor,
              ),
              onTap: () => onTabTap(0),
            ),
            // 1 — Peta (rotated diamond)
            _WargaNavItem(
              isActive: activeIndex == 1,
              color: activeIndex == 1 ? activeColor : inactiveColor,
              label: 'Peta',
              fontWeight: activeIndex == 1 ? FontWeight.w600 : FontWeight.w500,
              icon: _DiamondIcon(
                color: activeIndex == 1 ? activeColor : inactiveColor,
              ),
              onTap: () => onTabTap(1),
            ),
            // 2 — Buat (center FAB)
            _WargaFabItem(onTap: onFabTap),
            // 3 — Laporan (document bordered rectangle)
            _WargaNavItem(
              isActive: activeIndex == 3,
              color: activeIndex == 3 ? activeColor : inactiveColor,
              label: 'Laporan',
              fontWeight: activeIndex == 3 ? FontWeight.w600 : FontWeight.w500,
              icon: _DocumentIcon(
                color: activeIndex == 3 ? activeColor : inactiveColor,
              ),
              onTap: () => onTabTap(3),
            ),
            // 4 — Akun (circle)
            _WargaNavItem(
              isActive: activeIndex == 4,
              color: activeIndex == 4 ? activeColor : inactiveColor,
              label: 'Akun',
              fontWeight: activeIndex == 4 ? FontWeight.w600 : FontWeight.w500,
              icon: _CircleIcon(
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

/// Regular nav item for the Warga fixed bottom nav.
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
        child: SizedBox(
          width: 56,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon,
              const SizedBox(height: SigapSpacing.x4),
              Text(
                label,
                style: TextStyle(
                  fontSize: SigapTypography.size10,
                  fontWeight: fontWeight,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Center FAB item for "Buat" action.
class _WargaFabItem extends StatelessWidget {
  const _WargaFabItem({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Buat laporan',
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: 60,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // FAB circle — 50x50, teal, raised shadow
              Container(
                width: 50,
                height: 50,
                margin: const EdgeInsets.only(bottom: SigapSpacing.x4),
                decoration: BoxDecoration(
                  color: SigapColors.primary,
                  borderRadius: BorderRadius.circular(SigapRadius.x16),
                  boxShadow: SigapShadows.fab,
                ),
                child: const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: Stack(
                      children: [
                        // Horizontal bar of +
                        Positioned(
                          top: 9,
                          left: 2,
                          width: 16,
                          height: 2.4,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(
                                Radius.circular(2),
                              ),
                            ),
                          ),
                        ),
                        // Vertical bar of +
                        Positioned(
                          left: 9,
                          top: 2,
                          width: 2.4,
                          height: 16,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(
                                Radius.circular(2),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Text(
                'Buat',
                style: TextStyle(
                  fontSize: SigapTypography.size10,
                  fontWeight: FontWeight.w600,
                  color: SigapColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Custom DC border-style icons matching the M-05 design contract
// ---------------------------------------------------------------------------

/// Home icon — bordered rounded square.
class _HomeIcon extends StatelessWidget {
  const _HomeIcon({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}

/// Peta icon — bordered rotated diamond.
class _DiamondIcon extends StatelessWidget {
  const _DiamondIcon({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 45 * 3.14159265359 / 180,
      child: Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 2),
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }
}

/// Laporan icon — bordered rectangle (document).
class _DocumentIcon extends StatelessWidget {
  const _DocumentIcon({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 18,
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

/// Akun icon — bordered circle.
class _CircleIcon extends StatelessWidget {
  const _CircleIcon({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 17,
      height: 17,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
      ),
    );
  }
}

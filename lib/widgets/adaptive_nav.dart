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

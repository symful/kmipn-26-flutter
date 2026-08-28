import 'package:flutter/material.dart';
import 'package:sigap/theme/tokens.dart';

/// A bottom navigation item used by [SigapBottomNav].
class SigapBottomNavItem {
  const SigapBottomNavItem({
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
class SigapBottomNav extends StatelessWidget {
  const SigapBottomNav({
    super.key,
    required this.items,
    required this.activeIndex,
    required this.onTap,
    this.backgroundColor,
    this.height = 64,
    this.iconSize = 24,
  });

  /// List of navigation items. Each item provides icon, active icon, and label.
  final List<SigapBottomNavItem> items;

  /// Index of the currently active item.
  final int activeIndex;

  /// Callback fired when an item is tapped. Passes the item's index.
  final ValueChanged<int> onTap;

  /// Override the background color. Defaults to [SigapColors.surface].
  final Color? backgroundColor;

  /// Total height of the navigation bar. Defaults to 64px.
  final double height;

  /// Size of the icon. Defaults to 24px.
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final background = backgroundColor ?? SigapColors.surface;

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

  final SigapBottomNavItem item;
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

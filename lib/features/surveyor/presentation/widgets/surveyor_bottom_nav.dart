import 'package:flutter/material.dart';
import 'package:sigap/l10n/strings.dart';
import '../../../../theme/tokens.dart';

/// S-01 Surveyor Home Screen Bottom Navigation Widget
///
/// Displays 5 navigation items: Tugas, Peta, Sinkron, Riwayat, Akun.
/// Surveyor variant at 80px height with equal-width tabs.
///
/// Design: PantauDesa S-01 region bottom navigation
///
/// Design tokens used:
/// - Active: SigapColors.primary (#0F7A6B) with filled icon
/// - Inactive: SigapColors.textTertiary (#616770) with outlined icon
class SurveyorBottomNav extends StatelessWidget {
  /// Current selected index (0-4).
  final int currentIndex;

  /// Callback when a navigation item is tapped.
  final ValueChanged<int> onTap;

  const SurveyorBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  /// S-01 Navigation item labels: Tugas, Peta, Sinkron, Riwayat, Akun.
  String _label(int index) {
    switch (index) {
      case 0:
        return Strings.tugas;
      case 1:
        return Strings.peta;
      case 2:
        return Strings.sinkron;
      case 3:
        return Strings.riwayat;
      case 4:
        return Strings.akun;
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: SigapColors.bgCard,
        border: Border(top: BorderSide(color: SigapColors.borderCard)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(5, (index) => _buildNavItem(index)),
        ),
      ),
    );
  }

  /// Builds a navigation item (Tugas, Peta, Sinkron, Riwayat, Akun).
  Widget _buildNavItem(int index) {
    final isActive = currentIndex == index;
    final label = _label(index);

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getIcon(index, isActive),
              size: 24,
              color: isActive ? SigapColors.primary : SigapColors.textTertiary,
            ),
            const SizedBox(height: SigapSpacing.x4),
            Text(
              label,
              style: TextStyle(
                fontSize: SigapTypography.size10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive
                    ? SigapColors.primary
                    : SigapColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Returns the appropriate icon for each navigation item.
  ///
  /// Uses filled icons when active, outlined icons when inactive.
  IconData _getIcon(int index, bool isActive) {
    switch (index) {
      case 0:
        // Tugas
        return isActive ? Icons.assignment_rounded : Icons.assignment_outlined;
      case 1:
        // Peta
        return isActive ? Icons.map_rounded : Icons.map_outlined;
      case 2:
        // Sinkron
        return isActive ? Icons.sync_rounded : Icons.sync_outlined;
      case 3:
        // Riwayat
        return isActive ? Icons.history_rounded : Icons.history_outlined;
      case 4:
        // Akun
        return isActive ? Icons.person_rounded : Icons.person_outline;
      default:
        return Icons.circle;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:sigap/l10n/strings.dart';
import '../../../../theme/tokens.dart';

/// S-01 Surveyor Home Screen Bottom Navigation Widget
///
/// Displays 5 navigation items: Beranda, Tugas, Buat, Notifikasi, Profil.
/// The center "Buat" item has an elevated/floating style.
///
/// Design: PantauDesa S-01 region bottom navigation
///
/// Design tokens used:
/// - Active: SigapColors.primary (#0F7A6B) with filled icon
/// - Inactive: SigapColors.textTertiary (#616770) with outlined icon
/// - Buat item: elevated with shadow and primary background
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

  /// Navigation item labels in order.
  String _label(int index) {
    switch (index) {
      case 0:
        return Strings.beranda;
      case 1:
        return Strings.tugas;
      case 2:
        return Strings.buat;
      case 3:
        return Strings.notifikasi;
      case 4:
        return Strings.profil;
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: SigapColors.bgCard,
        border: Border(top: BorderSide(color: SigapColors.borderCard)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(5, (index) {
              return index == 2 ? _buildBuatItem(index) : _buildNavItem(index);
            }),
          ),
        ),
      ),
    );
  }

  /// Builds a regular navigation item (Beranda, Tugas, Notifikasi, Profil).
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
                color: isActive ? SigapColors.primary : SigapColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the elevated "Buat" center item.
  Widget _buildBuatItem(int index) {
    final isActive = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        width: 56,
        height: 56,
        margin: const EdgeInsets.only(top: 8),
        decoration: BoxDecoration(
          color: isActive ? SigapColors.primaryDark : SigapColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0x4D0F7A6B),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_getIcon(index, isActive), size: 24, color: Colors.white),
            const SizedBox(height: SigapSpacing.x4),
            Text(
              _label(index),
              style: const TextStyle(
                fontSize: SigapTypography.size10,
                fontWeight: FontWeight.w600,
                color: Colors.white,
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
        // Beranda
        return isActive ? Icons.home_rounded : Icons.home_outlined;
      case 1:
        // Tugas
        return isActive ? Icons.assignment_rounded : Icons.assignment_outlined;
      case 2:
        // Buat
        return isActive
            ? Icons.add_circle_rounded
            : Icons.add_circle_outline_rounded;
      case 3:
        // Notifikasi
        return isActive
            ? Icons.notifications_rounded
            : Icons.notifications_outlined;
      case 4:
        // Profil
        return isActive ? Icons.person_rounded : Icons.person_outline;
      default:
        return Icons.circle;
    }
  }
}

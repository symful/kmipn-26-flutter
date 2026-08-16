import 'package:flutter/material.dart';
import '../../../../theme/tokens.dart';

/// S-01 Surveyor Home Screen Bottom Navigation Widget
///
/// Displays 5 navigation items: Beranda, Tugas, Buat, Notifikasi, Profil.
/// The center "Buat" item has an elevated/floating style.
///
/// Design: PantauDesa S-01 region bottom navigation
///
/// Design tokens used:
/// - Active: AppColors.primary (#0F7A6B) with filled icon
/// - Inactive: AppColors.textTertiary (#616770) with outlined icon
/// - Buat item: elevated with shadow and primary background
class S01BottomNav extends StatelessWidget {
  /// Current selected index (0-4).
  final int currentIndex;

  /// Callback when a navigation item is tapped.
  final ValueChanged<int> onTap;

  const S01BottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  /// Navigation item labels in order.
  static const _labels = ['Beranda', 'Tugas', 'Buat', 'Notifikasi', 'Profil'];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
        border: Border(top: BorderSide(color: AppColors.borderCard)),
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
    final label = _labels[index];

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
              color: isActive ? AppColors.primary : AppColors.textTertiary,
            ),
            const SizedBox(height: AppSpacing.x4),
            Text(
              label,
              style: TextStyle(
                fontSize: AppTypography.size10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? AppColors.primary : AppColors.textTertiary,
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
          color: isActive ? AppColors.primaryDark : AppColors.primary,
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
            const SizedBox(height: AppSpacing.x4),
            Text(
              _labels[index],
              style: const TextStyle(
                fontSize: AppTypography.size10,
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

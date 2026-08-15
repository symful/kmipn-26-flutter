import 'package:flutter/material.dart';
import 'package:sigap/theme/tokens.dart';

enum BottomNavVariant { warga, surveyor }

class BottomNav5 extends StatelessWidget {
  final BottomNavVariant variant;
  final int selectedIndex;
  final Function(int) onTap;

  const BottomNav5({
    super.key,
    required this.variant,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (variant == BottomNavVariant.surveyor) {
      return _buildSurveyorNav();
    }
    return _buildWargaNav();
  }

  Widget _buildWargaNav() {
    final items = ['Beranda', 'Peta', 'Laporan', 'Akun'];
    final icons = [
      Icons.home_outlined,
      Icons.map_outlined,
      Icons.description_outlined,
      Icons.person_outline,
    ];
    final activeIcons = [
      Icons.home,
      Icons.map,
      Icons.description,
      Icons.person,
    ];

    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE4E7E2), width: 1)),
      ),
      padding: const EdgeInsets.fromLTRB(12, 9, 12, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ...List.generate(
            4,
            (i) => _buildNavItem(
              label: items[i],
              icon: selectedIndex == i ? activeIcons[i] : icons[i],
              isSelected: selectedIndex == i,
              onTap: () => onTap(i),
            ),
          ),
          _buildFAB(),
        ],
      ),
    );
  }

  Widget _buildSurveyorNav() {
    final items = ['Tugas', 'Peta', 'Sinkron', 'Riwayat', 'Akun'];
    final icons = [
      Icons.assignment_outlined,
      Icons.map_outlined,
      Icons.sync_outlined,
      Icons.history_outlined,
      Icons.person_outline,
    ];
    final activeIcons = [
      Icons.assignment,
      Icons.map,
      Icons.sync,
      Icons.history,
      Icons.person,
    ];

    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE4E7E2), width: 1)),
      ),
      padding: const EdgeInsets.fromLTRB(12, 9, 12, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(
          5,
          (i) => _buildNavItem(
            label: items[i],
            icon: selectedIndex == i ? activeIcons[i] : icons[i],
            isSelected: selectedIndex == i,
            onTap: () => onTap(i),
            flex: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    int flex = 1,
  }) {
    return Expanded(
      flex: flex,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? AppColors.primary : AppColors.textTertiary,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return GestureDetector(
      onTap: () => onTap(2), // Center FAB position
      child: Container(
        width: 50,
        height: 50,
        margin: const EdgeInsets.only(top: -14),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppRadius.x16),
          boxShadow: AppShadows.fab,
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}

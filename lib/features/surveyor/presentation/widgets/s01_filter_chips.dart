import 'package:flutter/material.dart';
import '../../../../theme/tokens.dart';

/// Filter chip data model
class S01FilterChipData {
  final int index;
  final String label;

  const S01FilterChipData({required this.index, required this.label});
}

/// Horizontal scrollable row of filter chips for surveyor home screen.
///
/// Chips: "Hari ini", "Terlambat", "Belum diunduh"
///
/// Supports [selectedIndex] state (0, 1, 2 or null for all selected).
/// Callbacks: [onChipSelected] with int? index.
class S01FilterChips extends StatelessWidget {
  /// Currently selected chip index (0, 1, 2), or null for "all" selected.
  final int? selectedIndex;

  /// Callback when a chip is selected. Pass null to deselect all.
  final ValueChanged<int?> onChipSelected;

  const S01FilterChips({
    super.key,
    required this.selectedIndex,
    required this.onChipSelected,
  });

  static const _chips = [
    S01FilterChipData(index: 0, label: 'Hari ini'),
    S01FilterChipData(index: 1, label: 'Terlambat'),
    S01FilterChipData(index: 2, label: 'Belum diunduh'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: _chips.map((chip) {
          final isSelected = chip.index == selectedIndex;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: _S01FilterChip(
              label: chip.label,
              isSelected: isSelected,
              onTap: () {
                if (isSelected) {
                  // Deselect if already selected (pass null)
                  onChipSelected(null);
                } else {
                  onChipSelected(chip.index);
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _S01FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _S01FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : AppColors.bgSurface,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderCard,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
            fontSize: AppTypography.size12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

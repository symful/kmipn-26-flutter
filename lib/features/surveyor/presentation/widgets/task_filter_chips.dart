import 'package:flutter/material.dart';
import '../../../../theme/tokens.dart';

/// Filter chip data model with count
class TaskFilterChipData {
  final int index;
  final String label;
  final int count;

  const TaskFilterChipData({
    required this.index,
    required this.label,
    required this.count,
  });
}

/// Horizontal scrollable row of filter chips for surveyor home screen.
///
/// Chips: "Hari ini", "Terlambat", "Belum diunduh"
///
/// Supports [selectedIndex] state (0, 1, 2 or null for all selected).
/// Callbacks: [onChipSelected] with int? index.
class TaskFilterChips extends StatelessWidget {
  /// Currently selected chip index (0, 1, 2), or null for "all" selected.
  final int? selectedIndex;

  /// Callback when a chip is selected. Pass null to deselect all.
  final ValueChanged<int?> onChipSelected;

  /// Count for "Hari ini" chip
  final int todayCount;

  /// Count for "Terlambat" chip
  final int overdueCount;

  /// Count for "Belum diunduh" chip
  final int notDownloadedCount;

  const TaskFilterChips({
    super.key,
    required this.selectedIndex,
    required this.onChipSelected,
    this.todayCount = 0,
    this.overdueCount = 0,
    this.notDownloadedCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final chips = [
      TaskFilterChipData(index: 0, label: 'Hari ini', count: todayCount),
      TaskFilterChipData(index: 1, label: 'Terlambat', count: overdueCount),
      TaskFilterChipData(
        index: 2,
        label: 'Belum diunduh',
        count: notDownloadedCount,
      ),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: SigapSpacing.lg,
        vertical: SigapSpacing.sm,
      ),
      child: Row(
        children: chips.map((chip) {
          final isSelected = chip.index == selectedIndex;
          return Padding(
            padding: const EdgeInsets.only(right: SigapSpacing.sm),
            child: _TaskFilterChip(
              label: chip.label,
              count: chip.count,
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

class _TaskFilterChip extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  const _TaskFilterChip({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  /// S-01 design tokens for each chip variant
  Color get _backgroundColor {
    if (label == 'Hari ini') {
      // Dark pill for "Hari ini"
      return isSelected
          ? SigapColors.phoneBezel
          : SigapColors.phoneBezel.withValues(alpha: 0.7);
    } else if (label == 'Terlambat') {
      // Red background for overdue - dangerBg
      return SigapColors.dangerBg; // #f8e2de
    }
    // White background for "Belum diunduh"
    return SigapColors.bgCard; // #ffffff
  }

  Color get _textColor {
    if (label == 'Hari ini') {
      return Colors.white;
    } else if (label == 'Terlambat') {
      return SigapColors.dangerTextStrong; // #a5271a
    }
    return isSelected
        ? SigapColors.textSecondary
        : SigapColors.textTertiary; // #3a3f45 / #616770
  }

  Color get _borderColor {
    if (label == 'Hari ini') {
      return Colors.transparent;
    } else if (label == 'Terlambat') {
      return SigapColors.dangerBorder; // #ecc4bd
    }
    return SigapColors.border; // #e4e7e2
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: SigapSpacing.md,
          vertical: SigapSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: _backgroundColor,
          borderRadius: BorderRadius.circular(SigapRadius.pill),
          border: Border.all(color: _borderColor, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: _textColor,
                fontSize: SigapTypography.size12,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (count > 0) ...[
              Text(
                ' $count',
                style: TextStyle(
                  color: _textColor.withValues(alpha: 0.7),
                  fontSize: SigapTypography.size12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:sigap/theme/tokens.dart';

/// Toggleable filter chip for W-02, P-02 filter patterns.
///
/// A pill-shaped chip that toggles between selected and unselected states.
/// Use in horizontal filter rows for category/status filtering.
///
/// **Design spec:** Container with border, radius [SigapRadius.pill] (999px),
/// tap to toggle. Selected state uses primary color fill;
/// unselected uses border-only style.
class SigapFilterChip extends StatelessWidget {
  /// The label text to display.
  final String label;

  /// Whether this chip is currently selected.
  final bool isSelected;

  /// Callback when the chip is tapped.
  final VoidCallback? onTap;

  /// Background color when selected. Defaults to [SigapColors.primary].
  final Color? selectedColor;

  /// Text color when selected. Defaults to white.
  final Color? selectedTextColor;

  /// Border color when unselected. Defaults to [SigapColors.border].
  final Color? unselectedBorderColor;

  /// Text color when unselected. Defaults to [SigapColors.textTertiary].
  final Color? unselectedTextColor;

  const SigapFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    this.onTap,
    this.selectedColor,
    this.selectedTextColor,
    this.unselectedBorderColor,
    this.unselectedTextColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveSelectedColor = selectedColor ?? SigapColors.primary;
    final effectiveSelectedTextColor = selectedTextColor ?? SigapColors.surface;
    final effectiveUnselectedBorderColor =
        unselectedBorderColor ?? SigapColors.border;
    final effectiveUnselectedTextColor =
        unselectedTextColor ?? SigapColors.textTertiary;

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
          color: isSelected ? effectiveSelectedColor : Colors.transparent,
          borderRadius: BorderRadius.circular(SigapRadius.pill),
          border: Border.all(
            color: isSelected
                ? effectiveSelectedColor
                : effectiveUnselectedBorderColor,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: SigapTypography.bodySmall,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? effectiveSelectedTextColor
                : effectiveUnselectedTextColor,
          ),
        ),
      ),
    );
  }
}

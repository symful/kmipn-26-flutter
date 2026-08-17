import 'package:flutter/material.dart';
import '../../../../theme/tokens.dart';

/// S-04 Radio button group for rekomendasi (recommendation) selection.
///
/// Displays a vertical list of radio options for selecting the recommendation
/// result of an item during surveyor visit form.
///
/// Options are: "Normal", "Perbaikan", "Penggantian", "Darurat"
///
/// Design tokens used:
/// - Selected radio: AppColors.primary (#0F7A6B) fill
/// - Unselected radio: AppColors.borderSoft (#D3D7D0) border
/// - Label text: AppColors.textPrimary (#17191C)
/// - Description text: AppColors.textTertiary (#616770)
/// - Row spacing: AppSpacing.sm (8px)
///
/// Example:
/// ```dart
/// RekomendasiSelector(
///   selectedValue: 'Normal',
///   options: ['Normal', 'Perbaikan', 'Penggantian', 'Darurat'],
///   onChanged: (value) => print('Selected: $value'),
/// )
/// ```
class RekomendasiSelector extends StatelessWidget {
  /// Currently selected value.
  final String? selectedValue;

  /// List of option labels.
  final List<String> options;

  /// Callback when an option is selected.
  final ValueChanged<String> onChanged;

  /// Creates a rekomendasi radio button group.
  ///
  /// All parameters are required.
  const RekomendasiSelector({
    super.key,
    required this.selectedValue,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < options.length; i++) ...[
          _RadioOption(
            label: options[i],
            isSelected: selectedValue == options[i],
            onTap: () => onChanged(options[i]),
          ),
          if (i < options.length - 1) const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _RadioOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _RadioOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _RadioCircle(isSelected: isSelected),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: AppTypography.size13,
                height: AppTypography.lineHeight140,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RadioCircle extends StatelessWidget {
  final bool isSelected;

  const _RadioCircle({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? AppColors.primary : Colors.transparent,
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.borderSoft,
          width: 2,
        ),
      ),
      child: isSelected
          ? const Center(
              child: Icon(Icons.circle, size: 10, color: Colors.white),
            )
          : null,
    );
  }
}

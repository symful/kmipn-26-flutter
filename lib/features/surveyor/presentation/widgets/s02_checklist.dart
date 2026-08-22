import 'package:flutter/material.dart';
import '../../../../theme/tokens.dart';

/// S-02 Checklist widget for surveyor task detail screen.
///
/// Displays a numbered list of mandatory checklist items with checkboxes.
/// Each item shows an asterisk (*) indicator for required items.
/// Checked items display with strikethrough and muted color.
///
/// Design tokens used:
/// - Checkbox checked: AppColors.primary (#0F7A6B)
/// - Checkbox unchecked: AppColors.bgSoft (#EEF0EC)
/// - Item text: AppColors.textPrimary (#17191C)
/// - Checked text: AppColors.textDisabled (#8A9099) with strikethrough
/// - Number badge: AppColors.primaryLight background, AppColors.primaryDark text
/// - Asterisk: AppColors.danger (#C0392B)
///
/// Example:
/// ```dart
/// S02Checklist(
///   items: ['Periksa kondisi jalan', 'Foto lokasi', 'Tanda tangan surveyor'],
///   checkedItems: {0, 1},
///   onItemToggled: (index) { /* Handle toggle */ },
/// )
/// ```
class S02Checklist extends StatelessWidget {
  /// List of checklist item texts.
  final List<String> items;

  /// Set of indices of checked items.
  final Set<int> checkedItems;

  /// Callback when an item is toggled.
  final void Function(int index) onItemToggled;

  /// Creates a checklist widget.
  ///
  /// All parameters are required.
  const S02Checklist({
    super.key,
    required this.items,
    required this.checkedItems,
    required this.onItemToggled,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < items.length; i++) ...[
          _ChecklistItem(
            index: i,
            text: items[i],
            isChecked: checkedItems.contains(i),
            onTap: () => onItemToggled(i),
          ),
          if (i < items.length - 1) const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _ChecklistItem extends StatelessWidget {
  final int index;
  final String text;
  final bool isChecked;
  final VoidCallback onTap;

  const _ChecklistItem({
    required this.index,
    required this.text,
    required this.isChecked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Number badge
          _NumberBadge(number: index + 1),
          const SizedBox(width: AppSpacing.sm),

          // Checkbox
          _Checkbox(isChecked: isChecked),
          const SizedBox(width: AppSpacing.x9),

          // Asterisk indicator
          Text(
            '*',
            style: TextStyle(
              fontSize: AppTypography.size13,
              fontWeight: FontWeight.w700,
              color: isChecked ? AppColors.textDisabled : AppColors.danger,
            ),
          ),
          const SizedBox(width: AppSpacing.xxs),

          // Item text
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: AppTypography.size13,
                height: AppTypography.lineHeight140,
                color: isChecked
                    ? AppColors.textDisabled
                    : AppColors.textPrimary,
                decoration: isChecked ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NumberBadge extends StatelessWidget {
  final int number;

  const _NumberBadge({required this.number});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Center(
        child: Text(
          '$number',
          style: const TextStyle(
            fontSize: AppTypography.size11,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryDark,
          ),
        ),
      ),
    );
  }
}

class _Checkbox extends StatelessWidget {
  final bool isChecked;

  const _Checkbox({required this.isChecked});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: isChecked ? AppColors.primary : AppColors.bgSoft,
        borderRadius: BorderRadius.circular(5),
        border: isChecked
            ? null
            : Border.all(color: AppColors.borderSoft, width: 1.5),
      ),
      child: isChecked
          ? const Center(
              child: Icon(Icons.check, size: 12, color: Colors.white),
            )
          : null,
    );
  }
}

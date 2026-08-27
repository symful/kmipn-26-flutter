import 'package:flutter/material.dart';
import '../../../../theme/tokens.dart';

/// S-02 Checklist widget for surveyor task detail screen.
///
/// Displays a numbered list of mandatory checklist items with checkboxes.
/// Each item shows an asterisk (*) indicator for required items.
/// Checked items display with strikethrough and muted color.
///
/// Design tokens used:
/// - Checkbox checked: SigapColors.primary (#0F7A6B)
/// - Checkbox unchecked: SigapColors.bgSoft (#EEF0EC)
/// - Item text: SigapColors.textPrimary (#17191C)
/// - Checked text: SigapColors.textDisabled (#8A9099) with strikethrough
/// - Number badge: SigapColors.primaryLight background, SigapColors.primaryDark text
/// - Asterisk: SigapColors.danger (#C0392B)
///
/// Example:
/// ```dart
/// S02Checklist(
///   items: ['Periksa kondisi jalan', 'Foto lokasi', 'Tanda tangan surveyor'],
///   checkedItems: {0, 1},
///   onItemToggled: (index) { /* Handle toggle */ },
/// )
/// ```
/// S-02 Checklist widget for surveyor task detail screen.
///
/// Displays a mandatory checklist card with 20x20px checkboxes and 1px dividers.
class S02Checklist extends StatelessWidget {
  /// List of checklist item texts.
  final List<String> items;

  /// Set of indices of checked items.
  final Set<int> checkedItems;

  /// Callback when an item is toggled.
  final void Function(int index) onItemToggled;

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
        const Text(
          'CHECKLIST WAJIB',
          style: TextStyle(
            fontSize: SigapTypography.size11,
            fontWeight: FontWeight.w700,
            color: SigapColors.textTertiary,
            letterSpacing: 0.04 * 11,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: SigapColors.borderCard),
            borderRadius: BorderRadius.circular(SigapRadius.x12),
          ),
          child: Column(
            children: [
              for (int i = 0; i < items.length; i++) ...[
                _ChecklistItem(
                  text: items[i],
                  isChecked: checkedItems.contains(i),
                  onTap: () => onItemToggled(i),
                  showDivider: i < items.length - 1,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ChecklistItem extends StatelessWidget {
  final String text;
  final bool isChecked;
  final VoidCallback onTap;
  final bool showDivider;

  const _ChecklistItem({
    required this.text,
    required this.isChecked,
    required this.onTap,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          border: showDivider
              ? const Border(bottom: BorderSide(color: Color(0xFFEEF0EC)))
              : null,
        ),
        child: Row(
          children: [
            // 20x20 Checkbox with radius 6 and border #cfd3cc
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isChecked ? SigapColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isChecked ? SigapColors.primary : const Color(0xFFCFD3CC),
                  width: 2,
                ),
              ),
              child: isChecked
                  ? const Center(
                      child: Icon(Icons.check, size: 13, color: Colors.white),
                    )
                  : null,
            ),
            const SizedBox(width: 10),

            // Item text
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: SigapTypography.size13,
                  color: isChecked
                      ? SigapColors.textDisabled
                      : SigapColors.textPrimary,
                  decoration: isChecked ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:sigap/l10n/strings.dart';
import 'package:sigap/theme/tokens.dart';

/// S-01 Sort Row widget for surveyor home screen.
///
/// Row containing a sort dropdown and "Unduh batch" link.
class TaskSortRow extends StatelessWidget {
  /// Currently selected sort value.
  final String selectedValue;

  /// Callback when sort value changes.
  final ValueChanged<String> onSortChanged;

  /// Callback when "Unduh batch" is tapped.
  final VoidCallback onUnduhBatchTap;

  const TaskSortRow({
    super.key,
    required this.selectedValue,
    required this.onSortChanged,
    required this.onUnduhBatchTap,
  });

  static const _sortOptions = [
    Strings.terbaru,
    Strings.slaTerdekat,
    'Prioritas',
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Sort dropdown
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: SigapColors.borderCard),
            borderRadius: BorderRadius.circular(SigapRadius.sm),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: SigapSpacing.sm,
            vertical: SigapSpacing.xs,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _sortOptions.contains(selectedValue)
                  ? selectedValue
                  : _sortOptions.first,
              items: _sortOptions.map((option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(
                    option,
                    style: const TextStyle(
                      fontSize: SigapTypography.size12,
                      color: SigapColors.textPrimary,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  onSortChanged(value);
                }
              },
            ),
          ),
        ),
        const Spacer(),
        // Unduh batch link with hover underline
        _UnduhBatchLink(onTap: onUnduhBatchTap),
      ],
    );
  }
}

class _UnduhBatchLink extends StatefulWidget {
  final VoidCallback onTap;

  const _UnduhBatchLink({required this.onTap});

  @override
  State<_UnduhBatchLink> createState() => _UnduhBatchLinkState();
}

class _UnduhBatchLinkState extends State<_UnduhBatchLink> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: SigapSpacing.xs,
            vertical: SigapSpacing.xs,
          ),
          child: Text(
            'Unduh batch',
            style: TextStyle(
              fontSize: SigapTypography.size12,
              fontWeight: FontWeight.w600,
              color: SigapColors.primary,
              decoration: _isHovered
                  ? TextDecoration.underline
                  : TextDecoration.none,
              decorationColor: SigapColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}

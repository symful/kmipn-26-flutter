import 'package:flutter/material.dart';
import 'package:sigap/l10n/generated/app_localizations.dart';
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

  // Using localization keys; labels computed in build()
  static const _sortKeys = ['terbaru', 'slaTerdekat', 'prioritas'];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final sortOptions = [l10n.terbaru, l10n.slaTerdekat, 'Prioritas'];

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
              value: _sortKeys.contains(selectedValue)
                  ? selectedValue
                  : _sortKeys.first,
              items: List.generate(_sortKeys.length, (i) {
                return DropdownMenuItem<String>(
                  value: _sortKeys[i],
                  child: Text(
                    sortOptions[i],
                    style: const TextStyle(
                      fontSize: SigapTypography.bodySmall,
                      color: SigapColors.textPrimary,
                    ),
                  ),
                );
              }),
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
              fontSize: SigapTypography.bodySmall,
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

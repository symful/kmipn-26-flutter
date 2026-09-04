import 'package:flutter/material.dart';
import 'package:sigap/l10n/generated/app_localizations.dart';
import 'package:sigap/theme/tokens.dart';

/// A generic filter bottom sheet with FilterChips.
///
/// Usage:
/// ```dart
/// FilterBottomSheet<String>(
///   title: 'Filter Status',
///   options: [
///     ('all', 'Semua'),
///     ('active', 'Aktif'),
///     ('closed', 'Ditutup'),
///   ],
///   selected: _selectedStatus,
///   onApply: (value) => setState(() => _selectedStatus = value),
/// )
/// ```
class FilterBottomSheet<T extends Object> extends StatefulWidget {
  /// Creates a [FilterBottomSheet].
  ///
  /// - [title]: Sheet header title
  /// - [options]: List of (value, label) tuples for filter chips
  /// - [selected]: Currently selected value (null = none selected)
  /// - [onApply]: Callback with selected value when Apply is pressed
  /// - [onReset]: Optional callback when Reset is pressed
  const FilterBottomSheet({
    super.key,
    required this.title,
    required this.options,
    required this.selected,
    required this.onApply,
    this.onReset,
    this.allowDeselect = true,
  });

  /// Sheet header title.
  final String title;

  /// List of (value, label) tuples for filter chips.
  final List<(T, String)> options;

  /// Currently selected value.
  final T? selected;

  /// Callback with selected value when Apply is pressed.
  final void Function(T?) onApply;

  /// Optional callback when Reset is pressed.
  final VoidCallback? onReset;

  /// If true, tapping selected chip deselects it. Defaults to true.
  final bool allowDeselect;

  @override
  State<FilterBottomSheet<T>> createState() => _FilterBottomSheetState<T>();
}

class _FilterBottomSheetState<T extends Object>
    extends State<FilterBottomSheet<T>> {
  late T? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.selected;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.only(
        left: SigapSpacing.lg,
        right: SigapSpacing.lg,
        top: SigapSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + SigapSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: SigapTypography.sectionTitle,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: SigapSpacing.lg),
          Wrap(
            spacing: SigapSpacing.sm,
            runSpacing: SigapSpacing.sm,
            children: widget.options.map((opt) {
              final isSelected = _selected == opt.$1;
              return FilterChip(
                label: Text(opt.$2),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (widget.allowDeselect && selected && isSelected) {
                      _selected = null;
                    } else {
                      _selected = selected ? opt.$1 : null;
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: SigapSpacing.lg),
          Row(
            children: [
              if (widget.onReset != null)
                TextButton(
                  onPressed: () {
                    setState(() => _selected = null);
                    widget.onReset?.call();
                  },
                  child: Text(l10n.reset),
                ),
              const Spacer(),
              FilledButton(
                onPressed: () {
                  widget.onApply(_selected);
                  Navigator.pop(context);
                },
                child: Text(l10n.terapkan),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Helper to show a filter bottom sheet from context.
Future<T?> showFilterSheet<T extends Object>({
  required BuildContext context,
  required String title,
  required List<(T, String)> options,
  required T? selected,
  required void Function(T?) onApply,
  VoidCallback? onReset,
  bool allowDeselect = true,
}) async {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Container(
      decoration: const BoxDecoration(
        color: SigapColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: FilterBottomSheet<T>(
        title: title,
        options: options,
        selected: selected,
        onApply: onApply,
        onReset: onReset,
        allowDeselect: allowDeselect,
      ),
    ),
  );
}

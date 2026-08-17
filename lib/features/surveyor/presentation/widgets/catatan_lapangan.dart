import 'package:flutter/material.dart';
import 'package:sigap/theme/tokens.dart';

/// Catatan lapangan (field notes) text input widget.
///
/// A multiline text field for entering field notes during a surveyor visit.
/// Displays a label "Catatan lapangan" above the input and an optional
/// character count indicator below the input.
///
/// Design tokens used:
/// - Input border: AppColors.borderCard (#E4E7E2)
/// - Input background: AppColors.bgCard (#FFFFFF)
/// - Input text: AppColors.textPrimary (#17191C)
/// - Placeholder text: AppColors.textTertiary (#616770)
/// - Label text: AppColors.textPrimary (#17191C)
/// - Character count text: AppColors.textTertiary (#616770)
/// - Focus border: AppColors.primary (#0F7A6B)
/// - Border radius: AppRadius.md (10px)
/// - Label font: AppTypography.size12, fontWeight 600
/// - Input font: AppTypography.size13
/// - Character count font: AppTypography.size11
///
/// Example:
/// ```dart
/// // Basic usage with onChanged
/// CatatanLapangan(
///   onChanged: (value) => print('Notes: $value'),
/// )
///
/// // With controller
/// final controller = TextEditingController();
/// CatatanLapangan(
///   controller: controller,
///   maxCharacters: 500,
/// )
/// ```
class CatatanLapangan extends StatelessWidget {
  /// Optional controller for the text field.
  /// If provided, the widget will use this controller directly.
  /// Cannot be used together with [onChanged].
  final TextEditingController? controller;

  /// Optional callback when text changes.
  /// Cannot be used together with [controller].
  final ValueChanged<String>? onChanged;

  /// Optional maximum number of characters allowed.
  /// If provided, a character count indicator will be shown.
  /// Default: no limit (no character count shown).
  final int? maxCharacters;

  /// Optional initial text value.
  /// Only used when [controller] is not provided.
  final String? initialValue;

  /// Optional hint/placeholder text.
  /// Default: "Tambahkan catatan..."
  final String? hintText;

  /// Number of visible lines for the text field.
  /// Default: 4
  final int minLines;

  /// Maximum number of lines the text field can grow to.
  /// Default: 8
  final int maxLines;

  /// Creates a catatan lapangan text input widget.
  ///
  /// Either [controller] or [onChanged] must be provided, but not both.
  const CatatanLapangan({
    super.key,
    this.controller,
    this.onChanged,
    this.maxCharacters,
    this.initialValue,
    this.hintText,
    this.minLines = 4,
    this.maxLines = 8,
  }) : assert(
         controller == null || onChanged == null,
         'Cannot provide both controller and onChanged',
       );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        const Text(
          'Catatan lapangan',
          style: TextStyle(
            fontSize: AppTypography.size12,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.x6),

        // Text input
        _CatatanTextField(
          controller: controller,
          onChanged: onChanged,
          initialValue: controller == null ? initialValue : null,
          hintText: hintText ?? 'Tambahkan catatan...',
          minLines: minLines,
          maxLines: maxLines,
          maxCharacters: maxCharacters,
        ),

        // Character count (only shown if maxCharacters is set)
        if (maxCharacters != null) ...[
          const SizedBox(height: AppSpacing.x4),
          _CharacterCount(
            controller: controller,
            onChanged: onChanged,
            maxCharacters: maxCharacters!,
          ),
        ],
      ],
    );
  }
}

/// Internal text field widget with styling.
class _CatatanTextField extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String? initialValue;
  final String hintText;
  final int minLines;
  final int maxLines;
  final int? maxCharacters;

  const _CatatanTextField({
    this.controller,
    this.onChanged,
    this.initialValue,
    required this.hintText,
    required this.minLines,
    required this.maxLines,
    this.maxCharacters,
  });

  @override
  Widget build(BuildContext context) {
    // Use TextFormField if we have a controller, otherwise use TextField with onChanged
    if (controller != null) {
      return TextFormField(
        controller: controller,
        minLines: minLines,
        maxLines: maxLines,
        maxLength: maxCharacters,
        decoration: _inputDecoration(hintText),
        style: const TextStyle(
          fontSize: AppTypography.size13,
          color: AppColors.textPrimary,
          height: AppTypography.lineHeight140,
        ),
        buildCounter:
            (context, {required currentLength, required isFocused, maxLength}) {
              return null; // Hide default counter since we show our own
            },
      );
    } else {
      return TextField(
        onChanged: onChanged,
        minLines: minLines,
        maxLines: maxLines,
        maxLength: maxCharacters,
        decoration: _inputDecoration(hintText),
        style: const TextStyle(
          fontSize: AppTypography.size13,
          color: AppColors.textPrimary,
          height: AppTypography.lineHeight140,
        ),
        buildCounter:
            (context, {required currentLength, required isFocused, maxLength}) {
              return null; // Hide default counter since we show our own
            },
      );
    }
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        fontSize: AppTypography.size13,
        color: AppColors.textTertiary,
        height: AppTypography.lineHeight140,
      ),
      filled: true,
      fillColor: AppColors.bgCard,
      contentPadding: const EdgeInsets.all(AppSpacing.md),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.borderCard),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.borderCard),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }
}

/// Internal character count indicator widget.
class _CharacterCount extends StatefulWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final int maxCharacters;

  const _CharacterCount({
    this.controller,
    this.onChanged,
    required this.maxCharacters,
  });

  @override
  State<_CharacterCount> createState() => _CharacterCountState();
}

class _CharacterCountState extends State<_CharacterCount> {
  int _currentLength = 0;

  @override
  void initState() {
    super.initState();
    _currentLength = widget.controller?.text.length ?? 0;
    widget.controller?.addListener(_updateLength);
  }

  void _updateLength() {
    setState(() {
      _currentLength = widget.controller?.text.length ?? 0;
    });
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_updateLength);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isOverLimit = _currentLength > widget.maxCharacters;
    final isNearLimit =
        !isOverLimit && _currentLength > (widget.maxCharacters * 0.8);

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          '$_currentLength/${widget.maxCharacters}',
          style: TextStyle(
            fontSize: AppTypography.size11,
            color: isOverLimit
                ? AppColors.danger
                : isNearLimit
                ? AppColors.warning
                : AppColors.textTertiary,
            fontWeight: isOverLimit ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

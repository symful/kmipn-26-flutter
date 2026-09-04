import 'package:flutter/material.dart';
import 'package:sigap/theme/tokens.dart';

/// Catatan lapangan (field notes) text input widget.
///
/// A multiline text field for entering field notes during a surveyor visit.
/// Displays a label "Catatan lapangan" above the input and an optional
/// character count indicator below the input.
///
/// Design tokens used:
/// - Input border: SigapColors.borderCard (#E4E7E2)
/// - Input background: SigapColors.bgCard (#FFFFFF)
/// - Input text: SigapColors.textPrimary (#17191C)
/// - Placeholder text: SigapColors.textTertiary (#616770)
/// - Label text: SigapColors.textPrimary (#17191C)
/// - Character count text: SigapColors.textTertiary (#616770)
/// - Focus border: SigapColors.primary (#0F7A6B)
/// - Border radius: SigapRadius.md (10px)
/// - Label font: SigapTypography.bodySmall, fontWeight 600
/// - Input font: SigapTypography.bodyText
/// - Character count font: SigapTypography.captionMedium
///
/// Example:
/// ```dart
/// // Basic usage with onChanged
/// CatatanLapangan(
///   onChanged: (value) { /* Handle notes change */ },
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
            fontSize: SigapTypography.bodySmall,
            fontWeight: FontWeight.w600,
            color: SigapColors.textPrimary,
          ),
        ),
        const SizedBox(height: SigapSpacing.x6),

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
          const SizedBox(height: SigapSpacing.x4),
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
          fontSize: SigapTypography.bodyText,
          color: SigapColors.textPrimary,
          height: SigapTypography.lineHeight140,
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
          fontSize: SigapTypography.bodyText,
          color: SigapColors.textPrimary,
          height: SigapTypography.lineHeight140,
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
        fontSize: SigapTypography.bodyText,
        color: SigapColors.textTertiary,
        height: SigapTypography.lineHeight140,
      ),
      filled: true,
      fillColor: SigapColors.bgCard,
      contentPadding: const EdgeInsets.all(SigapSpacing.md),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(SigapRadius.md),
        borderSide: const BorderSide(color: SigapColors.borderCard),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(SigapRadius.md),
        borderSide: const BorderSide(color: SigapColors.borderCard),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(SigapRadius.md),
        borderSide: const BorderSide(color: SigapColors.primary, width: 1.5),
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
            fontSize: SigapTypography.captionMedium,
            color: isOverLimit
                ? SigapColors.danger
                : isNearLimit
                ? SigapColors.warning
                : SigapColors.textTertiary,
            fontWeight: isOverLimit ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

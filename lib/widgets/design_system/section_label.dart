import 'package:flutter/material.dart';
import 'package:sigap/theme/tokens.dart';

/// Unified section label / header widget.
///
/// Supports both plain text labels and colored variants with accent bar
/// (used by sync_center_screen). For the colored variant, pass a [color];
/// the text will also render in that color and an accent bar is shown.
class SectionLabel extends StatelessWidget {
  final String label;
  final Color? color;
  final TextStyle? style;
  final EdgeInsets? padding;

  const SectionLabel({
    super.key,
    required this.label,
    this.color,
    this.style,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final Color effectiveColor = color ?? SigapColors.textSecondary;
    final double effectiveFontSize = style?.fontSize ?? SigapTypography.bodyText;
    final FontWeight effectiveFontWeight = style?.fontWeight ?? FontWeight.bold;

    if (color != null) {
      // Colored variant: shows an accent bar beside the text.
      return Padding(
        padding: padding ?? const EdgeInsets.only(bottom: SigapSpacing.sm),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 16,
              decoration: BoxDecoration(
                color: effectiveColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: SigapSpacing.sm),
            Text(
              label,
              style: TextStyle(
                fontSize: effectiveFontSize,
                fontWeight: effectiveFontWeight,
                color: effectiveColor,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: padding ?? const EdgeInsets.only(bottom: SigapSpacing.sm),
      child: Text(
        label,
        style: TextStyle(
          fontSize: effectiveFontSize,
          fontWeight: effectiveFontWeight,
          color: effectiveColor,
        ),
      ),
    );
  }
}

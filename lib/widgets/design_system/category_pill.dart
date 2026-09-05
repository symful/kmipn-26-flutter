import 'package:flutter/material.dart';
import 'package:sigap/theme/tokens.dart';

/// Category badge pill for displaying category labels.
///
/// Used in S-02 design pattern for category badges. Renders as a small
/// pill-shaped container with monospace font styling.
///
/// **Design spec:** Container with [SigapColors.bgSoft] background,
/// [SigapTypography.fontFamilyMono] font, radius [SigapRadius.sm] (5px).
class CategoryPill extends StatelessWidget {
  /// The category label text to display.
  final String label;

  /// Background color of the pill. Defaults to [SigapColors.bgSoft].
  final Color? backgroundColor;

  /// Text color for the label. Defaults to [SigapColors.textSecondary].
  final Color? textColor;

  const CategoryPill({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBg = backgroundColor ?? SigapColors.bgSoft;
    final effectiveTextColor = textColor ?? SigapColors.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SigapSpacing.sm,
        vertical: SigapSpacing.x4,
      ),
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: BorderRadius.circular(SigapRadius.sm),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: SigapTypography.fontFamilyMono,
          fontSize: SigapTypography.captionMedium,
          fontWeight: FontWeight.w600,
          color: effectiveTextColor,
        ),
      ),
    );
  }
}

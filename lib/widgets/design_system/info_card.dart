import 'package:flutter/material.dart';
import 'package:sigap/theme/tokens.dart';

/// Info card with icon and text for informational callouts.
///
/// Used in M-14 "who can see" info box pattern. Displays an icon
/// alongside descriptive text in a soft-background container.
///
/// **Design spec:** Container with [SigapColors.bgSoft] background,
/// icon + text row, radius [SigapRadius.md] (11px).
class InfoCard extends StatelessWidget {
  /// Icon displayed at the start of the card.
  final IconData icon;

  /// Descriptive text shown next to the icon.
  final String text;

  /// Background color of the card. Defaults to [SigapColors.bgSoft].
  final Color? backgroundColor;

  /// Text color. Defaults to [SigapColors.textSecondary].
  final Color? textColor;

  /// Icon color. Defaults to [SigapColors.textTertiary].
  final Color? iconColor;

  const InfoCard({
    super.key,
    required this.icon,
    required this.text,
    this.backgroundColor,
    this.textColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBg = backgroundColor ?? SigapColors.bgSoft;
    final effectiveTextColor = textColor ?? SigapColors.textSecondary;
    final effectiveIconColor = iconColor ?? SigapColors.textTertiary;

    return Container(
      padding: const EdgeInsets.all(SigapSpacing.md),
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: BorderRadius.circular(SigapRadius.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: effectiveIconColor),
          const SizedBox(width: SigapSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: SigapTypography.bodySmall,
                fontWeight: FontWeight.w500,
                color: effectiveTextColor,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:sigap/theme/tokens.dart';
import 'package:sigap/widgets/design_system/a11y.dart';

/// A section header row with a title on the left and an optional
/// action label (e.g. "Lihat Semua →") on the right.
///
/// Used throughout the app for section headers that need a tappable
/// "Lihat Semua" / "Lihat Details" link.
class SectionHeader extends StatelessWidget {
  /// The main section title text.
  final String title;

  /// Optional action label shown on the right (e.g. "Lihat Semua").
  /// If null, no action row is rendered.
  final String? actionLabel;

  /// Callback fired when the action label is tapped.
  final VoidCallback? onAction;

  /// Custom padding around the row. Defaults to `EdgeInsets.zero`.
  final EdgeInsets? padding;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: SigapTypography.size13,
              fontWeight: FontWeight.w700,
              color: SigapColors.textPrimary,
            ),
          ),
          if (actionLabel != null)
            MinTapTarget(
              semanticsLabel: '$title $actionLabel',
              child: GestureDetector(
                onTap: onAction,
                child: Text(
                  actionLabel!,
                  style: const TextStyle(
                    fontSize: SigapTypography.size12,
                    fontWeight: FontWeight.w600,
                    color: SigapColors.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

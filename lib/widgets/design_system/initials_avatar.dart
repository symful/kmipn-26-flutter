import 'package:flutter/material.dart';
import 'package:sigap/theme/tokens.dart';

/// Initials avatar displayed in a colored circle.
///
/// Used in M-05 and S-01 design patterns for showing user initials
/// in a compact circular avatar. The background color can be customized
/// or defaults to [SigapColors.primaryLight].
///
/// **Design spec:** Circle with colored background, initials text centered,
/// default radius 8-9px.
class InitialsAvatar extends StatelessWidget {
  /// The initials to display (typically 1-2 characters).
  final String initials;

  /// Background color of the circle. Defaults to [SigapColors.primaryLight].
  final Color? backgroundColor;

  /// Diameter of the avatar circle. Defaults to 34.
  final double size;

  /// Text color for the initials. Defaults to [SigapColors.primaryDark].
  final Color? textColor;

  const InitialsAvatar({
    super.key,
    required this.initials,
    this.backgroundColor,
    this.size = 34,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBg = backgroundColor ?? SigapColors.primaryLight;
    final effectiveTextColor = textColor ?? SigapColors.primaryDark;
    final displayText = initials.length > 2
        ? initials.substring(0, 2)
        : initials;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: effectiveBg, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        displayText.toUpperCase(),
        style: TextStyle(
          fontSize: size * 0.38,
          fontWeight: FontWeight.w600,
          color: effectiveTextColor,
          height: 1,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:sigap/theme/tokens.dart';

/// Reusable back arrow button with consistent 44x44 tap target.
///
/// Use instead of inline GestureDetector+Text('←') patterns.
///
/// Common pattern: back arrow → SizedBox(width) → title/subtitle column → optional trailing
class BackArrowButton extends StatelessWidget {
  /// Callback when the back arrow is tapped.
  final VoidCallback? onTap;

  /// Size of the tap target in pixels (default: 44).
  final double size;

  /// Override the arrow character (default: '←').
  final String arrow;

  const BackArrowButton({
    super.key,
    this.onTap,
    this.size = 44,
    this.arrow = '←',
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: size,
        height: size,
        child: Center(
          child: Text(
            arrow,
            style: TextStyle(
              fontSize: SigapTypography.headlineMedium,
              color: SigapColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

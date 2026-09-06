import 'package:sigap/theme/sigap_color_scheme.dart';
import 'package:flutter/material.dart';

/// Reusable back arrow button with consistent 48×48 tap target.
///
/// Use instead of inline GestureDetector+Text('←') patterns.
///
/// Common pattern: back arrow → SizedBox(width) → title/subtitle column → optional trailing
class BackArrowButton extends StatelessWidget {
  /// Callback when the back arrow is tapped.
  final VoidCallback? onTap;

  /// Size of the tap target in pixels (default: 48).
  final double size;

  const BackArrowButton({super.key, this.onTap, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: IconButton(
        icon: Icon(Icons.arrow_back_ios_new, size: 20),
        color: SigapColorScheme.of(context).textSecondary,
        onPressed: onTap,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        splashRadius: size / 2,
      ),
    );
  }
}

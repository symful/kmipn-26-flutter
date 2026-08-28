import 'package:flutter/material.dart';

/// Minimum tap target size as per accessibility guidelines (48×48px).
const double kMinTapTarget = 48.0;

/// A widget that enforces a minimum 48×48px tap target on its child.
///
/// Wraps the child in a [SizedBox] with constraints ensuring the minimum
/// tap target, and optionally adds [Semantics] for screen readers.
///
/// Usage:
/// ```dart
/// MinTapTarget(
///   semanticsLabel: 'Retry',
///   child: IconButton(icon: Icon(Icons.refresh), onPressed: onRetry),
/// )
/// ```
class MinTapTarget extends StatelessWidget {
  /// The widget to wrap.
  final Widget child;

  /// Optional semantic label for screen readers.
  /// When provided, wraps child in a [Semantics] widget.
  final String? semanticsLabel;

  const MinTapTarget({super.key, required this.child, this.semanticsLabel});

  @override
  Widget build(BuildContext context) {
    Widget result = SizedBox(
      width: kMinTapTarget,
      height: kMinTapTarget,
      child: child,
    );

    if (semanticsLabel != null) {
      result = Semantics(label: semanticsLabel, button: true, child: result);
    }

    return result;
  }
}

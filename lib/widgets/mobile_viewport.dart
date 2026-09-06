import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Keeps the mobile application mobile on Windows and wide browser windows.
class MobileViewport extends StatelessWidget {
  final Widget child;
  const MobileViewport({super.key, required this.child});
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final width = math.min(392.0, constraints.maxWidth);
      return ColoredBox(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Center(
          child: SizedBox(
            width: width,
            height: constraints.maxHeight,
            child: MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(size: Size(width, constraints.maxHeight)),
              child: child,
            ),
          ),
        ),
      );
    },
  );
}

import 'package:flutter/material.dart';
import 'package:sigap/theme/tokens.dart';

/// A simple colored dot/circle indicator.
///
/// Usage:
/// ```dart
/// LegendDot(color: SigapColors.primary)
/// ```
class LegendDot extends StatelessWidget {
  /// Creates a [LegendDot].
  ///
  /// - [color]: Fill color for the dot
  /// - [size]: Diameter of the dot (defaults to 8)
  /// - [borderRadius]: Corner radius for rectangular dots (null = circle)
  const LegendDot({
    super.key,
    required this.color,
    this.size = 8,
    this.borderRadius,
  });

  final Color color;
  final double size;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: borderRadius != null
            ? BorderRadius.circular(borderRadius!)
            : null,
        shape: borderRadius == null ? BoxShape.circle : BoxShape.rectangle,
      ),
    );
  }
}

/// A status dot showing sync/state indicator.
///
/// Usage:
/// ```dart
/// SyncDot(status: SyncStatus.synced) // green
/// SyncDot(status: SyncStatus.pending) // amber
/// SyncDot(status: SyncStatus.error) // red
/// ```
class SyncDot extends StatelessWidget {
  const SyncDot({super.key, required this.status, this.size = 10});

  final SyncStatus status;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: status.color, shape: BoxShape.circle),
    );
  }
}

/// Sync status enum with associated colors.
enum SyncStatus {
  synced,
  pending,
  error;

  Color get color {
    switch (this) {
      case SyncStatus.synced:
        return SigapColors.selesai;
      case SyncStatus.pending:
        return SigapColors.warning;
      case SyncStatus.error:
        return SigapColors.danger;
    }
  }
}

/// An urgency indicator dot (overdue = red, warning = amber).
class UrgencyDot extends StatelessWidget {
  const UrgencyDot({super.key, required this.isOverdue, this.size = 8});

  final bool isOverdue;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isOverdue ? SigapColors.danger : SigapColors.warning,
        shape: BoxShape.circle,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:sigap/theme/tokens.dart';

/// Priority level for surveyor task card.
///
/// Maps to PantauDesa design spec colors:
/// - urgent: Red stripe (#C0392B)
/// - high: Amber stripe (#B8730A)
/// - normal: Green/teal stripe (#0F7A6B)
/// - low: Gray stripe (#8A9099)
enum TaskPriority {
  /// Red stripe - requires immediate attention
  urgent,

  /// Amber stripe - high priority
  high,

  /// Green/teal stripe - normal priority
  normal,

  /// Gray stripe - low priority
  low,
}

/// Data model for a surveyor task card.
class SurveyorTaskData {
  /// Unique identifier for the task.
  final String id;

  /// Case title/description.
  final String title;

  /// Location address or description.
  final String location;

  /// Time ago string (e.g., "2 jam yang lalu", "Kemarin").
  final String timeAgo;

  /// Priority level of the task.
  final TaskPriority priority;

  const SurveyorTaskData({
    required this.id,
    required this.title,
    required this.location,
    required this.timeAgo,
    required this.priority,
  });
}

/// Task card widget with colored left border stripe indicating priority.
///
/// Displays case title, location, time ago, and priority indicator.
/// Used in the surveyor home screen task list.
///
/// Design tokens used:
/// - Urgent: SigapColors.danger (#C0392B)
/// - High: SigapColors.warning (#B8730A)
/// - Normal: SigapColors.primary (#0F7A6B)
/// - Low: SigapColors.textDisabled (#8A9099)
/// - Card background: SigapColors.bgCard (#FFFFFF)
/// - Border radius: SigapRadius.x12 (12px)
class SurveyorTaskCard extends StatelessWidget {
  /// Task data to display.
  final SurveyorTaskData task;

  /// Callback when card is tapped.
  final VoidCallback? onTap;

  const SurveyorTaskCard({super.key, required this.task, this.onTap});

  /// Returns the border color based on priority.
  Color get _borderColor {
    switch (task.priority) {
      case TaskPriority.urgent:
        return SigapColors.danger;
      case TaskPriority.high:
        return SigapColors.warning;
      case TaskPriority.normal:
        return SigapColors.primary;
      case TaskPriority.low:
        return SigapColors.textDisabled;
    }
  }

  /// Returns the priority label text.
  String get _priorityLabel {
    switch (task.priority) {
      case TaskPriority.urgent:
        return 'Urgent';
      case TaskPriority.high:
        return 'High';
      case TaskPriority.normal:
        return 'Normal';
      case TaskPriority.low:
        return 'Low';
    }
  }

  /// Returns the priority dot color.
  Color get _priorityDotColor {
    return _borderColor;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: SigapColors.bgCard,
          borderRadius: BorderRadius.circular(SigapRadius.x12),
          border: Border(left: BorderSide(color: _borderColor, width: 4)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(SigapSpacing.md),
          child: Row(
            children: [
              // Content area
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      task.title,
                      style: const TextStyle(
                        fontSize: SigapTypography.size13_5,
                        fontWeight: FontWeight.w600,
                        color: SigapColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Location
                    Text(
                      task.location,
                      style: const TextStyle(
                        fontSize: SigapTypography.size12,
                        color: SigapColors.textTertiary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Time ago
                    Text(
                      task.timeAgo,
                      style: const TextStyle(
                        fontSize: SigapTypography.size11,
                        color: SigapColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),

              // Priority indicator
              const SizedBox(width: SigapSpacing.sm),
              _PriorityIndicator(
                label: _priorityLabel,
                dotColor: _priorityDotColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Priority indicator widget with dot and label.
class _PriorityIndicator extends StatelessWidget {
  final String label;
  final Color dotColor;

  const _PriorityIndicator({required this.label, required this.dotColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SigapSpacing.x9,
        vertical: SigapSpacing.x4,
      ),
      decoration: BoxDecoration(
        color: dotColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(SigapRadius.x6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: SigapTypography.size11,
              fontWeight: FontWeight.w600,
              color: dotColor,
            ),
          ),
        ],
      ),
    );
  }
}

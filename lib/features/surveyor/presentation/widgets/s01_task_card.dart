import 'package:flutter/material.dart';
import 'package:sigap/theme/tokens.dart';

/// Priority level for surveyor task card.
///
/// Maps to PantauDesa design spec colors:
/// - urgent: Red stripe (#C0392B)
/// - high: Amber stripe (#B8730A)
/// - normal: Green/teal stripe (#0F7A6B)
/// - low: Gray stripe (#8A9099)
enum S01TaskPriority {
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
class S01TaskData {
  /// Unique identifier for the task.
  final String id;

  /// Case title/description.
  final String title;

  /// Location address or description.
  final String location;

  /// Time ago string (e.g., "2 jam yang lalu", "Kemarin").
  final String timeAgo;

  /// Priority level of the task.
  final S01TaskPriority priority;

  const S01TaskData({
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
/// - Urgent: AppColors.danger (#C0392B)
/// - High: AppColors.warning (#B8730A)
/// - Normal: AppColors.primary (#0F7A6B)
/// - Low: AppColors.textDisabled (#8A9099)
/// - Card background: AppColors.bgCard (#FFFFFF)
/// - Border radius: AppRadius.x12 (12px)
class S01TaskCard extends StatelessWidget {
  /// Task data to display.
  final S01TaskData task;

  /// Callback when card is tapped.
  final VoidCallback? onTap;

  const S01TaskCard({super.key, required this.task, this.onTap});

  /// Returns the border color based on priority.
  Color get _borderColor {
    switch (task.priority) {
      case S01TaskPriority.urgent:
        return AppColors.danger;
      case S01TaskPriority.high:
        return AppColors.warning;
      case S01TaskPriority.normal:
        return AppColors.primary;
      case S01TaskPriority.low:
        return AppColors.textDisabled;
    }
  }

  /// Returns the priority label text.
  String get _priorityLabel {
    switch (task.priority) {
      case S01TaskPriority.urgent:
        return 'Urgent';
      case S01TaskPriority.high:
        return 'High';
      case S01TaskPriority.normal:
        return 'Normal';
      case S01TaskPriority.low:
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
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(AppRadius.x12),
          border: Border(left: BorderSide(color: _borderColor, width: 4)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
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
                        fontSize: AppTypography.size13_5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Location
                    Text(
                      task.location,
                      style: const TextStyle(
                        fontSize: AppTypography.size12,
                        color: AppColors.textTertiary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Time ago
                    Text(
                      task.timeAgo,
                      style: const TextStyle(
                        fontSize: AppTypography.size11,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),

              // Priority indicator
              const SizedBox(width: AppSpacing.sm),
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
        horizontal: AppSpacing.x9,
        vertical: AppSpacing.x4,
      ),
      decoration: BoxDecoration(
        color: dotColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.x6),
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
              fontSize: AppTypography.size11,
              fontWeight: FontWeight.w600,
              color: dotColor,
            ),
          ),
        ],
      ),
    );
  }
}

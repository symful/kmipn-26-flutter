import 'package:flutter/material.dart';
import 'package:sigap/theme/tokens.dart';
import 'package:sigap/widgets/design_system/design_system.dart';

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
class TaskData {
  /// Unique identifier for the task (e.g., "TGS-3391").
  final String id;

  /// Category initials code (e.g., "JB", "JL", "AR").
  final String initials;

  /// Case title/description.
  final String title;

  /// Location address or description.
  final String location;

  /// Time ago string (e.g., "2 jam yang lalu", "Kemarin").
  final String timeAgo;

  /// Priority level of the task.
  final TaskPriority priority;

  /// SLA status label (e.g., "Terlambat 1h", "SLA 4j", "SLA besok").
  final String? slaLabel;

  /// Whether the task is downloaded for offline use.
  final bool isDownloaded;

  const TaskData({
    required this.id,
    this.initials = 'JB',
    required this.title,
    required this.location,
    required this.timeAgo,
    required this.priority,
    this.slaLabel,
    this.isDownloaded = false,
  });
}

/// Task card widget with colored left border stripe indicating priority.
class TaskCard extends StatelessWidget {
  /// Task data to display.
  final TaskData task;

  /// Callback when card is tapped.
  final VoidCallback? onTap;

  const TaskCard({super.key, required this.task, this.onTap});

  Color get _borderColor {
    switch (task.priority) {
      case TaskPriority.urgent:
        return SigapColors.danger;
      case TaskPriority.high:
        return SigapColors.warning;
      case TaskPriority.normal:
        return SigapColors.primary;
      case TaskPriority.low:
        return SigapColors.borderSoft;
    }
  }

  StatusTone get _priorityTone {
    switch (task.priority) {
      case TaskPriority.urgent:
        return StatusTone.danger;
      case TaskPriority.high:
        return StatusTone.warning;
      case TaskPriority.normal:
        return StatusTone.success;
      case TaskPriority.low:
        return StatusTone.neutral;
    }
  }

  String get _priorityLabel {
    switch (task.priority) {
      case TaskPriority.urgent:
        return 'Prioritas tinggi';
      case TaskPriority.high:
        return 'Prioritas sedang';
      case TaskPriority.normal:
        return 'Prioritas normal';
      case TaskPriority.low:
        return 'Prioritas rendah';
    }
  }

  Color get _slaBgColor {
    switch (task.priority) {
      case TaskPriority.urgent:
        return SigapColors.dangerBg;
      case TaskPriority.high:
        return SigapColors.warningBg;
      case TaskPriority.normal:
        return SigapColors.primaryLight;
      case TaskPriority.low:
        return SigapColors.bgSoft;
    }
  }

  Color get _slaTextColor {
    switch (task.priority) {
      case TaskPriority.urgent:
        return SigapColors.dangerTextStrong;
      case TaskPriority.high:
        return SigapColors.warningText;
      case TaskPriority.normal:
        return SigapColors.primaryDark;
      case TaskPriority.low:
        return SigapColors.textTertiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SigapCard(
        borderLeftColor: _borderColor,
        padding: const EdgeInsets.all(13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Avatar + Title & ID + SLA Badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: SigapColors.primaryLight,
                    borderRadius: BorderRadius.circular(SigapRadius.x8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    task.initials,
                    style: const TextStyle(
                      fontFamily: SigapTypography.fontFamilyMono,
                      fontSize: SigapTypography.size12,
                      fontWeight: FontWeight.w600,
                      color: SigapColors.primaryDark,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: const TextStyle(
                          fontSize: SigapTypography.size13_5,
                          fontWeight: FontWeight.w600,
                          color: SigapColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 1),
                      Text(
                        task.id,
                        style: const TextStyle(
                          fontFamily: SigapTypography.fontFamilyMono,
                          fontSize: SigapTypography.size11,
                          color: SigapColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (task.slaLabel != null && task.slaLabel!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: _slaBgColor,
                      borderRadius: BorderRadius.circular(SigapRadius.x6),
                    ),
                    child: Text(
                      task.slaLabel!,
                      style: TextStyle(
                        fontSize: SigapTypography.size11,
                        fontWeight: FontWeight.w700,
                        color: _slaTextColor,
                      ),
                    ),
                  ),
              ],
            ),

            // Location
            Padding(
              padding: const EdgeInsets.only(top: 11),
              child: Text(
                '📍 ${task.location}',
                style: const TextStyle(
                  fontSize: SigapTypography.size11_5,
                  color: SigapColors.textTertiary,
                ),
              ),
            ),

            // Footer Row: Priority + Offline status
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StatusPill(
                    label: _priorityLabel,
                    tone: _priorityTone,
                    showDot: true,
                  ),
                  if (task.isDownloaded)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          decoration: const BoxDecoration(
                            color: SigapColors.primaryLight,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            '↓',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: SigapColors.primaryDark,
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Text(
                          'Siap offline',
                          style: TextStyle(
                            fontSize: SigapTypography.size11,
                            fontWeight: FontWeight.w600,
                            color: SigapColors.primaryDark,
                          ),
                        ),
                      ],
                    )
                  else
                    const Text(
                      'Unduh untuk offline',
                      style: TextStyle(
                        fontSize: SigapTypography.size11,
                        fontWeight: FontWeight.w700,
                        color: SigapColors.primary,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

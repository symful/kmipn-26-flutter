import 'package:flutter/material.dart';
import 'package:sigap/theme/tokens.dart';

/// Offline availability indicator for task cards.
///
/// Shows a cloud-off icon with "Siap offline" text when the task
/// has been downloaded and is available for offline use.
///
/// Returns an empty widget when offline availability is not available.
class S01OfflineIndicator extends StatelessWidget {
  /// Whether the task has been downloaded for offline use.
  final bool isOfflineAvailable;

  const S01OfflineIndicator({super.key, required this.isOfflineAvailable});

  @override
  Widget build(BuildContext context) {
    if (!isOfflineAvailable) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.cloud_off,
          size: AppTypography.size11,
          color: AppColors.textTertiary,
        ),
        const SizedBox(width: AppSpacing.xxs),
        Text(
          'Siap offline',
          style: TextStyle(
            fontSize: AppTypography.size11,
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:sigap/theme/tokens.dart';

/// Offline ready banner for surveyor task detail screen (S-02 region).
///
/// Displays a subtle card indicating the task is available for offline use.
/// Shows a cloud-off icon with "Siap kerja offline" text.
///
/// Returns an empty widget when the task is not available for offline use.
class S02OfflineBanner extends StatelessWidget {
  /// Whether the task has been downloaded and is available for offline use.
  final bool isOfflineReady;

  const S02OfflineBanner({super.key, required this.isOfflineReady});

  @override
  Widget build(BuildContext context) {
    if (!isOfflineReady) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.warningBg,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.warningBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_off,
            size: AppTypography.size12,
            color: AppColors.warning,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            'Siap kerja offline',
            style: TextStyle(
              fontSize: AppTypography.size12,
              fontWeight: FontWeight.w500,
              color: AppColors.warningText,
            ),
          ),
        ],
      ),
    );
  }
}

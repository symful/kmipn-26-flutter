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
        horizontal: SigapSpacing.md,
        vertical: SigapSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: SigapColors.warningBg,
        borderRadius: BorderRadius.circular(SigapRadius.md),
        border: Border.all(color: SigapColors.warningBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_off,
            size: SigapTypography.size12,
            color: SigapColors.warning,
          ),
          const SizedBox(width: SigapSpacing.xs),
          Text(
            'Siap dikerjakan offline',
            style: TextStyle(
              fontSize: SigapTypography.size12,
              fontWeight: FontWeight.w500,
              color: SigapColors.warningText,
            ),
          ),
        ],
      ),
    );
  }
}

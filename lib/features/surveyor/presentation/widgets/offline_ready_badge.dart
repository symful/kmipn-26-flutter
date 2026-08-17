import 'package:flutter/material.dart';
import 'package:sigap/theme/tokens.dart';

/// Offline availability indicator for task cards.
///
/// S-01 Design:
/// - Downloaded: Shows "Siap offline" with circle+arrow icon in teal
/// - Not downloaded: Shows "Unduh untuk offline" as a teal link
class OfflineReadyBadge extends StatelessWidget {
  /// Whether the task has been downloaded for offline use.
  final bool isOfflineAvailable;

  /// Optional callback when "Unduh untuk offline" is tapped.
  final VoidCallback? onDownloadTap;

  const OfflineReadyBadge({
    super.key,
    required this.isOfflineAvailable,
    this.onDownloadTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isOfflineAvailable) {
      // S-01 "Siap offline" badge with circle-arrow icon
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: const BoxDecoration(
              color: Color(0xFFE2F1EE), // #e2f1ee
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_downward,
              size: 9,
              color: Colors.white, // white arrow on teal circle per S-01
            ),
          ),
          const SizedBox(width: 5),
          Text(
            'Siap offline',
            style: TextStyle(
              fontSize: AppTypography.size11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0A5C50), // #0a5c50
            ),
          ),
        ],
      );
    } else if (onDownloadTap != null) {
      // S-01 "Unduh untuk offline" link
      return GestureDetector(
        onTap: onDownloadTap,
        child: Text(
          'Unduh untuk offline',
          style: TextStyle(
            fontSize: AppTypography.size11,
            fontWeight: FontWeight.w700,
            color: AppColors.primary, // #0f7a6b
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

import 'package:flutter/material.dart';
import 'package:sigap/theme/tokens.dart';

/// Detail Laporan App Bar
/// Features back button, title "Detail laporan", dual IDs (local + server), and more button.
/// Spec: PantauDesa Screens.dc.html lines 211-215
class DetailAppBar extends StatelessWidget {
  final String localId;
  final String serverId;
  final VoidCallback? onBack;
  final VoidCallback? onMore;

  const DetailAppBar({
    super.key,
    required this.localId,
    required this.serverId,
    this.onBack,
    this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
      child: Row(
        children: [
          // Back arrow
          GestureDetector(
            onTap: onBack,
            behavior: HitTestBehavior.opaque,
            child: const SizedBox(
              width: 44,
              height: 44,
              child: Center(
                child: Text(
                  '←',
                  style: TextStyle(
                    fontSize: AppTypography.size22,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.x12),
          // Title and IDs column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Detail laporan',
                  style: TextStyle(
                    fontSize: AppTypography.size16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Lokal #$localId · Server #$serverId',
                  style: const TextStyle(
                    fontSize: AppTypography.size11,
                    fontFamily: 'IBM Plex Mono',
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          // More button
          GestureDetector(
            onTap: onMore,
            behavior: HitTestBehavior.opaque,
            child: const SizedBox(
              width: 44,
              height: 44,
              child: Center(
                child: Text(
                  '⋯',
                  style: TextStyle(
                    fontSize: AppTypography.size20,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

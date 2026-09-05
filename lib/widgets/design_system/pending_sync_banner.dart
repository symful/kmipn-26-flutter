import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/tokens.dart';
import 'a11y.dart';

/// Banner shown when there are locally-saved items pending sync.
///
/// Displays the count of pending items and provides navigation to the sync center.
/// Use this widget in screens that display locally-cached data to inform users
/// about pending synchronization.
///
/// Usage:
/// ```dart
/// PendingSyncBanner(
///   pendingCount: pendingReports.length,
///   onSyncNow: () => syncManager.syncNow(),
///   onViewSyncCenter: () => context.push('/sync-center'),
/// )
/// ```
///
/// See also:
/// - [SyncStatusIndicator] for the compact online/offline status pill.
class PendingSyncBanner extends StatelessWidget {
  /// Number of items pending synchronization.
  final int pendingCount;

  /// Optional callback invoked when the "Sync Now" button is tapped.
  final VoidCallback? onSyncNow;

  /// Optional callback invoked when the "View Sync Center" link is tapped.
  /// If not provided, defaults to navigating to `/sync-center`.
  final VoidCallback? onViewSyncCenter;

  const PendingSyncBanner({
    super.key,
    required this.pendingCount,
    this.onSyncNow,
    this.onViewSyncCenter,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SigapSpacing.x14,
        vertical: SigapSpacing.md,
      ),
      decoration: BoxDecoration(
        color: SigapColors.offlineBg,
        border: Border.all(color: SigapColors.offlineBorder),
        borderRadius: BorderRadius.circular(SigapRadius.lg),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Count badge
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: SigapColors.offlineDot,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              '$pendingCount',
              style: const TextStyle(
                color: SigapColors.surface,
                fontWeight: FontWeight.w700,
                fontSize: SigapTypography.bodyMedium,
              ),
            ),
          ),
          const SizedBox(width: SigapSpacing.x11),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _pendingLabel(pendingCount, l10n),
                  style: const TextStyle(
                    color: SigapColors.warningTextStrong,
                    fontWeight: FontWeight.w600,
                    fontSize: SigapTypography.bodyTextWide,
                  ),
                ),
                const SizedBox(height: SigapRadius.x1),
                Text(
                  l10n.tersimpanDiPerangkat,
                  style: TextStyle(
                    color: SigapColors.offlineText,
                    fontSize: SigapTypography.bodySmall,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: SigapSpacing.sm),
                // Sync now button (optional)
                if (onSyncNow != null) ...[
                  _SyncNowButton(onPressed: onSyncNow!),
                  const SizedBox(height: SigapSpacing.xs),
                ],
                // View sync center link
                MinTapTarget(
                  semanticsLabel: l10n.pusatSinkronisasi,
                  child: GestureDetector(
                    onTap:
                        onViewSyncCenter ?? () => context.push('/sync-center'),
                    child: Text(
                      l10n.bukaPusatSinkronisasiLink,
                      style: TextStyle(
                        color: SigapColors.primaryDark,
                        fontWeight: FontWeight.w600,
                        fontSize: SigapTypography.bodySmallFine,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _pendingLabel(int count, AppLocalizations l10n) {
    return l10n.laporanBelumTersinkronCount(count);
  }
}

class _SyncNowButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _SyncNowButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return MinTapTarget(
      semanticsLabel: l10n.sinkronkanSekarangSemantics,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: SigapSpacing.md,
            vertical: SigapSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: SigapColors.offlineDot,
            borderRadius: BorderRadius.circular(SigapRadius.sm),
          ),
          child: Text(
            l10n.sinkronkanSekarang,
            style: const TextStyle(
              color: SigapColors.surface,
              fontWeight: FontWeight.w600,
              fontSize: SigapTypography.bodySmallFine,
            ),
          ),
        ),
      ),
    );
  }
}

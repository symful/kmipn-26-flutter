import 'package:flutter/material.dart';
import 'package:sigap/theme/tokens.dart';
import 'package:sigap/widgets/design_system/sigap_card.dart';
import 'package:sigap/widgets/design_system/skeleton_loaders.dart';

/// Critical case item model for W-02 dashboard.
class CriticalCaseItem {
  final String id;
  final String title;
  final String caseCode;
  final String village;
  final int slaHoursRemaining;
  final bool isOverdue;

  const CriticalCaseItem({
    required this.id,
    required this.title,
    required this.caseCode,
    required this.village,
    required this.slaHoursRemaining,
    required this.isOverdue,
  });
}

/// W-02 Critical Cases Panel.
///
/// Displays a list of critical cases with SLA countdown timers.
/// Left-side panel when placed side-by-side with [DataQualityPanel].
class KasusKritisPanel extends StatelessWidget {
  const KasusKritisPanel({
    super.key,
    required this.cases,
    this.isLoading = false,
    this.errorMessage,
    this.onCaseTap,
  });

  /// List of critical case items to display.
  final List<CriticalCaseItem> cases;

  /// Whether data is currently loading.
  final bool isLoading;

  /// Optional error message to display.
  final String? errorMessage;

  /// Callback when a case is tapped.
  final void Function(CriticalCaseItem caseItem)? onCaseTap;

  @override
  Widget build(BuildContext context) {
    return SigapCard(
      padding: const EdgeInsets.all(SigapSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header row
          Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: SigapColors.danger,
                size: 18,
              ),
              const SizedBox(width: SigapSpacing.xs),
              const Text(
                'Kasus Kritis',
                style: TextStyle(
                  fontSize: SigapTypography.size13,
                  fontWeight: FontWeight.w600,
                  color: SigapColors.textPrimary,
                ),
              ),
              const Spacer(),
              if (cases.isNotEmpty && !isLoading)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SigapSpacing.xs,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: SigapColors.dangerBg,
                    borderRadius: BorderRadius.circular(SigapRadius.sm),
                  ),
                  child: Text(
                    '${cases.length}',
                    style: const TextStyle(
                      fontSize: SigapTypography.size10,
                      fontWeight: FontWeight.w700,
                      color: SigapColors.dangerTextStrong,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: SigapSpacing.md),

          // Content
          if (isLoading)
            _buildLoadingState()
          else if (errorMessage != null)
            _buildErrorState(errorMessage!)
          else if (cases.isEmpty)
            _buildEmptyState()
          else
            _buildCaseList(),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: List.generate(
        3,
        (index) => Padding(
          padding: EdgeInsets.only(bottom: index < 2 ? SigapSpacing.sm : 0),
          child: _CriticalCaseItemSkeleton(),
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SigapSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: SigapColors.danger,
              size: 24,
            ),
            const SizedBox(height: SigapSpacing.xs),
            Text(
              message,
              style: const TextStyle(
                fontSize: SigapTypography.size12,
                color: SigapColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(SigapSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_outline,
              color: SigapColors.success,
              size: 32,
            ),
            SizedBox(height: SigapSpacing.xs),
            Text(
              'Tidak ada kasus kritis',
              style: TextStyle(
                fontSize: SigapTypography.size12,
                color: SigapColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaseList() {
    return Column(
      children: cases.map((c) {
        return Padding(
          padding: const EdgeInsets.only(bottom: SigapSpacing.sm),
          child: _KasusKritisItem(
            caseItem: c,
            onTap: onCaseTap != null ? () => onCaseTap!(c) : null,
          ),
        );
      }).toList(),
    );
  }
}

/// Individual critical case item row.
class _KasusKritisItem extends StatelessWidget {
  const _KasusKritisItem({required this.caseItem, this.onTap});

  final CriticalCaseItem caseItem;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final urgencyColor = caseItem.isOverdue
        ? SigapColors.danger
        : SigapColors.warning;

    final slaText = caseItem.isOverdue
        ? 'Overdue'
        : '${caseItem.slaHoursRemaining}h';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(SigapRadius.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: SigapSpacing.xs,
          horizontal: SigapSpacing.xs,
        ),
        child: Row(
          children: [
            // Urgency indicator dot
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: urgencyColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: SigapSpacing.sm),

            // Case info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    caseItem.title,
                    style: const TextStyle(
                      fontSize: SigapTypography.size12,
                      fontWeight: FontWeight.w500,
                      color: SigapColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${caseItem.caseCode} · ${caseItem.village}',
                    style: const TextStyle(
                      fontSize: SigapTypography.size10,
                      color: SigapColors.textTertiary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // SLA countdown badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: SigapSpacing.xs,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: urgencyColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(SigapRadius.sm),
                border: Border.all(color: urgencyColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!caseItem.isOverdue) ...[
                    const Icon(
                      Icons.schedule,
                      size: 10,
                      color: SigapColors.warning,
                    ),
                    const SizedBox(width: 2),
                  ],
                  Text(
                    slaText,
                    style: TextStyle(
                      fontSize: SigapTypography.size10,
                      fontWeight: FontWeight.w600,
                      color: urgencyColor,
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

/// Skeleton loading for critical case item.
class _CriticalCaseItemSkeleton extends StatelessWidget {
  const _CriticalCaseItemSkeleton();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SkeletonBox(width: 8, height: 8, borderRadius: 4),
        const SizedBox(width: SigapSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(width: double.infinity, height: 12, borderRadius: 4),
              const SizedBox(height: SigapSpacing.xxs),
              const SkeletonBox(width: 100, height: 10, borderRadius: 4),
            ],
          ),
        ),
        const SizedBox(width: SigapSpacing.sm),
        const SkeletonBox(width: 40, height: 18, borderRadius: 4),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:sigap/theme/tokens.dart';
import 'package:sigap/widgets/design_system/sigap_card.dart';
import 'package:sigap/widgets/design_system/skeleton_loaders.dart';

/// Data model for urgent/critical case items.
class UrgentCaseItem {
  const UrgentCaseItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.slaHoursRemaining,
    required this.isOverdue,
  });

  final String id;
  final String title;
  final String subtitle;
  final int slaHoursRemaining;
  final bool isOverdue;

  Color get urgencyColor =>
      isOverdue ? SigapColors.danger : SigapColors.warning;
  String get slaText => isOverdue ? 'Overdue' : '${slaHoursRemaining}h';
}

/// A card displaying a list of urgent/critical cases.
///
/// Usage:
/// ```dart
/// UrgentCaseList(
///   cases: [
///     UrgentCaseItem(
///       id: '123',
///       title: 'Jalan Rusak Berat',
///       subtitle: 'ABCD1234 · Desa Makmur',
///       slaHoursRemaining: 2,
///       isOverdue: false,
///     ),
///   ],
///   onCaseTap: (id) => context.push('/case/$id'),
/// )
/// ```
class UrgentCaseList extends StatelessWidget {
  /// Creates an [UrgentCaseList].
  ///
  /// - [cases]: List of urgent case items
  /// - [onCaseTap]: Optional callback when a case is tapped
  /// - [title]: Optional custom title (defaults to 'Kasus kritis')
  const UrgentCaseList({
    super.key,
    required this.cases,
    this.onCaseTap,
    this.title = 'Kasus kritis',
  });

  final List<UrgentCaseItem> cases;
  final void Function(String id)? onCaseTap;
  final String title;

  @override
  Widget build(BuildContext context) {
    return SigapCard(
      padding: const EdgeInsets.all(SigapSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: SigapTypography.bodyText,
              fontWeight: FontWeight.w600,
              color: SigapColors.textPrimary,
            ),
          ),
          const SizedBox(height: SigapSpacing.md),
          if (cases.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(SigapSpacing.lg),
                child: Text(
                  'Tidak ada kasus kritis',
                  style: TextStyle(
                    fontSize: SigapTypography.bodySmall,
                    color: SigapColors.textTertiary,
                  ),
                ),
              ),
            )
          else
            ...cases.map(
              (c) => UrgentCaseItemWidget(
                caseItem: c,
                onTap: onCaseTap != null ? () => onCaseTap!(c.id) : null,
              ),
            ),
        ],
      ),
    );
  }
}

/// A single urgent case item row.
class UrgentCaseItemWidget extends StatelessWidget {
  const UrgentCaseItemWidget({super.key, required this.caseItem, this.onTap});

  final UrgentCaseItem caseItem;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: SigapSpacing.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SigapRadius.sm),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: caseItem.urgencyColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: SigapSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    caseItem.title,
                    style: const TextStyle(
                      fontSize: SigapTypography.bodySmall,
                      fontWeight: FontWeight.w500,
                      color: SigapColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    caseItem.subtitle,
                    style: const TextStyle(
                      fontSize: SigapTypography.captionSmall,
                      color: SigapColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              caseItem.slaText,
              style: TextStyle(
                fontSize: SigapTypography.captionMedium,
                fontWeight: FontWeight.w600,
                color: caseItem.urgencyColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Loading state for [UrgentCaseList].
class UrgentCaseListLoading extends StatelessWidget {
  const UrgentCaseListLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return SigapCard(
      padding: const EdgeInsets.all(SigapSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(width: 100, height: 14, borderRadius: 4),
          const SizedBox(height: SigapSpacing.md),
          for (int i = 0; i < 3; i++) ...[
            Row(
              children: [
                SkeletonBox(width: 8, height: 8, borderRadius: 4),
                const SizedBox(width: SigapSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(
                        width: double.infinity,
                        height: 12,
                        borderRadius: 4,
                      ),
                      const SizedBox(height: SigapSpacing.xxs),
                      SkeletonBox(width: 100, height: 10, borderRadius: 4),
                    ],
                  ),
                ),
                const SizedBox(width: SigapSpacing.sm),
                SkeletonBox(width: 40, height: 12, borderRadius: 4),
              ],
            ),
            if (i < 2) const SizedBox(height: SigapSpacing.sm),
          ],
        ],
      ),
    );
  }
}

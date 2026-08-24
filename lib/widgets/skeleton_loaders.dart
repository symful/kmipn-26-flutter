import 'package:flutter/material.dart';
import '../theme/tokens.dart';

/// Reusable skeleton loader primitives following the app's design system.
///
/// All skeleton widgets use design tokens:
/// - SigapColors.borderCard for placeholder color
/// - SigapRadius / SigapRadius for border radius
/// - SigapSpacing / SigapSpacing for spacing

/// A basic skeleton box primitive.
/// Renders a rounded rectangle placeholder with shimmer-like appearance.
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const SkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: SigapColors.borderCard,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// A skeleton line placeholder for text-like content.
class SkeletonLine extends StatelessWidget {
  final double? width;
  final double height;

  const SkeletonLine({super.key, this.width, this.height = 12});

  @override
  Widget build(BuildContext context) {
    return SkeletonBox(width: width, height: height, borderRadius: 4);
  }
}

/// Skeleton loading for a stat card (used in dashboards).
class SkeletonStatCard extends StatelessWidget {
  const SkeletonStatCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SigapSpacing.lg),
      decoration: BoxDecoration(
        color: SigapColors.borderCard.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(SigapRadius.md),
        border: Border.all(color: SigapColors.borderCard),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: SigapColors.borderCard,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: SigapSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 50, height: 24, borderRadius: 4),
                const SizedBox(height: 6),
                SkeletonBox(width: 80, height: 12, borderRadius: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton loading for warga home stats row.
class SkeletonStatsRow extends StatelessWidget {
  const SkeletonStatsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < 3; i++) ...[
          if (i > 0) const SizedBox(width: SigapSpacing.sm),
          Expanded(
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                color: SigapColors.surface,
                borderRadius: BorderRadius.circular(SigapRadius.md),
                border: Border.all(color: SigapColors.border),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: SigapColors.primary,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Skeleton loading for nearby cases card.
class SkeletonNearbyCard extends StatelessWidget {
  const SkeletonNearbyCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: SigapSpacing.md),
        Container(
          padding: const EdgeInsets.all(SigapSpacing.md),
          decoration: BoxDecoration(
            color: SigapColors.bgCard,
            border: Border.all(color: SigapColors.borderCard),
            borderRadius: BorderRadius.circular(SigapRadius.x12),
          ),
          child: Row(
            children: [
              const SizedBox(
                width: 38,
                height: 38,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: SigapColors.primary,
                ),
              ),
              const SizedBox(width: SigapSpacing.x11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: 120, height: 14, borderRadius: 4),
                    const SizedBox(height: 6),
                    SkeletonBox(width: 80, height: 11, borderRadius: 4),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Skeleton loading for report list item (warga home).
class SkeletonListItem extends StatelessWidget {
  const SkeletonListItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: SigapSpacing.sm),
      padding: const EdgeInsets.all(SigapSpacing.md),
      decoration: BoxDecoration(
        color: SigapColors.surface,
        borderRadius: BorderRadius.circular(SigapRadius.md),
        border: Border.all(color: SigapColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: SigapColors.border,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: SigapSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(
                  width: double.infinity,
                  height: 13,
                  borderRadius: 4,
                ),
                const SizedBox(height: SigapSpacing.xs),
                SkeletonBox(width: 100, height: 11, borderRadius: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton loading for task card (surveyor list).
class TaskCardSkeleton extends StatelessWidget {
  const TaskCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SigapColors.bgCard,
        borderRadius: BorderRadius.circular(SigapRadius.x12),
        border: Border.all(color: SigapColors.borderCard),
      ),
      child: Padding(
        padding: const EdgeInsets.all(SigapSpacing.md),
        child: Row(
          children: [
            // Left border placeholder (priority stripe)
            Container(
              width: 4,
              height: 60,
              decoration: BoxDecoration(
                color: SigapColors.borderCard,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: SigapSpacing.md),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(
                    width: double.infinity,
                    height: 14,
                    borderRadius: 4,
                  ),
                  const SizedBox(height: 8),
                  SkeletonBox(width: 150, height: 11, borderRadius: 4),
                  const SizedBox(height: 6),
                  SkeletonBox(width: 80, height: 10, borderRadius: 4),
                ],
              ),
            ),
            const SizedBox(width: SigapSpacing.sm),
            // Priority indicator placeholder
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: SigapSpacing.x9,
                vertical: SigapSpacing.x4,
              ),
              decoration: BoxDecoration(
                color: SigapColors.borderCard.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(SigapRadius.x6),
              ),
              child: SkeletonBox(width: 40, height: 10, borderRadius: 4),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton loading for operator dashboard summary cards.
class OperatorDashboardSkeleton extends StatelessWidget {
  const OperatorDashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(SigapSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Summary cards row 1
          Row(
            children: [
              const Expanded(child: SkeletonStatCard()),
              const SizedBox(width: SigapSpacing.md),
              const Expanded(child: SkeletonStatCard()),
            ],
          ),
          const SizedBox(height: SigapSpacing.md),
          // Summary cards row 2
          Row(
            children: [
              const Expanded(child: SkeletonStatCard()),
              const SizedBox(width: SigapSpacing.md),
              const Expanded(child: SkeletonStatCard()),
            ],
          ),
          const SizedBox(height: SigapSpacing.md),
          // Full width SLA card
          SkeletonStatCard(),
          const SizedBox(height: SigapSpacing.xl),
          // Quick actions section
          SkeletonBox(width: 100, height: 20, borderRadius: 4),
          const SizedBox(height: SigapSpacing.md),
          Row(
            children: [
              const Expanded(child: _SkeletonActionCard()),
              const SizedBox(width: SigapSpacing.md),
              const Expanded(child: _SkeletonActionCard()),
            ],
          ),
        ],
      ),
    );
  }
}

class _SkeletonActionCard extends StatelessWidget {
  const _SkeletonActionCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SigapSpacing.lg),
      decoration: BoxDecoration(
        color: SigapColors.borderCard.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(SigapRadius.md),
        border: Border.all(color: SigapColors.borderCard),
      ),
      child: Column(
        children: [
          SkeletonBox(width: 36, height: 36, borderRadius: 8),
          const SizedBox(height: SigapSpacing.sm),
          SkeletonBox(width: 80, height: 13, borderRadius: 4),
        ],
      ),
    );
  }
}

/// Skeleton loading for operator case detail screen.
class OperatorCaseDetailSkeleton extends StatelessWidget {
  const OperatorCaseDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(SigapSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header card
          Container(
            padding: const EdgeInsets.all(SigapSpacing.md),
            decoration: BoxDecoration(
              color: SigapColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(SigapRadius.md),
              border: Border.all(color: SigapColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(
                  width: double.infinity,
                  height: 20,
                  borderRadius: 4,
                ),
                const SizedBox(height: SigapSpacing.sm),
                Row(
                  children: [
                    SkeletonBox(
                      width: 80,
                      height: 24,
                      borderRadius: SigapRadius.sm,
                    ),
                    const SizedBox(width: SigapSpacing.sm),
                    SkeletonBox(
                      width: 100,
                      height: 24,
                      borderRadius: SigapRadius.sm,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: SigapSpacing.lg),

          // Photos section
          SkeletonBox(width: 100, height: 18, borderRadius: 4),
          const SizedBox(height: SigapSpacing.sm),
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: SigapSpacing.sm),
              itemBuilder: (_, __) => SkeletonBox(
                width: 100,
                height: 100,
                borderRadius: SigapRadius.md,
              ),
            ),
          ),
          const SizedBox(height: SigapSpacing.lg),

          // Description section
          SkeletonBox(width: 100, height: 18, borderRadius: 4),
          const SizedBox(height: SigapSpacing.sm),
          Container(
            padding: const EdgeInsets.all(SigapSpacing.md),
            decoration: BoxDecoration(
              color: SigapColors.surface,
              borderRadius: BorderRadius.circular(SigapRadius.md),
              border: Border.all(color: SigapColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(
                  width: double.infinity,
                  height: 12,
                  borderRadius: 4,
                ),
                const SizedBox(height: 8),
                SkeletonBox(width: 200, height: 12, borderRadius: 4),
              ],
            ),
          ),
          const SizedBox(height: SigapSpacing.xl),

          // Actions section
          SkeletonBox(width: 150, height: 18, borderRadius: 4),
          const SizedBox(height: SigapSpacing.md),
          Wrap(
            spacing: SigapSpacing.sm,
            runSpacing: SigapSpacing.sm,
            children: List.generate(
              5,
              (_) => SkeletonBox(
                width: 100,
                height: 40,
                borderRadius: SigapRadius.md,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton loading for verifikator case detail screen.
class VerifikatorCaseDetailSkeleton extends StatelessWidget {
  const VerifikatorCaseDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(SigapSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header card
          Container(
            padding: const EdgeInsets.all(SigapSpacing.md),
            decoration: BoxDecoration(
              color: SigapColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(SigapRadius.md),
              border: Border.all(color: SigapColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(
                  width: double.infinity,
                  height: 20,
                  borderRadius: 4,
                ),
                const SizedBox(height: SigapSpacing.sm),
                Row(
                  children: [
                    SkeletonBox(
                      width: 80,
                      height: 24,
                      borderRadius: SigapRadius.sm,
                    ),
                    const SizedBox(width: SigapSpacing.sm),
                    SkeletonBox(
                      width: 100,
                      height: 24,
                      borderRadius: SigapRadius.sm,
                    ),
                  ],
                ),
                const SizedBox(height: SigapSpacing.sm),
                SkeletonBox(width: 150, height: 12, borderRadius: 4),
              ],
            ),
          ),
          const SizedBox(height: SigapSpacing.lg),

          // Location section
          SkeletonBox(width: 80, height: 18, borderRadius: 4),
          const SizedBox(height: SigapSpacing.sm),
          Container(
            padding: const EdgeInsets.all(SigapSpacing.md),
            decoration: BoxDecoration(
              color: SigapColors.surface,
              borderRadius: BorderRadius.circular(SigapRadius.md),
              border: Border.all(color: SigapColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 250, height: 12, borderRadius: 4),
                const SizedBox(height: SigapSpacing.sm),
                SkeletonBox(
                  width: 120,
                  height: 32,
                  borderRadius: SigapRadius.sm,
                ),
              ],
            ),
          ),
          const SizedBox(height: SigapSpacing.lg),

          // Photos section
          SkeletonBox(width: 80, height: 18, borderRadius: 4),
          const SizedBox(height: SigapSpacing.sm),
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: SigapSpacing.sm),
              itemBuilder: (_, __) => SkeletonBox(
                width: 120,
                height: 120,
                borderRadius: SigapRadius.md,
              ),
            ),
          ),
          const SizedBox(height: SigapSpacing.lg),

          // Description section
          SkeletonBox(width: 100, height: 18, borderRadius: 4),
          const SizedBox(height: SigapSpacing.sm),
          Container(
            padding: const EdgeInsets.all(SigapSpacing.md),
            decoration: BoxDecoration(
              color: SigapColors.surface,
              borderRadius: BorderRadius.circular(SigapRadius.md),
              border: Border.all(color: SigapColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(
                  width: double.infinity,
                  height: 12,
                  borderRadius: 4,
                ),
                const SizedBox(height: 8),
                SkeletonBox(
                  width: double.infinity,
                  height: 12,
                  borderRadius: 4,
                ),
                const SizedBox(height: 8),
                SkeletonBox(width: 200, height: 12, borderRadius: 4),
              ],
            ),
          ),
          const SizedBox(height: SigapSpacing.lg),

          // Decision panel section
          SkeletonBox(width: 80, height: 18, borderRadius: 4),
          const SizedBox(height: SigapSpacing.md),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: SigapSpacing.sm,
            crossAxisSpacing: SigapSpacing.sm,
            childAspectRatio: 2.2,
            children: List.generate(
              6,
              (_) => SkeletonBox(height: 60, borderRadius: SigapRadius.md),
            ),
          ),
        ],
      ),
    );
  }
}

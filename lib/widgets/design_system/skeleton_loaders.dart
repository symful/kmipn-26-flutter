import 'package:flutter/material.dart';
import '../../theme/tokens.dart';

/// Reusable skeleton loader primitives following the app's design system.
///
/// All skeleton widgets use design tokens:
/// - SigapColors.border (with low opacity) for placeholder base color
/// - SigapRadius for border radius
/// - SigapSpacing for spacing

// -----------------------------------------------------------------------------
// Skeleton color - using border token as neutral base (no skeleton token exists)
// -----------------------------------------------------------------------------
class _SkeletonColors {
  _SkeletonColors._();

  /// Base color for skeleton placeholders (using border with low opacity).
  static Color get base => SigapColors.border.withValues(alpha: 0.4);

  /// Shimmer highlight color (lighter variant of base).
  static Color get shimmer => SigapColors.border.withValues(alpha: 0.15);

  /// Border color for skeleton containers.
  static Color get border => SigapColors.border;
}

// -----------------------------------------------------------------------------
// Shimmer effect widget
// -----------------------------------------------------------------------------

/// A skeleton box with subtle shimmer animation.
class SkeletonBox extends StatefulWidget {
  final double? width;
  final double height;
  final double borderRadius;
  final bool shimmer;

  const SkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = 4,
    this.shimmer = true,
  });

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.shimmer) {
      return Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: _SkeletonColors.base,
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(-1.0 + _animation.value, 0),
              end: Alignment(_animation.value, 0),
              colors: [
                _SkeletonColors.base,
                _SkeletonColors.shimmer,
                _SkeletonColors.base,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// SkeletonLoader factory class with variants
// -----------------------------------------------------------------------------

/// Factory class for creating skeleton loader variants.
///
/// Usage:
/// ```dart
/// SkeletonLoader.text()
/// SkeletonLoader.card()
/// SkeletonLoader.list(itemCount: 5)
/// SkeletonLoader.circle(size: 48)
/// ```
class SkeletonLoader {
  SkeletonLoader._();

  /// Creates a skeleton text line placeholder.
  ///
  /// [width] - optional width (defaults to full width).
  /// [height] - line height (defaults to 12).
  /// [borderRadius] - corner radius (defaults to 4).
  static Widget text({
    double? width,
    double height = 12,
    double borderRadius = 4,
  }) {
    return SkeletonBox(
      width: width,
      height: height,
      borderRadius: borderRadius,
    );
  }

  /// Creates a skeleton card placeholder.
  ///
  /// [padding] - internal padding (defaults to SigapSpacing.md).
  static Widget card({double? width, double height = 80, EdgeInsets? padding}) {
    return Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(SigapSpacing.md),
      decoration: BoxDecoration(
        color: SigapColors.surface,
        borderRadius: BorderRadius.circular(SigapRadius.md),
        border: Border.all(color: _SkeletonColors.border),
      ),
      child: Row(
        children: [
          SkeletonBox(width: 40, height: 40, borderRadius: SigapRadius.sm),
          const SizedBox(width: SigapSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SkeletonBox(
                  width: double.infinity,
                  height: 14,
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

  /// Creates a skeleton list with [itemCount] items.
  ///
  /// [itemCount] - number of list items to show (defaults to 3).
  /// [separator] - widget to use between items.
  static Widget list({int itemCount = 3, Widget? separator}) {
    return Column(
      children: List.generate(itemCount * 2 - 1, (index) {
        if (index.isOdd) {
          return separator ?? const SizedBox(height: SigapSpacing.sm);
        }
        return SkeletonBox(
          width: double.infinity,
          height: 72,
          borderRadius: SigapRadius.md,
        );
      }),
    );
  }

  /// Creates a skeleton circle placeholder.
  ///
  /// [size] - diameter of the circle (defaults to 48).
  static Widget circle({double size = 48}) {
    return SkeletonBox(width: size, height: size, borderRadius: size / 2);
  }
}

// -----------------------------------------------------------------------------
// Legacy skeleton widgets (preserved for backward compatibility)
// -----------------------------------------------------------------------------

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
        color: SigapColors.surface,
        borderRadius: BorderRadius.circular(SigapRadius.md),
        border: Border.all(color: _SkeletonColors.border),
      ),
      child: Row(
        children: [
          SkeletonBox(width: 40, height: 40, borderRadius: SigapRadius.sm),
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
                border: Border.all(color: _SkeletonColors.border),
              ),
              child: const Center(
                child: SkeletonBox(width: 40, height: 40, borderRadius: 20),
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
            border: Border.all(color: _SkeletonColors.border),
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
        border: Border.all(color: _SkeletonColors.border),
      ),
      child: Row(
        children: [
          SkeletonBox(width: 10, height: 10, borderRadius: 5),
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
        border: Border.all(color: _SkeletonColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(SigapSpacing.md),
        child: Row(
          children: [
            // Left border placeholder (priority stripe)
            SkeletonBox(width: 4, height: 60, borderRadius: 2),
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
                color: _SkeletonColors.base,
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
          const SkeletonStatCard(),
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
        color: SigapColors.surface,
        borderRadius: BorderRadius.circular(SigapRadius.md),
        border: Border.all(color: _SkeletonColors.border),
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

/// Unified skeleton for case detail screens (used by operator and verifikator).
///
/// [hasLocation] - shows location section (verifikator)
/// [hasDecision] - shows decision panel grid (verifikator)
/// [actionCount] - number of action buttons (operator=5, verifikator=0)
class CaseDetailSkeleton extends StatelessWidget {
  final bool hasLocation;
  final bool hasDecision;
  final int actionCount;

  const CaseDetailSkeleton({
    super.key,
    this.hasLocation = false,
    this.hasDecision = false,
    this.actionCount = 0,
  });

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
              border: Border.all(color: _SkeletonColors.border),
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
                if (hasLocation) ...[
                  const SizedBox(height: SigapSpacing.sm),
                  SkeletonBox(width: 150, height: 12, borderRadius: 4),
                ],
              ],
            ),
          ),

          if (hasLocation) ...[
            const SizedBox(height: SigapSpacing.lg),
            SkeletonBox(width: 80, height: 18, borderRadius: 4),
            const SizedBox(height: SigapSpacing.sm),
            Container(
              padding: const EdgeInsets.all(SigapSpacing.md),
              decoration: BoxDecoration(
                color: SigapColors.surface,
                borderRadius: BorderRadius.circular(SigapRadius.md),
                border: Border.all(color: _SkeletonColors.border),
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
          ],

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
              border: Border.all(color: _SkeletonColors.border),
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

          if (hasDecision) ...[
            const SizedBox(height: SigapSpacing.lg),
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

          if (actionCount > 0) ...[
            const SizedBox(height: SigapSpacing.xl),
            SkeletonBox(width: 150, height: 18, borderRadius: 4),
            const SizedBox(height: SigapSpacing.md),
            Wrap(
              spacing: SigapSpacing.sm,
              runSpacing: SigapSpacing.sm,
              children: List.generate(
                actionCount,
                (_) => SkeletonBox(
                  width: 100,
                  height: 40,
                  borderRadius: SigapRadius.md,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Skeleton loading for operator case detail screen.
@Deprecated('Use CaseDetailSkeleton(actionCount: 5) instead')
class OperatorCaseDetailSkeleton extends StatelessWidget {
  const OperatorCaseDetailSkeleton({super.key});
  @override
  Widget build(BuildContext context) =>
      const CaseDetailSkeleton(actionCount: 5);
}

/// Skeleton loading for verifikator case detail screen.
@Deprecated(
  'Use CaseDetailSkeleton(hasLocation: true, hasDecision: true) instead',
)
class VerifikatorCaseDetailSkeleton extends StatelessWidget {
  const VerifikatorCaseDetailSkeleton({super.key});
  @override
  Widget build(BuildContext context) =>
      const CaseDetailSkeleton(hasLocation: true, hasDecision: true);
}

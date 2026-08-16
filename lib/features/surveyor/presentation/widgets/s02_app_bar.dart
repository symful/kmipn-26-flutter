import 'package:flutter/material.dart';
import '../../../../theme/tokens.dart';

/// S-02 App Bar with SLA deadline badge for surveyor task detail screen.
///
/// Displays a back arrow, title (case category), and an SLA deadline badge
/// colored by urgency.
///
/// SLA badge colors:
/// - Green (>2 days remaining): AppColors.primary
/// - Amber (1-2 days remaining): AppColors.warning
/// - Red (<1 day or overdue): AppColors.danger
class S02AppBar extends StatelessWidget {
  /// Title text (case category).
  final String title;

  /// Days remaining until SLA deadline. Null means SLA not applicable.
  final int? slaDaysRemaining;

  /// Called when back arrow is tapped.
  final VoidCallback? onBack;

  const S02AppBar({
    super.key,
    required this.title,
    this.slaDaysRemaining,
    this.onBack,
  });

  /// Determines SLA badge color and text based on days remaining.
  _SlaBadgeData get _slaBadge {
    if (slaDaysRemaining == null) {
      return _SlaBadgeData(
        backgroundColor: AppColors.textDisabled,
        textColor: Colors.white,
        label: 'N/A',
      );
    }

    final days = slaDaysRemaining!;
    if (days <= 0) {
      // Overdue
      return _SlaBadgeData(
        backgroundColor: AppColors.danger,
        textColor: Colors.white,
        label: 'Overdue',
      );
    } else if (days < 1) {
      // Less than 1 day
      return _SlaBadgeData(
        backgroundColor: AppColors.danger,
        textColor: Colors.white,
        label: '<1d',
      );
    } else if (days <= 2) {
      // 1-2 days
      return _SlaBadgeData(
        backgroundColor: AppColors.warning,
        textColor: Colors.white,
        label: '${days}d',
      );
    } else {
      // More than 2 days
      return _SlaBadgeData(
        backgroundColor: AppColors.primary,
        textColor: Colors.white,
        label: '${days}d',
      );
    }
  }

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
          // Title
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: AppTypography.size16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // SLA badge
          _SlaBadge(data: _slaBadge),
        ],
      ),
    );
  }
}

class _SlaBadgeData {
  final Color backgroundColor;
  final Color textColor;
  final String label;

  const _SlaBadgeData({
    required this.backgroundColor,
    required this.textColor,
    required this.label,
  });
}

class _SlaBadge extends StatelessWidget {
  final _SlaBadgeData data;

  const _SlaBadge({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x9,
        vertical: AppSpacing.x4,
      ),
      decoration: BoxDecoration(
        color: data.backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        data.label,
        style: TextStyle(
          fontSize: AppTypography.size11,
          fontWeight: FontWeight.w600,
          color: data.textColor,
        ),
      ),
    );
  }
}

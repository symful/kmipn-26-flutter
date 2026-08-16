import 'package:flutter/material.dart';
import '../../../../theme/tokens.dart';

/// Category chip + report title widget for surveyor task detail screen.
///
/// Displays a rounded pill chip with category icon and name, with the
/// report title text below it.
class S02CategoryTitle extends StatelessWidget {
  /// Category icon (e.g., emoji like "🏗️").
  final String categoryIcon;

  /// Category display name (e.g., "Infrastruktur").
  final String categoryName;

  /// Report title text (max 2 lines, overflow ellipsis).
  final String title;

  const S02CategoryTitle({
    super.key,
    required this.categoryIcon,
    required this.categoryName,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CategoryChip(icon: categoryIcon, name: categoryName),
        const SizedBox(height: AppSpacing.sm),
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: AppTypography.size16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            height: AppTypography.lineHeight135,
          ),
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String icon;
  final String name;

  const _CategoryChip({required this.icon, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.x4,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        '$icon $name',
        style: const TextStyle(
          fontSize: AppTypography.size12,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryDark,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:sigap/theme/tokens.dart';

class OfflinePill extends StatelessWidget {
  const OfflinePill({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x9,
        vertical: AppSpacing.x4,
      ),
      decoration: BoxDecoration(
        color: AppColors.warningBg,
        border: Border.all(color: AppColors.warningBorder),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: AppSpacing.x7),
          SizedBox(
            width: 7,
            height: 7,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.warning,
                shape: BoxShape.circle,
              ),
            ),
          ),
          SizedBox(width: AppSpacing.xs),
          Text(
            'Offline',
            style: TextStyle(
              fontSize: AppTypography.size11,
              fontWeight: FontWeight.w600,
              color: AppColors.warningText,
            ),
          ),
        ],
      ),
    );
  }
}

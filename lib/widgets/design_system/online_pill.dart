import 'package:flutter/material.dart';
import 'package:sigap/theme/tokens.dart';

class OnlinePill extends StatelessWidget {
  const OnlinePill({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SigapSpacing.x9,
        vertical: SigapSpacing.x4,
      ),
      decoration: BoxDecoration(
        color: SigapColors.primaryLight,
        border: Border.all(color: SigapColors.successBorder),
        borderRadius: BorderRadius.circular(SigapRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: SigapSpacing.x7),
          SizedBox(
            width: 7,
            height: 7,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: SigapColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
          SizedBox(width: SigapSpacing.xs),
          Text(
            'Online',
            style: TextStyle(
              fontSize: SigapTypography.size11,
              fontWeight: FontWeight.w600,
              color: SigapColors.primaryDark,
            ),
          ),
        ],
      ),
    );
  }
}

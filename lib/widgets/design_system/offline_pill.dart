import 'package:flutter/material.dart';
import 'package:sigap/theme/tokens.dart';

class OfflinePill extends StatelessWidget {
  const OfflinePill({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SigapSpacing.x9,
        vertical: SigapSpacing.x4,
      ),
      decoration: BoxDecoration(
        color: SigapColors.warningBg,
        border: Border.all(color: SigapColors.warningBorder),
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
                color: SigapColors.warning,
                shape: BoxShape.circle,
              ),
            ),
          ),
          SizedBox(width: SigapSpacing.xs),
          Text(
            'Offline',
            style: TextStyle(
              fontSize: SigapTypography.captionMedium,
              fontWeight: FontWeight.w600,
              color: SigapColors.warningText,
            ),
          ),
        ],
      ),
    );
  }
}

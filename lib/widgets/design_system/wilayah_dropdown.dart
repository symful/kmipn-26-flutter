import 'package:flutter/material.dart';
import 'package:sigap/theme/tokens.dart';

class WilayahDropdown extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onTap;

  const WilayahDropdown({
    super.key,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: SigapTypography.captionMedium,
              color: SigapColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: SigapColors.textPrimary, // #17191c per M-05 spec
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.keyboard_arrow_down,
                size: 12,
                color: SigapColors.textDisabled,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

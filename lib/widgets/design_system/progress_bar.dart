import 'package:flutter/material.dart';
import 'package:sigap/theme/tokens.dart';

class ProgressBar extends StatelessWidget {
  final double percent; // 0-100
  final double height;
  final bool showLabel;

  const ProgressBar({
    super.key,
    required this.percent,
    this.height = 6,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              '${percent.toInt()}%',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: SigapColors.textTertiary,
              ),
            ),
          ),
        Container(
          height: height,
          decoration: BoxDecoration(
            color: SigapColors.bgSoft,
            borderRadius: BorderRadius.circular(height / 2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: (percent / 100).clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: SigapColors.primary,
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

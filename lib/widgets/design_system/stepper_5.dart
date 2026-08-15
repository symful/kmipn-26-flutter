import 'package:flutter/material.dart';
import 'package:sigap/theme/tokens.dart';

class Stepper5 extends StatelessWidget {
  final int currentStep; // 1-5

  const Stepper5({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (i) {
        final filled = i < currentStep;
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: i < 4 ? 5 : 0),
            decoration: BoxDecoration(
              color: filled ? AppColors.primary : const Color(0xFFE4E7E2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}

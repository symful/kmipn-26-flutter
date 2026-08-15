import 'package:flutter/material.dart';
import 'package:sigap/theme/tokens.dart';

class PhoneFrame extends StatelessWidget {
  final Widget child;

  const PhoneFrame({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 392,
      height: 812,
      decoration: BoxDecoration(
        color: AppColors.phoneBezel, // #1F2226
        borderRadius: BorderRadius.circular(AppRadius.x44),
        boxShadow: AppShadows.phoneBezel,
      ),
      padding: const EdgeInsets.all(AppSpacing.x11),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF4F5F3),
          borderRadius: BorderRadius.circular(AppRadius.x34),
        ),
        child: child,
      ),
    );
  }
}

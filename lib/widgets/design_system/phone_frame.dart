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
        color: SigapColors.phoneBezel, // #1F2226
        borderRadius: BorderRadius.circular(SigapRadius.x44),
        boxShadow: SigapShadows.phoneBezel,
      ),
      padding: const EdgeInsets.all(SigapSpacing.x11),
      child: Container(
        decoration: BoxDecoration(
          color: SigapColors.bgSurface,
          borderRadius: BorderRadius.circular(SigapRadius.x34),
        ),
        child: child,
      ),
    );
  }
}

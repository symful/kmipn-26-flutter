import 'package:flutter/material.dart';
import 'package:sigap/theme/tokens.dart';

class IconBadge extends StatelessWidget {
  final String code;
  final double size;

  const IconBadge({super.key, required this.code, this.size = 34});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: SigapColors.primaryLight,
        borderRadius: BorderRadius.circular(SigapRadius.sm),
      ),
      alignment: Alignment.center,
      child: Text(
        code.length > 2 ? code.substring(0, 2) : code,
        style: const TextStyle(
          fontFamily: SigapTypography.fontFamilyMono,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: SigapColors.primaryDark,
        ),
      ),
    );
  }
}

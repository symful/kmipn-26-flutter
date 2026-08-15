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
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      alignment: Alignment.center,
      child: Text(
        code.length > 2 ? code.substring(0, 2) : code,
        style: const TextStyle(
          fontFamily: 'IBM Plex Mono',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryDark,
        ),
      ),
    );
  }
}

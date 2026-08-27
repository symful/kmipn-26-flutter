import 'package:flutter/material.dart';
import 'package:sigap/theme/tokens.dart';

class SectionLabel extends StatelessWidget {
  final String text;

  const SectionLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: SigapColors.textTertiary,
        letterSpacing: 0.04,
      ),
    );
  }
}

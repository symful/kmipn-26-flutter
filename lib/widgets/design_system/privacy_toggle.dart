import 'package:flutter/material.dart';
import 'package:sigap/theme/tokens.dart';

class PrivacyToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const PrivacyToggle({super.key, required this.value, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onChanged != null ? () => onChanged!(!value) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 42,
        height: 24,
        decoration: BoxDecoration(
          color: value ? AppColors.primary : const Color(0xFFD3D7D0),
          borderRadius: BorderRadius.circular(999),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: AppShadows.toggleThumb,
            ),
          ),
        ),
      ),
    );
  }
}

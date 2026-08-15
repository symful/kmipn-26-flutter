import 'package:flutter/material.dart';

class WilayahDropdown extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onTap;

  const WilayahDropdown({
    super.key,
    this.label = 'Wilayah aktif',
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
            style: const TextStyle(fontSize: 11, color: Color(0xFF616770)),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF3A3F45),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.keyboard_arrow_down,
                size: 12,
                color: Color(0xFF8A9099),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

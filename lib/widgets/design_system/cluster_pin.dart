import 'package:flutter/material.dart';

enum ClusterStatus { red, amber, teal, blue }

class ClusterPin extends StatelessWidget {
  final int count;
  final ClusterStatus status;

  const ClusterPin({super.key, required this.count, required this.status});

  double get _size {
    if (count >= 50) return 52;
    if (count >= 20) return 44;
    if (count >= 10) return 34;
    if (count >= 5) return 30;
    if (count >= 2) return 26;
    return 22;
  }

  Color get _color {
    switch (status) {
      case ClusterStatus.red:
        return const Color(0xFFC0392B);
      case ClusterStatus.amber:
        return const Color(0xFFB8730A);
      case ClusterStatus.teal:
        return const Color(0xFF0F7A6B);
      case ClusterStatus.blue:
        return const Color(0xFF2563EB);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        color: _color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: _color.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        count > 99 ? '99+' : count.toString(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

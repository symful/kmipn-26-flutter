import 'package:flutter/material.dart';
import 'package:sigap/theme/tokens.dart';

/// Notification bell widget with optional unread count badge.
///
/// When [unreadCount] is > 0, displays a badge with the count (or a simple
/// dot if count is 1). When [unreadCount] is 0, no badge is shown.
///
/// Design: M-05 Beranda Warga spec - checkbox-style icon per PantauDesa
/// mockup, with red dot notification badge.
class NotificationBell extends StatelessWidget {
  /// Number of unread notifications. Shows badge when > 0.
  final int unreadCount;

  const NotificationBell({super.key, this.unreadCount = 0});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            border: Border.all(color: AppColors.borderCard),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Center(
            child: CustomPaint(
              size: const Size(14, 14),
              painter: _CheckboxPainter(),
            ),
          ),
        ),
        if (unreadCount > 0)
          Positioned(
            top: 6,
            right: 27,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xFFC0392B), // #c0392b per M-05
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.6),
              ),
              child: Center(
                child: Text(
                  unreadCount > 99 ? '99+' : unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Custom painter for checkbox-style notification icon per M-05 spec.
/// 14x14, border 1.6px, border-radius: 4px 4px 3px 3px, color #3a3f45.
class _CheckboxPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF3A3F45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    final rect = RRect.fromRectAndCorners(
      Rect.fromLTWH(0, 0, size.width, size.height),
      topLeft: const Radius.circular(4),
      topRight: const Radius.circular(4),
      bottomLeft: const Radius.circular(3),
      bottomRight: const Radius.circular(3),
    );

    canvas.drawRRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

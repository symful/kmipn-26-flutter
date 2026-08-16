import 'package:flutter/material.dart';
import 'package:sigap/theme/tokens.dart';

/// Notification bell widget with optional unread count badge.
///
/// When [unreadCount] is > 0, displays a badge with the count (or a simple
/// dot if count is 1). When [unreadCount] is 0, no badge is shown.
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
          child: const Icon(
            Icons.notifications_outlined,
            size: 14,
            color: AppColors.textSecondary,
          ),
        ),
        if (unreadCount > 0)
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.danger,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
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

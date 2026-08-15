import 'package:flutter/material.dart';
import 'package:sigap/theme/tokens.dart';

class NotificationBell extends StatelessWidget {
  final bool hasNotification;

  const NotificationBell({super.key, this.hasNotification = true});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            border: Border.all(color: AppColors.borderCard),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: const Icon(
            Icons.notifications_outlined,
            size: 14,
            color: AppColors.textSecondary,
          ),
        ),
        if (hasNotification)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.danger,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.bgCard, width: 1),
              ),
            ),
          ),
      ],
    );
  }
}

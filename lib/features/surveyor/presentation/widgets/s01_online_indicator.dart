import 'package:flutter/material.dart';
import 'package:sigap/theme/tokens.dart';

/// Online status for S-01 surveyor home screen indicator.
///
/// Maps to PantauDesa design spec colors:
/// - online: Green pill with "Online" text
/// - syncing: Amber pill with "Syncing" text
/// - offline: Gray pill with "Offline" text
enum S01OnlineStatus {
  /// Connected and ready to sync
  online,

  /// Currently syncing data
  syncing,

  /// No internet connection
  offline,
}

/// Pill badge widget showing online/offline/syncing status.
///
/// Displays a colored pill with text label indicating the current
/// connection status for the surveyor home screen.
///
/// Design tokens used:
/// - Online: AppColors.primary (#0F7A6B) background, white text
/// - Syncing: AppColors.warning (#B8730A) background, white text
/// - Offline: AppColors.textDisabled (#8A9099) background, white text
/// - Pill shape: AppRadius.pill (999px)
class S01OnlineIndicator extends StatelessWidget {
  /// Current online status.
  final S01OnlineStatus status;

  const S01OnlineIndicator({super.key, required this.status});

  /// Background color based on status.
  Color get _backgroundColor {
    switch (status) {
      case S01OnlineStatus.online:
        return AppColors.primary;
      case S01OnlineStatus.syncing:
        return AppColors.warning;
      case S01OnlineStatus.offline:
        return AppColors.textDisabled;
    }
  }

  /// Label text based on status.
  String get _label {
    switch (status) {
      case S01OnlineStatus.online:
        return 'Online';
      case S01OnlineStatus.syncing:
        return 'Syncing';
      case S01OnlineStatus.offline:
        return 'Offline';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x9,
        vertical: AppSpacing.x4,
      ),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        _label,
        style: const TextStyle(
          fontSize: AppTypography.size11,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}

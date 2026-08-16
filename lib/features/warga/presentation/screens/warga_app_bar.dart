import 'package:flutter/material.dart';
import 'package:sigap/theme/tokens.dart';
import 'package:sigap/widgets/design_system/offline_pill.dart';
import 'package:sigap/widgets/design_system/notification_bell.dart';
import 'package:sigap/widgets/design_system/wilayah_dropdown.dart';

/// App bar for Beranda Warga screen matching PantauDesa M-05 design.
///
/// This is a custom app bar container with:
/// - Left: WilayahDropdown showing active wilayah
/// - Right: OfflinePill (when offline) + NotificationBell
///
/// Use as a replacement for Scaffold's appBar parameter or as a standalone
/// header widget.
class WargaAppBar extends StatelessWidget {
  final String wilayahName;
  final bool isOffline;
  final int unreadCount;
  final VoidCallback? onWilayahTap;
  final VoidCallback? onNotificationTap;

  const WargaAppBar({
    super.key,
    required this.wilayahName,
    this.isOffline = false,
    this.unreadCount = 0,
    this.onWilayahTap,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 6, left: 18, right: 18, bottom: 12),
      decoration: const BoxDecoration(color: AppColors.bgSurface),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left: Wilayah dropdown
          WilayahDropdown(
            label: 'Wilayah aktif',
            value: wilayahName,
            onTap: onWilayahTap,
          ),

          // Right: Offline pill + notification bell
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isOffline) ...[const OfflinePill(), const SizedBox(width: 8)],
              GestureDetector(
                onTap: onNotificationTap,
                child: NotificationBell(unreadCount: unreadCount),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

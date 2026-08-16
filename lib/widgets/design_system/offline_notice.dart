import 'package:flutter/material.dart';

/// Amber-styled sync pending banner for Beranda Warga (M-05).
///
/// Displays pending sync count with descriptive message and optional action link.
/// Uses amber color scheme from PantauDesa design system.
class OfflineNotice extends StatelessWidget {
  /// Number to display in the amber badge (e.g., "2" reports pending).
  final int pendingCount;

  /// Main title text showing pending count message.
  final String title;

  /// Descriptive subtext explaining the sync status.
  final String description;

  /// Optional action link text (e.g., "Buka Pusat Sinkronisasi →").
  final String? actionText;

  /// Callback when action link is tapped.
  final VoidCallback? onActionTap;

  const OfflineNotice({
    super.key,
    this.pendingCount = 0,
    this.title = '',
    this.description = '',
    this.actionText,
    this.onActionTap,
  });

  /// Factory constructor for common offline/no connection scenario.
  factory OfflineNotice.offline({
    Key? key,
    String message = 'Tidak ada koneksi internet',
    VoidCallback? onActionTap,
  }) {
    return OfflineNotice(
      key: key,
      pendingCount: 0,
      title: message,
      description: 'Pastikan Wi-Fi atau data seluler aktif.',
      actionText: null,
      onActionTap: onActionTap,
    );
  }

  /// Factory constructor for sync pending scenario (M-05 Beranda Warga).
  factory OfflineNotice.syncPending({
    Key? key,
    required int count,
    VoidCallback? onActionTap,
  }) {
    return OfflineNotice(
      key: key,
      pendingCount: count,
      title: '$count laporan belum tersinkron',
      description:
          'Aman tersimpan di perangkat. Akan terkirim otomatis saat ada koneksi.',
      actionText: 'Buka Pusat Sinkronisasi →',
      onActionTap: onActionTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: const Color(0xffb8730a),
          ),
        ),
        const SizedBox(width: 8),
        Text(title),
      ],
    );
  }
}

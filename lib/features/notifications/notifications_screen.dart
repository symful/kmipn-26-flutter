import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/providers.dart';
import '../../theme/tokens.dart';

/// Notifications screen that displays user notifications from the server.
/// Supports marking individual notifications as read and marking all as read.
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  bool _markingAllRead = false;

  Future<void> _markAllRead() async {
    if (_markingAllRead) return;
    setState(() => _markingAllRead = true);
    try {
      final api = ref.read(apiClientProvider);
      await api.markAllNotificationsRead();
      ref.invalidate(notificationsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Semua notifikasi ditandai sudah dibaca'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menandai semua: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: SigapColors.perluTindakan,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _markingAllRead = false);
    }
  }

  Future<void> _markAsRead(String notificationId) async {
    try {
      final api = ref.read(apiClientProvider);
      await api.markNotificationRead(notificationId);
      ref.invalidate(notificationsProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menandai: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: SigapColors.perluTindakan,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: SigapColors.bgScreen,
      appBar: AppBar(
        title: const Text('Notifikasi'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _markingAllRead ? null : _markAllRead,
            child: _markingAllRead
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: SigapColors.primary,
                    ),
                  )
                : const Text('Baca semua'),
          ),
        ],
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return _buildEmptyState();
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(notificationsProvider),
            color: SigapColors.primary,
            child: ListView.builder(
              padding: const EdgeInsets.all(SigapSpacing.lg),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: SigapSpacing.sm),
                  child: _NotificationTile(
                    notification: notification,
                    onTap: () {
                      final notificationId = notification['id']?.toString();
                      final relatedReportId = notification['related_report_id']
                          ?.toString();
                      if (notificationId != null) {
                        _markAsRead(notificationId);
                      }
                      if (relatedReportId != null && relatedReportId.isNotEmpty) {
                        context.push('/detail/$relatedReportId');
                      }
                    },
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: SigapColors.primary,
          ),
        ),
        error: (error, _) => _buildErrorState(error),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SigapSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(SigapSpacing.xl),
              decoration: const BoxDecoration(
                color: SigapColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_outlined,
                size: 48,
                color: SigapColors.primary,
              ),
            ),
            const SizedBox(height: SigapSpacing.lg),
            const Text(
              'Tidak Ada Notifikasi',
              style: TextStyle(
                fontSize: SigapTypography.size16,
                fontWeight: FontWeight.bold,
                color: SigapColors.textPrimary,
              ),
            ),
            const SizedBox(height: SigapSpacing.xs),
            const Text(
              'Pemberitahuan terkait laporan atau penugasan akan muncul di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: SigapTypography.size13,
                color: SigapColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SigapSpacing.xl),
        child: Container(
          padding: const EdgeInsets.all(SigapSpacing.lg),
          decoration: BoxDecoration(
            color: SigapColors.surface,
            borderRadius: BorderRadius.circular(SigapRadius.md),
            border: Border.all(color: SigapColors.dangerBorder),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: SigapColors.perluTindakan,
              ),
              const SizedBox(height: SigapSpacing.md),
              const Text(
                'Gagal Memuat Notifikasi',
                style: TextStyle(
                  fontSize: SigapTypography.size16,
                  fontWeight: FontWeight.bold,
                  color: SigapColors.textPrimary,
                ),
              ),
              const SizedBox(height: SigapSpacing.xs),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: SigapTypography.size12,
                  color: SigapColors.textSecondary,
                ),
              ),
              const SizedBox(height: SigapSpacing.lg),
              ElevatedButton.icon(
                onPressed: () => ref.invalidate(notificationsProvider),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SigapColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final Map<String, dynamic> notification;
  final VoidCallback onTap;

  const _NotificationTile({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final readAt = notification['read_at'];
    final isRead = readAt != null;
    final title = notification['title']?.toString() ?? '';
    final body = notification['body']?.toString() ?? '';
    final createdAt = _formatDate(notification['created_at']);
    final kind = notification['kind']?.toString() ?? '';
    final color = _kindColor(kind);

    return Container(
      decoration: BoxDecoration(
        color: isRead ? SigapColors.surface : SigapColors.primaryLight.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(SigapRadius.md),
        border: Border.all(
          color: isRead ? SigapColors.border : SigapColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SigapRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(SigapSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon based on kind
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(SigapRadius.sm),
                ),
                child: Icon(_kindIcon(kind), size: 20, color: color),
              ),
              const SizedBox(width: SigapSpacing.md),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: SigapTypography.size14,
                              fontWeight: isRead
                                  ? FontWeight.w500
                                  : FontWeight.bold,
                              color: SigapColors.textPrimary,
                            ),
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(left: SigapSpacing.xs),
                            decoration: const BoxDecoration(
                              color: SigapColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    if (body.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        body,
                        style: const TextStyle(
                          fontSize: SigapTypography.size12,
                          color: SigapColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      createdAt,
                      style: const TextStyle(
                        fontSize: SigapTypography.size11,
                        color: SigapColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(dynamic value) {
    if (value == null) return '-';
    try {
      final date = DateTime.parse(value.toString());
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inMinutes < 1) return 'Baru saja';
      if (diff.inHours < 1) return '${diff.inMinutes} menit lalu';
      if (diff.inDays < 1) return '${diff.inHours} jam lalu';
      if (diff.inDays < 7) return '${diff.inDays} hari lalu';

      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      debugPrint('Error parsing date "$value": $e');
      return 'Tanggal tidak valid';
    }
  }

  IconData _kindIcon(String kind) {
    switch (kind.toLowerCase()) {
      case 'report_update':
      case 'status_change':
        return Icons.update;
      case 'new_comment':
      case 'comment':
        return Icons.comment_outlined;
      case 'assignment':
      case 'assigned':
        return Icons.assignment_ind_outlined;
      case 'verification':
      case 'verified':
        return Icons.verified_outlined;
      case 'resolution':
      case 'resolved':
        return Icons.check_circle_outline;
      case 'alert':
      case 'warning':
        return Icons.warning_amber_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _kindColor(String kind) {
    switch (kind.toLowerCase()) {
      case 'report_update':
      case 'status_change':
        return SigapColors.primary;
      case 'new_comment':
      case 'comment':
        return SigapColors.diproses;
      case 'assignment':
      case 'assigned':
        return SigapColors.warning;
      case 'verification':
      case 'verified':
        return SigapColors.selesai;
      case 'resolution':
      case 'resolved':
        return SigapColors.selesai;
      case 'alert':
      case 'warning':
        return SigapColors.perluTindakan;
      default:
        return SigapColors.textSecondary;
    }
  }
}

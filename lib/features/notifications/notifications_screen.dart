import 'package:sigap/widgets/request_error_details.dart';
import 'package:sigap/api/client.dart' show Notification;
import 'package:sigap/theme/sigap_color_scheme.dart';
import 'package:flutter/material.dart' hide Notification;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sigap/l10n/generated/app_localizations.dart';
import 'package:sigap/providers/providers.dart';
import 'package:sigap/theme/tokens.dart';
import 'package:sigap/utils/server_timestamp.dart';
import 'package:sigap/widgets/design_system/authenticated_shell.dart';
import 'package:sigap/widgets/design_system/sigap_app_bar.dart';

/// Notifications screen using the unified REST API client.
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
      final client = ref.read(apiClientProvider);
      await client.markAllNotificationsRead();
      ref.invalidate(notificationsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.semuaNotifikasiDibaca),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        showRequestFailure(context, e);
      }
    } finally {
      if (mounted) setState(() => _markingAllRead = false);
    }
  }

  Future<void> _markAsRead(String notificationId) async {
    try {
      final client = ref.read(apiClientProvider);
      await client.markNotificationRead(notificationId);
      ref.invalidate(notificationsProvider);
    } catch (e) {
      if (mounted) {
        showRequestFailure(context, e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(notificationsProvider);
    final activeRole = ref.watch(authNotifierProvider).userRole ?? '';

    return AuthenticatedShell(
      activeRole: activeRole,
      backgroundColor: SigapColorScheme.of(context).bgScreen,
      appBar: SigapAppBar(
        title: AppLocalizations.of(context)!.notifikasi,
        actions: [
          TextButton(
            onPressed: _markingAllRead ? null : _markAllRead,
            child: _markingAllRead
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: SigapColorScheme.of(context).primary,
                    ),
                  )
                : Text(AppLocalizations.of(context)!.bacaSemua),
          ),
        ],
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return _buildEmptyState();
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(notificationsProvider);
              await ref.read(notificationsProvider.future);
            },
            color: SigapColorScheme.of(context).primary,
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
                      final id = notification.id;
                      if (id != null) _markAsRead(id);
                      final relatedCaseId =
                          notification.relatedReportId ??
                          notification.relatedCaseId;
                      if (relatedCaseId != null && relatedCaseId.isNotEmpty) {
                        context.push('/laporan/$relatedCaseId');
                      }
                    },
                  ),
                );
              },
            ),
          );
        },
        loading: () => Center(
          child: CircularProgressIndicator(
            color: SigapColorScheme.of(context).primary,
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
              decoration: BoxDecoration(
                color: SigapColorScheme.of(context).primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_outlined,
                size: 48,
                color: SigapColorScheme.of(context).primary,
              ),
            ),
            SizedBox(height: SigapSpacing.lg),
            Text(
              AppLocalizations.of(context)!.tidakAdaNotifikasi,
              style: TextStyle(
                fontSize: SigapTypography.bodyLarge,
                fontWeight: FontWeight.bold,
                color: SigapColorScheme.of(context).textPrimary,
              ),
            ),
            SizedBox(height: SigapSpacing.xs),
            Text(
              AppLocalizations.of(context)!.pemberitahuanTerkait,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: SigapTypography.bodyText,
                color: SigapColorScheme.of(context).textSecondary,
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
            color: SigapColorScheme.of(context).surface,
            borderRadius: BorderRadius.circular(SigapRadius.md),
            border: Border.all(
              color: SigapColorScheme.of(context).dangerBorder,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: SigapColorScheme.of(context).perluTindakan,
              ),
              SizedBox(height: SigapSpacing.md),
              Text(
                AppLocalizations.of(context)!.gagalMemuatNotifikasi,
                style: TextStyle(
                  fontSize: SigapTypography.bodyLarge,
                  fontWeight: FontWeight.bold,
                  color: SigapColorScheme.of(context).textPrimary,
                ),
              ),
              SizedBox(height: SigapSpacing.xs),
              RequestErrorDetails(details: error.toString()),
              SizedBox(height: SigapSpacing.lg),
              ElevatedButton.icon(
                onPressed: () => ref.invalidate(notificationsProvider),
                icon: Icon(Icons.refresh, size: 18),
                label: Text(AppLocalizations.of(context)!.cobaLagi),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SigapColorScheme.of(context).primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
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
  final Notification notification;
  final VoidCallback onTap;

  const _NotificationTile({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // notification.read_at from backend, derive isRead as read_at == null means unread
    final readAt = notification.readAt;
    final isRead = readAt != null;
    final title = notification.title ?? '';
    final body = notification.body ?? '';
    final createdAtStr = notification.createdAt;
    final createdAt = parseServerTimestamp(createdAtStr);
    final kind = notification.kind ?? 'general';
    final color = _kindColor(context, kind);

    return Container(
      decoration: BoxDecoration(
        color: isRead
            ? SigapColorScheme.of(context).surface
            : SigapColorScheme.of(context).primaryLight.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(SigapRadius.md),
        border: Border.all(
          color: isRead
              ? SigapColorScheme.of(context).border
              : SigapColorScheme.of(context).primary.withValues(alpha: 0.3),
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
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(SigapRadius.sm),
                ),
                child: Icon(_kindIcon(kind), size: 20, color: color),
              ),
              SizedBox(width: SigapSpacing.md),
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
                              fontSize: SigapTypography.bodyMedium,
                              fontWeight: isRead
                                  ? FontWeight.w500
                                  : FontWeight.bold,
                              color: SigapColorScheme.of(context).textPrimary,
                            ),
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(
                              left: SigapSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: SigapColorScheme.of(context).primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    if (body.isNotEmpty) ...[
                      SizedBox(height: 4),
                      Text(
                        body,
                        style: TextStyle(
                          fontSize: SigapTypography.bodySmall,
                          color: SigapColorScheme.of(context).textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    SizedBox(height: 4),
                    Text(
                      createdAt != null ? _formatDate(context, createdAt) : '-',
                      style: TextStyle(
                        fontSize: SigapTypography.captionMedium,
                        color: SigapColorScheme.of(context).textTertiary,
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

  String _formatDate(BuildContext context, DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return AppLocalizations.of(context)!.baruSaja;
    if (diff.inHours < 1) {
      return '${diff.inMinutes} ${AppLocalizations.of(context)!.menitYangLalu}';
    }
    if (diff.inDays < 1) {
      return '${diff.inHours} ${AppLocalizations.of(context)!.jamYangLalu}';
    }
    if (diff.inDays < 7) {
      return '${diff.inDays} ${AppLocalizations.of(context)!.hariYangLalu}';
    }

    final local = date.toLocal();
    return '${local.day}/${local.month}/${local.year}';
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

  Color _kindColor(BuildContext context, String kind) {
    switch (kind.toLowerCase()) {
      case 'report_update':
      case 'status_change':
        return SigapColorScheme.of(context).primary;
      case 'new_comment':
      case 'comment':
        return SigapColorScheme.of(context).diproses;
      case 'assignment':
      case 'assigned':
        return SigapColorScheme.of(context).warning;
      case 'verification':
      case 'verified':
        return SigapColorScheme.of(context).selesai;
      case 'resolution':
      case 'resolved':
        return SigapColorScheme.of(context).selesai;
      case 'alert':
      case 'warning':
        return SigapColorScheme.of(context).perluTindakan;
      default:
        return SigapColorScheme.of(context).textSecondary;
    }
  }
}

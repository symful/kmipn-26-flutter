import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../db/database.dart';
import '../../providers/providers.dart';
import '../../theme/tokens.dart';
import '../../features/warga/presentation/widgets/detail_app_bar.dart';
import '../../features/warga/presentation/widgets/status_action_banner.dart';
import '../../features/warga/presentation/widgets/parent_case_card.dart';
import '../../features/warga/presentation/widgets/vertical_timeline.dart';
import '../../features/warga/presentation/widgets/privacy_notice.dart';

/// Converts API/server status string to LaporanStatus.
LaporanStatus _parseStatus(String? status) {
  switch (status?.toLowerCase()) {
    case 'submitted':
    case 'under_review':
    case 'needs_survey':
    case 'needs_completion':
      return LaporanStatus.pending;
    case 'verified':
    case 'in_progress':
      return LaporanStatus.reviewing;
    case 'resolved':
    case 'rejected':
    case 'duplicate_merged':
    case 'out_of_scope':
      return LaporanStatus.resolved;
    default:
      return LaporanStatus.pending;
  }
}

/// Laporan Detail Screen for warga to view their report status and timeline.
class LaporanDetailScreen extends ConsumerWidget {
  final String? reportId;

  const LaporanDetailScreen({super.key, this.reportId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // If reportId is not provided, show placeholder for testing
    if (reportId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Laporan')),
        body: const Center(child: Text('Report ID is required')),
      );
    }

    // Try to find the report - first check local, then server
    final localReportsAsync = ref.watch(localReportsProvider);
    final serverReportsAsync = ref.watch(wargaReportsProvider);

    return localReportsAsync.when(
      data: (localReports) {
        // Check local reports first
        final localReport = localReports
            .where(
              (r) => r.idempotencyKey == reportId || r.serverId == reportId,
            )
            .firstOrNull;

        if (localReport != null) {
          return _buildDetailScreen(context, ref, _localToMap(localReport));
        }

        // Check server reports
        return serverReportsAsync.when(
          data: (serverReports) {
            final serverReport = serverReports
                .where(
                  (r) =>
                      r['id']?.toString() == reportId ||
                      r['idempotency_key']?.toString() == reportId,
                )
                .firstOrNull;

            if (serverReport != null) {
              return _buildDetailScreen(context, ref, serverReport);
            }

            return _buildNotFoundScreen(context);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => _buildNotFoundScreen(context),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Detail Laporan')),
        body: Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildNotFoundScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Laporan')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search_off,
              size: 64,
              color: SigapColors.textTertiary,
            ),
            const SizedBox(height: SigapSpacing.md),
            const Text(
              'Laporan tidak ditemukan',
              style: TextStyle(fontSize: 16, color: SigapColors.textSecondary),
            ),
            const SizedBox(height: SigapSpacing.lg),
            TextButton(
              onPressed: () => context.go('/warga'),
              child: const Text('Kembali ke Beranda'),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _localToMap(LocalReport r) {
    return {
      'id': r.serverId ?? r.idempotencyKey,
      'idempotency_key': r.idempotencyKey,
      'description': r.description,
      'status': r.status,
      'category_id': r.categoryId,
      'lat': r.lat,
      'lng': r.lng,
      'photo_path': r.photoPath,
      'created_at': r.createdAt.toIso8601String(),
      'is_local': true,
    };
  }

  Widget _buildDetailScreen(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> report,
  ) {
    final status = _parseStatus(report['status'] as String?);

    // Build ID display string from report data
    final localId = report['idempotency_key']?.toString() ?? reportId ?? '';
    final serverId = report['id']?.toString() ?? '';

    // Demo: determine if we show perluTindakan banner
    // In production this would come from report data
    final showNeedsAction = status == LaporanStatus.pending;

    // Demo timeline - in production from API
    final timelineEvents = [
      TimelineEvent(
        title: 'Perlu dilengkapi',
        meta: '17 Jul, 14:20 · oleh verifikator RW',
        isActive: true,
      ),
      TimelineEvent(title: 'Sedang diperiksa', meta: '17 Jul, 11:05 · sistem'),
      TimelineEvent(
        title: 'Laporan diterima',
        meta: '17 Jul, 10:48 · ID server dibuat',
      ),
      TimelineEvent(
        title: 'Tersimpan di perangkat',
        meta: '17 Jul, 09:33 · offline',
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // App bar
            DetailAppBar(
              localId: localId,
              serverId: serverId,
              onBack: () => context.go('/warga'),
              onMore: () {
                // Menu action - to be implemented
              },
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: SigapSpacing.x14),

                    // Status Banner
                    if (showNeedsAction)
                      StatusActionBanner(
                        data: StatusBannerData(
                          status: ReportStatus.perluTindakan,
                          description:
                              'Verifikator meminta 1 foto tambahan dari sisi yang berbeda agar lubang terlihat jelas.',
                          deadline: DateTime(2026, 7, 19),
                          onActionTap: () {
                            // Navigate to complete report screen
                          },
                        ),
                      )
                    else
                      _buildSimpleStatusBanner(status),

                    const SizedBox(height: SigapSpacing.x14),

                    // Parent case card
                    ParentCaseCard(
                      parentCase: const ParentCase(
                        initials: 'JL',
                        title: 'Jalan berlubang dekat Pasar',
                      ),
                      onViewCase: () {
                        // Navigate to parent case
                      },
                    ),

                    const SizedBox(height: SigapSpacing.x14),

                    // Timeline
                    VerticalTimeline(events: timelineEvents),

                    const SizedBox(height: SigapSpacing.x14),

                    // Privacy notice
                    const PrivacyNotice(),

                    const SizedBox(height: SigapSpacing.xxl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a simple status banner for non-action-required states.
  Widget _buildSimpleStatusBanner(LaporanStatus status) {
    return Container(
      decoration: BoxDecoration(
        color: status.backgroundColor,
        borderRadius: BorderRadius.circular(SigapRadius.lg),
      ),
      padding: const EdgeInsets.all(SigapSpacing.x14),
      child: Row(
        children: [
          Icon(status.icon, color: status.color, size: 24),
          const SizedBox(width: SigapSpacing.sm),
          Expanded(
            child: Text(
              status.label,
              style: TextStyle(
                fontSize: SigapTypography.size13,
                fontWeight: FontWeight.w600,
                color: status.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Status type for laporan progression.
enum LaporanStatus { pending, reviewing, resolved }

extension LaporanStatusExt on LaporanStatus {
  String get label {
    switch (this) {
      case LaporanStatus.pending:
        return 'Menunggu';
      case LaporanStatus.reviewing:
        return 'Diverifikasi';
      case LaporanStatus.resolved:
        return 'Selesai';
    }
  }

  Color get color {
    switch (this) {
      case LaporanStatus.pending:
        return SigapColors.warning;
      case LaporanStatus.reviewing:
        return SigapColors.info;
      case LaporanStatus.resolved:
        return SigapColors.primary;
    }
  }

  Color get backgroundColor {
    switch (this) {
      case LaporanStatus.pending:
        return SigapColors.warningBg;
      case LaporanStatus.reviewing:
        return SigapColors.infoBg;
      case LaporanStatus.resolved:
        return SigapColors.primaryLight;
    }
  }

  IconData get icon {
    switch (this) {
      case LaporanStatus.pending:
        return Icons.schedule;
      case LaporanStatus.reviewing:
        return Icons.visibility;
      case LaporanStatus.resolved:
        return Icons.check_circle;
    }
  }
}

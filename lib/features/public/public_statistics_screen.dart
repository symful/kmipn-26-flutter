import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sigap/api/client.dart';
import 'package:sigap/l10n/generated/app_localizations.dart';
import 'package:sigap/l10n/status_label.dart';
import 'package:sigap/providers/providers.dart';
import 'package:sigap/theme/tokens.dart';
import 'package:sigap/widgets/design_system/design_system.dart';

// ─── Status order (matches web SPA) ──────────────────────────────────────────

const _statusOrder = [
  'submitted',
  'under_review',
  'verified',
  'in_progress',
  'needs_survey',
  'resolved',
  'rejected',
  'duplicate_merged',
];

Color _statusColor(String status) {
  switch (status) {
    case 'submitted':
      return SigapColors.perluTindakan;
    case 'under_review':
    case 'verified':
    case 'in_progress':
    case 'needs_survey':
      return SigapColors.diproses;
    case 'resolved':
      return SigapColors.selesai;
    case 'rejected':
      return SigapColors.danger;
    default:
      return SigapColors.textMuted;
  }
}

// ─── Provider ────────────────────────────────────────────────────────────────

final publicStatsProvider = FutureProvider.autoDispose<PublicStats>((
  ref,
) async {
  final api = ref.read(publicApiClientProvider);
  return await api.getPublicStats();
});

// ─── Screen ──────────────────────────────────────────────────────────────────

class PublicStatisticsScreen extends ConsumerWidget {
  const PublicStatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final statsAsync = ref.watch(publicStatsProvider);

    return ResponsiveScaffold(
      appBar: SigapAppBar(
        title: l10n.statistik,
        showSync: true,
        syncState: SyncState.online,
      ),
      body: statsAsync.when(
        data: (stats) => _buildBody(context, ref, stats),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorRetryView(
          message: l10n.gagalMemuatStatistik,
          onRetry: () => ref.invalidate(publicStatsProvider),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, PublicStats stats) {
    final l10n = AppLocalizations.of(context)!;
    final byStatus = stats.byStatus ?? {};
    final byCategory = stats.byCategory ?? [];
    final total = stats.total ?? 0;
    final resolved = byStatus['resolved'] ?? 0;
    final inProgress =
        (byStatus['under_review'] ?? 0) +
        (byStatus['verified'] ?? 0) +
        (byStatus['in_progress'] ?? 0);
    final needsAction =
        (byStatus['submitted'] ?? 0) + (byStatus['needs_survey'] ?? 0);
    final maxStatusCount = byStatus.values
        .map((v) => v is int ? v : 0)
        .fold<int>(1, (a, b) => a > b ? a : b);
    final maxCategoryCount = byCategory
        .map((c) => (c['count'] as int?) ?? 0)
        .fold<int>(1, (a, b) => a > b ? a : b);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(SigapSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Summary cards
          Row(
            children: [
              Expanded(
                child: _statCard(
                  '$total',
                  'Total Laporan',
                  SigapColors.textPrimary,
                ),
              ),
              const SizedBox(width: SigapSpacing.md),
              Expanded(
                child: _statCard(
                  '$resolved',
                  'Total Selesai',
                  SigapColors.selesai,
                ),
              ),
              const SizedBox(width: SigapSpacing.md),
              Expanded(
                child: _statCard(
                  '$inProgress',
                  'Sedang Diproses',
                  SigapColors.diproses,
                ),
              ),
              const SizedBox(width: SigapSpacing.md),
              Expanded(
                child: _statCard(
                  '$needsAction',
                  'Perlu Tindakan',
                  SigapColors.perluTindakan,
                ),
              ),
            ],
          ),
          const SizedBox(height: SigapSpacing.lg),

          // Status distribution
          SigapCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.distribusiStatus,
                  style: const TextStyle(
                    fontSize: SigapTypography.bodyLarge,
                    fontWeight: FontWeight.w600,
                    color: SigapColors.textPrimary,
                  ),
                ),
                const SizedBox(height: SigapSpacing.md),
                ..._statusOrder.where((s) => (byStatus[s] ?? 0) > 0).map((
                  status,
                ) {
                  final count = (byStatus[status] ?? 0) as int;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: SigapSpacing.sm),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              statusLabel(context, status),
                              style: const TextStyle(
                                fontSize: SigapTypography.bodySmall,
                                color: SigapColors.textSecondary,
                              ),
                            ),
                            Text(
                              '$count',
                              style: const TextStyle(
                                fontSize: SigapTypography.bodySmall,
                                fontWeight: FontWeight.w500,
                                color: SigapColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(SigapRadius.x4),
                          child: LinearProgressIndicator(
                            value: count / maxStatusCount,
                            backgroundColor: SigapColors.bgSurface,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _statusColor(status),
                            ),
                            minHeight: 10,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: SigapSpacing.lg),

          // Category distribution
          SigapCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.distribusiKategori,
                  style: const TextStyle(
                    fontSize: SigapTypography.bodyLarge,
                    fontWeight: FontWeight.w600,
                    color: SigapColors.textPrimary,
                  ),
                ),
                const SizedBox(height: SigapSpacing.md),
                if (byCategory.isEmpty)
                  Text(
                    l10n.dataKategoriTidakTersedia,
                    style: const TextStyle(
                      color: SigapColors.textMuted,
                      fontSize: SigapTypography.bodySmall,
                    ),
                  )
                else
                  ...byCategory.map((cat) {
                    final name = cat['name'] ?? cat['category_id'] ?? 'Unknown';
                    final count = (cat['count'] as int?) ?? 0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: SigapSpacing.sm),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '$name',
                                style: const TextStyle(
                                  fontSize: SigapTypography.bodySmall,
                                  color: SigapColors.textSecondary,
                                ),
                              ),
                              Text(
                                '$count',
                                style: const TextStyle(
                                  fontSize: SigapTypography.bodySmall,
                                  fontWeight: FontWeight.w500,
                                  color: SigapColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(SigapRadius.x4),
                            child: LinearProgressIndicator(
                              value: count / maxCategoryCount,
                              backgroundColor: SigapColors.bgSurface,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                SigapColors.primary,
                              ),
                              minHeight: 10,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String value, String label, Color color) {
    return SigapCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: SigapTypography.bodySmall,
              color: SigapColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

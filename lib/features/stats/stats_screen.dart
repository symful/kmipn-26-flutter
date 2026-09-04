import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../api/client.dart' as new_api;
import '../../../l10n/generated/app_localizations.dart';
import '../../../l10n/status_label.dart';
import '../../../theme/tokens.dart';
import '../../../widgets/design_system/design_system.dart';

/// Local adapter class that maps StatsResponse to what the screen expects
class StatsAdapter {
  final int total;
  final int reports;
  final int cases;
  final int slaOverdue;
  final Map<String, int> byStatus;
  final Map<String, int> byCategory;

  StatsAdapter({
    required this.total,
    required this.reports,
    required this.cases,
    required this.slaOverdue,
    required this.byStatus,
    required this.byCategory,
  });

  factory StatsAdapter.fromStatsResponse(new_api.StatsResponse r) {
    // Build byStatus from API response
    final statusMap = <String, int>{};
    final rawByStatus = r.byStatus;
    if (rawByStatus != null) {
      for (final entry in rawByStatus.entries) {
        statusMap[entry.key] = (entry.value is int) ? entry.value : 0;
      }
    }

    // Build byCategory from API response (List<Map> -> Map<String, int>)
    final categoryMap = <String, int>{};
    final rawByCategory = r.byCategory;
    if (rawByCategory != null) {
      for (final item in rawByCategory) {
        final key =
            item['category'] as String? ?? item['name'] as String? ?? 'Unknown';
        final value = item['count'] as int? ?? 0;
        categoryMap[key] = value;
      }
    }

    return StatsAdapter(
      total: r.total ?? 0,
      reports: r.total ?? 0, // API doesn't distinguish reports vs cases
      cases: 0,
      slaOverdue: (r.slaBreached ?? 0) + (r.slaAtRisk ?? 0),
      byStatus: statusMap,
      byCategory: categoryMap,
    );
  }
}

/// Stats screen showing report statistics from the unified API.
class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(_statsProvider);

    return Scaffold(
      backgroundColor: SigapColors.bgScreen,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.statistik),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        backgroundColor: SigapColors.surface,
        foregroundColor: SigapColors.textPrimary,
        elevation: 0,
      ),
      body: statsAsync.when(
        data: (stats) => SingleChildScrollView(
          padding: const EdgeInsets.all(SigapSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary cards
              Row(
                children: [
                  Expanded(
                    child: KPICard(
                      label: AppLocalizations.of(context)!.totalLaporan,
                      value: '${stats.reports}',
                      icon: Icons.assignment,
                      color: SigapColors.primary,
                    ),
                  ),
                  const SizedBox(width: SigapSpacing.md),
                  Expanded(
                    child: KPICard(
                      label: AppLocalizations.of(context)!.totalKasus,
                      value: '${stats.cases}',
                      icon: Icons.folder_open,
                      color: SigapColors.info,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SigapSpacing.md),

              // SLA Overdue
              if (stats.slaOverdue > 0) ...[
                SigapCard(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(SigapSpacing.sm),
                        decoration: BoxDecoration(
                          color: SigapColors.perluTindakan.withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(SigapRadius.sm),
                        ),
                        child: const Icon(
                          Icons.warning_amber,
                          color: SigapColors.perluTindakan,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: SigapSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.labelSlaTerlewat,
                              style: const TextStyle(
                                fontSize: SigapTypography.bodySmall,
                                color: SigapColors.textSecondary,
                              ),
                            ),
                            Text(
                              '${stats.slaOverdue} laporan',
                              style: const TextStyle(
                                fontSize: SigapTypography.bodyLarge,
                                fontWeight: FontWeight.w700,
                                color: SigapColors.perluTindakan,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: SigapSpacing.md),
              ],

              // By status
              if (stats.byStatus.isNotEmpty) ...[
                Text(
                  AppLocalizations.of(context)!.berdasarkanStatus,
                  style: const TextStyle(
                    fontSize: SigapTypography.bodyLarge,
                    fontWeight: FontWeight.w700,
                    color: SigapColors.textPrimary,
                  ),
                ),
                const SizedBox(height: SigapSpacing.md),
                SigapCard(
                  child: Column(
                    children: stats.byStatus.entries.map((e) {
                      final total = stats.reports;
                      final pct = total > 0
                          ? (e.value / total * 100).round()
                          : 0;
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: SigapSpacing.xs,
                        ),
                        child: ProgressRow(
                          label: _statusLabel(context, e.key),
                          count: e.value,
                          percentage: pct,
                          color: _statusColor(e.key),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: SigapSpacing.xl),
              ],

              // By category
              if (stats.byCategory.isNotEmpty) ...[
                Text(
                  AppLocalizations.of(context)!.berdasarkanKategori,
                  style: const TextStyle(
                    fontSize: SigapTypography.bodyLarge,
                    fontWeight: FontWeight.w700,
                    color: SigapColors.textPrimary,
                  ),
                ),
                const SizedBox(height: SigapSpacing.md),
                SigapCard(
                  child: Column(
                    children: stats.byCategory.entries.map((e) {
                      final total = stats.reports;
                      final pct = total > 0
                          ? (e.value / total * 100).round()
                          : 0;
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: SigapSpacing.xs,
                        ),
                        child: ProgressRow(
                          label: e.key,
                          count: e.value,
                          percentage: pct,
                          color: SigapColors.primary,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ],
          ),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(color: SigapColors.primary),
        ),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(SigapSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: SigapColors.perluTindakan,
                ),
                const SizedBox(height: SigapSpacing.md),
                Text(
                  AppLocalizations.of(context)!.gagalMemuatStatistik,
                  style: const TextStyle(
                    fontSize: SigapTypography.bodyLarge,
                    fontWeight: FontWeight.w600,
                    color: SigapColors.textPrimary,
                  ),
                ),
                const SizedBox(height: SigapSpacing.xs),
                Text(
                  e.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: SigapTypography.bodySmall,
                    color: SigapColors.textSecondary,
                  ),
                ),
                const SizedBox(height: SigapSpacing.lg),
                ElevatedButton(
                  onPressed: () => ref.invalidate(_statsProvider),
                  child: Text(AppLocalizations.of(context)!.cobaLagi),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _statusLabel(BuildContext context, String key) {
    final l10n = AppLocalizations.of(context)!;
    switch (key.toLowerCase()) {
      case 'pending':
        return l10n.menunggu;
      case 'in_progress':
      case 'inprogress':
      case 'diproses':
        return l10n.diproses;
      case 'resolved':
      case 'selesai':
        return l10n.selesai;
      case 'rejected':
      case 'ditolak':
        return l10n.ditolak;
      default:
        return key;
    }
  }

  Color _statusColor(String key) {
    switch (key.toLowerCase()) {
      case 'pending':
        return SigapColors.warning;
      case 'in_progress':
      case 'inprogress':
      case 'diproses':
        return SigapColors.diproses;
      case 'resolved':
      case 'selesai':
        return SigapColors.selesai;
      case 'rejected':
      case 'ditolak':
        return SigapColors.perluTindakan;
      default:
        return SigapColors.textSecondary;
    }
  }
}

// Provider
final _statsProvider = FutureProvider<StatsAdapter>((ref) async {
  final client = new_api.ApiClient();
  final response = await client.getStats();
  return StatsAdapter.fromStatsResponse(response);
});

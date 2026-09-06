import 'package:sigap/l10n/status_label.dart';
import 'package:sigap/l10n/category_label.dart';
import 'package:sigap/theme/sigap_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:sigap/widgets/request_error_details.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sigap/api/client.dart' as new_api;
import 'package:sigap/l10n/generated/app_localizations.dart';
import 'package:sigap/providers/providers.dart';
import 'package:sigap/theme/tokens.dart';
import 'package:sigap/widgets/design_system/design_system.dart';

/// Local adapter class that maps stats responses to what the screen expects
class StatsAdapter {
  final int? total;
  final int? reports;
  final int? cases;
  final int? slaOverdue;
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
        statusMap[entry.key] = entry.value;
      }
    }

    // Build byCategory from API response (List<Map> -> Map<String, int>)
    final categoryMap = <String, int>{};
    final rawByCategory = r.byCategory;
    if (rawByCategory != null) {
      for (final item in rawByCategory) {
        final key = item.category ?? item.name ?? 'Unknown';
        final value = item.count;
        if (value != null) categoryMap[key] = value;
      }
    }

    return StatsAdapter(
      total: r.total,
      reports: r.totalReports ?? r.total,
      cases: r.totalCases,
      slaOverdue: r.slaBreached,
      byStatus: statusMap,
      byCategory: categoryMap,
    );
  }

  factory StatsAdapter.fromPublicStats(new_api.PublicStats r) {
    // Build byStatus from public API response
    final statusMap = <String, int>{};
    final rawByStatus = r.byStatus;
    if (rawByStatus != null) {
      for (final entry in rawByStatus.entries) {
        statusMap[entry.key] = entry.value;
      }
    }

    // Build byCategory from public API response (List<Map> -> Map<String, int>)
    final categoryMap = <String, int>{};
    final rawByCategory = r.byCategory;
    if (rawByCategory != null) {
      for (final item in rawByCategory) {
        final key = item.category ?? item.name ?? 'Unknown';
        final value = item.count;
        if (value != null) categoryMap[key] = value;
      }
    }

    return StatsAdapter(
      total: r.total,
      reports: r.total,
      cases: r.totalCases,
      slaOverdue: r.slaBreached,
      byStatus: statusMap,
      byCategory: categoryMap,
    );
  }
}

/// Stats screen showing report statistics from the unified API.
class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(_statsProvider);
    final activeRole = ref.watch(authNotifierProvider).userRole ?? '';

    return AuthenticatedShell(
      activeRole: activeRole,
      backgroundColor: SigapColorScheme.of(context).background,
      appBar: SigapAppBar(title: AppLocalizations.of(context)!.statistik),
      body: statsAsync.when(
        data: (stats) => SingleChildScrollView(
          padding: const EdgeInsets.all(SigapSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLocalizations.of(context)!.statisticsExplanation),
              const SizedBox(height: SigapSpacing.md),
              // Summary cards
              if (stats.reports == null && stats.cases == null)
                Text(AppLocalizations.of(context)!.mobileSummaryUnavailable),
              Row(
                children: [
                  if (stats.reports != null)
                    Expanded(
                      child: KPICard(
                        label: AppLocalizations.of(context)!.totalLaporan,
                        value: stats.reports?.toString() ?? '—',
                        icon: Icons.assignment,
                        color: SigapColors.primary,
                      ),
                    ),
                  if (stats.reports != null && stats.cases != null)
                    const SizedBox(width: SigapSpacing.md),
                  if (stats.cases != null)
                    Expanded(
                      child: KPICard(
                        label: AppLocalizations.of(context)!.totalKasus,
                        value: stats.cases?.toString() ?? '—',
                        icon: Icons.folder_open,
                        color: SigapColors.info,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: SigapSpacing.md),

              // SLA Overdue
              if (stats.slaOverdue != null && stats.slaOverdue! > 0) ...[
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
                        child: Icon(
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
                              style: TextStyle(
                                fontSize: SigapTypography.bodySmall,
                                color: SigapColorScheme.of(
                                  context,
                                ).textSecondary,
                              ),
                            ),
                            Text(
                              AppLocalizations.of(
                                context,
                              )!.slaOverdueLaporan(stats.slaOverdue!),
                              style: TextStyle(
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
                  style: TextStyle(
                    fontSize: SigapTypography.bodyLarge,
                    fontWeight: FontWeight.w700,
                    color: SigapColorScheme.of(context).textPrimary,
                  ),
                ),
                const SizedBox(height: SigapSpacing.md),
                SigapCard(
                  child: Column(
                    children: stats.byStatus.entries.map((e) {
                      final total = stats.reports;
                      if (total == null) {
                        return Text(
                          '${_statusLabel(context, e.key)}: ${e.value}',
                        );
                      }
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
                          color: _statusColor(context, e.key),
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
                  style: TextStyle(
                    fontSize: SigapTypography.bodyLarge,
                    fontWeight: FontWeight.w700,
                    color: SigapColorScheme.of(context).textPrimary,
                  ),
                ),
                const SizedBox(height: SigapSpacing.md),
                SigapCard(
                  child: Column(
                    children: stats.byCategory.entries.map((e) {
                      final total = stats.reports;
                      if (total == null) {
                        return Text(
                          '${categoryLabel(context, e.key)}: ${e.value}',
                        );
                      }
                      final pct = total > 0
                          ? (e.value / total * 100).round()
                          : 0;
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: SigapSpacing.xs,
                        ),
                        child: ProgressRow(
                          label: categoryLabel(context, e.key),
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
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: SigapColors.perluTindakan,
                ),
                const SizedBox(height: SigapSpacing.md),
                Text(
                  AppLocalizations.of(context)!.gagalMemuatStatistik,
                  style: TextStyle(
                    fontSize: SigapTypography.bodyLarge,
                    fontWeight: FontWeight.w600,
                    color: SigapColorScheme.of(context).textPrimary,
                  ),
                ),
                const SizedBox(height: SigapSpacing.xs),
                RequestErrorDetails(details: e.toString()),
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

  String _statusLabel(BuildContext context, String key) =>
      statusLabel(context, switch (key.toLowerCase()) {
        'inprogress' || 'diproses' => 'in_progress',
        'selesai' => 'resolved',
        'ditolak' => 'rejected',
        _ => key.toLowerCase(),
      });

  Color _statusColor(BuildContext context, String key) {
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
        return SigapColorScheme.of(context).textSecondary;
    }
  }
}

// Provider — uses public stats for unauthenticated, authenticated stats for logged-in users
final _statsProvider = FutureProvider<StatsAdapter>((ref) async {
  final authState = ref.watch(authNotifierProvider);
  final client = ref.read(apiClientProvider);

  if (authState.isAuthenticated) {
    final response = await client.getStats();
    return StatsAdapter.fromStatsResponse(response);
  } else {
    final response = await client.getPublicStats();
    return StatsAdapter.fromPublicStats(response);
  }
});

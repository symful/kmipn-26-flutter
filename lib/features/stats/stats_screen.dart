import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../api/client.dart' as new_api;
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
        title: const Text('Statistik'),
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
                    child: _StatCard(
                      title: 'Total Laporan',
                      value: '${stats.reports}',
                      icon: Icons.assignment,
                      color: SigapColors.primary,
                    ),
                  ),
                  const SizedBox(width: SigapSpacing.md),
                  Expanded(
                    child: _StatCard(
                      title: 'Total Kasus',
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
                            const Text(
                              'Melewati SLA',
                              style: TextStyle(
                                fontSize: SigapTypography.size12,
                                color: SigapColors.textSecondary,
                              ),
                            ),
                            Text(
                              '${stats.slaOverdue} laporan',
                              style: const TextStyle(
                                fontSize: SigapTypography.size16,
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
                const Text(
                  'Berdasarkan Status',
                  style: TextStyle(
                    fontSize: SigapTypography.size16,
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
                        child: _StatusRow(
                          label: _statusLabel(e.key),
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
                const Text(
                  'Berdasarkan Kategori',
                  style: TextStyle(
                    fontSize: SigapTypography.size16,
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
                        child: _StatusRow(
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
                const Text(
                  'Gagal memuat statistik',
                  style: TextStyle(
                    fontSize: SigapTypography.size16,
                    fontWeight: FontWeight.w600,
                    color: SigapColors.textPrimary,
                  ),
                ),
                const SizedBox(height: SigapSpacing.xs),
                Text(
                  e.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: SigapTypography.size12,
                    color: SigapColors.textSecondary,
                  ),
                ),
                const SizedBox(height: SigapSpacing.lg),
                ElevatedButton(
                  onPressed: () => ref.invalidate(_statsProvider),
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _statusLabel(String key) {
    switch (key.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'in_progress':
      case 'inprogress':
      case 'diproses':
        return 'Diproses';
      case 'resolved':
      case 'selesai':
        return 'Selesai';
      case 'rejected':
      case 'ditolak':
        return 'Ditolak';
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

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SigapCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(SigapSpacing.sm),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(SigapRadius.sm),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          const SizedBox(height: SigapSpacing.md),
          Text(
            value,
            style: TextStyle(
              fontSize: SigapTypography.size28,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: SigapSpacing.xs),
          Text(
            title,
            style: const TextStyle(
              fontSize: SigapTypography.size12,
              color: SigapColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String label;
  final int count;
  final int percentage;
  final Color color;

  const _StatusRow({
    required this.label,
    required this.count,
    required this.percentage,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: SigapTypography.size13,
                color: SigapColors.textPrimary,
              ),
            ),
            Text(
              '$count ($percentage%)',
              style: TextStyle(
                fontSize: SigapTypography.size13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: SigapSpacing.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: color.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: SigapSpacing.sm),
      ],
    );
  }
}

// Provider
final _statsProvider = FutureProvider<StatsAdapter>((ref) async {
  final client = new_api.ApiClient();
  final response = await client.getStats();
  return StatsAdapter.fromStatsResponse(response);
});

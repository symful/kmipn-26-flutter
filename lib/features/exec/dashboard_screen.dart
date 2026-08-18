import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../providers/providers.dart';
import '../../../theme/tokens.dart';
import '../../../utils/logger.dart';

final _logger = Logger('ExecDashboardScreen');

class ExecDashboardScreen extends ConsumerStatefulWidget {
  const ExecDashboardScreen({super.key});

  @override
  ConsumerState<ExecDashboardScreen> createState() =>
      _ExecDashboardScreenState();
}

class _ExecDashboardScreenState extends ConsumerState<ExecDashboardScreen> {
  Map<String, dynamic>? _dashboard;
  Map<String, dynamic>? _regionalStats;
  Map<String, dynamic>? _trendData;
  String _trendPeriod = 'monthly';
  bool _loading = true;
  bool _exporting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final client = ref.read(apiClientProvider);
      final results = await Future.wait([
        client.getExecutiveDashboard(),
        client.getExecutiveRegionalStats(),
        client.getExecutiveTrendAnalysis(_trendPeriod),
      ]);
      setState(() {
        _dashboard = results[0];
        _regionalStats = results[1];
        _trendData = results[2];
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _changePeriod(String period) async {
    if (period == _trendPeriod) return;
    setState(() => _trendPeriod = period);
    _loadAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Pengambil Keputusan'),
        automaticallyImplyLeading: false,
        actions: [
          if (_exporting)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            PopupMenuButton<String>(
              icon: const Icon(Icons.share),
              tooltip: 'Export Data',
              onSelected: (value) {
                if (value == 'csv') _exportCsv();
                if (value == 'geojson') _exportGeoJson();
                if (value == 'pdf') _exportPdf();
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'csv',
                  child: Row(
                    children: [
                      Icon(Icons.table_chart, size: 20),
                      SizedBox(width: 8),
                      Text('Export CSV'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'geojson',
                  child: Row(
                    children: [
                      Icon(Icons.map, size: 20),
                      SizedBox(width: 8),
                      Text('Export GeoJSON'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'pdf',
                  child: Row(
                    children: [
                      Icon(Icons.picture_as_pdf, size: 20),
                      SizedBox(width: 8),
                      Text('Export PDF'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _ErrorRetry(error: _error!, onRetry: _loadAll)
          : RefreshIndicator(
              onRefresh: _loadAll,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _SummaryCards(stats: _dashboard!),
                    const SizedBox(height: AppSpacing.xl),
                    _TrendPeriodSelector(
                      selected: _trendPeriod,
                      onChanged: _changePeriod,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _VerificationTrendSection(data: _trendData!),
                    const SizedBox(height: AppSpacing.xl),
                    _RegionalDistribution(
                      wilayahData: _regionalStats!['by_wilayah'] as List? ?? [],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _CategoryDistribution(
                      categoryData: _dashboard!['by_category'] as List? ?? [],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _WilayahCategoryMatrix(
                      data:
                          _regionalStats!['by_wilayah_category'] as List? ?? [],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _DrillDownSection(
                      stats: _dashboard!,
                      regionalStats: _regionalStats!,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _exportCsv() async {
    if (_dashboard == null || _regionalStats == null) return;

    setState(() => _exporting = true);

    try {
      final buffer = StringBuffer();

      // Header
      buffer.writeln('EXECUTIVE DASHBOARD EXPORT');
      buffer.writeln('Generated: ${DateTime.now().toIso8601String()}');
      buffer.writeln('');

      // Summary Stats
      buffer.writeln('=== SUMMARY ===');
      buffer.writeln('Total Reports,${_dashboard!['total']}');
      buffer.writeln('SLA Breached,${_dashboard!['sla_breached']}');
      buffer.writeln('SLA At Risk,${_dashboard!['sla_at_risk']}');
      buffer.writeln(
        'Recent Submissions (7 days),${_dashboard!['recent_submissions']}',
      );
      buffer.writeln(
        'Resolved This Month,${_dashboard!['resolved_this_month']}',
      );
      buffer.writeln(
        'Avg Verification Days,${_dashboard!['avg_verification_days']}',
      );
      buffer.writeln(
        'Avg Resolution Days,${_dashboard!['avg_resolution_days']}',
      );
      buffer.writeln('Active Operators,${_dashboard!['active_operators']}');
      buffer.writeln('Active Petugas,${_dashboard!['active_petugas']}');
      buffer.writeln('Total Wilayah,${_dashboard!['total_wilayah']}');
      buffer.writeln('');

      // By Status
      buffer.writeln('=== STATUS BREAKDOWN ===');
      final byStatus = _dashboard!['by_status'] as Map<String, dynamic>? ?? {};
      for (final entry in byStatus.entries) {
        buffer.writeln('${entry.key},${entry.value}');
      }
      buffer.writeln('');

      // By Category
      buffer.writeln('=== CATEGORY BREAKDOWN ===');
      final byCategory = _dashboard!['by_category'] as List? ?? [];
      buffer.writeln('Category Name,Count');
      for (final cat in byCategory) {
        buffer.writeln('${cat['name']},${cat['count']}');
      }
      buffer.writeln('');

      // Regional Stats
      buffer.writeln('=== WILAYAH PERFORMANCE ===');
      final wilayahStats = _regionalStats!['by_wilayah'] as List? ?? [];
      buffer.writeln(
        'Wilayah,Total,Resolved,Active,SLA Breached,Resolution Rate %',
      );
      for (final w in wilayahStats) {
        buffer.writeln(
          '${w['wilayah_name']},${w['total_reports']},${w['resolved_reports']},${w['active_reports']},${w['sla_breached']},${w['resolution_rate']}',
        );
      }

      // Save to file
      final dir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${dir.path}/exec_dashboard_$timestamp.csv');
      await file.writeAsString(buffer.toString());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export saved: ${file.path}'),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _exportGeoJson() async {
    setState(() => _exporting = true);

    try {
      final client = ref.read(apiClientProvider);
      final geojson = await client.get('/api/export/geojson');

      final features = geojson['features'] as List? ?? [];
      final featureCollection = {
        'type': 'FeatureCollection',
        'metadata': {
          'exported_at': DateTime.now().toIso8601String(),
          'count': features.length,
        },
        'features': features,
      };

      // Save to file
      final dir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${dir.path}/exec_geojson_$timestamp.geojson');
      await file.writeAsString(jsonEncode(featureCollection));

      // Share the file
      await Share.shareXFiles([
        XFile(file.path),
      ], subject: 'SIGAP GeoJSON Export');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('GeoJSON exported: ${file.path}'),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _exportPdf() async {
    setState(() => _exporting = true);

    try {
      final client = ref.read(apiClientProvider);
      final bytes = await client.exportPdf();

      // Save to file
      final dir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${dir.path}/sigap-reports-$timestamp.pdf');
      await file.writeAsBytes(bytes);

      // Share the file
      await Share.shareXFiles([XFile(file.path)], subject: 'SIGAP PDF Export');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF exported: ${file.path}'),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }
}

class _TrendPeriodSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _TrendPeriodSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Tren Verifikasi: ',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 8),
        _PeriodChip(
          label: 'Harian',
          value: 'daily',
          selected: selected == 'daily',
          onTap: () => onChanged('daily'),
        ),
        const SizedBox(width: 8),
        _PeriodChip(
          label: 'Mingguan',
          value: 'weekly',
          selected: selected == 'weekly',
          onTap: () => onChanged('weekly'),
        ),
        const SizedBox(width: 8),
        _PeriodChip(
          label: 'Bulanan',
          value: 'monthly',
          selected: selected == 'monthly',
          onTap: () => onChanged('monthly'),
        ),
      ],
    );
  }
}

class _PeriodChip extends StatelessWidget {
  final String label;
  final String value;
  final bool selected;
  final VoidCallback onTap;

  const _PeriodChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.bgCard,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.borderCard,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: AppTypography.size12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            color: selected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _SummaryCards extends StatelessWidget {
  final Map<String, dynamic> stats;
  const _SummaryCards({required this.stats});

  @override
  Widget build(BuildContext context) {
    final total = stats['total'] as int? ?? 0;
    final slaBreached = stats['sla_breached'] as int? ?? 0;
    final slaAtRisk = stats['sla_at_risk'] as int? ?? 0;
    final backlog = slaBreached + slaAtRisk;
    final slaCompliance = total > 0
        ? ((total - slaBreached) / total * 100)
        : 100.0;
    final operators = stats['active_operators'] as int? ?? 0;
    final petugas = stats['active_petugas'] as int? ?? 0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Total Laporan',
                value: '$total',
                icon: Icons.folder_open,
                color: AppColors.primary,
                onTap: () => context.push('/operator/cases'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _StatCard(
                title: 'Backlog',
                value: '$backlog',
                icon: Icons.warning_amber,
                color: backlog > 0 ? AppColors.warning : AppColors.primary,
                onTap: () => context.push('/operator/cases?status=in_progress'),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'SLA Compliance',
                value: '${slaCompliance.toStringAsFixed(1)}%',
                icon: Icons.verified,
                color: slaCompliance >= 80
                    ? AppColors.primary
                    : slaCompliance >= 60
                    ? AppColors.warning
                    : AppColors.danger,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _StatCard(
                title: 'SLA Terlewat',
                value: '$slaBreached',
                icon: Icons.error,
                color: AppColors.danger,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Operator Aktif',
                value: '$operators',
                icon: Icons.engineering,
                color: AppColors.info,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _StatCard(
                title: 'Petugas Aktif',
                value: '$petugas',
                icon: Icons.badge,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _MiniStat(
                label: 'Rata-rata Verifikasi',
                value: '${stats['avg_verification_days'] ?? "-"} hari',
                icon: Icons.timer,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _MiniStat(
                label: 'Rata-rata Resolusi',
                value: '${stats['avg_resolution_days'] ?? "-"} hari',
                icon: Icons.check_circle,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.bgCard,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.borderCard),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: AppTypography.size22,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: AppTypography.size12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (onTap != null) ...[
                          const SizedBox(width: 4),
                          Icon(
                            Icons.chevron_right,
                            size: 14,
                            color: AppColors.textTertiary,
                          ),
                        ],
                      ],
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
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.borderCard),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textTertiary),
          const SizedBox(width: AppSpacing.x4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: AppTypography.size14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: AppTypography.size10,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VerificationTrendSection extends StatelessWidget {
  final Map<String, dynamic> data;
  const _VerificationTrendSection({required this.data});

  @override
  Widget build(BuildContext context) {
    final trend = data['avg_verification_days'] as List? ?? [];
    final breachTrend = data['sla_breaches'] as List? ?? [];

    if (trend.isEmpty && breachTrend.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tren Verifikasi & SLA',
          style: TextStyle(
            fontSize: AppTypography.size16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.borderCard),
          ),
          child: Column(
            children: [
              if (trend.isNotEmpty) ...[
                _TrendChartRow(
                  label: 'Rata-rata Hari Verifikasi',
                  data: trend,
                  valueKey: 'avg_verification_days',
                  maxValue: 30,
                  color: AppColors.primary,
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              if (breachTrend.isNotEmpty)
                _TrendChartRow(
                  label: 'Pelanggaran SLA',
                  data: breachTrend,
                  valueKey: 'breached_count',
                  maxValue: 20,
                  color: AppColors.danger,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TrendChartRow extends StatelessWidget {
  final String label;
  final List<dynamic> data;
  final String valueKey;
  final double maxValue;
  final Color color;

  const _TrendChartRow({
    required this.label,
    required this.data,
    required this.valueKey,
    required this.maxValue,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final max = data.fold<double>(maxValue, (prev, item) {
      final val = (item[valueKey] as num?)?.toDouble() ?? 0;
      return val > prev ? val : prev;
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: AppTypography.size12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.x4),
        SizedBox(
          height: 40,
          child: Row(
            children: data.take(12).map((item) {
              final val = (item[valueKey] as num?)?.toDouble() ?? 0;
              final fraction = max > 0 ? (val / max).clamp(0.05, 1.0) : 0.05;
              final period = _formatPeriod(item['period'] as String? ?? '');

              return Expanded(
                child: Tooltip(
                  message: '$period: $val',
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    alignment: Alignment.bottomCenter,
                    child: FractionallySizedBox(
                      heightFactor: fraction,
                      child: Container(
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              _formatPeriod(data.first['period'] as String? ?? ''),
              style: TextStyle(
                fontSize: AppTypography.size9,
                color: AppColors.textTertiary,
              ),
            ),
            const Spacer(),
            Text(
              _formatPeriod(data.last['period'] as String? ?? ''),
              style: TextStyle(
                fontSize: AppTypography.size9,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatPeriod(String period) {
    if (period.isEmpty) return '-';
    try {
      final dt = DateTime.parse(period);
      return '${dt.month}/${dt.year % 100}';
    } catch (e, s) {
      _logger.warning('Error parsing period "$period"', e, s);
      return period.length > 7 ? period.substring(0, 7) : period;
    }
  }
}

class _RegionalDistribution extends StatelessWidget {
  final List<dynamic> wilayahData;
  const _RegionalDistribution({required this.wilayahData});

  @override
  Widget build(BuildContext context) {
    if (wilayahData.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxTotal = wilayahData.fold<int>(1, (prev, item) {
      final total = (item['total_reports'] as num?)?.toInt() ?? 0;
      return total > prev ? total : prev;
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Distribusi per Wilayah',
              style: TextStyle(
                fontSize: AppTypography.size16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              '${wilayahData.length} wilayah',
              style: TextStyle(
                fontSize: AppTypography.size12,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        ...wilayahData
            .take(8)
            .map((item) => _WilayahBar(item: item, maxTotal: maxTotal)),
      ],
    );
  }
}

class _WilayahBar extends StatelessWidget {
  final Map<String, dynamic> item;
  final int maxTotal;

  const _WilayahBar({required this.item, required this.maxTotal});

  @override
  Widget build(BuildContext context) {
    final name = item['wilayah_name'] as String? ?? '-';
    final total = (item['total_reports'] as num?)?.toInt() ?? 0;
    final rate = (item['resolution_rate'] as num?)?.toDouble() ?? 0;
    final fraction = maxTotal > 0 ? (total / maxTotal) : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: AppTypography.size13,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$total kasus',
                    style: const TextStyle(
                      fontSize: AppTypography.size12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.x4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: rate >= 70
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : rate >= 40
                          ? AppColors.warning.withValues(alpha: 0.1)
                          : AppColors.danger.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${rate.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: AppTypography.size11,
                        fontWeight: FontWeight.w600,
                        color: rate >= 70
                            ? AppColors.primary
                            : rate >= 40
                            ? AppColors.warning
                            : AppColors.danger,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: fraction.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: AppColors.borderCard,
              color: rate >= 70
                  ? AppColors.primary
                  : rate >= 40
                  ? AppColors.warning
                  : AppColors.danger,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryDistribution extends StatelessWidget {
  final List<dynamic> categoryData;
  const _CategoryDistribution({required this.categoryData});

  @override
  Widget build(BuildContext context) {
    if (categoryData.isEmpty) {
      return const SizedBox.shrink();
    }

    final totalCount = categoryData.fold<int>(
      0,
      (sum, cat) => sum + ((cat['count'] as num?)?.toInt() ?? 0),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Distribusi per Kategori',
          style: TextStyle(
            fontSize: AppTypography.size16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: categoryData.take(6).map((cat) {
            final count = (cat['count'] as num?)?.toInt() ?? 0;
            final fraction = totalCount > 0 ? count / totalCount : 0.0;
            return _CategoryChip(
              name: cat['name'] as String? ?? '-',
              count: count,
              fraction: fraction,
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String name;
  final int count;
  final double fraction;

  const _CategoryChip({
    required this.name,
    required this.count,
    required this.fraction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.x4,
      ),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.borderCard),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _getCategoryColor(name),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.x4),
          Text(
            name,
            style: const TextStyle(
              fontSize: AppTypography.size12,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: AppSpacing.x4),
          Text(
            '$count',
            style: TextStyle(
              fontSize: AppTypography.size12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String name) {
    final colors = [
      AppColors.primary,
      AppColors.info,
      AppColors.warning,
      AppColors.primary,
      AppColors.primary,
      AppColors.warning,
    ];
    return colors[name.hashCode % colors.length].withValues(alpha: 0.8);
  }
}

class _WilayahCategoryMatrix extends StatelessWidget {
  final List<dynamic> data;
  const _WilayahCategoryMatrix({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const SizedBox.shrink();
    }

    // Group by category
    final categoryMap = <String, Map<String, int>>{};
    for (final row in data) {
      final catName = row['category_name'] as String? ?? '-';
      final wilName = row['wilayah_name'] as String? ?? '-';
      final count = (row['report_count'] as num?)?.toInt() ?? 0;

      categoryMap.putIfAbsent(catName, () => {});
      categoryMap[catName]![wilName] = count;
    }

    final categories = categoryMap.keys.take(5).toList();
    if (categories.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Matriks Wilayah x Kategori',
          style: TextStyle(
            fontSize: AppTypography.size16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: AppSpacing.lg,
            headingRowColor: WidgetStateProperty.all(AppColors.bgSurface),
            columns: const [
              DataColumn(label: Text('Kategori')),
              DataColumn(label: Text('Wilayah')),
              DataColumn(label: Text('Jumlah'), numeric: true),
            ],
            rows: data.take(10).map<DataRow>((row) {
              return DataRow(
                cells: [
                  DataCell(
                    Text(
                      row['category_name'] as String? ?? '-',
                      style: const TextStyle(fontSize: AppTypography.size12),
                    ),
                  ),
                  DataCell(
                    Text(
                      row['wilayah_name'] as String? ?? '-',
                      style: const TextStyle(fontSize: AppTypography.size12),
                    ),
                  ),
                  DataCell(
                    Text(
                      '${row['report_count'] ?? 0}',
                      style: const TextStyle(
                        fontSize: AppTypography.size12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _DrillDownSection extends StatelessWidget {
  final Map<String, dynamic> stats;
  final Map<String, dynamic> regionalStats;
  const _DrillDownSection({required this.stats, required this.regionalStats});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Drill-down',
          style: TextStyle(
            fontSize: AppTypography.size16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _DrillDownCard(
                icon: Icons.list_alt,
                label: 'Semua Kasus',
                subtitle: '${stats['total']} total',
                color: AppColors.primary,
                onTap: () => context.push('/operator/cases'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _DrillDownCard(
                icon: Icons.pending_actions,
                label: 'Menunggu',
                subtitle:
                    '${(stats['by_status']?['submitted'] as int? ?? 0) + (stats['by_status']?['under_review'] as int? ?? 0)} kasus',
                color: AppColors.warning,
                onTap: () => context.push('/operator/cases?status=pending'),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _DrillDownCard(
                icon: Icons.engineering,
                label: 'Dalam Proses',
                subtitle:
                    '${(stats['by_status']?['in_progress'] as int? ?? 0) + (stats['by_status']?['assigned'] as int? ?? 0) + (stats['by_status']?['verified'] as int? ?? 0)} kasus',
                color: AppColors.info,
                onTap: () => context.push('/operator/cases?status=in_progress'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _DrillDownCard(
                icon: Icons.check_circle,
                label: 'Selesai',
                subtitle:
                    '${(stats['by_status']?['resolved'] as int? ?? 0) + (stats['by_status']?['closed'] as int? ?? 0)} kasus',
                color: AppColors.primary,
                onTap: () => context.push('/operator/cases?status=resolved'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DrillDownCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _DrillDownCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.bgCard,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.borderCard),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: AppTypography.size14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: AppTypography.size12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorRetry({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.danger),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Gagal memuat: $error',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.md),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/providers.dart';
import '../../theme/tokens.dart';

class Report {
  final String id;
  final String description;
  final String status;
  final String? categoryId;
  final String? categoryName;
  final int? severity;
  final String createdAt;

  Report({
    required this.id,
    required this.description,
    required this.status,
    this.categoryId,
    this.categoryName,
    this.severity,
    required this.createdAt,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'] as String? ?? '',
      description: json['description'] as String? ?? '',
      status: json['status'] as String? ?? 'unknown',
      categoryId: json['category_id'] as String?,
      categoryName: json['category']?['name'] as String?,
      severity: (json['severity'] as num?)?.toInt(),
      createdAt: json['created_at'] as String? ?? '',
    );
  }
}

class DashboardStats {
  final int total;
  final int slaBreached;
  final int slaAtRisk;
  final int inProgress;
  final int verified;
  final int assigned;

  DashboardStats({
    required this.total,
    required this.slaBreached,
    required this.slaAtRisk,
    required this.inProgress,
    required this.verified,
    required this.assigned,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    final byStatus = json['by_status'] as Map<String, dynamic>? ?? {};
    return DashboardStats(
      total: (json['total'] as num?)?.toInt() ?? 0,
      slaBreached: (json['sla_breached'] as num?)?.toInt() ?? 0,
      slaAtRisk: (json['sla_at_risk'] as num?)?.toInt() ?? 0,
      inProgress: (byStatus['in_progress'] as num?)?.toInt() ?? 0,
      verified: (byStatus['verified'] as num?)?.toInt() ?? 0,
      assigned: (byStatus['assigned'] as num?)?.toInt() ?? 0,
    );
  }

  int get dalamProses => inProgress + verified + assigned;
}

final adminStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final api = ref.watch(apiClientProvider);
  final res = await api.get('/api/reports/stats');
  return DashboardStats.fromJson(res);
});

final adminReportsProvider = FutureProvider<List<Report>>((ref) async {
  final api = ref.watch(apiClientProvider);
  final res = await api.get('/api/reports');
  final items = res['reports'] as List? ?? [];
  return items.map((e) => Report.fromJson(e as Map<String, dynamic>)).toList();
});

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminStatsProvider);
    final reportsAsync = ref.watch(adminReportsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dasbor Admin'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: RefreshIndicator(
        color: SigapColors.primary,
        onRefresh: () async {
          ref.invalidate(adminStatsProvider);
          ref.invalidate(adminReportsProvider);
          await Future.wait([
            ref.read(adminStatsProvider.future),
            ref.read(adminReportsProvider.future),
          ]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(SigapSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              statsAsync.when(
                data: (stats) => _buildStatsGrid(stats),
                loading: () => _buildStatsLoading(),
                error: (e, _) => _buildStatsError(e),
              ),
              const SizedBox(height: SigapSpacing.xl),
              Text(
                'Laporan Terbaru',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: SigapColors.textPrimary,
                ),
              ),
              const SizedBox(height: SigapSpacing.md),
              reportsAsync.when(
                data: (reports) => _buildReportsList(context, reports),
                loading: () => _buildReportsLoading(),
                error: (e, _) => _buildReportsError(e),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(DashboardStats stats) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: SigapSpacing.md,
      crossAxisSpacing: SigapSpacing.md,
      childAspectRatio: 1.5,
      children: [
        _StatCard(
          label: 'Total Laporan',
          value: stats.total.toString(),
          color: SigapColors.textPrimary,
        ),
        _StatCard(
          label: 'SLA Terlewat',
          value: stats.slaBreached.toString(),
          color: SigapColors.perluTindakan,
        ),
        _StatCard(
          label: 'SLA Berisiko',
          value: stats.slaAtRisk.toString(),
          color: SigapColors.offlineDot,
        ),
        _StatCard(
          label: 'Dalam Proses',
          value: stats.dalamProses.toString(),
          color: SigapColors.diproses,
        ),
      ],
    );
  }

  Widget _buildStatsLoading() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: SigapSpacing.md,
      crossAxisSpacing: SigapSpacing.md,
      childAspectRatio: 1.5,
      children: List.generate(4, (_) => _buildStatCardSkeleton()),
    );
  }

  Widget _buildStatCardSkeleton() {
    return Container(
      decoration: BoxDecoration(
        color: SigapColors.surface,
        borderRadius: BorderRadius.circular(SigapRadius.md),
        border: Border.all(color: SigapColors.border),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: SigapColors.primary,
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildStatsError(Object error) {
    return Container(
      padding: const EdgeInsets.all(SigapSpacing.lg),
      decoration: BoxDecoration(
        color: SigapColors.surface,
        borderRadius: BorderRadius.circular(SigapRadius.md),
        border: Border.all(color: SigapColors.border),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline,
            color: SigapColors.perluTindakan,
            size: 32,
          ),
          const SizedBox(height: SigapSpacing.sm),
          Text(
            'Gagal memuat statistik',
            style: TextStyle(color: SigapColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildReportsList(BuildContext context, List<Report> reports) {
    if (reports.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(SigapSpacing.xl),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.inbox, size: 64, color: SigapColors.textMuted),
              const SizedBox(height: SigapSpacing.lg),
              Text(
                'Belum ada laporan',
                style: TextStyle(fontSize: 16, color: SigapColors.textMuted),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: reports.length,
      itemBuilder: (context, index) {
        final report = reports[index];
        return _ReportCard(report: report);
      },
    );
  }

  Widget _buildReportsLoading() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      itemBuilder: (_, __) => _buildReportCardSkeleton(),
    );
  }

  Widget _buildReportCardSkeleton() {
    return Container(
      margin: const EdgeInsets.only(bottom: SigapSpacing.md),
      padding: const EdgeInsets.all(SigapSpacing.lg),
      decoration: BoxDecoration(
        color: SigapColors.surface,
        borderRadius: BorderRadius.circular(SigapRadius.md),
        border: Border.all(color: SigapColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 80, height: 14, color: SigapColors.border),
                const SizedBox(height: SigapSpacing.sm),
                Container(
                  width: double.infinity,
                  height: 14,
                  color: SigapColors.border,
                ),
              ],
            ),
          ),
          const SizedBox(width: SigapSpacing.md),
          Container(width: 60, height: 24, color: SigapColors.border),
        ],
      ),
    );
  }

  Widget _buildReportsError(Object error) {
    return Container(
      padding: const EdgeInsets.all(SigapSpacing.xl),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: SigapColors.perluTindakan,
            ),
            const SizedBox(height: SigapSpacing.lg),
            Text(
              'Gagal memuat data',
              style: TextStyle(fontSize: 16, color: SigapColors.textSecondary),
            ),
            const SizedBox(height: SigapSpacing.sm),
            Text(
              '$error',
              style: TextStyle(color: SigapColors.textMuted, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SigapSpacing.md),
      decoration: BoxDecoration(
        color: SigapColors.surface,
        borderRadius: BorderRadius.circular(SigapRadius.md),
        border: Border.all(color: SigapColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12, color: SigapColors.textMuted),
          ),
          const SizedBox(height: SigapSpacing.xs),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final Report report;

  const _ReportCard({required this.report});

  Color _statusColor() {
    switch (report.status.toLowerCase()) {
      case 'pending':
        return SigapColors.perluTindakan;
      case 'in_progress':
        return SigapColors.diproses;
      case 'verified':
        return SigapColors.diproses;
      case 'assigned':
        return SigapColors.diproses;
      case 'completed':
      case 'selesai':
        return SigapColors.selesai;
      default:
        return SigapColors.textMuted;
    }
  }

  String _statusLabel() {
    switch (report.status.toLowerCase()) {
      case 'pending':
        return 'Menunggu';
      case 'in_progress':
        return 'Diproses';
      case 'verified':
        return 'Terverifikasi';
      case 'assigned':
        return 'Ditugaskan';
      case 'completed':
        return 'Selesai';
      case 'selesai':
        return 'Selesai';
      default:
        return report.status;
    }
  }

  String _truncateDescription(String desc) {
    if (desc.length <= 80) return desc;
    return '${desc.substring(0, 80)}...';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: SigapSpacing.md),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SigapRadius.md),
        side: const BorderSide(color: SigapColors.border),
      ),
      child: InkWell(
        onTap: () => context.push('/admin/cases/${report.id}'),
        borderRadius: BorderRadius.circular(SigapRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(SigapSpacing.lg),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ID: ${report.id.length > 8 ? report.id.substring(0, 8) : report.id}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: SigapSpacing.sm),
                    Text(
                      _truncateDescription(report.description),
                      style: TextStyle(
                        color: SigapColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    if (report.categoryName != null) ...[
                      const SizedBox(height: SigapSpacing.xs),
                      Text(
                        report.categoryName!,
                        style: TextStyle(
                          fontSize: 12,
                          color: SigapColors.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: SigapSpacing.md),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: SigapSpacing.sm,
                  vertical: SigapSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: _statusColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(SigapRadius.sm),
                ),
                child: Text(
                  _statusLabel(),
                  style: TextStyle(
                    color: _statusColor(),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

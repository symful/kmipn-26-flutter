import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/providers.dart';
import '../../../theme/tokens.dart';
import '../../../widgets/skeleton_loaders.dart';

class OperatorDashboardScreen extends ConsumerStatefulWidget {
  const OperatorDashboardScreen({super.key});

  @override
  ConsumerState<OperatorDashboardScreen> createState() =>
      _OperatorDashboardScreenState();
}

class _OperatorDashboardScreenState
    extends ConsumerState<OperatorDashboardScreen> {
  Map<String, dynamic>? _stats;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final client = ref.read(apiClientProvider);
      final data = await client.get('/api/operator/dashboard');
      setState(() {
        _stats = data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Operator'),
        automaticallyImplyLeading: false,
      ),
      body: _loading
          ? const OperatorDashboardSkeleton()
          : _error != null
          ? _ErrorRetry(error: _error!, onRetry: _loadStats)
          : RefreshIndicator(
              onRefresh: _loadStats,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(SigapSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _SummaryCards(stats: _stats!),
                    const SizedBox(height: SigapSpacing.xl),
                    _QuickActions(),
                  ],
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
    final total = stats['total_cases'] as int? ?? 0;
    final pending = stats['pending'] as int? ?? 0;
    final inProgress = stats['in_progress'] as int? ?? 0;
    final resolved = stats['resolved'] as int? ?? 0;
    final slaBreach = stats['sla_breach_count'] as int? ?? 0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Total Kasus',
                value: '$total',
                icon: Icons.folder_open,
                color: SigapColors.primary,
              ),
            ),
            const SizedBox(width: SigapSpacing.md),
            Expanded(
              child: _StatCard(
                title: 'Menunggu',
                value: '$pending',
                icon: Icons.pending_actions,
                color: SigapColors.perluTindakan,
              ),
            ),
          ],
        ),
        const SizedBox(height: SigapSpacing.md),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Diproses',
                value: '$inProgress',
                icon: Icons.engineering,
                color: SigapColors.diproses,
              ),
            ),
            const SizedBox(width: SigapSpacing.md),
            Expanded(
              child: _StatCard(
                title: 'Selesai',
                value: '$resolved',
                icon: Icons.check_circle,
                color: SigapColors.selesai,
              ),
            ),
          ],
        ),
        const SizedBox(height: SigapSpacing.md),
        _StatCard(
          title: 'Pelanggaran SLA',
          value: '$slaBreach',
          icon: Icons.warning,
          color: SigapColors.perluTindakan,
          fullWidth: true,
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
  final bool fullWidth;
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SigapSpacing.lg),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(SigapRadius.md),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: SigapSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: color.withValues(alpha: 0.8),
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

class _QuickActions extends ConsumerStatefulWidget {
  @override
  ConsumerState<_QuickActions> createState() => _QuickActionsState();
}

class _QuickActionsState extends ConsumerState<_QuickActions> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Aksi Cepat',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: SigapSpacing.md),
        Row(
          children: [
            Expanded(
              child: _ActionCard(
                icon: Icons.list_alt,
                label: 'Daftar Kasus',
                color: SigapColors.primary,
                onTap: () => context.push('/operator/cases'),
              ),
            ),
            const SizedBox(width: SigapSpacing.md),
            Expanded(
              child: _ActionCard(
                icon: Icons.bar_chart,
                label: 'Statistik',
                color: SigapColors.primary,
                onTap: () => _showStatsDialog(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _showStatsDialog() async {
    final client = ref.read(apiClientProvider);
    Map<String, dynamic>? stats;
    String? error;
    bool loading = true;

    try {
      stats = await client.get('/api/reports/stats');
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Statistik'),
        content: loading
            ? const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              )
            : error != null
            ? Text('Gagal memuat statistik: $error')
            : _buildStatsContent(stats!),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsContent(Map<String, dynamic> stats) {
    final total = (stats['total'] as num?)?.toInt() ?? 0;
    final slaBreached = (stats['sla_breached'] as num?)?.toInt() ?? 0;
    final slaAtRisk = (stats['sla_at_risk'] as num?)?.toInt() ?? 0;
    final byStatus = stats['by_status'] as Map<String, dynamic>? ?? {};

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StatRow(label: 'Total Laporan', value: '$total'),
          const Divider(),
          _StatRow(
            label: 'SLA Terlewat',
            value: '$slaBreached',
            color: SigapColors.perluTindakan,
          ),
          _StatRow(
            label: 'SLA Berisiko',
            value: '$slaAtRisk',
            color: SigapColors.offlineDot,
          ),
          const Divider(),
          _StatRow(
            label: 'Dalam Proses',
            value: '${(byStatus['in_progress'] as num?)?.toInt() ?? 0}',
          ),
          _StatRow(
            label: 'Terverifikasi',
            value: '${(byStatus['verified'] as num?)?.toInt() ?? 0}',
          ),
          _StatRow(
            label: 'Ditugaskan',
            value: '${(byStatus['assigned'] as num?)?.toInt() ?? 0}',
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _StatRow({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SigapSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: SigapColors.textSecondary)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color ?? SigapColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(SigapRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SigapRadius.md),
        child: Container(
          padding: const EdgeInsets.all(SigapSpacing.lg),
          decoration: BoxDecoration(
            border: Border.all(color: color.withValues(alpha: 0.2)),
            borderRadius: BorderRadius.circular(SigapRadius.md),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 36),
              const SizedBox(height: SigapSpacing.sm),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
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
          const Icon(
            Icons.error_outline,
            size: 64,
            color: SigapColors.perluTindakan,
          ),
          const SizedBox(height: 16),
          Text('Gagal memuat: $error'),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: const Text('Coba Lagi')),
        ],
      ),
    );
  }
}

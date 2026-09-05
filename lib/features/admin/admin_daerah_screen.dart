import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../api/client.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/providers.dart';
import '../../theme/tokens.dart';
import '../../widgets/design_system/design_system.dart';

/// ADMIN_DAERAH regional dashboard.
///
/// Shows regional statistics, unit performance, and wilayah breakdown.
/// Route: /admin-daerah
class AdminDaerahScreen extends ConsumerStatefulWidget {
  const AdminDaerahScreen({super.key});

  @override
  ConsumerState<AdminDaerahScreen> createState() => _AdminDaerahScreenState();
}

class _AdminDaerahScreenState extends ConsumerState<AdminDaerahScreen> {
  bool _loading = true;
  String? _error;
  AdminDaerahDashboard? _dashboard;
  List<Unit> _units = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final client = ref.read(apiClientProvider);
      final results = await Future.wait([
        client.getAdminDaerahDashboard(),
        client.getUnits(),
      ]);
      final dashboard = results[0] as AdminDaerahDashboard;
      final units = (results[1] as UnitsPage).entries;
      setState(() {
        _dashboard = dashboard;
        _units = units;
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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adminDaerah),
        automaticallyImplyLeading: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: ErrorRetryView(
                message: l10n.gagalMemuatData,
                onRetry: _loadData,
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(SigapSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Stats grid
                    _buildStatsGrid(l10n),
                    const SizedBox(height: SigapSpacing.lg),
                    // Units section
                    _buildUnitsSection(l10n),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatsGrid(AppLocalizations l10n) {
    final total = _dashboard?.total ?? 0;
    final activeOperators = _dashboard?.activeOperators ?? 0;
    final activePetugas = _dashboard?.activePetugas ?? 0;
    final slaBreached = _dashboard?.slaBreached ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.ringkasanTab,
          style: const TextStyle(
            fontSize: SigapTypography.bodyLarge,
            fontWeight: FontWeight.w700,
            color: SigapColors.textPrimary,
          ),
        ),
        const SizedBox(height: SigapSpacing.sm),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: SigapSpacing.sm,
          crossAxisSpacing: SigapSpacing.sm,
          childAspectRatio: 1.8,
          children: [
            _StatCard(
              label: 'Total Kasus',
              value: '$total',
              color: SigapColors.primary,
            ),
            _StatCard(
              label: 'Operator Aktif',
              value: '$activeOperators',
              color: SigapColors.info,
            ),
            _StatCard(
              label: 'Petugas Aktif',
              value: '$activePetugas',
              color: SigapColors.selesai,
            ),
            _StatCard(
              label: 'SLA Terlewat',
              value: '$slaBreached',
              color: SigapColors.danger,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUnitsSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SKPD & Unit',
          style: const TextStyle(
            fontSize: SigapTypography.bodyLarge,
            fontWeight: FontWeight.w700,
            color: SigapColors.textPrimary,
          ),
        ),
        const SizedBox(height: SigapSpacing.sm),
        if (_units.isEmpty)
          EmptyState(
            icon: Icons.business_outlined,
            title: 'Belum ada unit',
            subtitle: 'Unit teknis belum terdaftar',
          )
        else
          ..._units.map(
            (unit) => Card(
              margin: const EdgeInsets.only(bottom: SigapSpacing.sm),
              child: ListTile(
                leading: const Icon(Icons.business, color: SigapColors.primary),
                title: Text(
                  unit.name ?? '-',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(unit.id ?? ''),
              ),
            ),
          ),
      ],
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
        color: SigapColors.bgCard,
        borderRadius: BorderRadius.circular(SigapRadius.md),
        border: Border.all(color: SigapColors.borderCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: SigapTypography.captionMedium,
              color: SigapColors.textTertiary,
            ),
          ),
          const SizedBox(height: SigapSpacing.xs),
          Text(
            value,
            style: TextStyle(
              fontSize: SigapTypography.headlineMedium,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

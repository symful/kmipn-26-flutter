import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'theme/tokens.dart';
import 'api/api_client.dart';
import 'features/create/create_report_screen.dart';
import 'features/detail/report_detail_screen.dart';
import 'features/map/map_screen.dart';
import 'features/rt_rw/verify_screen.dart';
import 'features/verifikator/case_detail_screen.dart';
import 'features/operator/dashboard_screen.dart';
import 'features/operator/case_list_screen.dart';
import 'features/operator/case_detail_screen.dart' as operator_detail;
import 'features/petugas/task_detail_screen.dart';
import 'features/surveyor/task_list_screen.dart';
import 'features/surveyor/task_detail_screen.dart';

import 'features/surveyor/form_survei.dart';
import 'features/exec/dashboard_screen.dart';
import 'features/admin_daerah/wilayah_screen.dart';
import 'features/admin_daerah/categories_screen.dart';
import 'features/admin_daerah/sla_screen.dart';
import 'features/admin_daerah/units_screen.dart';
import 'features/admin_daerah/priority_config_screen.dart';
import 'features/admin_daerah/accounts_screen.dart';
import 'features/admin_daerah/integrasi_screen.dart';
import 'features/auditor/audit_log_screen.dart';
import 'features/warga/sanggahan_screen.dart';
import 'features/warga/reopen_request_screen.dart';
import 'features/warga/complementary_evidence_screen.dart';
import 'features/warga/warga_home_screen.dart';
import 'features/warga/review_kiriman_screen.dart';
import 'features/notifications/notifications_screen.dart';
import 'screens/warga/laporan_detail_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/role_switcher/role_switcher_screen.dart';
import 'screens/verifikator/queue_screen.dart';
import 'screens/petugas/dashboard.dart';
import 'providers/auth_provider.dart';
import 'providers/providers.dart';
import 'widgets/role_banner.dart';

// Role-based redirect screen - reads activeRole and navigates to appropriate dashboard
class RoleBasedRedirectScreen extends ConsumerWidget {
  const RoleBasedRedirectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final activeRole = authState.activeRole ?? authState.userRole;

    // Redirect based on active role
    final redirectPath = RoleRedirectHelper.getRedirectPath(activeRole);

    // Use delayed navigation to avoid build-time issues
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        context.go(redirectPath);
      }
    });

    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

// Helper class for role-based redirect paths
class RoleRedirectHelper {
  static String getRedirectPath(String? role) {
    switch (role?.toLowerCase()) {
      case 'warga':
        return '/warga';
      case 'surveyor':
        return '/surveyor';
      case 'verifikator':
        return '/verifikator';
      case 'petugas':
        return '/petugas';
      case 'operator':
        return '/operator';
      case 'admin_daerah':
        return '/admin-daerah';
      case 'auditor':
        return '/auditor';
      case 'exec':
        return '/exec';
      case 'admin':
        return '/admin-daerah';
      default:
        // Fallback to home if no role
        return '/warga';
    }
  }
}

// Wrapper widget that adds role switcher to app bar for multi-role users
class RoleAppBarWrapper extends ConsumerWidget {
  final Widget child;
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;

  const RoleAppBarWrapper({
    super.key,
    required this.child,
    required this.title,
    this.showBackButton = false,
    this.actions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final hasMultipleRoles = authState.roles.length > 1;

    return Column(
      children: [
        const RoleBanner(),
        Expanded(
          child: Scaffold(
            appBar: AppBar(
              title: Text(title),
              automaticallyImplyLeading: showBackButton,
              leading: showBackButton
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => context.pop(),
                    )
                  : null,
              actions: [
                ...?actions,
                if (hasMultipleRoles)
                  IconButton(
                    icon: const Icon(Icons.swap_horiz),
                    tooltip: 'Ganti Peran',
                    onPressed: () => context.push('/switch-role'),
                  ),
              ],
            ),
            body: child,
          ),
        ),
      ],
    );
  }
}

// Surveyor home screen with real API data
class SurveyorHomeScreen extends ConsumerStatefulWidget {
  const SurveyorHomeScreen({super.key});

  @override
  ConsumerState<SurveyorHomeScreen> createState() => _SurveyorHomeScreenState();
}

class _SurveyorHomeScreenState extends ConsumerState<SurveyorHomeScreen> {
  List<Map<String, dynamic>> _tasks = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final client = ref.read(apiClientProvider);
      final data = await client.surveyorGetTasks();
      setState(() {
        _tasks = data;
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
    return RoleAppBarWrapper(
      title: 'Beranda Surveyor',
      actions: [
        IconButton(icon: const Icon(Icons.refresh), onPressed: _loadTasks),
        TextButton(
          onPressed: () => context.push('/surveyor/tasks'),
          child: const Text('Lihat Tugas'),
        ),
      ],
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildErrorState()
          : _buildDashboard(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SigapSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: SigapColors.perluTindakan,
            ),
            const SizedBox(height: 16),
            const Text(
              'Gagal memuat data',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? '',
              style: const TextStyle(color: SigapColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadTasks,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard() {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    int pending = 0;
    int inProgress = 0;
    int completedToday = 0;
    int total = _tasks.length;

    for (final task in _tasks) {
      final status = (task['status'] as String?)?.toLowerCase() ?? '';
      final completedAt = task['completed_at'] as String?;

      if (status == 'pending' || status == 'assigned') {
        pending++;
      } else if (status == 'in_progress' || status == 'ongoing') {
        inProgress++;
      }

      if (completedAt != null) {
        try {
          final completedDate = DateTime.parse(completedAt);
          if (completedDate.isAfter(todayStart) ||
              completedDate.isAtSameMomentAs(todayStart)) {
            completedToday++;
          }
        } catch (_) {}
      }
    }

    return RefreshIndicator(
      onRefresh: _loadTasks,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(SigapSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStatCard(
              title: 'Total Tugas',
              value: '$total',
              icon: Icons.assignment,
              color: SigapColors.primary,
            ),
            const SizedBox(height: SigapSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'Menunggu',
                    value: '$pending',
                    icon: Icons.pending_actions,
                    color: SigapColors.perluTindakan,
                  ),
                ),
                const SizedBox(width: SigapSpacing.md),
                Expanded(
                  child: _buildStatCard(
                    title: 'Diproses',
                    value: '$inProgress',
                    icon: Icons.engineering,
                    color: SigapColors.diproses,
                  ),
                ),
              ],
            ),
            const SizedBox(height: SigapSpacing.md),
            _buildStatCard(
              title: 'Selesai Hari Ini',
              value: '$completedToday',
              icon: Icons.check_circle,
              color: SigapColors.selesai,
            ),
            const SizedBox(height: SigapSpacing.xl),
            _buildQuickActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
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

  Widget _buildQuickActions() {
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
                label: 'Daftar Tugas',
                color: SigapColors.primary,
                onTap: () => context.push('/surveyor/tasks'),
              ),
            ),
            const SizedBox(width: SigapSpacing.md),
            Expanded(
              child: _ActionCard(
                icon: Icons.map,
                label: 'Peta',
                color: SigapColors.primary,
                onTap: () => context.push('/map'),
              ),
            ),
          ],
        ),
      ],
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

class VerifikatorHomeScreen extends ConsumerStatefulWidget {
  const VerifikatorHomeScreen({super.key});

  @override
  ConsumerState<VerifikatorHomeScreen> createState() =>
      _VerifikatorHomeScreenState();
}

class _VerifikatorHomeScreenState extends ConsumerState<VerifikatorHomeScreen> {
  Map<String, int> _counts = {};
  List<Map<String, dynamic>> _recentItems = [];
  bool _loading = true;
  String? _error;

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
      // Use the dedicated API method with high limit to get all queue items for dashboard
      final data = await client.getVerifikatorQueue(limit: 100);
      final items =
          (data['items'] as List?) ??
          (data['data'] as List?) ??
          (data['queue'] as List?) ??
          [];

      int menunggu = 0;
      int diproses = 0;
      int diverifikasi = 0;
      int ditolak = 0;

      for (final item in items) {
        final status = (item['status'] as String?)?.toLowerCase() ?? '';
        if (status == 'pending' ||
            status == 'submitted' ||
            status == 'under_review') {
          menunggu++;
        } else if (status == 'in_progress' || status == 'processing') {
          diproses++;
        } else if (status == 'verified' || status == 'completed') {
          diverifikasi++;
        } else if (status == 'rejected') {
          ditolak++;
        }
      }

      setState(() {
        _counts = {
          'menunggu': menunggu,
          'diproses': diproses,
          'diverifikasi': diverifikasi,
          'ditolak': ditolak,
          'total': items.length,
        };
        _recentItems = items.take(5).toList().cast<Map<String, dynamic>>();
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
    return RoleAppBarWrapper(
      title: 'Beranda Verifikator',
      actions: [
        IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        TextButton(
          onPressed: () => context.push('/verifikator/queue'),
          child: const Text('Lihat Antrean'),
        ),
      ],
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildErrorState()
          : _buildDashboard(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SigapSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: SigapColors.perluTindakan,
            ),
            const SizedBox(height: 16),
            const Text(
              'Gagal memuat data',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? '',
              style: const TextStyle(color: SigapColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard() {
    final total = _counts['total'] ?? 0;
    final menunggu = _counts['menunggu'] ?? 0;
    final diproses = _counts['diproses'] ?? 0;
    final diverifikasi = _counts['diverifikasi'] ?? 0;
    final ditolak = _counts['ditolak'] ?? 0;

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(SigapSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Total queue card
            Container(
              padding: const EdgeInsets.all(SigapSpacing.lg),
              decoration: BoxDecoration(
                color: SigapColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(SigapRadius.md),
                border: Border.all(
                  color: SigapColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.queue, color: SigapColors.primary, size: 40),
                  const SizedBox(width: SigapSpacing.md),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$total',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: SigapColors.primary,
                        ),
                      ),
                      const Text(
                        'Total Antrean',
                        style: TextStyle(
                          fontSize: 12,
                          color: SigapColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: SigapSpacing.md),
            // KPI row
            Row(
              children: [
                _buildKpiCard('Menunggu', menunggu, const Color(0xFFB8730A)),
                const SizedBox(width: SigapSpacing.sm),
                _buildKpiCard('Diproses', diproses, const Color(0xFF2563EB)),
                const SizedBox(width: SigapSpacing.sm),
                _buildKpiCard(
                  'Diverifikasi',
                  diverifikasi,
                  SigapColors.primary,
                ),
                const SizedBox(width: SigapSpacing.sm),
                _buildKpiCard('Ditolak', ditolak, const Color(0xFFC0392B)),
              ],
            ),
            const SizedBox(height: SigapSpacing.xl),
            // Recent items section
            if (_recentItems.isNotEmpty) ...[
              const Text(
                'Antrean Terbaru',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: SigapSpacing.md),
              ..._recentItems.map((item) => _buildRecentItemCard(item)),
            ],
            const SizedBox(height: SigapSpacing.xl),
            _buildQuickActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiCard(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.borderCard),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontSize: AppTypography.size22,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: AppTypography.size10,
                color: AppColors.textTertiary,
                height: AppTypography.lineHeight125,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentItemCard(Map<String, dynamic> item) {
    final title =
        item['title'] as String? ?? item['description'] as String? ?? '-';
    final status = item['status'] as String? ?? 'pending';
    final category =
        item['category'] as String? ?? item['category_name'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: SigapSpacing.sm),
      padding: const EdgeInsets.all(SigapSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.borderCard),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: AppTypography.size14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (category != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    category,
                    style: const TextStyle(
                      fontSize: AppTypography.size12,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: _getStatusColor(status).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Text(
              _getStatusLabel(status),
              style: TextStyle(
                fontSize: AppTypography.size11,
                fontWeight: FontWeight.w600,
                color: _getStatusColor(status),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'submitted':
      case 'under_review':
        return const Color(0xFFB8730A);
      case 'in_progress':
      case 'processing':
        return const Color(0xFF2563EB);
      case 'verified':
      case 'completed':
        return SigapColors.primary;
      case 'rejected':
        return const Color(0xFFC0392B);
      default:
        return AppColors.textTertiary;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'submitted':
      case 'under_review':
        return 'Menunggu';
      case 'in_progress':
      case 'processing':
        return 'Diproses';
      case 'verified':
      case 'completed':
        return 'Diverifikasi';
      case 'rejected':
        return 'Ditolak';
      default:
        return status;
    }
  }

  Widget _buildQuickActions() {
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
                icon: Icons.queue,
                label: 'Antrean',
                color: SigapColors.primary,
                onTap: () => context.push('/verifikator/queue'),
              ),
            ),
            const SizedBox(width: SigapSpacing.md),
            Expanded(
              child: _ActionCard(
                icon: Icons.map,
                label: 'Peta',
                color: SigapColors.primary,
                onTap: () => context.push('/map'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class AdminDaerahHomeScreen extends ConsumerStatefulWidget {
  const AdminDaerahHomeScreen({super.key});

  @override
  ConsumerState<AdminDaerahHomeScreen> createState() =>
      _AdminDaerahHomeScreenState();
}

class _AdminDaerahHomeScreenState extends ConsumerState<AdminDaerahHomeScreen> {
  Map<String, dynamic> _stats = {};
  bool _loading = true;
  String? _error;

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

      // Fetch data from multiple endpoints in parallel
      final results = await Future.wait([
        _safeGet(client, '/api/admin-daerah/wilayah'),
        _safeGet(client, '/api/admin-daerah/units'),
        _safeGet(client, '/api/admin-daerah/kategori'),
        _safeGet(client, '/api/operator/dashboard'),
      ]);

      final wilayahData = results[0];
      final unitsData = results[1];
      final kategoriData = results[2];
      final operatorData = results[3];

      setState(() {
        _stats = {
          'wilayah_count': _countItems(wilayahData),
          'units_count': _countItems(unitsData),
          'kategori_count': _countItems(kategoriData),
          'total_cases': operatorData['total_cases'] as int? ?? 0,
          'pending': operatorData['pending'] as int? ?? 0,
          'in_progress': operatorData['in_progress'] as int? ?? 0,
          'resolved': operatorData['resolved'] as int? ?? 0,
        };
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<Map<String, dynamic>> _safeGet(
    ApiClient client,
    String endpoint,
  ) async {
    try {
      return await client.get(endpoint);
    } catch (_) {
      return {};
    }
  }

  int _countItems(Map<String, dynamic> data) {
    if (data.containsKey('items')) {
      return (data['items'] as List?)?.length ?? 0;
    } else if (data.containsKey('data')) {
      return (data['data'] as List?)?.length ?? 0;
    } else if (data.containsKey('wilayah')) {
      return (data['wilayah'] as List?)?.length ?? 0;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return RoleAppBarWrapper(
      title: 'Beranda Admin Daerah',
      actions: [
        IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
      ],
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildErrorState()
          : _buildDashboard(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SigapSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: SigapColors.perluTindakan,
            ),
            const SizedBox(height: 16),
            const Text(
              'Gagal memuat data',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? '',
              style: const TextStyle(color: SigapColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard() {
    final wilayahCount = _stats['wilayah_count'] ?? 0;
    final unitsCount = _stats['units_count'] ?? 0;
    final kategoriCount = _stats['kategori_count'] ?? 0;
    final totalCases = _stats['total_cases'] ?? 0;
    final pending = _stats['pending'] ?? 0;
    final inProgress = _stats['in_progress'] ?? 0;
    final resolved = _stats['resolved'] ?? 0;

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(SigapSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Regional config stats
            const Text(
              'Konfigurasi Regional',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: SigapSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'Wilayah',
                    value: '$wilayahCount',
                    icon: Icons.map,
                    color: SigapColors.primary,
                    onTap: () => context.push('/admin-daerah/wilayah'),
                  ),
                ),
                const SizedBox(width: SigapSpacing.md),
                Expanded(
                  child: _buildStatCard(
                    title: 'Unit',
                    value: '$unitsCount',
                    icon: Icons.business,
                    color: const Color(0xFF2563EB),
                    onTap: () => context.push('/admin-daerah/units'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: SigapSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'Kategori',
                    value: '$kategoriCount',
                    icon: Icons.category,
                    color: const Color(0xFFB8730A),
                    onTap: () => context.push('/admin-daerah/categories'),
                  ),
                ),
                const SizedBox(width: SigapSpacing.md),
                Expanded(
                  child: _buildStatCard(
                    title: 'SLA',
                    value: 'Konfig',
                    icon: Icons.timer,
                    color: const Color(0xFFC0392B),
                    onTap: () => context.push('/admin-daerah/sla'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: SigapSpacing.xl),
            // Case stats
            const Text(
              'Statistik Kasus',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: SigapSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'Total',
                    value: '$totalCases',
                    icon: Icons.folder_open,
                    color: SigapColors.primary,
                  ),
                ),
                const SizedBox(width: SigapSpacing.md),
                Expanded(
                  child: _buildStatCard(
                    title: 'Menunggu',
                    value: '$pending',
                    icon: Icons.pending_actions,
                    color: const Color(0xFFB8730A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: SigapSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'Diproses',
                    value: '$inProgress',
                    icon: Icons.engineering,
                    color: const Color(0xFF2563EB),
                  ),
                ),
                const SizedBox(width: SigapSpacing.md),
                Expanded(
                  child: _buildStatCard(
                    title: 'Selesai',
                    value: '$resolved',
                    icon: Icons.check_circle,
                    color: SigapColors.selesai,
                  ),
                ),
              ],
            ),
            const SizedBox(height: SigapSpacing.xl),
            _buildQuickActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    final card = Container(
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

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(SigapRadius.md),
          child: card,
        ),
      );
    }

    return card;
  }

  Widget _buildQuickActions() {
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
                icon: Icons.map,
                label: 'Wilayah',
                color: SigapColors.primary,
                onTap: () => context.push('/admin-daerah/wilayah'),
              ),
            ),
            const SizedBox(width: SigapSpacing.md),
            Expanded(
              child: _ActionCard(
                icon: Icons.category,
                label: 'Kategori',
                color: SigapColors.primary,
                onTap: () => context.push('/admin-daerah/categories'),
              ),
            ),
          ],
        ),
        const SizedBox(height: SigapSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _ActionCard(
                icon: Icons.timer,
                label: 'SLA',
                color: SigapColors.primary,
                onTap: () => context.push('/admin-daerah/sla'),
              ),
            ),
            const SizedBox(width: SigapSpacing.md),
            Expanded(
              child: _ActionCard(
                icon: Icons.business,
                label: 'Unit',
                color: SigapColors.primary,
                onTap: () => context.push('/admin-daerah/units'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // Shell route that provides persistent role banner
    ShellRoute(
      builder: (context, state, child) {
        return Column(
          children: [
            const RoleBanner(),
            Expanded(child: child),
          ],
        );
      },
      routes: [
        // Root redirect to role-based dashboard
        GoRoute(path: '/', builder: (c, s) => const RoleBasedRedirectScreen()),

        // Warga routes
        GoRoute(path: '/warga', builder: (c, s) => const WargaHomeScreen()),
        GoRoute(
          path: '/warga/sanggahan/:reportId',
          builder: (c, s) =>
              SanggahanScreen(reportId: s.pathParameters['reportId']!),
        ),
        GoRoute(
          path: '/warga/reopen/:reportId',
          builder: (c, s) =>
              ReopenRequestScreen(reportId: s.pathParameters['reportId']!),
        ),
        GoRoute(
          path: '/warga/evidence/:reportId',
          builder: (c, s) => ComplementaryEvidenceScreen(
            reportId: s.pathParameters['reportId']!,
          ),
        ),
        GoRoute(
          path: '/warga/laporan/:reportId',
          builder: (c, s) =>
              LaporanDetailScreen(reportId: s.pathParameters['reportId']),
        ),
        GoRoute(
          path: '/warga/review',
          builder: (c, s) {
            final extra = s.extra as Map<String, dynamic>?;
            return ReviewKirimanScreen(
              description: extra?['description'] ?? '',
              lat: extra?['lat'] ?? 0.0,
              lng: extra?['lng'] ?? 0.0,
              categoryId: extra?['categoryId'],
              categoryName: extra?['categoryName'],
              photoPath: extra?['photoPath'],
              duplicateMatches: extra?['duplicateMatches'] ?? [],
            );
          },
        ),

        // Surveyor routes
        GoRoute(
          path: '/surveyor',
          builder: (c, s) => const SurveyorHomeScreen(),
        ),
        GoRoute(
          path: '/surveyor/tasks',
          builder: (c, s) => const SurveyorTaskListScreen(),
        ),
        GoRoute(
          path: '/surveyor/daftar-tugas',
          builder: (c, s) => const SurveyorTaskListScreen(),
        ),
        GoRoute(
          path: '/surveyor/tasks/:id',
          builder: (c, s) =>
              SurveyorTaskDetailScreen(taskId: s.pathParameters['id']!),
        ),
        GoRoute(
          path: '/surveyor/form-survei',
          builder: (c, s) => FormSurveiScreen(taskId: s.extra as String?),
        ),

        // Verifikator routes
        GoRoute(
          path: '/verifikator',
          builder: (c, s) => const VerifikatorHomeScreen(),
        ),
        GoRoute(
          path: '/verifikator/queue',
          builder: (c, s) => const VerifikatorQueueScreen(),
        ),
        GoRoute(
          path: '/verifikator/cases/:id',
          builder: (c, s) =>
              VerifikasiCaseDetailScreen(caseId: s.pathParameters['id']!),
        ),

        // Operator routes
        GoRoute(
          path: '/operator',
          builder: (c, s) => const OperatorDashboardScreen(),
        ),
        GoRoute(
          path: '/operator/cases',
          builder: (c, s) => const OperatorCaseListScreen(),
        ),
        GoRoute(
          path: '/operator/cases/:id',
          builder: (c, s) => operator_detail.OperatorCaseDetailScreen(
            caseId: s.pathParameters['id']!,
          ),
        ),

        // Petugas routes
        GoRoute(
          path: '/petugas',
          builder: (c, s) => const PetugasDashboardScreen(),
        ),
        GoRoute(
          path: '/petugas/tasks',
          builder: (c, s) => const PetugasDashboardScreen(),
        ),
        GoRoute(
          path: '/petugas/tasks/:id',
          builder: (c, s) =>
              PetugasTaskDetailScreen(taskId: s.pathParameters['id']!),
        ),

        // Exec route
        GoRoute(path: '/exec', builder: (c, s) => const ExecDashboardScreen()),

        // Admin Daerah routes
        GoRoute(
          path: '/admin-daerah',
          builder: (c, s) => const AdminDaerahHomeScreen(),
        ),
        GoRoute(
          path: '/admin-daerah/wilayah',
          builder: (c, s) => const AdminDaerahWilayahScreen(),
        ),
        GoRoute(
          path: '/admin-daerah/categories',
          builder: (c, s) => const AdminDaerahCategoriesScreen(),
        ),
        GoRoute(
          path: '/admin-daerah/sla',
          builder: (c, s) => const AdminDaerahSlaScreen(),
        ),
        GoRoute(
          path: '/admin-daerah/units',
          builder: (c, s) => const AdminDaerahUnitsScreen(),
        ),
        GoRoute(
          path: '/admin-daerah/priority',
          builder: (c, s) => const AdminDaerahPriorityConfigScreen(),
        ),
        GoRoute(
          path: '/admin-daerah/accounts',
          builder: (c, s) => const AdminDaerahAccountsScreen(),
        ),
        GoRoute(
          path: '/admin-daerah/integrasi',
          builder: (c, s) => const AdminDaerahIntegrasiScreen(),
        ),

        // Auditor route
        GoRoute(
          path: '/auditor',
          builder: (c, s) => const AuditorAuditLogScreen(),
        ),

        // Common routes
        GoRoute(path: '/create', builder: (c, s) => const CreateReportScreen()),
        GoRoute(
          path: '/detail/:id',
          builder: (c, s) => ReportDetailScreen(id: s.pathParameters['id']!),
        ),
        GoRoute(path: '/map', builder: (c, s) => const MapScreen()),
        GoRoute(
          path: '/rt-rw/verify/:token/:reportId',
          builder: (c, s) => RtRwVerifyScreen(
            token: s.pathParameters['token']!,
            reportId: s.pathParameters['reportId']!,
          ),
        ),
        GoRoute(
          path: '/notifications',
          builder: (c, s) => const NotificationsScreen(),
        ),

        // Settings & Profile
        GoRoute(path: '/settings', builder: (c, s) => const SettingsScreen()),
        GoRoute(path: '/profile', builder: (c, s) => const ProfileScreen()),
        GoRoute(
          path: '/switch-role',
          builder: (c, s) => const RoleSwitcherScreen(),
        ),
      ],
    ),
  ],
);

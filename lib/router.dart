import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'theme/tokens.dart';
import 'api/api_client.dart';
import 'api/types.g.dart';
import 'utils/logger.dart';
import 'features/create/create_report_screen.dart';
import 'features/detail/report_detail_screen.dart';
import 'features/map/map_screen.dart';
import 'features/rt_rw/verify_screen.dart';
import 'features/verifikator/case_detail_screen.dart';
import 'features/operator/dashboard_screen.dart';
import 'features/operator/case_list_screen.dart';
import 'features/operator/case_detail_screen.dart' as operator_detail;
import 'features/tasks/tasks_flow_list_screen.dart';
import 'features/tasks/tasks_flow_detail_screen.dart';
import 'features/surveyor/surveyor_tab_screen.dart';
import 'features/surveyor/sync_center_screen.dart';
import 'features/surveyor/riwayat_screen.dart';

import 'features/surveyor/form_survei.dart';
import 'features/exec/dashboard_screen.dart';
import 'features/admin_daerah/wilayah_screen.dart';
import 'features/admin_daerah/categories_screen.dart';
import 'features/admin_daerah/sla_screen.dart';
import 'features/admin_daerah/units_screen.dart';
import 'features/admin_daerah/priority_config_screen.dart';
import 'features/admin_daerah/accounts_screen.dart';
import 'features/auditor/audit_log_screen.dart';
import 'features/warga/sanggahan_screen.dart';
import 'features/warga/reopen_request_screen.dart';
import 'features/warga/complementary_evidence_screen.dart';
import 'features/warga/warga_home_screen.dart';
import 'features/warga/review_kiriman_screen.dart';
import 'features/anon/anon_landing_screen.dart';
import 'features/notifications/notifications_screen.dart';

import 'features/settings/settings_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/role_switcher/role_switcher_screen.dart';
import 'features/verifikator/verifikator_queue_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/providers.dart';
import 'providers/onboarding_provider.dart';
import 'widgets/role_banner.dart';
import 'features/onboarding/onboarding_screen.dart';

// Root redirect screen - checks auth state and onboarding status, redirects accordingly
class RootRedirectScreen extends ConsumerWidget {
  const RootRedirectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final onboardingAsync = ref.watch(onboardingCompleteProvider);

    return onboardingAsync.when(
      data: (onboardingComplete) {
        if (!authState.isAuthenticated) {
          // No token → /anon
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              context.go('/anon');
            }
          });
        } else if (!onboardingComplete) {
          // Token + !onboarding_complete → /onboarding
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              context.go('/onboarding');
            }
          });
        } else {
          // Token + onboarding_complete → RoleBasedRedirectScreen
          return const RoleBasedRedirectScreen();
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, __) => const RoleBasedRedirectScreen(),
    );
  }
}

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
// Note: RT_RW role does NOT have a navigable dashboard. They access the app exclusively
// via deep-link /rt-rw/verify/:token/:reportId, sent by warga who want RT/RW verification of their report.
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
  static final _logger = Logger('_SurveyorHomeScreenState');
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
        _tasks = data.tasks
            .map(
              (t) => {
                'taskId': t.taskId,
                'reportId': t.reportId,
                'reportTitle': t.reportTitle,
                'status': t.status,
                'assignedAt': t.assignedAt,
                'completedAt': t.completedAt,
              },
            )
            .toList();
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
        } catch (e, stack) {
          _logger.warning('Date parse failed', e, stack);
        }
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
  int _total = 0;
  int _menunggu = 0;
  int _diproses = 0;
  int _diverifikasi = 0;
  int _ditolak = 0;
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

      int menunggu = 0;
      int diproses = 0;
      int diverifikasi = 0;
      int ditolak = 0;

      for (final item in data.items) {
        final status = item.status?.value ?? '';
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
        _total = data.items.length;
        _menunggu = menunggu;
        _diproses = diproses;
        _diverifikasi = diverifikasi;
        _ditolak = ditolak;
        _recentItems = data.items.take(5).map((item) => item.toJson()).toList();
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
    final total = _total;
    final menunggu = _menunggu;
    final diproses = _diproses;
    final diverifikasi = _diverifikasi;
    final ditolak = _ditolak;

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
          vertical: SigapSpacing.md,
          horizontal: SigapSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: SigapColors.bgCard,
          borderRadius: BorderRadius.circular(SigapRadius.md),
          border: Border.all(color: SigapColors.borderCard),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontSize: SigapTypography.size22,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: SigapTypography.size10,
                color: SigapColors.textTertiary,
                height: SigapTypography.lineHeight125,
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
        color: SigapColors.bgCard,
        borderRadius: BorderRadius.circular(SigapRadius.md),
        border: Border.all(color: SigapColors.borderCard),
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
                    fontSize: SigapTypography.size14,
                    fontWeight: FontWeight.w600,
                    color: SigapColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (category != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    category,
                    style: const TextStyle(
                      fontSize: SigapTypography.size12,
                      color: SigapColors.textTertiary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: SigapSpacing.sm,
              vertical: SigapSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: _getStatusColor(status).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(SigapRadius.pill),
            ),
            child: Text(
              _getStatusLabel(status),
              style: TextStyle(
                fontSize: SigapTypography.size11,
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
        return SigapColors.textTertiary;
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

      // Fetch data from multiple endpoints in parallel using typed methods
      final results = await Future.wait([
        client.getWilayahList(),
        client.getCategories(),
        client.getUnits(limit: 100),
        client.getStats(),
      ]);

      final wilayahList = results[0] as List<Wilayah>;
      final kategoriList = results[1] as List<Category>;
      final unitsData = results[2] as UnitsPage;
      final dashboardData = results[3] as StatsResponse;

      // Extract status counts from byStatus map
      final byStatus = dashboardData.byStatus ?? <String, dynamic>{};
      final pending =
          ((byStatus['pending'] as int?) ?? 0) +
          ((byStatus['submitted'] as int?) ?? 0) +
          ((byStatus['under_review'] as int?) ?? 0);
      final inProgress =
          ((byStatus['in_progress'] as int?) ?? 0) +
          ((byStatus['assigned'] as int?) ?? 0);
      final resolved =
          ((byStatus['resolved'] as int?) ?? 0) +
          ((byStatus['closed'] as int?) ?? 0);

      setState(() {
        _stats = {
          'wilayah_count': wilayahList.length,
          'units_count': unitsData.entries.length,
          'kategori_count': kategoriList.length,
          'total_cases': dashboardData.total ?? 0,
          'pending': pending,
          'in_progress': inProgress,
          'resolved': resolved,
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
        GoRoute(path: '/', builder: (c, s) => const RootRedirectScreen()),

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
              ReportDetailScreen(id: s.pathParameters['reportId']!),
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
          builder: (c, s) => const SurveyorTabScreen(),
        ),
        GoRoute(
          path: '/surveyor/sinkron',
          builder: (c, s) => const SyncCenterScreen(),
        ),
        GoRoute(
          path: '/sync-center',
          builder: (c, s) => const SyncCenterScreen(isWargaSection: true),
        ),
        GoRoute(
          path: '/surveyor/riwayat',
          builder: (c, s) => const RiwayatScreen(),
        ),
        GoRoute(
          path: '/surveyor/tasks',
          builder: (c, s) => const TasksFlowListScreen(role: 'surveyor'),
        ),
        GoRoute(
          path: '/surveyor/daftar-tugas',
          builder: (c, s) => const TasksFlowListScreen(role: 'surveyor'),
        ),
        GoRoute(
          path: '/surveyor/tasks/:id',
          builder: (c, s) => TasksFlowDetailScreen(
            role: 'surveyor',
            taskId: s.pathParameters['id']!,
          ),
        ),
        GoRoute(
          path: '/surveyor/form-survei',
          builder: (c, s) => FormSurveiScreen(taskId: s.extra as String?),
        ),
        GoRoute(
          path: '/surveyor/form-survei/:taskId',
          builder: (c, s) =>
              FormSurveiScreen(taskId: s.pathParameters['taskId']!),
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
          builder: (c, s) => const TasksFlowListScreen(role: 'petugas'),
        ),
        GoRoute(
          path: '/petugas/tasks',
          builder: (c, s) => const TasksFlowListScreen(role: 'petugas'),
        ),
        GoRoute(
          path: '/petugas/tasks/:id',
          builder: (c, s) => TasksFlowDetailScreen(
            role: 'petugas',
            taskId: s.pathParameters['id']!,
          ),
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
        // Auditor route
        GoRoute(
          path: '/auditor',
          builder: (c, s) => const AuditorAuditLogScreen(),
        ),

        // Common routes
        GoRoute(path: '/create', builder: (c, s) => const CreateReportScreen()),
        GoRoute(
          path: '/create-anonymous',
          builder: (c, s) => const CreateReportScreen(anonymousMode: true),
        ),
        GoRoute(path: '/anon', builder: (c, s) => const AnonLandingScreen()),
        GoRoute(
          path: '/onboarding',
          builder: (c, s) => const OnboardingScreen(),
        ),
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

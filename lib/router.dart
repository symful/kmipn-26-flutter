import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'theme/tokens.dart';
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
import 'features/settings/settings_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/role_switcher/role_switcher_screen.dart';
import 'screens/verifikator/queue_screen.dart';
import 'screens/petugas/dashboard.dart';
import 'providers/auth_provider.dart';
import 'widgets/role_banner.dart';

// Role-based redirect screen - reads activeRole and navigates to appropriate dashboard
class RoleBasedRedirectScreen extends ConsumerWidget {
  const RoleBasedRedirectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final activeRole = authState.activeRole ?? authState.userRole;

    // Redirect based on active role
    final redirectPath = _getRedirectPath(activeRole);

    // Use delayed navigation to avoid build-time issues
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        context.go(redirectPath);
      }
    });

    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }

  String _getRedirectPath(String? role) {
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

// Simple home screens for roles that don't have dedicated dashboards yet
class SurveyorHomeScreen extends ConsumerWidget {
  const SurveyorHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RoleAppBarWrapper(
      title: 'Beranda Surveyor',
      actions: [
        TextButton(
          onPressed: () => context.push('/surveyor/tasks'),
          child: const Text('Lihat Tugas'),
        ),
      ],
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.map, size: 64, color: SigapColors.primary),
            const SizedBox(height: 16),
            const Text(
              'Beranda Surveyor',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Akses tugas survei dari menu di atas'),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.list),
              label: const Text('Daftar Tugas Survei'),
              onPressed: () => context.push('/surveyor/tasks'),
            ),
          ],
        ),
      ),
    );
  }
}

class VerifikatorHomeScreen extends ConsumerWidget {
  const VerifikatorHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RoleAppBarWrapper(
      title: 'Beranda Verifikator',
      actions: [
        TextButton(
          onPressed: () => context.push('/verifikator/queue'),
          child: const Text('Lihat Antrean'),
        ),
      ],
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.verified, size: 64, color: SigapColors.primary),
            const SizedBox(height: 16),
            const Text(
              'Beranda Verifikator',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Akses antrean verifikasi dari menu di atas'),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.queue),
              label: const Text('Antrean Verifikasi'),
              onPressed: () => context.push('/verifikator/queue'),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminDaerahHomeScreen extends ConsumerWidget {
  const AdminDaerahHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RoleAppBarWrapper(
      title: 'Beranda Admin Daerah',
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.location_city,
              size: 64,
              color: SigapColors.primary,
            ),
            const SizedBox(height: 16),
            const Text(
              'Beranda Admin Daerah',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.map),
                  label: const Text('Wilayah'),
                  onPressed: () => context.push('/admin-daerah/wilayah'),
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.category),
                  label: const Text('Kategori'),
                  onPressed: () => context.push('/admin-daerah/categories'),
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.timer),
                  label: const Text('SLA'),
                  onPressed: () => context.push('/admin-daerah/sla'),
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.business),
                  label: const Text('Unit'),
                  onPressed: () => context.push('/admin-daerah/units'),
                ),
              ],
            ),
          ],
        ),
      ),
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
          path: '/surveyor/tasks/:id',
          builder: (c, s) =>
              SurveyorTaskDetailScreen(taskId: s.pathParameters['id']!),
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'features/create/create_report_screen.dart';
import 'features/detail/report_detail_screen.dart';
import 'features/map/map_screen.dart';
import 'features/verify_screen.dart';
import 'features/case_review_screen.dart';
import 'features/case_action_screen.dart';
import 'features/tasks/tasks_flow_list_screen.dart';
import 'features/tasks/tasks_flow_detail_screen.dart';
import 'features/sync_center_screen.dart';
import 'features/riwayat_screen.dart';
import 'features/form_survei.dart';
import 'features/wilayah_screen.dart';
import 'features/categories_screen.dart';
import 'features/sla_screen.dart';
import 'features/units_screen.dart';
import 'features/priority_config_screen.dart';
import 'features/accounts_screen.dart';
import 'features/sanggahan_screen.dart';
import 'features/reopen_request_screen.dart';
import 'features/complementary_evidence_screen.dart';
import 'features/review_kiriman_screen.dart';
import 'features/anon/anon_landing_screen.dart';
import 'features/notifications/notifications_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/role_switcher/role_switcher_screen.dart';
import 'features/home_screen.dart';
import 'features/cases/case_queue_page.dart';
import 'providers/auth_provider.dart';
import 'providers/providers.dart';
import 'providers/onboarding_provider.dart';
import 'widgets/design_system/design_system.dart';
import 'features/onboarding/onboarding_screen.dart';

// Helper wrapper widgets for Tasks screens that derive role from auth state
class _TasksPage extends ConsumerWidget {
  const _TasksPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.read(authNotifierProvider).activeRole ?? 'surveyor';
    return TasksFlowListScreen(role: role);
  }
}

class _TaskDetailPage extends ConsumerWidget {
  final String taskId;

  const _TaskDetailPage({required this.taskId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.read(authNotifierProvider).activeRole ?? 'surveyor';
    return TasksFlowDetailScreen(role: role, taskId: taskId);
  }
}

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
class RoleRedirectHelper {
  static String getRedirectPath(String? role) {
    switch (role?.toUpperCase()) {
      case 'ADMIN':
        return '/dashboard';
      case 'ADMIN_DAERAH':
        return '/dashboard';
      case 'SURVEYOR':
        return '/tasks';
      case 'PETUGAS':
        return '/tasks';
      case 'VERIFIKATOR':
        return '/queue';
      case 'RT_RW':
        return '/dashboard';
      case 'WARGA':
        return '/dashboard';
      case 'OPERATOR':
        return '/queue';
      case 'AUDITOR':
        return '/dashboard';
      case 'PENGAMBIL_KEPUTUSAN':
        return '/dashboard';
      default:
        return '/dashboard';
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
                  ? MinTapTarget(
                      semanticsLabel: 'Kembali',
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => context.pop(),
                      ),
                    )
                  : null,
              actions: [
                ...?actions,
                if (hasMultipleRoles)
                  MinTapTarget(
                    semanticsLabel: 'Ganti Peran',
                    child: IconButton(
                      icon: const Icon(Icons.swap_horiz),
                      tooltip: 'Ganti Peran',
                      onPressed: () => context.push('/switch-role'),
                    ),
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

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (c, s) => const RootRedirectScreen()),

    // UNIFIED
    GoRoute(path: '/dashboard', builder: (c, s) => const HomeScreen()),
    GoRoute(path: '/queue', builder: (c, s) => const CaseQueuePage()),

    // TASKS (read role from auth state via wrapper)
    GoRoute(path: '/tasks', builder: (c, s) => const _TasksPage()),
    GoRoute(
      path: '/tasks/:id',
      builder: (c, s) => _TaskDetailPage(taskId: s.pathParameters['id']!),
    ),

    // WARGA/SURVEYOR
    GoRoute(
      path: '/review',
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
    GoRoute(
      path: '/sanggahan/:reportId',
      builder: (c, s) =>
          SanggahanScreen(reportId: s.pathParameters['reportId']!),
    ),
    GoRoute(
      path: '/reopen/:reportId',
      builder: (c, s) =>
          ReopenRequestScreen(reportId: s.pathParameters['reportId']!),
    ),
    GoRoute(
      path: '/evidence/:reportId',
      builder: (c, s) =>
          ComplementaryEvidenceScreen(reportId: s.pathParameters['reportId']!),
    ),
    GoRoute(
      path: '/laporan/:reportId',
      builder: (c, s) => ReportDetailScreen(id: s.pathParameters['reportId']!),
    ),

    // FORM SURVEI
    GoRoute(
      path: '/form-survei',
      builder: (c, s) => FormSurveiScreen(taskId: s.extra as String?),
    ),
    GoRoute(
      path: '/form-survei/:taskId',
      builder: (c, s) => FormSurveiScreen(taskId: s.pathParameters['taskId']!),
    ),

    // SYNC
    GoRoute(path: '/sync-center', builder: (c, s) => const SyncCenterScreen()),
    GoRoute(path: '/sinkron', builder: (c, s) => const SyncCenterScreen()),

    // RIWAYAT
    GoRoute(path: '/riwayat', builder: (c, s) => const RiwayatScreen()),

    // ADMIN DAERAH
    GoRoute(path: '/wilayah', builder: (c, s) => const WilayahScreen()),
    GoRoute(path: '/categories', builder: (c, s) => const CategoriesScreen()),
    GoRoute(path: '/sla', builder: (c, s) => const SlaScreen()),
    GoRoute(path: '/units', builder: (c, s) => const UnitsScreen()),
    GoRoute(path: '/priority', builder: (c, s) => const PriorityConfigScreen()),
    GoRoute(path: '/accounts', builder: (c, s) => const AccountsScreen()),

    // CASE DETAIL
    GoRoute(
      path: '/case-review/:id',
      builder: (c, s) => CaseReviewScreen(caseId: s.pathParameters['id']!),
    ),
    GoRoute(
      path: '/case-action/:id',
      builder: (c, s) => CaseActionScreen(caseId: s.pathParameters['id']!),
    ),

    // COMMON
    GoRoute(path: '/create', builder: (c, s) => const CreateReportScreen()),
    GoRoute(
      path: '/create-anonymous',
      builder: (c, s) => const CreateReportScreen(anonymousMode: true),
    ),
    GoRoute(path: '/anon', builder: (c, s) => const AnonLandingScreen()),
    GoRoute(path: '/onboarding', builder: (c, s) => const OnboardingScreen()),
    GoRoute(
      path: '/detail/:id',
      builder: (c, s) => ReportDetailScreen(id: s.pathParameters['id']!),
    ),
    GoRoute(path: '/map', builder: (c, s) => const MapScreen()),
    GoRoute(
      path: '/rt-rw/verify/:token/:reportId',
      builder: (c, s) => VerifyScreen(
        token: s.pathParameters['token']!,
        reportId: s.pathParameters['reportId']!,
      ),
    ),
    GoRoute(
      path: '/notifications',
      builder: (c, s) => const NotificationsScreen(),
    ),
    GoRoute(path: '/settings', builder: (c, s) => const SettingsScreen()),
    GoRoute(path: '/profile', builder: (c, s) => const ProfileScreen()),
    GoRoute(
      path: '/switch-role',
      builder: (c, s) => const RoleSwitcherScreen(),
    ),
  ],
);

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'l10n/generated/app_localizations.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/stats/stats_screen.dart';
import 'features/create/create_report_screen.dart';
import 'features/detail/report_detail_screen.dart';
import 'features/map/map_screen.dart';
import 'features/map/map_picker_screen.dart';

import 'features/case/case_workspace_screen.dart';
import 'features/case/case_review_screen.dart';
import 'features/tasks/task_workspace.dart';
import 'features/sync_center_screen.dart';
import 'features/riwayat_screen.dart';
import 'features/form_survei.dart';
import 'features/wilayah_screen.dart';
import 'features/categories_screen.dart';
import 'features/sla_screen.dart';
import 'features/units_screen.dart';
import 'features/priority_config_screen.dart';
import 'features/accounts_screen.dart';
import 'features/admin/admin_daerah_screen.dart';
import 'features/review_kiriman_screen.dart';
import 'features/public/public_portal_screen.dart';
import 'features/public/public_statistics_screen.dart';
import 'features/notifications/notifications_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/audit_log_screen.dart';
import 'features/export_screen.dart';
import 'features/ai_console_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/role_switcher/role_switcher_screen.dart';
import 'features/home_screen.dart';
import 'features/laporan_screen.dart';
import 'features/cases/case_queue_page.dart';
import 'features/sanggahan/sanggahan_screen.dart';
import 'features/evidence/evidence_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/capability_provider.dart';
import 'providers/providers.dart';
import 'providers/onboarding_provider.dart';
import 'widgets/design_system/design_system.dart';
import 'features/onboarding/onboarding_screen.dart';

// Helper wrapper widgets for Tasks screens - capabilities drive UI behavior
class _TasksPage extends ConsumerWidget {
  const _TasksPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const TaskWorkspace();
  }
}

class _TaskDetailPage extends ConsumerWidget {
  final String taskId;

  const _TaskDetailPage({required this.taskId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TaskWorkspace(taskId: taskId);
  }
}

/// Redirect logic for GoRouter — runs on every navigation event.
/// Forces re-evaluation when auth state changes (login/logout/role switch).
String? _authRedirect(BuildContext context, GoRouterState state) {
  final container = ProviderScope.containerOf(context, listen: false);
  final authState = container.read(authNotifierProvider);
  final onboardingAsync = container.read(onboardingCompleteProvider);

  final location = state.uri.toString();
  final isAuthRoute =
      location == '/login' || location == '/register' || location == '/portal';
  final isOnboarding = location == '/onboarding';
  final isPublicRoute =
      isAuthRoute ||
      location == '/public-statistics' ||
      location == '/create-anonymous' ||
      location == '/map-picker';

  // Not authenticated → only allow public routes
  if (!authState.isAuthenticated) {
    if (isPublicRoute || isOnboarding) return null;
    return '/portal';
  }

  // Authenticated but needs onboarding
  final onboardingComplete = onboardingAsync.valueOrNull ?? false;
  if (!onboardingComplete) {
    if (isOnboarding) return null;
    return '/onboarding';
  }

  // Authenticated + onboarding done → block auth/onboarding routes
  if (isAuthRoute || isOnboarding) return '/dashboard';

  return null; // no redirect
}

/// Listenable that notifies GoRouter to re-evaluate its redirect
/// whenever auth state changes.
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(Ref ref) {
    // Listen to auth state changes and notify GoRouter
    ref.listen(authNotifierProvider, (_, __) => notifyListeners());
    // Listen to capability state changes (role switch)
    ref.listen(capabilityNotifierProvider, (_, __) => notifyListeners());
    // Listen to onboarding state changes
    ref.listen(onboardingCompleteProvider, (_, __) => notifyListeners());
  }
}

// Wrapper widget that adds role switcher to app bar for multi-role users
class RoleAppBarWrapper extends ConsumerWidget {
  final Widget child;
  final String title;
  final List<Widget>? actions;

  const RoleAppBarWrapper({
    super.key,
    required this.child,
    required this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final hasMultipleRoles = authState.roles.length > 1;
    final canPop = GoRouter.of(context).canPop();

    return Column(
      children: [
        const RoleBanner(),
        Expanded(
          child: Scaffold(
            appBar: AppBar(
              title: Text(title),
              automaticallyImplyLeading: canPop,
              leading: canPop
                  ? MinTapTarget(
                      semanticsLabel:
                          AppLocalizations.of(context)?.kembali ?? 'Kembali',
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
                    semanticsLabel:
                        AppLocalizations.of(context)?.beralihPeran ??
                        'Ganti Peran',
                    child: IconButton(
                      icon: const Icon(Icons.swap_horiz),
                      tooltip:
                          AppLocalizations.of(context)?.beralihPeran ??
                          'Ganti Peran',
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

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _AuthRefreshNotifier(ref);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refreshNotifier,
    redirect: _authRedirect,
    routes: [
      // AUTH (new unified API screens)
      GoRoute(path: '/login', builder: (c, s) => const LoginScreen()),
      GoRoute(path: '/register', builder: (c, s) => const RegisterScreen()),

      // UNIFIED
      GoRoute(path: '/dashboard', builder: (c, s) => const HomeScreen()),
      GoRoute(
        path: '/gov-dashboard',
        builder: (c, s) => const DashboardScreen(),
      ),
      GoRoute(path: '/queue', builder: (c, s) => const CaseQueuePage()),
      GoRoute(path: '/stats', builder: (c, s) => const StatsScreen()),

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
      GoRoute(path: '/laporan', builder: (c, s) => const LaporanScreen()),
      GoRoute(
        path: '/laporan/:reportId',
        builder: (c, s) =>
            ReportDetailScreen(id: s.pathParameters['reportId']!),
      ),

      // SANGGAHAN (WARGA OBJECTION)
      GoRoute(
        path: '/sanggahan/:reportId',
        builder: (c, s) =>
            SanggahanScreen(reportId: s.pathParameters['reportId']!),
      ),

      // EVIDENCE (ADD PHOTOS TO EXISTING CASE)
      GoRoute(
        path: '/evidence/:caseId',
        builder: (c, s) => EvidenceScreen(caseId: s.pathParameters['caseId']!),
      ),

      // FORM SURVEI
      GoRoute(
        path: '/form-survei',
        builder: (c, s) => FormSurveiScreen(taskId: s.extra as String?),
      ),
      GoRoute(
        path: '/form-survei/:taskId',
        builder: (c, s) => FormSurveiScreen(
          taskId: s.pathParameters['taskId']!,
          extra: s.extra as Map<String, dynamic>?,
        ),
      ),

      // SYNC
      GoRoute(
        path: '/sync-center',
        builder: (c, s) => const SyncCenterScreen(),
      ),

      // RIWAYAT
      GoRoute(path: '/riwayat', builder: (c, s) => const RiwayatScreen()),

      // ADMIN DAERAH
      GoRoute(path: '/wilayah', builder: (c, s) => const WilayahScreen()),
      GoRoute(path: '/categories', builder: (c, s) => const CategoriesScreen()),
      GoRoute(path: '/sla', builder: (c, s) => const SlaScreen()),
      GoRoute(path: '/units', builder: (c, s) => const UnitsScreen()),
      GoRoute(
        path: '/priority',
        builder: (c, s) => const PriorityConfigScreen(),
      ),
      GoRoute(path: '/accounts', builder: (c, s) => const AccountsScreen()),
      GoRoute(
        path: '/admin-daerah',
        builder: (c, s) => const AdminDaerahScreen(),
      ),

      // CASE DETAIL
      GoRoute(
        path: '/case-workspace/:id',
        builder: (c, s) => CaseWorkspaceScreen(caseId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/case/:id',
        builder: (c, s) => CaseWorkspaceScreen(caseId: s.pathParameters['id']!),
      ),

      // CASE REVIEW (VERIFIKATOR)
      GoRoute(
        path: '/case-review/:id',
        builder: (c, s) => CaseReviewScreen(caseId: s.pathParameters['id']!),
      ),
      // COMMON
      GoRoute(path: '/create', builder: (c, s) => const CreateReportScreen()),
      GoRoute(
        path: '/create-anonymous',
        builder: (c, s) => const CreateReportScreen(anonymousMode: true),
      ),
      GoRoute(path: '/portal', builder: (c, s) => const PublicPortalScreen()),
      GoRoute(
        path: '/public-statistics',
        builder: (c, s) => const PublicStatisticsScreen(),
      ),
      GoRoute(path: '/onboarding', builder: (c, s) => const OnboardingScreen()),
      GoRoute(
        path: '/detail/:id',
        redirect: (c, s) => '/laporan/${s.pathParameters['id']}',
      ),
      GoRoute(path: '/map', builder: (c, s) => const MapScreen()),
      GoRoute(path: '/map-picker', builder: (c, s) => const MapPickerScreen()),
      GoRoute(
        path: '/notifications',
        builder: (c, s) => const NotificationsScreen(),
      ),
      GoRoute(path: '/settings', builder: (c, s) => const SettingsScreen()),
      GoRoute(path: '/profile', builder: (c, s) => const ProfileScreen()),
      GoRoute(path: '/audit', builder: (c, s) => const AuditLogScreen()),
      GoRoute(path: '/export', builder: (c, s) => const ExportScreen()),
      GoRoute(path: '/ai-console', builder: (c, s) => const AiConsoleScreen()),
      GoRoute(
        path: '/switch-role',
        builder: (c, s) => const RoleSwitcherScreen(),
      ),
      GoRoute(path: '/', builder: (c, s) => const PublicPortalScreen()),
    ],
  );
});

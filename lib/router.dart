import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/analytics/statistics_screen.dart';
import 'features/reports/create_report_screen.dart';
import 'features/reports/report_detail_screen.dart';
import 'features/map/map_screen.dart';
import 'features/map/map_picker_screen.dart';

import 'features/tasks/task_workspace_screen.dart';
import 'features/sync/sync_center_screen.dart';
import 'features/reports/report_history_screen.dart';
import 'features/tasks/survey_form_screen.dart';
import 'features/reports/report_submission_review_screen.dart';

import 'features/notifications/notifications_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/home/home_screen.dart';
import 'features/reports/report_list_screen.dart';
import 'features/reports/report_appeal_screen.dart';
import 'features/reports/report_evidence_screen.dart';
import 'providers/auth_provider.dart';
import 'core/route_access.dart';
import 'providers/onboarding_provider.dart';
import 'features/onboarding/onboarding_screen.dart';

/// Redirect logic for GoRouter — runs on every navigation event.
String? _authRedirect(BuildContext context, GoRouterState state) {
  final container = ProviderScope.containerOf(context, listen: false);
  final authState = container.read(authNotifierProvider);
  final onboardingAsync = container.read(onboardingCompleteProvider);

  return redirectForSession(
    uri: state.uri,
    authenticated: authState.isAuthenticated,
    onboardingComplete: onboardingAsync.valueOrNull ?? false,
    role: authState.userRole,
  );
}

/// Listenable that notifies GoRouter to re-evaluate its redirect
/// whenever auth state changes.
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(Ref ref) {
    ref.listen(authNotifierProvider, (_, __) => notifyListeners());
    ref.listen(onboardingCompleteProvider, (_, __) => notifyListeners());
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _AuthRefreshNotifier(ref);

  final router = GoRouter(
    initialLocation: '/',
    refreshListenable: refreshNotifier,
    redirect: _authRedirect,
    routes: [
      // AUTH
      GoRoute(path: '/login', builder: (c, s) => const LoginScreen()),
      GoRoute(path: '/register', builder: (c, s) => const RegisterScreen()),

      // UNIFIED
      GoRoute(path: '/dashboard', builder: (c, s) => const HomeScreen()),
      GoRoute(path: '/warga', builder: (c, s) => const HomeScreen()),
      GoRoute(path: '/surveyor', builder: (c, s) => const HomeScreen()),
      GoRoute(path: '/stats', builder: (c, s) => const StatisticsScreen()),

      // TASKS
      GoRoute(path: '/tasks', builder: (c, s) => const TaskWorkspaceScreen()),
      GoRoute(
        path: '/tasks/:id',
        builder: (c, s) => TaskWorkspaceScreen(taskId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/surveyor/tugas',
        builder: (c, s) => const TaskWorkspaceScreen(),
      ),
      GoRoute(
        path: '/surveyor/tugas/:id',
        builder: (c, s) => TaskWorkspaceScreen(taskId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/surveyor/riwayat',
        builder: (c, s) => const ReportHistoryScreen(),
      ),

      // WARGA
      GoRoute(
        path: '/review',
        builder: (c, s) {
          final extra = s.extra as Map<String, dynamic>?;
          if (extra == null || extra['lat'] is! num || extra['lng'] is! num) {
            return const CreateReportScreen();
          }
          return ReportSubmissionReviewScreen(
            description: extra['description'] ?? '',
            lat: (extra['lat'] as num).toDouble(),
            lng: (extra['lng'] as num).toDouble(),
            categoryId: extra['categoryId'],
            categoryName: extra['categoryName'],
            photoPath: extra['photoPath'],
            duplicateMatches: extra['duplicateMatches'] ?? [],
            condition: extra['condition'] as String?,
            accuracyMeters: (extra['accuracyMeters'] as num?)?.toDouble(),
            capturedAt: DateTime.tryParse(extra['capturedAt'] as String? ?? ''),
            impact: extra['impact'] as String?,
          );
        },
      ),
      GoRoute(path: '/laporan', builder: (c, s) => const ReportListScreen()),
      GoRoute(
        path: '/laporan/:reportId',
        builder: (c, s) =>
            ReportDetailScreen(id: s.pathParameters['reportId']!),
      ),
      GoRoute(
        path: '/reports/:reportId',
        builder: (c, s) =>
            ReportDetailScreen(id: s.pathParameters['reportId']!),
      ),
      GoRoute(
        path: '/warga/buat',
        builder: (c, s) => const CreateReportScreen(),
      ),
      GoRoute(
        path: '/warga/laporan',
        builder: (c, s) => const ReportListScreen(),
      ),
      GoRoute(
        path: '/warga/laporan/:reportId',
        builder: (c, s) =>
            ReportDetailScreen(id: s.pathParameters['reportId']!),
      ),
      GoRoute(path: '/warga/kasus', redirect: (c, s) => '/warga/laporan'),
      GoRoute(
        path: '/warga/kasus/:reportId',
        builder: (c, s) =>
            ReportDetailScreen(id: s.pathParameters['reportId']!),
      ),

      // SANGGAHAN
      GoRoute(
        path: '/sanggahan/:reportId',
        builder: (c, s) =>
            ReportAppealScreen(reportId: s.pathParameters['reportId']!),
      ),

      // EVIDENCE
      GoRoute(
        path: '/evidence/:caseId',
        builder: (c, s) =>
            ReportEvidenceScreen(caseId: s.pathParameters['caseId']!),
      ),

      // FORM SURVEI
      GoRoute(
        path: '/form-survei',
        builder: (c, s) => SurveyFormScreen(taskId: s.extra as String?),
      ),
      GoRoute(
        path: '/form-survei/:taskId',
        builder: (c, s) => SurveyFormScreen(
          taskId: s.pathParameters['taskId']!,
          extra: s.extra is SurveyFormArguments
              ? s.extra as SurveyFormArguments
              : null,
        ),
      ),

      // SYNC
      GoRoute(
        path: '/sync',
        builder: (c, s) => const SyncCenterScreen(standalone: true),
      ),
      GoRoute(
        path: '/sync-center',
        builder: (c, s) => const SyncCenterScreen(standalone: true),
      ),
      GoRoute(
        path: '/warga/sinkron',
        builder: (c, s) => const SyncCenterScreen(standalone: true),
      ),
      GoRoute(
        path: '/surveyor/sinkron',
        builder: (c, s) => const SyncCenterScreen(standalone: true),
      ),

      // RIWAYAT
      GoRoute(path: '/riwayat', builder: (c, s) => const ReportHistoryScreen()),

      // COMMON
      GoRoute(path: '/create', builder: (c, s) => const CreateReportScreen()),
      GoRoute(
        path: '/surveyor/form',
        builder: (c, s) => const SurveyFormScreen(),
      ),
      GoRoute(
        path: '/surveyor/form/:taskId',
        builder: (c, s) => SurveyFormScreen(
          taskId: s.pathParameters['taskId']!,
          extra: s.extra is SurveyFormArguments
              ? s.extra as SurveyFormArguments
              : null,
        ),
      ),
      GoRoute(
        path: '/create-anonymous',
        builder: (c, s) => const CreateReportScreen(anonymousMode: true),
      ),

      GoRoute(path: '/onboarding', builder: (c, s) => const OnboardingScreen()),
      GoRoute(
        path: '/detail/:id',
        redirect: (c, s) => '/laporan/${s.pathParameters['id']}',
      ),
      GoRoute(path: '/map', builder: (c, s) => const MapScreen()),
      GoRoute(path: '/warga/peta', builder: (c, s) => const MapScreen()),
      GoRoute(path: '/surveyor/peta', builder: (c, s) => const MapScreen()),
      GoRoute(path: '/map-picker', builder: (c, s) => const MapPickerScreen()),
      GoRoute(
        path: '/notifications',
        builder: (c, s) => const NotificationsScreen(),
      ),
      GoRoute(path: '/settings', builder: (c, s) => const SettingsScreen()),
      GoRoute(path: '/profile', builder: (c, s) => const ProfileScreen()),
      GoRoute(path: '/warga/akun', builder: (c, s) => const ProfileScreen()),
      GoRoute(path: '/surveyor/akun', builder: (c, s) => const ProfileScreen()),
      GoRoute(path: '/', builder: (c, s) => const LoginScreen()),
    ],
  );
  ref.onDispose(router.dispose);
  ref.onDispose(refreshNotifier.dispose);
  return router;
});

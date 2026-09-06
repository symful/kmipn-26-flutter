import 'roles.dart';

String? redirectForSession({
  required Uri uri,
  required bool authenticated,
  required bool onboardingComplete,
  required String? role,
}) {
  final path = uri.path;
  final isAuth = path == '/login' || path == '/register';
  final isOnboarding = path == '/onboarding';
  if (!authenticated) {
    return isAuth || isOnboarding ? null : '/login';
  }
  if (!mobileRoles.contains(role)) return path == '/login' ? null : '/login';
  if (!onboardingComplete) return isOnboarding ? null : '/onboarding';
  final home = roleHome[role] ?? '/dashboard';
  if (isAuth || isOnboarding || path == '/') return home;
  final segment = '/${uri.pathSegments.first}';
  final allowed = routeRoles[segment];
  return allowed == null || !allowed.contains(role) ? home : null;
}

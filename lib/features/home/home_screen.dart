import 'package:sigap/theme/sigap_color_scheme.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sigap/providers/providers.dart';
import 'package:sigap/widgets/adaptive_nav.dart';
import 'package:sigap/features/reports/report_list_screen.dart';
import 'package:sigap/features/map/map_screen.dart';
import 'package:sigap/features/sync/sync_center_screen.dart';
import 'package:sigap/features/profile/profile_screen.dart';
import 'package:sigap/features/tasks/task_workspace_screen.dart';
import 'package:sigap/features/reports/report_history_screen.dart';
import 'package:sigap/features/home/citizen_home_view.dart';

// ─── Shared models ───────────────────────────────────────────────────────────

// ─── UNIFIED HOME SCREEN ──────────────────────────────────────────────────────

/// Unified home screen — renders role-specific content based on userRole.
/// Flat route: /dashboard → HomeScreen
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Position? _currentPosition;
  int _selectedNavIndex = 0;
  String? _lastRouteContext;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final loc = GoRouterState.of(context).uri.toString();
      final authState = ref.read(authNotifierProvider);
      final userRole = authState.userRole;
      final routeContext = '$userRole:$loc';
      if (_lastRouteContext == routeContext) return;
      _lastRouteContext = routeContext;

      int newIndex = 0;
      if (userRole == 'WARGA') {
        // Fixed WARGA nav: match route to tab index directly.
        const routes = FixedWargaBottomNav.fixedRoutes;
        for (int i = 0; i < routes.length; i++) {
          // Skip index 2 (FAB /create) — it's not a nav tab.
          if (loc.startsWith(routes[i])) {
            newIndex = i;
            break;
          }
        }
      } else {
        // PETUGAS: derive nav index from role-based routes.
        final routes = navRoutesForRole(userRole);
        for (int i = 0; i < routes.length; i++) {
          if (loc.startsWith(routes[i])) {
            newIndex = i;
            break;
          }
        }
      }
      if (_selectedNavIndex != newIndex) {
        setState(() => _selectedNavIndex = newIndex);
      }
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(accuracy: LocationAccuracy.medium),
      );
      if (mounted) setState(() => _currentPosition = position);
    } catch (e) {
      // Location unavailable
    }
  }

  Widget _buildBodyForActiveTab(String? userRole, bool isOffline) {
    if (userRole == 'WARGA') {
      switch (_selectedNavIndex) {
        case 0:
          return CitizenHomeView(position: _currentPosition);
        case 1:
          return ReportListScreen();
        case 2:
          return MapScreen();
        case 3:
          return SyncCenterScreen(isWargaSection: true);
        case 4:
          return ProfileScreen();
        default:
          return CitizenHomeView(position: _currentPosition);
      }
    } else {
      switch (_selectedNavIndex) {
        case 0:
          return TaskWorkspaceScreen(embedded: true);
        case 1:
          return MapScreen();
        case 2:
          return SyncCenterScreen(isWargaSection: false);
        case 3:
          return ReportHistoryScreen();
        case 4:
          return ProfileScreen();
        default:
          return TaskWorkspaceScreen(embedded: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final connectivityAsync = ref.watch(connectivityProvider);
    final authState = ref.watch(authNotifierProvider);
    final userRole = authState.userRole;

    final isOffline =
        connectivityAsync.whenOrNull(
          data: (results) =>
              results.isEmpty ||
              results.every((r) => r == ConnectivityResult.none),
        ) ??
        true;

    return Scaffold(
      backgroundColor: SigapColorScheme.of(context).bgSurface,
      body: _buildBodyForActiveTab(userRole, isOffline),
      bottomNavigationBar: userRole == 'WARGA'
          ? FixedWargaBottomNav(
              activeIndex: _selectedNavIndex,
              onTabTap: (index) {
                setState(() => _selectedNavIndex = index);
              },
              onFabTap: () => context.push('/create'),
            )
          : AdaptiveNav(
              activeIndex: _selectedNavIndex,
              onTap: (index, route) {
                setState(() => _selectedNavIndex = index);
              },
            ),
    );
  }
}

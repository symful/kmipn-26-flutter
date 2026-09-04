import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:sigap/api/client.dart';
import '../db/database.dart';
import '../l10n/generated/app_localizations.dart';
import '../l10n/status_label.dart';
import '../providers/providers.dart';
import '../theme/tokens.dart';
import '../providers/capability_provider.dart';
import '../widgets/adaptive_nav.dart';
import '../widgets/design_system/skeleton_loaders.dart';
import '../widgets/design_system/status_grid.dart';
import '../widgets/design_system/kasus_terdekat_cards.dart';
import '../widgets/design_system/connectivity_indicator.dart';
import '../widgets/design_system/task_filter_chips.dart';
import '../widgets/design_system/task_sort_row.dart';
import '../widgets/design_system/task_card.dart';
import '../widgets/design_system/offline_pill.dart';
import '../widgets/design_system/notification_bell.dart';
import '../widgets/design_system/pending_sync_banner.dart';
import '../widgets/can.dart';

// ─── Shared models ───────────────────────────────────────────────────────────

/// Unified report model for warga role.
class ReportItem {
  final String key;
  final String description;
  final double lat;
  final double lng;
  final int syncStatus;
  final String? serverId;
  final String? idempotencyKey;
  final DateTime createdAt;
  final String? status;
  final bool isLocal;

  const ReportItem({
    required this.key,
    required this.description,
    required this.lat,
    required this.lng,
    required this.syncStatus,
    this.serverId,
    this.idempotencyKey,
    required this.createdAt,
    this.status,
    required this.isLocal,
  });

  factory ReportItem.fromLocal(LocalReport r) {
    return ReportItem(
      key: r.idempotencyKey,
      description: r.description,
      lat: r.lat,
      lng: r.lng,
      syncStatus: r.syncStatus,
      serverId: r.serverId,
      idempotencyKey: r.idempotencyKey,
      createdAt: r.createdAt,
      status: r.status,
      isLocal: true,
    );
  }

  static ReportItem? fromServer(Map<String, dynamic> r) {
    final lat = r['lat'] ?? r['location']?['lat'];
    final lng = r['lng'] ?? r['location']?['lng'];
    if (lat == null || lng == null) return null;
    return ReportItem(
      key: r['id']?.toString() ?? r['idempotency_key']?.toString() ?? '',
      description:
          r['description']?.toString() ??
          r['title']?.toString() ??
          'Tanpa judul',
      lat: lat.toDouble(),
      lng: lng.toDouble(),
      syncStatus: 1,
      serverId: r['id']?.toString(),
      idempotencyKey: r['idempotency_key']?.toString(),
      createdAt: _parseDate(r['created_at'] ?? r['createdAt']),
      status: r['status']?.toString(),
      isLocal: false,
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString()) ?? DateTime.now();
  }

  String get navKey => serverId ?? idempotencyKey ?? key;
}

/// Merges local Drift reports with server reports.
List<ReportItem> mergeReports(
  List<LocalReport> local,
  List<Map<String, dynamic>> server,
) {
  final seen = <String>{};
  final result = <ReportItem>[];

  for (final r in local) {
    final key = r.serverId ?? r.idempotencyKey;
    if (key.isEmpty) continue;
    if (seen.contains(key)) continue;
    seen.add(key);
    result.add(ReportItem.fromLocal(r));
  }

  for (final r in server) {
    final serverId = r['id']?.toString();
    final idempotencyKey = r['idempotency_key']?.toString();
    final dedupKey = serverId ?? idempotencyKey ?? '';
    if (dedupKey.isEmpty) continue;
    if (seen.contains(dedupKey)) continue;
    seen.add(dedupKey);
    final item = ReportItem.fromServer(r);
    if (item == null) continue;
    result.add(item);
  }

  result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return result;
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

Color _syncDotColor(int syncStatus) {
  switch (syncStatus) {
    case 1:
      return SigapColors.selesai;
    case 2:
      return SigapColors.perluTindakan;
    default:
      return SigapColors.offlineDot;
  }
}

String _serverStatusLabel(BuildContext context, String? status) {
  return statusLabel(context, status);
}

Color _serverStatusColor(String? status) {
  switch (status) {
    case 'submitted':
    case 'under_review':
      return SigapColors.perluTindakan;
    case 'verified':
    case 'in_progress':
      return SigapColors.diproses;
    case 'resolved':
      return SigapColors.selesai;
    default:
      return SigapColors.textMuted;
  }
}

// ─── Report list item (warga) ────────────────────────────────────────────────

class _ReportListItem extends StatelessWidget {
  final ReportItem report;
  final VoidCallback onTap;

  const _ReportListItem({required this.report, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: SigapSpacing.sm),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SigapRadius.md),
        side: const BorderSide(color: SigapColors.borderCard),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SigapRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(SigapSpacing.md),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: _syncDotColor(report.syncStatus),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: SigapSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (report.status != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: SigapSpacing.sm,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _serverStatusColor(
                                report.status,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(
                                SigapRadius.pill,
                              ),
                            ),
                            child: Text(
                              _serverStatusLabel(context, report.status),
                              style: TextStyle(
                                color: _serverStatusColor(report.status),
                                fontSize: SigapTypography.captionMedium,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: SigapSpacing.sm),
                        ],
                        Expanded(
                          child: Text(
                            report.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: SigapTypography.bodyTextWide,
                              fontWeight: FontWeight.w500,
                              color: SigapColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: SigapSpacing.xs),
                    Text(
                      '${report.lat.toStringAsFixed(4)}, ${report.lng.toStringAsFixed(4)}',
                      style: const TextStyle(
                        color: SigapColors.textTertiary,
                        fontFamily: SigapTypography.fontFamilyMono,
                        fontSize: SigapTypography.captionMedium,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: SigapColors.textTertiary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Loading / Error helpers ─────────────────────────────────────────────────

Widget _buildStatsLoading() => const SkeletonStatsRow();

Widget _buildStatsError(
  BuildContext context,
  Object error,
  VoidCallback onRetry,
) {
  final l10n = AppLocalizations.of(context)!;
  return Container(
    height: 70,
    padding: const EdgeInsets.all(SigapSpacing.md),
    decoration: BoxDecoration(
      color: SigapColors.surface,
      borderRadius: BorderRadius.circular(SigapRadius.md),
      border: Border.all(color: SigapColors.border),
    ),
    child: Row(
      children: [
        const Icon(
          Icons.error_outline,
          color: SigapColors.perluTindakan,
          size: 24,
        ),
        const SizedBox(width: SigapSpacing.sm),
        Expanded(
          child: Text(
            l10n.gagalMemuatStatistik,
            style: TextStyle(
              color: SigapColors.textSecondary,
              fontSize: SigapTypography.bodyText,
            ),
          ),
        ),
        TextButton(
          onPressed: onRetry,
          child: Text(
            l10n.cobaLagi,
            style: const TextStyle(fontSize: SigapTypography.bodyText),
          ),
        ),
      ],
    ),
  );
}

Widget _buildNearbyLoading() => const SkeletonNearbyCard();

Widget _buildNearbyError(
  BuildContext context,
  Object error,
  VoidCallback onRetry,
) {
  final l10n = AppLocalizations.of(context)!;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: SigapSpacing.md),
      Container(
        padding: const EdgeInsets.all(SigapSpacing.md),
        decoration: BoxDecoration(
          color: SigapColors.bgCard,
          border: Border.all(color: SigapColors.borderCard),
          borderRadius: BorderRadius.circular(SigapRadius.x12),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: SigapColors.danger,
              size: 24,
            ),
            const SizedBox(width: SigapSpacing.x11),
            Expanded(
              child: Text(
                l10n.gagalMemuatKasusTerdekat,
                style: TextStyle(
                  color: SigapColors.textSecondary,
                  fontSize: SigapTypography.bodyTextWide,
                ),
              ),
            ),
            TextButton(
              onPressed: onRetry,
              child: Text(
                l10n.cobaLagi,
                style: const TextStyle(
                  fontSize: SigapTypography.bodySmall,
                  fontWeight: FontWeight.w600,
                  color: SigapColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget _buildListLoading() {
  return ListView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: 3,
    itemBuilder: (_, __) => const SkeletonListItem(),
  );
}

Widget _buildListError(
  BuildContext context,
  Object error,
  VoidCallback onRetry,
) {
  final l10n = AppLocalizations.of(context)!;
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(SigapSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: SigapColors.perluTindakan,
            size: 48,
          ),
          const SizedBox(height: SigapSpacing.md),
          Text(
            l10n.gagalMemuatLaporan,
            style: TextStyle(
              color: SigapColors.textSecondary,
              fontSize: SigapTypography.bodyLarge,
            ),
          ),
          const SizedBox(height: SigapSpacing.sm),
          Text(
            error.toString(),
            style: TextStyle(
              color: SigapColors.textMuted,
              fontSize: SigapTypography.bodySmall,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: SigapSpacing.md),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 18),
            label: Text(l10n.cobaLagi),
          ),
        ],
      ),
    ),
  );
}

Widget _buildWargaEmpty(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  return Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: SigapSpacing.lg,
        vertical: SigapSpacing.xl,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: SigapColors.bgSurface,
              shape: BoxShape.circle,
              border: Border.all(color: SigapColors.borderCard, width: 2),
            ),
            child: const Icon(
              Icons.inbox_outlined,
              size: 32,
              color: SigapColors.textTertiary,
            ),
          ),
          const SizedBox(height: SigapSpacing.md),
          Text(
            l10n.belumAdaAktivitas,
            style: const TextStyle(
              color: SigapColors.textPrimary,
              fontSize: SigapTypography.bodyLarge,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: SigapSpacing.xs),
          const Text(
            'Laporan yang Anda kirimkan akan dicatat di sini.',
            style: TextStyle(
              color: SigapColors.textSecondary,
              fontSize: SigapTypography.bodyText,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

Widget _buildSurveyorLoading() {
  return ListView.builder(
    padding: const EdgeInsets.all(SigapSpacing.lg),
    itemCount: 3,
    itemBuilder: (_, __) => Padding(
      padding: const EdgeInsets.only(bottom: SigapSpacing.md),
      child: const TaskCardSkeleton(),
    ),
  );
}

Widget _buildSurveyorEmpty() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: SigapSpacing.x90,
          height: SigapSpacing.x90,
          decoration: BoxDecoration(
            color: SigapColors.bgSurface,
            shape: BoxShape.circle,
            border: Border.all(color: SigapColors.borderCard, width: 2),
          ),
          child: const Icon(
            Icons.inbox_outlined,
            size: 40,
            color: SigapColors.textTertiary,
          ),
        ),
        const SizedBox(height: SigapSpacing.lg),
        const Text(
          'Tidak ada tugas',
          style: TextStyle(
            fontSize: SigapTypography.bodyLarge,
            fontWeight: FontWeight.w600,
            color: SigapColors.textPrimary,
          ),
        ),
        const SizedBox(height: SigapSpacing.xs),
        const Text(
          'Tugas akan muncul di sini',
          style: TextStyle(
            fontSize: SigapTypography.bodyText,
            color: SigapColors.textTertiary,
          ),
        ),
      ],
    ),
  );
}

Widget _buildSurveyorError(
  BuildContext context,
  Object error,
  VoidCallback onRetry,
) {
  final l10n = AppLocalizations.of(context)!;
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(SigapSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: SigapColors.danger),
          const SizedBox(height: SigapSpacing.lg),
          Text(
            l10n.gagalMemuatTugas,
            style: const TextStyle(
              fontSize: SigapTypography.bodyLarge,
              fontWeight: FontWeight.w600,
              color: SigapColors.textPrimary,
            ),
          ),
          const SizedBox(height: SigapSpacing.sm),
          Text(
            error.toString(),
            style: const TextStyle(
              fontSize: SigapTypography.bodySmall,
              color: SigapColors.textTertiary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: SigapSpacing.lg),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text(l10n.cobaLagi),
            style: ElevatedButton.styleFrom(
              backgroundColor: SigapColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: SigapSpacing.lg,
                vertical: SigapSpacing.md,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// ─── UNIFIED HOME SCREEN ──────────────────────────────────────────────────────

/// Unified home screen — renders role-specific content based on activeRole.
/// Flat route: /dashboard → HomeScreen
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Position? _currentPosition;
  int _selectedNavIndex = 0;

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
      final activeRole = authState.activeRole;

      int newIndex = 0;
      if (activeRole == 'WARGA') {
        // Fixed WARGA nav: match route to tab index directly.
        const routes = FixedWargaBottomNav.fixedRoutes;
        for (int i = 0; i < routes.length; i++) {
          // Skip index 2 (FAB /create) — it's not a nav tab.
          if (i == 2) continue;
          if (loc.startsWith(routes[i])) {
            newIndex = i;
            break;
          }
        }
      } else if (activeRole == 'SURVEYOR') {
        // Fixed SURVEYOR nav: 5 tabs (Tugas, Peta, Sinkron, Riwayat, Akun).
        for (int i = 0; i < surveyorNavRoutes.length; i++) {
          if (loc.startsWith(surveyorNavRoutes[i])) {
            newIndex = i;
            break;
          }
        }
      } else {
        // Derive nav index from capabilities — same order as AdaptiveNav._buildNavItems.
        final capabilityState = ref.read(
          capabilityNotifierProvider.select((state) => state.valueOrNull),
        );
        final routes = navRoutesForCapabilities(
          capabilityState?.capabilities ?? {},
        );
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
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      );
      if (mounted) setState(() => _currentPosition = position);
    } catch (e) {
      // Location unavailable
    }
  }

  @override
  Widget build(BuildContext context) {
    final connectivityAsync = ref.watch(connectivityProvider);
    final authState = ref.watch(authNotifierProvider);
    final activeRole = authState.activeRole;

    final isOffline =
        connectivityAsync.whenOrNull(
          data: (results) =>
              results.isEmpty ||
              results.every((r) => r == ConnectivityResult.none),
        ) ??
        false;

    return Column(
      children: [
        Expanded(
          child: Scaffold(
            backgroundColor: SigapColors.bgSurface,
            body: _buildBody(isOffline),
            bottomNavigationBar: activeRole == 'WARGA'
                ? FixedWargaBottomNav(
                    activeIndex: _selectedNavIndex,
                    onTabTap: (index) {
                      setState(() => _selectedNavIndex = index);
                      final route = FixedWargaBottomNav.fixedRoutes[index];
                      if (index == 0) {
                        context.go(route);
                      } else {
                        context.push(route);
                      }
                    },
                    onFabTap: () => context.push('/create'),
                  )
                : activeRole == 'SURVEYOR'
                ? SurveyorBottomNav(
                    activeIndex: _selectedNavIndex,
                    onTap: (index) {
                      setState(() => _selectedNavIndex = index);
                      final route = surveyorNavRoutes[index];
                      if (index == 0) {
                        context.go(route);
                      } else {
                        context.push(route);
                      }
                    },
                  )
                : AdaptiveNav(
                    activeIndex: _selectedNavIndex,
                    onTap: (index) {
                      setState(() => _selectedNavIndex = index);
                      // Derive route from capabilities — same order as AdaptiveNav._buildNavItems.
                      final capabilityState = ref.read(
                        capabilityNotifierProvider.select(
                          (state) => state.valueOrNull,
                        ),
                      );
                      final routes = navRoutesForCapabilities(
                        capabilityState?.capabilities ?? {},
                      );
                      final route = index < routes.length
                          ? routes[index]
                          : '/dashboard';
                      if (index == 0) {
                        context.go(route);
                      } else {
                        context.push(route);
                      }
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(bool isOffline) {
    return HomeShell(isOffline: isOffline, currentPosition: _currentPosition);
  }
}

/// Capability-driven home shell that renders modules based on capabilities.
///
/// Replaces the role-branched _buildWargaBody / _buildSurveyorBody pattern.
class HomeShell extends ConsumerWidget {
  const HomeShell({super.key, required this.isOffline, this.currentPosition});

  final bool isOffline;
  final Position? currentPosition;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final userWilayahAsync = ref.watch(userWilayahProvider);
    final unreadCount = ref.watch(unreadCountProvider);

    final onlineStatus = isOffline
        ? ConnectivityStatus.offline
        : ConnectivityStatus.online;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(SigapSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Wilayah aktif header (M-05) ───────────────────────────────
          Padding(
            padding: const EdgeInsets.only(top: SigapSpacing.sm),
            child: Row(
              children: [
                // Left: wilayah label + name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.wilayahAktif,
                        style: const TextStyle(
                          fontSize: SigapTypography.captionMedium,
                          color: SigapColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: SigapSpacing.xxs),
                      userWilayahAsync.when(
                        data: (wilayahName) => Text(
                          '$wilayahName ▾',
                          style: const TextStyle(
                            fontSize: SigapTypography.subheading,
                            fontWeight: FontWeight.w700,
                            color: SigapColors.textPrimary,
                          ),
                        ),
                        loading: () => Text(
                          l10n.memuat,
                          style: const TextStyle(
                            fontSize: SigapTypography.subheading,
                            fontWeight: FontWeight.w700,
                            color: SigapColors.textMuted,
                          ),
                        ),
                        error: (_, __) => const Text(
                          '-',
                          style: TextStyle(
                            fontSize: SigapTypography.subheading,
                            fontWeight: FontWeight.w700,
                            color: SigapColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Right: connectivity indicator + notification bell
                ConnectivityIndicator(status: onlineStatus),
                const SizedBox(width: SigapSpacing.sm),
                GestureDetector(
                  onTap: () => context.push('/notifications'),
                  child: NotificationBell(unreadCount: unreadCount),
                ),
              ],
            ),
          ),
          const SizedBox(height: SigapSpacing.md),
          // ── Pending banner (report.read) ──────────────────────────────
          Can(
            action: 'report.read',
            child: _PendingBannerContent(isOffline: isOffline),
          ),
          const SizedBox(height: SigapSpacing.md),
          // ── Warga stats + list (report.read) ─────────────────────────
          Can(
            action: 'report.read',
            child: _WargaReportsModule(isOffline: isOffline),
          ),
          // ── Nearest cases (case.read) ─────────────────────────────────
          Can(
            action: 'case.read',
            child: _NearestCasesModule(currentPosition: currentPosition),
          ),
          // ── Surveyor tasks (task.read) ────────────────────────────────
          Can(
            action: 'task.read',
            child: _SurveyorTasksModule(isOffline: isOffline),
          ),
        ],
      ),
    );
  }
}

/// Pending banner content for warga.
class _PendingBannerContent extends ConsumerWidget {
  const _PendingBannerContent({required this.isOffline});
  final bool isOffline;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(pendingCountProvider);
    return pendingAsync.when(
      data: (count) => count > 0
          ? PendingSyncBanner(pendingCount: count)
          : const SizedBox.shrink(),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

/// Warga reports module: stats + merged local/server report list.
class _WargaReportsModule extends ConsumerWidget {
  const _WargaReportsModule({required this.isOffline});
  final bool isOffline;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final localAsync = ref.watch(localReportsProvider);
    final serverAsync = ref.watch(wargaReportsProvider);
    final statsAsync = ref.watch(wargaStatsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Stats
        statsAsync.when(
          data: (stats) => StatusGrid(
            perluTindakan: stats.submitted ?? 0,
            diproses: (stats.verified ?? 0) + (stats.inProgress ?? 0),
            selesai: stats.resolved ?? 0,
          ),
          loading: () => _buildStatsLoading(),
          error: (error, _) => _buildStatsError(
            context,
            error,
            () => ref.invalidate(wargaStatsProvider),
          ),
        ),
        // List header
        Padding(
          padding: const EdgeInsets.only(top: SigapSpacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.laporanSaya,
                style: const TextStyle(
                  fontSize: SigapTypography.bodyText,
                  fontWeight: FontWeight.w700,
                  color: SigapColors.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: () => context.push('/laporan'),
                child: Text(
                  l10n.lihatSemua,
                  style: const TextStyle(
                    fontSize: SigapTypography.bodySmall,
                    fontWeight: FontWeight.w600,
                    color: SigapColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: SigapSpacing.sm),
        // List
        localAsync.when(
          loading: () => _buildListLoading(),
          error: (e, _) => _buildListError(
            context,
            e,
            () => ref.invalidate(localReportsProvider),
          ),
          data: (localReports) => serverAsync.when(
            loading: () => _buildListLoading(),
            error: (e, _) => _buildListError(
              context,
              e,
              () => ref.invalidate(wargaReportsProvider),
            ),
            data: (serverReports) => _buildWargaList(
              context,
              ref,
              mergeReports(localReports, serverReports),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWargaList(
    BuildContext context,
    WidgetRef ref,
    List<ReportItem> reports,
  ) {
    if (reports.isEmpty) return _buildWargaEmpty(context);
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(localReportsProvider);
        ref.invalidate(wargaReportsProvider);
        await Future.wait([
          ref.read(localReportsProvider.future),
          ref.read(wargaReportsProvider.future),
        ]);
      },
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: reports.length,
        itemBuilder: (context, index) => _ReportListItem(
          report: reports[index],
          onTap: () => context.push('/laporan/${reports[index].navKey}'),
        ),
      ),
    );
  }
}

/// Nearest cases module (KasusTerdekatSection) for warga.
class _NearestCasesModule extends ConsumerWidget {
  const _NearestCasesModule({this.currentPosition});
  final Position? currentPosition;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (currentPosition == null) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;

    final nearbyAsync = ref.watch(
      nearbyReportsProvider((
        lat: currentPosition!.latitude,
        lng: currentPosition!.longitude,
      )),
    );

    return nearbyAsync.when(
      data: (reports) {
        if (reports.isEmpty) return const SizedBox.shrink();
        final cases = reports.map((r) {
          final statusStr = r['status']?.toString() ?? '';
          KasusStatus status =
              statusStr.contains('verified') ||
                  statusStr.contains('terverifikasi')
              ? KasusStatus.terverifikasi
              : KasusStatus.sedangDitangani;
          return KasusTerdekatCase(
            initials: (r['short_code'] ?? 'XX').toString().substring(
              0,
              2.clamp(0, (r['short_code'] ?? 'XX').toString().length),
            ),
            title: r['title']?.toString() ?? l10n.tanpaJudul,
            rw: r['village_name']?.toString() ?? 'RW -',
            distanceMeters: (r['distance_meters'] ?? 0).toInt(),
            laporanCount: (r['supporting_count'] ?? 0).toInt(),
            status: status,
          );
        }).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: SigapSpacing.md),
            KasusTerdekatSection(
              cases: cases,
              onLihatPeta: () => context.push('/map'),
              onCaseTap: (kasus) {
                final reportId = reports
                    .firstWhere(
                      (r) => r['title']?.toString() == kasus.title,
                      orElse: () => {},
                    )['id']
                    ?.toString();
                if (reportId != null) context.push('/laporan/$reportId');
              },
            ),
          ],
        );
      },
      loading: () => _buildNearbyLoading(),
      error: (error, _) => _buildNearbyError(
        context,
        error,
        () => ref.invalidate(
          nearbyReportsProvider((
            lat: currentPosition!.latitude,
            lng: currentPosition!.longitude,
          )),
        ),
      ),
    );
  }
}

/// Surveyor tasks module with SLA filters.
class _SurveyorTasksModule extends ConsumerWidget {
  const _SurveyorTasksModule({required this.isOffline});
  final bool isOffline;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final tasksAsync = ref.watch(surveyorTasksProvider);
    final filterIndex = ref.watch(surveyorFilterProvider);
    final sortValue = ref.watch(surveyorSortProvider);
    final userWilayahAsync = ref.watch(userWilayahProvider);

    final onlineStatus = isOffline
        ? ConnectivityStatus.offline
        : ConnectivityStatus.online;

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(SigapSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_hariIni(context)}, ${_tanggalIni(context)}',
                style: const TextStyle(
                  fontSize: SigapTypography.bodyText,
                  color: SigapColors.textSecondary,
                ),
              ),
              const SizedBox(height: SigapSpacing.xs),
              userWilayahAsync.when(
                data: (wilayahName) => Text(
                  wilayahName,
                  style: const TextStyle(
                    fontSize: SigapTypography.headlineMedium,
                    fontWeight: FontWeight.w700,
                    color: SigapColors.textPrimary,
                  ),
                ),
                loading: () => Text(
                  l10n.memuat,
                  style: const TextStyle(
                    fontSize: SigapTypography.headlineMedium,
                    fontWeight: FontWeight.w700,
                    color: SigapColors.textPrimary,
                  ),
                ),
                error: (_, __) => const Text(
                  '-',
                  style: TextStyle(
                    fontSize: SigapTypography.headlineMedium,
                    fontWeight: FontWeight.w700,
                    color: SigapColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Connectivity row
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: SigapSpacing.lg,
            vertical: SigapSpacing.sm,
          ),
          child: Row(
            children: [
              ConnectivityIndicator(status: onlineStatus),
              const Spacer(),
              // M-05 notification bell with unread badge
              Consumer(
                builder: (context, ref, _) {
                  final unreadCount = ref.watch(unreadCountProvider);
                  return GestureDetector(
                    onTap: () => context.push('/notifications'),
                    child: NotificationBell(unreadCount: unreadCount),
                  );
                },
              ),
            ],
          ),
        ),
        // Offline indicator
        if (isOffline) const OfflinePill(),
        // Filter chips
        TaskFilterChips(
          selectedIndex: filterIndex,
          onChipSelected: (index) =>
              ref.read(surveyorFilterProvider.notifier).state = index,
        ),
        // Sort row
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: SigapSpacing.lg,
            vertical: SigapSpacing.sm,
          ),
          child: TaskSortRow(
            selectedValue: _mapSortToDisplay(context, sortValue),
            onSortChanged: (value) =>
                ref.read(surveyorSortProvider.notifier).state =
                    _mapDisplayToSort(context, value),
            onUnduhBatchTap: () => _batchDownloadTasks(ref),
          ),
        ),
        // Task list
        tasksAsync.when(
          data: (tasks) =>
              _buildSurveyorTaskList(ref, tasks, filterIndex, sortValue),
          loading: () => _buildSurveyorLoading(),
          error: (error, _) => _buildSurveyorError(
            context,
            error,
            () => ref.invalidate(surveyorTasksProvider),
          ),
        ),
      ],
    );
  }

  Widget _buildSurveyorTaskList(
    WidgetRef ref,
    List<SurveyorTask> tasks,
    int? filterIndex,
    String sortValue,
  ) {
    final filteredTasks = _applyFilter(tasks, filterIndex);
    final sortedTasks = _applySort(filteredTasks, sortValue);
    if (sortedTasks.isEmpty) return _buildSurveyorEmpty();
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(surveyorTasksProvider);
        await ref.read(surveyorTasksProvider.future);
      },
      color: SigapColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(SigapSpacing.lg),
        itemCount: sortedTasks.length,
        itemBuilder: (context, index) {
          final task = sortedTasks[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: SigapSpacing.md),
            child: TaskCard(
              task: _mapToTaskData(context, task),
              onTap: () {
                final taskId = task.taskId;
                if (taskId != null) context.push('/tasks/$taskId');
              },
            ),
          );
        },
      ),
    );
  }

  /// Batch download tasks for offline use via surveyorTaskRepository.
  Future<void> _batchDownloadTasks(WidgetRef ref) async {
    final tasksAsync = ref.read(surveyorTasksProvider);
    final tasks = tasksAsync.valueOrNull;
    if (tasks == null || tasks.isEmpty) {
      if (ref.context.mounted) {
        final l10n = AppLocalizations.of(ref.context)!;
        ScaffoldMessenger.of(ref.context).showSnackBar(
          SnackBar(
            content: Text(l10n.tidakAdaTugasUntukDiunduh),
            duration: const Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    final repo = ref.read(surveyorTaskRepositoryProvider);
    int downloaded = 0;
    for (final task in tasks) {
      final taskId = task.taskId;
      if (taskId == null) continue;
      final existing = await repo.getDownloadedTask(taskId);
      if (existing == null) {
        await repo.saveDownloadedTask(
          taskId: taskId,
          title: task.reportTitle ?? '-',
          description: task.reportTitle ?? '',
          instructions: null, // Instructions available on detail view
          status: task.status ?? 'pending',
          checklistTemplate: [],
        );
        downloaded++;
      }
    }

    if (ref.context.mounted) {
      final l10n = AppLocalizations.of(ref.context)!;
      ScaffoldMessenger.of(ref.context).showSnackBar(
        SnackBar(
          content: Text(
            downloaded > 0
                ? l10n.berhasilMengunduhTugas(downloaded)
                : l10n.semuaTugasSudahDiunduh,
          ),
          backgroundColor: downloaded > 0 ? SigapColors.selesai : null,
        ),
      );
    }
  }

  List<SurveyorTask> _applyFilter(List<SurveyorTask> tasks, int? filterIndex) {
    if (filterIndex == null) return tasks;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (filterIndex) {
      case 0: // Hari ini
        return tasks.where((t) {
          final parsed = _parseDate(t.assignedAt);
          return parsed != null &&
              parsed.year == today.year &&
              parsed.month == today.month &&
              parsed.day == today.day;
        }).toList();
      case 1: // Terlambat — SLA has passed (deadline in the past)
        return tasks.where((t) {
          if (t.deadline == null) return false;
          final deadline = _parseDate(t.deadline);
          return deadline != null && deadline.isBefore(now);
        }).toList();
      case 2: // Belum diunduh — tasks not saved locally for offline
        // This filter is checked by the widget itself using _downloadedTaskIds
        // The actual filtering happens in the list builder
        return tasks;
      default:
        return tasks;
    }
  }

  List<SurveyorTask> _applySort(List<SurveyorTask> tasks, String sortValue) {
    final sorted = List<SurveyorTask>.from(tasks);
    switch (sortValue) {
      case 'terbaru':
        sorted.sort((a, b) {
          final dateA = _parseDate(a.assignedAt);
          final dateB = _parseDate(b.assignedAt);
          if (dateA == null && dateB == null) return 0;
          if (dateA == null) return 1;
          if (dateB == null) return -1;
          return dateB.compareTo(dateA);
        });
        break;
      case 'sla':
        // SLA terdekat — sort by deadline ascending (nearest deadline first)
        sorted.sort((a, b) {
          final deadlineA = _parseDate(a.deadline);
          final deadlineB = _parseDate(b.deadline);
          if (deadlineA == null && deadlineB == null) return 0;
          if (deadlineA == null) return 1; // null deadlines go last
          if (deadlineB == null) return -1;
          return deadlineA.compareTo(deadlineB);
        });
        break;
      case 'prioritas':
        // Priority sort: critical > high > medium > low, then by SLA
        const priorityOrder = {'critical': 0, 'high': 1, 'medium': 2, 'low': 3};
        sorted.sort((a, b) {
          final pA = priorityOrder[a.priority?.toLowerCase()] ?? 4;
          final pB = priorityOrder[b.priority?.toLowerCase()] ?? 4;
          if (pA != pB) return pA.compareTo(pB);
          // Same priority → sort by SLA deadline
          final deadlineA = _parseDate(a.deadline);
          final deadlineB = _parseDate(b.deadline);
          if (deadlineA == null && deadlineB == null) return 0;
          if (deadlineA == null) return 1;
          if (deadlineB == null) return -1;
          return deadlineA.compareTo(deadlineB);
        });
        break;
    }
    return sorted;
  }

  TaskData _mapToTaskData(BuildContext context, SurveyorTask task) {
    // Derive priority from actual task data (S-01)
    final priority = _mapTaskPriority(task.priority);
    final timeAgo = _formatTimeAgo(context, _parseDate(task.assignedAt));
    return TaskData(
      id: task.taskId ?? '',
      title: task.reportTitle ?? 'Tanpa judul',
      location: task.address ?? '-',
      timeAgo: timeAgo,
      priority: priority,
    );
  }

  TaskPriority _mapTaskPriority(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'critical':
        return TaskPriority.urgent;
      case 'high':
        return TaskPriority.high;
      case 'medium':
        return TaskPriority.normal;
      case 'low':
        return TaskPriority.low;
      default:
        return TaskPriority.normal;
    }
  }

  String _mapSortToDisplay(BuildContext context, String sort) {
    final l10n = AppLocalizations.of(context)!;
    switch (sort) {
      case 'terbaru':
        return l10n.terbaru;
      case 'sla':
        return l10n.slaTerdekat;
      case 'prioritas':
        return l10n.prioritas;
      default:
        return l10n.terbaru;
    }
  }

  String _mapDisplayToSort(BuildContext context, String display) {
    final l10n = AppLocalizations.of(context)!;
    if (display == l10n.terbaru) return 'terbaru';
    if (display == l10n.slaTerdekat) return 'sla';
    if (display == l10n.prioritas) return 'prioritas';
    return 'terbaru';
  }

  DateTime? _parseDate(String? s) => s == null ? null : DateTime.tryParse(s);

  String _formatTimeAgo(BuildContext context, DateTime? date) {
    if (date == null) return '-';
    final l10n = AppLocalizations.of(context)!;
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) {
      if (diff.inDays == 1) return l10n.kemarin;
      if (diff.inDays < 7) return '${diff.inDays} ${l10n.hariLalu}';
      return '${(diff.inDays / 7).floor()} ${l10n.mingguLalu}';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} ${l10n.jamYangLalu}';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} ${l10n.menitYangLalu}';
    }
    return l10n.baruSaja;
  }

  String _hariIni(BuildContext context) {
    return DateFormat(
      'EEEE',
      Localizations.localeOf(context).toString(),
    ).format(DateTime.now());
  }

  String _tanggalIni(BuildContext context) {
    return DateFormat(
      'd MMMM yyyy',
      Localizations.localeOf(context).toString(),
    ).format(DateTime.now());
  }
}

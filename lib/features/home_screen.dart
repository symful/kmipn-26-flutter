import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import '../api/types.g.dart';
import '../db/database.dart';
import '../l10n/strings.dart';
import '../providers/providers.dart';
import '../providers/auth_provider.dart';
import '../theme/tokens.dart';
import '../widgets/design_system/bottom_nav_5.dart';
import '../widgets/design_system/buttons.dart';
import '../widgets/design_system/phone_frame.dart';
import '../widgets/design_system/status_bar.dart';
import '../widgets/design_system/wilayah_dropdown.dart';
import '../widgets/design_system/notification_bell.dart';
import '../widgets/design_system/skeleton_loaders.dart';
import '../widgets/design_system/status_grid.dart';
import '../widgets/design_system/kasus_terdekat_cards.dart';
import '../widgets/design_system/connectivity_indicator.dart';
import '../widgets/design_system/task_filter_chips.dart';
import '../widgets/design_system/task_sort_row.dart';
import '../widgets/design_system/task_card.dart';
import '../widgets/design_system/offline_pill.dart';

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

  String get navKey => idempotencyKey ?? serverId ?? key;
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

String _serverStatusLabel(String? status) {
  switch (status) {
    case 'submitted':
    case 'under_review':
      return Strings.perluTindakanCapital;
    case 'verified':
    case 'in_progress':
      return Strings.diproses;
    case 'resolved':
      return Strings.selesai;
    case 'rejected':
      return Strings.ditolak;
    case 'duplicate_merged':
      return Strings.duplikat;
    case 'needs_survey':
      return Strings.perluSurvei;
    default:
      return status ?? Strings.unknown;
  }
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
                              _serverStatusLabel(report.status),
                              style: TextStyle(
                                color: _serverStatusColor(report.status),
                                fontSize: SigapTypography.size11,
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
                              fontSize: SigapTypography.size13_5,
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
                        fontSize: SigapTypography.size11,
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

Widget _buildStatsError(Object error, VoidCallback onRetry) {
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
            'Gagal memuat statistik',
            style: TextStyle(
              color: SigapColors.textSecondary,
              fontSize: SigapTypography.size13,
            ),
          ),
        ),
        TextButton(
          onPressed: onRetry,
          child: const Text(
            'Coba lagi',
            style: TextStyle(fontSize: SigapTypography.size13),
          ),
        ),
      ],
    ),
  );
}

Widget _buildNearbyLoading() => const SkeletonNearbyCard();

Widget _buildNearbyError(Object error, VoidCallback onRetry) {
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
                'Gagal memuat kasus terdekat',
                style: TextStyle(
                  color: SigapColors.textSecondary,
                  fontSize: SigapTypography.size13_5,
                ),
              ),
            ),
            TextButton(
              onPressed: onRetry,
              child: const Text(
                'Coba lagi',
                style: TextStyle(
                  fontSize: SigapTypography.size12,
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

Widget _buildListError(Object error, VoidCallback onRetry) {
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
            'Gagal memuat laporan',
            style: TextStyle(
              color: SigapColors.textSecondary,
              fontSize: SigapTypography.size16,
            ),
          ),
          const SizedBox(height: SigapSpacing.sm),
          Text(
            error.toString(),
            style: TextStyle(
              color: SigapColors.textMuted,
              fontSize: SigapTypography.size12,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: SigapSpacing.md),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Coba lagi'),
          ),
        ],
      ),
    ),
  );
}

Widget _buildWargaEmpty() {
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
          const Text(
            Strings.belumAdaAktivitas,
            style: TextStyle(
              color: SigapColors.textPrimary,
              fontSize: SigapTypography.size16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: SigapSpacing.xs),
          const Text(
            'Laporan yang Anda kirimkan akan dicatat di sini.',
            style: TextStyle(
              color: SigapColors.textSecondary,
              fontSize: SigapTypography.size13,
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
            fontSize: SigapTypography.size16,
            fontWeight: FontWeight.w600,
            color: SigapColors.textPrimary,
          ),
        ),
        const SizedBox(height: SigapSpacing.xs),
        const Text(
          'Tugas akan muncul di sini',
          style: TextStyle(
            fontSize: SigapTypography.size13,
            color: SigapColors.textTertiary,
          ),
        ),
      ],
    ),
  );
}

Widget _buildSurveyorError(Object error, VoidCallback onRetry) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(SigapSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: SigapColors.danger),
          const SizedBox(height: SigapSpacing.lg),
          const Text(
            'Gagal memuat tugas',
            style: TextStyle(
              fontSize: SigapTypography.size16,
              fontWeight: FontWeight.w600,
              color: SigapColors.textPrimary,
            ),
          ),
          const SizedBox(height: SigapSpacing.sm),
          Text(
            error.toString(),
            style: const TextStyle(
              fontSize: SigapTypography.size12,
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
            label: const Text('Coba lagi'),
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

// ─── Pending banner ───────────────────────────────────────────────────────────

class _PendingBanner extends StatelessWidget {
  final int count;
  const _PendingBanner({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SigapSpacing.x14,
        vertical: SigapSpacing.md,
      ),
      decoration: BoxDecoration(
        color: SigapColors.offlineBg,
        border: Border.all(color: SigapColors.offlineBorder),
        borderRadius: BorderRadius.circular(SigapRadius.lg),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: SigapColors.offlineDot,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              '$count',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: SigapTypography.size14,
              ),
            ),
          ),
          const SizedBox(width: SigapSpacing.x11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$count laporan belum tersinkron',
                  style: const TextStyle(
                    color: SigapColors.warningTextStrong,
                    fontWeight: FontWeight.w600,
                    fontSize: SigapTypography.size13_5,
                  ),
                ),
                const SizedBox(height: SigapRadius.x1),
                const Text(
                  'Aman tersimpan di perangkat. Akan terkirim otomatis saat ada koneksi.',
                  style: TextStyle(
                    color: SigapColors.offlineText,
                    fontSize: SigapTypography.size12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: SigapSpacing.sm),
                GestureDetector(
                  onTap: () => context.push('/sync-center'),
                  child: const Text(
                    'Buka Pusat Sinkronisasi →',
                    style: TextStyle(
                      color: SigapColors.primaryDark,
                      fontWeight: FontWeight.w600,
                      fontSize: SigapTypography.size12_5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
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
      int newIndex = 0;
      if (loc.startsWith('/map'))
        newIndex = 1;
      else if (loc.startsWith('/laporan'))
        newIndex = 3;
      else if (loc == '/profile')
        newIndex = 4;
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
    final activeRole = ref.watch(authNotifierProvider).activeRole ?? 'warga';
    final connectivityAsync = ref.watch(connectivityProvider);

    final isOffline =
        connectivityAsync.whenOrNull(
          data: (results) =>
              results.isEmpty ||
              results.every((r) => r == ConnectivityResult.none),
        ) ??
        false;

    return PhoneFrame(
      child: Column(
        children: [
          StatusBar(),
          Expanded(
            child: Scaffold(
              backgroundColor: SigapColors.bgSurface,
              body: _buildBody(activeRole, isOffline),
              bottomNavigationBar: BottomNav5(
                variant: _bottomNavVariant(activeRole),
                selectedIndex: _selectedNavIndex,
                onTap: (index) {
                  setState(() => _selectedNavIndex = index);
                  switch (index) {
                    case 0:
                      context.go('/');
                      break;
                    case 1:
                      context.push('/map');
                      break;
                    case 2:
                      context.push('/create');
                      break;
                    case 3:
                      context.push('/laporan');
                      break;
                    case 4:
                      context.push('/profile');
                      break;
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  BottomNavVariant _bottomNavVariant(String role) {
    switch (role) {
      case 'warga':
        return BottomNavVariant.warga;
      case 'surveyor':
        return BottomNavVariant.surveyor;
      default:
        return BottomNavVariant.warga;
    }
  }

  Widget _buildBody(String role, bool isOffline) {
    switch (role) {
      case 'warga':
        return _buildWargaBody(isOffline);
      case 'surveyor':
        return _buildSurveyorBody(isOffline);
      default:
        return _buildWargaBody(isOffline);
    }
  }

  // ─── WARGA BODY ─────────────────────────────────────────────────────────

  Widget _buildWargaBody(bool isOffline) {
    final authState = ref.watch(authNotifierProvider);
    final localAsync = ref.watch(localReportsProvider);
    final serverAsync = ref.watch(wargaReportsProvider);
    final pendingAsync = ref.watch(pendingCountProvider);
    final statsAsync = ref.watch(wargaStatsProvider);
    final selectedWilayah = ref.watch(selectedWilayahNameProvider);

    Widget? nearbySection;
    if (_currentPosition != null) {
      final nearbyAsync = ref.watch(
        nearbyReportsProvider((
          lat: _currentPosition!.latitude,
          lng: _currentPosition!.longitude,
        )),
      );
      nearbySection = nearbyAsync.when(
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
              title: r['title']?.toString() ?? 'Tanpa judul',
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
                  if (reportId != null) context.push('/detail/$reportId');
                },
              ),
            ],
          );
        },
        loading: () => _buildNearbyLoading(),
        error: (error, _) => _buildNearbyError(
          error,
          () => ref.invalidate(
            nearbyReportsProvider((
              lat: _currentPosition!.latitude,
              lng: _currentPosition!.longitude,
            )),
          ),
        ),
      );
    }

    return Column(
      children: [
        // AppBar
        AppBar(
          title: WilayahDropdown(
            label: 'Wilayah aktif',
            value: '$selectedWilayah ▾',
            onTap: null,
          ),
          automaticallyImplyLeading: false,
          actions: [
            if (isOffline)
              Container(
                margin: const EdgeInsets.only(right: SigapSpacing.x4),
                padding: const EdgeInsets.symmetric(
                  horizontal: SigapSpacing.x9,
                  vertical: SigapSpacing.x4,
                ),
                decoration: BoxDecoration(
                  color: SigapColors.offlineBg,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: SigapColors.offlineBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: SigapColors.offlineDot,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: SigapSpacing.xs),
                    const Text(
                      'Offline',
                      style: TextStyle(
                        color: SigapColors.offlineText,
                        fontSize: SigapTypography.size11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            if (authState.roles.length > 1)
              IconButton(
                icon: const Icon(Icons.swap_horiz),
                tooltip: 'Ganti Peran',
                onPressed: () => context.push('/switch-role'),
              ),
            IconButton(
              onPressed: () => context.push('/notifications'),
              icon: NotificationBell(
                unreadCount: ref.watch(unreadCountProvider),
              ),
            ),
          ],
        ),
        // Body
        Expanded(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(SigapSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: SigapSpacing.lg),
                  // CTA
                  CtaButton(
                    label: 'Buat laporan',
                    subtitle: 'Foto, lokasi, dan kondisi lapangan',
                    onPressed: () => context.push('/create'),
                  ),
                  const SizedBox(height: SigapSpacing.md),
                  // Pending banner
                  pendingAsync.when(
                    data: (count) => count > 0
                        ? _PendingBanner(count: count)
                        : const SizedBox.shrink(),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: SigapSpacing.md),
                  // Stats
                  statsAsync.when(
                    data: (stats) => StatusGrid(
                      perluTindakan: stats.submitted ?? 0,
                      diproses: (stats.verified ?? 0) + (stats.inProgress ?? 0),
                      selesai: stats.resolved ?? 0,
                    ),
                    loading: () => _buildStatsLoading(),
                    error: (error, _) => _buildStatsError(
                      error,
                      () => ref.invalidate(wargaStatsProvider),
                    ),
                  ),
                  // Nearby
                  if (nearbySection != null) nearbySection,
                  // List header
                  Padding(
                    padding: const EdgeInsets.only(top: SigapSpacing.md),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          Strings.laporanSaya,
                          style: TextStyle(
                            fontSize: SigapTypography.size13,
                            fontWeight: FontWeight.w700,
                            color: SigapColors.textPrimary,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.push('/laporan'),
                          child: const Text(
                            Strings.lihatSemua,
                            style: TextStyle(
                              fontSize: SigapTypography.size12,
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
                  Expanded(
                    child: localAsync.when(
                      loading: () => _buildListLoading(),
                      error: (e, _) => _buildListError(
                        e,
                        () => ref.invalidate(localReportsProvider),
                      ),
                      data: (localReports) => serverAsync.when(
                        loading: () => _buildListLoading(),
                        error: (e, _) => _buildListError(
                          e,
                          () => ref.invalidate(wargaReportsProvider),
                        ),
                        data: (serverReports) => _buildWargaList(
                          mergeReports(localReports, serverReports),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWargaList(List<ReportItem> reports) {
    if (reports.isEmpty) return _buildWargaEmpty();
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
        itemCount: reports.length,
        itemBuilder: (context, index) => _ReportListItem(
          report: reports[index],
          onTap: () => context.push('/detail/${reports[index].navKey}'),
        ),
      ),
    );
  }

  // ─── SURVEYOR BODY ───────────────────────────────────────────────────────

  Widget _buildSurveyorBody(bool isOffline) {
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
                '${_hariIni()}, ${_tanggalIni()}',
                style: const TextStyle(
                  fontSize: SigapTypography.size13,
                  color: SigapColors.textSecondary,
                ),
              ),
              const SizedBox(height: SigapSpacing.xs),
              userWilayahAsync.when(
                data: (wilayahName) => Text(
                  wilayahName,
                  style: const TextStyle(
                    fontSize: SigapTypography.size22,
                    fontWeight: FontWeight.w700,
                    color: SigapColors.textPrimary,
                  ),
                ),
                loading: () => const Text(
                  'Memuat...',
                  style: TextStyle(
                    fontSize: SigapTypography.size22,
                    fontWeight: FontWeight.w700,
                    color: SigapColors.textPrimary,
                  ),
                ),
                error: (_, __) => const Text(
                  'Kab. Bandung',
                  style: TextStyle(
                    fontSize: SigapTypography.size22,
                    fontWeight: FontWeight.w700,
                    color: SigapColors.textPrimary,
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
              if (isOffline)
                TextButton.icon(
                  onPressed: () => ref.read(syncWorkerProvider).syncNow(),
                  icon: const Icon(Icons.sync, size: 16),
                  label: const Text('Sinkronkan'),
                  style: TextButton.styleFrom(
                    foregroundColor: SigapColors.primary,
                  ),
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
            selectedValue: _mapSortToDisplay(sortValue),
            onSortChanged: (value) =>
                ref.read(surveyorSortProvider.notifier).state =
                    _mapDisplayToSort(value),
            onUnduhBatchTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Fitur unduh batch belum tersedia'),
                duration: Duration(seconds: 2),
              ),
            ),
          ),
        ),
        // Task list
        Expanded(
          child: tasksAsync.when(
            data: (tasks) =>
                _buildSurveyorTaskList(tasks, filterIndex, sortValue),
            loading: () => _buildSurveyorLoading(),
            error: (error, _) => _buildSurveyorError(
              error,
              () => ref.invalidate(surveyorTasksProvider),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSurveyorTaskList(
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
              task: _mapToTaskData(task),
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

  List<SurveyorTask> _applyFilter(List<SurveyorTask> tasks, int? filterIndex) {
    if (filterIndex == null) return tasks;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (filterIndex) {
      case 0:
        return tasks.where((t) {
          final parsed = _parseDate(t.assignedAt);
          return parsed != null &&
              parsed.year == today.year &&
              parsed.month == today.month &&
              parsed.day == today.day;
        }).toList();
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
    }
    return sorted;
  }

  TaskData _mapToTaskData(SurveyorTask task) {
    const priority = TaskPriority.normal;
    final timeAgo = _formatTimeAgo(_parseDate(task.assignedAt));
    return TaskData(
      id: task.taskId ?? '',
      title: task.reportTitle ?? 'Tanpa judul',
      location: '-',
      timeAgo: timeAgo,
      priority: priority,
    );
  }

  String _mapSortToDisplay(String sort) {
    switch (sort) {
      case 'terbaru':
        return 'Terbaru';
      case 'sla':
        return 'SLA terdekat';
      case 'prioritas':
        return 'Prioritas';
      default:
        return 'Terbaru';
    }
  }

  String _mapDisplayToSort(String display) {
    switch (display) {
      case 'Terbaru':
        return 'terbaru';
      case 'SLA terdekat':
        return 'sla';
      case 'Prioritas':
        return 'prioritas';
      default:
        return 'terbaru';
    }
  }

  DateTime? _parseDate(String? s) => s == null ? null : DateTime.tryParse(s);

  String _formatTimeAgo(DateTime? date) {
    if (date == null) return '-';
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) {
      if (diff.inDays == 1) return 'Kemarin';
      if (diff.inDays < 7) return '${diff.inDays} hari lalu';
      return '${(diff.inDays / 7).floor()} minggu lalu';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} jam yang lalu';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} menit lalu';
    }
    return 'Baru saja';
  }

  String _hariIni() {
    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    return days[DateTime.now().weekday - 1];
  }

  String _tanggalIni() {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    final d = DateTime.now();
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}

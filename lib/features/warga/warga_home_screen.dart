import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import '../../db/database.dart';
import '../../providers/providers.dart';
import '../../providers/auth_provider.dart';
import '../../theme/tokens.dart';
import '../../widgets/design_system/bottom_nav_5.dart';
import '../../widgets/design_system/buttons.dart';
import '../../widgets/design_system/phone_frame.dart';
import '../../widgets/design_system/status_bar.dart';
import '../../widgets/design_system/wilayah_dropdown.dart';
import '../../widgets/design_system/notification_bell.dart';
import '../../widgets/skeleton_loaders.dart';
import 'presentation/widgets/status_grid.dart';
import 'presentation/widgets/kasus_terdekat_cards.dart';

/// Unified report model that wraps both local and server report data.
class WargaReportItem {
  final String key; // idempotencyKey for local, or server id for server-only
  final String description;
  final double lat;
  final double lng;
  final int syncStatus; // 0=pending, 1=synced, 2=failed
  final String? serverId;
  final String? idempotencyKey;
  final DateTime createdAt;
  final String? status; // server-assigned status label
  final bool isLocal; // true if from local DB

  const WargaReportItem({
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

  factory WargaReportItem.fromLocal(LocalReport r) {
    return WargaReportItem(
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

  /// Returns null if lat/lng is missing — caller should filter these out.
  static WargaReportItem? fromServer(Map<String, dynamic> r) {
    final lat = r['lat'] ?? r['location']?['lat'];
    final lng = r['lng'] ?? r['location']?['lng'];
    if (lat == null || lng == null) {
      return null; // skip reports without location
    }
    return WargaReportItem(
      key: r['id']?.toString() ?? r['idempotency_key']?.toString() ?? '',
      description:
          r['description']?.toString() ??
          r['title']?.toString() ??
          'Tanpa judul',
      lat: lat.toDouble(),
      lng: lng.toDouble(),
      syncStatus: 1, // server reports are always "synced"
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

  /// Navigation target: prefers idempotencyKey (local), falls back to serverId.
  String get navKey => idempotencyKey ?? serverId ?? key;
}

/// Merges local Drift reports with server reports, deduplicating by serverId
/// (for synced local reports) or idempotencyKey (for unsynced locals).
List<WargaReportItem> mergeReports(
  List<LocalReport> local,
  List<Map<String, dynamic>> server,
) {
  final seen = <String>{};
  final result = <WargaReportItem>[];

  // Add all local reports (they carry sync state)
  for (final r in local) {
    final key = r.serverId ?? r.idempotencyKey;
    if (key.isEmpty) continue;
    if (seen.contains(key)) continue;
    seen.add(key);
    result.add(WargaReportItem.fromLocal(r));
  }

  // Add server reports that aren't already covered by a local entry
  for (final r in server) {
    final serverId = r['id']?.toString();
    final idempotencyKey = r['idempotency_key']?.toString();

    final dedupKey = serverId ?? idempotencyKey ?? '';
    if (dedupKey.isEmpty) continue;
    if (seen.contains(dedupKey)) continue;
    seen.add(dedupKey);
    final item = WargaReportItem.fromServer(r);
    if (item == null) continue; // skip reports without valid location
    result.add(item);
  }

  // Sort newest first
  result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return result;
}

// ─── Sync status dot helper ───────────────────────────────────────────────────

Color _syncDotColor(int syncStatus) {
  switch (syncStatus) {
    case 1:
      return SigapColors.selesai;
    case 2:
      return SigapColors.perluTindakan;
    default:
      return SigapColors.offlineDot; // 0 = amber/pending
  }
}

// ─── Server status label helper ─────────────────────────────────────────────

String _serverStatusLabel(String? status) {
  switch (status) {
    case 'submitted':
    case 'under_review':
      return 'Perlu Tindakan';
    case 'verified':
    case 'in_progress':
      return 'Diproses';
    case 'resolved':
      return 'Selesai';
    case 'rejected':
      return 'Ditolak';
    case 'duplicate_merged':
      return 'Duplikat';
    case 'needs_survey':
      return 'Perlu Survei';
    default:
      return status ?? 'Unknown';
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

// ─── Widgets ─────────────────────────────────────────────────────────────────

class _WargaReportListItem extends StatelessWidget {
  final WargaReportItem report;
  final VoidCallback onTap;

  const _WargaReportListItem({required this.report, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: SigapSpacing.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SigapRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(SigapSpacing.md),
          child: Row(
            children: [
              // Sync status dot
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: _syncDotColor(report.syncStatus),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: SigapSpacing.md),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status badge + description
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
                                SigapRadius.sm,
                              ),
                            ),
                            child: Text(
                              _serverStatusLabel(report.status),
                              style: TextStyle(
                                color: _serverStatusColor(report.status),
                                fontSize: 11,
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
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: SigapSpacing.xs),
                    // Coordinates
                    Text(
                      '${report.lat.toStringAsFixed(4)}, ${report.lng.toStringAsFixed(4)}',
                      style: const TextStyle(
                        color: SigapColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              // Chevron
              const Icon(
                Icons.chevron_right,
                color: SigapColors.textMuted,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Loading & Error helpers ─────────────────────────────────────────────────

/// Skeleton loading for the stats grid.
Widget _buildStatsLoading() {
  return const SkeletonStatsRow();
}

/// Error state for stats with retry button.
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
            style: TextStyle(color: SigapColors.textSecondary, fontSize: 13),
          ),
        ),
        TextButton(
          onPressed: onRetry,
          child: const Text('Coba lagi', style: TextStyle(fontSize: 13)),
        ),
      ],
    ),
  );
}

/// Loading indicator for nearby cases section.
Widget _buildNearbyLoading() {
  return const SkeletonNearbyCard();
}

/// Error state for nearby cases with retry button.
Widget _buildNearbyError(Object error, VoidCallback onRetry) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: SigapSpacing.md),
      Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          border: Border.all(color: AppColors.borderCard),
          borderRadius: BorderRadius.circular(AppRadius.x12),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: AppColors.danger, size: 24),
            const SizedBox(width: AppSpacing.x11),
            Expanded(
              child: Text(
                'Gagal memuat kasus terdekat',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: AppTypography.size13_5,
                ),
              ),
            ),
            TextButton(
              onPressed: onRetry,
              child: const Text(
                'Coba lagi',
                style: TextStyle(
                  fontSize: AppTypography.size12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

/// Skeleton loading for report list.
Widget _buildListLoading() {
  return ListView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: 3,
    itemBuilder: (_, __) => const SkeletonListItem(),
  );
}

/// Error state for report list with retry button.
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
            style: TextStyle(color: SigapColors.textSecondary, fontSize: 16),
          ),
          const SizedBox(height: SigapSpacing.sm),
          Text(
            error.toString(),
            style: TextStyle(color: SigapColors.textMuted, fontSize: 12),
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

// ─── Pending banner ─────────────────────────────────────────────────────────

class _WargaPendingBanner extends StatelessWidget {
  final int count;
  const _WargaPendingBanner({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SigapSpacing.md),
      decoration: BoxDecoration(
        color: SigapColors.offlineBg,
        border: Border.all(color: SigapColors.offlineBorder),
        borderRadius: BorderRadius.circular(SigapRadius.lg),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
              color: SigapColors.offlineDot,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$count',
              style: TextStyle(
                color: Theme.of(context).colorScheme.surface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: SigapSpacing.md),
          Expanded(
            child: Text(
              '$count laporan belum tersinkron',
              style: const TextStyle(
                color: SigapColors.offlineText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => context.push('/sync-center'),
            child: const Text(
              'Buka Pusat Sinkronisasi →',
              style: TextStyle(
                color: SigapColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Main screen ─────────────────────────────────────────────────────────────

class WargaHomeScreen extends ConsumerStatefulWidget {
  const WargaHomeScreen({super.key});

  @override
  ConsumerState<WargaHomeScreen> createState() => _WargaHomeScreenState();
}

class _WargaHomeScreenState extends ConsumerState<WargaHomeScreen> {
  Position? _currentPosition;
  int _selectedNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
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
      if (mounted) {
        setState(() {
          _currentPosition = position;
        });
      }
    } catch (e) {
      // Location unavailable, nearby reports will not load
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final localAsync = ref.watch(localReportsProvider);
    final serverAsync = ref.watch(wargaReportsProvider);
    final connectivityAsync = ref.watch(connectivityProvider);
    final pendingAsync = ref.watch(pendingCountProvider);
    final statsAsync = ref.watch(wargaStatsProvider);

    final isOffline =
        connectivityAsync.whenOrNull(
          data: (results) =>
              results.isEmpty ||
              results.every((r) => r == ConnectivityResult.none),
        ) ??
        false;

    // Build nearby reports provider if location is available
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
            KasusStatus status;
            if (statusStr.contains('verified') ||
                statusStr.contains('terverifikasi')) {
              status = KasusStatus.terverifikasi;
            } else {
              status = KasusStatus.sedangDitangani;
            }
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
                  // Find the report ID from the cases list and navigate
                  final reportId = reports
                      .firstWhere(
                        (r) => r['title']?.toString() == kasus.title,
                        orElse: () => {},
                      )['id']
                      ?.toString();
                  if (reportId != null) {
                    context.push('/detail/$reportId');
                  }
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

    return PhoneFrame(
      child: Column(
        children: [
          StatusBar(),
          Expanded(
            child: Scaffold(
              appBar: AppBar(
                title: WilayahDropdown(
                  label: 'Wilayah aktif',
                  value: authState.activeRole ?? authState.userRole ?? 'Warga',
                  onTap: () {},
                ),
                automaticallyImplyLeading: false,
                actions: [
                  // Offline badge
                  if (isOffline)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: SigapColors.offlineBg,
                        borderRadius: BorderRadius.circular(SigapRadius.md),
                        border: Border.all(color: SigapColors.offlineBorder),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.wifi_off,
                            size: 14,
                            color: SigapColors.offlineText,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Offline',
                            style: TextStyle(
                              color: SigapColors.offlineText,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  // Sync Now button
                  TextButton.icon(
                    onPressed: () {
                      ref.read(syncWorkerProvider).syncNow();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Sinkronisasi dimulai…'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.sync, size: 18),
                    label: const Text('Sync Now'),
                  ),
                  // Role switcher (only if multi-role)
                  if (authState.roles.length > 1)
                    IconButton(
                      icon: const Icon(Icons.swap_horiz),
                      tooltip: 'Ganti Peran',
                      onPressed: () => context.push('/switch-role'),
                    ),
                  IconButton(
                    onPressed: () {
                      // TODO: Navigate to notifications screen
                    },
                    icon: const NotificationBell(unreadCount: 0),
                  ),
                ],
              ),
              bottomNavigationBar: BottomNav5(
                variant: BottomNavVariant.warga,
                selectedIndex: _selectedNavIndex,
                onTap: (index) => setState(() => _selectedNavIndex = index),
              ),
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(SigapSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Welcome header
                      Text(
                        'Selamat datang, ${authState.userName ?? "Warga"}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Peran aktif: ${authState.activeRole ?? authState.userRole ?? "warga"}',
                        style: const TextStyle(
                          color: SigapColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: SigapSpacing.lg),

                      // Buat Laporan CTA
                      CtaButton(
                        label: 'Buat laporan',
                        subtitle: 'from LatLng? then...',
                        onPressed: () => context.push('/create'),
                      ),
                      const SizedBox(height: SigapSpacing.md),

                      // Pending banner
                      pendingAsync.when(
                        data: (count) => count > 0
                            ? _WargaPendingBanner(count: count)
                            : const SizedBox.shrink(),
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                      const SizedBox(height: SigapSpacing.md),

                      // Status grid
                      statsAsync.when(
                        data: (stats) {
                          final submitted = (stats['submitted'] ?? 0) as int;
                          final verified = (stats['verified'] ?? 0) as int;
                          final inProgress = (stats['in_progress'] ?? 0) as int;
                          final resolved = (stats['resolved'] ?? 0) as int;
                          return StatusGrid(
                            perluTindakan: submitted,
                            diproses: verified + inProgress,
                            selesai: resolved,
                          );
                        },
                        loading: () => _buildStatsLoading(),
                        error: (error, _) => _buildStatsError(
                          error,
                          () => ref.invalidate(wargaStatsProvider),
                        ),
                      ),

                      // Nearby cases section
                      if (nearbySection != null) nearbySection,

                      // Report list
                      Expanded(
                        child: localAsync.when(
                          loading: () => _buildListLoading(),
                          error: (e, _) => _buildListError(
                            e,
                            () => ref.invalidate(localReportsProvider),
                          ),
                          data: (localReports) {
                            return serverAsync.when(
                              loading: () => _buildListLoading(),
                              error: (e, _) => _buildListError(
                                e,
                                () => ref.invalidate(wargaReportsProvider),
                              ),
                              data: (serverReports) => _buildList(
                                context,
                                ref,
                                mergeReports(localReports, serverReports),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    WidgetRef ref,
    List<WargaReportItem> reports,
  ) {
    if (reports.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: SigapColors.textMuted),
            SizedBox(height: SigapSpacing.md),
            Text(
              'Belum ada aktivitas',
              style: TextStyle(color: SigapColors.textMuted, fontSize: 16),
            ),
          ],
        ),
      );
    }

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
        itemBuilder: (context, index) => _WargaReportListItem(
          report: reports[index],
          onTap: () => context.push('/detail/${reports[index].navKey}'),
        ),
      ),
    );
  }
}

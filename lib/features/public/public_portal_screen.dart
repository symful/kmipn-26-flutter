import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sigap/api/client.dart';
import 'package:sigap/theme/tokens.dart';
import 'package:sigap/widgets/design_system/design_system.dart';

// ============================================================================
// Public Portal Screen — P-02 Layout
// Map+list split with public header, filter bar, and responsive layout
// ============================================================================

// ─── Breakpoints (phone 392, tablet 600–1024, desktop >1024) ────────────────

const _publicBreakpointMobile = 600.0;

// ─── Status Mapping ─────────────────────────────────────────────────────────

StatusTone _mapStatusToTone(String? statusStr) {
  if (statusStr == null) return StatusTone.neutral;
  try {
    final status = ReportStatus.fromJson(statusStr);
    switch (status) {
      case ReportStatus.submitted:
      case ReportStatus.pending:
        return StatusTone.warning;
      case ReportStatus.underReview:
      case ReportStatus.needsSurvey:
      case ReportStatus.assigned:
      case ReportStatus.inProgress:
      case ReportStatus.needsCompletion:
      case ReportStatus.inReview:
      case ReportStatus.needsAction:
        return StatusTone.info;
      case ReportStatus.verified:
      case ReportStatus.resolved:
      case ReportStatus.closed:
      case ReportStatus.completed:
        return StatusTone.success;
      case ReportStatus.rejected:
      case ReportStatus.duplicateMerged:
      case ReportStatus.outOfScope:
      case ReportStatus.merged:
      case ReportStatus.separated:
      case ReportStatus.draft:
      case ReportStatus.locallyCreated:
      case ReportStatus.locallySaved:
        return StatusTone.neutral;
    }
  } catch (_) {
    return StatusTone.neutral;
  }
}

String _formatStatus(String? statusStr) {
  if (statusStr == null) return 'Unknown';
  try {
    final status = ReportStatus.fromJson(statusStr);
    switch (status) {
      case ReportStatus.submitted:
        return 'Submitted';
      case ReportStatus.underReview:
        return 'Under Review';
      case ReportStatus.verified:
        return 'Verified';
      case ReportStatus.assigned:
        return 'Assigned';
      case ReportStatus.inProgress:
        return 'In Progress';
      case ReportStatus.resolved:
        return 'Resolved';
      case ReportStatus.closed:
        return 'Closed';
      case ReportStatus.rejected:
        return 'Rejected';
      case ReportStatus.duplicateMerged:
        return 'Duplicate';
      case ReportStatus.needsSurvey:
        return 'Needs Survey';
      case ReportStatus.merged:
        return 'Merged';
      case ReportStatus.separated:
        return 'Separated';
      case ReportStatus.needsCompletion:
        return 'Needs Completion';
      case ReportStatus.outOfScope:
        return 'Out of Scope';
      case ReportStatus.pending:
        return 'Pending';
      case ReportStatus.draft:
        return 'Draft';
      case ReportStatus.locallyCreated:
        return 'Draft';
      case ReportStatus.locallySaved:
        return 'Saved Locally';
      case ReportStatus.inReview:
        return 'In Review';
      case ReportStatus.needsAction:
        return 'Needs Action';
      case ReportStatus.completed:
        return 'Completed';
    }
  } catch (_) {
    return statusStr;
  }
}

// ─── Providers ────────────────────────────────────────────────────────────────

final publicReportsProvider = FutureProvider.autoDispose<PublicReportsPage>((
  ref,
) async {
  final api = ApiClient(onLogout: () async {});
  // Use public endpoint — no auth required
  return await api.getPublicReports(limit: 100);
});

final publicGeojsonProvider =
    FutureProvider.autoDispose<GeoJSONFeatureCollection>((ref) async {
      final filters = ref.watch(publicFiltersProvider);
      final api = ApiClient(onLogout: () async {});
      return await api.getMapGeoJson(wilayah: filters.wilayahId);
    });

final publicViewModeProvider = StateProvider<bool>((ref) => false);
// true = list-only, false = map+list split

// ─── Filter State ─────────────────────────────────────────────────────────────

class PublicFilters {
  final String? categoryId;
  final String? wilayahId;
  final ReportStatus? status;
  final DateTime? startDate;
  final DateTime? endDate;

  const PublicFilters({
    this.categoryId,
    this.wilayahId,
    this.status,
    this.startDate,
    this.endDate,
  });

  PublicFilters copyWith({
    String? categoryId,
    String? wilayahId,
    ReportStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    bool clearWilayah = false,
    bool clearDates = false,
  }) {
    return PublicFilters(
      categoryId: categoryId ?? this.categoryId,
      wilayahId: clearWilayah ? null : (wilayahId ?? this.wilayahId),
      status: status ?? this.status,
      startDate: clearDates ? null : (startDate ?? this.startDate),
      endDate: clearDates ? null : (endDate ?? this.endDate),
    );
  }

  bool get isActive =>
      categoryId != null ||
      wilayahId != null ||
      status != null ||
      startDate != null ||
      endDate != null;
}

final publicFiltersProvider = StateProvider<PublicFilters>((ref) {
  return const PublicFilters();
});

// ─── Wilayah Provider ─────────────────────────────────────────────────────────

final publicWilayahListProvider = FutureProvider.autoDispose<List<String>>((
  ref,
) async {
  final api = ApiClient(onLogout: () async {});
  final geojson = await api.getMapGeoJson();
  final wilayahSet = <String>{};
  for (final feature in geojson.features ?? []) {
    final props = feature.properties;
    if (props != null) {
      // Try various keys that might contain wilayah name
      final wilayah =
          props['wilayah']?.toString() ??
          props['kecamatan']?.toString() ??
          props['desa']?.toString();
      if (wilayah != null && wilayah.isNotEmpty) {
        wilayahSet.add(wilayah);
      }
    }
  }
  final list = wilayahSet.toList()..sort();
  return list;
});

// ─── Public Portal Screen ────────────────────────────────────────────────────

class PublicPortalScreen extends ConsumerWidget {
  const PublicPortalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: SigapColors.bgSurface,
      appBar: const _PublicAppBar(),
      body: Column(
        children: [
          const _FilterBar(),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < _publicBreakpointMobile;
                final showListOnly =
                    isMobile || ref.watch(publicViewModeProvider);

                if (showListOnly) {
                  return const _ReportsList();
                }
                return const _MapListSplit();
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Public App Bar ──────────────────────────────────────────────────────────

class _PublicAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _PublicAppBar();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return SigapAppBar(
      title: 'Portal Publik',
      showSync: true,
      syncState: SyncState.online,
      leading: Padding(
        padding: const EdgeInsets.only(left: SigapSpacing.md),
        child: Center(
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: SigapColors.primary,
              borderRadius: BorderRadius.circular(SigapRadius.x6),
            ),
            child: const Icon(Icons.map, color: Colors.white, size: 18),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () {}, child: const Text('Beranda')),
        TextButton(onPressed: () {}, child: const Text('Peta')),
        TextButton(onPressed: () {}, child: const Text('Statistik')),
        const SizedBox(width: SigapSpacing.sm),
        ElevatedButton(
          onPressed: () => GoRouter.of(context).push('/create-anonymous'),
          style: ElevatedButton.styleFrom(
            backgroundColor: SigapColors.primary,
            foregroundColor: Colors.white,
          ),
          child: const Text('Buat Laporan'),
        ),
        const SizedBox(width: SigapSpacing.sm),
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            foregroundColor: SigapColors.primary,
            side: const BorderSide(color: SigapColors.primary),
          ),
          child: const Text('Masuk'),
        ),
        const SizedBox(width: SigapSpacing.sm),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: SigapColors.primary,
            foregroundColor: Colors.white,
          ),
          child: const Text('Daftar'),
        ),
        const SizedBox(width: SigapSpacing.md),
      ],
    );
  }
}

// ─── Filter Bar ───────────────────────────────────────────────────────────────

class _FilterBar extends ConsumerWidget {
  const _FilterBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(publicFiltersProvider);
    final viewMode = ref.watch(publicViewModeProvider);
    final reportsAsync = ref.watch(publicReportsProvider);
    final wilayahListAsync = ref.watch(publicWilayahListProvider);

    final count = reportsAsync.maybeWhen(
      data: (page) => page.total,
      orElse: () => 0,
    );

    final wilayahList = wilayahListAsync.maybeWhen(
      data: (list) => list,
      orElse: () => <String>[],
    );

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SigapSpacing.lg,
        vertical: SigapSpacing.md,
      ),
      decoration: const BoxDecoration(
        color: SigapColors.surface,
        border: Border(bottom: BorderSide(color: SigapColors.border)),
      ),
      child: Wrap(
        spacing: SigapSpacing.md,
        runSpacing: SigapSpacing.sm,
        children: [
          // Category dropdown
          _FilterDropdown(
            label: 'Kategori',
            value: filters.categoryId,
            items: const ['road', 'bridge', 'drainage', 'public'],
            onChanged: (value) {
              ref.read(publicFiltersProvider.notifier).state = filters.copyWith(
                categoryId: value,
              );
            },
          ),
          // Status dropdown
          _FilterDropdown(
            label: 'Status',
            value: filters.status?.value,
            items: ReportStatus.allValues.map((s) => s.value).toList(),
            onChanged: (value) {
              if (value != null) {
                ref.read(publicFiltersProvider.notifier).state = filters
                    .copyWith(status: ReportStatus.fromJson(value));
              }
            },
          ),
          // Wilayah dropdown
          if (wilayahList.isNotEmpty)
            _FilterDropdown(
              label: 'Wilayah',
              value: filters.wilayahId,
              items: wilayahList,
              onChanged: (value) {
                ref.read(publicFiltersProvider.notifier).state = filters
                    .copyWith(wilayahId: value);
              },
            ),
          // Date filter button
          _DateFilterButton(
            startDate: filters.startDate,
            endDate: filters.endDate,
            onTap: () => _showDateRangePicker(context, ref, filters),
          ),
          // Active filters chips
          if (filters.isActive) ...[
            if (filters.categoryId != null)
              _FilterChip(
                label: _formatDropdownItem(filters.categoryId!),
                onRemove: () {
                  ref.read(publicFiltersProvider.notifier).state = filters
                      .copyWith(categoryId: null);
                },
              ),
            if (filters.wilayahId != null)
              _FilterChip(
                label: filters.wilayahId!,
                onRemove: () {
                  ref.read(publicFiltersProvider.notifier).state = filters
                      .copyWith(clearWilayah: true);
                },
              ),
            if (filters.startDate != null || filters.endDate != null)
              _FilterChip(
                label: _formatDateRange(filters.startDate, filters.endDate),
                onRemove: () {
                  ref.read(publicFiltersProvider.notifier).state = filters
                      .copyWith(clearDates: true);
                },
              ),
          ],
          // Count text
          Text(
            '$count laporan',
            style: const TextStyle(
              fontSize: SigapTypography.size13,
              color: SigapColors.textSecondary,
            ),
          ),
          // Map/List toggle
          _ViewToggle(
            isListOnly: viewMode,
            onToggle: () {
              ref.read(publicViewModeProvider.notifier).state = !viewMode;
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showDateRangePicker(
    BuildContext context,
    WidgetRef ref,
    PublicFilters filters,
  ) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialDateRange: filters.startDate != null && filters.endDate != null
          ? DateTimeRange(start: filters.startDate!, end: filters.endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: SigapColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: SigapColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      ref.read(publicFiltersProvider.notifier).state = filters.copyWith(
        startDate: picked.start,
        endDate: picked.end,
      );
    }
  }

  String _formatDateRange(DateTime? start, DateTime? end) {
    if (start == null && end == null) return 'Tanggal';
    final startStr = start != null
        ? '${start.day}/${start.month}/${start.year}'
        : '-';
    final endStr = end != null ? '${end.day}/${end.month}/${end.year}' : '-';
    return '$startStr - $endStr';
  }

  String _formatDropdownItem(String item) {
    switch (item) {
      case 'road':
        return 'Jalan Rusak';
      case 'bridge':
        return 'Jembatan';
      case 'drainage':
        return 'Drainase';
      case 'public':
        return 'Fasilitas Umum';
      default:
        return item;
    }
  }
}

class _DateFilterButton extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final VoidCallback onTap;

  const _DateFilterButton({this.startDate, this.endDate, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasDateFilter = startDate != null || endDate != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: SigapSpacing.md,
          vertical: SigapSpacing.x4,
        ),
        decoration: BoxDecoration(
          color: hasDateFilter ? SigapColors.primaryLight : SigapColors.surface,
          borderRadius: BorderRadius.circular(SigapRadius.sm),
          border: Border.all(color: SigapColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 16,
              color: hasDateFilter
                  ? SigapColors.primaryDark
                  : SigapColors.textSecondary,
            ),
            const SizedBox(width: SigapSpacing.x4),
            Text(
              hasDateFilter ? _formatDateRange() : 'Tanggal',
              style: TextStyle(
                fontSize: SigapTypography.size13,
                color: hasDateFilter
                    ? SigapColors.primaryDark
                    : SigapColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateRange() {
    if (startDate == null && endDate == null) return 'Tanggal';
    final startStr = startDate != null
        ? '${startDate!.day}/${startDate!.month}'
        : '-';
    final endStr = endDate != null ? '${endDate!.day}/${endDate!.month}' : '-';
    return '$startStr - $endStr';
  }
}

class _FilterDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _FilterDropdown({
    required this.label,
    this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SigapSpacing.md,
        vertical: SigapSpacing.x4,
      ),
      decoration: BoxDecoration(
        color: SigapColors.surface,
        borderRadius: BorderRadius.circular(SigapRadius.sm),
        border: Border.all(color: SigapColors.border),
      ),
      child: DropdownButton<String>(
        value: value,
        hint: Text(
          label,
          style: const TextStyle(
            fontSize: SigapTypography.size13,
            color: SigapColors.textSecondary,
          ),
        ),
        underline: const SizedBox(),
        isDense: true,
        items: [
          DropdownMenuItem<String>(
            value: null,
            child: Text(
              'Semua $label',
              style: const TextStyle(fontSize: SigapTypography.size13),
            ),
          ),
          ...items.map(
            (item) => DropdownMenuItem<String>(
              value: item,
              child: Text(
                _formatDropdownItem(item),
                style: const TextStyle(fontSize: SigapTypography.size13),
              ),
            ),
          ),
        ],
        onChanged: onChanged,
      ),
    );
  }

  String _formatDropdownItem(String item) {
    switch (item) {
      case 'road':
        return 'Jalan Rusak';
      case 'bridge':
        return 'Jembatan';
      case 'drainage':
        return 'Drainase';
      case 'public':
        return 'Fasilitas Umum';
      default:
        return item;
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _FilterChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SigapSpacing.sm,
        vertical: SigapSpacing.x4,
      ),
      decoration: BoxDecoration(
        color: SigapColors.primaryLight,
        borderRadius: BorderRadius.circular(SigapRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: SigapTypography.size11,
              color: SigapColors.primaryDark,
            ),
          ),
          const SizedBox(width: SigapSpacing.x4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.close,
              size: 14,
              color: SigapColors.primaryDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _ViewToggle extends StatelessWidget {
  final bool isListOnly;
  final VoidCallback onToggle;

  const _ViewToggle({required this.isListOnly, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: SigapColors.border),
        borderRadius: BorderRadius.circular(SigapRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleButton(
            icon: Icons.list,
            isActive: isListOnly,
            onTap: onToggle,
          ),
          _ToggleButton(
            icon: Icons.map,
            isActive: !isListOnly,
            onTap: onToggle,
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(SigapSpacing.sm),
        decoration: BoxDecoration(
          color: isActive ? SigapColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(SigapRadius.x4),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isActive ? Colors.white : SigapColors.textSecondary,
        ),
      ),
    );
  }
}

// ─── Map + List Split ────────────────────────────────────────────────────────

class _MapListSplit extends StatelessWidget {
  const _MapListSplit();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Map area (flex: 1)
        const Expanded(child: _PublicMap()),
        // Vertical divider
        Container(width: 1, color: SigapColors.border),
        // List panel (400px fixed)
        Container(
          width: 400,
          color: SigapColors.bgSurface,
          child: const _ReportsList(),
        ),
      ],
    );
  }
}

// ─── Public Map ──────────────────────────────────────────────────────────────

class _PublicMap extends ConsumerWidget {
  const _PublicMap();

  static const _indonesiaCenter = LatLng(-2.548926, 118.0148634);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final geojsonAsync = ref.watch(publicGeojsonProvider);

    return geojsonAsync.when(
      data: (geojson) {
        return FlutterMap(
          options: const MapOptions(
            initialCenter: _indonesiaCenter,
            initialZoom: 5.0,
            minZoom: 3.5,
            maxZoom: 18.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'id.kmipn.sigap',
            ),
            // Note: GeoJSON markers would be rendered here
            // Using a simple marker placeholder for now
            MarkerLayer(
              markers: [
                Marker(
                  point: _indonesiaCenter,
                  width: 40,
                  height: 40,
                  child: Icon(
                    Icons.location_on,
                    color: SigapColors.primary,
                    size: 36,
                  ),
                ),
              ],
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => ErrorRetryView(
        message: 'Gagal memuat peta',
        onRetry: () => ref.invalidate(publicGeojsonProvider),
      ),
    );
  }
}

// ─── Reports List ─────────────────────────────────────────────────────────────

class _ReportsList extends ConsumerWidget {
  const _ReportsList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(publicReportsProvider);
    final filters = ref.watch(publicFiltersProvider);

    return reportsAsync.when(
      data: (page) {
        final items = _filterReports(page.items, filters);

        if (items.isEmpty) {
          return EmptyState(
            icon: Icons.inbox_outlined,
            title: 'Belum Ada Laporan',
            subtitle: 'Tidak ada laporan yang sesuai dengan filter',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(SigapSpacing.md),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: SigapSpacing.md),
              child: _ReportCard(item: item),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => ErrorRetryView(
        message: 'Gagal memuat laporan',
        onRetry: () => ref.invalidate(publicReportsProvider),
      ),
    );
  }

  List<PublicReportItem> _filterReports(
    List<PublicReportItem> items,
    PublicFilters filters,
  ) {
    return items.where((item) {
      if (filters.categoryId != null &&
          item.category?.id != filters.categoryId) {
        return false;
      }
      if (filters.status != null && item.status != filters.status?.value) {
        return false;
      }
      // Wilayah filter - match against either desa or kecamatan
      if (filters.wilayahId != null) {
        final wilayahMatch =
            item.wilayah?.desa == filters.wilayahId ||
            item.wilayah?.kecamatan == filters.wilayahId;
        if (!wilayahMatch) return false;
      }
      // Date range filter using lastUpdated
      if (filters.startDate != null && item.lastUpdated != null) {
        try {
          final itemDate = DateTime.parse(item.lastUpdated!);
          if (itemDate.isBefore(filters.startDate!)) return false;
        } catch (_) {}
      }
      if (filters.endDate != null && item.lastUpdated != null) {
        try {
          final itemDate = DateTime.parse(item.lastUpdated!);
          // Add one day to endDate to include the full day
          final endOfDay = filters.endDate!.add(const Duration(days: 1));
          if (itemDate.isAfter(endOfDay)) return false;
        } catch (_) {}
      }
      return true;
    }).toList();
  }
}

// ─── Report Card ─────────────────────────────────────────────────────────────

class _ReportCard extends ConsumerWidget {
  final PublicReportItem item;

  const _ReportCard({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusStr = item.status;
    final tone = _mapStatusToTone(statusStr);
    final statusLabel = _formatStatus(statusStr);

    return GestureDetector(
      onTap: () => _showCaseDetailSheet(context, ref),
      child: SigapCard(
        borderLeftColor: _getToneColor(tone),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category and status row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(SigapSpacing.sm),
                  decoration: BoxDecoration(
                    color: SigapColors.primaryLight,
                    borderRadius: BorderRadius.circular(SigapRadius.sm),
                  ),
                  child: Icon(
                    _getCategoryIcon(item.category?.id),
                    size: 20,
                    color: SigapColors.primary,
                  ),
                ),
                const SizedBox(width: SigapSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.category?.name ?? 'Unknown',
                        style: const TextStyle(
                          fontSize: SigapTypography.size14,
                          fontWeight: FontWeight.w600,
                          color: SigapColors.textPrimary,
                        ),
                      ),
                      if (item.wilayah?.desa != null ||
                          item.wilayah?.kecamatan != null)
                        Text(
                          '${item.wilayah?.desa ?? ''}, ${item.wilayah?.kecamatan ?? ''}',
                          style: const TextStyle(
                            fontSize: SigapTypography.size11,
                            color: SigapColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                StatusPill(label: statusLabel, tone: tone),
              ],
            ),
            const SizedBox(height: SigapSpacing.md),
            // Progress bar
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(SigapRadius.x4),
                    child: LinearProgressIndicator(
                      value: item.publicProgress / 100,
                      backgroundColor: SigapColors.border,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        SigapColors.primary,
                      ),
                      minHeight: 4,
                    ),
                  ),
                ),
                const SizedBox(width: SigapSpacing.sm),
                Text(
                  '${item.publicProgress}%',
                  style: const TextStyle(
                    fontSize: SigapTypography.size11,
                    color: SigapColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: SigapSpacing.md),
            // Meta row
            Row(
              children: [
                Icon(
                  Icons.people_outline,
                  size: 14,
                  color: SigapColors.textMuted,
                ),
                const SizedBox(width: SigapSpacing.x4),
                Text(
                  '${item.supportingCount} mendukung',
                  style: const TextStyle(
                    fontSize: SigapTypography.size11,
                    color: SigapColors.textMuted,
                  ),
                ),
                const Spacer(),
                if (item.lastUpdated != null)
                  Text(
                    _formatDate(item.lastUpdated!),
                    style: const TextStyle(
                      fontSize: SigapTypography.size11,
                      color: SigapColors.textMuted,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCaseDetailSheet(BuildContext context, WidgetRef ref) async {
    final caseId = item.id;
    if (caseId == null) return;

    // Fetch share metadata
    ShareMetadata? shareMeta;
    try {
      final api = ApiClient(onLogout: () async {});
      shareMeta = await api.getShareMetadata(caseId);
    } catch (_) {
      // Ignore share meta errors
    }

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(SigapSpacing.lg),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.category?.name ?? 'Detail Laporan',
                      style: const TextStyle(
                        fontSize: SigapTypography.size19,
                        fontWeight: FontWeight.w700,
                        color: SigapColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.share_outlined,
                      color: SigapColors.textSecondary,
                    ),
                    onPressed: () => _onShare(ctx, shareMeta, caseId),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(SigapSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DetailRow(
                      label: 'Status',
                      value: _formatStatus(item.status),
                    ),
                    _DetailRow(
                      label: 'Wilayah',
                      value: item.wilayah != null
                          ? '${item.wilayah?.desa ?? ''}, ${item.wilayah?.kecamatan ?? ''}'
                          : '-',
                    ),
                    _DetailRow(
                      label: 'Progres',
                      value: '${item.publicProgress}%',
                    ),
                    _DetailRow(
                      label: 'Dukungan',
                      value: '${item.supportingCount} orang',
                    ),
                    if (item.lastUpdated != null)
                      _DetailRow(
                        label: 'Terakhir Diperbarui',
                        value: _formatDate(item.lastUpdated!),
                      ),
                    if (shareMeta?.description != null) ...[
                      const SizedBox(height: SigapSpacing.md),
                      Text(
                        shareMeta!.description!,
                        style: const TextStyle(
                          fontSize: SigapTypography.size13,
                          color: SigapColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onShare(
    BuildContext context,
    ShareMetadata? shareMeta,
    String caseId,
  ) async {
    final shareUrl =
        shareMeta?.url ?? 'https://sigap.live/public/cases/$caseId';
    final shareText = shareMeta?.title != null && shareMeta?.description != null
        ? '${shareMeta!.title}\n\n${shareMeta.description}\n\n$shareUrl'
        : shareUrl;
    await Share.share(shareText, subject: shareMeta?.title);
  }

  Color _getToneColor(StatusTone tone) {
    switch (tone) {
      case StatusTone.success:
        return SigapColors.success;
      case StatusTone.warning:
        return SigapColors.warning;
      case StatusTone.danger:
        return SigapColors.danger;
      case StatusTone.info:
        return SigapColors.info;
      case StatusTone.neutral:
        return SigapColors.textMuted;
    }
  }

  IconData _getCategoryIcon(String? categoryId) {
    switch (categoryId) {
      case 'road':
        return Icons.edit_road;
      case 'bridge':
        return Icons.architecture;
      case 'drainage':
        return Icons.water_drop;
      case 'public':
        return Icons.location_city;
      default:
        return Icons.report;
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inDays > 30) {
        return '${date.day}/${date.month}/${date.year}';
      } else if (diff.inDays > 0) {
        return '${diff.inDays} hari lalu';
      } else if (diff.inHours > 0) {
        return '${diff.inHours} jam lalu';
      } else {
        return 'Baru saja';
      }
    } catch (_) {
      return dateStr;
    }
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: SigapSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: SigapTypography.size13,
                color: SigapColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: SigapTypography.size13,
                fontWeight: FontWeight.w600,
                color: SigapColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

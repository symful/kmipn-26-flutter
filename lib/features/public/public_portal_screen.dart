import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:sigap/api/api_client.dart';
import 'package:sigap/api/types.g.dart';
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
        return StatusTone.info;
      case ReportStatus.verified:
      case ReportStatus.resolved:
      case ReportStatus.closed:
        return StatusTone.success;
      case ReportStatus.rejected:
      case ReportStatus.duplicateMerged:
      case ReportStatus.outOfScope:
      case ReportStatus.merged:
      case ReportStatus.separated:
      case ReportStatus.draft:
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
  return await api.getPublicReports();
});

final publicGeojsonProvider =
    FutureProvider.autoDispose<GeoJSONFeatureCollection>((ref) async {
      final api = ApiClient(onLogout: () async {});
      return await api.getPublicGeojson();
    });

final publicViewModeProvider = StateProvider<bool>((ref) => false);
// true = list-only, false = map+list split

// ─── Filter State ─────────────────────────────────────────────────────────────

class PublicFilters {
  final String? categoryId;
  final String? wilayahId;
  final ReportStatus? status;

  const PublicFilters({this.categoryId, this.wilayahId, this.status});

  PublicFilters copyWith({
    String? categoryId,
    String? wilayahId,
    ReportStatus? status,
  }) {
    return PublicFilters(
      categoryId: categoryId ?? this.categoryId,
      wilayahId: wilayahId ?? this.wilayahId,
      status: status ?? this.status,
    );
  }

  bool get isActive =>
      categoryId != null || wilayahId != null || status != null;
}

final publicFiltersProvider = StateProvider<PublicFilters>((ref) {
  return const PublicFilters();
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

    final count = reportsAsync.maybeWhen(
      data: (page) => page.total,
      orElse: () => 0,
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
      child: Row(
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
          const SizedBox(width: SigapSpacing.md),
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
          const SizedBox(width: SigapSpacing.md),
          // Active filters chips
          if (filters.isActive) ...[
            _FilterChip(
              label: filters.categoryId ?? 'Unknown',
              onRemove: () {
                ref.read(publicFiltersProvider.notifier).state = PublicFilters(
                  status: filters.status,
                );
              },
            ),
            const SizedBox(width: SigapSpacing.sm),
          ],
          const Spacer(),
          // Count text
          Text(
            '$count laporan',
            style: const TextStyle(
              fontSize: SigapTypography.size13,
              color: SigapColors.textSecondary,
            ),
          ),
          const SizedBox(width: SigapSpacing.md),
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
      return true;
    }).toList();
  }
}

// ─── Report Card ─────────────────────────────────────────────────────────────

class _ReportCard extends StatelessWidget {
  final PublicReportItem item;

  const _ReportCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final statusStr = item.status;
    final tone = _mapStatusToTone(statusStr);
    final statusLabel = _formatStatus(statusStr);

    return SigapCard(
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
    );
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

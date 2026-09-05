import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sigap/api/client.dart';
import 'package:sigap/config/map_constants.dart';
import 'package:sigap/l10n/generated/app_localizations.dart';
import 'package:sigap/l10n/status_label.dart';
import 'package:sigap/providers/providers.dart';
import 'package:sigap/theme/tokens.dart';
import 'package:sigap/features/map/report_map_widget.dart';
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

String _formatStatus(BuildContext context, String? statusStr) {
  return statusLabel(context, statusStr);
}

// ─── Providers ────────────────────────────────────────────────────────────────

final publicReportsProvider = FutureProvider.autoDispose<PublicReportsPage>((
  ref,
) async {
  final api = ref.read(publicApiClientProvider);
  // Use public endpoint — no auth required
  return await api.getPublicReports(limit: 100);
});

final publicGeojsonProvider =
    FutureProvider.autoDispose<GeoJSONFeatureCollection>((ref) async {
      final filters = ref.watch(publicFiltersProvider);
      final api = ref.read(publicApiClientProvider);
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
  final api = ref.read(publicApiClientProvider);
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
    return ResponsiveScaffold(
      appBar: const _PublicAppBar(),
      body: Column(
        children: [
          const _FilterBar(),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final showListOnly = ref.watch(publicViewModeProvider);

                if (showListOnly) {
                  return const _ReportsList();
                }
                final isMobile = constraints.maxWidth < _publicBreakpointMobile;
                if (isMobile) {
                  return const _MobileMapListStack();
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

class _PublicAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const _PublicAppBar();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return SigapAppBar(
      title: l10n.portalPublik,
      showSync: true,
      syncState: SyncState.online,
      trailing: Padding(
        padding: const EdgeInsets.only(right: SigapSpacing.md),
        child: Center(
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: SigapColors.primary,
              borderRadius: BorderRadius.circular(SigapRadius.x6),
            ),
            child: const Icon(Icons.map, color: SigapColors.surface, size: 18),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, size: 20),
          tooltip: l10n.cobaLagi,
          onPressed: () {
            ref.invalidate(publicReportsProvider);
            ref.invalidate(publicGeojsonProvider);
          },
        ),
        const SizedBox(width: SigapSpacing.sm),
        TextButton(
          onPressed: () => context.push('/public-statistics'),
          child: Text(l10n.statistik),
        ),
        const SizedBox(width: SigapSpacing.sm),
        ElevatedButton(
          onPressed: () => context.push('/create-anonymous'),
          style: ElevatedButton.styleFrom(
            backgroundColor: SigapColors.primary,
            foregroundColor: SigapColors.surface,
          ),
          child: Text(l10n.buatLaporan),
        ),
        const SizedBox(width: SigapSpacing.sm),
        OutlinedButton(
          onPressed: () => context.push('/login'),
          style: OutlinedButton.styleFrom(
            foregroundColor: SigapColors.primary,
            side: const BorderSide(color: SigapColors.primary),
          ),
          child: Text(l10n.masuk),
        ),
        const SizedBox(width: SigapSpacing.sm),
        ElevatedButton(
          onPressed: () => context.push('/register'),
          style: ElevatedButton.styleFrom(
            backgroundColor: SigapColors.primary,
            foregroundColor: SigapColors.surface,
          ),
          child: Text(l10n.daftar),
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
    final l10n = AppLocalizations.of(context)!;

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
            label: l10n.kategori,
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
            label: l10n.status,
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
              label: l10n.wilayah,
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
                label: _formatDropdownItem(context, filters.categoryId!),
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
                label: _formatDateRange(
                  context,
                  filters.startDate,
                  filters.endDate,
                ),
                onRemove: () {
                  ref.read(publicFiltersProvider.notifier).state = filters
                      .copyWith(clearDates: true);
                },
              ),
          ],
          // Count text
          Text(
            l10n.laporanCountLabel(count),
            style: const TextStyle(
              fontSize: SigapTypography.bodyText,
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
              onPrimary: SigapColors.surface,
              surface: SigapColors.surface,
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

  String _formatDateRange(
    BuildContext context,
    DateTime? start,
    DateTime? end,
  ) {
    if (start == null && end == null) {
      return AppLocalizations.of(context)!.tanggal;
    }
    final startStr = start != null
        ? '${start.day}/${start.month}/${start.year}'
        : '-';
    final endStr = end != null ? '${end.day}/${end.month}/${end.year}' : '-';
    return '$startStr - $endStr';
  }

  String _formatDropdownItem(BuildContext context, String item) {
    final l10n = AppLocalizations.of(context)!;
    switch (item) {
      case 'road':
        return l10n.jalanRusak;
      case 'bridge':
        return l10n.jembatan;
      case 'drainage':
        return l10n.drainase;
      case 'public':
        return l10n.fasilitasUmum;
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
    final l10n = AppLocalizations.of(context)!;
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
              hasDateFilter ? _formatDateRange(context) : l10n.tanggal,
              style: TextStyle(
                fontSize: SigapTypography.bodyText,
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

  String _formatDateRange(BuildContext context) {
    if (startDate == null && endDate == null) {
      return AppLocalizations.of(context)!.tanggal;
    }
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
            fontSize: SigapTypography.bodyText,
            color: SigapColors.textSecondary,
          ),
        ),
        underline: const SizedBox(),
        isDense: true,
        items: [
          DropdownMenuItem<String>(
            value: null,
            child: Text(
              AppLocalizations.of(context)!.semuaLabel(label),
              style: const TextStyle(fontSize: SigapTypography.bodyText),
            ),
          ),
          ...items.map(
            (item) => DropdownMenuItem<String>(
              value: item,
              child: Text(
                _formatDropdownItem(context, item),
                style: const TextStyle(fontSize: SigapTypography.bodyText),
              ),
            ),
          ),
        ],
        onChanged: onChanged,
      ),
    );
  }

  String _formatDropdownItem(BuildContext context, String item) {
    final l10n = AppLocalizations.of(context)!;
    switch (item) {
      case 'road':
        return l10n.jalanRusak;
      case 'bridge':
        return l10n.jembatan;
      case 'drainage':
        return l10n.drainase;
      case 'public':
        return l10n.fasilitasUmum;
      default:
        return statusLabel(context, item);
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
              fontSize: SigapTypography.captionMedium,
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
          color: isActive ? SigapColors.surface : SigapColors.textSecondary,
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

/// Mobile layout: map on top (40% height), list below (60% height).
class _MobileMapListStack extends StatelessWidget {
  const _MobileMapListStack();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Map — takes 40% of available height
        const Expanded(flex: 4, child: _PublicMap()),
        // Divider
        Container(height: 1, color: SigapColors.border),
        // List — takes 60% of available height
        const Expanded(flex: 6, child: _ReportsList()),
      ],
    );
  }
}

// ─── Public Map ──────────────────────────────────────────────────────────────

class _PublicMap extends ConsumerWidget {
  const _PublicMap();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final geojsonAsync = ref.watch(publicGeojsonProvider);

    return geojsonAsync.when(
      data: (geojson) {
        final markers = (geojson.features ?? [])
            .map((f) => ReportMapMarker.fromGeoJSONFeature(f))
            .where((m) => m.point.latitude != 0 || m.point.longitude != 0)
            .toList();
        return ReportMapWidget(markers: markers, interactive: true);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) {
        final l10n = AppLocalizations.of(context)!;
        return ErrorRetryView(
          message: l10n.gagalMemuatPeta,
          onRetry: () => ref.invalidate(publicGeojsonProvider),
        );
      },
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
          final l10n = AppLocalizations.of(context)!;
          return EmptyState(
            icon: Icons.inbox_outlined,
            title: l10n.belumAdaLaporan,
            subtitle: l10n.tidakAdaLaporanSesuaiFilter,
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
      error: (e, _) {
        final l10n = AppLocalizations.of(context)!;
        return ErrorRetryView(
          message: l10n.gagalMemuatLaporan,
          onRetry: () => ref.invalidate(publicReportsProvider),
        );
      },
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
    final l10n = AppLocalizations.of(context)!;
    final statusStr = item.status;
    final tone = _mapStatusToTone(statusStr);
    final statusLabel = _formatStatus(context, statusStr);

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
                          fontSize: SigapTypography.bodyMedium,
                          fontWeight: FontWeight.w600,
                          color: SigapColors.textPrimary,
                        ),
                      ),
                      if (item.wilayah?.desa != null ||
                          item.wilayah?.kecamatan != null)
                        Text(
                          '${item.wilayah?.desa ?? ''}, ${item.wilayah?.kecamatan ?? ''}',
                          style: const TextStyle(
                            fontSize: SigapTypography.captionMedium,
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
                    fontSize: SigapTypography.captionMedium,
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
                  '${item.supportingCount} ${l10n.mendukung}',
                  style: const TextStyle(
                    fontSize: SigapTypography.captionMedium,
                    color: SigapColors.textMuted,
                  ),
                ),
                const Spacer(),
                if (item.lastUpdated != null)
                  Text(
                    _formatDate(context, item.lastUpdated!),
                    style: const TextStyle(
                      fontSize: SigapTypography.captionMedium,
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
      final api = ref.read(publicApiClientProvider);
      shareMeta = await api.getShareMetadata(caseId);
    } catch (_) {
      // Ignore share meta errors
    }

    if (!context.mounted) return;
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: SigapColors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(SigapRadius.x16),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: SigapSpacing.x12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: SigapColors.border,
                borderRadius: BorderRadius.circular(SigapRadius.x2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(SigapSpacing.lg),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.category?.name ?? l10n.detailLaporan,
                      style: const TextStyle(
                        fontSize: SigapTypography.sectionTitle,
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
                      label: l10n.status,
                      value: _formatStatus(context, item.status),
                    ),
                    _DetailRow(
                      label: l10n.wilayah,
                      value: item.wilayah != null
                          ? '${item.wilayah?.desa ?? ''}, ${item.wilayah?.kecamatan ?? ''}'
                          : '-',
                    ),
                    _DetailRow(
                      label: l10n.labelProgres,
                      value: '${item.publicProgress}%',
                    ),
                    _DetailRow(
                      label: l10n.labelDukungan,
                      value: '${item.supportingCount} orang',
                    ),
                    if (item.lastUpdated != null)
                      _DetailRow(
                        label: l10n.labelTerakhirDiperbarui,
                        value: _formatDate(context, item.lastUpdated!),
                      ),
                    if (shareMeta?.description != null) ...[
                      const SizedBox(height: SigapSpacing.md),
                      Text(
                        shareMeta!.description!,
                        style: const TextStyle(
                          fontSize: SigapTypography.bodyText,
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

  String _formatDate(BuildContext context, String dateStr) {
    final l10n = AppLocalizations.of(context)!;
    try {
      final date = DateTime.parse(dateStr).toLocal();
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inDays > 30) {
        return '${date.day}/${date.month}/${date.year}';
      } else if (diff.inDays > 0) {
        return '${diff.inDays} ${l10n.hariLalu}';
      } else if (diff.inHours > 0) {
        return '${diff.inHours} ${l10n.jamLalu}';
      } else {
        return l10n.baruSaja;
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
                fontSize: SigapTypography.bodyText,
                color: SigapColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: SigapTypography.bodyText,
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

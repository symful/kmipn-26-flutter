import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../config/map_constants.dart';
import '../../db/database.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/tokens.dart';
import '../../providers/providers.dart';
import '../../api/client.dart';
import '../../utils/logger.dart';
import '../../widgets/design_system/design_system.dart';
import 'report_map_widget.dart';

final _logger = Logger('MapScreen');

// ─── Filter State ─────────────────────────────────────────────────────────────

class MapFilters {
  final Set<String> categories;
  final Set<ReportStatus> statuses;
  final DateTime? startDate;
  final DateTime? endDate;

  const MapFilters({
    this.categories = const {},
    this.statuses = const {},
    this.startDate,
    this.endDate,
  });

  MapFilters copyWith({
    Set<String>? categories,
    Set<ReportStatus>? statuses,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return MapFilters(
      categories: categories ?? this.categories,
      statuses: statuses ?? this.statuses,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  bool get isActive =>
      categories.isNotEmpty ||
      statuses.isNotEmpty ||
      startDate != null ||
      endDate != null;
}

// ─── Providers ────────────────────────────────────────────────────────────────

final mapFiltersProvider = StateProvider<MapFilters>(
  (ref) => const MapFilters(),
);

final heatmapEnabledProvider = StateProvider<bool>((ref) => false);

final geoJsonReportsProvider = FutureProvider<GeoJSONFeatureCollection>((
  ref,
) async {
  final api = ref.read(apiClientProvider);
  return await api.getMapGeoJson();
});

final deviceLocationProvider = FutureProvider<LatLng?>((ref) async {
  try {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 10),
      ),
    );
    return LatLng(position.latitude, position.longitude);
  } catch (e, s) {
    _logger.warning('Error getting current location', e, s);
    rethrow; // Preserve error so .when(error:) is triggered
  }
});

// ─── Map Screen ───────────────────────────────────────────────────────────────

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final MapController _mapController = MapController();

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _FilterBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final reportsAsync = ref.watch(localReportsProvider);
    final filters = ref.watch(mapFiltersProvider);
    final heatmapEnabled = ref.watch(heatmapEnabledProvider);
    final deviceLocationAsync = ref.watch(deviceLocationProvider);

    // Show location prompt when device location is unavailable
    final showLocationPrompt =
        deviceLocationAsync.hasError ||
        (deviceLocationAsync.value == null && !deviceLocationAsync.isLoading);

    return ResponsiveScaffold(
      appBar: AppBar(
        title: Text(l10n.petaLaporan),
        actions: [
          MinTapTarget(
            semanticsLabel: l10n.heatmap,
            child: IconButton(
              icon: Icon(heatmapEnabled ? Icons.layers : Icons.layers_outlined),
              tooltip: l10n.heatmap,
              onPressed: () {
                ref.read(heatmapEnabledProvider.notifier).state =
                    !heatmapEnabled;
              },
            ),
          ),
          MinTapTarget(
            semanticsLabel: l10n.filter,
            child: IconButton(
              icon: Badge(
                isLabelVisible: filters.isActive,
                child: const Icon(Icons.filter_list),
              ),
              tooltip: l10n.filter,
              onPressed: _showFilterSheet,
            ),
          ),
        ],
      ),
      body: reportsAsync.when(
        data: (reports) {
          final filteredReports = _filterReports(reports, filters);
          final mapMarkers = filteredReports
              .map((r) => ReportMapMarker.fromLocalReport(r))
              .toList();
          return ReportMapWidget(
            markers: mapMarkers,
            showHeatmap: heatmapEnabled,
            mapController: _mapController,
            showLocationPrompt: showLocationPrompt,
            onMarkerTap: (marker) {
              final report = filteredReports.firstWhere(
                (r) =>
                    (r.lat == marker.point.latitude &&
                        r.lng == marker.point.longitude) ||
                    (r.idempotencyKey == marker.id),
                orElse: () => filteredReports.first,
              );
              _showReportDetails(context, report);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'recenter_indonesia',
            tooltip: l10n.pusatIndonesia,
            backgroundColor: Colors.white,
            foregroundColor: SigapColors.primary,
            onPressed: () {
              _mapController.fitCamera(
                CameraFit.bounds(
                  bounds: LatLngBounds(
                    const LatLng(-11.0, 95.0),
                    const LatLng(6.0, 141.0),
                  ),
                  padding: const EdgeInsets.all(24),
                  maxZoom: 6,
                ),
              );
            },
            child: const Icon(Icons.public),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'my_location',
            tooltip: l10n.lokasiSaya,
            backgroundColor: SigapColors.primary,
            foregroundColor: Colors.white,
            onPressed: () async {
              final deviceLocation = await ref.read(
                deviceLocationProvider.future,
              );
              if (deviceLocation != null) {
                _mapController.move(deviceLocation, 14);
              }
            },
            child: const Icon(Icons.my_location),
          ),
        ],
      ),
    );
  }

  List<LocalReport> _filterReports(
    List<LocalReport> reports,
    MapFilters filters,
  ) {
    return reports.where((report) {
      if (filters.categories.isNotEmpty &&
          !filters.categories.contains(report.categoryId)) {
        return false;
      }
      if (filters.statuses.isNotEmpty) {
        final status = ReportStatus.fromJson(report.status);
        if (!filters.statuses.contains(status)) {
          return false;
        }
      }
      if (filters.startDate != null &&
          report.createdAt.isBefore(filters.startDate!)) {
        return false;
      }
      if (filters.endDate != null &&
          report.createdAt.isAfter(filters.endDate!)) {
        return false;
      }
      return true;
    }).toList();
  }

  void _showReportDetails(BuildContext context, LocalReport report) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(SigapSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              report.categoryId,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: SigapSpacing.sm),
            Text(
              report.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            if (report.addressArea != null &&
                report.addressArea!.isNotEmpty) ...[
              const SizedBox(height: SigapSpacing.sm),
              Row(
                children: [
                  Icon(Icons.place, size: 16, color: SigapColors.textMuted),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      report.addressArea!,
                      style: TextStyle(color: SigapColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: SigapSpacing.sm),
            Text(
              l10n.statusMarker(report.status),
              style: TextStyle(color: SigapColors.textSecondary),
            ),
            const SizedBox(height: SigapSpacing.md),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: SigapColors.textMuted),
                const SizedBox(width: 4),
                Text(
                  '${report.lat.toStringAsFixed(6)}, ${report.lng.toStringAsFixed(6)}',
                  style: TextStyle(color: SigapColors.textMuted),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Filter Bottom Sheet ───────────────────────────────────────────────────────

class _FilterBottomSheet extends ConsumerStatefulWidget {
  const _FilterBottomSheet();

  @override
  ConsumerState<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<_FilterBottomSheet> {
  late Set<String> _selectedCategories;
  late Set<ReportStatus> _selectedStatuses;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    final filters = ref.read(mapFiltersProvider);
    _selectedCategories = Set.from(filters.categories);
    _selectedStatuses = Set.from(filters.statuses);
    _startDate = filters.startDate;
    _endDate = filters.endDate;
  }

  void _applyFilters() {
    ref.read(mapFiltersProvider.notifier).state = MapFilters(
      categories: _selectedCategories,
      statuses: _selectedStatuses,
      startDate: _startDate,
      endDate: _endDate,
    );
    Navigator.pop(context);
  }

  void _clearFilters() {
    setState(() {
      _selectedCategories.clear();
      _selectedStatuses.clear();
      _startDate = null;
      _endDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final categoriesAsync = ref.watch(mapCategoriesProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(SigapSpacing.lg),
          child: ListView(
            controller: scrollController,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.filter,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextButton(
                    onPressed: _clearFilters,
                    child: Text(l10n.hapusSemua),
                  ),
                ],
              ),
              const SizedBox(height: SigapSpacing.lg),
              Text(
                l10n.kategori,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: SigapSpacing.sm),
              categoriesAsync.when(
                data: (categories) => Wrap(
                  spacing: 8,
                  children: categories.map((cat) {
                    final slug = cat['slug'] ?? '';
                    final name = cat['name'] ?? slug;
                    final isSelected = _selectedCategories.contains(slug);
                    return FilterChip(
                      label: Text(name),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedCategories.add(slug);
                          } else {
                            _selectedCategories.remove(slug);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => _buildHardcodedCategoryChips(),
              ),
              const SizedBox(height: SigapSpacing.lg),
              Text(l10n.status, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: SigapSpacing.sm),
              Wrap(
                spacing: 8,
                children: ReportStatus.allValues.map((status) {
                  final isSelected = _selectedStatuses.contains(status);
                  return FilterChip(
                    label: Text(_formatStatus(status)),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedStatuses.add(status);
                        } else {
                          _selectedStatuses.remove(status);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: SigapSpacing.lg),
              Text(
                l10n.waktuSection,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: SigapSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _selectDate(true),
                      child: Text(
                        _startDate != null
                            ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                            : l10n.dariTanggal,
                      ),
                    ),
                  ),
                  const SizedBox(width: SigapSpacing.sm),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _selectDate(false),
                      child: Text(
                        _endDate != null
                            ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                            : l10n.sampaiTanggal,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SigapSpacing.xl),
              ElevatedButton(
                onPressed: _applyFilters,
                child: Text(l10n.terapkanFilter),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectDate(bool isStartDate) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? (_startDate ?? now) : (_endDate ?? now),
      firstDate: DateTime(2020),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  /// Fallback method to build category chips from hardcoded values
  /// when API fetch fails.
  Widget _buildHardcodedCategoryChips() {
    const hardcodedCategories = ['road', 'bridge', 'drainage', 'public'];
    return Wrap(
      spacing: 8,
      children: hardcodedCategories.map((cat) {
        final isSelected = _selectedCategories.contains(cat);
        return FilterChip(
          label: Text(_formatCategory(cat)),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedCategories.add(cat);
              } else {
                _selectedCategories.remove(cat);
              }
            });
          },
        );
      }).toList(),
    );
  }

  String _formatCategory(String cat) {
    final l10n = AppLocalizations.of(context)!;
    switch (cat) {
      case 'road':
        return l10n.jalanRusak;
      case 'bridge':
        return l10n.jembatan;
      case 'drainage':
        return l10n.drainase;
      case 'public':
        return l10n.fasilitasUmum;
      default:
        return cat;
    }
  }

  String _formatStatus(ReportStatus status) {
    final l10n = AppLocalizations.of(context)!;
    switch (status) {
      case ReportStatus.submitted:
        return l10n.submittedLabel;
      case ReportStatus.underReview:
        return l10n.underReviewLabel;
      case ReportStatus.verified:
        return l10n.verifiedLabel;
      case ReportStatus.inProgress:
        return l10n.inProgressLabel;
      case ReportStatus.resolved:
        return l10n.resolvedLabel;
      case ReportStatus.rejected:
        return l10n.rejectedLabel;
      case ReportStatus.duplicateMerged:
        return l10n.duplikat;
      case ReportStatus.needsSurvey:
        return l10n.perluSurvei;
      case ReportStatus.needsCompletion:
        return l10n.perluKelengkapan;
      case ReportStatus.outOfScope:
        return l10n.diluteJangkauan;
      default:
        return status.value;
    }
  }
}

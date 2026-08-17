import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../db/database.dart';
import '../../l10n/strings.dart';
import '../../theme/tokens.dart';
import '../../providers/providers.dart';
import '../../providers/auth_provider.dart';
import '../../api/api_client.dart';
import '../../api/types.g.dart';
import '../../utils/logger.dart';

final _logger = Logger('MapScreen');

// ─── Tile Providers ───────────────────────────────────────────────────────────

const _primaryTileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
const _fallbackTileUrl = 'https://tile.openstreetmap.de/{z}/{x}/{y}.png';

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
  final api = ApiClient(
    onLogout: () => ref.read(authNotifierProvider.notifier).logout(),
  );
  final data = await api.get('/api/reports/geojson');
  return GeoJSONFeatureCollection.fromJson(data);
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
  final bool _tileErrorOccurred = false;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    final deviceLocation = await ref.read(deviceLocationProvider.future);
    if (mounted && deviceLocation != null) {
      _mapController.move(deviceLocation, 14);
    }
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    final pickMode = ref.read(pickLocationModeProvider);
    final callback = ref.read(pickLocationCallbackProvider);
    if (pickMode && callback != null) {
      callback(point);
      ref.read(pickLocationModeProvider.notifier).state = false;
      ref.read(pickLocationCallbackProvider.notifier).state = null;
    }
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _FilterBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reportsAsync = ref.watch(localReportsProvider);
    final filters = ref.watch(mapFiltersProvider);
    final heatmapEnabled = ref.watch(heatmapEnabledProvider);
    final pickMode = ref.watch(pickLocationModeProvider);
    final deviceLocationAsync = ref.watch(deviceLocationProvider);

    // Determine initial map center from device location
    final initialCenter = deviceLocationAsync.when(
      data: (loc) => loc ?? const LatLng(-6.2, 106.8),
      loading: () => const LatLng(-6.2, 106.8),
      error: (_, __) => const LatLng(-6.2, 106.8),
    );

    // Show location prompt when device location is unavailable
    final showLocationPrompt =
        deviceLocationAsync.hasError ||
        (deviceLocationAsync.value == null && !deviceLocationAsync.isLoading);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Peta Laporan'),
        actions: [
          IconButton(
            icon: Icon(heatmapEnabled ? Icons.layers : Icons.layers_outlined),
            tooltip: 'Heatmap',
            onPressed: () {
              ref.read(heatmapEnabledProvider.notifier).state = !heatmapEnabled;
            },
          ),
          IconButton(
            icon: Badge(
              isLabelVisible: filters.isActive,
              child: const Icon(Icons.filter_list),
            ),
            tooltip: Strings.filter,
            onPressed: _showFilterSheet,
          ),
          IconButton(
            icon: Icon(
              pickMode ? Icons.location_on : Icons.location_on_outlined,
              color: pickMode ? SigapColors.primary : null,
            ),
            tooltip: 'Pilih Lokasi',
            onPressed: () {
              final newPickMode = !pickMode;
              ref.read(pickLocationModeProvider.notifier).state = newPickMode;
              if (newPickMode) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ketuk peta untuk memilih lokasi'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          reportsAsync.when(
            data: (reports) {
              final filteredReports = _filterReports(reports, filters);
              final markers = _buildMarkers(filteredReports);
              final heatmapData = _buildHeatmapData(filteredReports);

              return FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: initialCenter,
                  initialZoom: 10,
                  onTap: pickMode ? _onMapTap : null,
                ),
                children: [
                  TileLayer(
                    urlTemplate: _tileErrorOccurred
                        ? _fallbackTileUrl
                        : _primaryTileUrl,
                    userAgentPackageName: 'id.kmipn.sigap',
                  ),
                  if (heatmapEnabled && heatmapData.isNotEmpty)
                    HeatMapLayer(
                      heatMapDataSource: InMemoryHeatMapDataSource(
                        data: heatmapData,
                      ),
                      heatMapOptions: HeatMapOptions(
                        radius: 40,
                        blurFactor: 0.5,
                        gradient: {
                          0.0: Colors.green,
                          0.5: Colors.yellow,
                          0.9: Colors.red,
                        },
                      ),
                    ),
                  MarkerClusterLayerWidget(
                    options: MarkerClusterLayerOptions(
                      maxClusterRadius: 80,
                      size: const Size(50, 50),
                      markers: markers,
                      builder: (context, markers) {
                        return Container(
                          decoration: BoxDecoration(
                            color: SigapColors.primary.withValues(alpha: 0.8),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Center(
                            child: Text(
                              markers.length.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          ),
          if (pickMode)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: SigapColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Ketuk untuk memilih lokasi',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          if (showLocationPrompt)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                color: SigapColors.offlineBg,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(Icons.location_off, color: SigapColors.offlineDot),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Aktifkan lokasi untuk melihat peta Anda',
                          style: TextStyle(color: SigapColors.offlineText),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final deviceLocation = await ref.read(deviceLocationProvider.future);
          if (deviceLocation != null) {
            _mapController.move(deviceLocation, 14);
          }
        },
        child: const Icon(Icons.my_location),
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

  List<Marker> _buildMarkers(List<LocalReport> reports) {
    return reports.map((r) {
      return Marker(
        point: LatLng(r.lat, r.lng),
        width: 40,
        height: 40,
        child: GestureDetector(
          onTap: () => _showReportDetails(r),
          child: Icon(
            Icons.location_on,
            color: _getMarkerColor(r.status),
            size: 36,
          ),
        ),
      );
    }).toList();
  }

  Color _getMarkerColor(String statusStr) {
    try {
      final status = ReportStatus.fromJson(statusStr);
      switch (status) {
        case ReportStatus.submitted:
          return SigapColors.perluTindakan;
        case ReportStatus.underReview:
        case ReportStatus.needsSurvey:
          return SigapColors.diproses;
        case ReportStatus.verified:
        case ReportStatus.inProgress:
          return SigapColors.diproses;
        case ReportStatus.resolved:
          return SigapColors.selesai;
        case ReportStatus.rejected:
        case ReportStatus.duplicateMerged:
          return SigapColors.textMuted;
      }
    } catch (e, s) {
      _logger.warning('Error parsing report status "$statusStr"', e, s);
      return SigapColors.primary;
    }
  }

  List<WeightedLatLng> _buildHeatmapData(List<LocalReport> reports) {
    return reports.map((r) {
      return WeightedLatLng(LatLng(r.lat, r.lng), 1.0);
    }).toList();
  }

  void _showReportDetails(LocalReport report) {
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
            const SizedBox(height: SigapSpacing.sm),
            Text(
              'Status: ${report.status}',
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

  static const _availableCategories = ['road', 'bridge', 'drainage', 'public'];

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
                    Strings.filter,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextButton(
                    onPressed: _clearFilters,
                    child: const Text('Hapus Semua'),
                  ),
                ],
              ),
              const SizedBox(height: SigapSpacing.lg),
              Text('Kategori', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: SigapSpacing.sm),
              Wrap(
                spacing: 8,
                children: _availableCategories.map((cat) {
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
              ),
              const SizedBox(height: SigapSpacing.lg),
              Text('Status', style: Theme.of(context).textTheme.titleMedium),
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
              Text('Waktu', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: SigapSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _selectDate(true),
                      child: Text(
                        _startDate != null
                            ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                            : 'Dari Tanggal',
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
                            : 'Sampai Tanggal',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SigapSpacing.xl),
              ElevatedButton(
                onPressed: _applyFilters,
                child: const Text('Terapkan Filter'),
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

  String _formatCategory(String cat) {
    switch (cat) {
      case 'road':
        return 'Jalan Rusak';
      case 'bridge':
        return 'Jembatan';
      case 'drainage':
        return 'Drainase';
      case 'public':
        return 'Fasilitas Umum';
      default:
        return cat;
    }
  }

  String _formatStatus(ReportStatus status) {
    switch (status) {
      case ReportStatus.submitted:
        return 'Submitted';
      case ReportStatus.underReview:
        return 'Under Review';
      case ReportStatus.verified:
        return 'Verified';
      case ReportStatus.inProgress:
        return 'In Progress';
      case ReportStatus.resolved:
        return 'Resolved';
      case ReportStatus.rejected:
        return 'Rejected';
      case ReportStatus.duplicateMerged:
        return 'Duplicate';
      case ReportStatus.needsSurvey:
        return 'Needs Survey';
    }
  }
}

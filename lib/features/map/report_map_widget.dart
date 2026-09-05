import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';
import 'package:latlong2/latlong.dart';
import 'package:sigap/api/client.dart';
import '../../config/map_constants.dart';
import '../../db/database.dart';
import '../../theme/tokens.dart';
import '../../widgets/design_system/design_system.dart';

/// Reusable map widget that renders report markers with clustering and optional
/// heatmap. Used by both the authenticated MapScreen and the public portal.
class ReportMapWidget extends StatefulWidget {
  final List<ReportMapMarker> markers;
  final bool showHeatmap;
  final MapController? mapController;
  final void Function(ReportMapMarker marker)? onMarkerTap;
  final bool interactive;
  final bool showLocationPrompt;

  const ReportMapWidget({
    super.key,
    required this.markers,
    this.showHeatmap = false,
    this.mapController,
    this.onMarkerTap,
    this.interactive = true,
    this.showLocationPrompt = false,
  });

  @override
  State<ReportMapWidget> createState() => _ReportMapWidgetState();
}

class _ReportMapWidgetState extends State<ReportMapWidget> {
  late final MapController _mapController;
  bool _tileErrorOccurred = false;
  bool _mapReadyFired = false;

  @override
  void initState() {
    super.initState();
    _mapController = widget.mapController ?? MapController();
  }

  void _onMapReady() {
    if (_mapReadyFired) return;
    _mapReadyFired = true;
    _fitToMarkers(widget.markers);
  }

  void _fitToMarkers(List<ReportMapMarker> markers) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final validMarkers = markers
          .where((m) => m.point.latitude != 0 || m.point.longitude != 0)
          .toList();
      if (validMarkers.isEmpty) {
        _mapController.fitCamera(
          CameraFit.bounds(
            bounds: _indonesiaBounds,
            padding: const EdgeInsets.all(24),
            maxZoom: 6,
          ),
        );
      } else if (validMarkers.length == 1) {
        _mapController.move(validMarkers.first.point, 14);
      } else {
        final points = validMarkers.map((m) => m.point).toList();
        _mapController.fitCamera(
          CameraFit.bounds(
            bounds: LatLngBounds.fromPoints(points),
            padding: const EdgeInsets.all(40),
            maxZoom: 14,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: MapConstants.indonesiaCenter,
            initialZoom: 5.0,
            minZoom: 3.5,
            maxZoom: 18.0,
            cameraConstraint: CameraConstraint.contain(
              bounds: _indonesiaMaxBounds,
            ),
            interactionOptions: widget.interactive
                ? const InteractionOptions()
                : const InteractionOptions(flags: InteractiveFlag.none),
            onMapReady: _onMapReady,
          ),
          children: [
            TileLayer(
              urlTemplate: _tileErrorOccurred
                  ? MapConstants.fallbackTileUrl
                  : MapConstants.primaryTileUrl,
              userAgentPackageName: 'id.kmipn.sigap',
            ),
            _buildMapLayers(),
          ],
        ),
        if (widget.showLocationPrompt)
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(SigapRadius.x8),
              color: SigapColors.offlineBg,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.location_off, color: SigapColors.offlineDot),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Aktifkan lokasi untuk melihat peta',
                        style: TextStyle(color: SigapColors.offlineText),
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

  Widget _buildMapLayers() {
    final markers = _buildMarkers(widget.markers);
    final heatmapData = _buildHeatmapData(widget.markers);

    return Stack(
      children: [
        if (widget.showHeatmap && heatmapData.isNotEmpty)
          HeatMapLayer(
            heatMapDataSource: InMemoryHeatMapDataSource(data: heatmapData),
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
  }

  List<Marker> _buildMarkers(List<ReportMapMarker> reports) {
    return reports.map((r) {
      return Marker(
        point: r.point,
        width: 40,
        height: 40,
        child: GestureDetector(
          onTap: widget.onMarkerTap != null
              ? () => widget.onMarkerTap!(r)
              : null,
          child: Icon(
            Icons.location_on,
            color: _getMarkerColor(r.status),
            size: 36,
          ),
        ),
      );
    }).toList();
  }

  List<WeightedLatLng> _buildHeatmapData(List<ReportMapMarker> reports) {
    return reports.map((r) {
      return WeightedLatLng(r.point, 1.0);
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
        case ReportStatus.verified:
        case ReportStatus.inProgress:
        case ReportStatus.needsCompletion:
        case ReportStatus.inReview:
        case ReportStatus.needsAction:
          return SigapColors.diproses;
        case ReportStatus.resolved:
        case ReportStatus.completed:
          return SigapColors.selesai;
        case ReportStatus.rejected:
        case ReportStatus.duplicateMerged:
        case ReportStatus.outOfScope:
        case ReportStatus.pending:
        case ReportStatus.locallyCreated:
        case ReportStatus.locallySaved:
          return SigapColors.textMuted;
        case ReportStatus.assigned:
        case ReportStatus.closed:
        case ReportStatus.merged:
        case ReportStatus.separated:
        case ReportStatus.draft:
          return SigapColors.primary;
      }
    } catch (_) {
      return SigapColors.primary;
    }
  }
}

// ─── Indonesia Bounds ───────────────────────────────────────────────────────

final _indonesiaBounds = LatLngBounds(
  const LatLng(-11.0, 95.0),
  const LatLng(6.0, 141.0),
);

final _indonesiaMaxBounds = LatLngBounds(
  const LatLng(-14.0, 92.0),
  const LatLng(9.0, 144.0),
);

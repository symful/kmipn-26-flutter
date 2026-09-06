import 'package:sigap/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:sigap/config/map_constants.dart';
import 'package:sigap/theme/tokens.dart';
import 'package:sigap/theme/sigap_color_scheme.dart';

/// Reusable map widget that renders report markers with clustering and optional
/// heatmap. Used by both the authenticated MapScreen and the public portal.
class ReportMapWidget extends StatefulWidget {
  final List<ReportMapMarker> markers;
  final bool generalizedLocations;
  final TileProvider? tileProvider;
  final MapController? mapController;
  final void Function(ReportMapMarker marker)? onMarkerTap;
  final bool interactive;
  final bool showLocationPrompt;

  const ReportMapWidget({
    super.key,
    required this.markers,
    this.generalizedLocations = true,
    this.tileProvider,
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
  bool _mapReadyFired = false;

  @override
  void initState() {
    super.initState();
    _mapController = widget.mapController ?? MapController();
  }

  @override
  void didUpdateWidget(ReportMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.markers.length != widget.markers.length ||
        oldWidget.markers.map((m) => '${m.id}:${m.point}').join('|') !=
            widget.markers.map((m) => '${m.id}:${m.point}').join('|')) {
      _fitToMarkers(widget.markers);
    }
  }

  @override
  void dispose() {
    if (widget.mapController == null) _mapController.dispose();
    super.dispose();
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
              urlTemplate: MapConstants.primaryTileUrl,
              tileProvider: widget.tileProvider,
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
                        AppLocalizations.of(
                          context,
                        )!.mobileEnableLocationToViewTheMap,
                        style: TextStyle(color: SigapColors.offlineText),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        // ── Map Zoom Controls (Top Right) ────────────────────────────────────
        Positioned(
          top: 16,
          right: 16,
          child: Column(
            children: [
              _MapControlButton(
                icon: Icons.add,
                onPressed: () => _mapController.move(
                  _mapController.camera.center,
                  _mapController.camera.zoom + 1,
                ),
              ),
              const SizedBox(height: 4),
              _MapControlButton(
                icon: Icons.remove,
                onPressed: () => _mapController.move(
                  _mapController.camera.center,
                  _mapController.camera.zoom - 1,
                ),
              ),
              const SizedBox(height: 4),
              _MapControlButton(
                icon: Icons.my_location,
                onPressed: () => _fitToMarkers(widget.markers),
              ),
            ],
          ),
        ),
        // ── Legend Box (Bottom Left) ──────────────────────────────────────────
        Positioned(
          bottom: 9,
          left: 9,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 9),
            decoration: BoxDecoration(
              color: SigapColorScheme.of(
                context,
              ).surface.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(SigapRadius.md),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 4),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(context)!.mobileCaseStatus,
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: SigapColorScheme.of(context).textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                _LegendRow(
                  color: SigapColorScheme.of(context).selesai,
                  label: AppLocalizations.of(context)!.mobileVerifiedCompleted,
                ),
                _LegendRow(
                  color: SigapColorScheme.of(context).warning,
                  label: AppLocalizations.of(context)!.mobileAwaitingFollowUp,
                ),
                _LegendRow(
                  color: SigapColorScheme.of(context).diproses,
                  label: AppLocalizations.of(context)!.mobileInProgress,
                ),
              ],
            ),
          ),
        ),
        // ── Privacy Notice (Bottom Right) ────────────────────────────────────
        Positioned(
          bottom: 9,
          right: 9,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 140),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: SigapColorScheme.of(
                context,
              ).surface.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(SigapRadius.sm),
            ),
            child: Text(
              (widget.generalizedLocations
                  ? AppLocalizations.of(
                      context,
                    )!.mobileLocationsAreGeneralizedToProtectReporterPrivacyPDPLaw
                  : AppLocalizations.of(
                      context,
                    )!.mobileTaskLocationsForAuthorizedFieldWorkers),
              style: TextStyle(
                fontSize: 8,
                color: SigapColorScheme.of(context).textMuted,
                height: 1.2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMapLayers() {
    final markers = _buildMarkers(widget.markers);

    return Stack(
      children: [
        MarkerClusterLayerWidget(
          options: MarkerClusterLayerOptions(
            maxClusterRadius: 80,
            size: const Size(50, 50),
            markers: markers,
            builder: (context, markers) {
              return Container(
                decoration: BoxDecoration(
                  color: SigapColorScheme.of(
                    context,
                  ).primary.withValues(alpha: 0.8),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: SigapColorScheme.of(context).surface,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    markers.length.toString(),
                    style: TextStyle(
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

  Color _getMarkerColor(String statusStr) {
    final s = statusStr.toLowerCase();
    if (s.contains('ditangani') ||
        s.contains('in_progress') ||
        s.contains('assigned')) {
      return SigapColorScheme.of(context).diproses; // Sedang Ditangani
    } else if (s.contains('selesai') ||
        s.contains('terverifikasi') ||
        s.contains('resolved') ||
        s == 'verified' ||
        s == 'completed' ||
        s.contains('closed')) {
      return SigapColorScheme.of(context).selesai; // Terverifikasi / selesai
    } else {
      return SigapColorScheme.of(
        context,
      ).warning; // Menunggu verifikasi / tindak lanjut
    }
  }
}

class _MapControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  const _MapControlButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SigapColorScheme.of(context).surface,
        borderRadius: BorderRadius.circular(SigapRadius.sm),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: IconButton(
        icon: Icon(
          icon,
          size: 20,
          color: SigapColorScheme.of(context).textPrimary,
        ),
        onPressed: onPressed,
        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        padding: EdgeInsets.zero,
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendRow({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 8,
              color: SigapColorScheme.of(context).textSecondary,
            ),
          ),
        ],
      ),
    );
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

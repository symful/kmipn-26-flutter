import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../providers/providers.dart';
import '../../theme/tokens.dart';
import '../../utils/logger.dart';

const _logger = Logger('DashboardMiniMap');

// ─── Tile URL (same as Web MiniMapCluster) ─────────────────────────────────────

const _tileUrl =
    'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png';

// Indonesia center fallback (same as Web)
const _indonesiaCenter = LatLng(-6.2088, 106.8456);

// ─── Marker Data ───────────────────────────────────────────────────────────────

/// Mini map report marker with parsed geo data.
class MiniMapMarker {
  final String id;
  final String status;
  final String categoryName;
  final LatLng point;

  const MiniMapMarker({
    required this.id,
    required this.status,
    required this.categoryName,
    required this.point,
  });
}

// ─── Provider ─────────────────────────────────────────────────────────────────

/// Fetches reports for the dashboard mini map.
final dashboardMiniMapProvider = FutureProvider<List<MiniMapMarker>>((
  ref,
) async {
  final api = ref.watch(apiClientProvider);
  try {
    final geojson = await api.getMapGeoJson();
    final features = geojson.features ?? [];
    final markers = <MiniMapMarker>[];

    for (final feature in features) {
      final geometry = feature.geometry;
      if (geometry == null) continue;

      final coords = geometry['coordinates'];
      if (coords is! List || coords.length < 2) continue;

      final lng = (coords[0] as num?)?.toDouble();
      final lat = (coords[1] as num?)?.toDouble();
      if (lng == null || lat == null) continue;

      final props = feature.properties;
      markers.add(
        MiniMapMarker(
          id: props?['id']?.toString() ?? '',
          status: props?['status']?.toString() ?? 'submitted',
          categoryName: props?['category_id']?.toString() ?? '',
          point: LatLng(lat, lng),
        ),
      );
    }

    return markers;
  } catch (e, s) {
    _logger.error('Failed to fetch mini-map geojson', e, s);
    rethrow;
  }
});

// ─── Marker Color Helper ───────────────────────────────────────────────────────

/// Returns marker color based on report status (mirrors Web MiniMapCluster).
Color _getMarkerColor(String status) {
  switch (status) {
    case 'resolved':
      return SigapColors.selesai;
    case 'verified':
    case 'in_progress':
      return SigapColors.diproses;
    case 'under_review':
    case 'needs_survey':
      return SigapColors.warning;
    case 'submitted':
    default:
      return SigapColors.perluTindakan;
  }
}

// ─── Widget ───────────────────────────────────────────────────────────────────

/// W-02 MiniMap widget for dashboard.
///
/// Mirrors the Web SPA MiniMapCluster pattern:
/// - CARTO light tile layer
/// - Status-colored markers
/// - Fetches from /api/map/geojson
/// - Loading/error states
/// - Non-interactive (no drag/scroll/zoom)
class DashboardMiniMap extends ConsumerWidget {
  final String? className;

  const DashboardMiniMap({super.key, this.className});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(dashboardMiniMapProvider);

    return Container(
      decoration: BoxDecoration(
        color: SigapColors.background,
        borderRadius: BorderRadius.circular(SigapRadius.lg),
      ),
      clipBehavior: Clip.antiAlias,
      child: reportsAsync.when(
        data: (reports) => _MiniMapContent(reports: reports),
        loading: () => const _MiniMapLoading(),
        error: (error, _) => _MiniMapError(
          message: AppLocalizations.of(context)!.gagalMemuatPeta,
        ),
      ),
    );
  }
}

class _MiniMapContent extends StatelessWidget {
  final List<MiniMapMarker> reports;

  const _MiniMapContent({required this.reports});

  @override
  Widget build(BuildContext context) {
    // Dynamic center based on first marker, or Indonesia fallback
    final center = reports.isNotEmpty ? reports.first.point : _indonesiaCenter;

    final markers = reports.map((r) {
      return Marker(
        point: r.point,
        width: 24,
        height: 24,
        child: GestureDetector(
          onTap: () => _showMarkerPopup(context, r),
          child: Container(
            decoration: BoxDecoration(
              color: _getMarkerColor(r.status),
              shape: BoxShape.circle,
              border: Border.all(color: SigapColors.surface, width: 2),
              boxShadow: [
                BoxShadow(
                  color: SigapColors.textPrimary.withValues(alpha: 0.25),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: SigapColors.surface,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      );
    }).toList();

    return FlutterMap(
      options: MapOptions(
        initialCenter: center,
        initialZoom: 11,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.none, // Non-interactive
        ),
      ),
      children: [
        TileLayer(urlTemplate: _tileUrl, userAgentPackageName: 'id.sigap.app'),
        MarkerClusterLayerWidget(
          options: MarkerClusterLayerOptions(
            maxClusterRadius: 60,
            size: const Size(40, 40),
            markers: markers,
            builder: (context, clusterMarkers) {
              return Container(
                decoration: BoxDecoration(
                  color: SigapColors.primary.withValues(alpha: 0.85),
                  shape: BoxShape.circle,
                  border: Border.all(color: SigapColors.surface, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: SigapColors.textPrimary.withValues(alpha: 0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    clusterMarkers.length.toString(),
                    style: const TextStyle(
                      color: SigapColors.surface,
                      fontSize: SigapTypography.captionMedium,
                      fontWeight: FontWeight.w700,
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

  void _showMarkerPopup(BuildContext context, MiniMapMarker marker) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              marker.categoryName,
              style: const TextStyle(
                fontSize: SigapTypography.bodyText,
                fontWeight: FontWeight.w600,
                color: SigapColors.textPrimary,
              ),
            ),
            const SizedBox(height: SigapSpacing.xs),
            Text(
              l10n.statusMarker(marker.status),
              style: const TextStyle(
                fontSize: SigapTypography.captionMedium,
                color: SigapColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.tutup),
          ),
        ],
      ),
    );
  }
}

class _MiniMapLoading extends StatelessWidget {
  const _MiniMapLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: SigapColors.surface.withValues(alpha: 0.6),
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(SigapColors.primary),
          ),
        ),
      ),
    );
  }
}

class _MiniMapError extends StatelessWidget {
  final String message;

  const _MiniMapError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: SigapColors.surface.withValues(alpha: 0.6),
      child: Center(
        child: Text(
          message,
          style: const TextStyle(
            fontSize: SigapTypography.captionMedium,
            color: SigapColors.textMuted,
          ),
        ),
      ),
    );
  }
}

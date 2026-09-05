import 'package:latlong2/latlong.dart';

/// Shared map constants used across multiple screens.
/// Eliminates duplicate definitions in map_screen, public_portal_screen,
/// and dashboard_mini_map.
abstract class MapConstants {
  static const indonesiaCenter = LatLng(-2.548926, 118.0148634);

  static const primaryTileUrl =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const fallbackTileUrl =
      'https://tile.openstreetmap.de/{z}/{x}/{y}.png';
}

/// Unified map marker model that both LocalReport (Drift) and GeoJSONFeature
/// (API) can be converted to, enabling a single shared map widget.
class ReportMapMarker {
  final LatLng point;
  final String status;
  final String categoryId;
  final String description;
  final String? addressArea;
  final String? id;

  const ReportMapMarker({
    required this.point,
    required this.status,
    required this.categoryId,
    this.description = '',
    this.addressArea,
    this.id,
  });

  /// Create from a Drift LocalReport row.
  factory ReportMapMarker.fromLocalReport(dynamic report) {
    return ReportMapMarker(
      point: LatLng(report.lat as double, report.lng as double),
      status: report.status as String,
      categoryId: report.categoryId as String,
      description: (report.description as String?) ?? '',
      addressArea: report.addressArea as String?,
      id: report.idempotencyKey as String?,
    );
  }

  /// Create from a GeoJSON feature (public API response).
  factory ReportMapMarker.fromGeoJSONFeature(dynamic feature) {
    final geometry = feature.geometry as Map<String, dynamic>?;
    final coordinates = geometry?['coordinates'] as List?;
    final properties = feature.properties as Map<String, dynamic>?;

    double lat = 0;
    double lng = 0;
    if (coordinates != null && coordinates.length >= 2) {
      lng = (coordinates[0] as num).toDouble();
      lat = (coordinates[1] as num).toDouble();
    }

    return ReportMapMarker(
      point: LatLng(lat, lng),
      status: properties?['status'] as String? ?? 'submitted',
      categoryId: properties?['category_id'] as String? ?? '',
      description: properties?['description'] as String? ?? '',
      addressArea: properties?['address_area'] as String?,
      id: properties?['id'] as String?,
    );
  }
}

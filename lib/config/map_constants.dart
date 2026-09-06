import 'package:latlong2/latlong.dart';
import '../api/client.dart';
import '../db/database.dart';

/// Shared map constants used across multiple screens.
/// Eliminates duplicate definitions in map-related screens.
abstract class MapConstants {
  static const indonesiaCenter = LatLng(-2.548926, 118.0148634);

  static const primaryTileUrl =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const fallbackTileUrl =
      'https://tile.openstreetmap.de/{z}/{x}/{y}.png';
}

/// Typed marker shared by local drafts, public cases and assigned tasks.
class ReportMapMarker {
  final LatLng point;
  final String status;
  final String categoryId;
  final String description;
  final String? title;
  final String? categoryName;
  final String? addressArea;
  final String? id;
  final DateTime? createdAt;

  const ReportMapMarker({
    required this.point,
    required this.status,
    required this.categoryId,
    this.description = '',
    this.title,
    this.categoryName,
    this.addressArea,
    this.id,
    this.createdAt,
  });

  factory ReportMapMarker.fromLocalReport(LocalReport report) =>
      ReportMapMarker(
        point: LatLng(report.lat, report.lng),
        status: report.status,
        categoryId: report.categoryId,
        description: report.description,
        addressArea: report.addressArea,
        id: report.serverId ?? report.idempotencyKey,
        createdAt: report.createdAt,
      );

  factory ReportMapMarker.fromGeoJSONFeature(GeoJSONFeature feature) {
    final coordinates = feature.geometry?.coordinates;
    if (feature.geometry?.type != 'Point' ||
        coordinates is! List ||
        coordinates.length < 2 ||
        coordinates[0] is! num ||
        coordinates[1] is! num) {
      throw const FormatException('Expected GeoJSON Point coordinates');
    }
    final p = feature.properties;
    return ReportMapMarker(
      point: LatLng(
        (coordinates[1] as num).toDouble(),
        (coordinates[0] as num).toDouble(),
      ),
      status: p?.status ?? '',
      categoryId: p?.categoryId ?? '',
      categoryName: p?.category,
      title: p?.name,
      description: p?.description ?? '',
      addressArea: p?.addressArea,
      id: p?.reportId,
      createdAt: p?.createdAt,
    );
  }

  factory ReportMapMarker.fromTask(PetugasTask task, {String? categoryId}) =>
      ReportMapMarker(
        point: LatLng(task.lat!, task.lng!),
        status: task.status ?? '',
        categoryId: categoryId ?? task.categorySlug ?? '',
        categoryName: task.categoryName,
        title: task.reportTitle,
        description: task.reportDescription ?? '',
        addressArea: task.address,
        id: task.reportId,
        createdAt: task.createdAt,
      );
}

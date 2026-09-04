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

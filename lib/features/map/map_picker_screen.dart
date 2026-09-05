import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:sigap/l10n/generated/app_localizations.dart';
import 'package:sigap/theme/tokens.dart';

/// Dedicated map picker screen for selecting a location.
///
/// Returns the selected [LatLng] via [GoRouter.pop] when the user confirms.
class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  final MapController _mapController = MapController();
  LatLng? _selectedLocation;
  bool _mapReady = false;

  // Default to center of Indonesia
  static const _initialCenter = LatLng(-2.548926, 118.0148634);
  static final _indonesiaMaxBounds = LatLngBounds(
    const LatLng(-14.0, 92.0),
    const LatLng(9.0, 144.0),
  );

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    setState(() => _selectedLocation = point);
  }

  void _onMapReady() {
    if (_mapReady) return;
    _mapReady = true;
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds.fromPoints([
          const LatLng(-11.0, 95.0),
          const LatLng(6.0, 141.0),
        ]),
        padding: const EdgeInsets.all(24),
        maxZoom: 6,
      ),
    );
  }

  void _confirm() {
    if (_selectedLocation != null) {
      context.pop(_selectedLocation);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.pilihLokasi),
        actions: [
          if (_selectedLocation != null)
            TextButton(
              onPressed: _confirm,
              child: Text(
                l10n.konfirmasi,
                style: const TextStyle(
                  color: SigapColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _initialCenter,
              initialZoom: 5.0,
              minZoom: 3.5,
              maxZoom: 18.0,
              cameraConstraint: CameraConstraint.contain(
                bounds: _indonesiaMaxBounds,
              ),
              onTap: _onMapTap,
              onMapReady: _onMapReady,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'id.kmipn.sigap',
              ),
              if (_selectedLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedLocation!,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.location_pin,
                        color: SigapColors.primary,
                        size: 40,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          // Instruction banner
          if (_selectedLocation == null)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: SafeArea(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SigapSpacing.md,
                    vertical: SigapSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: SigapColors.bgSurface,
                    borderRadius: BorderRadius.circular(SigapRadius.md),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 18,
                        color: SigapColors.primary,
                      ),
                      const SizedBox(width: SigapSpacing.sm),
                      Expanded(
                        child: Text(
                          l10n.ketukPetaUntukMemilihLokasi,
                          style: const TextStyle(
                            fontSize: SigapTypography.bodySmall,
                            color: SigapColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          // Confirm button at bottom
          if (_selectedLocation != null)
            Positioned(
              bottom: 24,
              left: 16,
              right: 16,
              child: SafeArea(
                child: ElevatedButton(
                  onPressed: _confirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SigapColors.primary,
                    foregroundColor: SigapColors.surface,
                    padding: const EdgeInsets.symmetric(
                      vertical: SigapSpacing.md,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(SigapRadius.md),
                    ),
                  ),
                  child: Text(
                    l10n.konfirmasi,
                    style: const TextStyle(
                      fontSize: SigapTypography.bodyLarge,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

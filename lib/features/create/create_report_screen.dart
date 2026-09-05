import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' show Value;
import 'package:exif/exif.dart';
import 'package:image/image.dart' as img;
import '../../l10n/generated/app_localizations.dart';
import '../../theme/tokens.dart';
import '../../db/database.dart';
import '../../api/client.dart';
import '../../widgets/design_system/similar_cases_banner.dart';
import '../../providers/providers.dart';
import '../../utils/logger.dart';
import '../../utils/platform_helper.dart';
import '../../widgets/design_system/design_system.dart';

class CreateReportScreen extends ConsumerStatefulWidget {
  final bool anonymousMode;

  const CreateReportScreen({super.key, this.anonymousMode = false});

  @override
  ConsumerState<CreateReportScreen> createState() => _CreateReportScreenState();
}

/// Formats DateTime to "HH:MM" string for autosave display.
class _TimeOfDayFormatter {
  static String format(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

/// Builds a section card with icon header, divider, and content, using SigapCard.
Widget _sectionCard({
  required String title,
  required IconData icon,
  required Widget child,
}) {
  return SigapCard(
    padding: EdgeInsets.zero,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            SigapSpacing.lg,
            SigapSpacing.md,
            SigapSpacing.lg,
            SigapSpacing.sm,
          ),
          child: Row(
            children: [
              Icon(icon, color: SigapColors.primary, size: 20),
              const SizedBox(width: SigapSpacing.sm),
              Text(
                title,
                style: const TextStyle(
                  fontSize: SigapTypography.bodyMedium,
                  fontWeight: FontWeight.w600,
                  color: SigapColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: SigapColors.border),
        Padding(padding: const EdgeInsets.all(SigapSpacing.lg), child: child),
      ],
    ),
  );
}

// ─── Category Section ─────────────────────────────────────────────────────────

class _CategorySection extends ConsumerWidget {
  final String? selectedCategoryId;
  final ValueChanged<String?> onChanged;

  const _CategorySection({
    required this.selectedCategoryId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return categoriesAsync.when(
      loading: () => const LinearProgressIndicator(),
      error: (error, _) => _CategoryErrorWidget(error: error.toString()),
      data: (categories) {
        return _CategoryDropdown(
          categories: categories,
          selectedCategoryId: selectedCategoryId,
          onChanged: onChanged,
        );
      },
    );
  }
}

class _CategoryDropdown extends StatelessWidget {
  final List<Category> categories;
  final String? selectedCategoryId;
  final ValueChanged<String?> onChanged;

  const _CategoryDropdown({
    required this.categories,
    required this.selectedCategoryId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.labelPilihKategori,
        labelStyle: const TextStyle(color: SigapColors.textSecondary),
        hintText: AppLocalizations.of(context)!.tapUntukMemilihKategori,
        hintStyle: const TextStyle(color: SigapColors.textTertiary),
      ),
      initialValue: selectedCategoryId,
      items: categories.map((cat) {
        return DropdownMenuItem(value: cat.id, child: Text(cat.name ?? ""));
      }).toList(),
      onChanged: onChanged,
      validator: (v) =>
          v == null ? AppLocalizations.of(context)!.labelPilihKategori : null,
    );
  }
}

class _CategoryErrorWidget extends ConsumerWidget {
  final String error;

  const _CategoryErrorWidget({required this.error});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InputDecorator(
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.kategori,
            errorText: null,
          ),
          child: Row(
            children: [
              const Icon(Icons.error_outline, color: SigapColors.danger),
              const SizedBox(width: SigapSpacing.sm),
              Expanded(
                child: Text(
                  error,
                  style: const TextStyle(
                    color: SigapColors.danger,
                    fontSize: SigapTypography.bodySmall,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: SigapSpacing.md),
        ElevatedButton.icon(
          icon: const Icon(Icons.refresh, size: 18),
          label: Text(AppLocalizations.of(context)!.cobaLagi),
          onPressed: () => ref.invalidate(categoriesProvider),
        ),
      ],
    );
  }
}

// ─── Photo Section ────────────────────────────────────────────────────────────

class _PhotoSection extends StatelessWidget {
  final List<_PhotoEntry> photos;
  final VoidCallback onAdd;
  final void Function(int) onRemove;

  const _PhotoSection({
    required this.photos,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Thumbnail grid
        if (photos.isNotEmpty) ...[
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: SigapSpacing.sm,
              mainAxisSpacing: SigapSpacing.sm,
            ),
            itemCount: photos.length,
            itemBuilder: (context, index) {
              final photo = photos[index];
              final hasGps = _hasGpsInExif(photo.exifJson);
              return AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(SigapRadius.md),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Photo thumbnail
                      Image.file(File(photo.path), fit: BoxFit.cover),
                      // GPS badge
                      if (hasGps)
                        Positioned(
                          bottom: SigapSpacing.x4,
                          left: SigapSpacing.x4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: SigapSpacing.x4,
                              vertical: SigapSpacing.xxs,
                            ),
                            decoration: BoxDecoration(
                              color: SigapColors.selesai.withValues(
                                alpha: 0.85,
                              ),
                              borderRadius: BorderRadius.circular(
                                SigapRadius.x4,
                              ),
                            ),
                            child: Text(
                              l10n.gpsBadge,
                              style: const TextStyle(
                                color: SigapColors.surface,
                                fontSize: SigapTypography.captionMicro,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      // Remove button
                      Positioned(
                        top: SigapSpacing.x4,
                        right: SigapSpacing.x4,
                        child: GestureDetector(
                          onTap: () => onRemove(index),
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              color: SigapColors.danger,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: SigapColors.surface,
                              size: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: SigapSpacing.md),
        ],
        // Upload button
        InkWell(
          onTap: photos.length >= 5 ? null : onAdd,
          borderRadius: BorderRadius.circular(SigapRadius.md),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: SigapSpacing.md),
            decoration: BoxDecoration(
              color: photos.isEmpty
                  ? SigapColors.primaryLight
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(SigapRadius.md),
              border: Border.all(
                color: SigapColors.primary.withValues(alpha: 0.3),
                style: photos.isEmpty ? BorderStyle.solid : BorderStyle.solid,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  photos.isEmpty
                      ? Icons.add_a_photo
                      : Icons.add_photo_alternate,
                  color: SigapColors.primary,
                  size: photos.isEmpty ? 40 : 24,
                ),
                const SizedBox(width: SigapSpacing.sm),
                Text(
                  photos.isEmpty
                      ? l10n.sectionAmbilFoto
                      : l10n.tambahFoto(photos.length, 5),
                  style: const TextStyle(
                    color: SigapColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: SigapSpacing.sm),
        Text(
          l10n.maks5FotoFormat,
          style: TextStyle(
            color: SigapColors.textTertiary,
            fontSize: SigapTypography.captionMedium,
          ),
        ),
      ],
    );
  }

  /// Checks if the EXIF JSON string contains GPS-related keys.
  bool _hasGpsInExif(String? exifJson) {
    if (exifJson == null || exifJson.isEmpty) return false;
    try {
      final map = Map<String, dynamic>.from(
        Map<String, dynamic>.from(const JsonDecoder().convert(exifJson) as Map),
      );
      return map.keys.any(
        (k) =>
            k.contains('GPSLatitude') ||
            k.contains('GPSLongitude') ||
            k.contains('latitude') ||
            k.contains('longitude') ||
            k.contains('GPS'),
      );
    } catch (_) {
      return false;
    }
  }
}

// ─── Location Section ─────────────────────────────────────────────────────────

class _LocationSection extends StatelessWidget {
  final double? lat;
  final double? lng;
  final VoidCallback onCapture;
  final VoidCallback onPickFromMap;

  const _LocationSection({
    required this.lat,
    required this.lng,
    required this.onCapture,
    required this.onPickFromMap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasLocation = lat != null && lng != null;

    return Column(
      children: [
        InkWell(
          onTap: onCapture,
          borderRadius: BorderRadius.circular(SigapRadius.md),
          child: Container(
            padding: const EdgeInsets.all(SigapSpacing.md),
            decoration: BoxDecoration(
              color: hasLocation
                  ? SigapColors.primaryLight
                  : SigapColors.bgSurface,
              borderRadius: BorderRadius.circular(SigapRadius.md),
              border: Border.all(
                color: hasLocation
                    ? SigapColors.primary.withValues(alpha: 0.3)
                    : SigapColors.borderCard,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.my_location,
                  color: hasLocation
                      ? SigapColors.primary
                      : SigapColors.textSecondary,
                  size: 24,
                ),
                const SizedBox(width: SigapSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasLocation
                            ? l10n.lokasiTerdeteksi
                            : l10n.ambilLokasiGps,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: hasLocation
                              ? SigapColors.primary
                              : SigapColors.textPrimary,
                        ),
                      ),
                      if (hasLocation) ...[
                        const SizedBox(height: 2),
                        Text(
                          '${lat!.toStringAsFixed(6)}, ${lng!.toStringAsFixed(6)}',
                          style: const TextStyle(
                            fontSize: SigapTypography.bodySmall,
                            color: SigapColors.textSecondary,
                          ),
                        ),
                      ] else ...[
                        const SizedBox(height: 2),
                        Text(
                          l10n.tapUntukMendapatkanLokasi,
                          style: TextStyle(
                            fontSize: SigapTypography.bodySmall,
                            color: SigapColors.textTertiary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (hasLocation)
                  const Icon(
                    Icons.check_circle,
                    color: SigapColors.primary,
                    size: 20,
                  )
                else
                  const Icon(
                    Icons.chevron_right,
                    color: SigapColors.textSecondary,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: SigapSpacing.sm),
        TextButton.icon(
          icon: const Icon(Icons.map, size: 16),
          label: Text(AppLocalizations.of(context)!.pilihDiPeta),
          onPressed: onPickFromMap,
        ),
      ],
    );
  }
}

// ─── Vulnerability Index Segment ───────────────────────────────────────────

class _VulnerabilitySegment extends StatelessWidget {
  final String label;
  final double value;
  final double groupValue;
  final ValueChanged<double> onChanged;

  const _VulnerabilitySegment({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = groupValue == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: SigapSpacing.md),
          decoration: BoxDecoration(
            color: isSelected ? SigapColors.primary : SigapColors.bgSurface,
            borderRadius: BorderRadius.circular(SigapRadius.md),
            border: Border.all(
              color: isSelected ? SigapColors.primary : SigapColors.border,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: SigapTypography.bodyText,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? SigapColors.surface
                    : SigapColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Duplicate Cases Section (M-11) ──────────────────────────────────────────

class _DuplicateCasesSection extends ConsumerWidget {
  final double lat;
  final double lng;
  final String? categoryId;

  const _DuplicateCasesSection({
    required this.lat,
    required this.lng,
    required this.categoryId,
  });

  /// Converts API response map to SimilarCase model.
  SimilarCase _mapToSimilarCase(Map<String, dynamic> json) {
    final title = json['title']?.toString() ?? '';
    // Derive initials from title (first letters of first 2 words)
    final words = title.trim().split(' ');
    String initials;
    if (words.isEmpty) {
      initials = '??';
    } else if (words.length == 1) {
      initials = words[0]
          .substring(0, words[0].length.clamp(0, 2))
          .toUpperCase();
    } else {
      initials = '${words[0][0]}${words[1][0]}'.toUpperCase();
    }

    final distanceM = (json['distance_m'] as num?)?.toDouble() ?? 0.0;
    final reportCount = (json['report_count'] as num?)?.toInt() ?? 0;
    final similarityPercent =
        (((json['similarity_score'] as num?)?.toDouble() ?? 0.0) * 100).round();

    return SimilarCase(
      id: json['report_id']?.toString() ?? '',
      initials: json['initials']?.toString() ?? initials,
      title: title,
      distance: '${distanceM.round()} m',
      similarityPercent: similarityPercent,
      reportCount: reportCount,
    );
  }

  /// Shows a bottom sheet displaying all similar cases with options to view details
  /// or add evidence to each case.
  void _showAllSimilarCasesBottomSheet(
    BuildContext context,
    List<SimilarCase> cases,
  ) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (_, scrollController) => Container(
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
              Padding(
                padding: const EdgeInsets.all(SigapSpacing.xl),
                child: Text(
                  l10n.kasusSerupa(cases.length),
                  style: const TextStyle(
                    fontSize: SigapTypography.titleLarge,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: cases.length,
                  itemBuilder: (_, index) {
                    final c = cases[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: SigapColors.primaryLight,
                        child: Text(
                          c.initials,
                          style: const TextStyle(
                            color: SigapColors.roleVerifikator,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(c.title),
                      subtitle: Text(
                        l10n.infoSerupa(
                          c.distance,
                          c.similarityPercent,
                          c.reportCount,
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.pop(ctx);
                        context.push('/laporan/${c.id}');
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Similar cases are fetched from GET /api/reports/duplicates using
    // location + category entered during report creation (M-11).
    final similarAsync = ref.watch(
      similarCasesProvider(
        SimilarCasesParams(lat: lat, lng: lng, categoryId: categoryId!),
      ),
    );

    return similarAsync.when(
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => const SizedBox.shrink(), // Silent fail, banner hidden
      data: (duplicates) {
        if (duplicates.isEmpty) return const SizedBox.shrink();
        final cases = duplicates.map(_mapToSimilarCase).toList();
        return SimilarCasesBanner(
          cases: cases,
          onViewAll: () {
            // Show bottom sheet with full list of duplicate cases
            _showAllSimilarCasesBottomSheet(context, cases);
          },
          onAddEvidence: (selectedCase) {
            // Navigate to evidence submission for the selected existing case
            context.push('/evidence/${selectedCase.id}');
          },
          onCreateSeparate: () {
            // User chose to create separate case - continue with current report
            // No navigation needed; form continues normally
          },
        );
      },
    );
  }
}

// ─── Main Screen ─────────────────────────────────────────────────────────────

class _PhotoEntry {
  final String path;
  final String? exifJson;
  _PhotoEntry({required this.path, this.exifJson});
}

class _CreateReportScreenState extends ConsumerState<CreateReportScreen> {
  static final _logger = Logger('CreateReportScreen');
  final _formKey = GlobalKey<FormState>();
  final List<_PhotoEntry> _photos = [];
  final ImagePicker _picker = ImagePicker();
  double? _lat;
  double? _lng;
  String? _categoryId;
  final _descriptionController = TextEditingController();
  final _populationAffectedController = TextEditingController();
  int _populationAffected = 0;
  double _vulnerabilityIndex = 0.5;
  final Set<String> _selectedDampak = {};
  bool _submitting = false;
  bool _isDirty = false;
  DateTime? _autosaveTimestamp;
  Timer? _autosaveTimer;
  late final String _draftId = const Uuid().v4();

  /// Strips EXIF data from JPEG bytes using the image package.
  /// Throws [Exception] if stripping fails — never returns original bytes.
  Uint8List _stripExifFromJpeg(Uint8List bytes) {
    final image = img.decodeImage(bytes);
    if (image == null) {
      throw Exception(AppLocalizations.of(context)!.gagalMendekodeGambar);
    }
    final strippedBytes = Uint8List.fromList(img.encodeJpg(image, quality: 85));
    _logger.info('EXIF data stripped from image');
    return strippedBytes;
  }

  void _showPhotoSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: SigapColors.primary),
              title: Text(AppLocalizations.of(context)!.kamera),
              onTap: () {
                Navigator.pop(ctx);
                _pickPhoto(cameraSource());
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: SigapColors.primary,
              ),
              title: Text(AppLocalizations.of(context)!.galeri),
              onTap: () {
                Navigator.pop(ctx);
                _pickPhoto(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickPhoto(ImageSource source) async {
    if (_photos.length >= 5) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.maksimal5Foto)),
        );
      }
      return;
    }

    final photo = await _picker.pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    if (photo != null) {
      String? exifJson;
      try {
        final bytes = await photo.readAsBytes();
        final exifData = await readExifFromBytes(bytes);
        if (exifData.isNotEmpty) {
          exifJson = jsonEncode({
            for (final entry in exifData.entries)
              entry.key: entry.value.toString(),
          });
        }
        final strippedBytes = _stripExifFromJpeg(bytes);
        final tempDir = await getTemporaryDirectory();
        final strippedFile = File(
          '${tempDir.path}/photo_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        await strippedFile.writeAsBytes(strippedBytes);
        if (mounted) {
          setState(() {
            _photos.add(
              _PhotoEntry(path: strippedFile.path, exifJson: exifJson),
            );
          });
          _onFormChanged();
        }
        _logger.info('Photo captured: ${strippedFile.path}');
      } catch (e, s) {
        _logger.warning('Error capturing photo', e, s);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(
                  context,
                )!.gagalHapusMetadataFoto(e.toString()),
              ),
              backgroundColor: SigapColors.danger,
            ),
          );
        }
      }
    }
  }

  Future<void> _captureLocation() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      final requested = await Geolocator.requestPermission();
      if (requested == LocationPermission.denied ||
          requested == LocationPermission.deniedForever) {
        _showLocationPickerDialog();
        return;
      }
    } else if (permission == LocationPermission.deniedForever) {
      _showLocationPickerDialog();
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      if (mounted) {
        setState(() {
          _lat = position.latitude;
          _lng = position.longitude;
        });
        _onFormChanged();
      }
    } catch (e, s) {
      _logger.warning('Error getting location', e, s);
      if (mounted) {
        _showLocationPickerDialog();
      }
    }
  }

  void _showLocationPickerDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        final dl10n = AppLocalizations.of(ctx)!;
        return AlertDialog(
          title: Text(dl10n.lokasiTidakTersedia),
          content: Text(dl10n.tidakDapatAksesGps),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(dl10n.batal),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _openMapPicker();
              },
              child: Text(dl10n.pilihDiPeta),
            ),
          ],
        );
      },
    );
  }

  void _openMapPicker() async {
    final result = await context.push<LatLng>('/map-picker');
    if (result != null && mounted) {
      setState(() {
        _lat = result.latitude;
        _lng = result.longitude;
      });
      _onFormChanged();
    }
  }

  static const String _deviceIdKey = 'anonymous_device_id';

  /// Gets or generates a persistent device ID for anonymous reports.
  Future<String> _getOrCreateDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString(_deviceIdKey);
    if (deviceId == null) {
      deviceId = const Uuid().v4();
      await prefs.setString(_deviceIdKey, deviceId);
      _logger.info('Generated new anonymous device_id: $deviceId');
    }
    return deviceId;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_photos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.ambilFotoTerlebihDahulu),
        ),
      );
      return;
    }
    if (_lat == null || _lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.aktifkanLokasiUntukMelapor,
          ),
          backgroundColor: SigapColors.danger,
        ),
      );
      return;
    }
    if (_categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.pilihKategoriTerlebihDahulu,
          ),
        ),
      );
      return;
    }

    // Anonymous mode submission
    if (widget.anonymousMode) {
      await _submitAnonymous();
      return;
    }

    // Regular authenticated submission
    setState(() => _submitting = true);

    try {
      final client = ref.read(apiClientProvider);
      final idempotencyKey = const Uuid().v4();

      // Step 1: Upload photos FIRST (matching web SPA canonical flow)
      final uploadedUrls = <String>[];
      for (var i = 0; i < _photos.length; i++) {
        try {
          final url = await client.uploadReportPhotoAnon(
            _photos[i].path,
            idempotencyKey,
            slot: i,
          );
          uploadedUrls.add(url);
          _logger.info('Photo $i uploaded: $url');
        } catch (e) {
          _logger.warning('Photo $i upload failed: $e');
          uploadedUrls.add(_photos[i].path); // fallback to local
        }
      }

      // Step 2: Create report with photo URLs in body
      final result = await client.submitReport(
        idempotencyKey: idempotencyKey,
        categoryId: _categoryId!,
        description: _descriptionController.text,
        lat: _lat!,
        lng: _lng!,
        photoUrls: uploadedUrls,
        populationAffected: _populationAffected,
        vulnerabilityIndex: _vulnerabilityIndex,
        impactDampak: _selectedDampak.isNotEmpty
            ? _selectedDampak.toList()
            : null,
      );

      if (result.duplicate) {
        _logger.info('Report detected as duplicate: ${result.id}');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.laporanTersimpanTerkirim,
            ),
            backgroundColor: SigapColors.warning,
          ),
        );
        context.pop();
        return;
      }

      final serverReportId = result.id ?? idempotencyKey;
      _logger.info('Authenticated report submitted: id=$serverReportId');

      // Save locally for offline support
      final reportRepo = ref.read(reportRepositoryProvider);
      await reportRepo.saveLocal(
        LocalReportsCompanion.insert(
          idempotencyKey: idempotencyKey,
          categoryId: _categoryId!,
          description: _descriptionController.text,
          lat: _lat!,
          lng: _lng!,
          photoPath: Value(uploadedUrls.isNotEmpty ? uploadedUrls.first : ''),
          exifDataJson: Value(
            _photos.isNotEmpty ? _photos.first.exifJson : null,
          ),
          populationAffected: Value(_populationAffected),
          vulnerabilityIndex: Value(_vulnerabilityIndex),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      // Insert photo records for ALL photos
      final db = ref.read(databaseProvider);
      for (var i = 0; i < uploadedUrls.length; i++) {
        await db.insertPhoto(
          reportIdempotencyKey: idempotencyKey,
          filePath: uploadedUrls[i],
          exifDataJson: _photos[i].exifJson,
          capturedAt: DateTime.now().millisecondsSinceEpoch,
        );
      }

      // Enqueue for sync (status updates, photo uploads, etc.)
      final queueRepo = ref.read(syncQueueRepositoryProvider);
      await queueRepo.enqueue(idempotencyKey, kind: 'report');

      ref.invalidate(localReportsProvider);
      ref.invalidate(pendingCountProvider);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.laporanTersimpanTerkirim),
          backgroundColor: SigapColors.primary,
        ),
      );
      context.pop();
    } catch (e, s) {
      _logger.error('Submit failed', e, s);
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.gagalMenyimpan(e.toString()),
          ),
          backgroundColor: SigapColors.danger,
        ),
      );
    }
  }

  /// Submits an anonymous report directly to the API.
  Future<void> _submitAnonymous() async {
    setState(() => _submitting = true);

    try {
      final deviceId = await _getOrCreateDeviceId();
      final client = ref.read(apiClientProvider);
      final idempotencyKey = const Uuid().v4();

      // Step 1: Upload photos FIRST (matching web SPA canonical flow)
      final uploadedUrls = <String>[];
      for (var i = 0; i < _photos.length; i++) {
        try {
          final url = await client.uploadReportPhotoAnon(
            _photos[i].path,
            idempotencyKey,
            slot: i,
          );
          uploadedUrls.add(url);
          _logger.info('Anonymous photo $i uploaded: $url');
        } catch (e) {
          _logger.warning('Anonymous photo $i upload failed: $e');
          uploadedUrls.add(_photos[i].path); // fallback to local
        }
      }

      // Step 2: Create report with photo URLs in body
      final result = await client.submitReport(
        idempotencyKey: idempotencyKey,
        deviceId: deviceId,
        categoryId: _categoryId!,
        description: _descriptionController.text,
        lat: _lat!,
        lng: _lng!,
        photoUrls: uploadedUrls,
        populationAffected: _populationAffected,
        vulnerabilityIndex: _vulnerabilityIndex,
        impactDampak: _selectedDampak.isNotEmpty
            ? _selectedDampak.toList()
            : null,
        anonymous: true,
      );

      if (result.duplicate) {
        _logger.info('Anonymous report detected as duplicate: ${result.id}');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(
                context,
              )!.laporanAnonimTersimpanId(result.id ?? ''),
            ),
            backgroundColor: SigapColors.warning,
          ),
        );
        context.pop();
        return;
      }

      _logger.info(
        'Anonymous report submitted: id=${result.id}, photos=${uploadedUrls.length}',
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(
              context,
            )!.laporanAnonimTersimpanId(result.id ?? ''),
          ),
          backgroundColor: SigapColors.primary,
        ),
      );
      context.pop();
    } catch (e, s) {
      _logger.error('Anonymous submit failed', e, s);
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.gagalMenyimpan(e.toString()),
          ),
          backgroundColor: SigapColors.danger,
        ),
      );
    }
  }

  /// Called whenever form fields change to trigger autosave debounce.
  void _onFormChanged() {
    if (_submitting) return; // Don't autosave during submission
    setState(() => _isDirty = true);
    _autosaveTimer?.cancel();
    _autosaveTimer = Timer(const Duration(seconds: 2), () {
      if (_isDirty && mounted) {
        _autosaveDraft();
      }
    });
  }

  /// Autosaves form state to LocalReports with debounce.
  /// Skips saving if GPS coordinates are not available (prevents Null-Island defaults).
  Future<void> _autosaveDraft() async {
    if (!_isDirty) return;
    // Skip autosave if GPS is not available - don't save Null-Island coordinates
    if (_lat == null || _lng == null) return;
    try {
      final reportRepo = ref.read(reportRepositoryProvider);
      final now = DateTime.now();
      await reportRepo.saveLocal(
        LocalReportsCompanion.insert(
          idempotencyKey: _draftId,
          categoryId: _categoryId ?? '',
          description: _descriptionController.text,
          lat: _lat!,
          lng: _lng!,
          photoPath: Value(_photos.isNotEmpty ? _photos.first.path : null),
          exifDataJson: Value(
            _photos.isNotEmpty ? _photos.first.exifJson : null,
          ),
          populationAffected: Value(_populationAffected),
          vulnerabilityIndex: Value(_vulnerabilityIndex),
          createdAt: now,
          updatedAt: now,
        ),
      );
      setState(() {
        _isDirty = false;
        _autosaveTimestamp = now;
      });
      _logger.info('Autosave triggered');
    } catch (e, s) {
      _logger.warning('Autosave failed', e, s);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ResponsiveScaffold(
      appBar: SigapAppBar(
        title: l10n.buatLaporan,
        subtitle: _autosaveTimestamp != null
            ? l10n.tersimpanPada(
                _TimeOfDayFormatter.format(_autosaveTimestamp!),
              )
            : null,
      ),
      body: Column(
        children: [
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(SigapSpacing.lg),
                children: [
                  // Photo Section
                  _sectionCard(
                    title: l10n.sectionAmbilFoto,
                    icon: Icons.add_a_photo,
                    child: _PhotoSection(
                      photos: _photos,
                      onAdd: _showPhotoSourceDialog,
                      onRemove: (index) =>
                          setState(() => _photos.removeAt(index)),
                    ),
                  ),
                  const SizedBox(height: SigapSpacing.lg),

                  // Location Section
                  _sectionCard(
                    title: l10n.sectionLokasi,
                    icon: Icons.location_on,
                    child: _LocationSection(
                      lat: _lat,
                      lng: _lng,
                      onCapture: _captureLocation,
                      onPickFromMap: _openMapPicker,
                    ),
                  ),
                  const SizedBox(height: SigapSpacing.lg),

                  // Category Section
                  _sectionCard(
                    title: l10n.kategori,
                    icon: Icons.category,
                    child: _CategorySection(
                      selectedCategoryId: _categoryId,
                      onChanged: (v) {
                        setState(() => _categoryId = v);
                        _onFormChanged();
                      },
                    ),
                  ),
                  const SizedBox(height: SigapSpacing.lg),

                  // Similar Cases Banner (M-11)
                  if (_lat != null && _lng != null && _categoryId != null)
                    _DuplicateCasesSection(
                      lat: _lat!,
                      lng: _lng!,
                      categoryId: _categoryId,
                    ),
                  if (_lat != null && _lng != null && _categoryId != null)
                    const SizedBox(height: SigapSpacing.lg),

                  // Description Section
                  _sectionCard(
                    title: l10n.sectionDeskripsi,
                    icon: Icons.description,
                    child: TextFormField(
                      controller: _descriptionController,
                      onChanged: (_) => _onFormChanged(),
                      decoration: InputDecoration(
                        labelText: l10n.labelJelaskanLaporan,
                        labelStyle: const TextStyle(
                          color: SigapColors.textSecondary,
                        ),
                        hintText: l10n.minimal10Karakter,
                        hintStyle: TextStyle(color: SigapColors.textTertiary),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 4,
                      maxLength: 2000,
                      validator: (v) => v == null || v.length < 10
                          ? l10n.minimal10KarakterValidasi
                          : null,
                    ),
                  ),
                  const SizedBox(height: SigapSpacing.lg),

                  // Population Affected Section
                  _sectionCard(
                    title: l10n.sectionPerkiraanTerdampak,
                    icon: Icons.people,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _populationAffectedController,
                          onChanged: (v) {
                            final parsed = int.tryParse(v);
                            if (parsed != null && parsed >= 0) {
                              setState(() => _populationAffected = parsed);
                              _onFormChanged();
                            }
                          },
                          decoration: InputDecoration(
                            labelText: l10n.labelPerkiraanTerdampak,
                            labelStyle: TextStyle(
                              color: SigapColors.textSecondary,
                            ),
                            hintText: '0',
                            hintStyle: TextStyle(
                              color: SigapColors.textTertiary,
                            ),
                            suffixText: l10n.orang,
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: SigapSpacing.sm),
                        Text(
                          l10n.jumlahPerkiraanTerdampak,
                          style: TextStyle(
                            fontSize: SigapTypography.bodySmall,
                            color: SigapColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: SigapSpacing.lg),

                  // Vulnerability Index Section
                  _sectionCard(
                    title: l10n.sectionTingkatKerentanan,
                    icon: Icons.warning,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.seberapaRentan,
                          style: TextStyle(
                            fontSize: SigapTypography.bodySmall,
                            color: SigapColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: SigapSpacing.md),
                        Row(
                          children: [
                            _VulnerabilitySegment(
                              label: l10n.rendah,
                              value: 0.25,
                              groupValue: _vulnerabilityIndex,
                              onChanged: (v) {
                                setState(() => _vulnerabilityIndex = v);
                                _onFormChanged();
                              },
                            ),
                            const SizedBox(width: SigapSpacing.sm),
                            _VulnerabilitySegment(
                              label: l10n.sedang,
                              value: 0.5,
                              groupValue: _vulnerabilityIndex,
                              onChanged: (v) {
                                setState(() => _vulnerabilityIndex = v);
                                _onFormChanged();
                              },
                            ),
                            const SizedBox(width: SigapSpacing.sm),
                            _VulnerabilitySegment(
                              label: l10n.tinggi,
                              value: 0.75,
                              groupValue: _vulnerabilityIndex,
                              onChanged: (v) {
                                setState(() => _vulnerabilityIndex = v);
                                _onFormChanged();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: SigapSpacing.lg),

                  // Dampak Section
                  _sectionCard(
                    title: l10n.sectionDampak,
                    icon: Icons.warning,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.pilihJenisDampak,
                          style: TextStyle(
                            fontSize: SigapTypography.bodySmall,
                            color: SigapColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: SigapSpacing.md),
                        Wrap(
                          spacing: SigapSpacing.sm,
                          runSpacing: SigapSpacing.sm,
                          children:
                              [
                                l10n.keselamatan,
                                l10n.aksesWilayah,
                                l10n.layananSekolah,
                                l10n.ekonomi,
                                l10n.lingkungan,
                              ].map((dampak) {
                                final isSelected = _selectedDampak.contains(
                                  dampak,
                                );
                                return FilterChip(
                                  label: Text(dampak),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        _selectedDampak.add(dampak);
                                      } else {
                                        _selectedDampak.remove(dampak);
                                      }
                                    });
                                    _onFormChanged();
                                  },
                                );
                              }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: SigapSpacing.xxl,
                  ), // Space for bottom CTA
                ],
              ),
            ),
          ),

          // Bottom CTA Button
          Container(
            padding: EdgeInsets.fromLTRB(
              SigapSpacing.lg,
              SigapSpacing.md,
              SigapSpacing.lg,
              SigapSpacing.lg + MediaQuery.of(context).padding.bottom,
            ),
            decoration: const BoxDecoration(
              color: SigapColors.bgCard,
              border: Border(top: BorderSide(color: SigapColors.borderCard)),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: SigapColors.primary,
                  foregroundColor: SigapColors.surface,
                  disabledBackgroundColor: SigapColors.primary.withValues(
                    alpha: 0.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(SigapRadius.md),
                  ),
                  elevation: 0,
                ),
                child: _submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            SigapColors.surface,
                          ),
                        ),
                      )
                    : Text(
                        l10n.kirimLaporan,
                        style: const TextStyle(
                          fontSize: SigapTypography.titleMedium,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _autosaveTimer?.cancel();
    _descriptionController.dispose();
    super.dispose();
  }
}

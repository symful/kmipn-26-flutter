import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' show Value;
import 'package:exif/exif.dart';
import 'package:image/image.dart' as img;
import '../../theme/tokens.dart';
import '../../db/database.dart';
import '../../providers/providers.dart';
import '../../utils/logger.dart';

class CreateReportScreen extends ConsumerStatefulWidget {
  const CreateReportScreen({super.key});
  @override
  ConsumerState<CreateReportScreen> createState() => _CreateReportScreenState();
}

// ─── Section Card Widget ──────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderCard),
          Padding(padding: const EdgeInsets.all(AppSpacing.lg), child: child),
        ],
      ),
    );
  }
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
  final List<Map<String, dynamic>> categories;
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
      decoration: const InputDecoration(
        labelText: 'Pilih Kategori',
        labelStyle: TextStyle(color: AppColors.textSecondary),
        hintText: 'Tap untuk memilih kategori',
        hintStyle: TextStyle(color: AppColors.textTertiary),
      ),
      initialValue: selectedCategoryId,
      items: categories.map((cat) {
        return DropdownMenuItem(
          value: cat['id'].toString(),
          child: Text(cat['name']?.toString() ?? ''),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (v) => v == null ? 'Pilih kategori' : null,
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
          decoration: const InputDecoration(
            labelText: 'Kategori',
            errorText: null,
          ),
          child: Row(
            children: [
              const Icon(Icons.error_outline, color: AppColors.danger),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  error,
                  style: const TextStyle(color: AppColors.danger, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ElevatedButton.icon(
          icon: const Icon(Icons.refresh, size: 18),
          label: const Text('Coba Lagi'),
          onPressed: () => ref.invalidate(categoriesProvider),
        ),
      ],
    );
  }
}

// ─── Photo Section ────────────────────────────────────────────────────────────

class _PhotoSection extends StatelessWidget {
  final String? photoPath;
  final VoidCallback onCapture;

  const _PhotoSection({required this.photoPath, required this.onCapture});

  @override
  Widget build(BuildContext context) {
    if (photoPath != null) {
      return Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Image.file(
              File(photoPath!),
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            icon: const Icon(Icons.camera_alt, size: 18),
            label: const Text('Ambil Ulang Foto'),
            onPressed: onCapture,
          ),
        ],
      );
    }

    return InkWell(
      onTap: onCapture,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_a_photo, color: AppColors.primary, size: 40),
              SizedBox(height: AppSpacing.sm),
              Text(
                'Ambil Foto',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Tap untuk membuka kamera',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
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
    final hasLocation = lat != null && lng != null;

    return Column(
      children: [
        InkWell(
          onTap: onCapture,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: hasLocation ? AppColors.primaryLight : AppColors.bgSurface,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: hasLocation
                    ? AppColors.primary.withValues(alpha: 0.3)
                    : AppColors.borderCard,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.my_location,
                  color: hasLocation
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  size: 24,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasLocation ? 'Lokasi Terdeteksi' : 'Ambil Lokasi GPS',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: hasLocation
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                      ),
                      if (hasLocation) ...[
                        const SizedBox(height: 2),
                        Text(
                          '${lat!.toStringAsFixed(6)}, ${lng!.toStringAsFixed(6)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ] else ...[
                        const SizedBox(height: 2),
                        const Text(
                          'Tap untuk mendapatkan lokasi saat ini',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (hasLocation)
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.primary,
                    size: 20,
                  )
                else
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextButton.icon(
          icon: const Icon(Icons.map, size: 16),
          label: const Text('Pilih di Peta'),
          onPressed: onPickFromMap,
        ),
      ],
    );
  }
}

// ─── Main Screen ─────────────────────────────────────────────────────────────

class _CreateReportScreenState extends ConsumerState<CreateReportScreen> {
  static final _logger = Logger('CreateReportScreen');
  final _formKey = GlobalKey<FormState>();
  String? _photoPath;
  String? _exifDataJson;
  double? _lat;
  double? _lng;
  String? _categoryId;
  final _descriptionController = TextEditingController();
  bool _submitting = false;

  static const int maxPending = 50;

  /// Strips EXIF data from JPEG bytes using the image package.
  Uint8List _stripExifFromJpeg(Uint8List bytes) {
    try {
      final image = img.decodeImage(bytes);
      if (image == null) {
        _logger.warning('Failed to decode image for EXIF stripping');
        return bytes;
      }
      final strippedBytes = Uint8List.fromList(
        img.encodeJpg(image, quality: 85),
      );
      _logger.info('EXIF data stripped from image');
      return strippedBytes;
    } catch (e, s) {
      _logger.warning('Error stripping EXIF', e, s);
      return bytes;
    }
  }

  Future<void> _capturePhoto() async {
    final picker = ImagePicker();
    final photo = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
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
            _photoPath = strippedFile.path;
            _exifDataJson = exifJson;
          });
        }
        _logger.info('Photo captured: ${strippedFile.path}');
      } catch (e, s) {
        _logger.warning('Error capturing photo', e, s);
        if (mounted) {
          setState(() {
            _photoPath = photo.path;
            _exifDataJson = null;
          });
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
      builder: (context) => AlertDialog(
        title: const Text('Lokasi Tidak Tersedia'),
        content: const Text(
          'Tidak dapat mengakses GPS. Pilih lokasi manual di peta.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _openMapPicker();
            },
            child: const Text('Pilih di Peta'),
          ),
        ],
      ),
    );
  }

  void _openMapPicker() {
    ref.read(pickLocationCallbackProvider.notifier).state = (latLng) {
      if (mounted) {
        setState(() {
          _lat = latLng.latitude;
          _lng = latLng.longitude;
        });
      }
      ref.read(pickLocationCallbackProvider.notifier).state = null;
    };
    ref.read(pickLocationModeProvider.notifier).state = true;
    context.push('/map');
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_photoPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ambil foto terlebih dahulu')),
      );
      return;
    }
    if (_lat == null || _lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tentukan lokasi terlebih dahulu')),
      );
      return;
    }
    if (_categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih kategori terlebih dahulu')),
      );
      return;
    }

    final pendingCount = await ref
        .read(reportRepositoryProvider)
        .countPending();
    if (pendingCount >= maxPending) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Batas tercapai: $maxPending laporan belum tersinkron. Sinkronkan dulu.',
          ),
        ),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      final idempotencyKey = const Uuid().v4();
      final reportRepo = ref.read(reportRepositoryProvider);

      await reportRepo.saveLocal(
        LocalReportsCompanion.insert(
          idempotencyKey: idempotencyKey,
          categoryId: _categoryId!,
          description: _descriptionController.text,
          lat: _lat!,
          lng: _lng!,
          photoPath: Value(_photoPath),
          exifDataJson: Value(_exifDataJson),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      // Insert photo record
      final db = ref.read(databaseProvider);
      await db.insertPhoto(
        reportIdempotencyKey: idempotencyKey,
        filePath: _photoPath!,
        exifDataJson: _exifDataJson,
        capturedAt: DateTime.now().millisecondsSinceEpoch,
      );

      // Upload photo
      try {
        final api = ref.read(apiClientProvider);
        final photoFile = File(_photoPath!);
        final photoBytes = await photoFile.readAsBytes();
        final filename = _photoPath!.split('/').last;
        final uploadUrl = '/api/reports/$idempotencyKey/photos/upload-url';
        await api.uploadPhotoBytes(uploadUrl, photoBytes, filename);
        _logger.info('Photo uploaded for report: $idempotencyKey');
      } catch (e, s) {
        _logger.warning('Photo upload failed, will sync later', e, s);
      }

      // Enqueue for sync
      final queueRepo = ref.read(syncQueueRepositoryProvider);
      await queueRepo.enqueue(idempotencyKey);

      ref.invalidate(localReportsProvider);
      ref.invalidate(pendingCountProvider);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Laporan tersimpan. Akan sinkron otomatis.'),
          backgroundColor: AppColors.primary,
        ),
      );
      context.pop();
    } catch (e, s) {
      _logger.error('Submit failed', e, s);
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan: $e'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgSurface,
      appBar: AppBar(
        title: const Text('Buat Laporan'),
        backgroundColor: AppColors.bgCard,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  // Photo Section
                  _SectionCard(
                    title: 'Ambil Foto',
                    icon: Icons.add_a_photo,
                    child: _PhotoSection(
                      photoPath: _photoPath,
                      onCapture: _capturePhoto,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Location Section
                  _SectionCard(
                    title: 'Lokasi',
                    icon: Icons.location_on,
                    child: _LocationSection(
                      lat: _lat,
                      lng: _lng,
                      onCapture: _captureLocation,
                      onPickFromMap: _openMapPicker,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Category Section
                  _SectionCard(
                    title: 'Kategori',
                    icon: Icons.category,
                    child: _CategorySection(
                      selectedCategoryId: _categoryId,
                      onChanged: (v) => setState(() => _categoryId = v),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Description Section
                  _SectionCard(
                    title: 'Deskripsi',
                    icon: Icons.description,
                    child: TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Jelaskan laporan Anda',
                        labelStyle: TextStyle(color: AppColors.textSecondary),
                        hintText: 'Minimal 10 karakter...',
                        hintStyle: TextStyle(color: AppColors.textTertiary),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 4,
                      maxLength: 2000,
                      validator: (v) => v == null || v.length < 10
                          ? 'Minimal 10 karakter'
                          : null,
                    ),
                  ),
                  const SizedBox(
                    height: AppSpacing.xxl,
                  ), // Space for bottom CTA
                ],
              ),
            ),
          ),

          // Bottom CTA Button
          Container(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.lg + MediaQuery.of(context).padding.bottom,
            ),
            decoration: const BoxDecoration(
              color: AppColors.bgCard,
              border: Border(top: BorderSide(color: AppColors.borderCard)),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.primary.withValues(
                    alpha: 0.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
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
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text(
                        'Kirim Laporan',
                        style: TextStyle(
                          fontSize: 16,
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
    _descriptionController.dispose();
    super.dispose();
  }
}

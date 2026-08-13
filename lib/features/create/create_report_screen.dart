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

/// Widget that handles category loading with cache fallback and error handling
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
      decoration: const InputDecoration(labelText: 'Kategori'),
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
              Icon(
                Icons.error_outline,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  error,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: SigapSpacing.sm),
        ElevatedButton.icon(
          icon: const Icon(Icons.refresh),
          label: const Text('Coba Lagi'),
          onPressed: () => ref.invalidate(categoriesProvider),
        ),
      ],
    );
  }
}

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
  /// Decoding and re-encoding naturally removes EXIF metadata.
  /// Returns the original bytes if stripping fails.
  Uint8List _stripExifFromJpeg(Uint8List bytes) {
    try {
      final image = img.decodeImage(bytes);
      if (image == null) {
        _logger.warning('Failed to decode image for EXIF stripping');
        return bytes;
      }
      // Re-encode as JPEG - EXIF is stripped by default during decode/encode
      final strippedBytes = Uint8List.fromList(
        img.encodeJpg(image, quality: 95),
      );
      _logger.info('EXIF data stripped from image using image package');
      return strippedBytes;
    } catch (e, s) {
      _logger.warning('Error stripping EXIF using image package', e, s);
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
        // Strip EXIF data from image bytes
        final strippedBytes = _stripExifFromJpeg(bytes);
        // Save stripped image to temp file
        final tempDir = await getTemporaryDirectory();
        final strippedFile = File(
          '${tempDir.path}/photo_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        await strippedFile.writeAsBytes(strippedBytes);
        setState(() {
          _photoPath = strippedFile.path;
          _exifDataJson = exifJson;
        });
        _logger.info('Photo captured with EXIF stripped: ${strippedFile.path}');
      } catch (e, s) {
        _logger.warning('Error capturing/stripping photo', e, s);
        // Fallback: use original photo without stripping
        setState(() {
          _photoPath = photo.path;
          _exifDataJson = null;
        });
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

    final position = await Geolocator.getCurrentPosition();
    if (mounted) {
      setState(() {
        _lat = position.latitude;
        _lng = position.longitude;
      });
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
    if (_photoPath == null ||
        _lat == null ||
        _lng == null ||
        _categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi foto, lokasi, dan kategori')),
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

    final idempotencyKey = const Uuid().v4();
    final reportRepo = ref.read(reportRepositoryProvider);
    final queueRepo = ref.read(syncQueueRepositoryProvider);

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

    // Insert photo record with EXIF data
    final db = ref.read(databaseProvider);
    await db.insertPhoto(
      reportIdempotencyKey: idempotencyKey,
      filePath: _photoPath!,
      exifDataJson: _exifDataJson,
      capturedAt: DateTime.now().millisecondsSinceEpoch,
    );

    // Upload stripped photo via Dio
    try {
      final api = ref.read(apiClientProvider);
      final photoFile = File(_photoPath!);
      final photoBytes = await photoFile.readAsBytes();
      final filename = _photoPath!.split('/').last;
      final uploadUrl = '/api/reports/$idempotencyKey/photos/upload-url';
      await api.uploadPhotoBytes(uploadUrl, photoBytes, filename);
      _logger.info('Photo uploaded successfully for report: $idempotencyKey');
    } catch (e, s) {
      _logger.warning('Failed to upload photo, will sync later', e, s);
      // Continue even if upload fails - sync worker will retry
    }

    await queueRepo.enqueue(idempotencyKey);

    ref.invalidate(localReportsProvider);
    ref.invalidate(pendingCountProvider);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Laporan tersimpan lokal. Akan sinkron otomatis.'),
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buat Laporan')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(SigapSpacing.lg),
          children: [
            if (_photoPath != null)
              Image.file(File(_photoPath!), height: 200, fit: BoxFit.cover),
            ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: Text(_photoPath == null ? 'Ambil Foto' : 'Ambil Ulang'),
              onPressed: _capturePhoto,
            ),
            const SizedBox(height: SigapSpacing.md),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _lat == null
                        ? 'Lokasi belum diambil'
                        : 'Lat: ${_lat!.toStringAsFixed(6)}, Lng: ${_lng!.toStringAsFixed(6)}',
                    style: TextStyle(
                      color: _lat == null
                          ? SigapColors.textMuted
                          : SigapColors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.my_location),
                  onPressed: _captureLocation,
                ),
              ],
            ),
            const SizedBox(height: SigapSpacing.md),
            _CategorySection(
              selectedCategoryId: _categoryId,
              onChanged: (v) => setState(() => _categoryId = v),
            ),
            const SizedBox(height: SigapSpacing.md),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Deskripsi'),
              maxLines: 3,
              maxLength: 2000,
              validator: (v) =>
                  v == null || v.length < 10 ? 'Minimal 10 karakter' : null,
            ),
            const SizedBox(height: SigapSpacing.lg),
            ElevatedButton(
              onPressed: _submitting ? null : _submit,
              child: Text(_submitting ? 'Menyimpan...' : 'Kirim'),
            ),
          ],
        ),
      ),
    );
  }
}

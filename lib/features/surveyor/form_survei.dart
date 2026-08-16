import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:exif/exif.dart';
import '../../db/database.dart';
import '../../providers/providers.dart';
import '../../theme/tokens.dart';
import '../../components/app_icons.dart';
import '../../widgets/design_system/phone_frame.dart';
import '../../widgets/design_system/status_bar.dart';

class FormSurveiScreen extends ConsumerStatefulWidget {
  final String? taskId;
  const FormSurveiScreen({super.key, this.taskId});

  @override
  ConsumerState<FormSurveiScreen> createState() => _FormSurveiScreenState();
}

class _PhotoEntry {
  final String path;
  final String? exifJson;
  _PhotoEntry({required this.path, this.exifJson});
}

class _FormSurveiScreenState extends ConsumerState<FormSurveiScreen> {
  final _damageDescriptionController = TextEditingController();
  final _notesController = TextEditingController();
  final List<_PhotoEntry> _photos = [];
  final ImagePicker _picker = ImagePicker();

  (double, double)? _capturedGps;
  bool _gpsLoading = false;
  bool _submitting = false;
  String? _submitError;
  bool _success = false;

  bool get _canSubmit {
    if (_damageDescriptionController.text.trim().length < 10) return false;
    if (_photos.isEmpty) return false;
    if (_capturedGps == null) return false;
    return true;
  }

  @override
  void dispose() {
    _damageDescriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _captureGps() async {
    setState(() => _gpsLoading = true);

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Izin lokasi ditolak')));
        }
        setState(() => _gpsLoading = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      setState(() {
        _capturedGps = (position.latitude, position.longitude);
        _gpsLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'GPS captured: ${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}',
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _gpsLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal capture GPS: $e')));
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (image != null) {
        String? exifJson;
        try {
          final bytes = await image.readAsBytes();
          final exifData = await readExifFromBytes(bytes);
          if (exifData.isNotEmpty) {
            exifJson = jsonEncode({
              for (final entry in exifData.entries)
                entry.key: entry.value.toString(),
            });
          }
        } catch (_) {
          // EXIF extraction failed, continue without it
        }
        setState(() {
          _photos.add(_PhotoEntry(path: image.path, exifJson: exifJson));
        });
      }
    } catch (e) {
      setState(() => _submitError = 'Gagal memilih gambar: $e');
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _photos.removeAt(index);
    });
  }

  void _showPhotoSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primary),
              title: const Text('Kamera'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: AppColors.primary,
              ),
              title: const Text('Galeri'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_canSubmit) return;

    setState(() {
      _submitting = true;
      _submitError = null;
    });

    try {
      final db = ref.read(databaseProvider);
      final now = DateTime.now().millisecondsSinceEpoch;
      final idempotencyKey = 'survei_${widget.taskId ?? 'standalone'}_$now';

      // Store photos locally with EXIF data
      for (final photo in _photos) {
        await db.insertPhoto(
          reportIdempotencyKey: idempotencyKey,
          filePath: photo.path,
          exifDataJson: photo.exifJson,
          capturedAt: now,
        );
      }

      // Build submission data
      final submitData = {
        'task_id': widget.taskId,
        'damage_description': _damageDescriptionController.text.trim(),
        'notes': _notesController.text.trim(),
        'gps': _capturedGps != null
            ? {'lat': _capturedGps!.$1, 'lng': _capturedGps!.$2}
            : null,
        'photo_count': _photos.length,
        'submitted_at': DateTime.now().toIso8601String(),
      };

      // Queue for later sync
      final taskRepo = ref.read(surveyorTaskRepositoryProvider);
      final queueRepo = ref.read(syncQueueRepositoryProvider);

      await taskRepo.saveVisit(
        idempotencyKey: idempotencyKey,
        taskId: widget.taskId ?? 'form_survei',
        visitData: submitData,
      );
      await queueRepo.enqueue(idempotencyKey);

      setState(() => _success = true);
    } catch (e) {
      setState(() => _submitError = e.toString());
    } finally {
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_success) {
      return PhoneFrame(
        child: Column(
          children: [
            StatusBar(),
            Expanded(
              child: Scaffold(
                appBar: AppBar(title: const Text('Form Survei')),
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: AppColors.primary,
                          size: 64,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        const Text(
                          'Survei berhasil dikirim!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Data survei telah tersimpan dan akan diproses oleh tim terkait.',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        ElevatedButton(
                          onPressed: () => context.go('/surveyor/tasks'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xl,
                              vertical: AppSpacing.md,
                            ),
                          ),
                          child: const Text('Kembali ke Daftar Tugas'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return PhoneFrame(
      child: Column(
        children: [
          StatusBar(),
          Expanded(
            child: Scaffold(
              appBar: AppBar(title: const Text('Form Survei')),
              body: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // GPS Section
                          _buildSectionHeader('Lokasi GPS', AppIcons.location),
                          const SizedBox(height: AppSpacing.sm),
                          _buildGpsCard(),
                          const SizedBox(height: AppSpacing.xl),

                          // Photo Grid Section
                          _buildSectionHeader('Foto Bukti', AppIcons.camera),
                          const SizedBox(height: AppSpacing.sm),
                          _buildPhotoGrid(),
                          const SizedBox(height: AppSpacing.xl),

                          // Damage Description
                          _buildSectionHeader('Deskripsi Kerusakan', null),
                          const SizedBox(height: AppSpacing.sm),
                          TextField(
                            controller: _damageDescriptionController,
                            maxLines: 4,
                            maxLength: 500,
                            decoration: InputDecoration(
                              hintText:
                                  'Jelaskan kerusakan atau temuan survei...',
                              hintStyle: TextStyle(
                                color: AppColors.textTertiary,
                              ),
                              filled: true,
                              fillColor: AppColors.bgCard,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.md,
                                ),
                                borderSide: const BorderSide(
                                  color: AppColors.borderCard,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.md,
                                ),
                                borderSide: const BorderSide(
                                  color: AppColors.borderCard,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.md,
                                ),
                                borderSide: const BorderSide(
                                  color: AppColors.primary,
                                  width: 2,
                                ),
                              ),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                          const SizedBox(height: AppSpacing.lg),

                          // Notes
                          _buildSectionHeader('Catatan Tambahan', null),
                          const SizedBox(height: AppSpacing.sm),
                          TextField(
                            controller: _notesController,
                            maxLines: 3,
                            maxLength: 300,
                            decoration: InputDecoration(
                              hintText: 'Tambahkan catatan jika diperlukan...',
                              hintStyle: TextStyle(
                                color: AppColors.textTertiary,
                              ),
                              filled: true,
                              fillColor: AppColors.bgCard,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.md,
                                ),
                                borderSide: const BorderSide(
                                  color: AppColors.borderCard,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.md,
                                ),
                                borderSide: const BorderSide(
                                  color: AppColors.borderCard,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.md,
                                ),
                                borderSide: const BorderSide(
                                  color: AppColors.primary,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),

                          // Error message
                          if (_submitError != null) ...[
                            const SizedBox(height: AppSpacing.lg),
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: AppColors.dangerBg,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.sm,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: AppColors.danger,
                                    size: 18,
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: Text(
                                      _submitError!,
                                      style: TextStyle(
                                        color: AppColors.danger,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(
                            height: 100,
                          ), // Space for bottom button
                        ],
                      ),
                    ),
                  ),

                  // Bottom Fixed Submit Button
                  Container(
                    padding: EdgeInsets.only(
                      left: AppSpacing.lg,
                      right: AppSpacing.lg,
                      top: AppSpacing.md,
                      bottom:
                          MediaQuery.of(context).padding.bottom + AppSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.textPrimary.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _canSubmit && !_submitting ? _submit : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                        disabledBackgroundColor: AppColors.borderCard,
                      ),
                      child: _submitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'Kirim Hasil',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Icon? icon) {
    return Row(
      children: [
        if (icon != null) ...[icon, const SizedBox(width: AppSpacing.sm)],
        Text(
          title,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildGpsCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderCard),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: _capturedGps != null
                  ? AppColors.primaryLight
                  : AppColors.bgSurface,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(
              Icons.location_on,
              color: _capturedGps != null
                  ? AppColors.primary
                  : AppColors.textTertiary,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _capturedGps != null
                      ? 'GPS Tertangkap'
                      : 'GPS Belum Tertangkap',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _capturedGps != null
                      ? '${_capturedGps!.$1.toStringAsFixed(6)}, ${_capturedGps!.$2.toStringAsFixed(6)}'
                      : 'Ketuk tombol untuk menangkap koordinat GPS',
                  style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
                ),
              ],
            ),
          ),
          if (_capturedGps != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Text(
                'OK',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            TextButton(
              onPressed: _gpsLoading ? null : _captureGps,
              child: _gpsLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Capture'),
            ),
        ],
      ),
    );
  }

  Widget _buildPhotoGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_photos.isEmpty)
          GestureDetector(
            onTap: _showPhotoSourceDialog,
            child: Container(
              height: 160,
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                  color: AppColors.borderCard,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_a_photo_outlined,
                    size: 48,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Belum ada foto',
                    style: TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ketuk untuk menambahkan foto',
                    style: TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppSpacing.sm,
              mainAxisSpacing: AppSpacing.sm,
              childAspectRatio: 1,
            ),
            itemCount: _photos.length + 1,
            itemBuilder: (context, index) {
              if (index == _photos.length) {
                // Add photo button
                return GestureDetector(
                  onTap: _showPhotoSourceDialog,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.bgSurface,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.borderCard),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, color: AppColors.primary, size: 32),
                        const SizedBox(height: 4),
                        Text(
                          'Tambah Foto',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Photo thumbnail
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: Image.file(
                      File(_photos[index].path),
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.bgSurface,
                        child: const Icon(Icons.image, size: 40),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => _removePhoto(index),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.textPrimary.withValues(alpha: 0.54),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

        if (_photos.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt, size: 18),
                  label: const Text('Kamera'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library, size: 18),
                  label: const Text('Galeri'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

// Helper for JSON encoding
String jsonEncode(Map<String, String> map) {
  final entries = map.entries.map((e) => '"${e.key}":"${e.value}"');
  return '{${entries.join(',')}}';
}

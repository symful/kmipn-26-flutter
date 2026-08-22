import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:exif/exif.dart';
import '../../db/database.dart';
import '../../l10n/strings.dart';
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

  // Kondisi: 0=Ringan, 1=Berat, 2=Kritis
  int _selectedKondisi = 0;
  // Rekomendasi: 0=Perbaikan, 1=Penggantian, 2=Monitoring
  int _selectedRekomendasi = 0;

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
                          Strings.surveiBerhasilDikirim,
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
              backgroundColor: AppColors.bgScreen,
              body: Column(
                children: [
                  // Custom Header with Back Arrow, Title, Task ID, Timestamp, Progress
                  _buildCustomHeader(),
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

                          // Photo Grid Section - "Foto per sudut"
                          _buildSectionHeader(
                            'Foto per sudut',
                            AppIcons.camera,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          _buildPhotoCounter(),
                          const SizedBox(height: AppSpacing.sm),
                          _buildPhotoGrid(),
                          const SizedBox(height: AppSpacing.xl),

                          // Kondisi Segmented Control
                          _buildSectionHeader('Kondisi', null),
                          const SizedBox(height: AppSpacing.sm),
                          _buildKondisiSegmentedControl(),
                          const SizedBox(height: AppSpacing.xl),

                          // Catatan Lapangan
                          _buildSectionHeader('Catatan lapangan', null),
                          const SizedBox(height: AppSpacing.sm),
                          TextField(
                            controller: _notesController,
                            maxLines: 3,
                            maxLength: 300,
                            decoration: InputDecoration(
                              hintText: 'Tambahkan catatan lapangan...',
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
                          const SizedBox(height: AppSpacing.xl),

                          // Rekomendasi Radio Buttons
                          _buildSectionHeader('Rekomendasi', null),
                          const SizedBox(height: AppSpacing.sm),
                          _buildRekomendasiRadioGroup(),
                          const SizedBox(height: AppSpacing.xl),

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
                              'Lanjut ke review hasil',
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

  Widget _buildCustomHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + AppSpacing.md,
        left: AppSpacing.md,
        right: AppSpacing.lg,
        bottom: AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
        border: Border(bottom: BorderSide(color: AppColors.borderCard)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Back arrow + Title + Task ID
          Row(
            children: [
              IconButton(
                onPressed: () => context.pop(),
                icon: AppIcons.arrowBack,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: AppSpacing.md),
              const Text(
                'Form survei',
                style: TextStyle(
                  fontSize: AppTypography.size20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                'TGS-3402',
                style: TextStyle(
                  fontSize: AppTypography.size11,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'IBM Plex Mono',
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                ' · offline',
                style: TextStyle(
                  fontSize: AppTypography.size11,
                  color: AppColors.textTertiary,
                ),
              ),
              const Spacer(),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Tersimpan 10:02',
                    style: TextStyle(
                      fontSize: AppTypography.size11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Progress bar (66%)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.borderCard,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: 0.66,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '66%',
                style: TextStyle(
                  fontSize: AppTypography.size10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoCounter() {
    final filledCount = _photos.length.clamp(0, 3);
    return Row(
      children: [
        Text(
          '$filledCount dari 3',
          style: TextStyle(
            fontSize: AppTypography.size13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        if (filledCount < 3)
          GestureDetector(
            onTap: _showPhotoSourceDialog,
            child: Text(
              'Tambah foto',
              style: TextStyle(
                fontSize: AppTypography.size13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
      ],
    );
  }

  String _getPhotoLabel(int index) {
    const labels = ['Depan', 'Kanan', 'Kiri'];
    if (index < _photos.length) {
      return '${labels[index]} ✓';
    }
    return labels[index];
  }

  Color _getPhotoLabelColor(int index) {
    if (index < _photos.length) {
      return AppColors.textSecondary;
    }
    return AppColors.danger;
  }

  Widget _buildKondisiSegmentedControl() {
    const kondisiOptions = [
      'Baik',
      'Rusak Ringan',
      'Rusak Sedang',
      'Rusak Berat',
    ];
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderCard),
      ),
      child: Row(
        children: List.generate(4, (index) {
          final isSelected = _selectedKondisi == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedKondisi = index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.horizontal(
                    left: index == 0
                        ? const Radius.circular(AppRadius.lg - 1)
                        : Radius.zero,
                    right: index == 3
                        ? const Radius.circular(AppRadius.lg - 1)
                        : Radius.zero,
                  ),
                ),
                child: Text(
                  kondisiOptions[index],
                  style: TextStyle(
                    fontSize: AppTypography.size13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildRekomendasiRadioGroup() {
    const rekomendasiOptions = [
      ('Verifikasi', ''),
      ('Tidak Dapat Diverifikasi', ''),
    ];

    return Column(
      children: List.generate(2, (index) {
        final isSelected = _selectedRekomendasi == index;
        final (label, desc) = rekomendasiOptions[index];
        return GestureDetector(
          onTap: () => setState(() => _selectedRekomendasi = index),
          child: Container(
            margin: EdgeInsets.only(bottom: index < 1 ? AppSpacing.sm : 0),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryLight : AppColors.bgCard,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.borderCard,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? AppColors.primary : Colors.white,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.borderSoft,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: AppTypography.size13,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.primaryDark
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
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
                      ? '${_capturedGps!.$1.toStringAsFixed(6)}, ${_capturedGps!.$2.toStringAsFixed(6)}'
                      : 'GPS Belum Tertangkap',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                if (_capturedGps != null)
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(AppRadius.x1),
                        ),
                        child: Text(
                          'Akurasi baik',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: AppTypography.size10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    'Ketuk untuk menangkap koordinat GPS',
                    style: TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          if (_capturedGps != null)
            GestureDetector(
              onTap: _captureGps,
              child: Text(
                'Ambil ulang',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: AppTypography.size13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            _gpsLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : GestureDetector(
                    onTap: _captureGps,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: const Text(
                        'Ambil GPS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: AppTypography.size12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
        ],
      ),
    );
  }

  Widget _buildPhotoGrid() {
    // Always show 3 photo slots
    return Row(
      children: List.generate(3, (index) {
        final hasPhoto = index < _photos.length;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index < 2 ? AppSpacing.sm : 0),
            child: Column(
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: hasPhoto
                      ? Stack(
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
                                  child: const Icon(Icons.image, size: 32),
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
                                    color: AppColors.textPrimary.withValues(
                                      alpha: 0.54,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : GestureDetector(
                          onTap: _showPhotoSourceDialog,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.bgSurface,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              border: Border.all(
                                color: AppColors.borderCard,
                                style: BorderStyle.solid,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add,
                                  size: 22,
                                  color: AppColors.textMuted,
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getPhotoLabel(index),
                  style: TextStyle(
                    color: _getPhotoLabelColor(index),
                    fontSize: AppTypography.size10,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

// Helper for JSON encoding
String jsonEncode(Map<String, String> map) {
  final entries = map.entries.map((e) => '"${e.key}":"${e.value}"');
  return '{${entries.join(',')}}';
}

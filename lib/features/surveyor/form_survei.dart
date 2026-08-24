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
              leading: const Icon(Icons.camera_alt, color: SigapColors.primary),
              title: const Text('Kamera'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: SigapColors.primary,
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
                    padding: const EdgeInsets.all(SigapSpacing.xl),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: SigapColors.primary,
                          size: 64,
                        ),
                        const SizedBox(height: SigapSpacing.lg),
                        const Text(
                          Strings.surveiBerhasilDikirim,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: SigapSpacing.sm),
                        Text(
                          'Data survei telah tersimpan dan akan diproses oleh tim terkait.',
                          style: TextStyle(
                            color: SigapColors.textSecondary,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: SigapSpacing.xl),
                        ElevatedButton(
                          onPressed: () => context.go('/surveyor/tasks'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: SigapColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: SigapSpacing.xl,
                              vertical: SigapSpacing.md,
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
              backgroundColor: SigapColors.bgScreen,
              body: Column(
                children: [
                  // Custom Header with Back Arrow, Title, Task ID, Timestamp, Progress
                  _buildCustomHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(SigapSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // GPS Section
                          _buildSectionHeader('Lokasi GPS', AppIcons.location),
                          const SizedBox(height: SigapSpacing.sm),
                          _buildGpsCard(),
                          const SizedBox(height: SigapSpacing.xl),

                          // Photo Grid Section - "Foto per sudut"
                          _buildSectionHeader(
                            'Foto per sudut',
                            AppIcons.camera,
                          ),
                          const SizedBox(height: SigapSpacing.xs),
                          _buildPhotoCounter(),
                          const SizedBox(height: SigapSpacing.sm),
                          _buildPhotoGrid(),
                          const SizedBox(height: SigapSpacing.xl),

                          // Kondisi Segmented Control
                          _buildSectionHeader('Kondisi', null),
                          const SizedBox(height: SigapSpacing.sm),
                          _buildKondisiSegmentedControl(),
                          const SizedBox(height: SigapSpacing.xl),

                          // Catatan Lapangan
                          _buildSectionHeader('Catatan lapangan', null),
                          const SizedBox(height: SigapSpacing.sm),
                          TextField(
                            controller: _notesController,
                            maxLines: 3,
                            maxLength: 300,
                            decoration: InputDecoration(
                              hintText: 'Tambahkan catatan lapangan...',
                              hintStyle: TextStyle(
                                color: SigapColors.textTertiary,
                              ),
                              filled: true,
                              fillColor: SigapColors.bgCard,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  SigapRadius.md,
                                ),
                                borderSide: const BorderSide(
                                  color: SigapColors.borderCard,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  SigapRadius.md,
                                ),
                                borderSide: const BorderSide(
                                  color: SigapColors.borderCard,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  SigapRadius.md,
                                ),
                                borderSide: const BorderSide(
                                  color: SigapColors.primary,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: SigapSpacing.xl),

                          // Rekomendasi Radio Buttons
                          _buildSectionHeader('Rekomendasi', null),
                          const SizedBox(height: SigapSpacing.sm),
                          _buildRekomendasiRadioGroup(),
                          const SizedBox(height: SigapSpacing.xl),

                          // Error message
                          if (_submitError != null) ...[
                            const SizedBox(height: SigapSpacing.lg),
                            Container(
                              padding: const EdgeInsets.all(SigapSpacing.md),
                              decoration: BoxDecoration(
                                color: SigapColors.dangerBg,
                                borderRadius: BorderRadius.circular(
                                  SigapRadius.sm,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: SigapColors.danger,
                                    size: 18,
                                  ),
                                  const SizedBox(width: SigapSpacing.sm),
                                  Expanded(
                                    child: Text(
                                      _submitError!,
                                      style: TextStyle(
                                        color: SigapColors.danger,
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
                      left: SigapSpacing.lg,
                      right: SigapSpacing.lg,
                      top: SigapSpacing.md,
                      bottom:
                          MediaQuery.of(context).padding.bottom + SigapSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      color: SigapColors.bgCard,
                      boxShadow: [
                        BoxShadow(
                          color: SigapColors.textPrimary.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _canSubmit && !_submitting ? _submit : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SigapColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: SigapSpacing.md,
                        ),
                        disabledBackgroundColor: SigapColors.borderCard,
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
        if (icon != null) ...[icon, const SizedBox(width: SigapSpacing.sm)],
        Text(
          title,
          style: TextStyle(
            color: SigapColors.textPrimary,
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
        top: MediaQuery.of(context).padding.top + SigapSpacing.md,
        left: SigapSpacing.md,
        right: SigapSpacing.lg,
        bottom: SigapSpacing.md,
      ),
      decoration: const BoxDecoration(
        color: SigapColors.bgCard,
        border: Border(bottom: BorderSide(color: SigapColors.borderCard)),
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
              const SizedBox(width: SigapSpacing.md),
              const Text(
                'Form survei',
                style: TextStyle(
                  fontSize: SigapTypography.size20,
                  fontWeight: FontWeight.w700,
                  color: SigapColors.textPrimary,
                ),
              ),
              const SizedBox(width: SigapSpacing.md),
              Text(
                'TGS-3402',
                style: TextStyle(
                  fontSize: SigapTypography.size11,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'IBM Plex Mono',
                  color: SigapColors.textSecondary,
                ),
              ),
              Text(
                ' · offline',
                style: TextStyle(
                  fontSize: SigapTypography.size11,
                  color: SigapColors.textTertiary,
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
                      color: SigapColors.primary,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Tersimpan 10:02',
                    style: TextStyle(
                      fontSize: SigapTypography.size11,
                      fontWeight: FontWeight.w600,
                      color: SigapColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: SigapSpacing.md),
          // Progress bar (66%)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: SigapColors.borderCard,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: 0.66,
                  child: Container(
                    decoration: BoxDecoration(
                      color: SigapColors.primary,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: SigapSpacing.xs),
              Text(
                '66%',
                style: TextStyle(
                  fontSize: SigapTypography.size10,
                  fontWeight: FontWeight.w600,
                  color: SigapColors.primary,
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
            fontSize: SigapTypography.size13,
            fontWeight: FontWeight.w600,
            color: SigapColors.textSecondary,
          ),
        ),
        const Spacer(),
        if (filledCount < 3)
          GestureDetector(
            onTap: _showPhotoSourceDialog,
            child: Text(
              'Tambah foto',
              style: TextStyle(
                fontSize: SigapTypography.size13,
                fontWeight: FontWeight.w600,
                color: SigapColors.primary,
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
      return SigapColors.textSecondary;
    }
    return SigapColors.danger;
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
        color: SigapColors.bgCard,
        borderRadius: BorderRadius.circular(SigapRadius.lg),
        border: Border.all(color: SigapColors.borderCard),
      ),
      child: Row(
        children: List.generate(4, (index) {
          final isSelected = _selectedKondisi == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedKondisi = index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: SigapSpacing.md),
                decoration: BoxDecoration(
                  color: isSelected ? SigapColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.horizontal(
                    left: index == 0
                        ? const Radius.circular(SigapRadius.lg - 1)
                        : Radius.zero,
                    right: index == 3
                        ? const Radius.circular(SigapRadius.lg - 1)
                        : Radius.zero,
                  ),
                ),
                child: Text(
                  kondisiOptions[index],
                  style: TextStyle(
                    fontSize: SigapTypography.size13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : SigapColors.textSecondary,
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
            margin: EdgeInsets.only(bottom: index < 1 ? SigapSpacing.sm : 0),
            padding: const EdgeInsets.all(SigapSpacing.md),
            decoration: BoxDecoration(
              color: isSelected ? SigapColors.primaryLight : SigapColors.bgCard,
              borderRadius: BorderRadius.circular(SigapRadius.md),
              border: Border.all(
                color: isSelected ? SigapColors.primary : SigapColors.borderCard,
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
                    color: isSelected ? SigapColors.primary : Colors.white,
                    border: Border.all(
                      color: isSelected
                          ? SigapColors.primary
                          : SigapColors.borderSoft,
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
                const SizedBox(width: SigapSpacing.sm),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: SigapTypography.size13,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? SigapColors.primaryDark
                          : SigapColors.textPrimary,
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
      padding: const EdgeInsets.all(SigapSpacing.md),
      decoration: BoxDecoration(
        color: SigapColors.bgCard,
        borderRadius: BorderRadius.circular(SigapRadius.lg),
        border: Border.all(color: SigapColors.borderCard),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(SigapSpacing.sm),
            decoration: BoxDecoration(
              color: _capturedGps != null
                  ? SigapColors.primaryLight
                  : SigapColors.bgSurface,
              borderRadius: BorderRadius.circular(SigapRadius.sm),
            ),
            child: Icon(
              Icons.location_on,
              color: _capturedGps != null
                  ? SigapColors.primary
                  : SigapColors.textTertiary,
              size: 24,
            ),
          ),
          const SizedBox(width: SigapSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _capturedGps != null
                      ? '${_capturedGps!.$1.toStringAsFixed(6)}, ${_capturedGps!.$2.toStringAsFixed(6)}'
                      : 'GPS Belum Tertangkap',
                  style: TextStyle(
                    color: SigapColors.textPrimary,
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
                          horizontal: SigapSpacing.xs,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: SigapColors.primaryLight,
                          borderRadius: BorderRadius.circular(SigapRadius.x1),
                        ),
                        child: Text(
                          'Akurasi baik',
                          style: TextStyle(
                            color: SigapColors.primary,
                            fontSize: SigapTypography.size10,
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
                      color: SigapColors.textTertiary,
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
                  color: SigapColors.primary,
                  fontSize: SigapTypography.size13,
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
                        horizontal: SigapSpacing.md,
                        vertical: SigapSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: SigapColors.primary,
                        borderRadius: BorderRadius.circular(SigapRadius.pill),
                      ),
                      child: const Text(
                        'Ambil GPS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: SigapTypography.size12,
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
            padding: EdgeInsets.only(right: index < 2 ? SigapSpacing.sm : 0),
            child: Column(
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: hasPhoto
                      ? Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(SigapRadius.md),
                              child: Image.file(
                                File(_photos[index].path),
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: SigapColors.bgSurface,
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
                                    color: SigapColors.textPrimary.withValues(
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
                              color: SigapColors.bgSurface,
                              borderRadius: BorderRadius.circular(SigapRadius.md),
                              border: Border.all(
                                color: SigapColors.borderCard,
                                style: BorderStyle.solid,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add,
                                  size: 22,
                                  color: SigapColors.textMuted,
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
                    fontSize: SigapTypography.size10,
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

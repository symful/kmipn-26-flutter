import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:exif/exif.dart';
import 'package:image/image.dart' as img;
import '../../db/database.dart';
import '../../providers/providers.dart';
import '../../theme/tokens.dart';
import '../../utils/logger.dart';

class ComplementaryEvidenceScreen extends ConsumerStatefulWidget {
  final String reportId;
  const ComplementaryEvidenceScreen({super.key, required this.reportId});

  @override
  ConsumerState<ComplementaryEvidenceScreen> createState() =>
      _ComplementaryEvidenceScreenState();
}

class _PhotoData {
  final String path;
  final String? exifJson;
  _PhotoData({required this.path, this.exifJson});
}

class _ComplementaryEvidenceScreenState
    extends ConsumerState<ComplementaryEvidenceScreen> {
  static final _logger = Logger('ComplementaryEvidenceScreen');
  final _descriptionController = TextEditingController();
  final List<_PhotoData> _photos = [];
  final ImagePicker _picker = ImagePicker();
  bool _submitting = false;
  String? _submitError;
  bool _success = false;

  bool get _canSubmit {
    if (_descriptionController.text.trim().length < 10) return false;
    if (_photos.isEmpty) return false;
    return true;
  }

  /// Strips EXIF data from JPEG bytes to protect privacy (especially GPS).
  /// Throws [Exception] if stripping fails — never returns original bytes.
  Uint8List _stripExifFromJpeg(Uint8List bytes) {
    final image = img.decodeImage(bytes);
    if (image == null) {
      throw Exception('Gagal mendekode gambar untuk menghapus EXIF');
    }
    final strippedBytes = Uint8List.fromList(img.encodeJpg(image, quality: 85));
    _logger.info('EXIF data stripped from image');
    return strippedBytes;
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
          // Strip EXIF before storing to protect privacy
          final strippedBytes = _stripExifFromJpeg(bytes);
          final tempDir = Directory.systemTemp;
          final strippedFile = File(
            '${tempDir.path}/warga_evidence_${DateTime.now().millisecondsSinceEpoch}.jpg',
          );
          await strippedFile.writeAsBytes(strippedBytes);
          if (!mounted) return;
          setState(() {
            _photos.add(
              _PhotoData(path: strippedFile.path, exifJson: exifJson),
            );
          });
        } catch (e, s) {
          _logger.warning('Error processing image', e, s);
          // If stripping fails, abort this photo and show error
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Gagal memproses foto: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
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

  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() {
      _submitting = true;
      _submitError = null;
    });
    try {
      // Store photos locally with EXIF data
      final db = ref.read(databaseProvider);
      final now = DateTime.now().millisecondsSinceEpoch;
      for (final photo in _photos) {
        await db.insertPhoto(
          reportIdempotencyKey: widget.reportId,
          filePath: photo.path,
          exifDataJson: photo.exifJson,
          capturedAt: now,
        );
      }

      final client = ref.read(apiClientProvider);
      await client.wargaSubmitEvidence(
        reportId: widget.reportId,
        description: _descriptionController.text.trim(),
        photoPaths: _photos.map((p) => p.path).toList(),
      );
      setState(() => _success = true);
    } catch (e) {
      setState(() => _submitError = e.toString());
    } finally {
      setState(() => _submitting = false);
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_success) {
      return Scaffold(
        appBar: AppBar(title: const Text('Bukti Tambahan')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(SigapSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: SigapColors.selesai,
                  size: 64,
                ),
                const SizedBox(height: SigapSpacing.lg),
                const Text(
                  'Bukti tambahan berhasil dikirim',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: SigapSpacing.sm),
                Text(
                  'Tim verifikator akan meninjau bukti yang Anda kirimkan.',
                  style: TextStyle(
                    color: SigapColors.textSecondary,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: SigapSpacing.xl),
                ElevatedButton(
                  onPressed: () => context.go('/'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SigapColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: SigapSpacing.xl,
                      vertical: SigapSpacing.md,
                    ),
                  ),
                  child: const Text('Kembali ke Beranda'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Kirim Bukti Tambahan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(SigapSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(SigapSpacing.md),
              decoration: BoxDecoration(
                color: SigapColors.selesai.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(SigapRadius.md),
                border: Border.all(
                  color: SigapColors.selesai.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: SigapColors.selesai,
                    size: 20,
                  ),
                  const SizedBox(width: SigapSpacing.sm),
                  Expanded(
                    child: Text(
                      'Unggah foto atau dokumen pendukung untuk memperkuat laporan Anda.',
                      style: TextStyle(
                        color: SigapColors.selesai,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: SigapSpacing.xl),
            Text(
              'Deskripsi Bukti',
              style: TextStyle(
                color: SigapColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: SigapSpacing.sm),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: 'Jelaskan bukti yang Anda kirimkan...',
                hintStyle: TextStyle(color: SigapColors.textMuted),
                border: const OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: SigapColors.primary),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: SigapSpacing.lg),
            Text(
              'Foto Bukti',
              style: TextStyle(
                color: SigapColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: SigapSpacing.sm),
            if (_photos.isEmpty)
              Container(
                padding: const EdgeInsets.all(SigapSpacing.xl),
                decoration: BoxDecoration(
                  color: SigapColors.surface,
                  borderRadius: BorderRadius.circular(SigapRadius.md),
                  border: Border.all(
                    color: SigapColors.border,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.add_a_photo_outlined,
                      size: 48,
                      color: SigapColors.textMuted,
                    ),
                    const SizedBox(height: SigapSpacing.sm),
                    Text(
                      'Belum ada foto',
                      style: TextStyle(
                        color: SigapColors.textMuted,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )
            else
              SizedBox(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _photos.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: SigapSpacing.sm),
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(SigapRadius.md),
                          child: Image.file(
                            File(_photos[index].path),
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
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
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            const SizedBox(height: SigapSpacing.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt, size: 18),
                    label: const Text('Kamera'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: SigapColors.primary,
                      side: BorderSide(color: SigapColors.primary),
                      padding: const EdgeInsets.symmetric(
                        vertical: SigapSpacing.md,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: SigapSpacing.md),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library, size: 18),
                    label: const Text('Galeri'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: SigapColors.primary,
                      side: BorderSide(color: SigapColors.primary),
                      padding: const EdgeInsets.symmetric(
                        vertical: SigapSpacing.md,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_submitError != null) ...[
              const SizedBox(height: SigapSpacing.md),
              Container(
                padding: const EdgeInsets.all(SigapSpacing.md),
                decoration: BoxDecoration(
                  color: SigapColors.perluTindakan.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(SigapRadius.sm),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: SigapColors.perluTindakan,
                      size: 18,
                    ),
                    const SizedBox(width: SigapSpacing.sm),
                    Expanded(
                      child: Text(
                        _submitError!,
                        style: TextStyle(
                          color: SigapColors.perluTindakan,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: SigapSpacing.xl),
            ElevatedButton(
              onPressed: _canSubmit && !_submitting ? _submit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: SigapColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: SigapSpacing.md),
                disabledBackgroundColor: SigapColors.border,
              ),
              child: _submitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Kirim Bukti',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

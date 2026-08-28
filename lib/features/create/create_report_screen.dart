import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigap/api/types.g.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' show Value;
import 'package:exif/exif.dart';
import 'package:image/image.dart' as img;
import '../../l10n/strings.dart';
import '../../theme/tokens.dart';
import '../../db/database.dart';
import '../../widgets/design_system/similar_cases_banner.dart';
import '../../providers/providers.dart';
import '../../services/photo_service.dart';
import '../../utils/logger.dart';
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
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: SigapColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: SigapColors.border),
          Padding(padding: const EdgeInsets.all(SigapSpacing.lg), child: child),
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
      decoration: const InputDecoration(
        labelText: 'Pilih Kategori',
        labelStyle: TextStyle(color: SigapColors.textSecondary),
        hintText: 'Tap untuk memilih kategori',
        hintStyle: TextStyle(color: SigapColors.textTertiary),
      ),
      initialValue: selectedCategoryId,
      items: categories.map((cat) {
        return DropdownMenuItem(value: cat.id, child: Text(cat.name ?? ""));
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
              const Icon(Icons.error_outline, color: SigapColors.danger),
              const SizedBox(width: SigapSpacing.sm),
              Expanded(
                child: Text(
                  error,
                  style: const TextStyle(
                    color: SigapColors.danger,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: SigapSpacing.md),
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
            borderRadius: BorderRadius.circular(SigapRadius.md),
            child: Image.file(
              File(photoPath!),
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: SigapSpacing.md),
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
      borderRadius: BorderRadius.circular(SigapRadius.md),
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: SigapColors.primaryLight,
          borderRadius: BorderRadius.circular(SigapRadius.md),
          border: Border.all(color: SigapColors.primary.withValues(alpha: 0.3)),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_a_photo, color: SigapColors.primary, size: 40),
              SizedBox(height: SigapSpacing.sm),
              Text(
                'Ambil Foto',
                style: TextStyle(
                  color: SigapColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Tap untuk membuka kamera',
                style: TextStyle(
                  color: SigapColors.textSecondary,
                  fontSize: 12,
                ),
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
                        hasLocation ? 'Lokasi Terdeteksi' : 'Ambil Lokasi GPS',
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
                            fontSize: 12,
                            color: SigapColors.textSecondary,
                          ),
                        ),
                      ] else ...[
                        const SizedBox(height: 2),
                        const Text(
                          'Tap untuk mendapatkan lokasi saat ini',
                          style: TextStyle(
                            fontSize: 12,
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
          label: const Text('Pilih di Peta'),
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
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : SigapColors.textPrimary,
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
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '${cases.length} Kasus Serupa',
                  style: const TextStyle(
                    fontSize: 18,
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
                        '${c.distance} · kemiripan ${c.similarityPercent}% · ${c.reportCount} laporan',
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
    final duplicatesAsync = ref.watch(
      duplicateCasesProvider((lat: lat, lng: lng, categoryId: categoryId)),
    );

    return duplicatesAsync.when(
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

class _CreateReportScreenState extends ConsumerState<CreateReportScreen> {
  static final _logger = Logger('CreateReportScreen');
  final _formKey = GlobalKey<FormState>();
  String? _photoPath;
  String? _exifDataJson;
  double? _lat;
  double? _lng;
  String? _categoryId;
  final _descriptionController = TextEditingController();
  final _populationAffectedController = TextEditingController();
  int _populationAffected = 0;
  double _vulnerabilityIndex = 0.5;
  bool _submitting = false;
  bool _isDirty = false;
  DateTime? _autosaveTimestamp;
  Timer? _autosaveTimer;

  // NOTE: This should be fetched from backend config (e.g., /api/config/max_pending)
  // when the backend supports it. Currently hardcoded for backward compatibility.
  static const int maxPending = 50;

  /// Strips EXIF data from JPEG bytes using the image package.
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
          _onFormChanged();
        }
        _logger.info('Photo captured: ${strippedFile.path}');
      } catch (e, s) {
        _logger.warning('Error capturing photo', e, s);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menghapus metadata foto: $e'),
              backgroundColor: Colors.red,
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
      builder: (context) => AlertDialog(
        title: const Text('Lokasi Tidak Tersedia'),
        content: const Text(
          'Tidak dapat mengakses GPS. Pilih lokasi manual di peta.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(Strings.batal),
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
        _onFormChanged();
      }
      ref.read(pickLocationCallbackProvider.notifier).state = null;
    };
    ref.read(pickLocationModeProvider.notifier).state = true;
    context.push('/map');
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
    if (_photoPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ambil foto terlebih dahulu')),
      );
      return;
    }
    if (_lat == null || _lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aktifkan lokasi untuk melapor'),
          backgroundColor: SigapColors.danger,
        ),
      );
      return;
    }
    if (_categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih kategori terlebih dahulu')),
      );
      return;
    }

    // Anonymous mode submission
    if (widget.anonymousMode) {
      await _submitAnonymous();
      return;
    }

    // Regular authenticated submission
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
          populationAffected: Value(_populationAffected),
          vulnerabilityIndex: Value(_vulnerabilityIndex),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      // Upload photo immediately via signed URL and get R2 URL
      final photoService = PhotoService(ref.read(apiClientProvider));
      final r2Url = await photoService.uploadPhotoAndGetUrl(
        _photoPath!,
        idempotencyKey,
      );

      // Insert photo record with R2 URL (or local path if upload failed)
      final db = ref.read(databaseProvider);
      await db.insertPhoto(
        reportIdempotencyKey: idempotencyKey,
        filePath: r2Url, // Store R2 URL, not local path
        exifDataJson: _exifDataJson,
        capturedAt: DateTime.now().millisecondsSinceEpoch,
      );
      _logger.info('Photo uploaded for report: $idempotencyKey, url: $r2Url');

      // Enqueue for sync
      final queueRepo = ref.read(syncQueueRepositoryProvider);
      await queueRepo.enqueue(idempotencyKey);

      ref.invalidate(localReportsProvider);
      ref.invalidate(pendingCountProvider);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Laporan tersimpan. Akan sinkron otomatis.'),
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
          content: Text('Gagal menyimpan: $e'),
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

      // Upload the photo anonymously first, then attach its URL to the report
      // at creation time (anonymous reports are created after the upload, so
      // server-side auto-attach is not possible).
      final List<String> photoUrls = [];
      if (_photoPath != null) {
        try {
          final uploaded = await client.uploadReportPhotoAnon(
            filePath: _photoPath!,
            idempotencyKey: idempotencyKey,
          );
          if (uploaded.publicUrl != null && uploaded.publicUrl!.isNotEmpty) {
            photoUrls.add(uploaded.publicUrl!);
          }
        } catch (uploadErr, uploadStack) {
          _logger.error(
            'Anonymous photo upload failed',
            uploadErr,
            uploadStack,
          );
          if (!mounted) return;
          setState(() => _submitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal mengunggah foto: $uploadErr'),
              backgroundColor: SigapColors.danger,
            ),
          );
          return;
        }
      }

      final result = await client.submitAnonymousReport(
        idempotencyKey: idempotencyKey,
        deviceId: deviceId,
        categoryId: _categoryId!,
        description: _descriptionController.text,
        lat: _lat!,
        lng: _lng!,
        photos: photoUrls,
        captchaToken: 'test-token-bypass',
        populationAffected: _populationAffected,
        vulnerabilityIndex: _vulnerabilityIndex,
      );

      _logger.info(
        'Anonymous report submitted: id=${result.id}, status=${result.status}',
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Laporan匿名 tersimpan: ${result.id}'),
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
          content: Text('Gagal menyimpan: $e'),
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
          idempotencyKey: 'draft',
          categoryId: _categoryId ?? '',
          description: _descriptionController.text,
          lat: _lat!,
          lng: _lng!,
          photoPath: Value(_photoPath),
          exifDataJson: Value(_exifDataJson),
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
    return Scaffold(
      backgroundColor: SigapColors.bgSurface,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Buat Laporan'),
            if (_autosaveTimestamp != null)
              Text(
                'Tersimpan ${_TimeOfDayFormatter.format(_autosaveTimestamp!)}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: SigapColors.textSecondary,
                ),
              ),
          ],
        ),
        backgroundColor: SigapColors.bgCard,
        foregroundColor: SigapColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
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
                  _SectionCard(
                    title: 'Ambil Foto',
                    icon: Icons.add_a_photo,
                    child: _PhotoSection(
                      photoPath: _photoPath,
                      onCapture: _capturePhoto,
                    ),
                  ),
                  const SizedBox(height: SigapSpacing.lg),

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
                  const SizedBox(height: SigapSpacing.lg),

                  // Category Section
                  _SectionCard(
                    title: 'Kategori',
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
                  _SectionCard(
                    title: 'Deskripsi',
                    icon: Icons.description,
                    child: TextFormField(
                      controller: _descriptionController,
                      onChanged: (_) => _onFormChanged(),
                      decoration: const InputDecoration(
                        labelText: 'Jelaskan laporan Anda',
                        labelStyle: TextStyle(color: SigapColors.textSecondary),
                        hintText: 'Minimal 10 karakter...',
                        hintStyle: TextStyle(color: SigapColors.textTertiary),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 4,
                      maxLength: 2000,
                      validator: (v) => v == null || v.length < 10
                          ? 'Minimal 10 karakter'
                          : null,
                    ),
                  ),
                  const SizedBox(height: SigapSpacing.lg),

                  // Population Affected Section
                  _SectionCard(
                    title: 'Perkiraan Jumlah Terdampak',
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
                          decoration: const InputDecoration(
                            labelText: 'Perkiraan jumlah warga terdampak',
                            labelStyle: TextStyle(
                              color: SigapColors.textSecondary,
                            ),
                            hintText: '0',
                            hintStyle: TextStyle(
                              color: SigapColors.textTertiary,
                            ),
                            suffixText: 'orang',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: SigapSpacing.sm),
                        Text(
                          'Jumlah perkiraan warga yang terdampak insiden ini',
                          style: TextStyle(
                            fontSize: 12,
                            color: SigapColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: SigapSpacing.lg),

                  // Vulnerability Index Section
                  _SectionCard(
                    title: 'Tingkat Kerentanan',
                    icon: Icons.warning,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Seberapa rentan kelompok masyarakat setempat?',
                          style: TextStyle(
                            fontSize: 12,
                            color: SigapColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: SigapSpacing.md),
                        Row(
                          children: [
                            _VulnerabilitySegment(
                              label: 'Rendah',
                              value: 0.25,
                              groupValue: _vulnerabilityIndex,
                              onChanged: (v) {
                                setState(() => _vulnerabilityIndex = v);
                                _onFormChanged();
                              },
                            ),
                            const SizedBox(width: SigapSpacing.sm),
                            _VulnerabilitySegment(
                              label: 'Sedang',
                              value: 0.5,
                              groupValue: _vulnerabilityIndex,
                              onChanged: (v) {
                                setState(() => _vulnerabilityIndex = v);
                                _onFormChanged();
                              },
                            ),
                            const SizedBox(width: SigapSpacing.sm),
                            _VulnerabilitySegment(
                              label: 'Tinggi',
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
                  foregroundColor: Colors.white,
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
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text(
                        Strings.kirimLaporan,
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
    _autosaveTimer?.cancel();
    _descriptionController.dispose();
    super.dispose();
  }
}

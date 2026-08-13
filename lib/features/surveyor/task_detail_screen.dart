import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:exif/exif.dart';
import '../../../db/database.dart';
import '../../../providers/providers.dart';
import '../../../theme/tokens.dart';
import '../../../utils/logger.dart';

class SurveyorTaskDetailScreen extends ConsumerStatefulWidget {
  final String taskId;
  const SurveyorTaskDetailScreen({super.key, required this.taskId});

  @override
  ConsumerState<SurveyorTaskDetailScreen> createState() =>
      _SurveyorTaskDetailScreenState();
}

class _SurveyorTaskDetailScreenState
    extends ConsumerState<SurveyorTaskDetailScreen> {
  static final _logger = Logger('SurveyorTaskDetailScreen');
  Map<String, dynamic>? _task;
  List<Map<String, dynamic>> _checklistItems = [];
  bool _loading = true;
  String? _error;
  bool _submitting = false;
  bool _success = false;
  bool _isOfflineMode = false;

  // Per-checklist data: itemId -> {gps: LatLng?, photo: String?, checked: bool, notes: String}
  final Map<String, _ChecklistEntry> _checklistData = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final taskRepo = ref.read(surveyorTaskRepositoryProvider);

    try {
      // Try API first
      final client = ref.read(apiClientProvider);
      final data = await client.surveyorGetTaskDetail(widget.taskId);
      final checklistTemplate =
          data['checklist_template'] as List? ??
          data['checklist'] as List? ??
          [];

      setState(() {
        _task = data;
        _checklistItems = checklistTemplate.cast<Map<String, dynamic>>();
        _loading = false;
        _isOfflineMode = false;
      });

      // Initialize checklist data map
      for (final item in _checklistItems) {
        final id = item['id']?.toString() ?? item['item_id']?.toString() ?? '';
        _checklistData[id] = _ChecklistEntry(
          checked: false,
          gps: null,
          photoPath: null,
          photoExifJson: null,
          notes: '',
        );
      }
    } catch (e) {
      // Fall back to offline local data
      try {
        final localTask = await taskRepo.getDownloadedTask(widget.taskId);
        if (localTask != null) {
          final checklistTemplate = jsonDecode(localTask.checklistTemplateJson);

          setState(() {
            _task = {
              'id': localTask.taskId,
              'title': localTask.title,
              'description': localTask.description,
              'instructions': localTask.instructions,
              'status': localTask.status,
              'checklist_template': checklistTemplate,
            };
            _checklistItems = (checklistTemplate as List)
                .cast<Map<String, dynamic>>();
            _loading = false;
            _isOfflineMode = true;
          });

          // Initialize checklist data map
          for (final item in _checklistItems) {
            final id =
                item['id']?.toString() ?? item['item_id']?.toString() ?? '';
            _checklistData[id] = _ChecklistEntry(
              checked: false,
              gps: null,
              photoPath: null,
              photoExifJson: null,
              notes: '',
            );
          }
        } else {
          setState(() {
            _error = e.toString();
            _loading = false;
          });
        }
      } catch (localError) {
        setState(() {
          _error = localError.toString();
          _loading = false;
        });
      }
    }
  }

  Future<void> _captureGps(String itemId) async {
    try {
      final permission = await Geolocator.checkPermission();
      LocationPermission locPerm = permission;
      if (permission == LocationPermission.denied) {
        locPerm = await Geolocator.requestPermission();
      }
      if (locPerm == LocationPermission.denied ||
          locPerm == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Izin lokasi ditolak')));
        }
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      setState(() {
        _checklistData[itemId]?.gps = (position.latitude, position.longitude);
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
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal capture GPS: $e')));
      }
    }
  }

  Future<void> _capturePhoto(String itemId, ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, maxWidth: 1200);
    if (picked != null) {
      String? exifJson;
      try {
        final bytes = await picked.readAsBytes();
        final exifData = await readExifFromBytes(bytes);
        if (exifData.isNotEmpty) {
          exifJson = jsonEncode({
            for (final entry in exifData.entries)
              entry.key: entry.value.toString(),
          });
        }
      } catch (e, s) {
        _logger.warning('Error extracting EXIF data', e, s);
        // EXIF extraction failed, continue without it
      }

      // Store photo in LocalPhotos
      final idempotencyKey =
          'surveyor_visit_${widget.taskId}_${DateTime.now().millisecondsSinceEpoch}';
      final db = ref.read(databaseProvider);
      await db.insertPhoto(
        reportIdempotencyKey: idempotencyKey,
        filePath: picked.path,
        exifDataJson: exifJson,
        capturedAt: DateTime.now().millisecondsSinceEpoch,
      );

      setState(() {
        _checklistData[itemId]?.photoPath = picked.path;
        _checklistData[itemId]?.photoExifJson = exifJson;
      });
    }
  }

  Future<void> _submitVisit() async {
    // Validate: each required item needs GPS + photo
    final missing = <String>[];
    for (final item in _checklistItems) {
      final required = item['required'] == true || item['is_required'] == true;
      if (required) {
        final id = item['id']?.toString() ?? item['item_id']?.toString() ?? '';
        final entry = _checklistData[id];
        if (entry?.gps == null || entry?.photoPath == null) {
          missing.add(
            item['label'] as String? ?? item['name'] as String? ?? id,
          );
        }
      }
    }
    if (missing.isNotEmpty) {
      setState(
        () => _error = 'Item wajib belum lengkap: ${missing.join(", ")}',
      );
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    final visitData = <String, dynamic>{
      'checklist': _checklistItems.map((item) {
        final id = item['id']?.toString() ?? item['item_id']?.toString() ?? '';
        final entry = _checklistData[id];
        return {
          'item_id': id,
          'label': item['label'] ?? item['name'],
          'checked': entry?.checked ?? false,
          'gps': entry?.gps != null
              ? {'lat': entry!.gps!.$1, 'lng': entry.gps!.$2}
              : null,
          'photo_path': entry?.photoPath,
          'notes': entry?.notes,
        };
      }).toList(),
      'submitted_at': DateTime.now().toIso8601String(),
    };

    final idempotencyKey =
        'surveyor_visit_${widget.taskId}_${DateTime.now().millisecondsSinceEpoch}';

    try {
      if (!_isOfflineMode) {
        // Try to submit directly when online
        final client = ref.read(apiClientProvider);
        await client.surveyorSubmitVisit(widget.taskId, visitData);
        setState(() {
          _success = true;
          _submitting = false;
        });
      } else {
        // Queue for later sync when offline
        final taskRepo = ref.read(surveyorTaskRepositoryProvider);
        final queueRepo = ref.read(syncQueueRepositoryProvider);

        await taskRepo.saveVisit(
          idempotencyKey: idempotencyKey,
          taskId: widget.taskId,
          visitData: visitData,
        );
        await queueRepo.enqueue(idempotencyKey);

        setState(() {
          _success = true;
          _submitting = false;
        });
      }
    } catch (e) {
      // If direct submit fails, queue for later
      try {
        final taskRepo = ref.read(surveyorTaskRepositoryProvider);
        final queueRepo = ref.read(syncQueueRepositoryProvider);

        await taskRepo.saveVisit(
          idempotencyKey: idempotencyKey,
          taskId: widget.taskId,
          visitData: visitData,
        );
        await queueRepo.enqueue(idempotencyKey);

        setState(() {
          _success = true;
          _submitting = false;
        });
      } catch (queueError) {
        setState(() {
          _error = queueError.toString();
          _submitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_success) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tugas Survei')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: SigapColors.selesai,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                _isOfflineMode
                    ? 'Kunjungan disimpan, akan dikirim saat online!'
                    : 'Kunjungan berhasil dikirim!',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/surveyor/tasks'),
                child: const Text('Kembali ke Daftar'),
              ),
            ],
          ),
        ),
      );
    }

    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Tugas')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null && _task == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Tugas')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: SigapColors.perluTindakan,
              ),
              const SizedBox(height: 16),
              Text('Gagal memuat: $_error'),
              ElevatedButton(onPressed: _load, child: const Text('Coba Lagi')),
            ],
          ),
        ),
      );
    }

    final task = _task!;
    final title = task['title'] as String? ?? '-';
    final instructions = task['instructions'] as String? ?? '-';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (_isOfflineMode)
            Container(
              margin: const EdgeInsets.only(right: SigapSpacing.md),
              padding: const EdgeInsets.symmetric(
                horizontal: SigapSpacing.sm,
                vertical: SigapSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: SigapColors.offlineBg,
                borderRadius: BorderRadius.circular(SigapRadius.sm),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.cloud_off,
                    size: 14,
                    color: SigapColors.offlineText,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'OFFLINE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: SigapColors.offlineText,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Task info banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(SigapSpacing.md),
            color: SigapColors.primary.withValues(alpha: 0.05),
            child: Text(
              instructions,
              style: const TextStyle(
                fontSize: 13,
                color: SigapColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(SigapSpacing.lg),
              itemCount: _checklistItems.length,
              itemBuilder: (context, index) {
                final item = _checklistItems[index];
                final itemId =
                    item['id']?.toString() ?? item['item_id']?.toString() ?? '';
                final entry = _checklistData[itemId];
                final label =
                    item['label'] as String? ??
                    item['name'] as String? ??
                    'Item ${index + 1}';
                final required =
                    item['required'] == true || item['is_required'] == true;

                return _ChecklistItemCard(
                  label: label,
                  required: required,
                  checked: entry?.checked ?? false,
                  gps: entry?.gps,
                  photoPath: entry?.photoPath,
                  notes: entry?.notes ?? '',
                  onCheckedChanged: (v) => setState(() {
                    _checklistData[itemId]?.checked = v ?? false;
                  }),
                  onCaptureGps: () => _captureGps(itemId),
                  onCapturePhoto: (source) => _capturePhoto(itemId, source),
                  onNotesChanged: (v) => setState(() {
                    _checklistData[itemId]?.notes = v;
                  }),
                );
              },
            ),
          ),
          // Submit button
          Container(
            padding: EdgeInsets.only(
              left: SigapSpacing.lg,
              right: SigapSpacing.lg,
              top: SigapSpacing.md,
              bottom: MediaQuery.of(context).padding.bottom + SigapSpacing.md,
            ),
            decoration: BoxDecoration(
              color: SigapColors.surface,
              boxShadow: [
                BoxShadow(
                  color: SigapColors.textPrimary.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: SigapSpacing.sm),
                    child: Text(
                      'Error: $_error',
                      style: const TextStyle(
                        color: SigapColors.perluTindakan,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ElevatedButton(
                  onPressed: _submitting ? null : _submitVisit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SigapColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _submitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _isOfflineMode
                              ? 'Simpan (Kirim Saat Online)'
                              : 'Kirim Kunjungan',
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChecklistEntry {
  bool checked;
  (double, double)? gps;
  String? photoPath;
  String? photoExifJson;
  String notes;
  _ChecklistEntry({
    required this.checked,
    required this.gps,
    required this.photoPath,
    required this.photoExifJson,
    required this.notes,
  });
}

class _ChecklistItemCard extends StatefulWidget {
  final String label;
  final bool required;
  final bool checked;
  final (double, double)? gps;
  final String? photoPath;
  final String notes;
  final ValueChanged<bool?> onCheckedChanged;
  final VoidCallback onCaptureGps;
  final void Function(ImageSource) onCapturePhoto;
  final ValueChanged<String> onNotesChanged;

  const _ChecklistItemCard({
    required this.label,
    required this.required,
    required this.checked,
    required this.gps,
    required this.photoPath,
    required this.notes,
    required this.onCheckedChanged,
    required this.onCaptureGps,
    required this.onCapturePhoto,
    required this.onNotesChanged,
  });

  @override
  State<_ChecklistItemCard> createState() => _ChecklistItemCardState();
}

class _ChecklistItemCardState extends State<_ChecklistItemCard> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.notes);
  }

  @override
  void didUpdateWidget(_ChecklistItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.notes != widget.notes && _controller.text != widget.notes) {
      _controller.text = widget.notes;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: SigapSpacing.md),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SigapRadius.md),
        side: const BorderSide(color: SigapColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(SigapSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(
                  value: widget.checked,
                  onChanged: widget.onCheckedChanged,
                ),
                Expanded(
                  child: Text(
                    widget.label + (widget.required ? ' *' : ''),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: SigapSpacing.sm),

            // GPS
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.location_on,
                    color: widget.gps != null
                        ? SigapColors.selesai
                        : SigapColors.textMuted,
                  ),
                  onPressed: widget.onCaptureGps,
                  tooltip: 'Capture GPS',
                  iconSize: 20,
                ),
                if (widget.gps != null)
                  Expanded(
                    child: Text(
                      '${widget.gps!.$1.toStringAsFixed(5)}, ${widget.gps!.$2.toStringAsFixed(5)}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontFamily: 'monospace',
                      ),
                    ),
                  )
                else
                  const Expanded(
                    child: Text(
                      'GPS belum di-capture',
                      style: TextStyle(
                        fontSize: 11,
                        color: SigapColors.textMuted,
                      ),
                    ),
                  ),
              ],
            ),

            // Photo
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.camera_alt,
                    color: widget.photoPath != null
                        ? SigapColors.selesai
                        : SigapColors.textMuted,
                  ),
                  onPressed: () => _showPhotoSourceDialog(context),
                  tooltip: 'Ambil Foto',
                  iconSize: 20,
                ),
                if (widget.photoPath != null)
                  Expanded(
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.file(
                            File(widget.photoPath!),
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.image, size: 20),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Foto tersimpan',
                            style: TextStyle(
                              fontSize: 11,
                              color: SigapColors.selesai,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  const Expanded(
                    child: Text(
                      'Foto belum diambil',
                      style: TextStyle(
                        fontSize: 11,
                        color: SigapColors.textMuted,
                      ),
                    ),
                  ),
              ],
            ),

            // Notes
            TextField(
              decoration: const InputDecoration(
                labelText: 'Catatan',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              style: const TextStyle(fontSize: 13),
              maxLines: 2,
              controller: _controller,
              onChanged: (value) {
                widget.onNotesChanged(value);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showPhotoSourceDialog(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera'),
              onTap: () {
                Navigator.pop(ctx);
                widget.onCapturePhoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () {
                Navigator.pop(ctx);
                widget.onCapturePhoto(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
}

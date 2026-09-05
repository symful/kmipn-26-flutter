import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:exif/exif.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api/client.dart';
import '../../db/database.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/providers.dart';
import '../../services/photo_service.dart';
import '../../sync/sync_engine.dart';
import '../../theme/tokens.dart';
import '../../utils/platform_helper.dart';
import '../../components/app_icons.dart';
import '../widgets/design_system/gps_capture_card.dart';
import '../widgets/design_system/catatan_lapangan.dart';
import '../widgets/design_system/rekomendasi_selector.dart';
import '../widgets/design_system/survey_submit_button.dart';

class FormSurveiScreen extends ConsumerStatefulWidget {
  final String? taskId;
  final Map<String, dynamic>? extra;
  const FormSurveiScreen({super.key, this.taskId, this.extra});

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
  double? _gpsAccuracy;
  bool _gpsLoading = false;
  bool _submitting = false;
  String? _submitError;
  bool _success = false;
  bool _queuedOffline = false;

  // Checklist items passed from task workspace
  List<Map<String, dynamic>> _checklistItems = [];

  // Task detail for header
  TaskDetail? _taskDetail;

  // Kondisi: 0=Ringan, 1=Berat, 2=Kritis
  int _selectedKondisi = 0;
  // Rekomendasi: 0=Valid/ditemukan, 1=Tidak ditemukan
  int _selectedRekomendasi = 0;

  // ─── S-04 Autosave state ──────────────────────────────────────────────
  Timer? _autosaveTimer;
  DateTime? _lastSavedTime;

  bool get _canSubmit {
    if (_damageDescriptionController.text.trim().length < 10) return false;
    if (_photos.isEmpty) return false;
    if (_capturedGps == null) return false;
    return true;
  }

  @override
  void initState() {
    super.initState();
    // Extract checked checklist items from route extra
    if (widget.extra != null &&
        widget.extra!['checkedChecklistItems'] != null) {
      _checklistItems = List<Map<String, dynamic>>.from(
        widget.extra!['checkedChecklistItems'] as List,
      );
    }
    // Load task detail for header
    if (widget.taskId != null) {
      _loadTaskDetail();
      _restoreAutosave();
    }
    // Start periodic autosave timer (~15s)
    _autosaveTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      _autoSave();
    });
    // Trigger initial autosave after a brief delay (let form settle)
    Future.delayed(const Duration(seconds: 2), () => _autoSave());
  }

  @override
  void dispose() {
    _autosaveTimer?.cancel();
    _damageDescriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadTaskDetail() async {
    if (widget.taskId == null) return;

    try {
      final client = ref.read(apiClientProvider);
      final detail = await client.getTaskDetail(widget.taskId!);
      if (mounted) {
        setState(() {
          _taskDetail = detail;
        });
      }
    } catch (e) {
      // Silently fail - header will show default values
    }
  }

  /// S-04: Persist form state to local storage for autosave.
  Future<void> _autoSave() async {
    if (!mounted || widget.taskId == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final saveData = <String, dynamic>{
        'damageDescription': _damageDescriptionController.text,
        'notes': _notesController.text,
        'selectedKondisi': _selectedKondisi,
        'selectedRekomendasi': _selectedRekomendasi,
        'gpsLat': _capturedGps?.$1,
        'gpsLng': _capturedGps?.$2,
        'gpsAccuracy': _gpsAccuracy,
        'photoCount': _photos.length,
        'savedAt': DateTime.now().toIso8601String(),
      };
      await prefs.setString(
        'survey_autosave_${widget.taskId}',
        jsonEncode(saveData),
      );
      if (mounted) {
        setState(() => _lastSavedTime = DateTime.now());
      }
    } catch (_) {
      // Autosave is best-effort; silently ignore failures
    }
  }

  /// S-04: Restore form state from local autosave storage.
  Future<void> _restoreAutosave() async {
    if (widget.taskId == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('survey_autosave_${widget.taskId}');
      if (raw == null) return;
      final data = jsonDecode(raw) as Map<String, dynamic>;

      if (mounted) {
        setState(() {
          _damageDescriptionController.text =
              (data['damageDescription'] as String?) ?? '';
          _notesController.text = (data['notes'] as String?) ?? '';
          _selectedKondisi = (data['selectedKondisi'] as int?) ?? 0;
          _selectedRekomendasi = (data['selectedRekomendasi'] as int?) ?? 0;
          final gpsLat = (data['gpsLat'] as num?)?.toDouble();
          final gpsLng = (data['gpsLng'] as num?)?.toDouble();
          if (gpsLat != null && gpsLng != null) {
            _capturedGps = (gpsLat, gpsLng);
          }
          _gpsAccuracy = (data['gpsAccuracy'] as num?)?.toDouble();
          final savedAtStr = data['savedAt'] as String?;
          if (savedAtStr != null) {
            _lastSavedTime = DateTime.tryParse(savedAtStr);
          }
        });
      }
    } catch (_) {
      // Restore is best-effort
    }
  }

  Future<void> _captureGps() async {
    setState(() => _gpsLoading = true);
    final l10n = AppLocalizations.of(context)!;

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.izinkanLokasiDitolakSnack)),
          );
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
        _gpsAccuracy = position.accuracy;
        _gpsLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.gpsBerhasilDitangkap(
                position.latitude.toStringAsFixed(5),
                position.longitude.toStringAsFixed(5),
              ),
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _gpsLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.gagalCaptureGPS(e.toString()))),
        );
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
            exifJson = _encodeExifJson({
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
      setState(
        () => _submitError = AppLocalizations.of(
          context,
        )!.gagalMemilihGambar(e.toString()),
      );
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
              title: Text(AppLocalizations.of(context)!.kamera),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(cameraSource());
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
    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _submitting = true;
      _submitError = null;
    });

    try {
      final client = ref.read(apiClientProvider);

      // Get task details to retrieve uploadToken and reportId
      final taskDetail = await client.getTaskDetail(widget.taskId!);
      final uploadToken = taskDetail.uploadToken;
      final reportId = taskDetail.reportId;

      if (uploadToken == null || reportId == null) {
        throw Exception('Task details missing uploadToken or reportId');
      }

      // Check connectivity: if offline, queue the visit for later sync
      final online = await SyncEngine.isOnline();
      if (!online) {
        // Build checklist from form data
        final kondisiLabels = [l10n.ringan, l10n.berat, l10n.kritis];
        final rekomendasiLabels = [
          l10n.validPerluTindakLanjut,
          l10n.tidakDitemukanDiLokasi,
        ];
        final checklist = [
          ..._checklistItems,
          {
            'item': 'Kondisi: ${kondisiLabels[_selectedKondisi]}',
            'status': 'completed',
            'notes': _damageDescriptionController.text.trim(),
          },
          {
            'item': 'Rekomendasi: ${rekomendasiLabels[_selectedRekomendasi]}',
            'status': 'completed',
            'notes': '',
          },
        ];

        // Serialize visit payload for later sync
        final visitPayload = jsonEncode({
          'task_id': widget.taskId,
          'findings':
              '${kondisiLabels[_selectedKondisi]}, ${rekomendasiLabels[_selectedRekomendasi]}',
          'checklist': checklist,
          'photo_urls': <String>[], // Photos will need re-upload when online
          'gps_lat': _capturedGps!.$1,
          'gps_lng': _capturedGps!.$2,
          'accuracy': _gpsAccuracy ?? 6.0,
          'condition_assessment': kondisiLabels[_selectedKondisi],
          'recommendation': rekomendasiLabels[_selectedRekomendasi],
          'catatan': _notesController.text.trim(),
          'saved_at': DateTime.now().toIso8601String(),
          'local_photo_paths': _photos.map((p) => p.path).toList(),
        });

        // Save photo paths locally for re-upload when online
        for (var i = 0; i < _photos.length; i++) {
          final photo = _photos[i];
          try {
            await ref
                .read(databaseProvider)
                .insertPhoto(
                  reportIdempotencyKey: widget.taskId!,
                  filePath: photo.path,
                  exifDataJson: photo.exifJson,
                  capturedAt: DateTime.now().millisecondsSinceEpoch,
                );
          } catch (_) {
            // Photo insert is best-effort for offline queue
          }
        }

        // Enqueue to sync queue with kind='visit'
        final queueRepo = ref.read(syncQueueRepositoryProvider);
        await queueRepo.enqueue(
          'visit_${widget.taskId}_${DateTime.now().millisecondsSinceEpoch}',
          kind: 'visit',
          payloadJson: visitPayload,
        );

        setState(() {
          _success = true;
          _queuedOffline = true;
        });
        return;
      }

      // Online path: upload photos and submit directly
      // Upload photos and collect public URLs
      final photoUrls = <String>[];
      for (var i = 0; i < _photos.length; i++) {
        final photo = _photos[i];
        final photoUrl = await PhotoService(
          client,
        ).uploadPhotoAndGetUrl(photo.path, reportId, uploadToken, slot: i);
        photoUrls.add(photoUrl);
      }

      // Build checklist from form data
      final kondisiLabels = [l10n.ringan, l10n.berat, l10n.kritis];
      final rekomendasiLabels = [
        l10n.validPerluTindakLanjut,
        l10n.tidakDitemukanDiLokasi,
      ];
      final checklist = [
        ..._checklistItems,
        {
          'item': 'Kondisi: ${kondisiLabels[_selectedKondisi]}',
          'status': 'completed',
          'notes': _damageDescriptionController.text.trim(),
        },
        {
          'item': 'Rekomendasi: ${rekomendasiLabels[_selectedRekomendasi]}',
          'status': 'completed',
          'notes': '',
        },
      ];

      // Submit visit report directly via API when online
      final findings =
          '${kondisiLabels[_selectedKondisi]}, ${rekomendasiLabels[_selectedRekomendasi]}';
      await client.submitVisitReport(
        taskId: widget.taskId!,
        findings: findings,
        checklist: checklist,
        photoUrls: photoUrls,
        gpsLat: _capturedGps!.$1,
        gpsLng: _capturedGps!.$2,
        accuracy: _gpsAccuracy ?? 6.0,
        conditionAssessment: kondisiLabels[_selectedKondisi],
        recommendation: rekomendasiLabels[_selectedRekomendasi],
        catatan: _notesController.text.trim(),
      );

      setState(() => _success = true);
    } catch (e) {
      setState(() => _submitError = e.toString());
    } finally {
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_success) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.formSurveiTitle)),
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
                Text(
                  l10n.surveiBerhasilDikirim,
                  style: const TextStyle(
                    fontSize: SigapTypography.titleLarge,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: SigapSpacing.sm),
                Text(
                  _queuedOffline
                      ? l10n.dataSurveiTersimpanLokal
                      : l10n.dataSurveiTersimpanDiproses,
                  style: TextStyle(
                    color: SigapColors.textSecondary,
                    fontSize: SigapTypography.bodyMedium,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: SigapSpacing.xl),
                ElevatedButton(
                  onPressed: () => context.push('/tasks'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SigapColors.primary,
                    foregroundColor: SigapColors.surface,
                    padding: const EdgeInsets.symmetric(
                      horizontal: SigapSpacing.xl,
                      vertical: SigapSpacing.md,
                    ),
                  ),
                  child: Text(l10n.kembaliKeDaftarTugasBtn),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: SigapColors.bgScreen,
      body: Column(
        children: [
          // S-04 Header: Form survei / TGS-3402 · offline + Tersimpan 10:02 + 66% progress
          _FormSurveiHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: SigapSpacing.lg,
                vertical: SigapSpacing.x14,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Foto per sudut Section — custom 3-slot row matching S-04
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Text(
                            l10n.fotoPerSudut,
                            style: TextStyle(
                              fontSize: SigapTypography.bodyText,
                              fontWeight: FontWeight.w700,
                              color: SigapColors.textPrimary,
                            ),
                          ),
                          SizedBox(width: SigapSpacing.xxs),
                          Text(
                            '*',
                            style: TextStyle(
                              fontSize: SigapTypography.bodyText,
                              fontWeight: FontWeight.w700,
                              color: SigapColors.danger,
                            ),
                          ),
                        ],
                      ),
                      _buildPhotoCounter(),
                    ],
                  ),
                  const SizedBox(height: SigapSpacing.sm),
                  _FotoSudutRow(
                    photos: _photos,
                    onAddPhoto: _showPhotoSourceDialog,
                    onRemovePhoto: _removePhoto,
                  ),
                  const SizedBox(height: SigapSpacing.x14),

                  // 2. Kondisi Segmented Control — custom matching S-04 (Ringan/Berat/Kritis)
                  Row(
                    children: [
                      Text(
                        l10n.kondisiAktual,
                        style: TextStyle(
                          fontSize: SigapTypography.bodyText,
                          fontWeight: FontWeight.w700,
                          color: SigapColors.textPrimary,
                        ),
                      ),
                      SizedBox(width: SigapSpacing.xxs),
                      Text(
                        '*',
                        style: TextStyle(
                          fontSize: SigapTypography.bodyText,
                          fontWeight: FontWeight.w700,
                          color: SigapColors.danger,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: SigapSpacing.sm),
                  _buildKondisiSegmentedControl(),
                  const SizedBox(height: SigapSpacing.x14),

                  // 3. GPS Section — GpsCaptureCard
                  _buildGpsCard(),
                  const SizedBox(height: SigapSpacing.x14),

                  // 4. Catatan Lapangan
                  CatatanLapangan(
                    controller: _notesController,
                    hintText: l10n.hintCatatanLapangan,
                    maxCharacters: 300,
                  ),
                  const SizedBox(height: SigapSpacing.x14),

                  // 5. Rekomendasi Section
                  Row(
                    children: [
                      Text(
                        l10n.rekomendasiHasil,
                        style: TextStyle(
                          fontSize: SigapTypography.bodyText,
                          fontWeight: FontWeight.w700,
                          color: SigapColors.textPrimary,
                        ),
                      ),
                      SizedBox(width: SigapSpacing.xxs),
                      Text(
                        '*',
                        style: TextStyle(
                          fontSize: SigapTypography.bodyText,
                          fontWeight: FontWeight.w700,
                          color: SigapColors.danger,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: SigapSpacing.sm),
                  RekomendasiSelector(
                    selectedValue: _selectedRekomendasi == 0
                        ? l10n.validPerluTindakLanjut
                        : l10n.tidakDitemukanDiLokasi,
                    options: [
                      l10n.validPerluTindakLanjut,
                      l10n.tidakDitemukanDiLokasi,
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedRekomendasi = value.startsWith('Valid')
                            ? 0
                            : 1;
                      });
                    },
                  ),
                  const SizedBox(height: SigapSpacing.x14),

                  // Error message
                  if (_submitError != null) ...[
                    const SizedBox(height: SigapSpacing.lg),
                    Container(
                      padding: const EdgeInsets.all(SigapSpacing.md),
                      decoration: BoxDecoration(
                        color: SigapColors.dangerBg,
                        borderRadius: BorderRadius.circular(SigapRadius.sm),
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
                                fontSize: SigapTypography.bodyText,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          // Bottom Fixed Submit Button — S-02 SurveySubmitButton
          SurveySubmitButton(
            isLoading: _submitting,
            isEnabled: _canSubmit,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }

  /// S-04 Header matching: "Form survei / TGS-3402 · offline" + "Tersimpan 10:02" + 66% progress
  Widget _FormSurveiHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Construct task code from taskId (following task_workspace pattern)
    final taskCode = _taskDetail?.taskId != null
        ? 'TGS-${_taskDetail!.taskId!.length >= 4 ? _taskDetail!.taskId!.substring(0, 4) : _taskDetail!.taskId}'
        : 'TGS-';

    // S-04: Show actual last-saved time from autosave, not task creation time
    String formattedTime = '--:--';
    if (_lastSavedTime != null) {
      formattedTime =
          '${_lastSavedTime!.hour.toString().padLeft(2, '0')}:${_lastSavedTime!.minute.toString().padLeft(2, '0')}';
    } else if (_taskDetail?.assignedAt != null) {
      try {
        final dt = DateTime.parse(_taskDetail!.assignedAt!);
        formattedTime =
            '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      } catch (_) {
        // Keep default if parsing fails
      }
    }

    // Calculate progress from form state
    final progressValue = _calculateProgress();
    final progressFactor = progressValue / 100;

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
          // Top row: Back arrow + Title + Task ID + Offline dot + Save time
          Row(
            children: [
              IconButton(
                onPressed: () => context.pop(),
                icon: AppIcons.arrowBack,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: SigapSpacing.md),
              Text(
                l10n.formSurveiHeader,
                style: TextStyle(
                  fontSize: SigapTypography.headlineSmall,
                  fontWeight: FontWeight.w700,
                  color: SigapColors.textPrimary,
                ),
              ),
              const SizedBox(width: SigapSpacing.md),
              Text(
                taskCode,
                style: TextStyle(
                  fontSize: SigapTypography.captionMedium,
                  fontWeight: FontWeight.w600,
                  fontFamily: SigapTypography.fontFamilyMono,
                  color: SigapColors.textSecondary,
                ),
              ),
              Text(
                ' · ${l10n.labelOffline}',
                style: TextStyle(
                  fontSize: SigapTypography.captionMedium,
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
                    l10n.tersimpanPada(formattedTime),
                    style: TextStyle(
                      fontSize: SigapTypography.captionMedium,
                      fontWeight: FontWeight.w600,
                      color: SigapColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: SigapSpacing.md),
          // Progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: SigapSpacing.x6,
                decoration: BoxDecoration(
                  color: SigapColors.borderCard,
                  borderRadius: BorderRadius.circular(SigapRadius.x3),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progressFactor.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: SigapColors.primary,
                      borderRadius: BorderRadius.circular(SigapRadius.x3),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: SigapSpacing.xs),
              Text(
                '$progressValue%',
                style: TextStyle(
                  fontSize: SigapTypography.captionSmall,
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

  /// Calculate form completion progress percentage
  int _calculateProgress() {
    int filled = 0;
    int total = 4;

    // Photos filled (1 slot = 1/3, 2 slots = 2/3, 3 slots = 100%)
    if (_photos.isNotEmpty) {
      filled += (_photos.length / 3 * total).round().clamp(0, total);
    }

    // GPS captured
    if (_capturedGps != null) {
      filled += (total ~/ 4);
    }

    // Notes filled (at least 10 chars)
    if (_notesController.text.trim().length >= 10) {
      filled += (total ~/ 4);
    }

    // Description filled (at least 10 chars)
    if (_damageDescriptionController.text.trim().length >= 10) {
      filled += (total ~/ 4);
    }

    // Cap at 100%
    return (filled * 100 / total).round().clamp(0, 100);
  }

  Widget _buildPhotoCounter() {
    final l10n = AppLocalizations.of(context)!;
    final filledCount = _photos.length.clamp(0, 3);
    return Row(
      children: [
        Text(
          l10n.fotoCountDari(filledCount, 3),
          style: TextStyle(
            fontSize: SigapTypography.bodyText,
            fontWeight: FontWeight.w600,
            color: SigapColors.textSecondary,
          ),
        ),
        const Spacer(),
        if (filledCount < 3)
          GestureDetector(
            onTap: _showPhotoSourceDialog,
            child: Text(
              l10n.tambahFotoLabel,
              style: TextStyle(
                fontSize: SigapTypography.bodyText,
                fontWeight: FontWeight.w600,
                color: SigapColors.primary,
              ),
            ),
          ),
      ],
    );
  }

  /// S-04 GPS card using S-02 GpsCaptureCard widget.
  Widget _buildGpsCard() {
    final l10n = AppLocalizations.of(context)!;
    if (_capturedGps != null) {
      return GpsCaptureCard(
        latitude: _capturedGps!.$1,
        longitude: _capturedGps!.$2,
        accuracyMeters: _gpsAccuracy ?? 6.0,
        timestamp: DateTime.now(),
        onRefresh: _captureGps,
      );
    }
    // Empty state: show placeholder matching S-04 appearance
    return GestureDetector(
      onTap: _gpsLoading ? null : _captureGps,
      child: Container(
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
                color: SigapColors.bgSurface,
                borderRadius: BorderRadius.circular(SigapRadius.sm),
              ),
              child: AppIcons.locationIcon(
                color: SigapColors.textTertiary,
                size: 24,
              ),
            ),
            const SizedBox(width: SigapSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.gpsBelumTertangkap,
                    style: TextStyle(
                      color: SigapColors.textPrimary,
                      fontSize: SigapTypography.bodyMedium,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.ketukUntukMenangkapGps,
                    style: TextStyle(
                      color: SigapColors.textTertiary,
                      fontSize: SigapTypography.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            _gpsLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SigapSpacing.md,
                      vertical: SigapSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: SigapColors.primary,
                      borderRadius: BorderRadius.circular(SigapRadius.pill),
                    ),
                    child: Text(
                      l10n.ambilGPS,
                      style: TextStyle(
                        color: SigapColors.surface,
                        fontSize: SigapTypography.bodySmall,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  /// S-04 Kondisi segmented control: Ringan / Berat / Kritis
  Widget _buildKondisiSegmentedControl() {
    final l10n = AppLocalizations.of(context)!;
    final kondisiOptions = [l10n.ringan, l10n.berat, l10n.kritis];
    return Container(
      decoration: BoxDecoration(
        color: SigapColors.bgCard,
        borderRadius: BorderRadius.circular(SigapRadius.lg),
        border: Border.all(color: SigapColors.borderCard),
      ),
      child: Row(
        children: List.generate(3, (index) {
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
                    right: index == 2
                        ? const Radius.circular(SigapRadius.lg - 1)
                        : Radius.zero,
                  ),
                ),
                child: Text(
                  kondisiOptions[index],
                  style: TextStyle(
                    fontSize: SigapTypography.bodyText,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? SigapColors.surface
                        : SigapColors.textSecondary,
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
}

/// Spec diagonal hatch for captured photo slots.
/// Repeating-linear-gradient(135deg,#e4e7e2 0 6px,#eef0ec 6px 12px).
class _HatchPainter extends CustomPainter {
  const _HatchPainter();

  static const _stripeWidth = 6.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..strokeWidth = _stripeWidth;
    final colors = [SigapColors.borderCard, SigapColors.bgSoft];
    final step = _stripeWidth * 1.414; // hypotenuse of 45° triangle
    final diag = size.width + size.height;
    final count = (diag / step).ceil();
    for (var i = -count; i <= count; i++) {
      paint.color = colors[i.abs() % 2];
      final cx = i * step;
      // 135° line: direction (-1, 1) per unit
      canvas.drawLine(Offset(cx, 0), Offset(cx - diag, diag), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _HatchPainter old) => false;
}

/// Spec dashed border for empty photo slots.
/// 2px dashed #CFD3CC with 5px dash, 3px gap.
class _DashedBorderPainter extends CustomPainter {
  final double radius;

  const _DashedBorderPainter({this.radius = 11});

  static const _dash = 5.0;
  static const _gap = 3.0;
  static const _color = SigapColors.borderSoft;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );

    _drawDashedPath(canvas, path, paint);
  }

  static void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    final metrics = path.computeMetrics().toList();
    for (final metric in metrics) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = (distance + _dash).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += _dash + _gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter old) =>
      radius != old.radius;
}

/// S-04 Foto per sudut row: 3 horizontal slots (Depan, Samping, Atas).
/// Spec: captured = photo over hatch bg + "✓" label #616770;
/// empty = transparent + 2px dashed #CFD3CC + "+" 22px #8a9099 + bare red label.
class _FotoSudutRow extends StatelessWidget {
  final List<_PhotoEntry> photos;
  final VoidCallback onAddPhoto;
  final void Function(int index) onRemovePhoto;

  const _FotoSudutRow({
    required this.photos,
    required this.onAddPhoto,
    required this.onRemovePhoto,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final labels = [l10n.depan, l10n.samping, l10n.atas];
    return Row(
      children: List.generate(3, (index) {
        final hasPhoto = index < photos.length;
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
                            // Hatch background (spec: diagonal stripes)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(
                                SigapRadius.md,
                              ),
                              child: const DecoratedBox(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(SigapRadius.md),
                                  ),
                                ),
                                child: SizedBox.expand(
                                  child: CustomPaint(painter: _HatchPainter()),
                                ),
                              ),
                            ),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(
                                SigapRadius.md,
                              ),
                              child: Image.file(
                                File(photos[index].path),
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
                                onTap: () => onRemovePhoto(index),
                                child: Container(
                                  padding: const EdgeInsets.all(
                                    SigapSpacing.x4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: SigapColors.textPrimary.withValues(
                                      alpha: 0.54,
                                    ),
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
                        )
                      : GestureDetector(
                          onTap: onAddPhoto,
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: CustomPaint(
                                  painter: _DashedBorderPainter(
                                    radius: SigapRadius.md,
                                  ),
                                ),
                              ),
                              const Center(
                                child: Text(
                                  '+',
                                  style: TextStyle(
                                    fontSize: SigapTypography.headlineMedium,
                                    color: SigapColors.textMuted,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
                const SizedBox(height: 4),
                Text(
                  hasPhoto ? '${labels[index]} ✓' : labels[index],
                  style: TextStyle(
                    color: hasPhoto
                        ? SigapColors.textTertiary
                        : SigapColors.danger,
                    fontSize: SigapTypography.captionSmall,
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

// Helper for EXIF JSON encoding (avoids shadowing dart:convert jsonEncode)
String _encodeExifJson(Map<String, String> map) {
  final entries = map.entries.map((e) => '"${e.key}":"${e.value}"');
  return '{${entries.join(',')}}';
}

import 'package:sigap/widgets/design_system/mobile_title_bar.dart';
import 'package:sigap/theme/sigap_color_scheme.dart';

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sigap/widgets/request_error_details.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:exif/exif.dart';
import 'package:sigap/db/repositories/task_cache_repository.dart';
import 'package:sigap/api/client.dart';
import 'package:sigap/db/database.dart';
import 'package:sigap/l10n/generated/app_localizations.dart';
import 'package:sigap/providers/providers.dart';
import 'package:sigap/sync/sync_engine.dart';
import 'package:sigap/theme/tokens.dart';
import 'package:sigap/utils/platform_helper.dart';
import 'package:sigap/components/app_icons.dart';
import 'package:sigap/widgets/design_system/gps_capture_card.dart';
import 'package:sigap/widgets/design_system/catatan_lapangan.dart';

class SurveyFormArguments {
  final List<SurveyChecklistAnswer> checklist;
  const SurveyFormArguments({this.checklist = const []});
}

class SurveyFormScreen extends ConsumerStatefulWidget {
  final String? taskId;
  final SurveyFormArguments? extra;
  const SurveyFormScreen({super.key, this.taskId, this.extra});

  @override
  ConsumerState<SurveyFormScreen> createState() => _SurveyFormScreenState();
}

class _PhotoEntry {
  final String path;
  final String? exifJson;
  _PhotoEntry({required this.path, this.exifJson});
}

class _SurveyFormScreenState extends ConsumerState<SurveyFormScreen> {
  late final TaskCacheRepository _cache;
  final _damageDescriptionController = TextEditingController();
  final _dimensionsController = TextEditingController();
  final _notesController = TextEditingController();
  final List<_PhotoEntry> _photos = [];
  final ImagePicker _picker = ImagePicker();

  (double, double)? _capturedGps;
  double? _gpsAccuracy;
  DateTime? _gpsCapturedAt;
  bool _gpsLoading = false;
  bool _submitting = false;
  String? _submitError;
  String? _submitErrorDetails;
  bool _success = false;
  bool _queuedOffline = false;

  // Checklist items passed from task workspace
  List<SurveyChecklistAnswer> _checklistItems = [];

  // Task detail for header

  // Kondisi: 0=Ringan, 1=Berat, 2=Kritis
  int _selectedKondisi = 0;
  // Rekomendasi: 0=Valid/ditemukan, 1=Tidak ditemukan
  int _selectedRekomendasi = 0;

  // ─── S-04 Autosave state ──────────────────────────────────────────────
  Timer? _autosaveTimer;
  DateTime? _lastSavedTime;

  bool get _canSubmit {
    if (_notesController.text.trim().length < 10) return false;
    if (_dimensionsController.text.trim().isEmpty) return false;
    if (_photos.length < 3) return false;
    if (_capturedGps == null ||
        _gpsAccuracy == null ||
        !_gpsAccuracy!.isFinite ||
        _gpsAccuracy! < 0) {
      return false;
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    _cache = ref.read(taskCacheRepositoryProvider);
    _notesController.addListener(_formChanged);
    _dimensionsController.addListener(_formChanged);
    _checklistItems = widget.extra?.checklist ?? [];
    // Load task detail for header
    if (widget.taskId != null) {
      _restoreAutosave();
    }
    // Start periodic autosave timer (~15s)
    _autosaveTimer = Timer.periodic(Duration(seconds: 15), (_) {
      _autoSave();
    });
    // Trigger initial autosave after a brief delay (let form settle)
    Future.delayed(Duration(seconds: 2), () => _autoSave());
  }

  void _formChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _autosaveTimer?.cancel();
    _damageDescriptionController.dispose();
    _dimensionsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// S-04: Persist form state to local storage for autosave.
  Future<void> _autoSave() async {
    if (!mounted || widget.taskId == null || _success) return;
    try {
      final saveData = <String, dynamic>{
        'damageDescription': _damageDescriptionController.text,
        'dimensions': _dimensionsController.text,
        'notes': _notesController.text,
        'selectedKondisi': _selectedKondisi,
        'selectedRekomendasi': _selectedRekomendasi,
        'gpsLat': _capturedGps?.$1,
        'gpsLng': _capturedGps?.$2,
        'gpsAccuracy': _gpsAccuracy,
        'gpsCapturedAt': _gpsCapturedAt?.toIso8601String(),
        'photos': _photos
            .map((photo) => {'path': photo.path, 'exifJson': photo.exifJson})
            .toList(),
        'savedAt': DateTime.now().toIso8601String(),
      };
      await _cache.saveSurveyDraft(widget.taskId!, jsonEncode(saveData));
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
      final raw = await _cache.readSurveyDraft(widget.taskId!);
      if (raw == null) return;
      final data = jsonDecode(raw) as Map<String, dynamic>;

      if (mounted) {
        setState(() {
          _damageDescriptionController.text =
              (data['damageDescription'] as String?) ?? '';
          _dimensionsController.text = (data['dimensions'] as String?) ?? '';
          _notesController.text = (data['notes'] as String?) ?? '';
          _photos.clear();
          for (final photo in (data['photos'] as List? ?? [])) {
            _photos.add(
              _PhotoEntry(
                path: photo['path'] as String,
                exifJson: photo['exifJson'] as String?,
              ),
            );
          }
          _selectedKondisi = (data['selectedKondisi'] as int?) ?? 0;
          _selectedRekomendasi = (data['selectedRekomendasi'] as int?) ?? 0;
          final gpsLat = (data['gpsLat'] as num?)?.toDouble();
          final gpsLng = (data['gpsLng'] as num?)?.toDouble();
          if (gpsLat != null && gpsLng != null) {
            _capturedGps = (gpsLat, gpsLng);
          }
          _gpsAccuracy = (data['gpsAccuracy'] as num?)?.toDouble();
          _gpsCapturedAt = DateTime.tryParse(
            data['gpsCapturedAt'] as String? ?? '',
          );
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
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      setState(() {
        _capturedGps = (position.latitude, position.longitude);
        _gpsAccuracy = position.accuracy;
        _gpsCapturedAt = position.timestamp;
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
        showRequestFailure(context, e);
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_photos.length >= 3) return;
    _submitErrorDetails = null;
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        if (await image.length() > 10 * 1024 * 1024) {
          setState(
            () => _submitError = AppLocalizations.of(
              context,
            )!.surveyPhotoTooLarge,
          );
          return;
        }
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
      setState(() {
        _submitError = AppLocalizations.of(
          context,
        )!.mobileRequestFailedExplanation;
        _submitErrorDetails = e.toString();
      });
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
              leading: Icon(
                Icons.camera_alt,
                color: SigapColorScheme.of(context).primary,
              ),
              title: Text(AppLocalizations.of(context)!.kamera),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(cameraSource());
              },
            ),
            ListTile(
              leading: Icon(
                Icons.photo_library,
                color: SigapColorScheme.of(context).primary,
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
      _submitErrorDetails = null;
    });

    try {
      final client = ref.read(apiClientProvider);

      // Check connectivity: if offline, queue the visit for later sync
      final online =
          !ref.read(offlineModeProvider) && await SyncEngine.isOnline();
      if (!online) {
        // Build checklist from form data
        final kondisiLabels = [l10n.ringan, l10n.berat, l10n.kritis];
        final rekomendasiLabels = [
          l10n.validPerluTindakLanjut,
          l10n.tidakDitemukanDiLokasi,
          l10n.mobileAlreadyRepaired,
        ];
        final checklist = [
          ..._checklistItems,
          SurveyChecklistAnswer(
            item: 'Kondisi: ${kondisiLabels[_selectedKondisi]}',
            status: 'completed',
            notes: _damageDescriptionController.text.trim(),
          ),
          SurveyChecklistAnswer(
            item: 'Rekomendasi: ${rekomendasiLabels[_selectedRekomendasi]}',
            status: 'completed',
          ),
        ];

        // Serialize visit payload for later sync
        final visitPayload = jsonEncode({
          'task_id': widget.taskId,
          'findings': _notesController.text.trim(),
          'checklist': checklist.map((entry) => entry.toJson()).toList(),
          'photo_urls': <String>[], // Photos will need re-upload when online
          'gps_lat': _capturedGps!.$1,
          'gps_lng': _capturedGps!.$2,
          'accuracy': _gpsAccuracy!,
          'condition_assessment': kondisiLabels[_selectedKondisi],
          'recommendation': rekomendasiLabels[_selectedRekomendasi],
          'dimensions': _dimensionsController.text.trim(),
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
      final taskDetail = await client.getTaskDetail(widget.taskId!);
      final reportId = taskDetail.reportId;
      if (reportId == null) throw StateError('ID laporan tugas tidak tersedia');
      // Upload photos and collect public URLs
      final photoUrls = <String>[];
      for (var i = 0; i < _photos.length; i++) {
        final photo = _photos[i];
        final photoUrl = await client.uploadTaskPhoto(reportId, photo.path);
        photoUrls.add(photoUrl);
      }

      // Build checklist from form data
      final kondisiLabels = [l10n.ringan, l10n.berat, l10n.kritis];
      final rekomendasiLabels = [
        l10n.validPerluTindakLanjut,
        l10n.tidakDitemukanDiLokasi,
        l10n.mobileAlreadyRepaired,
      ];
      final checklist = [
        ..._checklistItems,
        SurveyChecklistAnswer(
          item: 'Kondisi: ${kondisiLabels[_selectedKondisi]}',
          status: 'completed',
          notes: _damageDescriptionController.text.trim(),
        ),
        SurveyChecklistAnswer(
          item: 'Rekomendasi: ${rekomendasiLabels[_selectedRekomendasi]}',
          status: 'completed',
        ),
      ];

      // Submit visit report directly via API when online
      final findings = _notesController.text.trim();
      await client.submitVisitReport(
        taskId: widget.taskId!,
        findings: findings,
        checklist: checklist,
        photoUrls: photoUrls,
        gpsLat: _capturedGps!.$1,
        gpsLng: _capturedGps!.$2,
        accuracy: _gpsAccuracy!,
        conditionAssessment: kondisiLabels[_selectedKondisi],
        recommendation: rekomendasiLabels[_selectedRekomendasi],
        dimensions: _dimensionsController.text.trim(),
        catatan: _notesController.text.trim(),
      );
      await client.taskAction(
        widget.taskId!,
        action: 'complete',
        note: findings,
      );

      await _cache.removeSurveyDraft(widget.taskId!);
      setState(() => _success = true);
    } catch (e) {
      setState(() {
        _submitError = l10n.mobileRequestFailedExplanation;
        _submitErrorDetails = e.toString();
      });
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
                Icon(
                  Icons.check_circle,
                  color: SigapColorScheme.of(context).primary,
                  size: 64,
                ),
                SizedBox(height: SigapSpacing.lg),
                Text(
                  l10n.surveiBerhasilDikirim,
                  style: TextStyle(
                    fontSize: SigapTypography.titleLarge,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: SigapSpacing.sm),
                Text(
                  _queuedOffline
                      ? l10n.dataSurveiTersimpanLokal
                      : l10n.dataSurveiTersimpanDiproses,
                  style: TextStyle(
                    color: SigapColorScheme.of(context).textSecondary,
                    fontSize: SigapTypography.bodyMedium,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: SigapSpacing.xl),
                ElevatedButton(
                  onPressed: () => context.push('/tasks'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SigapColorScheme.of(context).primary,
                    foregroundColor: SigapColorScheme.of(context).surface,
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
      backgroundColor: SigapColorScheme.of(context).bgScreen,
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
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: (_photos.length / 3).clamp(0.0, 1.0),
                          color: SigapColorScheme.of(context).primary,
                          backgroundColor: SigapColorScheme.of(
                            context,
                          ).borderCard,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        (AppLocalizations.of(
                          context,
                        )!.photoProgress(_photos.length, 3)),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
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
                              color: SigapColorScheme.of(context).textPrimary,
                            ),
                          ),
                          SizedBox(width: SigapSpacing.xxs),
                          Text(
                            ('*'),
                            style: TextStyle(
                              fontSize: SigapTypography.bodyText,
                              fontWeight: FontWeight.w700,
                              color: SigapColorScheme.of(context).danger,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: SigapSpacing.sm),
                  _FotoSudutRow(
                    photos: _photos,
                    onAddPhoto: _showPhotoSourceDialog,
                    onRemovePhoto: _removePhoto,
                  ),
                  SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(
                      context,
                    )!.mobileTapAPhotoToReplaceItMaximum1MB,
                    style: TextStyle(
                      fontSize: 12,
                      color: SigapColorScheme.of(context).textSecondary,
                    ),
                  ),
                  SizedBox(height: 18),

                  // 2. Kondisi Segmented Control — custom matching S-04 (Ringan/Berat/Kritis)
                  Row(
                    children: [
                      Text(
                        l10n.kondisiAktual,
                        style: TextStyle(
                          fontSize: SigapTypography.bodyText,
                          fontWeight: FontWeight.w700,
                          color: SigapColorScheme.of(context).textPrimary,
                        ),
                      ),
                      SizedBox(width: SigapSpacing.xxs),
                      Text(
                        ('*'),
                        style: TextStyle(
                          fontSize: SigapTypography.bodyText,
                          fontWeight: FontWeight.w700,
                          color: SigapColorScheme.of(context).danger,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: SigapSpacing.sm),
                  _buildKondisiSegmentedControl(),
                  SizedBox(height: 18),

                  // 3. GPS Section — GpsCaptureCard
                  _buildGpsCard(),
                  SizedBox(height: 18),

                  // 4. Dimensi Kerusakan
                  Row(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.mobileDamageDimensions,
                        style: TextStyle(
                          fontSize: SigapTypography.bodyText,
                          fontWeight: FontWeight.w700,
                          color: SigapColorScheme.of(context).textPrimary,
                        ),
                      ),
                      SizedBox(width: SigapSpacing.xxs),
                      Text(
                        ('*'),
                        style: TextStyle(
                          fontSize: SigapTypography.bodyText,
                          fontWeight: FontWeight.w700,
                          color: SigapColorScheme.of(context).danger,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: SigapSpacing.sm),
                  TextField(
                    controller: _dimensionsController,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(
                        context,
                      )!.mobileExampleLength2MWidth1M,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(SigapRadius.md),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: SigapSpacing.md,
                        vertical: SigapSpacing.sm,
                      ),
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                  SizedBox(height: 18),

                  // 5. Catatan Lapangan
                  CatatanLapangan(
                    controller: _notesController,
                    hintText: l10n.hintCatatanLapangan,
                    maxCharacters: 300,
                  ),
                  SizedBox(height: 18),

                  // 6. Rekomendasi Section
                  Row(
                    children: [
                      Text(
                        l10n.rekomendasiHasil,
                        style: TextStyle(
                          fontSize: SigapTypography.bodyText,
                          fontWeight: FontWeight.w700,
                          color: SigapColorScheme.of(context).textPrimary,
                        ),
                      ),
                      SizedBox(width: SigapSpacing.xxs),
                      Text(
                        ('*'),
                        style: TextStyle(
                          fontSize: SigapTypography.bodyText,
                          fontWeight: FontWeight.w700,
                          color: SigapColorScheme.of(context).danger,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: SigapSpacing.sm),
                  DropdownButtonFormField<int>(
                    initialValue: _selectedRekomendasi,
                    isExpanded: true,
                    decoration: InputDecoration(border: OutlineInputBorder()),
                    items: [
                      DropdownMenuItem(
                        value: 0,
                        child: Text(
                          AppLocalizations.of(context)!.validPerluTindakLanjut,
                        ),
                      ),
                      DropdownMenuItem(
                        value: 1,
                        child: Text(
                          AppLocalizations.of(context)!.tidakDitemukanDiLokasi,
                        ),
                      ),
                      DropdownMenuItem(
                        value: 2,
                        child: Text(
                          AppLocalizations.of(context)!.mobileAlreadyRepaired,
                        ),
                      ),
                    ],
                    onChanged: (value) =>
                        setState(() => _selectedRekomendasi = value ?? 0),
                  ),
                  SizedBox(height: 18),

                  // Error message
                  if (_submitError != null) ...[
                    SizedBox(height: SigapSpacing.lg),
                    Container(
                      padding: const EdgeInsets.all(SigapSpacing.md),
                      decoration: BoxDecoration(
                        color: SigapColorScheme.of(context).dangerBg,
                        borderRadius: BorderRadius.circular(SigapRadius.sm),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: SigapColorScheme.of(context).danger,
                            size: 18,
                          ),
                          SizedBox(width: SigapSpacing.sm),
                          Expanded(
                            child: _submitErrorDetails != null
                                ? RequestErrorDetails(
                                    details: _submitErrorDetails!,
                                    message: _submitError,
                                  )
                                : Text(
                                    _submitError!,
                                    style: TextStyle(
                                      color: SigapColorScheme.of(
                                        context,
                                      ).danger,
                                      fontSize: SigapTypography.bodyText,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  Container(
                    padding: const EdgeInsets.all(14),
                    color: SigapColorScheme.of(context).bgSoft,
                    child: Text(
                      AppLocalizations.of(
                        context,
                      )!.mobileResultsGoToTheOperatorForVerificationOfflineResults,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _submitting ? null : _autoSave,
                          child: Text(
                            AppLocalizations.of(context)!.mobileSaveDraft,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: FilledButton(
                          onPressed: _canSubmit && !_submitting
                              ? _submit
                              : null,
                          child: Text(
                            (_submitting
                                ? AppLocalizations.of(context)!.mobileSending
                                : ref.watch(offlineModeProvider)
                                ? AppLocalizations.of(
                                    context,
                                  )!.saveSurveyToQueue
                                : AppLocalizations.of(
                                    context,
                                  )!.submitSurveyResult),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Bottom Fixed Submit Button — S-02 SurveySubmitButton
        ],
      ),
    );
  }

  /// S-04 Header matching: "Form survei / TGS-3402 · offline" + "Tersimpan 10:02" + 66% progress
  Widget _FormSurveiHeader(BuildContext context) => MobileTitleBar(
    title: AppLocalizations.of(context)!.formSurveiHeader,
    subtitle:
        '${widget.taskId ?? ''} · ${(_lastSavedTime == null ? AppLocalizations.of(context)!.mobileNewDraft : AppLocalizations.of(context)!.mobileDraftSaved)}',
    onBack: () => context.pop(),
  );

  Widget _buildGpsCard() {
    final l10n = AppLocalizations.of(context)!;
    if (_capturedGps != null &&
        _gpsAccuracy != null &&
        _gpsAccuracy!.isFinite &&
        _gpsAccuracy! >= 0) {
      return GpsCaptureCard(
        latitude: _capturedGps!.$1,
        longitude: _capturedGps!.$2,
        accuracyMeters: _gpsAccuracy!,
        timestamp: _gpsCapturedAt,
        onRefresh: _captureGps,
      );
    }
    // Empty state: show placeholder matching S-04 appearance
    return GestureDetector(
      onTap: _gpsLoading ? null : _captureGps,
      child: Container(
        padding: const EdgeInsets.all(SigapSpacing.md),
        decoration: BoxDecoration(
          color: SigapColorScheme.of(context).bgCard,
          borderRadius: BorderRadius.circular(SigapRadius.lg),
          border: Border.all(color: SigapColorScheme.of(context).borderCard),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(SigapSpacing.sm),
              decoration: BoxDecoration(
                color: SigapColorScheme.of(context).bgSurface,
                borderRadius: BorderRadius.circular(SigapRadius.sm),
              ),
              child: AppIcons.locationIcon(
                color: SigapColorScheme.of(context).textTertiary,
                size: 24,
              ),
            ),
            SizedBox(width: SigapSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.gpsBelumTertangkap,
                    style: TextStyle(
                      color: SigapColorScheme.of(context).textPrimary,
                      fontSize: SigapTypography.bodyMedium,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    l10n.ketukUntukMenangkapGps,
                    style: TextStyle(
                      color: SigapColorScheme.of(context).textTertiary,
                      fontSize: SigapTypography.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            _gpsLoading
                ? SizedBox(
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
                      color: SigapColorScheme.of(context).primary,
                      borderRadius: BorderRadius.circular(SigapRadius.pill),
                    ),
                    child: Text(
                      l10n.ambilGPS,
                      style: TextStyle(
                        color: SigapColorScheme.of(context).surface,
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
    return DropdownButtonFormField<int>(
      initialValue: _selectedKondisi,
      decoration: InputDecoration(border: OutlineInputBorder()),
      items: [
        DropdownMenuItem(
          value: 0,
          child: Text(AppLocalizations.of(context)!.mobileMinor),
        ),
        DropdownMenuItem(
          value: 1,
          child: Text(AppLocalizations.of(context)!.mobileSevere),
        ),
        DropdownMenuItem(
          value: 2,
          child: Text(AppLocalizations.of(context)!.kritis),
        ),
      ],
      onChanged: (value) => setState(() => _selectedKondisi = value ?? 0),
    );
  }
}

/// Spec diagonal hatch for captured photo slots.
/// Repeating-linear-gradient(135deg,#e4e7e2 0 6px,#eef0ec 6px 12px).
class _HatchPainter extends CustomPainter {
  final SigapColorScheme colors;
  const _HatchPainter(this.colors);

  static const _stripeWidth = 6.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..strokeWidth = _stripeWidth;
    final stripeColors = [colors.borderCard, colors.bgSoft];
    final step = _stripeWidth * 1.414; // hypotenuse of 45° triangle
    final diag = size.width + size.height;
    final count = (diag / step).ceil();
    for (var i = -count; i <= count; i++) {
      paint.color = stripeColors[i.abs() % 2];
      final cx = i * step;
      // 135° line: direction (-1, 1) per unit
      canvas.drawLine(Offset(cx, 0), Offset(cx - diag, diag), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _HatchPainter old) => old.colors != colors;
}

/// Spec dashed border for empty photo slots.
/// 2px dashed #CFD3CC with 5px dash, 3px gap.
class _DashedBorderPainter extends CustomPainter {
  final double radius;

  final Color color;
  const _DashedBorderPainter({required this.color, this.radius = 11});

  static const _dash = 5.0;
  static const _gap = 3.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
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
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(SigapRadius.md),
                                  ),
                                ),
                                child: SizedBox.expand(
                                  child: CustomPaint(
                                    painter: _HatchPainter(
                                      SigapColorScheme.of(context),
                                    ),
                                  ),
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
                                  color: SigapColorScheme.of(context).bgSurface,
                                  child: Icon(Icons.image, size: 32),
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
                                    color: SigapColorScheme.of(
                                      context,
                                    ).textPrimary.withValues(alpha: 0.54),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.close,
                                    color: SigapColorScheme.of(context).surface,
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
                                    color: SigapColorScheme.of(
                                      context,
                                    ).borderSoft,
                                    radius: SigapRadius.md,
                                  ),
                                ),
                              ),
                              Center(
                                child: Text(
                                  ('+'),
                                  style: TextStyle(
                                    fontSize: SigapTypography.headlineMedium,
                                    color: SigapColorScheme.of(
                                      context,
                                    ).textMuted,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
                SizedBox(height: 4),
                Text(
                  hasPhoto ? '${labels[index]} ✓' : labels[index],
                  style: TextStyle(
                    color: hasPhoto
                        ? SigapColorScheme.of(context).textTertiary
                        : SigapColorScheme.of(context).danger,
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

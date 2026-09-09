import 'package:sigap/widgets/request_error_details.dart';
import 'package:sigap/l10n/report_condition_label.dart';
import 'package:sigap/l10n/category_label.dart';
import 'package:sigap/theme/sigap_color_scheme.dart';
import 'package:sigap/services/internet_reachability.dart';
import 'package:sigap/services/report_photo.dart';
import 'package:sigap/widgets/facility_icon.dart';

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:sigap/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:sigap/config/map_constants.dart';

import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' show Value;
import 'package:exif/exif.dart';
import 'package:sigap/theme/tokens.dart';
import 'package:sigap/db/database.dart';
import 'package:sigap/providers/providers.dart';
import 'package:sigap/utils/logger.dart';
import 'package:sigap/widgets/design_system/design_system.dart';
import 'package:sigap/widgets/design_system/mobile_title_bar.dart';

// ─── Severity levels ─────────────────────────────────────────────────────────
const List<String> _severityLevels = ['Ringan', 'Sedang', 'Berat', 'Kritis'];

class CreateReportScreen extends ConsumerStatefulWidget {
  final bool anonymousMode;

  const CreateReportScreen({super.key, this.anonymousMode = false});

  @override
  ConsumerState<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends ConsumerState<CreateReportScreen> {
  static final _logger = Logger('CreateReportScreen');

  // ── 5-step wizard state ────────────────────────────────────────────────
  int _step = 1;
  static const int _totalSteps = 5;
  List<String> get _stepNames => [
    AppLocalizations.of(context)!.kategori,
    AppLocalizations.of(context)!.mobilePhotoEvidence,
    AppLocalizations.of(context)!.lokasi,
    AppLocalizations.of(context)!.mobileCondition,
    AppLocalizations.of(context)!.mobileReview,
  ];

  // ── Form data ──────────────────────────────────────────────────────────
  String? _selectedCategory;
  String _title = '';
  final List<_PhotoEntry> _photos = [];
  String _selectedVillage = '';
  String? _kecamatan, _kabupaten, _provinsi, _addressAttribution;
  bool _villageEdited = false, _addressEdited = false;
  bool _addressLoading = false, _addressLookupFailed = false;
  int _addressGeneration = 0;
  Timer? _addressTimer;
  final _addressController = TextEditingController();
  final _villageController = TextEditingController();
  double? _lat;
  double? _lng;
  String _severity = 'Berat';
  bool _truthDeclared = false;
  String? _mergeCandidateId; // for duplicate merge

  // ── UI state ───────────────────────────────────────────────────────────
  final ImagePicker _picker = ImagePicker();
  bool _submitting = false;
  bool _isDirty = false;
  Timer? _autosaveTimer;
  String _draftId = Uuid().v4();
  final _descriptionController = TextEditingController();
  final _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _restoreDraft().then((_) {
      if (mounted && (_lat == null || _lng == null)) _getCurrentLocation();
    });
  }

  String get _draftKey =>
      'citizen_report_draft_${ref.read(authNotifierProvider).userId ?? 'anonymous'}';

  Map<String, dynamic> get _draftPayload => {
    'idempotency_key': _draftId,
    'category_id': _selectedCategory,
    'title': _titleController.text.trim(),
    'anonymous': widget.anonymousMode,
    'kecamatan': _kecamatan,
    'kabupaten': _kabupaten,
    'provinsi': _provinsi,
    'address_area': _addressController.text.trim(),
    'address_edited': _addressEdited,
    'village_edited': _villageEdited,
    'description': _descriptionController.text,
    'lat': _lat,
    'lng': _lng,
    'reported_severity': _severity.toLowerCase(),
    'kelurahan': _selectedVillage,
    'supporting_case_id': _mergeCandidateId,
    'photo_paths': _photos.map((photo) => photo.path).toList(),
    'original_photo_paths': _photos.map((photo) => photo.originalPath).toList(),
  };

  Future<void> _restoreDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_draftKey);
    if (saved == null || !mounted) return;
    try {
      final draft = jsonDecode(saved) as Map<String, dynamic>;
      setState(() {
        _draftId = draft['idempotency_key'] as String? ?? _draftId;
        _selectedCategory = draft['category_id'] as String?;
        _title = draft['title'] as String? ?? '';
        _titleController.text = _title;
        _descriptionController.text = draft['description'] as String? ?? '';
        _lat = (draft['lat'] as num?)?.toDouble();
        _lng = (draft['lng'] as num?)?.toDouble();
        _selectedVillage = draft['kelurahan'] as String? ?? _selectedVillage;
        _villageController.text = _selectedVillage;
        _addressController.text = draft['address_area'] as String? ?? '';
        _kecamatan = draft['kecamatan'] as String?;
        _kabupaten = draft['kabupaten'] as String?;
        _provinsi = draft['provinsi'] as String?;
        _villageEdited =
            draft['village_edited'] as bool? ?? _selectedVillage.isNotEmpty;
        _addressEdited =
            draft['address_edited'] as bool? ??
            _addressController.text.isNotEmpty;
        final severity = draft['reported_severity'] as String?;
        if (severity != null && severity.isNotEmpty) {
          _severity = '${severity[0].toUpperCase()}${severity.substring(1)}';
        }
        _mergeCandidateId = draft['supporting_case_id'] as String?;
        _photos.addAll(
          (draft['photo_paths'] as List? ?? [])
              .asMap()
              .entries
              .where((entry) => entry.value is String)
              .map((entry) {
                final originals = draft['original_photo_paths'] as List? ?? [];
                return _PhotoEntry(
                  path: entry.value as String,
                  originalPath: entry.key < originals.length
                      ? originals[entry.key] as String?
                      : null,
                );
              }),
        );
      });
    } catch (error, stack) {
      _logger.warning('Could not restore draft', error, stack);
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(accuracy: LocationAccuracy.medium),
      );
      if (mounted) {
        setState(() {
          _lat = position.latitude;
          _lng = position.longitude;
        });
        _scheduleAddressLookup();
        _onFormChanged();
      }
    } catch (e) {
      // Location unavailable — user can pick from map
    }
  }

  // ── Navigation ─────────────────────────────────────────────────────────

  void _scheduleAddressLookup() {
    _addressTimer?.cancel();
    final generation = ++_addressGeneration;
    final latitude = _lat;
    final longitude = _lng;
    if (latitude == null || longitude == null) return;
    setState(() {
      _kecamatan = _kabupaten = _provinsi = _addressAttribution = null;
      if (!_addressEdited) _addressController.clear();
      if (!_villageEdited) {
        _selectedVillage = '';
        _villageController.clear();
      }
      _addressLoading = true;
      _addressLookupFailed = false;
    });
    _addressTimer = Timer(const Duration(milliseconds: 500), () async {
      try {
        final address = await ref
            .read(apiClientProvider)
            .reverseGeocode(latitude, longitude);
        if (!mounted ||
            generation != _addressGeneration ||
            _lat != latitude ||
            _lng != longitude) {
          return;
        }
        setState(() {
          if (!_addressEdited) _addressController.text = address.addressArea;
          if (!_villageEdited) {
            _selectedVillage = address.kelurahan ?? '';
            _villageController.text = _selectedVillage;
          }
          _kecamatan = address.kecamatan;
          _kabupaten = address.kabupaten;
          _provinsi = address.provinsi;
          _addressAttribution = address.attribution;
          _addressLoading = false;
        });
        _onFormChanged();
      } catch (_) {
        if (!mounted || generation != _addressGeneration) return;
        setState(() {
          _addressLoading = false;
          _addressLookupFailed = true;
        });
      }
    });
  }

  bool _canProceed() {
    switch (_step) {
      case 1:
        return _selectedCategory != null && _title.length >= 8;
      case 2:
        return true; // Photos optional (can add later)
      case 3:
        return _lat != null && _lng != null;
      case 4:
        return _descriptionController.text.trim().length >= 15;
      case 5:
        return _truthDeclared;
      default:
        return false;
    }
  }

  void _nextStep() {
    if (_step < _totalSteps && _canProceed()) {
      setState(() => _step++);
      _onFormChanged();
    }
  }

  void _prevStep() {
    if (_step > 1) {
      setState(() => _step--);
    }
  }

  // ── Photo handling ─────────────────────────────────────────────────────

  Future<void> _pickPhoto(ImageSource source) async {
    final l10n = AppLocalizations.of(context)!;
    final photo = await _picker.pickImage(source: source);
    if (photo != null) {
      String? exifJson;
      try {
        final bytes = await photo.readAsBytes();
        if (bytes.length > 10 * 1024 * 1024) {
          throw FormatException(l10n.originalPhotoTooLarge);
        }
        final exifData = await readExifFromBytes(bytes);
        if (exifData.isNotEmpty) {
          exifJson = jsonEncode({
            for (final entry in exifData.entries)
              entry.key: entry.value.toString(),
          });
        }
        final strippedBytes = publicReportPhoto(bytes);
        final tempDir = await getApplicationDocumentsDirectory();
        final stamp = DateTime.now().microsecondsSinceEpoch;
        final extension = bytes.length > 8 && bytes[0] == 137
            ? 'png'
            : bytes.length > 12 && bytes[0] == 82 && bytes[8] == 87
            ? 'webp'
            : 'jpg';
        final originalFile = File(
          '${tempDir.path}/photo_${stamp}_original.$extension',
        );
        await originalFile.writeAsBytes(bytes);
        final strippedFile = File(
          '${tempDir.path}/photo_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        await strippedFile.writeAsBytes(strippedBytes);
        if (mounted) {
          setState(() {
            _photos.clear();
            _photos.add(
              _PhotoEntry(
                path: strippedFile.path,
                exifJson: exifJson,
                originalPath: originalFile.path,
              ),
            );
          });
          _onFormChanged();
        }
      } catch (e, s) {
        _logger.warning('Error capturing photo', e, s);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.reportPhotoPreparationFailed,
              ),
            ),
          );
        }
      }
    }
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
                _pickPhoto(ImageSource.camera);
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
                _pickPhoto(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ── Autosave ───────────────────────────────────────────────────────────

  void _onFormChanged() {
    if (_submitting) return;
    setState(() => _isDirty = true);
    _autosaveTimer?.cancel();
    _autosaveTimer = Timer(Duration(seconds: 2), () {
      if (_isDirty && mounted) _autosaveDraft();
    });
  }

  Future<void> _autosaveDraft() async {
    if (!_isDirty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_draftKey, jsonEncode(_draftPayload));
      if (!mounted) return;
      setState(() {
        _isDirty = false;
      });
    } catch (e, s) {
      _logger.warning('Autosave failed', e, s);
    }
  }

  // ── Submit ─────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_canProceed()) return;
    setState(() => _submitting = true);

    try {
      final client = ref.read(apiClientProvider);
      final idempotencyKey = _draftId;
      _autosaveTimer?.cancel();
      await _autosaveDraft();
      if (ref.read(offlineModeProvider) ||
          !await InternetReachability.isOnline()) {
        final now = DateTime.now();
        await ref.read(databaseProvider).transaction(() async {
          await ref
              .read(reportRepositoryProvider)
              .saveLocal(
                LocalReportsCompanion.insert(
                  idempotencyKey: _draftId,
                  categoryId: _selectedCategory!,
                  description: _descriptionController.text,
                  lat: _lat!,
                  lng: _lng!,
                  photoPath: Value(_photos.firstOrNull?.path),
                  createdAt: now,
                  updatedAt: now,
                ),
              );
          await ref
              .read(syncQueueRepositoryProvider)
              .enqueue(
                _draftId,
                kind: 'report',
                payloadJson: jsonEncode(_draftPayload),
              );
        });
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_draftKey);
        ref.invalidate(localReportsProvider);
        ref.invalidate(pendingCountProvider);
        if (mounted) context.go('/sync-center');
        return;
      }

      // Upload photos
      final uploadedUrls = <String>[];
      for (var i = 0; i < _photos.length; i++) {
        try {
          final url = await client.uploadReportPhotoAnon(
            _photos[i].path,
            idempotencyKey,
            slot: i,
            originalFilePath: _photos[i].originalPath,
          );
          uploadedUrls.add(url);
        } catch (e) {
          _logger.warning('Photo $i upload failed: $e');
          throw Exception(l10n.reportPhotoUploadRetry);
        }
      }

      // Submit report
      final result = await client.submitReport(
        idempotencyKey: idempotencyKey,
        categoryId: _selectedCategory!,
        description: _descriptionController.text,
        title: _titleController.text.trim(),
        reportedSeverity: _severity.toLowerCase(),
        supportingCaseId: _mergeCandidateId,
        anonymous: widget.anonymousMode,
        lat: _lat!,
        lng: _lng!,
        photoUrls: uploadedUrls,
        kecamatan: _kecamatan,
        kelurahan: _selectedVillage.isEmpty ? null : _selectedVillage,
        kabupaten: _kabupaten,
        provinsi: _provinsi,
        addressArea: _addressController.text,
      );

      // Save locally for offline support
      final reportRepo = ref.read(reportRepositoryProvider);
      await reportRepo.saveLocal(
        LocalReportsCompanion.insert(
          idempotencyKey: idempotencyKey,
          categoryId: _selectedCategory!,
          description: _descriptionController.text,
          lat: _lat!,
          lng: _lng!,
          photoPath: Value(uploadedUrls.isNotEmpty ? uploadedUrls.first : ''),
          exifDataJson: Value(
            _photos.isNotEmpty ? _photos.first.exifJson : null,
          ),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          serverId: Value(result.id),
          syncStatus: Value(1),
        ),
      );

      ref.invalidate(localReportsProvider);
      ref.invalidate(pendingCountProvider);
      ref.invalidate(wargaReportsProvider);
      ref.invalidate(wargaStatsProvider);
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_draftKey);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.laporanTersimpanTerkirim),
          backgroundColor: SigapColors.primary,
        ),
      );

      // Navigate to report detail
      final serverId = result.id ?? idempotencyKey;
      context.go('/laporan/$serverId');
    } catch (e, s) {
      _logger.error('Submit failed', e, s);
      if (!mounted) return;
      setState(() => _submitting = false);
      showRequestFailure(context, e);
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SigapColorScheme.of(context).bgSurface,
      appBar: MobileTitleBar(
        title: _step == 5
            ? AppLocalizations.of(context)!.reviewLaporan
            : AppLocalizations.of(context)!.buatLaporan,
        subtitle: AppLocalizations.of(
          context,
        )!.reportStepProgress(_step, _totalSteps, _stepNames[_step - 1]),
        onBack: () => context.pop(),
      ),
      body: Column(
        children: [
          // ── Stepper (mobile.css .m-stepper) ──────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(
              SigapSpacing.lg,
              SigapSpacing.md,
              SigapSpacing.lg,
              0,
            ),
            child: Row(
              children: List.generate(_totalSteps, (i) {
                final filled = i < _step;
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: EdgeInsets.only(right: i < _totalSteps - 1 ? 5 : 0),
                    decoration: BoxDecoration(
                      color: filled
                          ? SigapColorScheme.of(context).primary
                          : SigapColorScheme.of(context).borderCard,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),

          // ── Step content ─────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: _buildStepContent(),
            ),
          ),

          // ── Bottom actions (mobile.css .m-form-actions) ──────────────
          Container(
            padding: EdgeInsets.fromLTRB(
              SigapSpacing.lg,
              SigapSpacing.md,
              SigapSpacing.lg,
              SigapSpacing.lg + MediaQuery.of(context).padding.bottom,
            ),
            decoration: BoxDecoration(
              color: SigapColorScheme.of(context).bgSurface,
            ),
            child: Row(
              children: [
                if (_step > 1)
                  Expanded(
                    flex: 1,
                    child: OutlinedButton(
                      onPressed: _prevStep,
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: SigapSpacing.md,
                        ),
                        side: BorderSide(
                          color: SigapColorScheme.of(context).border,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(SigapRadius.md),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.mobileBack,
                        style: TextStyle(
                          color: SigapColorScheme.of(context).textSecondary,
                          fontSize: SigapTypography.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                if (_step > 1) SizedBox(width: SigapSpacing.sm),
                Expanded(
                  flex: _step < _totalSteps ? 2 : 2,
                  child: ElevatedButton(
                    onPressed: (_canProceed() && !_submitting)
                        ? (_step == _totalSteps ? _submit : _nextStep)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SigapColorScheme.of(context).primary,
                      foregroundColor: SigapColorScheme.of(context).surface,
                      disabledBackgroundColor: SigapColorScheme.of(
                        context,
                      ).primary.withValues(alpha: 0.5),
                      padding: EdgeInsets.symmetric(vertical: SigapSpacing.md),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(SigapRadius.md),
                      ),
                      elevation: 0,
                    ),
                    child: _submitting
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                SigapColorScheme.of(context).surface,
                              ),
                            ),
                          )
                        : Text(
                            (_step == _totalSteps
                                ? AppLocalizations.of(context)!.mobileSendReport
                                : AppLocalizations.of(context)!.mobileContinue),
                            style: TextStyle(
                              fontSize: SigapTypography.bodyText,
                              fontWeight: FontWeight.w600,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_step) {
      case 1:
        return _buildStep1Category();
      case 2:
        return _buildStep2Photo();
      case 3:
        return _buildLocation();
      case 4:
        return _buildCondition();
      case 5:
        return _buildStep5Review();
      default:
        return SizedBox.shrink();
    }
  }

  // ─── Step 1: Category + Title ──────────────────────────────────────────

  Widget _buildStep1Category() {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.mobileWhatWouldYouLikeToReport,
          style: TextStyle(
            fontSize: SigapTypography.titleLarge,
            fontWeight: FontWeight.w700,
            color: SigapColorScheme.of(context).textPrimary,
          ),
        ),
        SizedBox(height: SigapSpacing.xs),
        Text(
          AppLocalizations.of(context)!.mobileChooseTheTypeOfDamagedFacility,
          style: TextStyle(
            fontSize: SigapTypography.bodySmall,
            color: SigapColorScheme.of(context).textSecondary,
          ),
        ),
        SizedBox(height: SigapSpacing.lg),

        // ── Category Grid (mobile.css .m-category-grid) ────────────────
        categoriesAsync.when(
          loading: () => Center(child: CircularProgressIndicator()),
          error: (e, _) => Text(
            (AppLocalizations.of(context)!.errorDenganPesan(e.toString())),
          ),
          data: (categories) => GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              mainAxisExtent: 108,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              final name = cat.name ?? '';
              final isSelected = _selectedCategory == cat.id;
              final icon = facilityIcon(slug: cat.slug, name: name);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategory = cat.id;
                    _mergeCandidateId = null;
                  });
                  _onFormChanged();
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? SigapColorScheme.of(context).primaryLight
                        : SigapColorScheme.of(context).surface,
                    borderRadius: BorderRadius.circular(SigapRadius.x12),
                    border: Border.all(
                      color: isSelected
                          ? SigapColorScheme.of(context).primary
                          : SigapColorScheme.of(context).borderCard,
                      width: 1,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Selection indicator
                      if (isSelected)
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: SigapColorScheme.of(context).primary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 12,
                            ),
                          ),
                        ),
                      // Content
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              icon,
                              semanticLabel: name,
                              size: 28,
                              color: isSelected
                                  ? SigapColorScheme.of(context).primary
                                  : SigapColorScheme.of(context).textTertiary,
                            ),
                            SizedBox(height: SigapSpacing.xs),
                            Text(
                              (name),
                              style: TextStyle(
                                fontSize: SigapTypography.bodySmall,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: isSelected
                                    ? SigapColorScheme.of(context).primary
                                    : SigapColorScheme.of(context).textPrimary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        SizedBox(height: SigapSpacing.lg),

        // ── Title input ────────────────────────────────────────────────
        TextFormField(
          controller: _titleController,
          onChanged: (v) {
            setState(() => _title = v);
            _onFormChanged();
          },
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.mobileReportTitle,
            hintText: AppLocalizations.of(
              context,
            )!.mobileExamplePotholeNearTheMarket,
            labelStyle: TextStyle(
              color: SigapColorScheme.of(context).textSecondary,
            ),
            hintStyle: TextStyle(
              color: SigapColorScheme.of(context).textTertiary,
            ),
          ),
          maxLength: 120,
          validator: (v) => v == null || v.length < 8
              ? AppLocalizations.of(context)!.minimumEightCharacters
              : null,
        ),
      ],
    );
  }

  // ─── Step 2: Photo ─────────────────────────────────────────────────────

  Widget _buildStep2Photo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.mobileShowTheConditionsOnSite,
          style: TextStyle(
            fontSize: SigapTypography.titleLarge,
            fontWeight: FontWeight.w700,
            color: SigapColorScheme.of(context).textPrimary,
          ),
        ),
        SizedBox(height: SigapSpacing.xs),
        Text(
          AppLocalizations.of(
            context,
          )!.mobileTakeAClearPhotoWithoutFacesOrPersonalDetails,
          style: TextStyle(
            fontSize: SigapTypography.bodySmall,
            color: SigapColorScheme.of(context).textSecondary,
          ),
        ),
        SizedBox(height: SigapSpacing.lg),

        // ── Photo preview (mobile.css .m-photo-preview) ────────────────
        if (_photos.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(SigapRadius.x12),
            child: AspectRatio(
              aspectRatio: 1.3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(File(_photos.first.path), fit: BoxFit.cover),
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.mobileUPLOADEDEVIDENCE,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          // Empty state (mobile.css .m-photo-empty-large)
          AspectRatio(
            aspectRatio: 1.3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: SigapColorScheme.of(context).bgSoft,
                borderRadius: BorderRadius.circular(SigapRadius.x12),
                border: Border.all(
                  color: Color(0xFF91B6A8),
                  width: 2,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 40,
                    color: SigapColorScheme.of(context).primary,
                  ),
                  SizedBox(height: SigapSpacing.sm),
                  Text(
                    AppLocalizations.of(context)!.mobileNoPhotoYet,
                    style: TextStyle(
                      fontSize: SigapTypography.bodyLarge,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF16302B),
                    ),
                  ),
                  SizedBox(height: SigapSpacing.xs),
                  Text(
                    AppLocalizations.of(
                      context,
                    )!.mobileTakeOrChooseAPhotoFromYourDevice,
                    style: TextStyle(
                      fontSize: SigapTypography.bodySmall,
                      color: SigapColorScheme.of(context).textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),

        SizedBox(height: SigapSpacing.md),

        // ── Upload button (mobile.css .m-upload) ───────────────────────
        GestureDetector(
          onTap: _showPhotoSourceDialog,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(SigapSpacing.lg),
            decoration: BoxDecoration(
              color: SigapColorScheme.of(context).bgSoft,
              borderRadius: BorderRadius.circular(SigapRadius.x10),
              border: Border.all(
                color: Color(0xFF91B6A8),
                style: BorderStyle.solid,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _photos.isEmpty
                      ? Icons.add_a_photo
                      : Icons.add_photo_alternate,
                  color: SigapColorScheme.of(context).primaryDark,
                  size: 28,
                ),
                SizedBox(width: SigapSpacing.sm),
                Text(
                  (_photos.isEmpty
                      ? AppLocalizations.of(
                          context,
                        )!.mobileChoosePhotoFromDevice
                      : AppLocalizations.of(context)!.mobileReplacePhoto),
                  style: TextStyle(
                    color: SigapColorScheme.of(context).primaryDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: SigapSpacing.xs),
        Text(
          AppLocalizations.of(context)!.mobilePNGJPGWebPMax1MB,
          style: TextStyle(
            fontSize: SigapTypography.captionSmall,
            color: SigapColorScheme.of(context).textTertiary,
          ),
        ),

        // ── Photo actions ──────────────────────────────────────────────
        if (_photos.isNotEmpty) ...[
          SizedBox(height: SigapSpacing.sm),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() => _photos.clear());
                    _onFormChanged();
                  },
                  icon: Icon(Icons.close, size: 16),
                  label: Text(AppLocalizations.of(context)!.mobileRemovePhoto),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: SigapColorScheme.of(context).textSecondary,
                    side: BorderSide(
                      color: SigapColorScheme.of(context).border,
                    ),
                    padding: EdgeInsets.symmetric(vertical: SigapSpacing.sm),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  // ─── Step 3: Location ──────────────────────────────────────────────────

  Widget _buildLocation() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        AppLocalizations.of(context)!.mobileWhereIsItLocated,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
      SizedBox(height: 6),
      Text(
        AppLocalizations.of(context)!.reportLocationInstruction,
        style: TextStyle(
          fontSize: 12,
          color: SigapColorScheme.of(context).textTertiary,
        ),
      ),
      SizedBox(height: 18),
      Text(
        AppLocalizations.of(context)!.mobileVillage,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
      SizedBox(height: 8),
      TextFormField(
        controller: _villageController,
        decoration: InputDecoration(
          labelText: AppLocalizations.of(context)!.reportVillageLabel,
        ),
        onChanged: (value) {
          _villageEdited = true;
          _selectedVillage = value.trim();
          _onFormChanged();
        },
      ),
      SizedBox(height: 12),
      TextFormField(
        controller: _addressController,
        minLines: 2,
        maxLines: 3,
        decoration: InputDecoration(
          labelText: AppLocalizations.of(context)!.reportAddressLabel,
        ),
        onChanged: (_) {
          _addressEdited = true;
          _onFormChanged();
        },
      ),
      if (_addressLoading)
        Text(AppLocalizations.of(context)!.reportAddressLookupLoading),
      if (_addressLookupFailed)
        Text(AppLocalizations.of(context)!.reportAddressLookupFailed),
      if (_addressAttribution != null)
        Text(_addressAttribution!, style: TextStyle(fontSize: 11)),
      TextButton.icon(
        onPressed: _lat == null || _lng == null || _addressLoading
            ? null
            : _scheduleAddressLookup,
        icon: Icon(Icons.refresh),
        label: Text(AppLocalizations.of(context)!.reportAddressLookupRetry),
      ),
      SizedBox(height: 18),
      SizedBox(
        height: 230,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(_lat ?? -2.5, _lng ?? 118),
              initialZoom: _lat == null ? 4 : 14,
              onTap: (_, point) {
                setState(() {
                  _lat = point.latitude;
                  _lng = point.longitude;
                  _mergeCandidateId = null;
                });
                _scheduleAddressLookup();
                _onFormChanged();
              },
            ),
            children: [
              if (!ref.watch(offlineModeProvider))
                TileLayer(
                  urlTemplate: MapConstants.primaryTileUrl,
                  userAgentPackageName: 'id.kmipn.sigap',
                ),
              if (_lat != null && _lng != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(_lat!, _lng!),
                      child: Icon(
                        Icons.location_on,
                        color: SigapColorScheme.of(context).primary,
                        size: 32,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
      SizedBox(height: 18),
      Row(
        children: [
          Expanded(
            child: TextFormField(
              key: ValueKey('lat-$_lat'),
              initialValue: _lat?.toStringAsFixed(6),
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.latitude,
              ),
              keyboardType: TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              onFieldSubmitted: (value) {
                final parsed = double.tryParse(value);
                if (parsed != null && parsed >= -90 && parsed <= 90) {
                  setState(() => _lat = parsed);
                  _onFormChanged();
                }
              },
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: TextFormField(
              key: ValueKey('lng-$_lng'),
              initialValue: _lng?.toStringAsFixed(6),
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.longitude,
              ),
              keyboardType: TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              onFieldSubmitted: (value) {
                final parsed = double.tryParse(value);
                if (parsed != null && parsed >= -180 && parsed <= 180) {
                  setState(() => _lng = parsed);
                  _onFormChanged();
                }
              },
            ),
          ),
        ],
      ),
      SizedBox(height: 18),
      Container(
        padding: EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: SigapColorScheme.of(context).primaryLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          AppLocalizations.of(
            context,
          )!.mobileTapTheMapToMoveThePinPublicCoordinates,
          style: TextStyle(
            fontSize: 12,
            height: 1.5,
            color: SigapColorScheme.of(context).primaryDark,
          ),
        ),
      ),
    ],
  );

  // ─── Step 4: Severity ──────────────────────────────────────────────────

  Widget _buildCondition() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        AppLocalizations.of(context)!.mobileDescribeTheConditionsYouSee,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: -.15,
        ),
      ),
      SizedBox(height: 6),
      Text(
        AppLocalizations.of(context)!.mobileDetailsHelpStaffPrioritizeRepairs,
        style: TextStyle(
          fontSize: 12,
          color: SigapColorScheme.of(context).textTertiary,
        ),
      ),
      SizedBox(height: 18),
      Text(
        AppLocalizations.of(context)!.mobileDamageLevel,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
      SizedBox(height: 8),
      DropdownButtonFormField<String>(
        initialValue: _severity,
        items: _severityLevels
            .map(
              (value) => DropdownMenuItem(
                value: value,
                child: Text(reportConditionLabel(context, value)),
              ),
            )
            .toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() => _severity = value);
            _onFormChanged();
          }
        },
      ),
      SizedBox(height: 18),
      Text(
        AppLocalizations.of(context)!.mobileDescriptionImpact,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
      SizedBox(height: 8),
      TextFormField(
        controller: _descriptionController,
        minLines: 5,
        maxLines: 8,
        maxLength: 1000,
        decoration: InputDecoration(
          hintText: AppLocalizations.of(
            context,
          )!.mobileDescribeTheDamageSizeRisksAndAffectedResidents,
        ),
        onChanged: (_) => _onFormChanged(),
      ),
      SizedBox(height: 18),
      Container(
        padding: EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: SigapColorScheme.of(context).primaryLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          AppLocalizations.of(
            context,
          )!.mobileDescribeWhatYouObservedDoNotIncludeNamesPhone,
          style: TextStyle(
            fontSize: 12,
            height: 1.5,
            color: SigapColorScheme.of(context).primaryDark,
          ),
        ),
      ),
    ],
  );

  // ─── Step 5: Review ────────────────────────────────────────────────────

  Widget _buildStep5Review() {
    final categories = ref.watch(categoriesProvider).valueOrNull;
    final categoryName =
        categories
            ?.where((category) => category.id == _selectedCategory)
            .firstOrNull
            ?.name ??
        '-';
    final villageName = _selectedVillage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_lat != null && _lng != null && _selectedCategory != null)
          ref
              .watch(
                similarCasesProvider(
                  SimilarCasesParams(
                    lat: _lat!,
                    lng: _lng!,
                    categoryId: _selectedCategory!,
                  ),
                ),
              )
              .when(
                data: (cases) {
                  final candidate = cases.firstOrNull;
                  if (candidate == null) return SizedBox.shrink();
                  final candidateId = candidate.reportId;
                  if (candidateId == null) return SizedBox.shrink();
                  return Container(
                    margin: EdgeInsets.only(bottom: 18),
                    padding: EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: SigapColorScheme.of(context).infoBg,
                      border: Border.all(color: Color(0xFFC7D7FB)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(
                            context,
                          )!.mobileASimilarCaseWasFoundNearThisLocation,
                          style: TextStyle(
                            fontSize: 12,
                            color: SigapColorScheme.of(context).info,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 9),
                        Text(
                          (candidate.title ??
                              AppLocalizations.of(
                                context,
                              )!.mobileFacilityReport),
                          style: TextStyle(fontSize: 12),
                        ),
                        if (candidate.reportCount != null)
                          Text(
                            (AppLocalizations.of(
                              context,
                            )!.reportCount(candidate.reportCount!)),
                            style: TextStyle(fontSize: 10),
                          ),
                        SizedBox(height: 12),
                        RadioGroup<bool>(
                          groupValue: _mergeCandidateId == candidateId,
                          onChanged: (value) => setState(
                            () => _mergeCandidateId = value == true
                                ? candidateId
                                : null,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () => setState(
                                    () => _mergeCandidateId = candidateId,
                                  ),
                                  child: Row(
                                    children: [
                                      Radio<bool>(value: true),
                                      Flexible(
                                        child: Text(
                                          AppLocalizations.of(
                                            context,
                                          )!.mobileAddEvidence,
                                          style: TextStyle(fontSize: 10),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () =>
                                      setState(() => _mergeCandidateId = null),
                                  child: Row(
                                    children: [
                                      Radio<bool>(value: false),
                                      Flexible(
                                        child: Text(
                                          AppLocalizations.of(
                                            context,
                                          )!.mobileCreateSeparately,
                                          style: TextStyle(fontSize: 10),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
                loading: () => LinearProgressIndicator(),
                error: (_, __) => SizedBox.shrink(),
              ),
        // ── Eyebrow ────────────────────────────────────────────────────
        Text(
          AppLocalizations.of(context)!.ringkasanLaporanUppercase,
          style: TextStyle(
            fontSize: SigapTypography.captionSmall,
            fontWeight: FontWeight.w700,
            color: SigapColorScheme.of(context).textMuted,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: SigapSpacing.md),

        Text(AppLocalizations.of(context)!.reportReviewExplanation),
        const SizedBox(height: SigapSpacing.md),
        // ── Summary card (mobile.css .m-review-card) ───────────────────
        SigapCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo thumbnail
              if (_photos.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(SigapRadius.sm),
                  child: AspectRatio(
                    aspectRatio: 1.8,
                    child: Image.file(
                      File(_photos.first.path),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

              SizedBox(height: SigapSpacing.md),

              // Category + severity row
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: SigapSpacing.sm,
                      vertical: SigapSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: SigapColorScheme.of(context).primaryLight,
                      borderRadius: BorderRadius.circular(SigapRadius.sm),
                    ),
                    child: Text(
                      categoryLabel(context, categoryName).toUpperCase(),
                      style: TextStyle(
                        fontSize: SigapTypography.captionSmall,
                        fontWeight: FontWeight.w700,
                        color: SigapColorScheme.of(context).primary,
                      ),
                    ),
                  ),
                  Spacer(),
                  Text(
                    (AppLocalizations.of(context)!.conditionWithLabel(
                      reportConditionLabel(context, _severity),
                    )),
                    style: TextStyle(
                      fontSize: SigapTypography.captionSmall,
                      color: SigapColorScheme.of(context).textMuted,
                    ),
                  ),
                ],
              ),

              SizedBox(height: SigapSpacing.md),

              // Title
              Text(
                (_title.isNotEmpty
                    ? _title
                    : AppLocalizations.of(context)!.mobileReportTitle),
                style: TextStyle(
                  fontSize: SigapTypography.titleLarge,
                  fontWeight: FontWeight.w700,
                  color: SigapColorScheme.of(context).textPrimary,
                  height: 1.4,
                ),
              ),

              // Description
              if (_descriptionController.text.isNotEmpty) ...[
                SizedBox(height: SigapSpacing.sm),
                Text(
                  (_descriptionController.text),
                  style: TextStyle(
                    fontSize: SigapTypography.bodySmall,
                    color: SigapColorScheme.of(context).textSecondary,
                    height: 1.5,
                  ),
                ),
              ],

              SizedBox(height: SigapSpacing.md),
              Divider(height: 1, color: SigapColorScheme.of(context).border),
              SizedBox(height: SigapSpacing.md),

              // Location row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.lokasi,
                    style: TextStyle(
                      fontSize: SigapTypography.captionSmall,
                      color: SigapColorScheme.of(context).textMuted,
                    ),
                  ),
                  Text(
                    (AppLocalizations.of(
                      context,
                    )!.villageWithName(villageName)),
                    style: TextStyle(
                      fontSize: SigapTypography.bodySmall,
                      fontWeight: FontWeight.w600,
                      color: SigapColorScheme.of(context).textPrimary,
                    ),
                  ),
                ],
              ),

              SizedBox(height: SigapSpacing.sm),

              // Coordinates row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.mobileCoordinates,
                    style: TextStyle(
                      fontSize: SigapTypography.captionSmall,
                      color: SigapColorScheme.of(context).textMuted,
                    ),
                  ),
                  Text(
                    (_lat != null && _lng != null
                        ? '${_lat!.toStringAsFixed(4)}, ${_lng!.toStringAsFixed(4)}'
                        : AppLocalizations.of(
                            context,
                          )!.mobileLocationUnavailable),
                    style: TextStyle(
                      fontSize: SigapTypography.captionSmall,
                      fontFamily: SigapTypography.fontFamilyMono,
                      color: SigapColorScheme.of(context).textTertiary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        SizedBox(height: SigapSpacing.lg),

        // ── Privacy card ───────────────────────────────────────────────
        SigapCard(
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: SigapColorScheme.of(context).primaryLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_outline,
                  size: 14,
                  color: SigapColorScheme.of(context).primaryDark,
                ),
              ),
              SizedBox(width: SigapSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.mobileMyPublicIdentity,
                      style: TextStyle(
                        fontSize: SigapTypography.bodySmall,
                        fontWeight: FontWeight.w600,
                        color: SigapColorScheme.of(context).textPrimary,
                      ),
                    ),
                    Text(
                      AppLocalizations.of(
                        context,
                      )!.mobilePrivateVisibleOnlyToStaff,
                      style: TextStyle(
                        fontSize: SigapTypography.captionSmall,
                        color: SigapColorScheme.of(context).textMuted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context)!.privacyReportExplanation,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: SigapSpacing.lg),

        // ── Truth declaration checkbox (mobile.css .m-check) ───────────
        GestureDetector(
          onTap: () {
            setState(() => _truthDeclared = !_truthDeclared);
            _onFormChanged();
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: Duration(milliseconds: 200),
                width: 20,
                height: 20,
                margin: EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  color: _truthDeclared
                      ? SigapColorScheme.of(context).primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: _truthDeclared
                        ? SigapColorScheme.of(context).primary
                        : SigapColorScheme.of(context).borderCard,
                    width: 2,
                  ),
                ),
                child: _truthDeclared
                    ? Icon(Icons.check, color: Colors.white, size: 14)
                    : null,
              ),
              SizedBox(width: SigapSpacing.sm),
              Expanded(
                child: Text(
                  AppLocalizations.of(
                    context,
                  )!.mobileIConfirmThisInformationAccuratelyDescribesWhatIObserved,
                  style: TextStyle(
                    fontSize: SigapTypography.bodySmall,
                    color: SigapColorScheme.of(context).textPrimary,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _autosaveTimer?.cancel();
    _addressTimer?.cancel();
    _addressGeneration++;
    _addressController.dispose();
    _villageController.dispose();
    _descriptionController.dispose();
    _titleController.dispose();
    super.dispose();
  }
}

// ─── Photo entry model ───────────────────────────────────────────────────────

class _PhotoEntry {
  final String path;
  final String? exifJson;
  final String? originalPath;
  _PhotoEntry({required this.path, this.exifJson, this.originalPath});
}

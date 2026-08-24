import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import '../../providers/providers.dart';
import '../../theme/tokens.dart';
import '../../widgets/design_system/phone_frame.dart';
import '../../widgets/design_system/status_bar.dart';
import 'presentation/widgets/s02_checklist.dart';

class SurveyFormScreen extends ConsumerStatefulWidget {
  final String taskId;
  const SurveyFormScreen({super.key, required this.taskId});

  @override
  ConsumerState<SurveyFormScreen> createState() => _SurveyFormScreenState();
}

class _SurveyFormScreenState extends ConsumerState<SurveyFormScreen> {
  // Form state
  final _temuanController = TextEditingController();
  final _catatanController = TextEditingController();

  // GPS state
  (double, double)? _capturedGps;
  double? _gpsAccuracy;
  bool _gpsLoading = false;

  // Checklist state
  List<Map<String, dynamic>> _checklistItems = [];
  Set<int> _checkedItems = {};
  bool _checklistLoading = true;
  String? _checklistError;

  // Submission state
  bool _submitting = false;
  String? _submitError;
  bool _success = false;
  String? _visitId;

  // Kondisi and rekomendasi
  String _kondisi = 'ringan';
  String _rekomendasi = 'valid_needs_followup';

  bool get _canSubmit {
    final temuan = _temuanController.text.trim();
    if (temuan.length < 3) return false;
    if (_checkedItems.isEmpty) return false;
    if (_capturedGps == null) return false;
    return true;
  }

  @override
  void initState() {
    super.initState();
    _loadChecklistTemplate();
  }

  @override
  void dispose() {
    _temuanController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _loadChecklistTemplate() async {
    setState(() {
      _checklistLoading = true;
      _checklistError = null;
    });

    try {
      final client = ref.read(apiClientProvider);
      final template = await client.getTaskChecklistTemplate(widget.taskId);
      final items = template.items ?? [];

      // Normalize checklist items - API returns {id, item, required}
      // id IS the item text today per T17 context
      final normalized = items.map((item) {
        final id = item['id']?.toString() ?? item['item']?.toString() ?? '';
        return {
          'id': id,
          'item': item['item'] ?? item['id'] ?? '',
          'required': item['required'] == true,
        };
      }).toList();

      setState(() {
        _checklistItems = normalized;
        _checklistLoading = false;
      });
    } catch (e) {
      setState(() {
        _checklistError = e.toString();
        _checklistLoading = false;
      });
    }
  }

  Future<void> _captureGps() async {
    setState(() {
      _gpsLoading = true;
    });

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
        _gpsAccuracy = position.accuracy;
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
      setState(() {
        _gpsLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal capture GPS: $e')));
      }
    }
  }

  Future<void> _submit() async {
    if (!_canSubmit) return;

    setState(() {
      _submitting = true;
      _submitError = null;
    });

    try {
      final client = ref.read(apiClientProvider);

      // Build checklist from checked items
      final checklist = <Map<String, dynamic>>[];
      for (int i = 0; i < _checklistItems.length; i++) {
        if (_checkedItems.contains(i)) {
          final item = _checklistItems[i];
          checklist.add({
            'item_id': item['id'],
            'label': item['item'],
            'checked': true,
            'gps': _capturedGps != null
                ? {'lat': _capturedGps!.$1, 'lng': _capturedGps!.$2}
                : null,
          });
        }
      }

      // Validate checklist is not empty (shouldn't happen since _canSubmit checks)
      if (checklist.isEmpty) {
        throw ArgumentError('submitVisitReport requires non-empty checklist');
      }

      final result = await client.submitVisitReport(
        taskId: widget.taskId,
        findings: _temuanController.text.trim(),
        checklist: checklist,
        photoUrls: [],
        gpsLat: _capturedGps!.$1,
        gpsLng: _capturedGps!.$2,
        accuracy: _gpsAccuracy ?? 0.0,
        conditionAssessment: _kondisi,
        recommendation: _rekomendasi,
        catatan: _catatanController.text.trim().isNotEmpty
            ? _catatanController.text.trim()
            : null,
      );

      setState(() {
        _success = true;
        _visitId = result.visitId;
        _submitting = false;
      });
    } catch (e) {
      setState(() {
        _submitError = e.toString();
        _submitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_success) {
      return PhoneFrame(
        child: Column(
          children: [
            const StatusBar(),
            Expanded(
              child: Scaffold(
                backgroundColor: SigapColors.bgCard,
                appBar: AppBar(
                  backgroundColor: SigapColors.bgCard,
                  elevation: 0,
                  title: Text(
                    'Kunjungan Terkirim',
                    style: TextStyle(
                      fontSize: SigapTypography.size16,
                      fontWeight: FontWeight.w600,
                      color: SigapColors.textPrimary,
                    ),
                  ),
                ),
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(SigapSpacing.xl),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: SigapColors.selesai.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_circle,
                            color: SigapColors.selesai,
                            size: 48,
                          ),
                        ),
                        const SizedBox(height: SigapSpacing.lg),
                        Text(
                          'Kunjungan berhasil dikirim!',
                          style: TextStyle(
                            fontSize: SigapTypography.size17,
                            fontWeight: FontWeight.bold,
                            color: SigapColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (_visitId != null) ...[
                          const SizedBox(height: SigapSpacing.sm),
                          Text(
                            'Visit ID: $_visitId',
                            style: TextStyle(
                              fontSize: SigapTypography.size13,
                              fontFamily: SigapTypography.fontFamilyMono,
                              color: SigapColors.textSecondary,
                            ),
                          ),
                        ],
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
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                SigapRadius.md,
                              ),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Kembali ke Daftar',
                            style: TextStyle(
                              fontSize: SigapTypography.size14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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
          const StatusBar(),
          Expanded(
            child: Scaffold(
              backgroundColor: SigapColors.surface,
              appBar: AppBar(
                backgroundColor: SigapColors.bgCard,
                elevation: 0,
                toolbarHeight: 60,
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: SigapColors.textPrimary,
                    size: 22,
                  ),
                  onPressed: () => context.pop(),
                ),
                titleSpacing: 0,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Form Survei',
                      style: TextStyle(
                        fontSize: SigapTypography.size16,
                        fontWeight: FontWeight.w700,
                        color: SigapColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'TGS-${widget.taskId.substring(0, 4)}',
                      style: TextStyle(
                        fontSize: SigapTypography.size11,
                        fontWeight: FontWeight.w600,
                        fontFamily: SigapTypography.fontFamilyMono,
                        color: SigapColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              body: _checklistLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: SigapColors.primary,
                      ),
                    )
                  : _checklistError != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(SigapSpacing.xl),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 48,
                              color: SigapColors.perluTindakan,
                            ),
                            const SizedBox(height: SigapSpacing.md),
                            Text(
                              'Gagal memuat checklist:\n$_checklistError',
                              style: TextStyle(
                                fontSize: SigapTypography.size13,
                                color: SigapColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: SigapSpacing.md),
                            ElevatedButton(
                              onPressed: _loadChecklistTemplate,
                              child: const Text('Coba Lagi'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        // Error banner
                        if (_submitError != null)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(SigapSpacing.sm),
                            color: SigapColors.dangerBg,
                            child: Text(
                              'Error: $_submitError',
                              style: TextStyle(
                                fontSize: SigapTypography.size12,
                                color: SigapColors.dangerTextStrong,
                              ),
                            ),
                          ),
                        // Form content
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(SigapSpacing.md),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Temuan (Findings) - REQUIRED, min 3 chars
                                Text(
                                  'Temuan *',
                                  style: TextStyle(
                                    fontSize: SigapTypography.size13,
                                    fontWeight: FontWeight.w600,
                                    color: SigapColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: SigapSpacing.xs),
                                Text(
                                  'Minimum 3 karakter',
                                  style: TextStyle(
                                    fontSize: SigapTypography.size11,
                                    color: SigapColors.textTertiary,
                                  ),
                                ),
                                const SizedBox(height: SigapSpacing.sm),
                                TextField(
                                  controller: _temuanController,
                                  maxLines: 4,
                                  maxLength: 4000,
                                  onChanged: (_) => setState(() {}),
                                  decoration: InputDecoration(
                                    hintText: 'Deskripsikan temuan surve...',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        SigapRadius.md,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.all(
                                      SigapSpacing.md,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: SigapSpacing.lg),

                                // Checklist - REQUIRED, min 1 item checked
                                Text(
                                  'Checklist Survei *',
                                  style: TextStyle(
                                    fontSize: SigapTypography.size13,
                                    fontWeight: FontWeight.w600,
                                    color: SigapColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: SigapSpacing.xs),
                                Text(
                                  'Centang minimal 1 item',
                                  style: TextStyle(
                                    fontSize: SigapTypography.size11,
                                    color: SigapColors.textTertiary,
                                  ),
                                ),
                                const SizedBox(height: SigapSpacing.sm),
                                Container(
                                  padding: const EdgeInsets.all(
                                    SigapSpacing.md,
                                  ),
                                  decoration: BoxDecoration(
                                    color: SigapColors.bgCard,
                                    borderRadius: BorderRadius.circular(
                                      SigapRadius.x12,
                                    ),
                                    border: Border.all(
                                      color: SigapColors.border,
                                    ),
                                  ),
                                  child: S02Checklist(
                                    items: _checklistItems
                                        .map(
                                          (item) =>
                                              item['item'] as String? ?? '',
                                        )
                                        .toList(),
                                    checkedItems: _checkedItems,
                                    onItemToggled: (index) {
                                      setState(() {
                                        if (_checkedItems.contains(index)) {
                                          _checkedItems.remove(index);
                                        } else {
                                          _checkedItems.add(index);
                                        }
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(height: SigapSpacing.lg),

                                // GPS Card - REQUIRED
                                Text(
                                  'Lokasi GPS *',
                                  style: TextStyle(
                                    fontSize: SigapTypography.size13,
                                    fontWeight: FontWeight.w600,
                                    color: SigapColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: SigapSpacing.xs),
                                Text(
                                  'Wajib diisi untuk submit',
                                  style: TextStyle(
                                    fontSize: SigapTypography.size11,
                                    color: SigapColors.textTertiary,
                                  ),
                                ),
                                const SizedBox(height: SigapSpacing.sm),
                                GestureDetector(
                                  onTap: _gpsLoading ? null : _captureGps,
                                  child: Container(
                                    padding: const EdgeInsets.all(
                                      SigapSpacing.md,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _capturedGps != null
                                          ? SigapColors.selesai.withValues(
                                              alpha: 0.1,
                                            )
                                          : SigapColors.bgSoft,
                                      borderRadius: BorderRadius.circular(
                                        SigapRadius.md,
                                      ),
                                      border: Border.all(
                                        color: _capturedGps != null
                                            ? SigapColors.selesai
                                            : SigapColors.border,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          _capturedGps != null
                                              ? Icons.check_circle
                                              : Icons.location_on,
                                          color: _capturedGps != null
                                              ? SigapColors.selesai
                                              : SigapColors.textTertiary,
                                          size: 24,
                                        ),
                                        const SizedBox(width: SigapSpacing.sm),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                _capturedGps != null
                                                    ? 'Lokasi tertangkap'
                                                    : _gpsLoading
                                                    ? 'Mendeteksi lokasi...'
                                                    : 'Tap untuk capture GPS',
                                                style: TextStyle(
                                                  fontSize:
                                                      SigapTypography.size13,
                                                  fontWeight: FontWeight.w500,
                                                  color: _capturedGps != null
                                                      ? SigapColors.textPrimary
                                                      : SigapColors
                                                            .textSecondary,
                                                ),
                                              ),
                                              if (_capturedGps != null)
                                                Text(
                                                  '${_capturedGps!.$1.toStringAsFixed(6)}, ${_capturedGps!.$2.toStringAsFixed(6)}',
                                                  style: TextStyle(
                                                    fontSize:
                                                        SigapTypography.size11,
                                                    fontFamily: SigapTypography
                                                        .fontFamilyMono,
                                                    color: SigapColors
                                                        .textTertiary,
                                                  ),
                                                ),
                                              if (_gpsAccuracy != null)
                                                Text(
                                                  'Akurasi: ${_gpsAccuracy!.toStringAsFixed(1)}m',
                                                  style: TextStyle(
                                                    fontSize:
                                                        SigapTypography.size11,
                                                    color: SigapColors
                                                        .textTertiary,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        if (_gpsLoading)
                                          const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: SigapColors.primary,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: SigapSpacing.lg),

                                // Kondisi picker
                                Text(
                                  'Kondisi Kerusakan',
                                  style: TextStyle(
                                    fontSize: SigapTypography.size13,
                                    fontWeight: FontWeight.w600,
                                    color: SigapColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: SigapSpacing.sm),
                                Row(
                                  children: [
                                    _ConditionChip(
                                      label: 'Ringan',
                                      color: const Color(0xFF4CAF50),
                                      isSelected: _kondisi == 'ringan',
                                      onTap: () =>
                                          setState(() => _kondisi = 'ringan'),
                                    ),
                                    const SizedBox(width: SigapSpacing.sm),
                                    _ConditionChip(
                                      label: 'Berat',
                                      color: const Color(0xFFFF9800),
                                      isSelected: _kondisi == 'berat',
                                      onTap: () =>
                                          setState(() => _kondisi = 'berat'),
                                    ),
                                    const SizedBox(width: SigapSpacing.sm),
                                    _ConditionChip(
                                      label: 'Kritis',
                                      color: const Color(0xFFF44336),
                                      isSelected: _kondisi == 'kritis',
                                      onTap: () =>
                                          setState(() => _kondisi = 'kritis'),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: SigapSpacing.lg),

                                // Rekomendasi
                                Text(
                                  'Rekomendasi',
                                  style: TextStyle(
                                    fontSize: SigapTypography.size13,
                                    fontWeight: FontWeight.w600,
                                    color: SigapColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: SigapSpacing.sm),
                                _RecommendationOption(
                                  value: 'valid_needs_followup',
                                  label: 'Valid - Perlu ditindaklanjuti',
                                  isSelected:
                                      _rekomendasi == 'valid_needs_followup',
                                  onTap: () => setState(
                                    () => _rekomendasi = 'valid_needs_followup',
                                  ),
                                ),
                                const SizedBox(height: SigapSpacing.xs),
                                _RecommendationOption(
                                  value: 'not_found',
                                  label: 'Tidak ditemukan',
                                  isSelected: _rekomendasi == 'not_found',
                                  onTap: () => setState(
                                    () => _rekomendasi = 'not_found',
                                  ),
                                ),
                                const SizedBox(height: SigapSpacing.lg),

                                // Catatan textarea
                                Text(
                                  'Catatan (Opsional)',
                                  style: TextStyle(
                                    fontSize: SigapTypography.size13,
                                    fontWeight: FontWeight.w600,
                                    color: SigapColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: SigapSpacing.sm),
                                TextField(
                                  controller: _catatanController,
                                  maxLines: 3,
                                  decoration: InputDecoration(
                                    hintText: 'Tambahkan catatan survei...',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        SigapRadius.md,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.all(
                                      SigapSpacing.md,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: SigapSpacing.xl),
                              ],
                            ),
                          ),
                        ),
                        // Sticky footer
                        Container(
                          padding: const EdgeInsets.all(SigapSpacing.md),
                          decoration: BoxDecoration(
                            color: SigapColors.bgCard,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 4,
                                offset: const Offset(0, -2),
                              ),
                            ],
                          ),
                          child: SafeArea(
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _canSubmit && !_submitting
                                    ? _submit
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: SigapColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: SigapSpacing.md,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      SigapRadius.md,
                                    ),
                                  ),
                                  elevation: 0,
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
                                        'Kirim Kunjungan',
                                        style: TextStyle(
                                          fontSize: SigapTypography.size15,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
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
}

class _ConditionChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ConditionChip({
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: SigapSpacing.md,
          vertical: SigapSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(SigapRadius.pill),
          border: Border.all(color: color),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: SigapTypography.size12,
            color: isSelected ? Colors.white : color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _RecommendationOption extends StatelessWidget {
  final String value;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _RecommendationOption({
    required this.value,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(SigapSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? SigapColors.primary.withValues(alpha: 0.1)
              : SigapColors.bgCard,
          borderRadius: BorderRadius.circular(SigapRadius.md),
          border: Border.all(
            color: isSelected ? SigapColors.primary : SigapColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? SigapColors.primary : SigapColors.bgCard,
                border: Border.all(
                  color: isSelected ? SigapColors.primary : SigapColors.border,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: SigapSpacing.sm),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: SigapTypography.size13,
                  color: SigapColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

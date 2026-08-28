import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../api/api_client.dart';
import '../../api/types.g.dart';
import '../../l10n/strings.dart';
import '../../providers/providers.dart';
import '../../theme/tokens.dart';
import '../../utils/logger.dart';
import '../../widgets/design_system/design_system.dart';

/// Case Review screen for Verifikator to review and make decisions on cases.
///
/// Design tokens used:
/// - SigapColors: primary, danger, info, warning, bgCard, borderCard, textPrimary, textSecondary, textTertiary
/// - SigapSpacing: sm, md, lg, xxl
/// - SigapRadius: sm, md, lg
/// - SigapTypography: size11, size12, size13, size14, size16, size18, size22

class CaseReviewScreen extends ConsumerStatefulWidget {
  final String caseId;
  const CaseReviewScreen({super.key, required this.caseId});

  @override
  ConsumerState<CaseReviewScreen> createState() => _CaseReviewScreenState();
}

class _CaseReviewScreenState extends ConsumerState<CaseReviewScreen> {
  static final _logger = Logger('CaseReviewScreen');
  CaseDetail? _caseData;
  Map<String, dynamic>? _assessmentData;
  TimelineEnvelope? _timelineData;
  bool _loading = true;
  String? _error;
  bool _assessmentError = false; // Track if assessment fetch failed

  // Decision state
  String? _selectedDecision;
  final _reasonController = TextEditingController();
  final _duplicateIdController = TextEditingController();
  String? _selectedSurveyorId;
  List<UserResponse> _surveyors = [];
  bool _loadingSurveyors = false;
  bool _submitting = false;
  String? _submitError;
  bool _success = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final client = ref.read(apiClientProvider);
      final activeRole = ref.read(authNotifierProvider).activeRole ?? '';
      final caseData = await client.getVerifikatorCase(
        caseId: widget.caseId,
        activeRole: activeRole,
      );
      Map<String, dynamic>? assessmentData;
      bool assessmentError = false;
      try {
        final r = await client.getAiAssessment(widget.caseId);
        assessmentData = {
          'confidence': r.confidenceScore,
          'factors': {
            'supporting': r.supportingFactors ?? [],
            'risk': r.riskFactors ?? [],
            'correlation_ids': (r.duplicateCandidates ?? [])
                .map((e) => e.reportId?.toString() ?? '')
                .where((id) => id.isNotEmpty)
                .toList(),
          },
        };
      } catch (e, s) {
        _logger.warning('Error fetching assessment', e, s);
        // Assessment may not exist for all cases, but show visible error chip
        assessmentError = true;
        assessmentData = null;
      }
      TimelineEnvelope? timelineData;
      try {
        final timelineResult = await client.getReportTimeline(widget.caseId);
        timelineData = timelineResult;
      } catch (e, s) {
        _logger.warning('Error fetching timeline', e, s);
        timelineData = null;
      }
      setState(() {
        _caseData = caseData;
        _assessmentData = assessmentData;
        _assessmentError = assessmentError;
        _timelineData = timelineData;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  bool get _canSubmit {
    if (_selectedDecision == null) return false;
    // Reason is required for ALL decisions
    if (_reasonController.text.trim().isEmpty) return false;
    // needs_survey requires surveyor selection
    if (_selectedDecision == 'needs_survey' &&
        (_selectedSurveyorId == null || _selectedSurveyorId!.isEmpty)) {
      return false;
    }
    // duplicate requires duplicate_of_report_id
    if (_selectedDecision == 'duplicate' &&
        _duplicateIdController.text.trim().isEmpty) {
      return false;
    }
    return true;
  }

  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() {
      _submitting = true;
      _submitError = null;
    });
    try {
      final client = ref.read(apiClientProvider);
      final activeRole = ref.read(authNotifierProvider).activeRole ?? '';
      await client.decideVerifikatorCase(
        activeRole: activeRole,
        caseId: widget.caseId,
        decision: _selectedDecision!,
        reason: _reasonController.text.trim(),
        duplicateOfReportId: _selectedDecision == 'duplicate'
            ? (_duplicateIdController.text.trim().isNotEmpty
                  ? _duplicateIdController.text.trim()
                  : null)
            : null,
        surveyorId: _selectedDecision == 'needs_survey'
            ? _selectedSurveyorId
            : null,
      );
      setState(() => _success = true);
    } catch (e) {
      // Handle 409 INVALID_TRANSITION with friendly Indonesian message
      final errorStr = e.toString();
      if (errorStr.contains('409') ||
          errorStr.toLowerCase().contains('invalid_transition')) {
        setState(
          () => _submitError =
              'Transisi status tidak valid. Laporan mungkin sudah diproses.',
        );
      } else {
        setState(() => _submitError = 'Gagal mengirim keputusan: $errorStr');
      }
    } finally {
      setState(() => _submitting = false);
    }
  }

  Future<void> _loadSurveyors() async {
    setState(() => _loadingSurveyors = true);
    try {
      final client = ref.read(apiClientProvider);
      final activeRole = ref.read(authNotifierProvider).activeRole ?? '';
      final surveyors = await client.getSurveyors(activeRole: activeRole);
      setState(() {
        _surveyors = surveyors;
        _loadingSurveyors = false;
      });
    } catch (e) {
      _logger.warning('Failed to load surveyors', e);
      setState(() => _loadingSurveyors = false);
    }
  }

  void _showDecisionSheet(String decision, String label, Color color) {
    _reasonController.clear();
    _duplicateIdController.clear();
    _selectedSurveyorId = null;
    setState(() => _selectedDecision = decision);

    // Pre-fetch surveyors for needs_survey decision
    if (decision == 'needs_survey') {
      _loadSurveyors();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: SigapColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (decision == 'duplicate') ...[
                TextField(
                  controller: _duplicateIdController,
                  decoration: const InputDecoration(
                    labelText: 'ID Laporan Duplikat (WAJIB)',
                    hintText: 'Masukkan ID laporan duplikat',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (decision == 'needs_survey') ...[
                if (_loadingSurveyors) ...[
                  const Center(child: CircularProgressIndicator()),
                  const SizedBox(height: 12),
                ] else ...[
                  DropdownButtonFormField<String>(
                    initialValue: _selectedSurveyorId,
                    decoration: const InputDecoration(
                      labelText: 'Pilih Surveyor (WAJIB)',
                      border: OutlineInputBorder(),
                    ),
                    hint: const Text('Pilih surveyor'),
                    items: _surveyors.map((s) {
                      return DropdownMenuItem<String>(
                        value: s.id,
                        child: Text(s.name ?? s.email ?? s.id ?? '-'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() => _selectedSurveyorId = val);
                    },
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Surveyor wajib dipilih';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                ],
              ],
              TextField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: 'Alasan (WAJIB)',
                  hintText: 'Berikan alasan keputusan ini',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _canSubmit
                    ? () {
                        Navigator.pop(ctx);
                        _submit();
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: SigapColors.surface,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(Strings.kirimKeputusan),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _duplicateIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_success) {
      return Scaffold(
        appBar: AppBar(title: const Text('Verifikasi')),
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
              const Text(
                'Keputusan berhasil dikirim',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Kembali'),
              ),
            ],
          ),
        ),
      );
    }

    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text(Strings.detailKasus)),
        body: const VerifikatorCaseDetailSkeleton(),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text(Strings.detailKasus)),
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
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadData,
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    final caseData = _caseData!;
    final report = caseData.report;
    final photos = report?.photos ?? [];
    final categoryName = report?.category ?? '-';
    final status = report?.status?.value ?? '-';
    final description = report?.description ?? '-';
    final title = report?.title ?? '-';
    final createdAt = report?.createdAt;
    final lat = report?.location?['lat'] as double?;
    final lng = report?.location?['lng'] as double?;

    return Scaffold(
      appBar: AppBar(title: const Text(Strings.detailKasusVerifikasi)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(SigapSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(SigapSpacing.md),
              decoration: BoxDecoration(
                color: SigapColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(SigapRadius.md),
                border: Border.all(color: SigapColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: SigapSpacing.sm),
                  Row(
                    children: [
                      _StatusBadge(status: status),
                      const SizedBox(width: SigapSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: SigapSpacing.sm,
                          vertical: SigapSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: SigapColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(SigapRadius.sm),
                        ),
                        child: Text(
                          categoryName,
                          style: const TextStyle(
                            color: SigapColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (createdAt != null) ...[
                    const SizedBox(height: SigapSpacing.sm),
                    Text(
                      'Diajukan: ${_formatDate(createdAt)}',
                      style: TextStyle(
                        color: SigapColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: SigapSpacing.lg),

            // Location
            _SectionHeader(title: 'Lokasi'),
            Container(
              padding: const EdgeInsets.all(SigapSpacing.md),
              decoration: BoxDecoration(
                color: SigapColors.surface,
                borderRadius: BorderRadius.circular(SigapRadius.md),
                border: Border.all(color: SigapColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lat != null && lng != null
                        ? 'Koordinat: ${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}'
                        : 'Koordinat: Tidak tersedia',
                    style: const TextStyle(
                      fontSize: 13,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: SigapSpacing.sm),
                  OutlinedButton.icon(
                    onPressed: () => context.push('/map'),
                    icon: const Icon(Icons.map, size: 16),
                    label: const Text(Strings.lihatDiPeta),
                  ),
                ],
              ),
            ),
            const SizedBox(height: SigapSpacing.lg),

            // Photos
            if (photos.isNotEmpty) ...[
              _SectionHeader(title: 'Foto'),
              SizedBox(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: photos.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: SigapSpacing.sm),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => _showPhotoFullScreen(context, photos, index),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(SigapRadius.md),
                        child: Image.network(
                          photos[index],
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 120,
                            height: 120,
                            color: SigapColors.textMuted.withValues(alpha: 0.2),
                            child: const Icon(Icons.broken_image),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: SigapSpacing.lg),
            ],

            // Description
            _SectionHeader(title: 'Deskripsi'),
            Container(
              padding: const EdgeInsets.all(SigapSpacing.md),
              decoration: BoxDecoration(
                color: SigapColors.surface,
                borderRadius: BorderRadius.circular(SigapRadius.md),
                border: Border.all(color: SigapColors.border),
              ),
              child: Text(description, style: const TextStyle(fontSize: 14)),
            ),
            const SizedBox(height: SigapSpacing.lg),

            // AI Assessment
            if (_assessmentData != null) ...[
              _SectionHeader(title: 'Penilaian AI'),
              AiAssessmentCard(assessment: _assessmentData!),
              const SizedBox(height: SigapSpacing.lg),
            ] else if (_assessmentError) ...[
              // Show visible error chip when assessment fetch failed
              _SectionHeader(title: 'Penilaian AI'),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: SigapSpacing.md,
                  vertical: SigapSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: SigapColors.perluTindakan.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(SigapRadius.sm),
                  border: Border.all(color: SigapColors.perluTindakan),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 16,
                      color: SigapColors.perluTindakan,
                    ),
                    const SizedBox(width: SigapSpacing.sm),
                    Text(
                      'Assessment tidak tersedia',
                      style: TextStyle(
                        color: SigapColors.perluTindakan,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: SigapSpacing.lg),
            ],

            // Timeline
            if (_timelineData != null &&
                (_timelineData!.events?.isNotEmpty ?? false)) ...[
              _SectionHeader(title: 'Timeline'),
              _TimelineCard(data: _timelineData!),
              const SizedBox(height: SigapSpacing.lg),
            ],

            // 6-Decision Actions Panel
            _SectionHeader(title: 'Tindakan'),
            StickyActionBar(
              actions: [
                SigapActionButton(
                  label: Strings.ditolak,
                  semanticsLabel: Strings.ditolak,
                  onPressed: _submitting
                      ? null
                      : () => _showDecisionSheet(
                          'rejected',
                          Strings.ditolak,
                          SigapColors.perluTindakan,
                        ),
                  icon: Icons.cancel,
                ),
                SigapOutlineButton(
                  label: Strings.duplikat,
                  semanticsLabel: Strings.duplikat,
                  onPressed: _submitting
                      ? null
                      : () => _showDecisionSheet(
                          'duplicate',
                          Strings.tandaiDuplikat,
                          SigapColors.offlineDot,
                        ),
                  icon: Icons.link,
                ),
                SigapOutlineButton(
                  label: Strings.survei,
                  semanticsLabel: Strings.survei,
                  onPressed: _submitting
                      ? null
                      : () => _showDecisionSheet(
                          'needs_survey',
                          Strings.perluSurvei,
                          SigapColors.primary,
                        ),
                  icon: Icons.search,
                ),
                SigapOutlineButton(
                  label: Strings.dilute,
                  semanticsLabel: Strings.dilute,
                  onPressed: _submitting
                      ? null
                      : () => _showDecisionSheet(
                          'out_of_scope',
                          Strings.diluteJangkauan,
                          SigapColors.offlineDot,
                        ),
                  icon: Icons.block,
                ),
                SigapOutlineButton(
                  label: Strings.perluLengkapi,
                  semanticsLabel: Strings.perluLengkapi,
                  onPressed: _submitting
                      ? null
                      : () => _showDecisionSheet(
                          'needs_completion',
                          Strings.perluLengkapi,
                          SigapColors.diproses,
                        ),
                  icon: Icons.edit_note,
                ),
                SigapActionButton(
                  label: 'Valid',
                  semanticsLabel: 'Valid',
                  onPressed: _submitting
                      ? null
                      : () => _showDecisionSheet(
                          'valid',
                          'Valid — Terima Laporan',
                          SigapColors.selesai,
                        ),
                  icon: Icons.check_circle,
                ),
              ],
            ),
            if (_submitError != null) ...[
              const SizedBox(height: SigapSpacing.md),
              Text(
                'Error: $_submitError',
                style: const TextStyle(
                  color: SigapColors.perluTindakan,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e, s) {
      _logger.warning('Error parsing date "$iso"', e, s);
      return iso;
    }
  }

  void _showPhotoFullScreen(BuildContext ctx, List<String> photos, int index) {
    Navigator.of(ctx).push(
      MaterialPageRoute(
        builder: (_) => _PhotoFullScreen(photos: photos, initialIndex: index),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: SigapSpacing.sm),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: SigapColors.textPrimary,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  StatusTone get _tone {
    switch (status.toLowerCase()) {
      case 'submitted':
        return StatusTone.danger;
      case 'under_review':
        return StatusTone.neutral;
      case 'verified':
        return StatusTone.success;
      case 'in_progress':
        return StatusTone.info;
      case 'resolved':
        return StatusTone.success;
      case 'rejected':
        return StatusTone.danger;
      case 'duplicate_merged':
        return StatusTone.neutral;
      default:
        return StatusTone.neutral;
    }
  }

  String get _label {
    switch (status.toLowerCase()) {
      case 'submitted':
        return Strings.submitted;
      case 'under_review':
        return 'Under Review';
      case 'verified':
        return 'Verified';
      case 'in_progress':
        return 'In Progress';
      case 'resolved':
        return 'Resolved';
      case 'rejected':
        return Strings.rejected;
      case 'duplicate_merged':
        return Strings.duplikat;
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StatusPill(label: _label, tone: _tone, showDot: false);
  }
}

class _PhotoFullScreen extends StatefulWidget {
  final List<String> photos;
  final int initialIndex;
  const _PhotoFullScreen({required this.photos, required this.initialIndex});

  @override
  State<_PhotoFullScreen> createState() => _PhotoFullScreenState();
}

class _PhotoFullScreenState extends State<_PhotoFullScreen> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SigapColors.textPrimary,
      appBar: AppBar(
        backgroundColor: SigapColors.textPrimary,
        foregroundColor: SigapColors.surface,
        title: Text('${_currentIndex + 1} / ${widget.photos.length}'),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.photos.length,
        onPageChanged: (i) => setState(() => _currentIndex = i),
        itemBuilder: (context, index) {
          return InteractiveViewer(
            child: Center(
              child: Image.network(
                widget.photos[index],
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.broken_image,
                  color: SigapColors.surface,
                  size: 64,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  final TimelineEnvelope data;
  const _TimelineCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final events = data.events ?? [];

    return Container(
      padding: const EdgeInsets.all(SigapSpacing.md),
      decoration: BoxDecoration(
        color: SigapColors.surface,
        borderRadius: BorderRadius.circular(SigapRadius.md),
        border: Border.all(color: SigapColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < events.length; i++) ...[
            _TimelineEvent(event: events[i], isLast: i == events.length - 1),
          ],
        ],
      ),
    );
  }
}

class _TimelineEvent extends StatelessWidget {
  final TimelineEvent event;
  final bool isLast;
  const _TimelineEvent({required this.event, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final action = event.message ?? event.type ?? '-';
    final actor = event.userId ?? '-';
    final timestamp = event.timestamp ?? '';
    final note = event.message;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: SigapColors.primary,
                shape: BoxShape.circle,
              ),
            ),
            if (!isLast)
              Container(width: 2, height: 40, color: SigapColors.border),
          ],
        ),
        const SizedBox(width: SigapSpacing.sm),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: SigapSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  action,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: SigapColors.textPrimary,
                  ),
                ),
                if (actor != '-') ...[
                  const SizedBox(height: 2),
                  Text(
                    'oleh: $actor',
                    style: const TextStyle(
                      fontSize: 12,
                      color: SigapColors.textSecondary,
                    ),
                  ),
                ],
                if (timestamp.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    _formatDateTime(timestamp),
                    style: const TextStyle(
                      fontSize: 11,
                      color: SigapColors.textTertiary,
                    ),
                  ),
                ],
                if (note != null && note.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    note,
                    style: const TextStyle(
                      fontSize: 12,
                      color: SigapColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatDateTime(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }
}

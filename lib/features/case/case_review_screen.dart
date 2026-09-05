import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../api/client.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/providers.dart';
import '../../theme/tokens.dart';
import '../../widgets/design_system/design_system.dart';

/// Case Review Screen for the VERIFIKATOR role.
///
/// Core triage/decision UI where verifikators review case details and submit
/// decisions (valid, needs_completion, needs_survey, duplicate, rejected).
///
/// Route: `/case-review/:id`
class CaseReviewScreen extends ConsumerStatefulWidget {
  final String caseId;
  const CaseReviewScreen({super.key, required this.caseId});

  @override
  ConsumerState<CaseReviewScreen> createState() => _CaseReviewScreenState();
}

class _CaseReviewScreenState extends ConsumerState<CaseReviewScreen> {
  CaseDetail? _caseDetail;
  List<AgentAssessmentEntry> _assessments = [];
  bool _loading = true;
  String? _error;

  // Decision state
  String? _selectedDecision;
  final _reasonController = TextEditingController();
  final _duplicateIdController = TextEditingController();
  final _unitIdController = TextEditingController();
  String? _selectedSurveyorId;
  List<UserResponse> _surveyors = [];
  bool _loadingSurveyors = false;
  bool _submitting = false;
  String? _submitError;
  bool _success = false;

  // ─── Decision configuration ──────────────────────────────────────────────

  static const Map<String, _DecisionConfig> _decisionConfigs = {
    'valid': _DecisionConfig(
      labelKey: 'valid',
      icon: Icons.check_circle,
      color: SigapColors.selesai,
    ),
    'needs_completion': _DecisionConfig(
      labelKey: 'perluLengkapi',
      icon: Icons.edit_note,
      color: SigapColors.diproses,
    ),
    'needs_survey': _DecisionConfig(
      labelKey: 'perluSurvei',
      icon: Icons.search,
      color: SigapColors.primary,
    ),
    'duplicate': _DecisionConfig(
      labelKey: 'duplikat',
      icon: Icons.link,
      color: SigapColors.offlineDot,
    ),
    'rejected': _DecisionConfig(
      labelKey: 'tolak',
      icon: Icons.cancel,
      color: SigapColors.perluTindakan,
    ),
  };

  /// Decisions that require a mandatory reason (min 10 chars).
  static const Set<String> _reasonMandatory = {'duplicate', 'rejected'};

  // ─── Computed ──────────────────────────────────────────────────────────────

  bool get _canSubmit {
    if (_selectedDecision == null || _submitting) return false;
    if (_reasonMandatory.contains(_selectedDecision) &&
        _reasonController.text.trim().length < 10) {
      return false;
    }
    if (_selectedDecision == 'needs_survey' &&
        (_selectedSurveyorId == null || _selectedSurveyorId!.isEmpty)) {
      return false;
    }
    if (_selectedDecision == 'duplicate' &&
        _duplicateIdController.text.trim().isEmpty) {
      return false;
    }
    return true;
  }

  String _getDecisionLabel(String key, AppLocalizations l10n) {
    switch (key) {
      case 'valid':
        return l10n.valid;
      case 'needs_completion':
        return l10n.perluLengkapi;
      case 'needs_survey':
        return l10n.perluSurvei;
      case 'duplicate':
        return l10n.duplikat;
      case 'rejected':
        return l10n.ditolak;
      default:
        return key;
    }
  }

  // ─── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _duplicateIdController.dispose();
    _unitIdController.dispose();
    super.dispose();
  }

  // ─── Data loading ─────────────────────────────────────────────────────────

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final client = ref.read(apiClientProvider);
      final caseDetail = await client.getCaseDetail(widget.caseId);

      // Fetch AI assessment via /api/agent/assessments/:reportId (has full factors)
      // The case detail endpoint doesn't include supporting_factors/risk_factors/correlation_ids.
      List<AgentAssessmentEntry> assessments = [];
      try {
        final reportId = caseDetail.report?.id ?? widget.caseId;
        assessments = await client.getReportAssessments(reportId);
      } catch (_) {
        // AI assessment is optional
      }

      setState(() {
        _caseDetail = caseDetail;
        _assessments = assessments;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  // ─── Surveyors ────────────────────────────────────────────────────────────

  Future<void> _loadSurveyors() async {
    setState(() => _loadingSurveyors = true);
    try {
      final client = ref.read(apiClientProvider);
      final surveyors = await client.getUsersByRole('SURVEYOR');
      setState(() {
        _surveyors = surveyors;
        _loadingSurveyors = false;
      });
    } catch (_) {
      setState(() => _loadingSurveyors = false);
    }
  }

  // ─── Decision submission ──────────────────────────────────────────────────

  void _selectDecision(String decision, AppLocalizations l10n) {
    _reasonController.clear();
    _duplicateIdController.clear();
    _unitIdController.clear();
    _selectedSurveyorId = null;
    _submitError = null;
    setState(() => _selectedDecision = decision);

    if (decision == 'needs_survey') {
      _loadSurveyors();
    }

    // Show bottom sheet for the decision form
    _showDecisionSheet(
      decision,
      _getDecisionLabel(decision, l10n),
      _decisionConfigs[decision]!.color,
      l10n,
    );
  }

  void _showDecisionSheet(
    String decision,
    String label,
    Color color,
    AppLocalizations l10n,
  ) {
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: SigapColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Header
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 24,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(SigapRadius.x2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        label,
                        style: const TextStyle(
                          fontSize: SigapTypography.titleLarge,
                          fontWeight: FontWeight.bold,
                          color: SigapColors.textPrimary,
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

                // Conditional: Duplicate ID field
                if (decision == 'duplicate') ...[
                  TextField(
                    controller: _duplicateIdController,
                    decoration: InputDecoration(
                      labelText: l10n.labelIdLaporanDuplikatWajib,
                      hintText: 'UUID laporan primer',
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (_) => setSheetState(() {}),
                  ),
                  const SizedBox(height: 12),
                ],

                // Conditional: Surveyor select
                if (decision == 'needs_survey') ...[
                  if (_loadingSurveyors)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else
                    DropdownButtonFormField<String>(
                      value: _selectedSurveyorId,
                      decoration: InputDecoration(
                        labelText: l10n.labelPilihSurveyorWajib,
                        border: const OutlineInputBorder(),
                      ),
                      hint: Text(l10n.pilihSurveyor),
                      items: _surveyors
                          .map(
                            (s) => DropdownMenuItem<String>(
                              value: s.id,
                              child: Text(s.name ?? s.email ?? s.id ?? '-'),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        setSheetState(() => _selectedSurveyorId = val);
                      },
                    ),
                  const SizedBox(height: 12),
                ],

                // Conditional: Unit ID field (optional for valid)
                if (decision == 'valid') ...[
                  TextField(
                    controller: _unitIdController,
                    decoration: InputDecoration(
                      labelText: '${l10n.tindakan} (opsional)',
                      hintText: 'UUID unit penerima',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Reason field
                TextField(
                  controller: _reasonController,
                  decoration: InputDecoration(
                    labelText: _reasonMandatory.contains(decision)
                        ? '${l10n.labelAlasanWajib} (min 10)'
                        : '${l10n.labelAlasanWajib} (opsional)',
                    hintText: l10n.masukkanAlasanHint,
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  onChanged: (_) => setSheetState(() {}),
                ),
                const SizedBox(height: 20),

                // Submit button
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _canSubmit
                        ? () {
                            Navigator.pop(ctx);
                            _submitDecision();
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: SigapColors.surface,
                      disabledBackgroundColor: color.withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(SigapRadius.x8),
                      ),
                    ),
                    child: Text(
                      _submitting ? l10n.memuat : l10n.kirimKeputusan,
                      style: const TextStyle(
                        fontSize: SigapTypography.bodyLarge,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitDecision() async {
    if (_selectedDecision == null) return;
    setState(() {
      _submitting = true;
      _submitError = null;
    });
    try {
      final client = ref.read(apiClientProvider);
      final activeRole =
          ref.read(authNotifierProvider).activeRole ?? 'VERIFIKATOR';
      await client.decideCase(
        activeRole: activeRole,
        caseId: widget.caseId,
        decision: _selectedDecision!,
        reason: _reasonController.text.trim().isNotEmpty
            ? _reasonController.text.trim()
            : ' ',
        duplicateOfReportId: _selectedDecision == 'duplicate'
            ? (_duplicateIdController.text.trim().isNotEmpty
                  ? _duplicateIdController.text.trim()
                  : null)
            : null,
        surveyorId: _selectedDecision == 'needs_survey'
            ? _selectedSurveyorId
            : null,
        assignedUnitId:
            _selectedDecision == 'valid' &&
                _unitIdController.text.trim().isNotEmpty
            ? _unitIdController.text.trim()
            : null,
      );
      setState(() => _success = true);
    } catch (e) {
      final errorStr = e.toString();
      final l10n = AppLocalizations.of(context)!;
      if (errorStr.contains('409') ||
          errorStr.toLowerCase().contains('invalid_transition')) {
        setState(() => _submitError = l10n.transisiStatusTidakValid);
      } else {
        setState(() => _submitError = l10n.gagalMengirimKeputusan(errorStr));
      }
    } finally {
      setState(() => _submitting = false);
    }
  }

  // ─── Status helpers ──────────────────────────────────────────────────────

  StatusTone _getStatusTone(String? status) {
    switch (status?.toLowerCase()) {
      case 'submitted':
      case 'rejected':
      case 'out_of_scope':
        return StatusTone.danger;
      case 'under_review':
      case 'needs_completion':
      case 'needs_survey':
      case 'in_progress':
        return StatusTone.warning;
      case 'verified':
      case 'resolved':
        return StatusTone.success;
      default:
        return StatusTone.neutral;
    }
  }

  String _getStatusLabel(String? status, AppLocalizations l10n) {
    switch (status?.toLowerCase()) {
      case 'submitted':
        return l10n.labelSubmitted;
      case 'under_review':
        return l10n.labelUnderReview;
      case 'in_progress':
        return l10n.labelDiproses;
      case 'verified':
        return l10n.labelTerverifikasi;
      case 'resolved':
        return l10n.labelSelesai;
      case 'rejected':
        return l10n.labelDitolak;
      case 'needs_completion':
        return l10n.perluLengkapi;
      case 'needs_survey':
        return l10n.perluSurvei;
      default:
        return status ?? '-';
    }
  }

  bool _isReviewable(String? status) {
    switch (status?.toLowerCase()) {
      case 'submitted':
      case 'under_review':
        return true;
      default:
        return false;
    }
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_loading) {
      return ResponsiveScaffold(
        appBar: SigapAppBar(
          title: l10n.detailKasus,
          subtitle: widget.caseId.substring(
            0,
            8.clamp(0, widget.caseId.length),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null && _caseDetail == null) {
      return ResponsiveScaffold(
        appBar: SigapAppBar(title: l10n.detailKasus),
        body: Center(
          child: ErrorRetryView(
            message: l10n.gagalMemuatData,
            onRetry: _loadData,
          ),
        ),
      );
    }

    if (_success) {
      return ResponsiveScaffold(
        appBar: SigapAppBar(title: l10n.detailKasus),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: SigapColors.selesai,
                size: 64,
              ),
              const SizedBox(height: SigapSpacing.lg),
              Text(
                l10n.keputusanBerhasilDikirim,
                style: const TextStyle(
                  fontSize: SigapTypography.titleLarge,
                  fontWeight: FontWeight.bold,
                  color: SigapColors.textPrimary,
                ),
              ),
              const SizedBox(height: SigapSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SigapColors.primary,
                    foregroundColor: SigapColors.surface,
                    padding: const EdgeInsets.symmetric(
                      vertical: SigapSpacing.md,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(SigapRadius.x8),
                    ),
                  ),
                  child: Text(l10n.kembali),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final caseDetail = _caseDetail!;
    final report = caseDetail.report;
    final reportStatus = report?.status?.value ?? '';
    final assessment = _assessments.isNotEmpty ? _assessments.first : null;

    return ResponsiveScaffold(
      appBar: SigapAppBar(
        title: l10n.detailKasus,
        subtitle: widget.caseId.substring(0, 8.clamp(0, widget.caseId.length)),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(SigapSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Status badge
                  StatusPill(
                    label: _getStatusLabel(reportStatus, l10n),
                    tone: _getStatusTone(reportStatus),
                  ),
                  const SizedBox(height: SigapSpacing.lg),

                  // ── Report info card ──
                  _buildReportInfoCard(report, l10n),
                  const SizedBox(height: SigapSpacing.lg),

                  // ── AI Assessment ──
                  _buildAssessmentSection(assessment, l10n),
                  const SizedBox(height: SigapSpacing.lg),

                  // ── Photos ──
                  if (report?.photos != null && report!.photos!.isNotEmpty)
                    _buildPhotosSection(report.photos!, l10n),
                  if (report?.photos != null && report!.photos!.isNotEmpty)
                    const SizedBox(height: SigapSpacing.lg),

                  // ── Decision panel ──
                  if (_isReviewable(reportStatus))
                    _buildDecisionPanel(l10n)
                  else
                    _buildFinalStatusMessage(reportStatus, l10n),

                  // ── Error banner ──
                  if (_submitError != null) ...[
                    const SizedBox(height: SigapSpacing.md),
                    Container(
                      padding: const EdgeInsets.all(SigapSpacing.md),
                      decoration: BoxDecoration(
                        color: SigapColors.dangerBg,
                        borderRadius: BorderRadius.circular(SigapRadius.sm),
                        border: Border.all(color: SigapColors.dangerBorder),
                      ),
                      child: Text(
                        _submitError!,
                        style: const TextStyle(
                          color: SigapColors.dangerTextStrong,
                          fontSize: SigapTypography.bodyText,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: SigapSpacing.xl),

                  // ── Back button ──
                  SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () => context.pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: SigapColors.textSecondary,
                        side: const BorderSide(color: SigapColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(SigapRadius.x8),
                        ),
                      ),
                      child: Text(l10n.kembali),
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

  // ─── Report info card ────────────────────────────────────────────────────

  Widget _buildReportInfoCard(Report? report, AppLocalizations l10n) {
    return SigapCard(
      padding: const EdgeInsets.all(SigapSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category + severity row
          Row(
            children: [
              Icon(Icons.category, size: 18, color: SigapColors.textSecondary),
              const SizedBox(width: SigapSpacing.sm),
              Expanded(
                child: Text(
                  report?.category ?? l10n.kategori,
                  style: const TextStyle(
                    fontSize: SigapTypography.bodyLarge,
                    fontWeight: FontWeight.bold,
                    color: SigapColors.textPrimary,
                  ),
                ),
              ),
              if (report?.severity != null)
                StatusPill(
                  label: '${report!.severity}%',
                  tone: report.severity! >= 70
                      ? StatusTone.danger
                      : report.severity! >= 40
                      ? StatusTone.warning
                      : StatusTone.success,
                ),
            ],
          ),
          const SizedBox(height: SigapSpacing.sm),

          // Description
          if (report?.description != null &&
              report!.description!.isNotEmpty) ...[
            Text(
              report.description!,
              style: const TextStyle(
                fontSize: SigapTypography.bodyText,
                color: SigapColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: SigapSpacing.sm),
          ],

          // Created at
          if (report?.createdAt != null) ...[
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: SigapColors.textMuted),
                const SizedBox(width: SigapSpacing.xs),
                Text(
                  _formatDateTime(report!.createdAt!),
                  style: const TextStyle(
                    fontSize: SigapTypography.captionMedium,
                    color: SigapColors.textMuted,
                  ),
                ),
              ],
            ),
          ],

          // Location
          if (report?.lat != null && report?.lng != null) ...[
            const SizedBox(height: SigapSpacing.xs),
            Row(
              children: [
                Icon(Icons.location_on, size: 14, color: SigapColors.textMuted),
                const SizedBox(width: SigapSpacing.xs),
                Text(
                  '${report!.lat!.toStringAsFixed(5)}, ${report.lng!.toStringAsFixed(5)}',
                  style: const TextStyle(
                    fontSize: SigapTypography.captionMedium,
                    fontFamily: SigapTypography.fontFamilyMono,
                    color: SigapColors.textMuted,
                  ),
                ),
              ],
            ),
          ],

          // Address
          if (report?.address != null && report!.address!.isNotEmpty) ...[
            const SizedBox(height: SigapSpacing.xs),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.map, size: 14, color: SigapColors.textMuted),
                const SizedBox(width: SigapSpacing.xs),
                Expanded(
                  child: Text(
                    report.address!,
                    style: const TextStyle(
                      fontSize: SigapTypography.captionMedium,
                      color: SigapColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ─── AI Assessment section ───────────────────────────────────────────────

  Widget _buildAssessmentSection(
    AgentAssessmentEntry? assessment,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(label: l10n.labelPenilaianAI),
        const SizedBox(height: SigapSpacing.sm),
        if (assessment != null)
          AiAssessmentCard(
            assessment: {
              'confidence': assessment.confidence,
              'factors': {
                'supporting': assessment.supportingFactors ?? [],
                'risk': assessment.riskFactors ?? [],
              },
            },
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: SigapSpacing.md,
              vertical: SigapSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: SigapColors.textDisabled.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(SigapRadius.sm),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 16,
                  color: SigapColors.textMuted,
                ),
                const SizedBox(width: SigapSpacing.sm),
                Text(
                  l10n.assessmentTidakTersedia,
                  style: const TextStyle(
                    color: SigapColors.textMuted,
                    fontSize: SigapTypography.bodyText,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ─── Photos section ──────────────────────────────────────────────────────

  Widget _buildPhotosSection(List<String> photos, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(label: l10n.fotoLabel),
        const SizedBox(height: SigapSpacing.sm),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: photos.length,
            separatorBuilder: (_, __) => const SizedBox(width: SigapSpacing.sm),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          PhotoFullScreen(photos: photos, initialIndex: index),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(SigapRadius.sm),
                  child: Image.network(
                    photos[index],
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: SigapColors.bgSurface,
                        borderRadius: BorderRadius.circular(SigapRadius.sm),
                        border: Border.all(color: SigapColors.border),
                      ),
                      child: const Icon(
                        Icons.broken_image,
                        color: SigapColors.textMuted,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ─── Decision panel ──────────────────────────────────────────────────────

  Widget _buildDecisionPanel(AppLocalizations l10n) {
    return SigapCard(
      padding: const EdgeInsets.all(SigapSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel(label: l10n.tindakan),
          const SizedBox(height: SigapSpacing.md),

          // Decision buttons grid
          Wrap(
            spacing: SigapSpacing.sm,
            runSpacing: SigapSpacing.sm,
            children: _decisionConfigs.entries.map((entry) {
              final isSelected = _selectedDecision == entry.key;
              final config = entry.value;
              return SizedBox(
                height: 40,
                child: isSelected
                    ? FilledButton.icon(
                        onPressed: _submitting
                            ? null
                            : () => _selectDecision(entry.key, l10n),
                        icon: Icon(config.icon, size: 18),
                        label: Text(
                          _getDecisionLabel(entry.key, l10n),
                          style: const TextStyle(
                            fontSize: SigapTypography.bodySmall,
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: config.color,
                          foregroundColor: SigapColors.surface,
                          padding: const EdgeInsets.symmetric(
                            horizontal: SigapSpacing.md,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(SigapRadius.x8),
                          ),
                        ),
                      )
                    : OutlinedButton.icon(
                        onPressed: _submitting
                            ? null
                            : () => _selectDecision(entry.key, l10n),
                        icon: Icon(config.icon, size: 18),
                        label: Text(
                          _getDecisionLabel(entry.key, l10n),
                          style: const TextStyle(
                            fontSize: SigapTypography.bodySmall,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: SigapColors.textSecondary,
                          side: const BorderSide(color: SigapColors.border),
                          padding: const EdgeInsets.symmetric(
                            horizontal: SigapSpacing.md,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(SigapRadius.x8),
                          ),
                        ),
                      ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ─── Final status message ────────────────────────────────────────────────

  Widget _buildFinalStatusMessage(String status, AppLocalizations l10n) {
    return SigapCard(
      padding: const EdgeInsets.all(SigapSpacing.lg),
      child: Column(
        children: [
          Icon(Icons.info_outline, size: 32, color: SigapColors.textMuted),
          const SizedBox(height: SigapSpacing.md),
          Text(
            _getStatusLabel(status, l10n),
            style: const TextStyle(
              fontSize: SigapTypography.bodyLarge,
              fontWeight: FontWeight.bold,
              color: SigapColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: SigapSpacing.sm),
          Text(
            l10n.transisiStatusTidakValid,
            style: const TextStyle(
              fontSize: SigapTypography.bodyText,
              color: SigapColors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  String _formatDateTime(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }
}

// ─── Internal types ───────────────────────────────────────────────────────

class _DecisionConfig {
  final String labelKey;
  final IconData icon;
  final Color color;

  const _DecisionConfig({
    required this.labelKey,
    required this.icon,
    required this.color,
  });
}

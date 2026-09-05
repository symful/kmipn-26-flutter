import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../api/client.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/providers.dart';
import '../../theme/tokens.dart';
import '../../widgets/design_system/design_system.dart';
import '../../widgets/design_system/timeline_event.dart' as ds;
import '../../widgets/design_system/assign_dialog.dart';
import '../../capabilities/can.dart';
import 'case_workspace_ringkasan_tab.dart';
import 'case_workspace_audit_tab.dart';
import 'case_workspace_verifikasi_tab.dart';
import 'case_workspace_tugas_tab.dart';
import 'case_workspace_bukti_tab.dart';

/// W-04: Tabbed Case Workspace
///
/// Unified case detail screen with 5 tabs:
/// - Ringkasan (Summary)
/// - Bukti & Laporan (Evidence & Reports)
/// - Verifikasi (Verification - role-gated)
/// - Tugas & Progres (Tasks & Progress - role-gated)
/// - Riwayat Audit (Audit History)
///
/// Consolidates content from CaseActionScreen, CaseReviewScreen, and ReportDetailScreen.
/// Role-gated sections use the `Can` widget for capability-based visibility.
///
/// Route: /case-workspace/:id
class CaseWorkspaceScreen extends ConsumerStatefulWidget {
  final String caseId;
  const CaseWorkspaceScreen({super.key, required this.caseId});

  @override
  ConsumerState<CaseWorkspaceScreen> createState() =>
      _CaseWorkspaceScreenState();
}

class _CaseWorkspaceScreenState extends ConsumerState<CaseWorkspaceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  CaseDetail? _caseDetail;
  Map<String, dynamic>? _assessmentData;
  TimelineEnvelope? _timelineData;
  bool _loading = true;
  String? _error;
  bool _assessmentError = false;

  // Status-driven transitions map (mirrors Web SPA CaseDetail.tsx lines 523-592)
  static const Map<String, _StatusTransition> _statusTransitions = {
    'submitted': _StatusTransition(
      label: 'Menunggu Verifikasi',
      availableActions: [
        'valid',
        'needs_completion',
        'needs_survey',
        'duplicate',
        'rejected',
      ],
    ),
    'under_review': _StatusTransition(
      label: 'Menunggu Verifikasi',
      availableActions: [
        'valid',
        'needs_completion',
        'needs_survey',
        'duplicate',
        'rejected',
      ],
    ),
    'verified': _StatusTransition(
      label: 'Terverifikasi',
      availableActions: ['dispatch', 'combine'],
    ),
    'assigned': _StatusTransition(
      label: 'Ditugaskan',
      availableActions: ['resolve', 'reject'],
    ),
    'in_progress': _StatusTransition(
      label: 'Sedang Ditangani',
      availableActions: ['resolve', 'reject'],
    ),
  };

  List<_CaseAction> _getAvailableActions(AppLocalizations l10n) {
    final status = _caseDetail?.report?.status?.value ?? '';
    final transition = _statusTransitions[status];
    if (transition == null) return [];

    final actions = <_CaseAction>[];
    for (final action in transition.availableActions) {
      switch (action) {
        case 'valid':
          actions.add(
            _CaseAction(
              label: l10n.valid,
              icon: Icons.check_circle,
              onPressed: () =>
                  _showDecisionSheet('valid', l10n.valid, SigapColors.selesai),
            ),
          );
          break;
        case 'needs_completion':
          actions.add(
            _CaseAction(
              label: l10n.perluLengkapi,
              icon: Icons.edit_note,
              onPressed: () => _showDecisionSheet(
                'needs_completion',
                l10n.perluLengkapi,
                SigapColors.diproses,
              ),
            ),
          );
          break;
        case 'needs_survey':
          actions.add(
            _CaseAction(
              label: l10n.survei,
              icon: Icons.search,
              onPressed: () => _showDecisionSheet(
                'needs_survey',
                l10n.perluSurvei,
                SigapColors.primary,
              ),
            ),
          );
          break;
        case 'duplicate':
          actions.add(
            _CaseAction(
              label: l10n.duplikat,
              icon: Icons.link,
              onPressed: () => _showDecisionSheet(
                'duplicate',
                l10n.tandaiDuplikat,
                SigapColors.offlineDot,
              ),
            ),
          );
          break;
        case 'rejected':
          actions.add(
            _CaseAction(
              label: l10n.tolak,
              icon: Icons.cancel,
              onPressed: () => _showDecisionSheet(
                'rejected',
                l10n.ditolak,
                SigapColors.perluTindakan,
              ),
            ),
          );
          break;
        case 'dispatch':
          actions.add(
            _CaseAction(
              label: l10n.tugaskanPetugas,
              icon: Icons.send,
              onPressed: () => _showAssignDialog(),
            ),
          );
          break;
        case 'combine':
          actions.add(
            _CaseAction(
              label: l10n.gabungkan,
              icon: Icons.merge,
              onPressed: () => _showCombineDialog(),
            ),
          );
          break;
        case 'resolve':
          actions.add(
            _CaseAction(
              label: l10n.tandaiSelesai,
              icon: Icons.done_all,
              onPressed: () => _handleStatusChange('resolved'),
            ),
          );
          break;
      }
    }
    return actions;
  }

  void _showDecisionSheet(String decision, String label, Color color) {
    // Delegate to VerifikasiTab if on that tab, otherwise show a snackbar
    final l10n = AppLocalizations.of(context)!;
    if (_tabController.index == 2) {
      // Already on Verifikasi tab - the _VerifikasiTab handles its own decision sheet
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.aksiGunakanPanelVerifikasi(label))),
      );
    } else {
      // Switch to Verifikasi tab and trigger the action
      _tabController.animateTo(2);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.bukaTabVerifikasi(label))));
    }
  }

  void _showCombineDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.mergeKasus),
        content: Text(l10n.fiturGabungkanSegeraHadir),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.tutup),
          ),
        ],
      ),
    );
  }

  Future<void> _handleStatusChange(String newStatus) async {
    if (_caseDetail == null) return;
    try {
      final client = ref.read(apiClientProvider);
      final actionMap = <String, String>{
        'in_progress': 'dispatch',
        'resolved': 'close',
      };
      final action = actionMap[newStatus];
      if (action != null) {
        await client.caseAction(
          caseId: _caseDetail!.report!.id!,
          action: action,
        );
        _loadData(); // Refresh data
      }
    } catch (e) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.gagalUbahStatus(e.toString()))),
      );
    }
  }

  void _showAssignDialog() {
    if (_caseDetail?.report?.id == null) return;
    showDialog<bool>(
      context: context,
      builder: (ctx) => OperatorAssignDialog(caseId: _caseDetail!.report!.id!),
    ).then((assigned) {
      if (assigned == true) {
        _loadData(); // Refresh after successful assignment
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
      Map<String, dynamic>? assessmentData;
      bool assessmentError = false;
      try {
        final reportId = caseDetail.report?.id ?? widget.caseId;
        final entries = await client.getReportAssessments(reportId);
        final r = entries.isNotEmpty ? entries.first : null;
        if (r != null) {
          assessmentData = {
            'confidence': r.confidence,
            'factors': {
              'supporting': r.supportingFactors ?? [],
              'risk': r.riskFactors ?? [],
              'correlation_ids': <String>[],
            },
          };
        } else {
          // No assessments — not an error, just empty state
          assessmentData = null;
          assessmentError = false;
        }
      } catch (_) {
        assessmentData = null;
        assessmentError = false;
      }

      // Fetch timeline
      TimelineEnvelope? timelineData;
      try {
        timelineData = await client.getReportTimeline(widget.caseId);
      } catch (_) {
        timelineData = null;
      }

      setState(() {
        _caseDetail = caseDetail;
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ResponsiveScaffold(
      appBar: SigapAppBar(
        title: l10n.detailKasus,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(text: l10n.ringkasanTab),
            Tab(text: l10n.buktiLaporanTab),
            Tab(text: l10n.verifikasiTab),
            Tab(text: l10n.tugasProgresTab),
            Tab(text: l10n.riwayatAuditTab),
          ],
          labelColor: SigapColors.primary,
          unselectedLabelColor: SigapColors.textSecondary,
          indicatorColor: SigapColors.primary,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const CaseDetailSkeleton(actionCount: 5)
                : _error != null
                ? Center(
                    child: ErrorRetryView(
                      message: l10n.gagalMemuatData,
                      onRetry: _loadData,
                    ),
                  )
                : TabBarView(
                    controller: _tabController,
                    children: [
                      // Tab 1: Ringkasan (Summary)
                      CaseWorkspaceRingkasanTab(
                        caseDetail: _caseDetail!,
                        assessmentData: _assessmentData,
                        assessmentError: _assessmentError,
                      ),
                      // Tab 2: Bukti & Laporan (Evidence & Reports)
                      CaseWorkspaceBuktiTab(caseDetail: _caseDetail!),
                      // Tab 3: Verifikasi (Verification)
                      CaseWorkspaceVerifikasiTab(
                        caseId: widget.caseId,
                        caseDetail: _caseDetail!,
                        assessmentData: _assessmentData,
                        assessmentError: _assessmentError,
                      ),
                      // Tab 4: Tugas & Progres (Tasks & Progress)
                      CaseWorkspaceTugasTab(
                        caseId: widget.caseId,
                        caseDetail: _caseDetail!,
                      ),
                      // Tab 5: Riwayat Audit (Audit History)
                      CaseWorkspaceAuditTab(caseId: widget.caseId),
                    ],
                  ),
          ),
          // Sticky bottom action bar (mirrors Web SPA CaseDetail.tsx sticky bar)
          if (!_loading && _error == null) _buildStickyActionBar(),
        ],
      ),
    );
  }

  Widget _buildStickyActionBar() {
    final l10n = AppLocalizations.of(context)!;
    final actions = _getAvailableActions(l10n);
    if (actions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: const BoxDecoration(
        color: SigapColors.surface,
        border: Border(top: BorderSide(color: SigapColors.border, width: 1)),
      ),
      padding: EdgeInsets.only(
        left: SigapSpacing.lg,
        right: SigapSpacing.lg,
        top: SigapSpacing.md,
        bottom: SigapSpacing.md + MediaQuery.of(context).padding.bottom,
      ),
      child: Row(
        children: [
          Expanded(
            child: SigapOutlineButton(
              label: actions.first.label,
              icon: actions.first.icon,
              onPressed: actions.first.onPressed,
            ),
          ),
          if (actions.length > 1) ...[
            const SizedBox(width: SigapSpacing.sm),
            Expanded(
              child: SigapActionButton(
                label: actions[1].label,
                icon: actions[1].icon,
                onPressed: actions[1].onPressed,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Tab 3: Verifikasi (Verification - role-gated) ─────────────────────────

class _VerifikasiTab extends ConsumerStatefulWidget {
  final String caseId;
  final CaseDetail caseDetail;
  final Map<String, dynamic>? assessmentData;
  final bool assessmentError;

  const _VerifikasiTab({
    required this.caseId,
    required this.caseDetail,
    this.assessmentData,
    required this.assessmentError,
  });

  @override
  ConsumerState<_VerifikasiTab> createState() => _VerifikasiTabState();
}

class _VerifikasiTabState extends ConsumerState<_VerifikasiTab> {
  // Decision state (similar to CaseReviewScreen)
  String? _selectedDecision;
  final _reasonController = TextEditingController();
  final _duplicateIdController = TextEditingController();
  String? _selectedSurveyorId;
  List<UserResponse> _surveyors = [];
  bool _loadingSurveyors = false;
  bool _submitting = false;
  String? _submitError;
  bool _success = false;

  bool get _canSubmit {
    if (_selectedDecision == null) return false;
    if (_reasonController.text.trim().isEmpty) return false;
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

  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() {
      _submitting = true;
      _submitError = null;
    });
    try {
      final client = ref.read(apiClientProvider);
      final activeRole = ref.read(authNotifierProvider).activeRole ?? '';
      await client.decideCase(
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

  Future<void> _loadSurveyors() async {
    setState(() => _loadingSurveyors = true);
    try {
      final client = ref.read(apiClientProvider);
      final surveyors = await client.getUsersByRole('SURVEYOR');
      setState(() {
        _surveyors = surveyors;
        _loadingSurveyors = false;
      });
    } catch (e) {
      setState(() => _loadingSurveyors = false);
    }
  }

  void _showDecisionSheet(String decision, String label, Color color) {
    final l10n = AppLocalizations.of(context)!;
    _reasonController.clear();
    _duplicateIdController.clear();
    _selectedSurveyorId = null;
    setState(() => _selectedDecision = decision);

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
                  decoration: InputDecoration(
                    labelText: l10n.labelIdLaporanDuplikatWajib,
                    hintText: l10n.hintMasukkanIdLaporanDuplikat,
                    border: const OutlineInputBorder(),
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
                    value: _selectedSurveyorId,
                    decoration: InputDecoration(
                      labelText: l10n.labelPilihSurveyorWajib,
                      border: const OutlineInputBorder(),
                    ),
                    hint: Text(l10n.pilihSurveyor),
                    items: _surveyors.map((s) {
                      return DropdownMenuItem<String>(
                        value: s.id,
                        child: Text(s.name ?? s.email ?? s.id ?? '-'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() => _selectedSurveyorId = val);
                    },
                  ),
                  const SizedBox(height: 12),
                ],
              ],
              TextField(
                controller: _reasonController,
                decoration: InputDecoration(
                  labelText: l10n.labelAlasanWajib,
                  hintText: l10n.hintBerikanAlasanKeputusan,
                  border: const OutlineInputBorder(),
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
                child: Text(
                  l10n.kirimKeputusan,
                  style: const TextStyle(
                    fontSize: SigapTypography.bodyMedium,
                    fontWeight: FontWeight.w600,
                  ),
                ),
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
    final l10n = AppLocalizations.of(context)!;
    // Role-gated: Only show for VERIFIKATOR role (has case.verify capability)
    return Can(
      action: 'case.verify',
      resource: Resource(type: 'case', id: widget.caseId),
      fallback: AccessDeniedCard(message: l10n.andaTidakAksesVerifikasi),
      child: _buildVerificationContent(),
    );
  }

  Widget _buildVerificationContent() {
    final l10n = AppLocalizations.of(context)!;
    if (_success) {
      return Center(
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
              l10n.keputusanBerhasilDikirim,
              style: TextStyle(
                fontSize: SigapTypography.titleLarge,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.pop(),
              child: Text(
                l10n.kembali,
                style: const TextStyle(
                  fontSize: SigapTypography.bodyMedium,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Check if case is in a terminal status — hide all action buttons
    final status = widget.caseDetail.report?.status?.value ?? '';
    final isTerminal = CaseWorkspaceVerifikasiTab.isTerminalStatus(status);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(SigapSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // AI Assessment section
          if (widget.assessmentData != null) ...[
            SectionLabel(label: l10n.labelPenilaianAI),
            const SizedBox(height: SigapSpacing.sm),
            AiAssessmentCard(assessment: widget.assessmentData!),
            const SizedBox(height: SigapSpacing.lg),
          ] else if (widget.assessmentError) ...[
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
                    l10n.assessmentTidakTersedia,
                    style: TextStyle(
                      color: SigapColors.perluTindakan,
                      fontSize: SigapTypography.bodyText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: SigapSpacing.lg),
          ],

          // Decision Actions Panel — only for non-terminal statuses
          if (!isTerminal) ...[
            SectionLabel(label: l10n.tindakan),
            const SizedBox(height: SigapSpacing.md),
            StickyActionBar(
              actions: [
                SigapActionButton(
                  label: l10n.ditolak,
                  semanticsLabel: l10n.ditolak,
                  onPressed: _submitting
                      ? null
                      : () => _showDecisionSheet(
                          'rejected',
                          l10n.ditolak,
                          SigapColors.perluTindakan,
                        ),
                  icon: Icons.cancel,
                ),
                SigapOutlineButton(
                  label: l10n.duplikat,
                  semanticsLabel: l10n.duplikat,
                  onPressed: _submitting
                      ? null
                      : () => _showDecisionSheet(
                          'duplicate',
                          l10n.tandaiDuplikat,
                          SigapColors.offlineDot,
                        ),
                  icon: Icons.link,
                ),
                SigapOutlineButton(
                  label: l10n.survei,
                  semanticsLabel: l10n.survei,
                  onPressed: _submitting
                      ? null
                      : () => _showDecisionSheet(
                          'needs_survey',
                          l10n.perluSurvei,
                          SigapColors.primary,
                        ),
                  icon: Icons.search,
                ),
                SigapOutlineButton(
                  label: l10n.dilute,
                  semanticsLabel: l10n.dilute,
                  onPressed: _submitting
                      ? null
                      : () => _showDecisionSheet(
                          'out_of_scope',
                          l10n.diluteJangkauan,
                          SigapColors.offlineDot,
                        ),
                  icon: Icons.block,
                ),
                SigapOutlineButton(
                  label: l10n.perluDilengkapi,
                  semanticsLabel: l10n.perluDilengkapi,
                  onPressed: _submitting
                      ? null
                      : () => _showDecisionSheet(
                          'needs_completion',
                          l10n.perluDilengkapi,
                          SigapColors.diproses,
                        ),
                  icon: Icons.edit_note,
                ),
                SigapActionButton(
                  label: l10n.valid,
                  semanticsLabel: l10n.valid,
                  onPressed: _submitting
                      ? null
                      : () => _showDecisionSheet(
                          'valid',
                          l10n.valid,
                          SigapColors.selesai,
                        ),
                  icon: Icons.check_circle,
                ),
              ],
            ),
          ],
          if (_submitError != null) ...[
            const SizedBox(height: SigapSpacing.md),
            Text(
              l10n.errorLabel(_submitError!),
              style: const TextStyle(
                color: SigapColors.perluTindakan,
                fontSize: SigapTypography.bodyText,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Tab 4: Tugas & Progres (Tasks & Progress - role-gated) ────────────────

class _TugasProgresTab extends ConsumerWidget {
  final String caseId;
  final CaseDetail caseDetail;

  const _TugasProgresTab({required this.caseId, required this.caseDetail});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    // Role-gated: Only show for PETUGAS/OPERATOR roles
    return Can(
      action: 'task.view',
      resource: Resource(type: 'case', id: caseId),
      fallback: AccessDeniedCard(message: l10n.andaTidakAksesTugas),
      child: _buildTugasProgresContent(context, ref),
    );
  }

  Widget _buildTugasProgresContent(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final report = caseDetail.report;
    final status = report?.status?.value ?? '-';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(SigapSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Status info
          SigapCard(
            padding: const EdgeInsets.all(SigapSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.assignment,
                      color: SigapColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: SigapSpacing.sm),
                    Text(
                      l10n.statusKasus,
                      style: TextStyle(
                        fontSize: SigapTypography.bodyMedium,
                        fontWeight: FontWeight.bold,
                        color: SigapColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: SigapSpacing.sm),
                StatusPill(
                  label: _getStatusLabel(status, l10n),
                  tone: _getStatusTone(status),
                ),
              ],
            ),
          ),
          const SizedBox(height: SigapSpacing.lg),

          // Placeholder for task list
          _PlaceholderCard(
            title: l10n.tugasProgresTab,
            description: l10n.daftarTugasProgres,
          ),
        ],
      ),
    );
  }

  StatusTone _getStatusTone(String status) {
    switch (status.toLowerCase()) {
      case 'submitted':
      case 'rejected':
        return StatusTone.danger;
      case 'under_review':
      case 'in_progress':
        return StatusTone.warning;
      case 'verified':
      case 'resolved':
        return StatusTone.success;
      default:
        return StatusTone.neutral;
    }
  }

  String _getStatusLabel(String status, AppLocalizations l10n) {
    switch (status.toLowerCase()) {
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
      default:
        return status.isNotEmpty ? status : '-';
    }
  }
}

// ─── Tab 5: Riwayat Audit (Audit History) ───────────────────────────────────

class _RiwayatAuditTab extends StatelessWidget {
  final String caseId;
  final TimelineEnvelope? timelineData;

  const _RiwayatAuditTab({required this.caseId, this.timelineData});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Can(
      action: 'audit.view',
      resource: Resource(type: 'case', id: caseId),
      fallback: AccessDeniedCard(message: l10n.andaTidakAksesAudit),
      child: _buildAuditContent(context),
    );
  }

  Widget _buildAuditContent(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (timelineData == null || (timelineData!.events?.isEmpty ?? true)) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.history, size: 64, color: SigapColors.textMuted),
            const SizedBox(height: 16),
            Text(
              l10n.belumAdaRiwayatAudit,
              style: TextStyle(
                fontSize: SigapTypography.bodyLarge,
                color: SigapColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(SigapSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionLabel(label: l10n.riwayatAuditLabel),
          const SizedBox(height: SigapSpacing.md),
          SigapCard(
            padding: const EdgeInsets.all(SigapSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (
                  int i = 0;
                  i < (timelineData!.events ?? []).length;
                  i++
                ) ...[
                  ds.TimelineEvent(
                    title:
                        timelineData!.events![i].message ??
                        timelineData!.events![i].type ??
                        '-',
                    subtitle: _formatDateTime(
                      timelineData!.events![i].timestamp ?? '',
                    ),
                    actor: timelineData!.events![i].userId != null
                        ? l10n.olehLabel(timelineData!.events![i].userId!)
                        : null,
                    variant: ds.TimelineVariant.teal,
                    isLast: i == (timelineData!.events!.length - 1),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: SigapSpacing.lg),

          // Additional audit info placeholder
          _PlaceholderCard(
            title: l10n.detailAuditTitle,
            description: l10n.detailAuditDesc,
          ),
        ],
      ),
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

// ─── Shared Widgets ───────────────────────────────────────────────────────────

class _PlaceholderCard extends StatelessWidget {
  final String title;
  final String description;

  const _PlaceholderCard({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return SigapCard(
      padding: const EdgeInsets.all(SigapSpacing.lg),
      child: Column(
        children: [
          Icon(Icons.construction, size: 48, color: SigapColors.textMuted),
          const SizedBox(height: SigapSpacing.md),
          Text(
            title,
            style: TextStyle(
              fontSize: SigapTypography.bodyLarge,
              fontWeight: FontWeight.bold,
              color: SigapColors.textPrimary,
            ),
          ),
          const SizedBox(height: SigapSpacing.xs),
          Text(
            description,
            style: TextStyle(
              fontSize: SigapTypography.bodyText,
              color: SigapColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── Status Transitions Map (mirrors Web SPA CaseDetail.tsx) ───────────────────

class _StatusTransition {
  final String label;
  final List<String> availableActions;

  const _StatusTransition({
    required this.label,
    required this.availableActions,
  });
}

class _CaseAction {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _CaseAction({
    required this.label,
    required this.icon,
    required this.onPressed,
  });
}

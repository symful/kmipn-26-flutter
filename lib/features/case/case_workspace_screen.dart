import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../api/client.dart';
import '../../l10n/strings.dart';
import '../../providers/providers.dart';
import '../../theme/tokens.dart';
import '../../widgets/design_system/design_system.dart';
import '../../widgets/design_system/timeline_event.dart' as ds;
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
    'MENUNGGU_VERIFIKASI': _StatusTransition(
      label: 'Menunggu Verifikasi',
      availableActions: [
        'valid',
        'needs_completion',
        'needs_survey',
        'duplicate',
        'rejected',
      ],
    ),
    'TERVERIFIKASI': _StatusTransition(
      label: 'Terverifikasi',
      availableActions: ['dispatch', 'combine'],
    ),
    'SEDANG_DITANGANI': _StatusTransition(
      label: 'Sedang Ditangani',
      availableActions: ['resolve', 'reject'],
    ),
  };

  List<_CaseAction> _getAvailableActions() {
    final status = _caseDetail?.report?.status?.value ?? '';
    final transition = _statusTransitions[status];
    if (transition == null) return [];

    final actions = <_CaseAction>[];
    for (final action in transition.availableActions) {
      switch (action) {
        case 'valid':
          actions.add(
            _CaseAction(
              label: 'Valid',
              icon: Icons.check_circle,
              onPressed: () => _showDecisionSheet(
                'valid',
                'Valid — Terima Laporan',
                SigapColors.selesai,
              ),
            ),
          );
          break;
        case 'needs_completion':
          actions.add(
            _CaseAction(
              label: 'Perlu Lengkapi',
              icon: Icons.edit_note,
              onPressed: () => _showDecisionSheet(
                'needs_completion',
                'Perlu Lengkapi',
                SigapColors.diproses,
              ),
            ),
          );
          break;
        case 'needs_survey':
          actions.add(
            _CaseAction(
              label: 'Survei',
              icon: Icons.search,
              onPressed: () => _showDecisionSheet(
                'needs_survey',
                'Perlu Survei',
                SigapColors.primary,
              ),
            ),
          );
          break;
        case 'duplicate':
          actions.add(
            _CaseAction(
              label: 'Duplikat',
              icon: Icons.link,
              onPressed: () => _showDecisionSheet(
                'duplicate',
                'Tandai Duplikat',
                SigapColors.offlineDot,
              ),
            ),
          );
          break;
        case 'rejected':
          actions.add(
            _CaseAction(
              label: 'Tolak',
              icon: Icons.cancel,
              onPressed: () => _showDecisionSheet(
                'rejected',
                'Tolak Laporan',
                SigapColors.perluTindakan,
              ),
            ),
          );
          break;
        case 'dispatch':
          actions.add(
            _CaseAction(
              label: 'Tugaskan Petugas',
              icon: Icons.send,
              onPressed: () => _handleStatusChange('in_progress'),
            ),
          );
          break;
        case 'combine':
          actions.add(
            _CaseAction(
              label: 'Gabungkan',
              icon: Icons.merge,
              onPressed: () => _showCombineDialog(),
            ),
          );
          break;
        case 'resolve':
          actions.add(
            _CaseAction(
              label: 'Tandai Selesai',
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
    if (_tabController.index == 2) {
      // Already on Verifikasi tab - the _VerifikasiTab handles its own decision sheet
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Aksi "$label" - gunakan panel verifikasi')),
      );
    } else {
      // Switch to Verifikasi tab and trigger the action
      _tabController.animateTo(2);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Buka tab Verifikasi untuk aksi "$label"')),
      );
    }
  }

  void _showCombineDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Gabungkan Kasus'),
        content: const Text('Fitur gabungkan kasus akan segera hadir.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal ubah status: $e')));
    }
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

      // Fetch AI assessment if available
      Map<String, dynamic>? assessmentData;
      bool assessmentError = false;
      try {
        final list = await client.getAiAssessment(widget.caseId);
        final r = list.isNotEmpty ? list.first : null;
        if (r == null) {
          assessmentError = true;
          assessmentData = null;
        } else {
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
        }
      } catch (_) {
        assessmentError = true;
        assessmentData = null;
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.detailKasus),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Ringkasan'),
            Tab(text: 'Bukti & Laporan'),
            Tab(text: 'Verifikasi'),
            Tab(text: 'Tugas & Progres'),
            Tab(text: 'Riwayat Audit'),
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
                      message: 'Gagal memuat data',
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
    final actions = _getAvailableActions();
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
                    value: _selectedSurveyorId,
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
    // Role-gated: Only show for VERIFIKATOR role (has case.verify capability)
    return Can(
      action: 'case.verify',
      resource: Resource(type: 'case', id: widget.caseId),
      fallback: const _AccessDeniedPlaceholder(
        message: 'Anda tidak memiliki akses untuk memverifikasi kasus ini.',
      ),
      child: _buildVerificationContent(),
    );
  }

  Widget _buildVerificationContent() {
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
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(SigapSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // AI Assessment section
          if (widget.assessmentData != null) ...[
            Text(
              'Penilaian AI',
              style: TextStyle(
                fontSize: SigapTypography.size15,
                fontWeight: FontWeight.bold,
                color: SigapColors.textPrimary,
              ),
            ),
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
                    'Assessment tidak tersedia',
                    style: TextStyle(
                      color: SigapColors.perluTindakan,
                      fontSize: SigapTypography.size13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: SigapSpacing.lg),
          ],

          // Decision Actions Panel
          Text(
            'Tindakan',
            style: TextStyle(
              fontSize: SigapTypography.size15,
              fontWeight: FontWeight.bold,
              color: SigapColors.textPrimary,
            ),
          ),
          const SizedBox(height: SigapSpacing.md),
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
                fontSize: SigapTypography.size13,
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
    // Role-gated: Only show for PETUGAS/OPERATOR roles
    return Can(
      action: 'task.view',
      resource: Resource(type: 'case', id: caseId),
      fallback: const _AccessDeniedPlaceholder(
        message: 'Anda tidak memiliki akses untuk melihat tugas kasus ini.',
      ),
      child: _buildTugasProgresContent(context, ref),
    );
  }

  Widget _buildTugasProgresContent(BuildContext context, WidgetRef ref) {
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
                      'Status Kasus',
                      style: TextStyle(
                        fontSize: SigapTypography.size14,
                        fontWeight: FontWeight.bold,
                        color: SigapColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: SigapSpacing.sm),
                StatusPill(
                  label: _getStatusLabel(status),
                  tone: _getStatusTone(status),
                ),
              ],
            ),
          ),
          const SizedBox(height: SigapSpacing.lg),

          // Placeholder for task list
          _PlaceholderCard(
            title: 'Tugas & Progres',
            description:
                'Daftar tugas dan progres penanganan akan ditampilkan di sini.',
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

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'submitted':
        return 'Submitted';
      case 'under_review':
        return 'Under Review';
      case 'in_progress':
        return 'Diproses';
      case 'verified':
        return 'Terverifikasi';
      case 'resolved':
        return 'Selesai';
      case 'rejected':
        return 'Ditolak';
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
    return Can(
      action: 'audit.view',
      resource: Resource(type: 'case', id: caseId),
      fallback: const _AccessDeniedPlaceholder(
        message: 'Anda tidak memiliki akses untuk melihat riwayat audit.',
      ),
      child: _buildAuditContent(context),
    );
  }

  Widget _buildAuditContent(BuildContext context) {
    if (timelineData == null || (timelineData!.events?.isEmpty ?? true)) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.history, size: 64, color: SigapColors.textMuted),
            const SizedBox(height: 16),
            Text(
              'Belum ada riwayat audit',
              style: TextStyle(
                fontSize: SigapTypography.size16,
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
          Text(
            'Riwayat Audit',
            style: TextStyle(
              fontSize: SigapTypography.size15,
              fontWeight: FontWeight.bold,
              color: SigapColors.textPrimary,
            ),
          ),
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
                        ? 'oleh: ${timelineData!.events![i].userId}'
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
            title: 'Detail Audit',
            description: 'Detail lengkap audit chain akan ditampilkan di sini.',
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
              fontSize: SigapTypography.size16,
              fontWeight: FontWeight.bold,
              color: SigapColors.textPrimary,
            ),
          ),
          const SizedBox(height: SigapSpacing.xs),
          Text(
            description,
            style: TextStyle(
              fontSize: SigapTypography.size13,
              color: SigapColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _AccessDeniedPlaceholder extends StatelessWidget {
  final String message;

  const _AccessDeniedPlaceholder({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SigapSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline, size: 64, color: SigapColors.textMuted),
            const SizedBox(height: 16),
            Text(
              'Akses Ditolak',
              style: TextStyle(
                fontSize: SigapTypography.size18,
                fontWeight: FontWeight.bold,
                color: SigapColors.textPrimary,
              ),
            ),
            const SizedBox(height: SigapSpacing.sm),
            Text(
              message,
              style: TextStyle(
                fontSize: SigapTypography.size14,
                color: SigapColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
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

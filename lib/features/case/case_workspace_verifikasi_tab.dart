import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../api/client.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/providers.dart';
import '../../theme/tokens.dart';
import '../../widgets/design_system/design_system.dart';
import '../../capabilities/can.dart';

/// W-04 Verifikasi Tab Content
///
/// Verification tab for case workspace showing:
/// - AI Assessment card (if available)
/// - Verification action buttons (Setuju/Tolak/Minta Info)
/// - Decision modal sheets for each action type
///
/// Verifikator role can verify or reject cases.
/// Uses capabilities: case.verify, case.reject, case.request_info
///
/// This content was consolidated from CaseReviewScreen into the
/// case_workspace_screen tab structure.
class CaseWorkspaceVerifikasiTab extends ConsumerStatefulWidget {
  final String caseId;
  final CaseDetail caseDetail;
  final Map<String, dynamic>? assessmentData;
  final bool assessmentError;

  const CaseWorkspaceVerifikasiTab({
    super.key,
    required this.caseId,
    required this.caseDetail,
    this.assessmentData,
    required this.assessmentError,
  });

  /// Checks if a case status is terminal (resolved, rejected, closed, etc.)
  /// Terminal statuses should not show any action buttons.
  static bool isTerminalStatus(String status) {
    const terminalStatuses = {
      'SELESAI',
      'DITOLAK',
      'DUPLIKAT',
      'DITUTUP',
      'OUT_OF_SCOPE',
      'LUAR_CAKUPAN',
      'SEPARATED',
      'MERGED',
      'CLOSED',
      'RESOLVED',
      'REJECTED',
      'DUPLICATE_MERGED',
      'resolved',
      'rejected',
      'closed',
      'duplicate_merged',
      'merged',
      'separated',
      'out_of_scope',
    };
    return terminalStatuses.contains(status);
  }

  @override
  ConsumerState<CaseWorkspaceVerifikasiTab> createState() =>
      _CaseWorkspaceVerifikasiTabState();
}

class _CaseWorkspaceVerifikasiTabState
    extends ConsumerState<CaseWorkspaceVerifikasiTab> {
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
                    initialValue: _selectedSurveyorId,
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
    // Role-gated: Only show for VERIFIKATOR roles (has case.verify/reject/request_info capabilities)
    return Can(
      action: 'case.verify',
      resource: Resource(type: 'case', id: widget.caseId),
      fallback: AccessDeniedCard(message: l10n.andaTidakAksesVerifikasi),
      child: _buildVerificationContent(l10n),
    );
  }

  Widget _buildVerificationContent(AppLocalizations l10n) {
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
            _SectionLabel(label: l10n.labelPenilaianAI),
            const SizedBox(height: SigapSpacing.sm),
            AiAssessmentCard(assessment: widget.assessmentData!),
            const SizedBox(height: SigapSpacing.lg),
          ] else if (widget.assessmentError) ...[
            _SectionLabel(label: l10n.labelPenilaianAI),
            const SizedBox(height: SigapSpacing.sm),
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
            _SectionLabel(label: l10n.tindakan),
            const SizedBox(height: SigapSpacing.md),
            StickyActionBar(
              actions: [
                // Tolak (Reject) - case.reject capability
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
                // Duplikat (Duplicate)
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
                // Survei (Survey)
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
                // Diluar Jangkauan (Out of Scope)
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
                // Perlu Lengkapi (Needs Completion)
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
                // Setuju/Valid (Verify/Approve) - case.verify capability
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

/// Section label widget for consistent styling across tabs.
class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: SigapTypography.subtitle,
        fontWeight: FontWeight.bold,
        color: SigapColors.textPrimary,
      ),
    );
  }
}

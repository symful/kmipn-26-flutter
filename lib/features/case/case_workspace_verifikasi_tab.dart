import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../api/client.dart';
import '../../l10n/strings.dart';
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
/// RT_RW/Verifikator role can verify or reject cases.
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
    // Role-gated: Only show for VERIFIKATOR/RT_RW roles (has case.verify/reject/request_info capabilities)
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
              child: const Text(Strings.kembali),
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
            _SectionLabel(label: 'Penilaian AI'),
            const SizedBox(height: SigapSpacing.sm),
            AiAssessmentCard(assessment: widget.assessmentData!),
            const SizedBox(height: SigapSpacing.lg),
          ] else if (widget.assessmentError) ...[
            _SectionLabel(label: 'Penilaian AI'),
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
          _SectionLabel(label: 'Tindakan'),
          const SizedBox(height: SigapSpacing.md),
          StickyActionBar(
            actions: [
              // Tolak (Reject) - case.reject capability
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
              // Duplikat (Duplicate)
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
              // Survei (Survey)
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
              // Diluar Jangkauan (Out of Scope)
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
              // Perlu Lengkapi (Needs Completion)
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
              // Setuju/Valid (Verify/Approve) - case.verify capability
              SigapActionButton(
                label: Strings.valid,
                semanticsLabel: Strings.valid,
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

/// Section label widget for consistent styling across tabs.
class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: SigapTypography.size15,
        fontWeight: FontWeight.bold,
        color: SigapColors.textPrimary,
      ),
    );
  }
}

/// Access denied placeholder shown when user lacks verification capabilities.
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
            const Icon(
              Icons.lock_outline,
              size: 64,
              color: SigapColors.textMuted,
            ),
            const SizedBox(height: 16),
            const Text(
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
              style: const TextStyle(
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

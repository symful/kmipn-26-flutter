import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../api/types.g.dart';
import '../../l10n/strings.dart';
import '../../providers/providers.dart';
import '../../theme/tokens.dart';
import '../../widgets/design_system/design_system.dart';
import '../../widgets/design_system/merge_dialog.dart';
import '../../widgets/design_system/priority_slider.dart';
import '../../widgets/design_system/assign_dialog.dart';
import '../../widgets/design_system/escalation_dialog.dart';
import '../../widgets/design_system/split_dialog.dart';

/// Unified Case Detail screen for OPERATOR role.
///
/// Shows case information with operator actions:
/// - merge, split, priority, assign SLA, escalate
/// - timeline + AI assessment
///
/// Uses getVerifikatorCase (returns CaseDetail) and typed Report fields.
class CaseActionScreen extends ConsumerStatefulWidget {
  final String caseId;
  const CaseActionScreen({super.key, required this.caseId});

  @override
  ConsumerState<CaseActionScreen> createState() => _CaseActionScreenState();
}

class _CaseActionScreenState extends ConsumerState<CaseActionScreen> {
  CaseDetail? _caseDetail;
  Map<String, dynamic>? _assessmentData;
  bool _loading = true;
  String? _error;
  bool _assessmentError = false;

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
      final caseDetail = await client.getVerifikatorCase(
        caseId: widget.caseId,
        activeRole: activeRole,
      );

      // Fetch AI assessment if available
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
      } catch (_) {
        assessmentError = true;
        assessmentData = null;
      }

      setState(() {
        _caseDetail = caseDetail;
        _assessmentData = assessmentData;
        _assessmentError = assessmentError;
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
      appBar: AppBar(title: const Text(Strings.detailKasusOperator)),
      body: _loading
          ? const OperatorCaseDetailSkeleton()
          : _error != null
          ? Center(
              child: ErrorRetryView(
                message: 'Gagal memuat data',
                onRetry: _loadData,
              ),
            )
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    final caseDetail = _caseDetail!;
    final report = caseDetail.report;
    final photos = report?.photos ?? [];
    final description = report?.description ?? '';
    final title = report?.title ?? '';
    final status = report?.status?.value ?? '';
    final categoryName = report?.category;
    final priority = report?.priority;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(SigapSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card with borderTopColor for status
              SigapCard(
                borderTopColor: _statusBorderColor(status),
                padding: const EdgeInsets.all(SigapSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: SigapTypography.size18,
                        fontWeight: FontWeight.bold,
                        color: SigapColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: SigapSpacing.sm),
                    Wrap(
                      spacing: SigapSpacing.sm,
                      runSpacing: SigapSpacing.sm,
                      children: [
                        StatusPill(
                          label: _statusLabel(status),
                          tone: _statusTone(status),
                        ),
                        if (categoryName != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: SigapSpacing.sm,
                              vertical: SigapSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: SigapColors.primaryLight,
                              borderRadius: BorderRadius.circular(
                                SigapRadius.sm,
                              ),
                            ),
                            child: Text(
                              categoryName,
                              style: const TextStyle(
                                color: SigapColors.primaryDark,
                                fontSize: SigapTypography.size12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        if (priority != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: SigapSpacing.sm,
                              vertical: SigapSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: SigapColors.warningBg,
                              borderRadius: BorderRadius.circular(
                                SigapRadius.sm,
                              ),
                            ),
                            child: Text(
                              'Prioritas: ${priority.value}',
                              style: TextStyle(
                                color: SigapColors.warningText,
                                fontSize: SigapTypography.size12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: SigapSpacing.lg),

              // Photos
              if (photos.isNotEmpty) ...[
                Text(
                  'Foto',
                  style: TextStyle(
                    fontSize: SigapTypography.size15,
                    fontWeight: FontWeight.bold,
                    color: SigapColors.textPrimary,
                  ),
                ),
                const SizedBox(height: SigapSpacing.sm),
                SizedBox(
                  height: 100,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: photos.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(width: SigapSpacing.sm),
                    itemBuilder: (context, index) {
                      final photo = photos[index];
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(SigapRadius.md),
                        child: Image.network(
                          photo,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 100,
                            height: 100,
                            color: SigapColors.border,
                            child: const Icon(Icons.broken_image),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: SigapSpacing.lg),
              ],

              // Description
              Text(
                'Deskripsi',
                style: TextStyle(
                  fontSize: SigapTypography.size15,
                  fontWeight: FontWeight.bold,
                  color: SigapColors.textPrimary,
                ),
              ),
              const SizedBox(height: SigapSpacing.sm),
              SigapCard(
                padding: const EdgeInsets.all(SigapSpacing.md),
                child: Text(
                  description,
                  style: TextStyle(
                    fontSize: SigapTypography.size14,
                    color: SigapColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: SigapSpacing.lg),

              // AI Assessment
              if (_assessmentData != null) ...[
                Text(
                  'Penilaian AI',
                  style: TextStyle(
                    fontSize: SigapTypography.size15,
                    fontWeight: FontWeight.bold,
                    color: SigapColors.textPrimary,
                  ),
                ),
                const SizedBox(height: SigapSpacing.sm),
                AiAssessmentCard(assessment: _assessmentData!),
                const SizedBox(height: SigapSpacing.lg),
              ] else if (_assessmentError) ...[
                Text(
                  'Penilaian AI',
                  style: TextStyle(
                    fontSize: SigapTypography.size15,
                    fontWeight: FontWeight.bold,
                    color: SigapColors.textPrimary,
                  ),
                ),
                const SizedBox(height: SigapSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SigapSpacing.md,
                    vertical: SigapSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: SigapColors.dangerBg,
                    borderRadius: BorderRadius.circular(SigapRadius.sm),
                    border: Border.all(color: SigapColors.dangerBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 16,
                        color: SigapColors.danger,
                      ),
                      const SizedBox(width: SigapSpacing.sm),
                      Text(
                        'Assessment tidak tersedia',
                        style: TextStyle(
                          color: SigapColors.dangerTextStrong,
                          fontSize: SigapTypography.size13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: SigapSpacing.lg),
              ],

              // Action Buttons section header
              Text(
                'Tindakan Operator',
                style: TextStyle(
                  fontSize: SigapTypography.size15,
                  fontWeight: FontWeight.bold,
                  color: SigapColors.textPrimary,
                ),
              ),
              const SizedBox(height: SigapSpacing.md),
              _ActionGrid(onAction: _onAction),
              // Bottom padding to account for StickyActionBar
              const SizedBox(height: 100),
            ],
          ),
        ),
        // Sticky action bar at bottom
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: StickyActionBar(
            label: 'Aksi kasus:',
            actions: [
              SigapOutlineButton(
                label: 'Merge',
                icon: Icons.merge,
                onPressed: () => _onAction('merge'),
              ),
              SigapOutlineButton(
                label: 'Split',
                icon: Icons.call_split,
                onPressed: () => _onAction('split'),
              ),
              SigapActionButton(
                label: 'Prioritas',
                icon: Icons.trending_up,
                onPressed: () => _onAction('priority'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _onAction(String action) {
    switch (action) {
      case 'merge':
        _showMergeDialog(context);
        break;
      case 'split':
        _showSplitDialog(context);
        break;
      case 'priority':
        _showPriorityDialog(context);
        break;
      case 'assign':
        _showAssignDialog(context);
        break;
      case 'escalate':
        _showEscalationDialog(context);
        break;
    }
  }

  void _showMergeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => OperatorMergeDialog(caseId: widget.caseId),
    );
  }

  void _showSplitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => OperatorSplitDialog(caseId: widget.caseId),
    );
  }

  void _showPriorityDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => OperatorPriorityDialog(caseId: widget.caseId),
    );
  }

  void _showAssignDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => OperatorAssignDialog(caseId: widget.caseId),
    );
  }

  void _showEscalationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => OperatorEscalationDialog(caseId: widget.caseId),
    );
  }

  StatusTone _statusTone(String status) {
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

  Color _statusBorderColor(String status) {
    switch (status.toLowerCase()) {
      case 'submitted':
      case 'rejected':
        return SigapColors.danger;
      case 'under_review':
      case 'in_progress':
        return SigapColors.warning;
      case 'verified':
      case 'resolved':
        return SigapColors.success;
      default:
        return SigapColors.textMuted;
    }
  }

  String _statusLabel(String status) {
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

class _ActionGrid extends StatelessWidget {
  final void Function(String action) onAction;
  const _ActionGrid({required this.onAction});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: SigapSpacing.sm,
      runSpacing: SigapSpacing.sm,
      children: [
        _ActionChip(
          icon: Icons.merge,
          label: 'Merge',
          color: SigapColors.offlineDot,
          onTap: () => onAction('merge'),
        ),
        _ActionChip(
          icon: Icons.call_split,
          label: 'Split',
          color: SigapColors.diproses,
          onTap: () => onAction('split'),
        ),
        _ActionChip(
          icon: Icons.trending_up,
          label: 'Prioritas',
          color: SigapColors.offlineDot,
          onTap: () => onAction('priority'),
        ),
        _ActionChip(
          icon: Icons.assignment_ind,
          label: 'Assign SLA',
          color: SigapColors.diproses,
          onTap: () => onAction('assign'),
        ),
        _ActionChip(
          icon: Icons.arrow_upward,
          label: 'Escalate',
          color: SigapColors.danger,
          onTap: () => onAction('escalate'),
        ),
      ],
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(SigapRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SigapRadius.md),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: SigapSpacing.md,
            vertical: SigapSpacing.sm,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: color.withValues(alpha: 0.25)),
            borderRadius: BorderRadius.circular(SigapRadius.md),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: SigapTypography.size13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../api/types.g.dart';
import '../../../l10n/strings.dart';
import '../../../providers/providers.dart';
import '../../../theme/tokens.dart';
import '../../../widgets/ai_assessment_card.dart';
import '../../../widgets/skeleton_loaders.dart';
import 'widgets/merge_dialog.dart';
import 'widgets/priority_slider.dart';
import 'widgets/assign_dialog.dart';
import 'widgets/escalation_dialog.dart';
import 'widgets/split_dialog.dart';

/// Unified Case Detail screen for OPERATOR role.
///
/// Shows case information with operator actions:
/// - merge, split, priority, assign SLA, escalate
/// - timeline + AI assessment
///
/// Uses getVerifikatorCase (returns CaseDetail) and typed Report fields.
class OperatorCaseDetailScreen extends ConsumerStatefulWidget {
  final String caseId;
  const OperatorCaseDetailScreen({super.key, required this.caseId});

  @override
  ConsumerState<OperatorCaseDetailScreen> createState() =>
      _OperatorCaseDetailScreenState();
}

class _OperatorCaseDetailScreenState
    extends ConsumerState<OperatorCaseDetailScreen> {
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
      final caseDetail = await client.getVerifikatorCase(widget.caseId);

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
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text(Strings.detailKasus)),
        body: const OperatorCaseDetailSkeleton(),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text(Strings.detailKasus)),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: SigapColors.perluTindakan,
              ),
              const SizedBox(height: 16),
              Text('Gagal: $_error'),
              ElevatedButton(
                onPressed: _loadData,
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    final caseDetail = _caseDetail!;
    final report = caseDetail.report;
    final photos = report?.photos ?? [];
    final description = report?.description ?? '';
    final title = report?.title ?? '';
    final status = report?.status?.value ?? '';
    final categoryName = report?.category;
    final priority = report?.priority;

    return Scaffold(
      appBar: AppBar(title: const Text(Strings.detailKasusOperator)),
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
                      _StatusChip(status: status),
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
                          categoryName ?? "-",
                          style: const TextStyle(
                            color: SigapColors.primary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      if (priority != null) ...[
                        const SizedBox(width: SigapSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: SigapSpacing.sm,
                            vertical: SigapSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: SigapColors.offlineDot.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(SigapRadius.sm),
                          ),
                          child: Text(
                            'Prioritas: ${priority.value}',
                            style: const TextStyle(
                              color: SigapColors.offlineDot,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: SigapSpacing.lg),

            // Photos
            if (photos.isNotEmpty) ...[
              const Text(
                'Foto',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
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
                        photo.url ?? '',
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
            const Text(
              'Deskripsi',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: SigapSpacing.sm),
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
              const Text(
                'Penilaian AI',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: SigapSpacing.sm),
              AiAssessmentCard(assessment: _assessmentData!),
              const SizedBox(height: SigapSpacing.lg),
            ] else if (_assessmentError) ...[
              const Text(
                'Penilaian AI',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
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
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: SigapSpacing.lg),
            ],

            const SizedBox(height: SigapSpacing.xl),

            // Action Buttons
            const Text(
              'Tindakan Operator',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: SigapSpacing.md),
            Wrap(
              spacing: SigapSpacing.sm,
              runSpacing: SigapSpacing.sm,
              children: [
                _ActionChip(
                  icon: Icons.merge,
                  label: 'Merge',
                  color: SigapColors.offlineDot,
                  onTap: () => _showMergeDialog(context),
                ),
                _ActionChip(
                  icon: Icons.call_split,
                  label: 'Split',
                  color: SigapColors.diproses,
                  onTap: () => _showSplitDialog(context),
                ),
                _ActionChip(
                  icon: Icons.trending_up,
                  label: 'Prioritas',
                  color: SigapColors.offlineDot,
                  onTap: () => _showPriorityDialog(context),
                ),
                _ActionChip(
                  icon: Icons.assignment_ind,
                  label: 'Assign SLA',
                  color: SigapColors.diproses,
                  onTap: () => _showAssignDialog(context),
                ),
                _ActionChip(
                  icon: Icons.arrow_upward,
                  label: 'Escalate',
                  color: SigapColors.perluTindakan,
                  onTap: () => _showEscalationDialog(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  Color get _color {
    switch (status.toLowerCase()) {
      case 'submitted':
        return SigapColors.perluTindakan;
      case 'under_review':
        return SigapColors.offlineDot;
      case 'verified':
        return SigapColors.selesai;
      case 'in_progress':
        return SigapColors.diproses;
      case 'resolved':
        return SigapColors.selesai;
      case 'rejected':
        return SigapColors.perluTindakan;
      default:
        return SigapColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SigapSpacing.sm,
        vertical: SigapSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(SigapRadius.sm),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: _color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
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
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

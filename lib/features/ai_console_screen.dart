import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sigap/l10n/generated/app_localizations.dart';
import 'package:sigap/providers/providers.dart';
import 'package:sigap/theme/tokens.dart';
import 'package:sigap/widgets/design_system/authenticated_shell.dart';
import 'package:sigap/widgets/design_system/sigap_app_bar.dart';

/// AI Console screen for reviewing AI assessment results and triggering re-scans.
///
/// This screen provides access to AI vision assessment functionality for verifikators.
/// It wraps the backend /api/agent/assess endpoint.
class AiConsoleScreen extends ConsumerStatefulWidget {
  const AiConsoleScreen({super.key});

  @override
  ConsumerState<AiConsoleScreen> createState() => _AiConsoleScreenState();
}

class _AiConsoleScreenState extends ConsumerState<AiConsoleScreen> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _assessments = [];

  @override
  void initState() {
    super.initState();
    _loadAssessments();
  }

  Future<void> _loadAssessments() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // Load recent reports and extract assessments
      final client = ref.read(apiClientProvider);
      final reports = await client.getReports(limit: 20);

      final assessments = <Map<String, dynamic>>[];
      for (final report in reports.data) {
        try {
          final detail = await client.getCaseDetail(report.id!);
          if (detail.assessments != null) {
            for (final a in detail.assessments!) {
              assessments.add({
                'report_id': report.id,
                'description': report.description,
                'status': report.status?.value,
                'assessment': a,
              });
            }
          }
        } catch (_) {
          // Skip reports we can't fetch details for
        }
      }

      setState(() {
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final activeRole = ref.watch(authNotifierProvider).activeRole ?? '';
    return AuthenticatedShell(
      activeRole: activeRole,
      useScaffold: true,
      backgroundColor: SigapColors.bgScreen,
      appBar: SigapAppBar(
        title: l10n.aiConsole,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _loadAssessments,
            tooltip: l10n.refresh,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _ErrorView(error: _error!, onRetry: _loadAssessments)
          : _assessments.isEmpty
          ? _EmptyView(onRefresh: _loadAssessments)
          : _AssessmentList(
              assessments: _assessments,
              onRetryAssessment: _retryAssessment,
            ),
    );
  }

  Future<void> _retryAssessment(String reportId) async {
    try {
      final client = ref.read(apiClientProvider);
      await client.triggerAssessment(reportId);
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.aiRescanBerhasil),
            backgroundColor: SigapColors.success,
          ),
        );
        _loadAssessments();
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.aiRescanGagal(e.toString())),
            backgroundColor: SigapColors.perluTindakan,
          ),
        );
      }
    }
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
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
              l10n.gagalMemuatAssessment,
              style: TextStyle(
                fontSize: SigapTypography.bodyLarge,
                fontWeight: FontWeight.bold,
                color: SigapColors.textPrimary,
              ),
            ),
            const SizedBox(height: SigapSpacing.xs),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: SigapTypography.bodySmall,
                color: SigapColors.textSecondary,
              ),
            ),
            const SizedBox(height: SigapSpacing.lg),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(l10n.cobaLagi),
              style: ElevatedButton.styleFrom(
                backgroundColor: SigapColors.primary,
                foregroundColor: SigapColors.surface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final VoidCallback onRefresh;

  const _EmptyView({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SigapSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(SigapSpacing.lg),
              decoration: const BoxDecoration(
                color: SigapColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.psychology_outlined,
                size: 48,
                color: SigapColors.primary,
              ),
            ),
            const SizedBox(height: SigapSpacing.md),
            Text(
              l10n.belumAdaAssessmentAI,
              style: TextStyle(
                fontSize: SigapTypography.bodyLarge,
                fontWeight: FontWeight.bold,
                color: SigapColors.textPrimary,
              ),
            ),
            const SizedBox(height: SigapSpacing.xs),
            Text(
              l10n.assessmentAiMunculNanti,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: SigapTypography.bodyText,
                color: SigapColors.textSecondary,
              ),
            ),
            const SizedBox(height: SigapSpacing.lg),
            OutlinedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.refresh),
            ),
          ],
        ),
      ),
    );
  }
}

class _AssessmentList extends StatelessWidget {
  final List<Map<String, dynamic>> assessments;
  final Future<void> Function(String reportId) onRetryAssessment;

  const _AssessmentList({
    required this.assessments,
    required this.onRetryAssessment,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return RefreshIndicator(
      onRefresh: () async => {},
      color: SigapColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(SigapSpacing.lg),
        itemCount: assessments.length,
        itemBuilder: (context, index) {
          final item = assessments[index];
          final assessment = item['assessment'] as Map<String, dynamic>?;

          return Container(
            margin: const EdgeInsets.only(bottom: SigapSpacing.md),
            decoration: BoxDecoration(
              color: SigapColors.surface,
              borderRadius: BorderRadius.circular(SigapRadius.md),
              border: Border.all(color: SigapColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Report Info
                Container(
                  padding: const EdgeInsets.all(SigapSpacing.md),
                  decoration: BoxDecoration(
                    color: SigapColors.bgSurface,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(SigapRadius.md),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(SigapSpacing.sm),
                        decoration: BoxDecoration(
                          color: SigapColors.primaryLight,
                          borderRadius: BorderRadius.circular(SigapRadius.sm),
                        ),
                        child: const Icon(
                          Icons.psychology,
                          color: SigapColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: SigapSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.reportLabelId(item['report_id'] as String),
                              style: TextStyle(
                                fontSize: SigapTypography.bodyText,
                                fontWeight: FontWeight.w600,
                                color: SigapColors.textPrimary,
                              ),
                            ),
                            Text(
                              item['description'] ?? '-',
                              style: TextStyle(
                                fontSize: SigapTypography.captionMedium,
                                color: SigapColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Assessment Details
                if (assessment != null)
                  Padding(
                    padding: const EdgeInsets.all(SigapSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _AssessmentRow(
                          label: l10n.labelStatus,
                          value: assessment['status']?.toString() ?? '-',
                        ),
                        _AssessmentRow(
                          label: l10n.labelConfidence,
                          value:
                              '${((assessment['confidence'] ?? 0) * 100).toStringAsFixed(1)}%',
                        ),
                        if (assessment['result'] != null)
                          _AssessmentRow(
                            label: l10n.labelResult,
                            value: assessment['result'].toString(),
                          ),
                      ],
                    ),
                  ),

                // Retry Button
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    SigapSpacing.md,
                    0,
                    SigapSpacing.md,
                    SigapSpacing.md,
                  ),
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        onRetryAssessment(item['report_id'] as String),
                    icon: const Icon(Icons.refresh, size: 16),
                    label: Text(l10n.retryScan),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: SigapColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AssessmentRow extends StatelessWidget {
  final String label;
  final String value;

  const _AssessmentRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: SigapSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: SigapTypography.captionMedium,
                color: SigapColors.textMuted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: SigapTypography.captionMedium,
                color: SigapColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

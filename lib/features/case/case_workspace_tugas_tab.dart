import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../api/client.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/providers.dart';
import '../../theme/tokens.dart';
import '../../widgets/design_system/design_system.dart';

/// W-04 Tugas & Progres Tab Content
///
/// Task list tab for case workspace showing:
/// - Task cards with status indicators
/// - Accept/Reject actions
///
/// This content was ported from TaskWorkspace to display case-specific tasks.
class CaseWorkspaceTugasTab extends ConsumerStatefulWidget {
  final String caseId;
  final CaseDetail caseDetail;

  const CaseWorkspaceTugasTab({
    super.key,
    required this.caseId,
    required this.caseDetail,
  });

  @override
  ConsumerState<CaseWorkspaceTugasTab> createState() =>
      _CaseWorkspaceTugasTabState();
}

class _CaseWorkspaceTugasTabState extends ConsumerState<CaseWorkspaceTugasTab> {
  bool _loading = true;
  String? _error;
  List<_CaseTaskItem> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final client = ref.read(apiClientProvider);
      final taskPage = await client.getTasks();

      // Map tasks to internal model
      final tasks = taskPage.tasks
          .map((t) => _CaseTaskItem.fromPetugasTask(t))
          .toList();

      setState(() {
        _tasks = tasks;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _doAction(Future<void> Function() action) async {
    try {
      await action();
      await _loadTasks(); // Refresh list
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        final errorStr = e.toString().toLowerCase();
        if (errorStr.contains('409') || errorStr.contains('conflict')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.tugasDiprosesSurveyorLain),
              backgroundColor: SigapColors.warning,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.gagalDenganError(e.toString()))),
          );
        }
      }
    }
  }

  Future<void> _acceptTask(String taskId) async {
    await _doAction(() async {
      final client = ref.read(apiClientProvider);
      await client.taskAction(taskId, action: 'accept');
    });
  }

  Future<void> _rejectTask(String taskId) async {
    final reasonController = TextEditingController();
    final l10n = AppLocalizations.of(context)!;
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.tolakTugas),
        content: TextField(
          controller: reasonController,
          decoration: InputDecoration(
            labelText: l10n.alasanPenolakan,
            hintText: l10n.masukkanAlasanPenolakan,
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.batal),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, reasonController.text),
            child: Text(l10n.tolak),
          ),
        ],
      ),
    );
    if (reason == null || reason.isEmpty) return;

    final client = ref.read(apiClientProvider);
    await client.taskAction(taskId, action: 'reject', note: reason);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: SigapColors.primary),
      );
    }

    if (_error != null && _tasks.isEmpty) {
      return Center(
        child: ErrorRetryView(
          message: l10n.gagalMemuatTugas,
          onRetry: _loadTasks,
        ),
      );
    }

    if (_tasks.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadTasks,
      color: SigapColors.primary,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(SigapSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Task count header
            Row(
              children: [
                const Icon(
                  Icons.assignment,
                  color: SigapColors.primary,
                  size: 20,
                ),
                const SizedBox(width: SigapSpacing.sm),
                Text(
                  '${_tasks.length} Tugas',
                  style: const TextStyle(
                    fontSize: SigapTypography.subtitle,
                    fontWeight: FontWeight.bold,
                    color: SigapColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: SigapSpacing.md),

            // Task list
            ..._tasks.map(
              (task) => Padding(
                padding: const EdgeInsets.only(bottom: SigapSpacing.md),
                child: _CaseTaskCard(
                  task: task,
                  onAccept:
                      task.status == 'assigned' || task.status == 'pending'
                      ? () => _acceptTask(task.id)
                      : null,
                  onReject:
                      task.status == 'assigned' || task.status == 'pending'
                      ? () => _rejectTask(task.id)
                      : null,
                  onTap: () => context.push('/tasks/${task.id}'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SigapSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: SigapColors.bgSurface,
                shape: BoxShape.circle,
                border: Border.all(color: SigapColors.borderCard, width: 2),
              ),
              child: const Icon(
                Icons.assignment_outlined,
                size: 36,
                color: SigapColors.textTertiary,
              ),
            ),
            const SizedBox(height: SigapSpacing.md),
            const Text(
              'Tidak Ada Tugas',
              style: TextStyle(
                fontSize: SigapTypography.bodyLarge,
                fontWeight: FontWeight.w700,
                color: SigapColors.textPrimary,
              ),
            ),
            const SizedBox(height: SigapSpacing.xs),
            const Text(
              'Tugas penanganan untuk kasus ini akan muncul di sini.',
              style: TextStyle(
                fontSize: SigapTypography.bodyText,
                color: SigapColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: SigapSpacing.lg),
            OutlinedButton.icon(
              onPressed: _loadTasks,
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(l10n.segarkanData),
            ),
          ],
        ),
      ),
    );
  }
}

/// Internal task item model for case-specific tasks.
class _CaseTaskItem {
  final String id;
  final String title;
  final String status;
  final DateTime? assignedAt;
  final DateTime? completedAt;

  _CaseTaskItem({
    required this.id,
    required this.title,
    required this.status,
    this.assignedAt,
    this.completedAt,
  });

  factory _CaseTaskItem.fromPetugasTask(PetugasTask task) {
    DateTime? parseDate(String? s) {
      if (s == null) return null;
      return DateTime.tryParse(s);
    }

    return _CaseTaskItem(
      id: task.taskId ?? '',
      title: task.reportTitle ?? '-',
      status: task.status ?? 'pending',
      assignedAt: parseDate(task.assignedAt),
      completedAt: parseDate(task.completedAt),
    );
  }

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'pending':
        return SigapColors.offlineDot;
      case 'assigned':
        return SigapColors.diproses;
      case 'in_progress':
        return SigapColors.diproses;
      case 'completed':
      case 'resolved':
        return SigapColors.selesai;
      case 'rejected':
        return SigapColors.danger;
      default:
        return SigapColors.textTertiary;
    }
  }

  String get statusLabel {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Baru';
      case 'assigned':
        return 'Ditugaskan';
      case 'in_progress':
        return 'Dikerjakan';
      case 'completed':
      case 'resolved':
        return 'Selesai';
      case 'rejected':
        return 'Ditolak';
      default:
        return status;
    }
  }
}

/// Task card widget for case workspace tugas tab.
class _CaseTaskCard extends StatelessWidget {
  final _CaseTaskItem task;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onTap;

  const _CaseTaskCard({
    required this.task,
    this.onAccept,
    this.onReject,
    this.onTap,
  });

  Color get _priorityColor {
    // Use status color for left border priority indicator
    return task.statusColor;
  }

  String formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: SigapColors.bgCard,
          borderRadius: BorderRadius.circular(SigapRadius.x12),
          border: Border(left: BorderSide(color: _priorityColor, width: 4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Main content
            Padding(
              padding: const EdgeInsets.all(SigapSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row with title and status
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.title,
                              style: const TextStyle(
                                fontSize: SigapTypography.bodyTextWide,
                                fontWeight: FontWeight.w600,
                                color: SigapColors.textPrimary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'TGS-${task.id.length >= 4 ? task.id.substring(0, 4) : task.id}',
                              style: const TextStyle(
                                fontFamily: SigapTypography.fontFamilyMono,
                                fontSize: SigapTypography.captionMedium,
                                color: SigapColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: SigapSpacing.sm),
                      // Status badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: task.statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          task.statusLabel,
                          style: TextStyle(
                            fontSize: SigapTypography.captionMedium,
                            fontWeight: FontWeight.w600,
                            color: task.statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Assigned date
                  if (task.assignedAt != null) ...[
                    const SizedBox(height: SigapSpacing.xs),
                    Text(
                      'Ditugaskan: ${formatDate(task.assignedAt!)}',
                      style: const TextStyle(
                        fontSize: SigapTypography.captionMedium,
                        color: SigapColors.textTertiary,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Action buttons
            if (onAccept != null || onReject != null) ...[
              const Divider(height: 1, color: SigapColors.border),
              Padding(
                padding: const EdgeInsets.all(SigapSpacing.sm),
                child: Row(
                  children: [
                    if (onReject != null)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onReject,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: SigapColors.danger,
                            side: const BorderSide(color: SigapColors.danger),
                          ),
                          child: Text(
                            l10n.tolak,
                            style: const TextStyle(
                              fontSize: SigapTypography.bodySmall,
                            ),
                          ),
                        ),
                      ),
                    if (onReject != null && onAccept != null)
                      const SizedBox(width: SigapSpacing.sm),
                    if (onAccept != null)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onAccept,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: SigapColors.primary,
                            foregroundColor: SigapColors.surface,
                          ),
                          child: Text(
                            l10n.terima,
                            style: const TextStyle(
                              fontSize: SigapTypography.bodySmall,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

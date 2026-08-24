import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../api/exceptions.dart';
import '../../providers/providers.dart';
import '../../theme/tokens.dart';
import '../../utils/logger.dart';

final _logger = Logger('PetugasDashboard');

class PetugasTask {
  final String id;
  final String reportId;
  final String status;
  final String? instructions;
  final String? deadline;

  PetugasTask({
    required this.id,
    required this.reportId,
    required this.status,
    this.instructions,
    this.deadline,
  });

  factory PetugasTask.fromJson(Map<String, dynamic> json) {
    // Show dash for empty/null ids - no silent defaults
    final id = json['id'] as String?;
    final reportId = json['report_id'] as String?;
    final status = json['status'] as String?;
    return PetugasTask(
      id: (id != null && id.isNotEmpty) ? id : '-',
      reportId: (reportId != null && reportId.isNotEmpty) ? reportId : '-',
      // Status: show raw slug or dash - no magic 'pending' default
      status: (status != null && status.isNotEmpty) ? status : '-',
      instructions: json['instructions'] as String?,
      deadline: json['deadline'] as String?,
    );
  }
}

final petugasTasksProvider = FutureProvider<List<PetugasTask>>((ref) async {
  final api = ref.watch(apiClientProvider);
  final page = await api.petugasGetTasks();
  // Use typed page.tasks directly - already List<PetugasTask> from generated type
  return page.tasks
      .map(
        (t) => PetugasTask.fromJson({
          'id': t.id,
          'report_id': t.reportId,
          'status': t.status,
          'instructions': t.instructions,
          'deadline': t.deadline?.toIso8601String(),
        }),
      )
      .toList();
});

class PetugasDashboardScreen extends ConsumerStatefulWidget {
  const PetugasDashboardScreen({super.key});

  @override
  ConsumerState<PetugasDashboardScreen> createState() =>
      _PetugasDashboardScreenState();
}

class _PetugasDashboardScreenState
    extends ConsumerState<PetugasDashboardScreen> {
  final Map<String, int> _progressValues = {};
  final Map<String, String> _findingsValues = {};
  final Set<String> _updatingTasks = {};

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(petugasTasksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tugas Petugas'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: tasksAsync.when(
        data: (tasks) => tasks.isEmpty
            ? const Center(child: Text('Belum ada tugas'))
            : ListView.builder(
                padding: const EdgeInsets.all(SigapSpacing.lg),
                itemCount: tasks.length,
                itemBuilder: (context, index) => _TaskCard(
                  task: tasks[index],
                  progress: _progressValues[tasks[index].id] ?? 0,
                  findings: _findingsValues[tasks[index].id] ?? '',
                  isUpdating: _updatingTasks.contains(tasks[index].id),
                  onProgressChanged: (value) {
                    setState(() {
                      _progressValues[tasks[index].id] = value;
                    });
                  },
                  onFindingsChanged: (value) {
                    setState(() {
                      _findingsValues[tasks[index].id] = value;
                    });
                  },
                  onSubmit: () => _handleUpdateProgress(tasks[index]),
                ),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Future<void> _handleUpdateProgress(PetugasTask task) async {
    final progress = _progressValues[task.id] ?? 0;
    final findings = _findingsValues[task.id] ?? '';

    if (progress == 0 && findings.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan progress atau temuan terlebih dahulu'),
        ),
      );
      return;
    }

    setState(() {
      _updatingTasks.add(task.id);
    });

    try {
      final api = ref.read(apiClientProvider);
      await api.petugasUpdateProgress(
        taskId: task.id,
        progressPercent: progress,
        notes: findings.isNotEmpty ? findings : null,
      );

      // Refresh tasks after update
      ref.invalidate(petugasTasksProvider);

      // Clear inputs
      setState(() {
        _progressValues[task.id] = 0;
        _findingsValues[task.id] = '';
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui: ${extractErrorMessage(e)}'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _updatingTasks.remove(task.id);
        });
      }
    }
  }
}

class _TaskCard extends StatelessWidget {
  final PetugasTask task;
  final int progress;
  final String findings;
  final bool isUpdating;
  final ValueChanged<int> onProgressChanged;
  final ValueChanged<String> onFindingsChanged;
  final VoidCallback onSubmit;

  const _TaskCard({
    required this.task,
    required this.progress,
    required this.findings,
    required this.isUpdating,
    required this.onProgressChanged,
    required this.onFindingsChanged,
    required this.onSubmit,
  });

  Color _statusColor() {
    switch (task.status) {
      case 'completed':
        return SigapColors.selesai;
      case 'in_progress':
        return SigapColors.diproses;
      default:
        return SigapColors.perluTindakan;
    }
  }

  String _statusLabel() {
    switch (task.status) {
      case 'completed':
        return 'Selesai';
      case 'in_progress':
        return 'Dikerjakan';
      default:
        return 'Baru';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: SigapSpacing.lg),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SigapRadius.md),
        side: const BorderSide(color: SigapColors.border),
      ),
      child: InkWell(
        onTap: () => context.push('/petugas/task/${task.id}'),
        borderRadius: BorderRadius.circular(SigapRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(SigapSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Task ${task.id.substring(0, 8)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: SigapSpacing.xs),
                        Text(
                          'ID Laporan: ${task.reportId.substring(0, 8)}',
                          style: TextStyle(
                            color: SigapColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                        if (task.instructions != null) ...[
                          const SizedBox(height: SigapSpacing.sm),
                          Text(
                            task.instructions!,
                            style: TextStyle(
                              color: SigapColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                        if (task.deadline != null) ...[
                          const SizedBox(height: SigapSpacing.sm),
                          Text(
                            'Deadline: ${_formatDate(task.deadline!)}',
                            style: TextStyle(
                              color: SigapColors.perluTindakan,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SigapSpacing.sm,
                      vertical: SigapSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: _statusColor().withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(SigapRadius.sm),
                    ),
                    child: Text(
                      _statusLabel(),
                      style: TextStyle(
                        color: _statusColor(),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SigapSpacing.lg),
              Text(
                'Progress (0-100%)',
                style: TextStyle(
                  color: SigapColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: SigapSpacing.xs),
              Slider(
                value: progress.toDouble(),
                min: 0,
                max: 100,
                divisions: 10,
                activeColor: SigapColors.primary,
                onChanged: (value) => onProgressChanged(value.round()),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '$progress%',
                  style: TextStyle(color: SigapColors.textMuted, fontSize: 12),
                ),
              ),
              const SizedBox(height: SigapSpacing.md),
              Text(
                'Temuan / Catatan',
                style: TextStyle(
                  color: SigapColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: SigapSpacing.xs),
              TextField(
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Masukkan temuan...',
                  hintStyle: TextStyle(color: SigapColors.textMuted),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(SigapRadius.sm),
                    borderSide: const BorderSide(color: SigapColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(SigapRadius.sm),
                    borderSide: const BorderSide(color: SigapColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(SigapRadius.sm),
                    borderSide: const BorderSide(color: SigapColors.primary),
                  ),
                  contentPadding: const EdgeInsets.all(SigapSpacing.md),
                ),
                onChanged: onFindingsChanged,
                controller: TextEditingController(text: findings)
                  ..selection = TextSelection.fromPosition(
                    TextPosition(offset: findings.length),
                  ),
              ),
              const SizedBox(height: SigapSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isUpdating ? null : onSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SigapColors.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(
                      vertical: SigapSpacing.md,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(SigapRadius.sm),
                    ),
                  ),
                  child: isUpdating
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        )
                      : const Text('Update Progress'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (e, s) {
      _logger.warning('Error parsing date "$dateStr"', e, s);
      return dateStr;
    }
  }
}

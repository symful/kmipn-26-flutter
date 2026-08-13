import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/providers.dart';
import '../../../theme/tokens.dart';
import '../../../utils/logger.dart';

class SurveyorTaskListScreen extends ConsumerStatefulWidget {
  const SurveyorTaskListScreen({super.key});

  @override
  ConsumerState<SurveyorTaskListScreen> createState() =>
      _SurveyorTaskListScreenState();
}

class _SurveyorTaskListScreenState
    extends ConsumerState<SurveyorTaskListScreen> {
  static final _logger = Logger('SurveyorTaskListScreen');
  List<Map<String, dynamic>> _tasks = [];
  Set<String> _downloadedIds = {};
  bool _loading = true;
  String? _error;
  bool _isOfflineMode = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final taskRepo = ref.read(surveyorTaskRepositoryProvider);

    try {
      final client = ref.read(apiClientProvider);
      final tasks = await client.surveyorGetTasks();

      // Update downloaded IDs from local DB
      final downloadedTasks = await taskRepo.getDownloadedTasks();
      final downloadedIds = downloadedTasks.map((t) => t.taskId).toSet();

      setState(() {
        _tasks = tasks;
        _downloadedIds = downloadedIds;
        _isOfflineMode = false;
        _loading = false;
      });
    } catch (e) {
      // Fall back to offline mode
      try {
        final downloadedTasks = await taskRepo.getDownloadedTasks();
        final offlineTasks = downloadedTasks.map((t) {
          return {
            'id': t.taskId,
            'title': t.title,
            'description': t.description,
            'instructions': t.instructions,
            'status': t.status,
            'checklist_template': jsonDecode(t.checklistTemplateJson),
          };
        }).toList();

        setState(() {
          _tasks = offlineTasks;
          _isOfflineMode = true;
          _loading = false;
          _error = 'Offline mode - data dari unduhan lokal';
        });
      } catch (e, s) {
        _logger.warning('Error loading offline tasks', e, s);
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  Future<void> _toggleDownload(Map<String, dynamic> task) async {
    final taskId = task['id'] as String;
    final taskRepo = ref.read(surveyorTaskRepositoryProvider);

    if (_downloadedIds.contains(taskId)) {
      // Remove from offline storage
      await taskRepo.removeDownloadedTask(taskId);
      setState(() {
        _downloadedIds.remove(taskId);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hapus unduhan offline'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      // Download and store locally
      try {
        final client = ref.read(apiClientProvider);
        final detail = await client.surveyorGetTaskDetail(taskId);
        final checklistTemplate =
            (detail['checklist_template'] as List?) ??
            (detail['checklist'] as List?) ??
            [];

        await taskRepo.saveDownloadedTask(
          taskId: taskId,
          title: detail['title'] as String? ?? task['title'] as String? ?? '-',
          description: detail['description'] as String?,
          instructions: detail['instructions'] as String?,
          status:
              detail['status'] as String? ??
              task['status'] as String? ??
              'pending',
          checklistTemplate: checklistTemplate.cast<Map<String, dynamic>>(),
        );

        setState(() {
          _downloadedIds.add(taskId);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tugas di-download untuk offline'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal download: $e'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tugas Survei'),
        automaticallyImplyLeading: false,
        actions: [
          if (_isOfflineMode)
            Container(
              margin: const EdgeInsets.only(right: SigapSpacing.md),
              padding: const EdgeInsets.symmetric(
                horizontal: SigapSpacing.sm,
                vertical: SigapSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: SigapColors.offlineBg,
                borderRadius: BorderRadius.circular(SigapRadius.sm),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.cloud_off,
                    size: 14,
                    color: SigapColors.offlineText,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'OFFLINE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: SigapColors.offlineText,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null && _tasks.isEmpty
          ? _ErrorRetry(error: _error!, onRetry: _load)
          : _tasks.isEmpty
          ? const Center(child: Text('Tidak ada tugas survei'))
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                padding: const EdgeInsets.all(SigapSpacing.lg),
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  final task = _tasks[index];
                  return _SurveyorTaskCard(
                    task: task,
                    isDownloaded: _downloadedIds.contains(task['id']),
                    onTap: () => context.push('/surveyor/tasks/${task['id']}'),
                    onDownloadToggle: () => _toggleDownload(task),
                  );
                },
              ),
            ),
    );
  }
}

class _SurveyorTaskCard extends StatelessWidget {
  final Map<String, dynamic> task;
  final bool isDownloaded;
  final VoidCallback onTap;
  final VoidCallback onDownloadToggle;

  const _SurveyorTaskCard({
    required this.task,
    required this.isDownloaded,
    required this.onTap,
    required this.onDownloadToggle,
  });

  String get _statusLabel {
    switch ((task['status'] ?? '').toString().toLowerCase()) {
      case 'pending':
        return 'Menunggu';
      case 'assigned':
        return 'Ditugaskan';
      case 'in_progress':
        return 'Diproses';
      case 'completed':
        return 'Selesai';
      default:
        return task['status']?.toString() ?? '-';
    }
  }

  Color get _statusColor {
    switch ((task['status'] ?? '').toString().toLowerCase()) {
      case 'pending':
        return SigapColors.offlineDot;
      case 'assigned':
        return SigapColors.diproses;
      case 'in_progress':
        return SigapColors.primary;
      case 'completed':
        return SigapColors.selesai;
      default:
        return SigapColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = task['title'] as String? ?? '-';
    final desc =
        task['description'] as String? ??
        task['instructions'] as String? ??
        '-';

    return Card(
      margin: const EdgeInsets.only(bottom: SigapSpacing.md),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SigapRadius.md),
        side: const BorderSide(color: SigapColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SigapRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(SigapSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      isDownloaded
                          ? Icons.download_done
                          : Icons.download_for_offline_outlined,
                      color: isDownloaded
                          ? SigapColors.selesai
                          : SigapColors.textMuted,
                    ),
                    onPressed: onDownloadToggle,
                    tooltip: isDownloaded
                        ? 'Hapus offline'
                        : 'Download offline',
                  ),
                ],
              ),
              const SizedBox(height: SigapSpacing.xs),
              Text(
                desc.toString().length > 100
                    ? '${desc.toString().substring(0, 100)}...'
                    : desc.toString(),
                style: const TextStyle(
                  fontSize: 13,
                  color: SigapColors.textSecondary,
                ),
              ),
              const SizedBox(height: SigapSpacing.sm),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SigapSpacing.sm,
                      vertical: SigapSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: _statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(SigapRadius.sm),
                    ),
                    child: Text(
                      _statusLabel,
                      style: TextStyle(
                        color: _statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  TextButton(onPressed: onTap, child: const Text('Buka')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorRetry({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 64, color: SigapColors.perluTindakan),
          const SizedBox(height: 16),
          Text('Gagal memuat: $error'),
          ElevatedButton(onPressed: onRetry, child: const Text('Coba Lagi')),
        ],
      ),
    );
  }
}

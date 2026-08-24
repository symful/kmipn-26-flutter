import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../api/api_client.dart';
import '../../api/types.g.dart';
import '../../providers/providers.dart';
import '../../theme/tokens.dart';
import '../../widgets/design_system/bottom_nav_5.dart';
import '../../widgets/design_system/phone_frame.dart';
import '../../widgets/design_system/status_bar.dart';
import '../surveyor/presentation/widgets/task_filter_chips.dart';
import '../surveyor/presentation/widgets/connectivity_indicator.dart';

/// Unified TasksFlow List Screen for both SURVEYOR and PETUGAS roles.
///
/// Role determines:
/// - Which task provider to use (surveyorTasksProvider vs petugasTasksProvider)
/// - Which columns to display (SLA/priority for surveyor, progress/unit for petugas)
/// - Which navigation path to use for task detail
///
/// Uses F1-migrated API methods from api_client:
/// - surveyorGetTasks() / petugasGetTasks() → GET /api/tasks?role={role}
/// - getTaskDetail(taskId) → GET /api/tasks/:id
///
/// Navigation: pushes to TasksFlowDetailScreen with role and taskId.
class TasksFlowListScreen extends ConsumerStatefulWidget {
  /// 'surveyor' or 'petugas'
  final String role;

  const TasksFlowListScreen({super.key, required this.role});

  @override
  ConsumerState<TasksFlowListScreen> createState() =>
      _TasksFlowListScreenState();
}

class _TasksFlowListScreenState extends ConsumerState<TasksFlowListScreen> {
  bool _loading = true;
  String? _error;
  int? _filterIndex;
  String _sortValue = 'Terbaru';
  int _selectedNavIndex = 0;

  List<_TaskItem> _tasks = [];

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

    try {
      final client = ref.read(apiClientProvider);
      final TaskListPage page;

      if (widget.role == 'surveyor') {
        page = await client.surveyorGetTasks();
      } else {
        page = await client.petugasGetTasks();
      }

      final taskItems = page.tasks
          .map((t) => _TaskItem.fromTask(t, widget.role))
          .toList();

      setState(() {
        _tasks = taskItems;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  List<_TaskItem> _applyFilter(List<_TaskItem> tasks, int? filterIndex) {
    if (filterIndex == null) return tasks;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (filterIndex) {
      case 0: // Hari ini
        return tasks.where((t) {
          if (t.createdAt == null) return false;
          return t.createdAt!.year == today.year &&
              t.createdAt!.month == today.month &&
              t.createdAt!.day == today.day;
        }).toList();
      case 1: // Terlambat
        return tasks.where((t) {
          if (t.deadline == null) return false;
          return t.deadline!.isBefore(now);
        }).toList();
      default:
        return tasks;
    }
  }

  List<_TaskItem> _applySort(List<_TaskItem> tasks, String sortValue) {
    final sorted = List<_TaskItem>.from(tasks);
    switch (sortValue) {
      case 'Terbaru':
        sorted.sort((a, b) {
          if (a.createdAt == null && b.createdAt == null) return 0;
          if (a.createdAt == null) return 1;
          if (b.createdAt == null) return -1;
          return b.createdAt!.compareTo(a.createdAt!);
        });
      case 'Paling mendesak':
        sorted.sort((a, b) {
          if (a.deadline == null && b.deadline == null) return 0;
          if (a.deadline == null) return 1;
          if (b.deadline == null) return -1;
          return a.deadline!
              .difference(now)
              .compareTo(b.deadline!.difference(now));
        });
    }
    return sorted;
  }

  DateTime get now => DateTime.now();

  @override
  Widget build(BuildContext context) {
    final filteredTasks = _applySort(
      _applyFilter(_tasks, _filterIndex),
      _sortValue,
    );
    final taskCount = filteredTasks.length;

    // Calculate filter counts
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayCount = _tasks.where((t) {
      if (t.createdAt == null) return false;
      return t.createdAt!.year == today.year &&
          t.createdAt!.month == today.month &&
          t.createdAt!.day == today.day;
    }).length;
    final overdueCount = _tasks.where((t) {
      if (t.deadline == null) return false;
      return t.deadline!.isBefore(now);
    }).length;

    final isSurveyor = widget.role == 'surveyor';

    return PhoneFrame(
      child: Column(
        children: [
          StatusBar(),
          Expanded(
            child: Scaffold(
              backgroundColor: SigapColors.bgSurface,
              appBar: AppBar(
                backgroundColor: SigapColors.bgCard,
                elevation: 0,
                automaticallyImplyLeading: false,
                toolbarHeight: 60,
                titleSpacing: 0,
                title: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SigapSpacing.lg,
                  ),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isSurveyor ? 'Tugas Survei' : 'Tugas Petugas',
                            style: const TextStyle(
                              fontSize: SigapTypography.size19,
                              fontWeight: FontWeight.w700,
                              color: SigapColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$taskCount tugas',
                            style: const TextStyle(
                              fontFamily: 'IBM Plex Mono',
                              fontSize: SigapTypography.size12,
                              color: SigapColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const ConnectivityIndicator(
                        status: ConnectivityStatus.online,
                      ),
                    ],
                  ),
                ),
              ),
              body: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: SigapColors.primary,
                      ),
                    )
                  : _error != null && _tasks.isEmpty
                  ? _ErrorRetry(error: _error!, onRetry: _load)
                  : _tasks.isEmpty
                  ? Center(
                      child: Text(
                        isSurveyor
                            ? 'Tidak ada tugas survei'
                            : 'Belum ada tugas',
                        style: const TextStyle(
                          color: SigapColors.textSecondary,
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        // Filter chips
                        TaskFilterChips(
                          selectedIndex: _filterIndex,
                          onChipSelected: (index) {
                            setState(() {
                              _filterIndex = index;
                            });
                          },
                          todayCount: todayCount,
                          overdueCount: overdueCount,
                          notDownloadedCount: 0,
                        ),
                        // Sort row
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: SigapSpacing.lg,
                            vertical: SigapSpacing.sm,
                          ),
                          child: Row(
                            children: [
                              Text(
                                'Urutkan: ',
                                style: TextStyle(
                                  fontSize: SigapTypography.size12,
                                  color: SigapColors.textTertiary,
                                ),
                              ),
                              DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _sortValue,
                                  items: ['Terbaru', 'Paling mendesak'].map((
                                    option,
                                  ) {
                                    return DropdownMenuItem<String>(
                                      value: option,
                                      child: Text(
                                        option,
                                        style: const TextStyle(
                                          fontSize: SigapTypography.size12,
                                          fontWeight: FontWeight.w700,
                                          color: SigapColors.textPrimary,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        _sortValue = value;
                                      });
                                    }
                                  },
                                ),
                              ),
                              const Spacer(),
                            ],
                          ),
                        ),
                        // Task list
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: _load,
                            color: SigapColors.primary,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(SigapSpacing.lg),
                              itemCount: filteredTasks.length,
                              itemBuilder: (context, index) {
                                final task = filteredTasks[index];
                                return Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: SigapSpacing.md,
                                  ),
                                  child: _TasksFlowCard(
                                    task: task,
                                    role: widget.role,
                                    onTap: () {
                                      context.push(
                                        '/${widget.role}/tasks/${task.id}',
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
              bottomNavigationBar: isSurveyor
                  ? BottomNav5(
                      variant: BottomNavVariant.surveyor,
                      selectedIndex: _selectedNavIndex,
                      onTap: (index) {
                        setState(() {
                          _selectedNavIndex = index;
                        });
                        if (index == 1) {
                          context.go('/surveyor/map');
                        } else if (index == 4) {
                          context.go('/profile');
                        }
                      },
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

/// Internal task item model used by the list screen.
/// Avoids raw Map by using typed fields.
class _TaskItem {
  final String id;
  final String title;
  final String? description;
  final String status;
  final DateTime? createdAt;
  final DateTime? deadline;
  final String? categoryName;
  final String? address;
  final int? progressPercent;
  final int? severity;

  _TaskItem({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    this.createdAt,
    this.deadline,
    this.categoryName,
    this.address,
    this.progressPercent,
    this.severity,
  });

  factory _TaskItem.fromTask(dynamic t, String role) {
    // Parse ISO date string to DateTime
    DateTime? parseDate(String? s) {
      if (s == null) return null;
      return DateTime.tryParse(s);
    }

    if (role == 'surveyor') {
      final task = t as SurveyorTask;
      return _TaskItem(
        id: task.taskId ?? '',
        title: task.reportTitle ?? '-',
        description: null,
        status: task.status ?? 'pending',
        createdAt: parseDate(task.assignedAt),
        deadline: null, // SurveyorTask has no deadline field
        categoryName: null,
        address: null,
        progressPercent: null,
        severity: null,
      );
    } else {
      final task = t as PetugasTask;
      return _TaskItem(
        id: task.taskId ?? '',
        title: task.reportTitle ?? '-',
        description: null,
        status: task.status ?? 'pending',
        createdAt: parseDate(task.assignedAt),
        deadline: null, // PetugasTask has no deadline field
        categoryName: null,
        address: null,
        progressPercent: null,
        severity: null,
      );
    }
  }
}

class _TasksFlowCard extends StatelessWidget {
  final _TaskItem task;
  final String role;
  final VoidCallback onTap;

  const _TasksFlowCard({
    required this.task,
    required this.role,
    required this.onTap,
  });

  Color get _statusColor {
    switch (task.status.toLowerCase()) {
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

  String get _statusLabel {
    switch (task.status.toLowerCase()) {
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
        return task.status;
    }
  }

  Color get _priorityColor {
    if (task.deadline != null) {
      final now = DateTime.now();
      final hours = task.deadline!.difference(now).inHours;
      if (hours < 0) return SigapColors.danger;
      if (hours < 24) return SigapColors.warning;
    }
    return SigapColors.primary;
  }

  String get _slaLabel {
    if (task.deadline == null) return '';
    final now = DateTime.now();
    final hours = task.deadline!.difference(now).inHours;
    if (hours < 0) {
      final overdueHours = hours.abs();
      return 'Terlambat ${overdueHours}h';
    } else if (hours < 24) {
      return 'SLA ${hours}j';
    } else {
      final days = (hours / 24).ceil();
      return 'SLA ${days}d';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSurveyor = role == 'surveyor';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: SigapColors.bgCard,
          borderRadius: BorderRadius.circular(SigapRadius.x12),
          border: Border(left: BorderSide(color: _priorityColor, width: 4)),
        ),
        padding: const EdgeInsets.all(SigapSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: const TextStyle(
                          fontSize: SigapTypography.size13_5,
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
                          fontFamily: 'IBM Plex Mono',
                          fontSize: SigapTypography.size11,
                          color: SigapColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _statusLabel,
                    style: TextStyle(
                      fontSize: SigapTypography.size11,
                      fontWeight: FontWeight.w600,
                      color: _statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Location / Description
            if (task.address != null &&
                task.address!.isNotEmpty &&
                task.address != '-')
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  task.address!,
                  style: const TextStyle(
                    fontSize: SigapTypography.size11_5,
                    color: SigapColors.textTertiary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

            // Bottom row: SLA badge + progress (petugas) or category (surveyor)
            Row(
              children: [
                if (task.deadline != null && _slaLabel.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _slaLabel.startsWith('Terlambat')
                          ? const Color(0xFFF8E2DE)
                          : const Color(0xFFF8ECD6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _slaLabel,
                      style: TextStyle(
                        fontSize: SigapTypography.size10,
                        fontWeight: FontWeight.w700,
                        color: _slaLabel.startsWith('Terlambat')
                            ? const Color(0xFFA5271A)
                            : const Color(0xFF8A5808),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (isSurveyor && task.categoryName != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: SigapColors.primaryLight,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      task.categoryName!.toUpperCase(),
                      style: const TextStyle(
                        fontSize: SigapTypography.size10,
                        fontWeight: FontWeight.w600,
                        color: SigapColors.primaryDark,
                      ),
                    ),
                  ),
                ],
                if (!isSurveyor && task.progressPercent != null) ...[
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: task.progressPercent! / 100,
                              backgroundColor: SigapColors.bgSoft,
                              valueColor: AlwaysStoppedAnimation(_statusColor),
                              minHeight: 4,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${task.progressPercent}%',
                          style: const TextStyle(
                            fontSize: SigapTypography.size11,
                            fontWeight: FontWeight.w600,
                            color: SigapColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ],
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
          const Icon(
            Icons.error_outline,
            size: 64,
            color: SigapColors.perluTindakan,
          ),
          const SizedBox(height: 16),
          Text('Gagal memuat: $error'),
          ElevatedButton(onPressed: onRetry, child: const Text('Coba Lagi')),
        ],
      ),
    );
  }
}

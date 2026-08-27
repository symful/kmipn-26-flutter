import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../api/types.g.dart';
import '../../providers/providers.dart';
import '../../theme/tokens.dart';
import '../../widgets/design_system/phone_frame.dart';
import '../../widgets/design_system/status_bar.dart';
import '../../widgets/skeleton_loaders.dart';
import 'presentation/widgets/surveyor_task_list_header.dart';
import 'presentation/widgets/connectivity_indicator.dart';
import 'presentation/widgets/task_filter_chips.dart';
import 'presentation/widgets/task_sort_row.dart';
import 'presentation/widgets/surveyor_task_card.dart';

/// S-01 Surveyor Home Screen
///
/// Displays today's tasks with filter/sort capabilities and online status indicator.
/// Supports loading, empty, error, and offline states.
class SurveyorHomeScreen extends ConsumerStatefulWidget {
  const SurveyorHomeScreen({super.key});

  @override
  ConsumerState<SurveyorHomeScreen> createState() => _SurveyorHomeScreenState();
}

class _SurveyorHomeScreenState extends ConsumerState<SurveyorHomeScreen> {
  /// Mock wilayah name - in production this would come from auth/user provider
  static const _wilayahName = 'Kab. Bandung';

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(surveyorTasksProvider);
    final filterIndex = ref.watch(surveyorFilterProvider);
    final sortValue = ref.watch(surveyorSortProvider);
    final connectivityAsync = ref.watch(connectivityProvider);

    final isOffline =
        connectivityAsync.whenOrNull(
          data: (results) =>
              results.isEmpty ||
              results.every((r) => r == ConnectivityResult.none),
        ) ??
        false;

    // Determine online status for indicator
    final ConnectivityStatus onlineStatus;
    if (isOffline) {
      onlineStatus = ConnectivityStatus.offline;
    } else {
      // If we have a sync in progress, show syncing
      onlineStatus = ConnectivityStatus.online;
    }

    return PhoneFrame(
      child: Column(
        children: [
          StatusBar(),
          Expanded(
            child: Scaffold(
              backgroundColor: SigapColors.bgSurface,
              body: Column(
                children: [
                  // Header with date and wilayah
                  SurveyorTaskListHeader(wilayahName: _wilayahName),

                  // Online status indicator row
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SigapSpacing.lg,
                      vertical: SigapSpacing.sm,
                    ),
                    child: Row(
                      children: [
                        ConnectivityIndicator(status: onlineStatus),
                        const Spacer(),
                        // Sync button when offline
                        if (isOffline)
                          TextButton.icon(
                            onPressed: () {
                              ref.read(syncWorkerProvider).syncNow();
                            },
                            icon: const Icon(Icons.sync, size: 16),
                            label: const Text('Sinkronkan'),
                            style: TextButton.styleFrom(
                              foregroundColor: SigapColors.primary,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Offline banner
                  if (isOffline) _OfflineBanner(),

                  // Filter chips
                  TaskFilterChips(
                    selectedIndex: filterIndex,
                    onChipSelected: (index) {
                      ref.read(surveyorFilterProvider.notifier).state = index;
                    },
                  ),

                  // Sort row
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SigapSpacing.lg,
                      vertical: SigapSpacing.sm,
                    ),
                    child: TaskSortRow(
                      selectedValue: _mapSortToDisplay(sortValue),
                      onSortChanged: (value) {
                        ref.read(surveyorSortProvider.notifier).state =
                            _mapDisplayToSort(value);
                      },
                      onUnduhBatchTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Fitur unduh batch belum tersedia'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ),

                  // Task list with all states
                  Expanded(
                    child: tasksAsync.when(
                      data: (tasks) =>
                          _buildTaskList(tasks, filterIndex, sortValue),
                      loading: () => _buildLoading(),
                      error: (error, _) => _buildError(
                        error,
                        () => ref.invalidate(surveyorTasksProvider),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Maps internal sort key to display value
  String _mapSortToDisplay(String sort) {
    switch (sort) {
      case 'terbaru':
        return 'Terbaru';
      case 'sla':
        return 'SLA terdekat';
      case 'prioritas':
        return 'Prioritas';
      default:
        return 'Terbaru';
    }
  }

  /// Maps display value to internal sort key
  String _mapDisplayToSort(String display) {
    switch (display) {
      case 'Terbaru':
        return 'terbaru';
      case 'SLA terdekat':
        return 'sla';
      case 'Prioritas':
        return 'prioritas';
      default:
        return 'terbaru';
    }
  }

  /// Builds the task list with filtering and sorting applied
  Widget _buildTaskList(
    List<SurveyorTask> tasks,
    int? filterIndex,
    String sortValue,
  ) {
    // Apply filter
    final filteredTasks = _applyFilter(tasks, filterIndex);

    // Apply sort
    final sortedTasks = _applySort(filteredTasks, sortValue);

    if (sortedTasks.isEmpty) {
      return _buildEmpty();
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(surveyorTasksProvider);
        await ref.read(surveyorTasksProvider.future);
      },
      color: SigapColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(SigapSpacing.lg),
        itemCount: sortedTasks.length,
        itemBuilder: (context, index) {
          final task = sortedTasks[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: SigapSpacing.md),
            child: SurveyorTaskCard(
              task: _mapToTaskData(task),
              onTap: () {
                final taskId = task.taskId;
                if (taskId != null) {
                  context.push('/surveyor/tasks/$taskId');
                }
              },
            ),
          );
        },
      ),
    );
  }

  /// Applies filter based on selected chip index
  List<SurveyorTask> _applyFilter(List<SurveyorTask> tasks, int? filterIndex) {
    if (filterIndex == null) return tasks;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (filterIndex) {
      case 0: // Hari ini
        return tasks.where((t) {
          final parsed = _parseDate(t.assignedAt);
          return parsed != null &&
              parsed.year == today.year &&
              parsed.month == today.month &&
              parsed.day == today.day;
        }).toList();
      case 1: // Terlambat
        // SurveyorTask has no deadline field; cannot determine overdue
        return [];
      case 2: // Belum diunduh
        // Filter tasks that are not in offline storage
        // For now, return empty as we'd need to check local DB
        return [];
      default:
        return tasks;
    }
  }

  /// Applies sorting based on selected sort option
  List<SurveyorTask> _applySort(List<SurveyorTask> tasks, String sortValue) {
    final sorted = List<SurveyorTask>.from(tasks);

    switch (sortValue) {
      case 'terbaru':
        sorted.sort((a, b) {
          final dateA = _parseDate(a.assignedAt);
          final dateB = _parseDate(b.assignedAt);
          if (dateA == null && dateB == null) return 0;
          if (dateA == null) return 1;
          if (dateB == null) return -1;
          return dateB.compareTo(dateA); // newest first
        });
        break;
      case 'sla':
        // SurveyorTask has no deadline field; keep original order
        break;
      case 'prioritas':
        // SurveyorTask has no severity field; keep original order
        break;
    }

    return sorted;
  }

  /// Maps API task to SurveyorTaskData
  SurveyorTaskData _mapToTaskData(SurveyorTask task) {
    // SurveyorTask has no severity field; default to normal priority
    const priority = TaskPriority.normal;

    // Format time ago from assignedAt ISO string
    final timeAgo = _formatTimeAgo(_parseDate(task.assignedAt));

    return SurveyorTaskData(
      id: task.taskId ?? '',
      title: task.reportTitle ?? 'Tanpa judul',
      location: '-',
      timeAgo: timeAgo,
      priority: priority,
    );
  }

  /// Parses an ISO date string to DateTime.
  DateTime? _parseDate(String? s) {
    if (s == null) return null;
    return DateTime.tryParse(s);
  }

  /// Formats a date as "time ago" string
  String _formatTimeAgo(DateTime? date) {
    if (date == null) return '-';

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      if (difference.inDays == 1) return 'Kemarin';
      if (difference.inDays < 7) return '${difference.inDays} hari lalu';
      return '${(difference.inDays / 7).floor()} minggu lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit lalu';
    } else {
      return 'Baru saja';
    }
  }

  /// Builds the loading skeleton
  Widget _buildLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(SigapSpacing.lg),
      itemCount: 3,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: SigapSpacing.md),
        child: const TaskCardSkeleton(),
      ),
    );
  }

  /// Builds the empty state
  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Empty state illustration - using a simple icon
          Container(
            width: SigapSpacing.x90,
            height: SigapSpacing.x90,
            decoration: BoxDecoration(
              color: SigapColors.bgSurface,
              shape: BoxShape.circle,
              border: Border.all(color: SigapColors.borderCard, width: 2),
            ),
            child: const Icon(
              Icons.inbox_outlined,
              size: 40,
              color: SigapColors.textTertiary,
            ),
          ),
          const SizedBox(height: SigapSpacing.lg),
          const Text(
            'Tidak ada tugas',
            style: TextStyle(
              fontSize: SigapTypography.size16,
              fontWeight: FontWeight.w600,
              color: SigapColors.textPrimary,
            ),
          ),
          const SizedBox(height: SigapSpacing.xs),
          const Text(
            'Tugas akan muncul di sini',
            style: TextStyle(
              fontSize: SigapTypography.size13,
              color: SigapColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the error state with retry button
  Widget _buildError(Object error, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SigapSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: SigapColors.danger,
            ),
            const SizedBox(height: SigapSpacing.lg),
            const Text(
              'Gagal memuat tugas',
              style: TextStyle(
                fontSize: SigapTypography.size16,
                fontWeight: FontWeight.w600,
                color: SigapColors.textPrimary,
              ),
            ),
            const SizedBox(height: SigapSpacing.sm),
            Text(
              error.toString(),
              style: const TextStyle(
                fontSize: SigapTypography.size12,
                color: SigapColors.textTertiary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: SigapSpacing.lg),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: SigapColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: SigapSpacing.lg,
                  vertical: SigapSpacing.md,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Offline banner widget
class _OfflineBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: SigapSpacing.lg,
        vertical: SigapSpacing.sm,
      ),
      color: SigapColors.warning.withValues(alpha: 0.1),
      child: Row(
        children: [
          Icon(
            Icons.wifi_off,
            size: SigapTypography.size14,
            color: SigapColors.warning,
          ),
          const SizedBox(width: SigapSpacing.sm),
          Expanded(
            child: Text(
              'Tidak ada koneksi internet',
              style: TextStyle(
                fontSize: SigapTypography.size12,
                color: SigapColors.warning,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

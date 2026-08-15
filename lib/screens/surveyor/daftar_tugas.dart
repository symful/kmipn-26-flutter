import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/providers.dart';
import '../../theme/tokens.dart';

/// Filter options for surveyor task list
enum TaskFilter { all, pending, inProgress, completed }

/// Provider for surveyor tasks
final surveyorTasksProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final api = ref.watch(apiClientProvider);
  return api.surveyorGetTasks();
});

/// Provider for current filter
final surveyorTaskFilterProvider = StateProvider<TaskFilter>(
  (ref) => TaskFilter.all,
);

/// Model representing a surveyor task card
class SurveyorTaskCard {
  final String id;
  final String title;
  final String? description;
  final String status;
  final String? category;
  final String? location;
  final String? photoUrl;
  final String? assignedDate;
  final int? priority;

  SurveyorTaskCard({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    this.category,
    this.location,
    this.photoUrl,
    this.assignedDate,
    this.priority,
  });

  factory SurveyorTaskCard.fromJson(Map<String, dynamic> json) {
    return SurveyorTaskCard(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '-',
      description:
          json['description'] as String? ?? json['instructions'] as String?,
      status: json['status'] as String? ?? 'pending',
      category: json['category'] as String? ?? json['category_name'] as String?,
      location: json['location'] as String? ?? json['address'] as String?,
      photoUrl: json['photo_url'] as String? ?? json['photo'] as String?,
      assignedDate:
          json['assigned_date'] as String? ?? json['created_at'] as String?,
      priority: (json['priority'] as num?)?.toInt() ?? json['severity'] as int?,
    );
  }
}

/// Extension to get display-friendly status label
extension TaskStatusLabel on String {
  String get statusLabel {
    switch (toLowerCase()) {
      case 'pending':
        return 'Menunggu';
      case 'assigned':
        return 'Ditugaskan';
      case 'in_progress':
        return 'Diproses';
      case 'completed':
        return 'Selesai';
      default:
        return this;
    }
  }

  Color statusColor() {
    switch (toLowerCase()) {
      case 'pending':
        return AppColors.warning;
      case 'assigned':
        return AppColors.info;
      case 'in_progress':
        return AppColors.primary;
      case 'completed':
        return AppColors.primary;
      default:
        return AppColors.textTertiary;
    }
  }
}

/// Filter chip data
class FilterChipData {
  final TaskFilter filter;
  final String label;
  final int? count;

  const FilterChipData({required this.filter, required this.label, this.count});
}

/// Main Daftar Tugas screen (S-01)
class SurveyorDaftarTugasScreen extends ConsumerWidget {
  const SurveyorDaftarTugasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.bgSurface,
      appBar: AppBar(
        title: const Text('Daftar Tugas'),
        backgroundColor: AppColors.bgCard,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Filter chips
          const _FilterChipsSection(),
          // Task list
          const Expanded(child: _TaskListSection()),
        ],
      ),
    );
  }
}

class _FilterChipsSection extends ConsumerWidget {
  const _FilterChipsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(surveyorTasksProvider);
    final currentFilter = ref.watch(surveyorTaskFilterProvider);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
        border: Border(bottom: BorderSide(color: AppColors.borderCard)),
      ),
      child: tasksAsync.when(
        data: (tasks) {
          final filterChips = _buildFilterChips(tasks, currentFilter);
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: filterChips.map((data) {
                final isSelected = data.filter == currentFilter;
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: FilterChip(
                    label: Text(
                      data.count != null
                          ? '${data.label} (${data.count})'
                          : data.label,
                    ),
                    selected: isSelected,
                    onSelected: (_) {
                      ref.read(surveyorTaskFilterProvider.notifier).state =
                          data.filter;
                    },
                    backgroundColor: AppColors.bgSurface,
                    selectedColor: AppColors.primaryLight,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.borderCard,
                      ),
                    ),
                    showCheckmark: false,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        },
        loading: () => const SizedBox(
          height: 40,
          child: Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }

  List<FilterChipData> _buildFilterChips(
    List<Map<String, dynamic>> tasks,
    TaskFilter currentFilter,
  ) {
    final pendingCount = tasks
        .where((t) => t['status'] == 'pending' || t['status'] == 'assigned')
        .length;
    final inProgressCount = tasks
        .where((t) => t['status'] == 'in_progress')
        .length;
    final completedCount = tasks
        .where((t) => t['status'] == 'completed')
        .length;

    return [
      FilterChipData(
        filter: TaskFilter.all,
        label: 'Semua',
        count: tasks.length,
      ),
      FilterChipData(
        filter: TaskFilter.pending,
        label: 'Menunggu',
        count: pendingCount,
      ),
      FilterChipData(
        filter: TaskFilter.inProgress,
        label: 'Diproses',
        count: inProgressCount,
      ),
      FilterChipData(
        filter: TaskFilter.completed,
        label: 'Selesai',
        count: completedCount,
      ),
    ];
  }
}

class _TaskListSection extends ConsumerWidget {
  const _TaskListSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(surveyorTasksProvider);
    final currentFilter = ref.watch(surveyorTaskFilterProvider);

    return tasksAsync.when(
      data: (tasks) {
        // Convert to domain models
        final taskCards = tasks
            .map((t) => SurveyorTaskCard.fromJson(t))
            .toList();

        // Apply filter
        final filteredTasks = _applyFilter(taskCards, currentFilter);

        if (filteredTasks.isEmpty) {
          return _EmptyState(filter: currentFilter);
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(surveyorTasksProvider);
          },
          color: AppColors.primary,
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: filteredTasks.length,
            itemBuilder: (context, index) {
              final task = filteredTasks[index];
              return _SurveyorTaskCardWidget(
                task: task,
                onTap: () => context.push('/surveyor/tasks/${task.id}'),
              );
            },
          ),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
      error: (error, _) => _ErrorState(
        error: error.toString(),
        onRetry: () => ref.invalidate(surveyorTasksProvider),
      ),
    );
  }

  List<SurveyorTaskCard> _applyFilter(
    List<SurveyorTaskCard> tasks,
    TaskFilter filter,
  ) {
    switch (filter) {
      case TaskFilter.all:
        return tasks;
      case TaskFilter.pending:
        return tasks
            .where((t) => t.status == 'pending' || t.status == 'assigned')
            .toList();
      case TaskFilter.inProgress:
        return tasks.where((t) => t.status == 'in_progress').toList();
      case TaskFilter.completed:
        return tasks.where((t) => t.status == 'completed').toList();
    }
  }
}

class _SurveyorTaskCardWidget extends StatelessWidget {
  final SurveyorTaskCard task;
  final VoidCallback onTap;

  const _SurveyorTaskCardWidget({required this.task, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      color: AppColors.bgCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: const BorderSide(color: AppColors.borderCard),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: Photo thumbnail + content
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Photo thumbnail
                  _PhotoThumbnail(photoUrl: task.photoUrl),
                  const SizedBox(width: AppSpacing.md),
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          task.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        // Location
                        if (task.location != null) ...[
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 14,
                                color: AppColors.textTertiary,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  task.location!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textTertiary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xs),
                        ],
                        // Category
                        if (task.category != null)
                          Row(
                            children: [
                              const Icon(
                                Icons.category_outlined,
                                size: 14,
                                color: AppColors.textTertiary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                task.category!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              // Divider
              Container(height: 1, color: AppColors.borderCard),
              const SizedBox(height: AppSpacing.md),
              // Bottom row: Priority badge + Assigned date + Status
              Row(
                children: [
                  // Priority badge
                  if (task.priority != null) ...[
                    _PriorityBadge(priority: task.priority!),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  // Assigned date
                  if (task.assignedDate != null)
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 12,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(task.assignedDate!),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  const Spacer(),
                  // Status badge
                  _StatusBadge(status: task.status),
                ],
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
    } catch (_) {
      return dateStr;
    }
  }
}

class _PhotoThumbnail extends StatelessWidget {
  final String? photoUrl;

  const _PhotoThumbnail({this.photoUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.md),
        color: AppColors.bgSurface,
        border: Border.all(color: AppColors.borderCard),
      ),
      clipBehavior: Clip.antiAlias,
      child: photoUrl != null && photoUrl!.isNotEmpty
          ? Image.network(
              photoUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _placeholderIcon(),
            )
          : _placeholderIcon(),
    );
  }

  Widget _placeholderIcon() {
    return const Center(
      child: Icon(
        Icons.image_outlined,
        size: 32,
        color: AppColors.textTertiary,
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  final int priority;

  const _PriorityBadge({required this.priority});

  Color get _color {
    if (priority >= 4) return AppColors.danger;
    if (priority >= 2) return AppColors.warning;
    return AppColors.info;
  }

  String get _label {
    if (priority >= 4) return 'Tinggi';
    if (priority >= 2) return 'Sedang';
    return 'Rendah';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        'Prioritas $_label',
        style: TextStyle(
          color: _color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: status.statusColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        status.statusLabel,
        style: TextStyle(
          color: status.statusColor(),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final TaskFilter filter;

  const _EmptyState({required this.filter});

  String get _message {
    switch (filter) {
      case TaskFilter.all:
        return 'Belum ada tugas survei';
      case TaskFilter.pending:
        return 'Tidak ada tugas yang menunggu';
      case TaskFilter.inProgress:
        return 'Tidak ada tugas sedang diproses';
      case TaskFilter.completed:
        return 'Belum ada tugas yang selesai';
    }
  }

  IconData get _icon {
    switch (filter) {
      case TaskFilter.all:
        return Icons.inbox_outlined;
      case TaskFilter.pending:
        return Icons.pending_actions_outlined;
      case TaskFilter.inProgress:
        return Icons.engineering_outlined;
      case TaskFilter.completed:
        return Icons.check_circle_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(_icon, size: 64, color: AppColors.textTertiary),
          const SizedBox(height: AppSpacing.lg),
          Text(
            _message,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorState({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.danger),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Gagal memuat data',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              error,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

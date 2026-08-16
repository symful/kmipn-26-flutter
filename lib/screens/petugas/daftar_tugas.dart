import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../api/exceptions.dart';
import '../../providers/providers.dart';
import '../../theme/tokens.dart';
import '../../widgets/design_system/status_pill.dart';

/// Filter options for petugas task list
enum PetugasTaskFilter { all, active, completed }

/// Provider for petugas tasks
final petugasTasksProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final api = ref.watch(apiClientProvider);
  return api.petugasGetTasks();
});

/// Provider for current filter
final petugasTaskFilterProvider = StateProvider<PetugasTaskFilter>(
  (ref) => PetugasTaskFilter.all,
);

/// Model representing a petugas task card
class PetugasTaskCard {
  final String id;
  final String title;
  final String? description;
  final String status;
  final String? category;
  final String? location;
  final double? distance;
  final String? photoUrl;
  final String? assignedDate;
  final int? priority;

  PetugasTaskCard({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    this.category,
    this.location,
    this.distance,
    this.photoUrl,
    this.assignedDate,
    this.priority,
  });

  factory PetugasTaskCard.fromJson(Map<String, dynamic> json) {
    return PetugasTaskCard(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '-',
      description:
          json['description'] as String? ?? json['instructions'] as String?,
      status: json['status'] as String? ?? 'pending',
      category: json['category'] as String? ?? json['category_name'] as String?,
      location: json['location'] as String? ?? json['address'] as String?,
      distance: (json['distance'] as num?)?.toDouble(),
      photoUrl: json['photo_url'] as String? ?? json['photo'] as String?,
      assignedDate:
          json['assigned_date'] as String? ?? json['created_at'] as String?,
      priority: (json['priority'] as num?)?.toInt() ?? json['severity'] as int?,
    );
  }
}

/// Extension to get display-friendly status label
extension PetugasTaskStatusLabel on String {
  String get statusLabel {
    switch (toLowerCase()) {
      case 'pending':
        return 'Baru';
      case 'accepted':
        return 'Diterima';
      case 'in_progress':
        return 'Diproses';
      case 'completed':
        return 'Selesai';
      case 'rejected':
        return 'Ditolak';
      default:
        return this;
    }
  }

  StatusPillVariant get statusPillVariant {
    switch (toLowerCase()) {
      case 'pending':
        return StatusPillVariant.warning;
      case 'accepted':
        return StatusPillVariant.info;
      case 'in_progress':
        return StatusPillVariant.info;
      case 'completed':
        return StatusPillVariant.success;
      case 'rejected':
        return StatusPillVariant.danger;
      default:
        return StatusPillVariant.neutral;
    }
  }
}

/// Filter chip data
class PetugasFilterChipData {
  final PetugasTaskFilter filter;
  final String label;
  final int? count;

  const PetugasFilterChipData({
    required this.filter,
    required this.label,
    this.count,
  });
}

/// Main Daftar Tugas screen for Petugas
class PetugasDaftarTugasScreen extends ConsumerWidget {
  const PetugasDaftarTugasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.bgSurface,
      appBar: AppBar(
        title: const Text('Tugas Petugas'),
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
        children: const [
          // Filter chips
          _PetugasFilterChipsSection(),
          // Task list
          Expanded(child: _PetugasTaskListSection()),
        ],
      ),
    );
  }
}

class _PetugasFilterChipsSection extends ConsumerWidget {
  const _PetugasFilterChipsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(petugasTasksProvider);
    final currentFilter = ref.watch(petugasTaskFilterProvider);

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
                      ref.read(petugasTaskFilterProvider.notifier).state =
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

  List<PetugasFilterChipData> _buildFilterChips(
    List<Map<String, dynamic>> tasks,
    PetugasTaskFilter currentFilter,
  ) {
    final activeCount = tasks
        .where(
          (t) =>
              t['status'] == 'pending' ||
              t['status'] == 'accepted' ||
              t['status'] == 'in_progress',
        )
        .length;
    final completedCount = tasks
        .where((t) => t['status'] == 'completed')
        .length;

    return [
      PetugasFilterChipData(
        filter: PetugasTaskFilter.all,
        label: 'Semua',
        count: tasks.length,
      ),
      PetugasFilterChipData(
        filter: PetugasTaskFilter.active,
        label: 'Aktif',
        count: activeCount,
      ),
      PetugasFilterChipData(
        filter: PetugasTaskFilter.completed,
        label: 'Selesai',
        count: completedCount,
      ),
    ];
  }
}

class _PetugasTaskListSection extends ConsumerWidget {
  const _PetugasTaskListSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(petugasTasksProvider);
    final currentFilter = ref.watch(petugasTaskFilterProvider);

    return tasksAsync.when(
      data: (tasks) {
        // Convert to domain models
        final taskCards = tasks
            .map((t) => PetugasTaskCard.fromJson(t))
            .toList();

        // Apply filter
        final filteredTasks = _applyFilter(taskCards, currentFilter);

        if (filteredTasks.isEmpty) {
          return _PetugasEmptyState(filter: currentFilter);
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(petugasTasksProvider);
          },
          color: AppColors.primary,
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: filteredTasks.length,
            itemBuilder: (context, index) {
              final task = filteredTasks[index];
              return _PetugasTaskCardWidget(
                task: task,
                onTap: () => context.push('/petugas/tasks/${task.id}'),
              );
            },
          ),
        );
      },
      loading: () => const _PetugasSkeletonList(),
      error: (error, _) => _PetugasErrorState(
        error: extractErrorMessage(error),
        onRetry: () => ref.invalidate(petugasTasksProvider),
      ),
    );
  }

  List<PetugasTaskCard> _applyFilter(
    List<PetugasTaskCard> tasks,
    PetugasTaskFilter filter,
  ) {
    switch (filter) {
      case PetugasTaskFilter.all:
        return tasks;
      case PetugasTaskFilter.active:
        return tasks
            .where(
              (t) =>
                  t.status == 'pending' ||
                  t.status == 'accepted' ||
                  t.status == 'in_progress',
            )
            .toList();
      case PetugasTaskFilter.completed:
        return tasks.where((t) => t.status == 'completed').toList();
    }
  }
}

class _PetugasTaskCardWidget extends StatelessWidget {
  final PetugasTaskCard task;
  final VoidCallback onTap;

  const _PetugasTaskCardWidget({required this.task, required this.onTap});

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
                  _PetugasPhotoThumbnail(photoUrl: task.photoUrl),
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
              // Bottom row: Priority badge + Distance + Time ago + Status
              Row(
                children: [
                  // Priority badge
                  if (task.priority != null) ...[
                    _PetugasPriorityBadge(priority: task.priority!),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  // Distance
                  if (task.distance != null)
                    Row(
                      children: [
                        const Icon(
                          Icons.directions_walk_outlined,
                          size: 12,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDistance(task.distance!),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textTertiary,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                      ],
                    ),
                  // Time ago
                  if (task.assignedDate != null)
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 12,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _timeAgo(task.assignedDate!),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  const Spacer(),
                  // Status badge
                  StatusPill(
                    label: task.status.statusLabel,
                    variant: task.status.statusPillVariant,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDistance(double distance) {
    if (distance < 1) {
      return '${(distance * 1000).round()} m';
    } else {
      return '${distance.toStringAsFixed(1)} km';
    }
  }

  String _timeAgo(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(dt);

      if (diff.inDays > 30) {
        return '${(diff.inDays / 30).floor()} bln lalu';
      } else if (diff.inDays > 0) {
        return '${diff.inDays} hari lalu';
      } else if (diff.inHours > 0) {
        return '${diff.inHours} jam lalu';
      } else if (diff.inMinutes > 0) {
        return '${diff.inMinutes} menit lalu';
      } else {
        return 'Baru';
      }
    } catch (_) {
      return dateStr;
    }
  }
}

class _PetugasPhotoThumbnail extends StatelessWidget {
  final String? photoUrl;

  const _PetugasPhotoThumbnail({this.photoUrl});

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
      child: Icon(Icons.task_alt, size: 32, color: AppColors.textTertiary),
    );
  }
}

class _PetugasPriorityBadge extends StatelessWidget {
  final int priority;

  const _PetugasPriorityBadge({required this.priority});

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

class _PetugasEmptyState extends StatelessWidget {
  final PetugasTaskFilter filter;

  const _PetugasEmptyState({required this.filter});

  String get _message {
    switch (filter) {
      case PetugasTaskFilter.all:
        return 'Belum ada tugas';
      case PetugasTaskFilter.active:
        return 'Tidak ada tugas aktif';
      case PetugasTaskFilter.completed:
        return 'Belum ada tugas selesai';
    }
  }

  IconData get _icon {
    switch (filter) {
      case PetugasTaskFilter.all:
        return Icons.inbox_outlined;
      case PetugasTaskFilter.active:
        return Icons.pending_actions_outlined;
      case PetugasTaskFilter.completed:
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

class _PetugasErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _PetugasErrorState({required this.error, required this.onRetry});

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

/// Skeleton loader for task list
class _PetugasSkeletonList extends StatelessWidget {
  const _PetugasSkeletonList();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: 5,
      itemBuilder: (context, index) => const _PetugasSkeletonCard(),
    );
  }
}

class _PetugasSkeletonCard extends StatelessWidget {
  const _PetugasSkeletonCard();

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
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Photo skeleton
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    color: AppColors.bgSoft,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                // Content skeleton
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 16,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: AppColors.bgSoft,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        height: 12,
                        width: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: AppColors.bgSoft,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Container(
                        height: 12,
                        width: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: AppColors.bgSoft,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Container(height: 1, color: AppColors.borderCard),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Container(
                  height: 20,
                  width: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    color: AppColors.bgSoft,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Container(
                  height: 20,
                  width: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    color: AppColors.bgSoft,
                  ),
                ),
                const Spacer(),
                Container(
                  height: 20,
                  width: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    color: AppColors.bgSoft,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

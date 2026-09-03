import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import '../../api/client.dart';
import '../../l10n/strings.dart';
import '../../providers/providers.dart';
import '../../providers/capability_provider.dart';
import '../../theme/tokens.dart';
import '../../widgets/adaptive_nav.dart';
import '../../widgets/design_system/phone_frame.dart';
import '../../widgets/design_system/status_bar.dart';
import '../../widgets/design_system/task_filter_chips.dart';
import '../../widgets/design_system/sync_status_indicator.dart';
import '../../widgets/design_system/photo_full_screen.dart';
import '../../widgets/design_system/petugas_action_bar.dart';
import '../../widgets/can.dart';
import 'package:sigap/widgets/design_system/s02_action_bar.dart';
import 'package:sigap/widgets/design_system/s02_instruksi_card.dart';
import 'package:sigap/widgets/design_system/s02_checklist.dart';
import 'package:sigap/widgets/design_system/s02_bukti_thumbnails.dart';
import 'package:sigap/widgets/design_system/s02_offline_banner.dart';
import 'package:sigap/widgets/design_system/offline_ready_badge.dart';

/// Unified TaskWorkspace for both SURVEYOR and PETUGAS roles.
///
/// Combines list and detail views into a single capability-driven workspace:
/// - `taskId` param null → list view
/// - `taskId` param set → detail view
///
/// Capability determine:
/// - `survey.start` → surveyor mode (SLA/deadline badges, download for offline, distance)
/// - Missing `survey.start` → petugas mode (progress bars, no distance)
///
/// Uses `Can` widget for capability-gated UI sections and `capabilityState.can()`
/// for fetcher/action determination.
///
/// Navigation: pushes to same workspace with taskId set.
class TaskWorkspace extends ConsumerStatefulWidget {
  /// Optional taskId - when set, shows detail view for that task.
  final String? taskId;

  const TaskWorkspace({super.key, this.taskId});

  @override
  ConsumerState<TaskWorkspace> createState() => _TaskWorkspaceState();
}

class _TaskWorkspaceState extends ConsumerState<TaskWorkspace> {
  // ─── List state ───────────────────────────────────────────────────────────

  bool _loading = true;
  String? _error;
  int? _filterIndex;
  String _sortValue = Strings.slaTerdekat;
  int _selectedNavIndex = 0;

  List<_TaskItem> _tasks = [];
  Set<String> _downloadedTaskIds = {};
  double? _deviceLat;
  double? _deviceLng;
  bool _isDownloading = false;

  // ─── Detail state ─────────────────────────────────────────────────────────

  bool _detailLoading = true;
  String? _detailError;
  TaskDetail? _detail;
  List<String> _reportPhotos = [];
  ChecklistTemplate? _checklistTemplate;
  bool _isDownloaded = false;
  Set<int> _checkedChecklistItems = {};

  @override
  void initState() {
    super.initState();
    if (widget.taskId != null) {
      _loadDetail();
    } else {
      _load();
    }
  }

  @override
  void didUpdateWidget(TaskWorkspace oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.taskId != widget.taskId) {
      if (widget.taskId != null) {
        _loadDetail();
      } else {
        _load();
      }
    }
  }

  // ─── List methods ──────────────────────────────────────────────────────────

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final client = ref.read(apiClientProvider);
      final capabilityState = ref.read(capabilityNotifierProvider).valueOrNull;
      final isSurveyor =
          capabilityState?.capabilities.contains('survey.start') ?? false;

      final page = await client.getTasks();

      final taskItems = page.tasks
          .map((t) => _TaskItem.fromTask(t, isSurveyor))
          .toList();

      // Load downloaded task IDs for filter chip
      final surveyorRepo = ref.read(surveyorTaskRepositoryProvider);
      final downloadedTasks = await surveyorRepo.getDownloadedTasks();
      final downloadedIds = downloadedTasks.map((t) => t.taskId).toSet();

      // Get device location for distance calculation
      double? deviceLat;
      double? deviceLng;
      try {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 5),
          ),
        );
        deviceLat = position.latitude;
        deviceLng = position.longitude;
      } catch (_) {
        // Location not available
      }

      setState(() {
        _tasks = taskItems;
        _downloadedTaskIds = downloadedIds;
        _deviceLat = deviceLat;
        _deviceLng = deviceLng;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  /// Calculate distance in km between device and task location using haversine
  String? _calculateDistance(double? taskLat, double? taskLng) {
    if (taskLat == null ||
        taskLng == null ||
        _deviceLat == null ||
        _deviceLng == null) {
      return null;
    }
    const double earthRadius = 6371; // km
    final dLat = _toRadians(taskLat - _deviceLat!);
    final dLng = _toRadians(taskLng - _deviceLng!);
    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(_deviceLat!)) *
            cos(_toRadians(taskLat)) *
            sin(dLng / 2) *
            sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final distance = earthRadius * c;
    if (distance < 1) {
      return '${(distance * 1000).round()} m';
    }
    return '${distance.toStringAsFixed(1)} km';
  }

  double _toRadians(double degree) => degree * pi / 180;

  /// Bulk download selected tasks for offline use
  Future<void> _bulkDownload(List<_TaskItem> tasks) async {
    if (_isDownloading) return;
    setState(() => _isDownloading = true);

    final surveyorRepo = ref.read(surveyorTaskRepositoryProvider);
    int downloaded = 0;

    for (final task in tasks) {
      if (!_downloadedTaskIds.contains(task.id)) {
        await surveyorRepo.saveDownloadedTask(
          taskId: task.id,
          title: task.title,
          description: task.description,
          instructions: task.instructions,
          status: task.status,
          checklistTemplate: [], // Checklist fetched on task detail view
        );
        downloaded++;
      }
    }

    // Refresh downloaded IDs
    final downloadedTasks = await surveyorRepo.getDownloadedTasks();
    final downloadedIds = downloadedTasks.map((t) => t.taskId).toSet();

    setState(() {
      _downloadedTaskIds = downloadedIds;
      _isDownloading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Berhasil mengunduh $downloaded tugas'),
          backgroundColor: SigapColors.selesai,
        ),
      );
    }
  }

  /// Get count of tasks not yet downloaded
  int _getNotDownloadedCount() {
    return _tasks.where((t) => !_downloadedTaskIds.contains(t.id)).length;
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
      case 2: // Belum diunduh
        return tasks.where((t) => !_downloadedTaskIds.contains(t.id)).toList();
      default:
        return tasks;
    }
  }

  List<_TaskItem> _applySort(List<_TaskItem> tasks, String sortValue) {
    final sorted = List<_TaskItem>.from(tasks);
    switch (sortValue) {
      case Strings.terbaru:
        sorted.sort((a, b) {
          if (a.createdAt == null && b.createdAt == null) return 0;
          if (a.createdAt == null) return 1;
          if (b.createdAt == null) return -1;
          return b.createdAt!.compareTo(a.createdAt!);
        });
      case Strings.slaTerdekat:
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

  // ─── Detail methods ────────────────────────────────────────────────────────

  Future<void> _loadDetail() async {
    if (widget.taskId == null) return;

    setState(() {
      _detailLoading = true;
      _detailError = null;
    });

    try {
      final client = ref.read(apiClientProvider);
      final detail = await client.getTaskDetail(widget.taskId!);

      // Reset secondary state
      _reportPhotos = [];
      _checklistTemplate = null;
      _isDownloaded = false;

      // Fetch report photos if we have a reportId
      if (detail.reportId != null) {
        try {
          final report = await client.getReportById(detail.reportId!);
          setState(() {
            _reportPhotos = report.photos ?? [];
          });
        } catch (_) {
          // Report fetch failed, continue without photos
        }
      }

      // Fetch checklist template for surveyor role
      final capabilityState = ref.read(capabilityNotifierProvider).valueOrNull;
      final isSurveyor =
          capabilityState?.capabilities.contains('survey.start') ?? false;
      if (isSurveyor) {
        try {
          final template = await client.getTaskChecklistTemplate(
            widget.taskId!,
          );
          setState(() {
            _checklistTemplate = template;
          });
        } catch (_) {
          // Template fetch failed, continue without it
        }
      }

      // Check offline status
      final repo = ref.read(surveyorTaskRepositoryProvider);
      final downloadedTask = await repo.getDownloadedTask(widget.taskId!);
      final isDownloaded = downloadedTask != null;

      setState(() {
        _isDownloaded = isDownloaded;
        _detail = detail;
        _detailLoading = false;
      });
    } catch (e) {
      setState(() {
        _detailError = e.toString();
        _detailLoading = false;
      });
    }
  }

  Future<void> _doAction(Future<void> Function() action) async {
    try {
      await action();
      await _loadDetail(); // Refresh detail
    } catch (e) {
      if (mounted) {
        // Check for 409 conflict error
        final errorStr = e.toString().toLowerCase();
        if (errorStr.contains('409') || errorStr.contains('conflict')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tugas sudah dimulai oleh surveyor lain'),
              backgroundColor: SigapColors.warning,
            ),
          );
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Gagal: $e')));
        }
      }
    }
  }

  Future<void> _acceptTask() async {
    await _doAction(() async {
      final client = ref.read(apiClientProvider);
      await client.taskAction(widget.taskId!, action: 'accept');
    });
  }

  Future<void> _startTask() async {
    await _doAction(() async {
      final client = ref.read(apiClientProvider);
      await client.taskAction(widget.taskId!, action: 'start');
    });
  }

  Future<void> _rejectTask() async {
    final reasonController = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tolak Tugas'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            labelText: 'Alasan penolakan',
            hintText: 'Masukkan alasan...',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, reasonController.text),
            child: const Text('Tolak'),
          ),
        ],
      ),
    );
    if (reason == null || reason.isEmpty) return;

    final client = ref.read(apiClientProvider);
    await client.taskAction(widget.taskId!, action: 'reject', note: reason);
  }

  Future<void> _requestClarification() async {
    final noteController = TextEditingController();
    final note = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Minta Clarifikasi'),
        content: TextField(
          controller: noteController,
          decoration: const InputDecoration(
            labelText: 'Pertanyaan / klarifikasi',
            hintText: 'Tulis pertanyaan Anda...',
          ),
          maxLines: 4,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, noteController.text),
            child: const Text('Kirim'),
          ),
        ],
      ),
    );
    if (note == null || note.isEmpty) return;

    final client = ref.read(apiClientProvider);
    await client.taskAction(widget.taskId!, action: 'clarify', note: note);
  }

  void _navigateToSurveyForm() {
    // Build checklist items map from checked indices
    final checklistItems = (_checklistTemplate?.items ?? [])
        .asMap()
        .entries
        .map((entry) {
          final label =
              entry.value['label']?.toString() ??
              entry.value['text']?.toString() ??
              'Item';
          return {
            'item': label,
            'status': _checkedChecklistItems.contains(entry.key)
                ? 'completed'
                : 'pending',
          };
        })
        .toList();

    context.push(
      '/form-survei/${widget.taskId}',
      extra: {'checkedChecklistItems': checklistItems},
    );
  }

  // ─── Computed properties ────────────────────────────────────────────────────

  bool _getIsSurveyor(CapabilityState? capabilityState) {
    return capabilityState?.capabilities.contains('survey.start') ?? false;
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return SigapColors.offlineDot;
      case 'assigned':
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

  String _getStatusLabel(String status) {
    return Strings.statusLabel(status);
  }

  String _formatDate(String? s) {
    if (s == null) return '-';
    final dt = DateTime.tryParse(s);
    if (dt == null) return s;
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final capabilityState = ref.watch(
      capabilityNotifierProvider.select((s) => s.valueOrNull),
    );
    final isSurveyor = _getIsSurveyor(capabilityState);

    return PhoneFrame(
      child: Column(
        children: [
          StatusBar(),
          Expanded(
            child: widget.taskId != null
                ? _buildDetailView(isSurveyor)
                : _buildListView(isSurveyor),
          ),
        ],
      ),
    );
  }

  // ─── List view ─────────────────────────────────────────────────────────────

  Widget _buildListView(bool isSurveyor) {
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

    return Scaffold(
      backgroundColor: SigapColors.bgSurface,
      appBar: AppBar(
        backgroundColor: SigapColors.bgCard,
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 60,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: SigapSpacing.lg),
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
                      fontFamily: SigapTypography.fontFamilyMono,
                      fontSize: SigapTypography.size12,
                      color: SigapColors.textTertiary,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Only show download button for surveyor
              Can(
                action: 'survey.start',
                child: Builder(
                  builder: (context) {
                    if (isSurveyor && !_isDownloading) {
                      return IconButton(
                        icon: const Icon(Icons.download_rounded),
                        color: SigapColors.primary,
                        tooltip: 'Unduh semua untuk offline',
                        onPressed: _tasks.isEmpty
                            ? null
                            : () => _bulkDownload(_tasks),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              if (_isDownloading)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: SigapColors.primary,
                    ),
                  ),
                ),
              const SyncStatusIndicator(state: SyncState.online),
            ],
          ),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: SigapColors.primary),
            )
          : _error != null && _tasks.isEmpty
          ? _ErrorRetry(error: _error!, onRetry: _load)
          : _tasks.isEmpty
          ? _buildEmptyState(isSurveyor)
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
                  notDownloadedCount: _getNotDownloadedCount(),
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
                          items: ['Terbaru', 'Paling mendesak'].map((option) {
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
                        final isDownloaded = _downloadedTaskIds.contains(
                          task.id,
                        );
                        final distance = isSurveyor
                            ? _calculateDistance(task.lat, task.lng)
                            : null;
                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: SigapSpacing.md,
                          ),
                          child: _TasksFlowCard(
                            task: task,
                            isSurveyor: isSurveyor,
                            isDownloaded: isDownloaded,
                            distance: distance,
                            onDownload: isSurveyor && !isDownloaded
                                ? () => _bulkDownload([task])
                                : null,
                            onTap: () {
                              context.push('/tasks/${task.id}');
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
          ? AdaptiveNav(
              activeIndex: _selectedNavIndex,
              onTap: (index) {
                setState(() {
                  _selectedNavIndex = index;
                });
                if (index == 1) {
                  context.go('/map');
                } else if (index == 4) {
                  context.go('/profile');
                }
              },
            )
          : null,
    );
  }

  Widget _buildEmptyState(bool isSurveyor) {
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
            Text(
              isSurveyor ? 'Tidak Ada Tugas Survei' : 'Belum Ada Tugas',
              style: const TextStyle(
                fontSize: SigapTypography.size16,
                fontWeight: FontWeight.w700,
                color: SigapColors.textPrimary,
              ),
            ),
            const SizedBox(height: SigapSpacing.xs),
            Text(
              isSurveyor
                  ? 'Semua tugas survei lapangan yang ditugaskan akan tampil di sini.'
                  : 'Tugas penanganan dari operator akan muncul di sini saat ditugaskan.',
              style: const TextStyle(
                fontSize: SigapTypography.size13,
                color: SigapColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: SigapSpacing.lg),
            OutlinedButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Segarkan Data'),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Detail view ──────────────────────────────────────────────────────────

  Widget _buildDetailView(bool isSurveyor) {
    return Scaffold(
      backgroundColor: SigapColors.bgSurface,
      body: SafeArea(
        child: Column(
          children: [
            // Header bar with back
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: SigapSpacing.md),
              decoration: const BoxDecoration(
                color: SigapColors.bgCard,
                border: Border(
                  bottom: BorderSide(color: SigapColors.border, width: 0.5),
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    behavior: HitTestBehavior.opaque,
                    child: const Icon(
                      Icons.arrow_back_ios,
                      size: 20,
                      color: SigapColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: SigapSpacing.sm),
                  Expanded(
                    child: Text(
                      isSurveyor
                          ? 'Detail Tugas Survei'
                          : 'Detail Tugas Petugas',
                      style: const TextStyle(
                        fontSize: SigapTypography.size16,
                        fontWeight: FontWeight.w600,
                        color: SigapColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: _detailLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: SigapColors.primary,
                      ),
                    )
                  : _detailError != null && _detail == null
                  ? _ErrorRetry(
                      error: _detailError!,
                      onRetry: _loadDetail,
                      taskId: widget.taskId,
                    )
                  : _buildDetailContent(isSurveyor),
            ),

            // Action bar
            _buildActionBar(isSurveyor),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailContent(bool isSurveyor) {
    final detail = _detail;
    if (detail == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(SigapSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: SigapSpacing.sm,
              vertical: SigapSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: _getStatusColor(
                detail.status ?? '',
              ).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(SigapRadius.sm),
            ),
            child: Text(
              _getStatusLabel(detail.status ?? ''),
              style: TextStyle(
                fontSize: SigapTypography.size11,
                fontWeight: FontWeight.w600,
                color: _getStatusColor(detail.status ?? ''),
              ),
            ),
          ),
          const SizedBox(height: SigapSpacing.md),

          // Title
          Text(
            detail.reportTitle ?? '-',
            style: const TextStyle(
              fontSize: SigapTypography.size17,
              fontWeight: FontWeight.w700,
              color: SigapColors.textPrimary,
            ),
          ),
          const SizedBox(height: SigapSpacing.sm),

          // Task ID
          Text(
            'TGS-${(detail.taskId ?? '').length >= 4 ? detail.taskId!.substring(0, 4) : detail.taskId ?? '-'}',
            style: const TextStyle(
              fontFamily: SigapTypography.fontFamilyMono,
              fontSize: SigapTypography.size11,
              color: SigapColors.textTertiary,
            ),
          ),
          const SizedBox(height: SigapSpacing.lg),

          // Instruksi
          if (detail.description != null && detail.description!.isNotEmpty) ...[
            S02InstruksiCard(title: 'Instruksi', body: detail.description!),
            const SizedBox(height: SigapSpacing.lg),
          ],

          // Progress (for petugas only - surveyor uses checklist)
          if (!isSurveyor && detail.progress != null) ...[
            const Text(
              'Progress',
              style: TextStyle(
                fontSize: SigapTypography.size13,
                fontWeight: FontWeight.w600,
                color: SigapColors.textSecondary,
              ),
            ),
            const SizedBox(height: SigapSpacing.xs),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: (detail.progress! / 100).clamp(0.0, 1.0),
                    backgroundColor: SigapColors.border,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      SigapColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: SigapSpacing.sm),
                Text(
                  '${detail.progress}%',
                  style: const TextStyle(
                    fontSize: SigapTypography.size12,
                    fontWeight: FontWeight.w600,
                    color: SigapColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: SigapSpacing.lg),
          ],

          // Clarification note (if any)
          if (detail.clarification != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(SigapSpacing.md),
              decoration: BoxDecoration(
                color: SigapColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(SigapRadius.md),
                border: Border.all(color: SigapColors.warning),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Clarification',
                    style: TextStyle(
                      fontSize: SigapTypography.size12,
                      fontWeight: FontWeight.w600,
                      color: SigapColors.warning,
                    ),
                  ),
                  const SizedBox(height: SigapSpacing.xs),
                  Text(
                    detail.clarification.toString(),
                    style: const TextStyle(
                      fontSize: SigapTypography.size13,
                      color: SigapColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: SigapSpacing.lg),
          ],

          // Timestamps
          _InfoRow(label: 'Ditugaskan', value: _formatDate(detail.assignedAt)),
          if (detail.completedAt != null)
            _InfoRow(
              label: 'Diselesaikan',
              value: _formatDate(detail.completedAt),
            ),

          // Offline status card (surveyor only)
          if (isSurveyor) ...[
            const SizedBox(height: SigapSpacing.lg),
            S02OfflineBanner(isOfflineReady: _isDownloaded),
          ],

          // Citizen evidence gallery (Bukti warga)
          if (_reportPhotos.isNotEmpty) ...[
            const SizedBox(height: SigapSpacing.lg),
            S02BuktiThumbnails(
              imageUrls: _reportPhotos,
              onThumbnailTap: (index) =>
                  _showPhotoFullScreen(_reportPhotos, index),
            ),
          ],

          // Checklist section (surveyor only)
          if (isSurveyor &&
              _checklistTemplate != null &&
              (_checklistTemplate!.items ?? []).isNotEmpty) ...[
            const SizedBox(height: SigapSpacing.lg),
            S02Checklist(
              items: (_checklistTemplate!.items ?? []).map((item) {
                final label =
                    item['label']?.toString() ??
                    item['text']?.toString() ??
                    'Item';
                return label;
              }).toList(),
              checkedItems: _checkedChecklistItems,
              onItemToggled: (index) {
                setState(() {
                  if (_checkedChecklistItems.contains(index)) {
                    _checkedChecklistItems = Set.from(_checkedChecklistItems)
                      ..remove(index);
                  } else {
                    _checkedChecklistItems = Set.from(_checkedChecklistItems)
                      ..add(index);
                  }
                });
              },
            ),
          ],
        ],
      ),
    );
  }

  void _showPhotoFullScreen(List<String> photos, int index) {
    PhotoFullScreen.show(context, photos, index);
  }

  Widget _buildActionBar(bool isSurveyor) {
    if (_detail == null) return const SizedBox.shrink();

    final status = (_detail?.status ?? '').toLowerCase();
    final isAssigned = status == 'assigned';
    final isPending = status == 'pending';
    final isAccepted = status == 'accepted';

    if (isSurveyor) {
      // Surveyor: Two-step lifecycle: accept → start
      // Before accept (assigned/pending): show Terima, MintaClarifikasi, Tolak
      // After accept (accepted): show Kunjungi, MintaClarifikasi, Tolak
      return S02ActionBar(
        onTolak: isAssigned || isPending ? _rejectTask : null,
        onMintaClarifikasi: isAssigned || isPending || isAccepted
            ? _requestClarification
            : null,
        onTerima: isAssigned || isPending ? _acceptTask : null,
        onKunjungi: isAccepted ? _startTask : null,
      );
    } else {
      // Petugas: Terima, Kunjungi (opens survey form), Tolak, Clarifikasi
      return PetugasActionBar(
        onTolak: isAssigned || isPending ? _rejectTask : null,
        onMintaClarifikasi: isAssigned || isPending
            ? _requestClarification
            : null,
        onTerima: isAssigned || isPending ? _acceptTask : null,
        onKunjungi: isAssigned ? _navigateToSurveyForm : null,
      );
    }
  }
}

// ─── Shared models and widgets ────────────────────────────────────────────────

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
  final double? lat;
  final double? lng;
  final String? checklistTemplateJson;
  final String? instructions;
  final bool unclaimed;

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
    this.lat,
    this.lng,
    this.checklistTemplateJson,
    this.instructions,
    this.unclaimed = false,
  });

  factory _TaskItem.fromTask(dynamic t, bool isSurveyor) {
    // Parse ISO date string to DateTime
    DateTime? parseDate(String? s) {
      if (s == null) return null;
      return DateTime.tryParse(s);
    }

    if (isSurveyor) {
      final task = t as SurveyorTask;
      return _TaskItem(
        id: task.taskId ?? '',
        title: task.reportTitle ?? '-',
        description: null,
        status: task.status ?? 'pending',
        unclaimed: task.surveyorId == null && task.status == 'assigned',
        createdAt: parseDate(task.assignedAt),
        deadline: parseDate(task.deadline),
        categoryName: task.categoryName,
        address: task.address,
        progressPercent: null,
        severity: null,
        lat: task.reportLat,
        lng: task.reportLng,
        checklistTemplateJson: null,
        instructions: task.instructions,
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
        lat: null,
        lng: null,
        checklistTemplateJson: null,
        instructions: null,
      );
    }
  }
}

class _TasksFlowCard extends StatelessWidget {
  final _TaskItem task;
  final bool isSurveyor;
  final VoidCallback onTap;
  final bool isDownloaded;
  final VoidCallback? onDownload;
  final String? distance;

  const _TasksFlowCard({
    required this.task,
    required this.isSurveyor,
    required this.onTap,
    this.isDownloaded = false,
    this.onDownload,
    this.distance,
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
    return Strings.statusLabel(task.status);
  }

  Color get _priorityColor {
    if (task.deadline != null) {
      final now = DateTime.now();
      final hours = task.deadline!.difference(now).inHours;
      if (hours < 0) return SigapColors.danger;
      if (hours < 24) return SigapColors.warning;
    }
    if (!isDownloaded) return SigapColors.borderSoft;
    return SigapColors.primary;
  }

  /// SLA label per design S-01:
  /// - Terlambat Xh (red) when overdue
  /// - SLA Xj (amber) when within same day
  /// - SLA besok (gray) when deadline is tomorrow
  String get _slaLabel {
    if (task.deadline == null) return '';
    final now = DateTime.now();
    final hours = task.deadline!.difference(now).inHours;
    if (hours < 0) {
      final overdueHours = hours.abs();
      return 'Terlambat ${overdueHours}h';
    } else if (hours < 24) {
      return 'SLA ${hours}j';
    } else if (hours < 48) {
      return 'SLA besok';
    } else {
      final days = (hours / 24).ceil();
      return 'SLA ${days}d';
    }
  }

  /// Background color for SLA badge per design spec
  Color get _slaBadgeColor {
    if (task.deadline == null) return SigapColors.textTertiary;
    final now = DateTime.now();
    final hours = task.deadline!.difference(now).inHours;
    if (hours < 0) {
      return SigapColors.dangerBg; // red bg - Terlambat
    } else if (hours < 24) {
      return SigapColors.warningBg; // amber bg - SLA today
    } else if (hours < 48) {
      return SigapColors.bgSoft; // gray bg - SLA besok
    } else {
      return SigapColors.warningBg; // amber for future
    }
  }

  Color get _slaTextColor {
    if (task.deadline == null) return SigapColors.textTertiary;
    final now = DateTime.now();
    final hours = task.deadline!.difference(now).inHours;
    if (hours < 0) {
      return SigapColors.dangerTextStrong; // red text - Terlambat
    } else if (hours < 24) {
      return SigapColors.warningText; // amber text - SLA today
    } else if (hours < 48) {
      return SigapColors.textSecondary; // gray text - SLA besok
    } else {
      return SigapColors.warningText; // amber for future
    }
  }

  @override
  Widget build(BuildContext context) {
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
                          fontFamily: SigapTypography.fontFamilyMono,
                          fontSize: SigapTypography.size11,
                          color: SigapColors.textTertiary,
                        ),
                      ),
                      if (task.unclaimed) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Menunggu klaim personel',
                          style: TextStyle(
                            fontSize: SigapTypography.size11,
                            fontWeight: FontWeight.w600,
                            color: SigapColors.warning,
                          ),
                        ),
                      ],
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

            // Bottom row: SLA badge + progress (petugas) or category (surveyor) + distance/download
            Row(
              children: [
                if (task.deadline != null && _slaLabel.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _slaBadgeColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _slaLabel,
                      style: TextStyle(
                        fontSize: SigapTypography.size10,
                        fontWeight: FontWeight.w700,
                        color: _slaTextColor,
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
                // Distance indicator
                if (distance != null && isSurveyor) ...[
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.location_on_outlined,
                    size: 14,
                    color: SigapColors.textTertiary,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    distance!,
                    style: const TextStyle(
                      fontSize: SigapTypography.size10,
                      color: SigapColors.textTertiary,
                    ),
                  ),
                ],
                // Download status/button for surveyor
                if (isSurveyor) ...[
                  const Spacer(),
                  OfflineReadyBadge(
                    isOfflineAvailable: isDownloaded,
                    onDownloadTap: onDownload,
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
  final String? taskId;
  const _ErrorRetry({required this.error, required this.onRetry, this.taskId});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SigapSpacing.xl),
        child: Container(
          padding: const EdgeInsets.all(SigapSpacing.xl),
          decoration: BoxDecoration(
            color: SigapColors.bgCard,
            borderRadius: BorderRadius.circular(SigapRadius.lg),
            border: Border.all(color: SigapColors.borderCard),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 52,
                color: SigapColors.perluTindakan,
              ),
              const SizedBox(height: SigapSpacing.md),
              Text(
                taskId != null
                    ? 'Gagal Memuat Detail Tugas'
                    : 'Gagal Memuat Tugas',
                style: const TextStyle(
                  fontSize: SigapTypography.size16,
                  fontWeight: FontWeight.w700,
                  color: SigapColors.textPrimary,
                ),
              ),
              const SizedBox(height: SigapSpacing.xs),
              Text(
                error,
                style: const TextStyle(
                  fontSize: SigapTypography.size13,
                  color: SigapColors.textSecondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: SigapSpacing.lg),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SigapColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Info row widget for displaying label/value pairs.
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: SigapSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: SigapTypography.size12,
                color: SigapColors.textTertiary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: SigapTypography.size12,
                color: SigapColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Full screen photo viewer with page navigation.

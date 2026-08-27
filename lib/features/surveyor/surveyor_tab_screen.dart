import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import '../../api/types.g.dart';
import '../../providers/providers.dart';
import '../../theme/tokens.dart';
import '../../widgets/design_system/phone_frame.dart';
import '../../widgets/design_system/status_bar.dart';
import 'presentation/widgets/connectivity_indicator.dart';
import 'presentation/widgets/task_filter_chips.dart';

/// S-01 Surveyor Tab Screen
///
/// Container screen with 2-tab bottom navigation:
/// - Sinkron (sync icon) - main surveyor task list
/// - Riwayat (history icon) - history of submitted visits
///
/// Uses BottomNav5 styling for consistency with PantauDesa design.
class SurveyorTabScreen extends ConsumerStatefulWidget {
  const SurveyorTabScreen({super.key});

  @override
  ConsumerState<SurveyorTabScreen> createState() => _SurveyorTabScreenState();
}

class _SurveyorTabScreenState extends ConsumerState<SurveyorTabScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return PhoneFrame(
      child: Column(
        children: [
          StatusBar(),
          Expanded(
            child: Scaffold(
              backgroundColor: SigapColors.bgSurface,
              body: IndexedStack(
                index: _selectedIndex,
                children: const [_SinkronTab(), _RiwayatTab()],
              ),
              bottomNavigationBar: _Surveyor2TabNav(
                selectedIndex: _selectedIndex,
                onTap: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Sinkron tab - main surveyor task list
class _SinkronTab extends ConsumerStatefulWidget {
  const _SinkronTab();

  @override
  ConsumerState<_SinkronTab> createState() => _SinkronTabState();
}

class _SinkronTabState extends ConsumerState<_SinkronTab> {
  Set<String> _downloadedTaskIds = {};
  double? _deviceLat;
  double? _deviceLng;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _loadDownloadedAndLocation();
  }

  Future<void> _loadDownloadedAndLocation() async {
    // Load downloaded task IDs
    final surveyorRepo = ref.read(surveyorTaskRepositoryProvider);
    final downloadedTasks = await surveyorRepo.getDownloadedTasks();
    final downloadedIds = downloadedTasks.map((t) => t.taskId).toSet();

    // Get device location
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

    if (mounted) {
      setState(() {
        _downloadedTaskIds = downloadedIds;
        _deviceLat = deviceLat;
        _deviceLng = deviceLng;
      });
    }
  }

  /// Calculate distance in km using haversine
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

  Future<void> _bulkDownload(List<SurveyorTask> tasks) async {
    if (_isDownloading) return;
    setState(() => _isDownloading = true);

    final surveyorRepo = ref.read(surveyorTaskRepositoryProvider);
    int downloaded = 0;

    for (final task in tasks) {
      final taskId = task.taskId ?? '';
      if (taskId.isNotEmpty && !_downloadedTaskIds.contains(taskId)) {
        await surveyorRepo.saveDownloadedTask(
          taskId: taskId,
          title: task.reportTitle ?? '-',
          description: null,
          instructions: null,
          status: task.status ?? 'pending',
          checklistTemplate: [],
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

  /// SLA label per design S-01
  String _getSlaLabel(SurveyorTask task) {
    final deadline = task.deadline;
    if (deadline == null) return '';
    final parsed = DateTime.tryParse(deadline);
    if (parsed == null) return '';

    final now = DateTime.now();
    final hours = parsed.difference(now).inHours;
    if (hours < 0) {
      return 'Terlambat ${hours.abs()}h';
    } else if (hours < 24) {
      return 'SLA ${hours}j';
    } else if (hours < 48) {
      return 'SLA besok';
    } else {
      final days = (hours / 24).ceil();
      return 'SLA ${days}d';
    }
  }

  Color _getSlaBadgeColor(SurveyorTask task) {
    final deadline = task.deadline;
    if (deadline == null) return SigapColors.textTertiary;
    final parsed = DateTime.tryParse(deadline);
    if (parsed == null) return SigapColors.textTertiary;

    final now = DateTime.now();
    final hours = parsed.difference(now).inHours;
    if (hours < 0) {
      return SigapColors.dangerBg; // red bg
    } else if (hours < 24) {
      return SigapColors.warningBg; // amber bg
    } else if (hours < 48) {
      return SigapColors.bgSoft; // gray bg
    } else {
      return SigapColors.warningBg; // amber for future
    }
  }

  Color _getSlaTextColor(SurveyorTask task) {
    final deadline = task.deadline;
    if (deadline == null) return SigapColors.textTertiary;
    final parsed = DateTime.tryParse(deadline);
    if (parsed == null) return SigapColors.textTertiary;

    final now = DateTime.now();
    final hours = parsed.difference(now).inHours;
    if (hours < 0) {
      return SigapColors.dangerTextStrong; // red text
    } else if (hours < 24) {
      return SigapColors.warningText; // amber text
    } else if (hours < 48) {
      return SigapColors.textSecondary; // gray text
    } else {
      return SigapColors.warningText; // amber text
    }
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(surveyorTasksProvider);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          backgroundColor: SigapColors.bgCard,
          automaticallyImplyLeading: false,
          titleSpacing: 0,
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: SigapSpacing.lg),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Tugas hari ini',
                      style: TextStyle(
                        fontSize: SigapTypography.size19,
                        fontWeight: FontWeight.w700,
                        color: SigapColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    tasksAsync.when(
                      data: (tasks) => Text(
                        '${tasks.length} tugas',
                        style: const TextStyle(
                          fontFamily: SigapTypography.fontFamilyMono,
                          fontSize: SigapTypography.size12,
                          color: SigapColors.textTertiary,
                        ),
                      ),
                      loading: () => const Text(
                        '-',
                        style: TextStyle(color: SigapColors.textTertiary),
                      ),
                      error: (_, __) => const Text(
                        '-',
                        style: TextStyle(color: SigapColors.textTertiary),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                if (!_isDownloading)
                  IconButton(
                    icon: const Icon(Icons.download_rounded),
                    color: SigapColors.primary,
                    tooltip: 'Unduh semua untuk offline',
                    onPressed: () {
                      tasksAsync.whenData((tasks) {
                        if (tasks.isNotEmpty) {
                          _bulkDownload(tasks);
                        }
                      });
                    },
                  )
                else
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
                const ConnectivityIndicator(status: ConnectivityStatus.online),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: SigapSpacing.lg,
              vertical: SigapSpacing.sm,
            ),
            child: TaskFilterChips(selectedIndex: null, onChipSelected: (_) {}),
          ),
        ),
        tasksAsync.when(
          data: (tasks) {
            if (tasks.isEmpty) {
              return SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: SigapColors.bgSurface,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: SigapColors.borderCard,
                            width: 2,
                          ),
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
                    ],
                  ),
                ),
              );
            }
            return SliverPadding(
              padding: const EdgeInsets.all(SigapSpacing.lg),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final task = tasks[index];
                  final taskId = task.taskId ?? '';
                  final isDownloaded = _downloadedTaskIds.contains(taskId);
                  final distance = _calculateDistance(
                    task.reportLat,
                    task.reportLng,
                  );
                  final slaLabel = _getSlaLabel(task);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: SigapSpacing.md),
                    child: _SinkronTaskCard(
                      title: task.reportTitle ?? '-',
                      taskId: taskId,
                      location: task.address ?? '-',
                      slaLabel: slaLabel,
                      slaBadgeColor: _getSlaBadgeColor(task),
                      slaTextColor: _getSlaTextColor(task),
                      distance: distance,
                      isDownloaded: isDownloaded,
                      onDownload: !isDownloaded
                          ? () => _bulkDownload([task])
                          : null,
                      onTap: () {
                        if (taskId.isNotEmpty) {
                          context.push('/surveyor/tasks/$taskId');
                        }
                      },
                    ),
                  );
                }, childCount: tasks.length),
              ),
            );
          },
          loading: () => const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) =>
              SliverFillRemaining(child: Center(child: Text('Error: $error'))),
        ),
      ],
    );
  }
}

/// Task card for Sinkron tab
class _SinkronTaskCard extends StatelessWidget {
  final String title;
  final String taskId;
  final String location;
  final VoidCallback onTap;
  final String slaLabel;
  final Color slaBadgeColor;
  final Color slaTextColor;
  final String? distance;
  final bool isDownloaded;
  final VoidCallback? onDownload;

  const _SinkronTaskCard({
    required this.title,
    required this.taskId,
    required this.location,
    required this.onTap,
    this.slaLabel = '',
    this.slaBadgeColor = SigapColors.textTertiary,
    this.slaTextColor = SigapColors.textTertiary,
    this.distance,
    this.isDownloaded = false,
    this.onDownload,
  });

  String get _taskIdDisplay {
    if (taskId.startsWith('TGS-')) return taskId;
    return 'TGS-$taskId';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: SigapColors.bgCard,
          borderRadius: BorderRadius.circular(SigapRadius.x12),
          border: Border.all(color: SigapColors.borderCard),
        ),
        padding: const EdgeInsets.all(SigapSpacing.md),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: SigapColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  title.isNotEmpty ? title.substring(0, 1).toUpperCase() : '-',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: SigapColors.primaryDark,
                  ),
                ),
              ),
            ),
            const SizedBox(width: SigapSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: SigapTypography.size13_5,
                            fontWeight: FontWeight.w600,
                            color: SigapColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (slaLabel.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: slaBadgeColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            slaLabel,
                            style: TextStyle(
                              fontSize: SigapTypography.size10,
                              fontWeight: FontWeight.w700,
                              color: slaTextColor,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _taskIdDisplay,
                    style: const TextStyle(
                      fontFamily: SigapTypography.fontFamilyMono,
                      fontSize: SigapTypography.size11,
                      color: SigapColors.textTertiary,
                    ),
                  ),
                  if (location != '-') ...[
                    const SizedBox(height: 2),
                    Text(
                      location,
                      style: const TextStyle(
                        fontSize: SigapTypography.size11_5,
                        color: SigapColors.textTertiary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (distance != null) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 12,
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
                    ),
                  ],
                ],
              ),
            ),
            // Download status or button
            if (isDownloaded)
              Icon(Icons.download_done, color: SigapColors.selesai, size: 20)
            else if (onDownload != null)
              GestureDetector(
                onTap: onDownload,
                child: Icon(
                  Icons.download_outlined,
                  color: SigapColors.primary,
                  size: 20,
                ),
              )
            else
              const Icon(Icons.chevron_right, color: SigapColors.textTertiary),
          ],
        ),
      ),
    );
  }
}

/// Riwayat tab - history of submitted visits
class _RiwayatTab extends ConsumerStatefulWidget {
  const _RiwayatTab();

  @override
  ConsumerState<_RiwayatTab> createState() => _RiwayatTabState();
}

class _RiwayatTabState extends ConsumerState<_RiwayatTab> {
  List<_RiwayatVisitItem> _visits = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRiwayat();
  }

  Future<void> _loadRiwayat() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final surveyorRepo = ref.read(surveyorTaskRepositoryProvider);
      final syncedVisits = await surveyorRepo.getSyncedVisits();

      final items = <_RiwayatVisitItem>[];
      for (final visit in syncedVisits) {
        // Try to get task title from downloaded tasks, else fall back to visit payload
        String title = 'Visit #${visit.taskId}';
        String? taskId = visit.taskId;

        if (taskId.isNotEmpty) {
          final downloadedTask = await surveyorRepo.getDownloadedTask(taskId);
          if (downloadedTask != null && downloadedTask.title.isNotEmpty) {
            title = downloadedTask.title;
          }
        }

        // Try to parse title from visit data JSON
        try {
          final decoded =
              jsonDecode(visit.visitDataJson) as Map<String, dynamic>;
          final payloadTitle = decoded['title'] as String?;
          if (payloadTitle != null && payloadTitle.isNotEmpty) {
            title = payloadTitle;
          }
        } catch (_) {
          // Use default title
        }

        items.add(
          _RiwayatVisitItem(
            idempotencyKey: visit.idempotencyKey,
            taskId: visit.taskId,
            title: title,
            createdAt: visit.createdAt,
            serverId: visit.serverId,
          ),
        );
      }

      setState(() {
        _visits = items;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) {
      return 'Hari ini';
    } else if (diff.inDays == 1) {
      return 'Kemarin';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} hari lalu';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          backgroundColor: SigapColors.bgCard,
          automaticallyImplyLeading: false,
          titleSpacing: 0,
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: SigapSpacing.lg),
            child: Row(
              children: [
                const Text(
                  'Riwayat',
                  style: TextStyle(
                    fontSize: SigapTypography.size19,
                    fontWeight: FontWeight.w700,
                    color: SigapColors.textPrimary,
                  ),
                ),
                const Spacer(),
                if (!_loading && (_error?.isNotEmpty ?? false))
                  Text(
                    '${_visits.length} visit',
                    style: const TextStyle(
                      fontFamily: SigapTypography.fontFamilyMono,
                      fontSize: SigapTypography.size11,
                      color: SigapColors.textTertiary,
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (_loading)
          const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_error != null && _visits.isEmpty)
          SliverFillRemaining(
            child: _RiwayatError(error: _error!, onRetry: _loadRiwayat),
          )
        else if (_visits.isEmpty)
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: SigapColors.bgSurface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: SigapColors.borderCard,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.history,
                      size: 40,
                      color: SigapColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: SigapSpacing.lg),
                  const Text(
                    'Belum ada riwayat',
                    style: TextStyle(
                      fontSize: SigapTypography.size16,
                      fontWeight: FontWeight.w600,
                      color: SigapColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: SigapSpacing.xs),
                  const Text(
                    'Visit yang dikirim akan muncul di sini',
                    style: TextStyle(
                      fontSize: SigapTypography.size13,
                      color: SigapColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.all(SigapSpacing.lg),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final visit = _visits[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: SigapSpacing.md),
                  child: _RiwayatVisitCard(
                    title: visit.title,
                    taskId: visit.taskId,
                    date: _formatDate(visit.createdAt),
                    onTap: () {
                      if (visit.taskId.isNotEmpty) {
                        context.push('/surveyor/tasks/${visit.taskId}');
                      }
                    },
                  ),
                );
              }, childCount: _visits.length),
            ),
          ),
      ],
    );
  }
}

class _RiwayatVisitItem {
  final String idempotencyKey;
  final String taskId;
  final String title;
  final DateTime createdAt;
  final String? serverId;

  _RiwayatVisitItem({
    required this.idempotencyKey,
    required this.taskId,
    required this.title,
    required this.createdAt,
    this.serverId,
  });
}

class _RiwayatVisitCard extends StatelessWidget {
  final String title;
  final String taskId;
  final String date;
  final VoidCallback onTap;

  const _RiwayatVisitCard({
    required this.title,
    required this.taskId,
    required this.date,
    required this.onTap,
  });

  String get _taskIdDisplay {
    if (taskId.startsWith('TGS-')) return taskId;
    return 'TGS-$taskId';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: SigapColors.bgCard,
          borderRadius: BorderRadius.circular(SigapRadius.x12),
          border: Border.all(color: SigapColors.borderCard),
        ),
        padding: const EdgeInsets.all(SigapSpacing.md),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: SigapColors.selesai.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.check_circle,
                color: SigapColors.selesai,
                size: 20,
              ),
            ),
            const SizedBox(width: SigapSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: SigapTypography.size13_5,
                      fontWeight: FontWeight.w600,
                      color: SigapColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _taskIdDisplay,
                    style: const TextStyle(
                      fontFamily: SigapTypography.fontFamilyMono,
                      fontSize: SigapTypography.size11,
                      color: SigapColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: SigapSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: SigapColors.selesai.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Terkirim',
                    style: TextStyle(
                      fontSize: SigapTypography.size10,
                      fontWeight: FontWeight.w600,
                      color: SigapColors.selesai,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: SigapTypography.size10,
                    color: SigapColors.textTertiary,
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

class _RiwayatError extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _RiwayatError({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SigapSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: SigapColors.perluTindakan,
            ),
            const SizedBox(height: SigapSpacing.lg),
            const Text(
              'Gagal memuat riwayat',
              style: TextStyle(
                fontSize: SigapTypography.size16,
                fontWeight: FontWeight.w600,
                color: SigapColors.textPrimary,
              ),
            ),
            const SizedBox(height: SigapSpacing.sm),
            Text(
              error,
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 2-tab bottom navigation for surveyor screens.
/// Matches PantauDesa S-01 design.
class _Surveyor2TabNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _Surveyor2TabNav({required this.selectedIndex, required this.onTap});

  Widget _buildNavItem(
    int index,
    String label,
    IconData icon,
    IconData activeIcon,
  ) {
    final isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 24,
              color: isSelected
                  ? SigapColors.primary
                  : SigapColors.textTertiary,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? SigapColors.primary
                    : SigapColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: SigapColors.borderCard, width: 1),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 9, 24, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, 'Sinkron', Icons.sync_outlined, Icons.sync),
          _buildNavItem(1, 'Riwayat', Icons.history_outlined, Icons.history),
        ],
      ),
    );
  }
}

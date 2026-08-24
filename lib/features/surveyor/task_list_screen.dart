import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../../providers/providers.dart';
import '../../../theme/tokens.dart';
import '../../../utils/logger.dart';
import '../../../widgets/design_system/bottom_nav_5.dart';
import 'presentation/widgets/task_filter_chips.dart';
import 'presentation/widgets/offline_ready_badge.dart';
import 'presentation/widgets/connectivity_indicator.dart';

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
  // Tracks which task IDs are currently being downloaded (with prefetch)
  final Set<String> _downloadingTaskIds = {};
  // Download progress: taskId -> (current, total)
  final Map<String, (int, int)> _downloadProgress = {};
  // Filter state: 0=Hari ini, 1=Terlambat, 2=Belum diunduh, null=all
  int? _filterIndex;
  // Sort state
  String _sortValue = 'Terbaru';
  // Selected nav index for BottomNav5
  int _selectedNavIndex = 0;

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

  // ─── Offline Cache Helpers ───────────────────────────────────────────────────

  /// Returns the cache directory for a specific task's offline content.
  Future<Directory> _getTaskCacheDir(String taskId) async {
    final appDir = await getApplicationDocumentsDirectory();
    final taskCacheDir = Directory(p.join(appDir.path, 'task_cache', taskId));
    if (!await taskCacheDir.exists()) {
      await taskCacheDir.create(recursive: true);
    }
    return taskCacheDir;
  }

  /// Downloads a file from [url] and saves it to [destFile].
  /// Returns true on success, false on failure.
  Future<bool> _downloadFile(String url, File destFile) async {
    try {
      final dio = Dio();
      await dio.download(url, destFile.path);
      return true;
    } catch (e, s) {
      _logger.warning('Failed to download $url', e, s);
      return false;
    }
  }

  /// Pre-fetches task photos and stores them locally.
  /// Returns the number of successfully cached photos.
  Future<int> _prefetchPhotos(String taskId, List<dynamic> photoUrls) async {
    if (photoUrls.isEmpty) return 0;

    final cacheDir = await _getTaskCacheDir(taskId);
    final photosDir = Directory(p.join(cacheDir.path, 'photos'));
    if (!await photosDir.exists()) {
      await photosDir.create(recursive: true);
    }

    int successCount = 0;
    for (int i = 0; i < photoUrls.length; i++) {
      final url = photoUrls[i].toString();
      if (url.isEmpty) continue;

      final ext = p.extension(url).isNotEmpty ? p.extension(url) : '.jpg';
      final destFile = File(p.join(photosDir.path, 'photo_$i$ext'));
      if (await _downloadFile(url, destFile)) {
        successCount++;
      }

      // Update progress
      setState(() {
        _downloadProgress[taskId] = (i + 1, photoUrls.length);
      });
    }
    return successCount;
  }

  /// Converts lat/lng to tile coordinates at a given zoom level.
  (int, int) _latLngToTile(double lat, double lng, int zoom) {
    final n = pow(2.0, zoom);
    final x = ((lng + 180.0) / 360.0 * n).floor();
    final latRad = lat * pi / 180.0;
    final y = ((1.0 - log(tan(latRad) + 1.0 / cos(latRad)) / pi) / 2.0 * n)
        .floor();
    return (x, y);
  }

  /// Pre-fetches OSM tiles for the area around [lat], [lng].
  /// Downloads zoom levels 14-17 by default.
  Future<int> _prefetchTiles(String taskId, double lat, double lng) async {
    const minZoom = 14;
    const maxZoom = 17;
    const tileUrlTemplate = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

    // Calculate how many tiles to fetch per zoom level for a small area
    // Around the location (roughly 500m x 500m area)
    int totalTiles = 0;
    final dio = Dio();

    for (int zoom = minZoom; zoom <= maxZoom; zoom++) {
      // Get center tile
      final (cx, cy) = _latLngToTile(lat, lng, zoom);

      // For each zoom, fetch a 3x3 grid around center for better coverage
      for (int dx = -1; dx <= 1; dx++) {
        for (int dy = -1; dy <= 1; dy++) {
          final x = cx + dx;
          final y = cy + dy;
          final url = tileUrlTemplate
              .replaceAll('{z}', zoom.toString())
              .replaceAll('{x}', x.toString())
              .replaceAll('{y}', y.toString());

          final cacheDir = await _getTaskCacheDir(taskId);
          final tilesDir = Directory(p.join(cacheDir.path, 'tiles'));
          if (!await tilesDir.exists()) {
            await tilesDir.create(recursive: true);
          }

          final destFile = File(p.join(tilesDir.path, '$zoom-$x-$y.png'));
          if (!await destFile.exists()) {
            try {
              await dio.download(url, destFile.path);
            } catch (e) {
              // Tile download failed, continue with others
            }
          }
          totalTiles++;

          // Update progress (photos done first, then tiles)
          setState(() {
            _downloadProgress[taskId] = (
              totalTiles,
              (maxZoom - minZoom + 1) * 9,
            );
          });
        }
      }
    }
    return totalTiles;
  }

  /// Main prefetch orchestrator: downloads photos and tiles for a task.
  Future<void> _prefetchTaskOfflineContent(Map<String, dynamic> detail) async {
    final taskId = detail['id']?.toString() ?? detail['taskId']?.toString();
    if (taskId == null) return;

    // Extract photo URLs from detail
    final photoUrls = detail['photo_urls'] as List<dynamic>? ?? [];

    // Extract location for tile pre-fetch
    final location = detail['location'] as Map<String, dynamic>?;
    final lat = location?['lat'] as double?;
    final lng = location?['lng'] as double?;

    // Pre-fetch in parallel
    await Future.wait([
      _prefetchPhotos(taskId, photoUrls),
      if (lat != null && lng != null && lat != 0.0 && lng != 0.0)
        _prefetchTiles(taskId, lat, lng),
    ]);
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
        // Mark as downloading
        setState(() {
          _downloadingTaskIds.add(taskId);
          _downloadProgress[taskId] = (0, 1);
        });

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

        // Pre-fetch photos and OSM tiles for offline use
        await _prefetchTaskOfflineContent(detail);

        setState(() {
          _downloadedIds.add(taskId);
          _downloadingTaskIds.remove(taskId);
          _downloadProgress.remove(taskId);
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
        setState(() {
          _downloadingTaskIds.remove(taskId);
          _downloadProgress.remove(taskId);
        });
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
    final filteredTasks = _applySort(
      _applyFilter(_tasks, _filterIndex),
      _sortValue,
    );
    final taskCount = filteredTasks.length;

    // Calculate filter counts for chips
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayCount = _tasks.where((t) {
      final createdAt = _parseDate(t['created_at'] ?? t['assigned_date']);
      return createdAt != null &&
          createdAt.year == today.year &&
          createdAt.month == today.month &&
          createdAt.day == today.day;
    }).length;
    final overdueCount = _tasks.where((t) {
      final dueDate = _parseDate(t['sla_due_date'] ?? t['due_date']);
      return dueDate != null && dueDate.isBefore(now);
    }).length;
    final notDownloadedCount = _tasks
        .where((t) => !_downloadedIds.contains(t['id']?.toString()))
        .length;

    return Scaffold(
      backgroundColor: AppColors.bgSurface,
      appBar: AppBar(
        backgroundColor: AppColors.bgCard,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            children: [
              // Title + Subtitle column
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Tugas hari ini',
                    style: const TextStyle(
                      fontSize: AppTypography.size19,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // S-01 subtitle: "N tugas · M siap offline" in mono font
                  Text(
                    '$taskCount tugas · ${_downloadedIds.length} siap offline',
                    style: const TextStyle(
                      fontFamily: 'IBM Plex Mono',
                      fontSize: AppTypography.size12,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              ConnectivityIndicator(
                status: _isOfflineMode
                    ? ConnectivityStatus.offline
                    : ConnectivityStatus.online,
              ),
            ],
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null && _tasks.isEmpty
          ? _ErrorRetry(error: _error!, onRetry: _load)
          : _tasks.isEmpty
          ? const Center(child: Text('Tidak ada tugas survei'))
          : Column(
              children: [
                // Filter chips with counts - S-01 design
                TaskFilterChips(
                  selectedIndex: _filterIndex,
                  onChipSelected: (index) {
                    setState(() {
                      _filterIndex = index;
                    });
                  },
                  todayCount: todayCount,
                  overdueCount: overdueCount,
                  notDownloadedCount: notDownloadedCount,
                ),
                // Sort row - S-01 design: "Urutkan: SLA terdekat ▾" + "Unduh N tugas"
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      // Sort label with dropdown value
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Urutkan: ',
                            style: const TextStyle(
                              fontSize: AppTypography.size12,
                              color: AppColors.textTertiary,
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
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        option,
                                        style: const TextStyle(
                                          fontSize: AppTypography.size12,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const Text(
                                        ' ▾',
                                        style: TextStyle(
                                          fontSize: AppTypography.size12,
                                          color: AppColors.textTertiary,
                                        ),
                                      ),
                                    ],
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
                        ],
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          // Batch download action
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Fitur unduh batch belum tersedia'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Text(
                          'Unduh $taskCount tugas',
                          style: const TextStyle(
                            fontSize: AppTypography.size12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Task list
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _load,
                    color: AppColors.primary,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      itemCount: filteredTasks.length,
                      itemBuilder: (context, index) {
                        final task = filteredTasks[index];
                        final taskId = task['id'] as String;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: _SurveyorTaskCard(
                            task: task,
                            isDownloaded: _downloadedIds.contains(taskId),
                            isDownloading: _downloadingTaskIds.contains(taskId),
                            progress: _downloadProgress[taskId],
                            onTap: () =>
                                context.push('/surveyor/tasks/$taskId'),
                            onDownloadToggle: () => _toggleDownload(task),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: BottomNav5(
        variant: BottomNavVariant.surveyor,
        selectedIndex: _selectedNavIndex,
        onTap: (index) {
          setState(() {
            _selectedNavIndex = index;
          });
          if (index == 1) {
            // Peta tab
            context.go('/surveyor/map');
          } else if (index == 4) {
            // Akun tab
            context.go('/profile');
          }
        },
      ),
    );
  }

  /// Applies filter based on selected chip index
  List<Map<String, dynamic>> _applyFilter(
    List<Map<String, dynamic>> tasks,
    int? filterIndex,
  ) {
    if (filterIndex == null) return tasks;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (filterIndex) {
      case 0: // Hari ini
        return tasks.where((t) {
          final createdAt = _parseDate(t['created_at'] ?? t['assigned_date']);
          return createdAt != null &&
              createdAt.year == today.year &&
              createdAt.month == today.month &&
              createdAt.day == today.day;
        }).toList();
      case 1: // Terlambat
        return tasks.where((t) {
          final dueDate = _parseDate(t['sla_due_date'] ?? t['due_date']);
          return dueDate != null && dueDate.isBefore(now);
        }).toList();
      case 2: // Belum diunduh
        return tasks.where((t) {
          final taskId = t['id']?.toString();
          return taskId != null && !_downloadedIds.contains(taskId);
        }).toList();
      default:
        return tasks;
    }
  }

  /// Parses a date string from API response
  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }

  /// Applies sort based on selected sort value
  List<Map<String, dynamic>> _applySort(
    List<Map<String, dynamic>> tasks,
    String sortValue,
  ) {
    final sorted = List<Map<String, dynamic>>.from(tasks);
    switch (sortValue) {
      case 'Terbaru':
        sorted.sort((a, b) {
          final dateA = _parseDate(a['created_at'] ?? a['assigned_date']);
          final dateB = _parseDate(b['created_at'] ?? b['assigned_date']);
          if (dateA == null && dateB == null) return 0;
          if (dateA == null) return 1;
          if (dateB == null) return -1;
          return dateB.compareTo(dateA); // newest first
        });
      case 'Paling mendesak':
        sorted.sort((a, b) {
          final dueDateA = _parseDate(a['sla_due_date'] ?? a['due_date']);
          final dueDateB = _parseDate(b['sla_due_date'] ?? b['due_date']);
          final now = DateTime.now();
          if (dueDateA == null && dueDateB == null) return 0;
          if (dueDateA == null) return 1;
          if (dueDateB == null) return -1;
          // Most urgent (soonest deadline) first
          return dueDateA.difference(now).compareTo(dueDateB.difference(now));
        });
      default:
        break;
    }
    return sorted;
  }
}

class _SurveyorTaskCard extends StatelessWidget {
  final Map<String, dynamic> task;
  final bool isDownloaded;
  final bool isDownloading;
  final (int, int)? progress;
  final VoidCallback onTap;
  final VoidCallback onDownloadToggle;

  const _SurveyorTaskCard({
    required this.task,
    required this.isDownloaded,
    required this.isDownloading,
    this.progress,
    required this.onTap,
    required this.onDownloadToggle,
  });

  /// Priority level based on SLA urgency or status
  /// S-01 Design: urgent (red), high (amber), normal (teal), low (gray)
  TaskPriorityLevel get _priority {
    final dueDate = _parseDate(task['sla_due_date'] ?? task['due_date']);
    if (dueDate != null) {
      final now = DateTime.now();
      final difference = dueDate.difference(now).inDays;
      final hours = dueDate.difference(now).inHours;
      if (difference < 0 || hours < 0) {
        return TaskPriorityLevel.urgent;
      } else if (difference <= 1) {
        return TaskPriorityLevel.high;
      } else if (difference <= 2) {
        return TaskPriorityLevel.high;
      }
    }
    // Fall back to status-based priority
    switch ((task['status'] ?? '').toString().toLowerCase()) {
      case 'pending':
        return TaskPriorityLevel.low;
      case 'assigned':
        return TaskPriorityLevel.normal;
      case 'in_progress':
        return TaskPriorityLevel.normal;
      case 'completed':
        return TaskPriorityLevel.normal;
      default:
        return TaskPriorityLevel.low;
    }
  }

  /// Returns SLA badge text matching S-01 design
  String get _slaLabel {
    final dueDate = _parseDate(task['sla_due_date'] ?? task['due_date']);
    if (dueDate != null) {
      final now = DateTime.now();
      final difference = dueDate.difference(now).inDays;
      final hours = dueDate.difference(now).inHours;
      if (difference < 0 || hours < 0) {
        final overdueHours = hours.abs();
        if (overdueHours < 1) {
          return 'Terlambat <1j';
        }
        return 'Terlambat ${overdueHours}h';
      } else if (difference == 0) {
        if (hours < 1) {
          return 'SLA <1j';
        }
        return 'SLA ${hours}j';
      } else if (difference == 1) {
        return 'SLA besok';
      } else {
        return 'SLA ${difference}d';
      }
    }
    return '';
  }

  /// Background color for SLA badge (S-01 design)
  Color get _slaBadgeColor {
    final dueDate = _parseDate(task['sla_due_date'] ?? task['due_date']);
    if (dueDate != null) {
      final now = DateTime.now();
      final hours = dueDate.difference(now).inHours;
      if (hours < 0) {
        return const Color(0xFFF8E2DE); // #f8e2de - red bg
      } else if (hours < 24) {
        return const Color(0xFFF8ECD6); // #f8ecd6 - amber bg
      }
    }
    return const Color(0xFFEEF0EC); // #eef0ec - gray bg
  }

  /// Text color for SLA badge (S-01 design)
  Color get _slaTextColor {
    final dueDate = _parseDate(task['sla_due_date'] ?? task['due_date']);
    if (dueDate != null) {
      final now = DateTime.now();
      final hours = dueDate.difference(now).inHours;
      if (hours < 0) {
        return const Color(0xFFA5271A); // #a5271a - red text
      } else if (hours < 24) {
        return const Color(0xFF8A5808); // #8a5808 - amber text
      }
    }
    return const Color(0xFF616770); // #616770 - gray text
  }

  /// Priority label in Indonesian (S-01 design)
  String get _priorityLabel {
    switch (_priority) {
      case TaskPriorityLevel.urgent:
        return 'Prioritas tinggi';
      case TaskPriorityLevel.high:
        return 'Prioritas sedang';
      case TaskPriorityLevel.normal:
        return 'Prioritas normal';
      case TaskPriorityLevel.low:
        return 'Prioritas rendah';
    }
  }

  /// Priority dot color (S-01 design)
  Color get _priorityDotColor {
    switch (_priority) {
      case TaskPriorityLevel.urgent:
        return AppColors.danger; // #c0392b
      case TaskPriorityLevel.high:
        return AppColors.warning; // #b8730a
      case TaskPriorityLevel.normal:
        return AppColors.primary; // #0f7a6b
      case TaskPriorityLevel.low:
        return AppColors.textTertiary; // #8a9099
    }
  }

  /// Border color for left stripe (S-01 design)
  Color get _borderColor {
    switch (_priority) {
      case TaskPriorityLevel.urgent:
        return AppColors.danger; // #c0392b
      case TaskPriorityLevel.high:
        return AppColors.warning; // #b8730a
      case TaskPriorityLevel.normal:
        return AppColors.primary; // #0f7a6b
      case TaskPriorityLevel.low:
        return AppColors.borderSoft; // #d3d7d0
    }
  }

  /// Location string from task data
  String get _location {
    // Try various location fields
    final location = task['location'] as String?;
    final address = task['address'] as String?;
    final wilayah = task['wilayah'] as String?;
    final rw = task['rw'] as String?;
    final distance =
        task['distance'] as String? ?? task['distance_km'] as String?;

    final parts = <String>[];
    if (rw != null && rw.toString().isNotEmpty) {
      parts.add('RW $rw');
    } else if (wilayah != null && wilayah.toString().isNotEmpty) {
      parts.add(wilayah.toString());
    } else if (address != null && address.toString().isNotEmpty) {
      parts.add(address.toString());
    } else if (location != null && location.toString().isNotEmpty) {
      parts.add(location.toString());
    }

    if (distance != null && distance.toString().isNotEmpty) {
      parts.add('$distance km');
    }

    return parts.isEmpty ? 'Lokasi tidak tersedia' : parts.join(' · ');
  }

  /// Task ID display string (e.g., "TGS-3391")
  String get _taskIdDisplay {
    final taskId = task['id']?.toString() ?? '-';
    if (taskId.startsWith('TGS-')) {
      return taskId;
    }
    return 'TGS-$taskId';
  }

  /// 2-letter avatar initials from title
  String get _avatarInitials {
    final title = task['title'] as String? ?? '-';
    if (title.isEmpty || title == '-') return '--';

    // Get first letter of first two words
    final words = title.split(' ').where((w) => w.isNotEmpty).toList();
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    } else if (words.isNotEmpty && words[0].length >= 2) {
      return words[0].substring(0, 2).toUpperCase();
    }
    return '--';
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }

  @override
  Widget build(BuildContext context) {
    final title = task['title'] as String? ?? '-';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(AppRadius.x12),
          border: Border(left: BorderSide(color: _borderColor, width: 4)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: Avatar + Title/ID + SLA Badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar with initials
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight, // #e2f1ee
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        _avatarInitials,
                        style: const TextStyle(
                          fontFamily: 'IBM Plex Mono',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryDark, // #0a5c50
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 9),
                  // Title + Task ID
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: AppTypography.size13_5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _taskIdDisplay,
                          style: const TextStyle(
                            fontFamily: 'IBM Plex Mono',
                            fontSize: AppTypography.size11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // SLA Badge
                  if (_slaLabel.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _slaBadgeColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _slaLabel,
                        style: TextStyle(
                          fontSize: AppTypography.size11,
                          fontWeight: FontWeight.w700,
                          color: _slaTextColor,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 11),
              // Location
              Text(
                _location,
                style: const TextStyle(
                  fontSize: AppTypography.size11_5,
                  color: AppColors.textTertiary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              // Bottom row: Priority badge + Offline badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Priority indicator
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: _priorityDotColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _priorityLabel,
                        style: TextStyle(
                          fontSize: AppTypography.size11,
                          fontWeight: FontWeight.w600,
                          color: _priorityTextColor,
                        ),
                      ),
                    ],
                  ),
                  // Offline badge or download button
                  if (isDownloading)
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  else
                    OfflineReadyBadge(
                      isOfflineAvailable: isDownloaded,
                      onDownloadTap: isDownloaded ? null : onDownloadToggle,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color get _priorityTextColor {
    switch (_priority) {
      case TaskPriorityLevel.urgent:
        return AppColors.dangerTextStrong; // #a5271a
      case TaskPriorityLevel.high:
        return AppColors.warningText; // #8a5808
      case TaskPriorityLevel.normal:
        return AppColors.primaryDark; // #0a5c50
      case TaskPriorityLevel.low:
        return AppColors.textTertiary; // #616770
    }
  }
}

enum TaskPriorityLevel { urgent, high, normal, low }

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

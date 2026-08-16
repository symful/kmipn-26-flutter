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
    final lat = location?['lat'] as double? ?? 0.0;
    final lng = location?['lng'] as double? ?? 0.0;

    // Pre-fetch in parallel
    await Future.wait([
      _prefetchPhotos(taskId, photoUrls),
      if (lat != 0.0 && lng != 0.0) _prefetchTiles(taskId, lat, lng),
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
                  final taskId = task['id'] as String;
                  return _SurveyorTaskCard(
                    task: task,
                    isDownloaded: _downloadedIds.contains(taskId),
                    isDownloading: _downloadingTaskIds.contains(taskId),
                    progress: _downloadProgress[taskId],
                    onTap: () => context.push('/surveyor/tasks/$taskId'),
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
                  if (isDownloading)
                    const SizedBox(
                      width: 48,
                      height: 48,
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  else
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

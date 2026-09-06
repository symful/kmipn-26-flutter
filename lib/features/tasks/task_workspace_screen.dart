import 'package:sigap/widgets/request_error_details.dart';
import 'package:intl/intl.dart';
import 'package:sigap/l10n/category_label.dart';
import 'package:sigap/widgets/design_system/mobile_title_bar.dart';
import 'survey_form_screen.dart';
import 'package:sigap/db/repositories/task_cache_repository.dart';
import 'package:sigap/config/api_config.dart';
import 'package:sigap/theme/sigap_color_scheme.dart';

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:sigap/api/client.dart';
import 'package:sigap/l10n/generated/app_localizations.dart';
import 'package:sigap/l10n/status_label.dart';
import 'package:sigap/providers/providers.dart';
import 'package:sigap/theme/tokens.dart';
import 'package:sigap/widgets/adaptive_nav.dart';

import 'package:sigap/widgets/design_system/photo_full_screen.dart';

/// Approximate tile bundle size for offline map area — picked once.
const double kMapTileEstimateMb = 2.0;

/// Approximate average size of a compressed field evidence photo in bytes.
// Evidence is loaded from the report. // ~500 KB per JPEG

/// Unified TaskWorkspaceScreen for PETUGAS role.
///
/// Combines list and detail views into a single capability-driven workspace:
/// - `taskId` param null → list view
/// - `taskId` param set → detail view
///
/// Capability determine:
/// - `survey.start` → field mode (SLA/deadline badges, distance)
/// - Missing `survey.start` → standard mode (progress bars, no distance)
///
/// Uses `Can` widget for capability-gated UI sections and `capabilityState.can()`
/// for fetcher/action determination.
///
/// Navigation: pushes to same workspace with taskId set.
class TaskWorkspaceScreen extends ConsumerStatefulWidget {
  /// Optional taskId - when set, shows detail view for that task.
  final String? taskId;
  final DateTime Function()? currentTime;
  final bool embedded;

  const TaskWorkspaceScreen({
    super.key,
    this.taskId,
    this.currentTime,
    this.embedded = false,
  });

  @override
  ConsumerState<TaskWorkspaceScreen> createState() =>
      _TaskWorkspaceScreenState();
}

class _TaskWorkspaceScreenState extends ConsumerState<TaskWorkspaceScreen> {
  // ─── List state ───────────────────────────────────────────────────────────

  late AppLocalizations _l10n;
  late final TaskCacheRepository _cache;
  bool _loading = true;
  String? _error;
  int? _filterIndex;
  String _sortValue = '';
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
  bool _photoLoadFailed = false;
  ChecklistTemplate? _checklistTemplate;
  bool _isDownloaded = false;
  Set<int> _checkedChecklistItems = {};
  int _listRequest = 0;
  int _detailRequest = 0;

  @override
  void initState() {
    super.initState();
    _cache = ref.read(taskCacheRepositoryProvider);
    if (widget.taskId != null) {
      _loadDetail();
    } else {
      _load();
    }
  }

  @override
  void didUpdateWidget(TaskWorkspaceScreen oldWidget) {
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
    final request = ++_listRequest;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final client = ref.read(apiClientProvider);
      final authState = ref.read(authNotifierProvider);
      final isPetugas = _getIsFieldMode(authState);

      if (ref.read(offlineModeProvider)) throw StateError('Mode offline');
      final page = await client.getTasks();

      final taskItems = page.tasks
          .map((t) => _TaskItem.fromTask(t, isPetugas))
          .toList();

      // Downloaded tasks — offline feature removed
      final cache = _cache;
      final downloadedIds = (await cache.readTasks())
          .map((task) => task.taskId!)
          .toSet();

      // Get device location for distance calculation
      double? deviceLat;
      double? deviceLng;
      try {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 5),
          ),
        );
        deviceLat = position.latitude;
        deviceLng = position.longitude;
      } catch (_) {
        // Location not available
      }

      if (!mounted || request != _listRequest) return;
      setState(() {
        _tasks = taskItems;
        _downloadedTaskIds = downloadedIds;
        _deviceLat = deviceLat;
        _deviceLng = deviceLng;
        _loading = false;
      });
    } catch (e) {
      final cached = await _cache.readTasks();
      if (!mounted || request != _listRequest) return;
      final ids = cached.map((task) => task.taskId!).toList();
      if (cached.isNotEmpty && mounted) {
        setState(() {
          _tasks = cached
              .map(
                (detail) => _TaskItem(
                  id: detail.taskId ?? '',
                  title: detail.reportTitle ?? '',
                  status: detail.status ?? '',
                  deadline: DateTime.tryParse(detail.deadline ?? ''),
                  categoryName: detail.categoryName,
                  progressPercent: detail.progress,
                ),
              )
              .toList();
          _downloadedTaskIds = ids.toSet();
          _loading = false;
        });
        return;
      }
      setState(() {
        _error = ref.read(offlineModeProvider)
            ? AppLocalizations.of(context)!.mobileYouAreOffline
            : e.toString();
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

  /// Bulk download selected tasks for offline use — feature removed
  Future<void> _bulkDownload(List<_TaskItem> tasks) async {
    setState(() => _isDownloading = true);
    try {
      final cache = _cache;
      final ids = (await cache.readTasks()).map((task) => task.taskId!).toSet();
      for (final task in tasks) {
        final detail = await ref.read(apiClientProvider).getTaskDetail(task.id);
        await cache.saveTask(detail);
        ids.add(task.id);
      }
      if (mounted) setState(() => _downloadedTaskIds = ids);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              (AppLocalizations.of(context)!.saveTaskFailed(error.toString())),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  List<_TaskItem> _applyFilter(List<_TaskItem> tasks, int? filterIndex) {
    if (filterIndex == null) return tasks;

    switch (filterIndex) {
      case 0:
        return tasks;
      case 1:
        return tasks
            .where((t) => t.status != 'completed' && t.status != 'rejected')
            .toList();
      case 2: // Belum diunduh
        return tasks.where((t) => !_downloadedTaskIds.contains(t.id)).toList();
      case 3:
        return tasks.where((t) => t.status == 'completed').toList();
      default:
        return tasks;
    }
  }

  List<_TaskItem> _applySort(List<_TaskItem> tasks, String sortValue) {
    final sorted = List<_TaskItem>.from(tasks);
    if (sortValue == _l10n.terbaru) {
      sorted.sort((a, b) {
        if (a.createdAt == null && b.createdAt == null) return 0;
        if (a.createdAt == null) return 1;
        if (b.createdAt == null) return -1;
        return b.createdAt!.compareTo(a.createdAt!);
      });
    } else if (sortValue == _l10n.slaTerdekat) {
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

  DateTime get now => widget.currentTime?.call() ?? DateTime.now();

  // ─── Detail methods ────────────────────────────────────────────────────────

  Future<void> _loadDetail() async {
    if (widget.taskId == null) return;
    final taskId = widget.taskId!;
    final request = ++_detailRequest;
    bool current() =>
        mounted && request == _detailRequest && widget.taskId == taskId;

    setState(() {
      _detailLoading = true;
      _detailError = null;
    });

    try {
      final client = ref.read(apiClientProvider);
      if (ref.read(offlineModeProvider)) throw StateError('Mode offline');
      final detail = await client.getTaskDetail(widget.taskId!);
      if (!current()) return;

      // Reset secondary state
      _reportPhotos =
          detail.evidenceUrls
              ?.map((photo) => photo.url ?? '')
              .where((url) => url.isNotEmpty)
              .toList() ??
          [];
      _photoLoadFailed = false;
      _checklistTemplate = null;
      _isDownloaded = false;

      // Fetch report photos if we have a reportId
      if (detail.reportId != null && _reportPhotos.isEmpty) {
        try {
          final report = await client.getReportById(detail.reportId!);
          if (!current()) return;
          setState(() {
            _reportPhotos = report.photos ?? [];
          });
        } catch (_) {
          if (!current()) return;
          setState(() => _photoLoadFailed = true);
        }
      }

      // This route is Petugas-only; fetch the actual task configuration.
      try {
        final template = await client.getTaskChecklistTemplate(widget.taskId!);
        if (!current()) return;
        setState(() {
          _checklistTemplate = template;
        });
      } catch (_) {
        // Missing configuration remains explicit instead of inventing actions.
      }

      // Check offline status — offline feature removed
      final cache = _cache;
      final isDownloaded = await cache.readTask(widget.taskId!) != null;
      final checked = await cache.readChecklist(widget.taskId!);
      if (!current()) return;

      setState(() {
        _isDownloaded = isDownloaded;
        _checkedChecklistItems = checked;
        _detail = detail;
        _detailLoading = false;
      });
    } catch (e) {
      if (!current()) return;
      final cache = _cache;
      final cached = await cache.readTask(widget.taskId!);
      final checked = await cache.readChecklist(widget.taskId!);
      if (!current()) return;
      if (cached != null && mounted) {
        final detail = cached;
        setState(() {
          _detail = detail;
          _checkedChecklistItems = checked;
          _reportPhotos =
              detail.evidenceUrls
                  ?.map((photo) => photo.url ?? '')
                  .where((url) => url.isNotEmpty)
                  .toList() ??
              [];
          _detailLoading = false;
          _isDownloaded = true;
        });
        return;
      }
      setState(() {
        _detailError = ref.read(offlineModeProvider)
            ? AppLocalizations.of(context)!.mobileYouAreOffline
            : e.toString();
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
            SnackBar(
              content: Text(_l10n.tugasDimulaiPetugasLain),
              backgroundColor: SigapColorScheme.of(context).warning,
            ),
          );
        } else {
          showRequestFailure(context, e);
        }
      }
    }
  }

  Future<void> _rejectTask() async {
    final reasonController = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_l10n.tolakTugas),
        content: TextField(
          controller: reasonController,
          decoration: InputDecoration(
            labelText: _l10n.labelAlasanPenolakan,
            hintText: _l10n.hintMasukkanAlasan,
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(_l10n.batal),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, reasonController.text),
            child: Text(_l10n.tolak),
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
        title: Text(_l10n.mintaClarifikasi),
        content: TextField(
          controller: noteController,
          decoration: InputDecoration(
            labelText: _l10n.labelPertanyaanKlarifikasi,
            hintText: _l10n.hintTulisPertanyaan,
          ),
          maxLines: 4,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(_l10n.batal),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, noteController.text),
            child: Text(_l10n.kirim),
          ),
        ],
      ),
    );
    if (note == null || note.isEmpty) return;

    final client = ref.read(apiClientProvider);
    await client.taskAction(widget.taskId!, action: 'clarify', note: note);
  }

  void _navigateToSurveyForm() {
    if (_checklistLabels.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.taskChecklistMissing),
        ),
      );
      return;
    }
    // Build checklist items map from checked indices
    final checklistItems = _checklistLabels.asMap().entries.map((entry) {
      final label = entry.value;
      return SurveyChecklistAnswer(
        item: label,
        status: _checkedChecklistItems.contains(entry.key)
            ? 'completed'
            : 'pending',
      );
    }).toList();

    context.push(
      '/surveyor/form/${widget.taskId}',
      extra: SurveyFormArguments(checklist: checklistItems),
    );
  }

  // ─── Computed properties ────────────────────────────────────────────────────
  List<String> get _checklistLabels {
    final labels =
        _checklistTemplate?.items
            ?.map((item) => item.label ?? '')
            .where((label) => label.isNotEmpty)
            .toList() ??
        <String>[];
    return labels;
  }

  bool _getIsFieldMode(dynamic authState) {
    final role = ((authState?.userRole ?? authState?.activeRole) ?? '')
        .toString()
        .toUpperCase();
    return role == 'PETUGAS';
  }

  String _getStatusLabel(String status) {
    if (!mounted) return status;
    return statusLabel(context, status);
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    ref.listen(offlineModeProvider, (wasOffline, offline) {
      if (wasOffline == true && !offline) {
        if (widget.taskId != null) {
          _loadDetail();
        } else {
          _load();
        }
      }
    });
    _l10n = AppLocalizations.of(context)!;
    if (_sortValue.isEmpty) _sortValue = _l10n.slaTerdekat;

    final authState = ref.watch(authNotifierProvider);
    final isFieldMode = _getIsFieldMode(authState);

    return widget.taskId != null
        ? _buildDetailView(isFieldMode)
        : _buildListView(isFieldMode);
  }

  // ─── List view ─────────────────────────────────────────────────────────────

  Widget _buildListView(bool isFieldMode) {
    final filteredTasks = _applySort(
      _applyFilter(_tasks, _filterIndex),
      _sortValue,
    );
    return Scaffold(
      appBar: MobileTitleBar(
        title: AppLocalizations.of(context)!.mobileTodaySTasks,
        subtitle: AppLocalizations.of(
          context,
        )!.taskSavedSummary(_tasks.length, _downloadedTaskIds.length),
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(
                color: SigapColorScheme.of(context).primary,
              ),
            )
          : _error != null && _tasks.isEmpty
          ? _ErrorRetry(error: _error!, onRetry: _load)
          : _tasks.isEmpty
          ? _buildEmptyState(isFieldMode)
          : Column(
              children: [
                // Filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    children:
                        [
                              AppLocalizations.of(context)!.semua,
                              AppLocalizations.of(context)!.aktifStatus,
                              AppLocalizations.of(context)!.mobileNotSaved,
                              AppLocalizations.of(context)!.taskSubmittedStatus,
                            ]
                            .asMap()
                            .entries
                            .map(
                              (entry) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  showCheckmark: false,
                                  visualDensity: VisualDensity.compact,
                                  labelStyle: TextStyle(fontSize: 11),
                                  shape: StadiumBorder(),
                                  label: Text((entry.value)),
                                  selected: (_filterIndex ?? 0) == entry.key,
                                  onSelected: (_) =>
                                      setState(() => _filterIndex = entry.key),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ),
                // Sort row
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: SigapSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      Text(
                        _l10n.urutkanLabel,
                        style: TextStyle(
                          fontSize: SigapTypography.bodySmall,
                          color: SigapColorScheme.of(context).textTertiary,
                        ),
                      ),
                      DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _sortValue,
                          items: [_l10n.terbaru, _l10n.slaTerdekat].map((
                            option,
                          ) {
                            return DropdownMenuItem<String>(
                              value: option,
                              child: Text(
                                option,
                                style: TextStyle(
                                  fontSize: SigapTypography.bodySmall,
                                  fontWeight: FontWeight.w700,
                                  color: SigapColorScheme.of(
                                    context,
                                  ).textPrimary,
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
                      Spacer(),
                      TextButton(
                        onPressed: _isDownloading
                            ? null
                            : () => _bulkDownload(_tasks),
                        child: Text(
                          AppLocalizations.of(context)!.mobileSaveAll,
                        ),
                      ),
                    ],
                  ),
                ),
                // Task list
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _load,
                    color: SigapColorScheme.of(context).primary,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      itemCount: filteredTasks.length,
                      itemBuilder: (context, index) {
                        final task = filteredTasks[index];
                        final isDownloaded = _downloadedTaskIds.contains(
                          task.id,
                        );
                        final distance = isFieldMode
                            ? _calculateDistance(task.lat, task.lng)
                            : null;
                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: SigapSpacing.md,
                          ),
                          child: _TasksFlowCard(
                            now: now,
                            task: task,
                            isFieldMode: isFieldMode,
                            isDownloaded: isDownloaded,
                            distance: distance,
                            onDownload: isFieldMode && !isDownloaded
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
      bottomNavigationBar: widget.embedded
          ? null
          : AdaptiveNav(
              activeIndex: _selectedNavIndex,
              onTap: (index, route) {
                setState(() {
                  _selectedNavIndex = index;
                });
                context.push(route);
              },
            ),
    );
  }

  Widget _buildEmptyState(bool isFieldMode) {
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
                color: SigapColorScheme.of(context).bgSurface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: SigapColorScheme.of(context).borderCard,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.assignment_outlined,
                size: 36,
                color: SigapColorScheme.of(context).textTertiary,
              ),
            ),
            SizedBox(height: SigapSpacing.md),
            Text(
              _l10n.belumAdaTugas,
              style: TextStyle(
                fontSize: SigapTypography.bodyLarge,
                fontWeight: FontWeight.w700,
                color: SigapColorScheme.of(context).textPrimary,
              ),
            ),
            SizedBox(height: SigapSpacing.xs),
            Text(
              _l10n.tugasPetugasDeskripsi,
              style: TextStyle(
                fontSize: SigapTypography.bodyText,
                color: SigapColorScheme.of(context).textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: SigapSpacing.lg),
            OutlinedButton.icon(
              onPressed: _load,
              icon: Icon(Icons.refresh, size: 18),
              label: Text(_l10n.segarkanData),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Detail view ──────────────────────────────────────────────────────────

  Widget _buildDetailView(bool isFieldMode) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            MobileTitleBar(
              title: _l10n.taskDetailsTitle,
              subtitle: widget.taskId ?? '',
              onBack: () => context.pop(),
            ),
            // Content
            Expanded(
              child: _detailLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: SigapColorScheme.of(context).primary,
                      ),
                    )
                  : _detailError != null && _detail == null
                  ? _ErrorRetry(
                      error: _detailError!,
                      onRetry: _loadDetail,
                      taskId: widget.taskId,
                    )
                  : _buildDetailContent(isFieldMode),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailContent(bool isFieldMode) {
    final detail = _detail;
    if (detail == null) return const SizedBox.shrink();
    final labels = _checklistLabels;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              Chip(
                label: Text(
                  detail.categoryName == null
                      ? AppLocalizations.of(context)!.infrastructureLabel
                      : categoryLabel(context, detail.categoryName!),
                ),
              ),
              Chip(label: Text(_getStatusLabel(detail.status ?? ''))),
            ],
          ),
          SizedBox(height: 12),
          Text(
            detail.reportTitle ??
                AppLocalizations.of(context)!.infrastructureReportLabel,
            style: TextStyle(
              fontSize: 20,
              height: 1.4,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 18),
          if (detail.address?.trim().isNotEmpty == true ||
              (detail.lat != null && detail.lng != null)) ...[
            Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                leading: const Icon(Icons.location_on_outlined),
                title: Text(
                  detail.address?.trim().isNotEmpty == true
                      ? detail.address!
                      : '${detail.lat!.toStringAsFixed(5)}, ${detail.lng!.toStringAsFixed(5)}',
                ),
                subtitle:
                    detail.address?.trim().isNotEmpty == true &&
                        detail.lat != null &&
                        detail.lng != null
                    ? Text(
                        '${detail.lat!.toStringAsFixed(5)}, ${detail.lng!.toStringAsFixed(5)}',
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 18),
          ],
          Text(_l10n.taskLocationExplanation),
          const SizedBox(height: 18),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _l10n.taskInstructions,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    detail.description?.isNotEmpty == true
                        ? detail.description!
                        : _l10n.taskInstructionsMissing,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 18),
          Text(
            _l10n.taskRequiredChecklist,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 8),
          if (labels.isEmpty) Text(_l10n.taskChecklistMissing),
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: labels
                  .asMap()
                  .entries
                  .map(
                    (entry) => CheckboxListTile(
                      dense: true,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Text(_localizedChecklistLabel(entry.value)),
                      value: _checkedChecklistItems.contains(entry.key),
                      onChanged: (checked) async {
                        setState(() {
                          if (checked == true) {
                            _checkedChecklistItems.add(entry.key);
                          } else {
                            _checkedChecklistItems.remove(entry.key);
                          }
                        });
                        await _cache.saveChecklist(
                          widget.taskId!,
                          _checkedChecklistItems,
                        );
                      },
                    ),
                  )
                  .toList(),
            ),
          ),
          SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.mobileCitizenEvidence,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                _l10n.taskPhotoCount(_reportPhotos.length),
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
          SizedBox(height: 10),
          if (_photoLoadFailed)
            TextButton.icon(
              onPressed: _loadDetail,
              icon: const Icon(Icons.refresh),
              label: Text(_l10n.taskPhotosLoadFailed),
            )
          else if (_reportPhotos.isEmpty)
            Text(AppLocalizations.of(context)!.mobileNoCitizenPhotosYet)
          else
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _reportPhotos.length,
                separatorBuilder: (_, __) => SizedBox(width: 8),
                itemBuilder: (_, index) => InkWell(
                  onTap: () => _showPhotoFullScreen(_reportPhotos, index),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      Uri.parse(
                        ApiConfig.baseUrl,
                      ).resolve(_reportPhotos[index]).toString(),
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => SizedBox(
                        width: 100,
                        child: Icon(Icons.image_not_supported_outlined),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 10),
          Text(_l10n.taskEvidenceExplanation),
          SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            color: SigapColorScheme.of(context).bgSoft,
            child: Text(
              _isDownloaded
                  ? _l10n.taskSavedPhotosOnline
                  : _l10n.taskSavePreparation,
            ),
          ),
          if (detail.visits.isNotEmpty) ...[
            SizedBox(height: 18),
            Text(
              _l10n.taskSurveyResults,
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(_l10n.taskResultsExplanation),
            ...detail.visits.map(_surveyResult),
          ],
          SizedBox(height: 18),
          _buildActionBar(isFieldMode),
        ],
      ),
    );
  }

  void _showPhotoFullScreen(List<String> photos, int index) {
    PhotoFullScreen.show(
      context,
      photos
          .map((url) => Uri.parse(ApiConfig.baseUrl).resolve(url).toString())
          .toList(),
      index,
    );
  }

  String _formatDimensions(SurveyDimensions dimensions) {
    final unit = dimensions.unit == null ? '' : ' ${dimensions.unit}';
    return [
      if (dimensions.length != null)
        '${_l10n.taskLength}: ${dimensions.length}$unit',
      if (dimensions.width != null)
        '${_l10n.taskWidth}: ${dimensions.width}$unit',
      if (dimensions.height != null)
        '${_l10n.taskHeight}: ${dimensions.height}$unit',
      if (dimensions.depth != null)
        '${_l10n.taskDepth}: ${dimensions.depth}$unit',
    ].join('\n');
  }

  String _localizedChecklistLabel(String canonical) {
    if (Localizations.localeOf(context).languageCode != 'en') return canonical;
    for (final item in _checklistTemplate?.items ?? <ChecklistItem>[]) {
      if (item.label == canonical) return item.labelEn ?? canonical;
    }
    return canonical;
  }

  Widget _surveyResult(SurveyVisit visit) {
    Widget field(String label, String? value) => value == null || value.isEmpty
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Text(value, style: const TextStyle(height: 1.5)),
              ],
            ),
          );
    return Card(
      margin: const EdgeInsets.only(top: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            field(_l10n.taskFindings, visit.findings),
            field(
              _l10n.taskMeasurements,
              visit.measuredDimensions == null
                  ? visit.dimensions
                  : _formatDimensions(visit.measuredDimensions!),
            ),
            field(_l10n.taskRecommendation, visit.recommendation),
            field(_l10n.taskNotes, visit.notes),
            if (visit.photoUrls.isNotEmpty) ...[
              Text(
                _l10n.taskSurveyPhotos,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: visit.photoUrls
                    .asMap()
                    .entries
                    .map(
                      (entry) => InkWell(
                        onTap: () =>
                            _showPhotoFullScreen(visit.photoUrls, entry.key),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            Uri.parse(
                              ApiConfig.baseUrl,
                            ).resolve(entry.value).toString(),
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.broken_image_outlined),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionBar(bool isFieldMode) {
    if (_detail == null) return const SizedBox.shrink();
    final status = _detail!.status;
    if (status == 'completed') {
      return Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          _detail!.reportStatus == 'resolved' ||
                  _detail!.reportStatus == 'closed'
              ? _l10n.taskResolved
              : _l10n.taskAwaitingReview,
        ),
      );
    }
    if (status == 'rejected') return const SizedBox.shrink();
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.zero,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  if (status == 'in_progress') {
                    _navigateToSurveyForm();
                    return;
                  }
                  await _doAction(() async {
                    final client = ref.read(apiClientProvider);
                    if (status == 'assigned') {
                      await client.taskAction(widget.taskId!, action: 'accept');
                    }
                    await client.taskAction(widget.taskId!, action: 'start');
                    if (mounted) _navigateToSurveyForm();
                  });
                },
                child: Text(
                  status == 'in_progress'
                      ? AppLocalizations.of(context)!.taskContinueSurvey
                      : AppLocalizations.of(context)!.mobileAcceptStartSurvey,
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _requestClarification,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 48),
                      textStyle: Theme.of(
                        context,
                      ).textTheme.labelLarge?.copyWith(fontSize: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.mobileRequestClarification,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _rejectTask,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: SigapColorScheme.of(context).danger,
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.mobileDeclineTask,
                    ),
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

  final String? instructions;
  final String? unitName;

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

    this.instructions,
    this.unitName,
  });

  factory _TaskItem.fromTask(dynamic t, bool isFieldMode) {
    // Parse ISO date string to DateTime
    DateTime? parseDate(String? s) {
      if (s == null) return null;
      return DateTime.tryParse(s);
    }

    // Only PetugasTask type supported
    final task = t as PetugasTask;
    return _TaskItem(
      id: task.taskId ?? '',
      title: task.reportTitle ?? '-',
      description: task.reportDescription,
      status: task.status ?? '',
      createdAt: task.createdAt ?? parseDate(task.assignedAt),
      deadline: parseDate(task.deadline),
      categoryName: task.categoryName,
      address: task.address,
      progressPercent: task.progressPercent,
      severity: task.severity,
      lat: task.lat,
      lng: task.lng,

      instructions: task.instructions,
      unitName: task.unitName,
    );
  }
}

class _TasksFlowCard extends StatelessWidget {
  final DateTime now;
  final _TaskItem task;
  final bool isFieldMode;
  final VoidCallback onTap;
  final bool isDownloaded;
  final VoidCallback? onDownload;
  final String? distance;

  const _TasksFlowCard({
    required this.now,
    required this.task,
    required this.isFieldMode,
    required this.onTap,
    this.isDownloaded = false,
    this.onDownload,
    this.distance,
  });

  String _slaLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (task.deadline == null) return '';
    final hours = task.deadline!.difference(now).inHours;
    if (hours < 0) {
      final overdueHours = hours.abs();
      return l10n.terlambatXjam(overdueHours);
    } else if (hours < 24) {
      return l10n.slaXjam(hours);
    } else if (hours < 48) {
      return l10n.slaBesok;
    } else {
      final days = (hours / 24).ceil();
      return l10n.slaXhari(days);
    }
  }

  /// Background color for SLA badge per design spec
  Color _slaTextColor(BuildContext context) {
    if (task.deadline == null) return SigapColorScheme.of(context).textTertiary;
    final hours = task.deadline!.difference(now).inHours;
    if (hours < 0) {
      return SigapColorScheme.of(
        context,
      ).dangerTextStrong; // red text - Terlambat
    } else if (hours < 24) {
      return SigapColorScheme.of(context).warningText; // amber text - SLA today
    } else if (hours < 48) {
      return SigapColorScheme.of(
        context,
      ).textSecondary; // gray text - SLA besok
    } else {
      return SigapColorScheme.of(context).warningText; // amber for future
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = task.progressPercent;
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: (task.severity ?? 0) >= 75
              ? SigapColorScheme.of(context).danger
              : SigapColorScheme.of(context).borderCard,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: onTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          ('TGS-${task.id.toUpperCase()}'),
                          style: TextStyle(
                            fontSize: 11,
                            fontFamily: SigapTypography.fontFamilyMono,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          task.status == 'completed'
                              ? AppLocalizations.of(
                                  context,
                                )!.taskSubmittedStatus
                              : _slaLabel(context),
                          style: TextStyle(
                            fontSize: 11,
                            color: _slaTextColor(context),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    task.title,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '⌖ ${task.address ?? (task.lat != null && task.lng != null ? '${task.lat!.toStringAsFixed(4)}, ${task.lng!.toStringAsFixed(4)}' : AppLocalizations.of(context)!.lokasiTidakTersedia)} · ${task.categoryName == null ? AppLocalizations.of(context)!.survei : categoryLabel(context, task.categoryName!)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: SigapColorScheme.of(context).textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          task.unitName ??
                              AppLocalizations.of(context)!.fieldWorkerLabel,
                          style: TextStyle(
                            fontSize: 12,
                            color: SigapColorScheme.of(context).textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (progress != null)
                        Flexible(
                          child: Text(
                            '$progress%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 8),
                  if (progress != null)
                    LinearProgressIndicator(
                      value: (progress / 100).clamp(0.0, 1.0),
                      minHeight: 5,
                      color: SigapColorScheme.of(context).primary,
                      backgroundColor: SigapColorScheme.of(context).borderCard,
                    ),
                ],
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${AppLocalizations.of(context)!.mobileDue}: ${task.deadline == null ? AppLocalizations.of(context)!.mobileNotSet : DateFormat.yMd(AppLocalizations.of(context)!.localeName).format(task.deadline!.toLocal())}',
                    style: TextStyle(fontSize: 11),
                  ),
                ),
                if (isDownloaded)
                  Text(
                    AppLocalizations.of(context)!.mobileAvailableLocally,
                    style: TextStyle(
                      fontSize: 11,
                      color: SigapColorScheme.of(context).primary,
                    ),
                  )
                else
                  TextButton(
                    onPressed: onDownload,
                    child: Text(AppLocalizations.of(context)!.mobileSaveTask),
                  ),
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
            color: SigapColorScheme.of(context).bgCard,
            borderRadius: BorderRadius.circular(SigapRadius.lg),
            border: Border.all(color: SigapColorScheme.of(context).borderCard),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 52,
                color: SigapColorScheme.of(context).perluTindakan,
              ),
              SizedBox(height: SigapSpacing.md),
              Text(
                taskId != null
                    ? AppLocalizations.of(context)!.gagalMemuatDetailTugas
                    : AppLocalizations.of(context)!.gagalMemuatTugasTitle,
                style: TextStyle(
                  fontSize: SigapTypography.bodyLarge,
                  fontWeight: FontWeight.w700,
                  color: SigapColorScheme.of(context).textPrimary,
                ),
              ),
              SizedBox(height: SigapSpacing.xs),
              RequestErrorDetails(details: error),
              SizedBox(height: SigapSpacing.lg),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: Icon(Icons.refresh, size: 18),
                label: Text(AppLocalizations.of(context)!.cobaLagi),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SigapColorScheme.of(context).primary,
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

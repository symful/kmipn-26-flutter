import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../api/exceptions.dart';
import '../../providers/providers.dart';
import '../../theme/tokens.dart';
import '../../components/app_icons.dart';

/// Screen S-02: Surveyor Detail Tugas
/// Displays report details, checklist template, and accept/start buttons.
class SurveyorDetailTugasScreen extends ConsumerStatefulWidget {
  final String taskId;

  const SurveyorDetailTugasScreen({super.key, required this.taskId});

  @override
  ConsumerState<SurveyorDetailTugasScreen> createState() =>
      _SurveyorDetailTugasScreenState();
}

class _SurveyorDetailTugasScreenState
    extends ConsumerState<SurveyorDetailTugasScreen> {
  Map<String, dynamic>? _task;
  List<Map<String, dynamic>> _checklistItems = [];
  bool _loading = true;
  String? _error;
  bool _accepting = false;
  bool _starting = false;

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
      final data = await client.surveyorGetTaskDetail(widget.taskId);
      final checklistTemplate =
          data['checklist_template'] as List? ??
          data['checklist'] as List? ??
          [];

      setState(() {
        _task = data;
        _checklistItems = checklistTemplate.cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _acceptTask() async {
    setState(() {
      _accepting = true;
      _error = null;
    });

    try {
      final client = ref.read(apiClientProvider);
      await client.surveyorAcceptTask(widget.taskId);
      setState(() {
        _accepting = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tugas berhasil diterima!')),
        );
        // Refresh to show updated status
        _load();
      }
    } catch (e) {
      setState(() {
        _error = extractErrorMessage(e);
        _accepting = false;
      });
    }
  }

  Future<void> _startSurvey() async {
    setState(() {
      _starting = true;
      _error = null;
    });

    try {
      final client = ref.read(apiClientProvider);
      await client.surveyorStartTask(widget.taskId);
      setState(() {
        _starting = false;
      });
      if (mounted) {
        // Navigate to the survey execution screen
        context.push('/surveyor/tasks/${widget.taskId}');
      }
    } catch (e) {
      setState(() {
        _error = extractErrorMessage(e);
        _starting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Tugas')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null && _task == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Tugas')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppIcons.error,
              const SizedBox(height: AppSpacing.md),
              Text('Gagal memuat: $_error'),
              const SizedBox(height: AppSpacing.md),
              ElevatedButton(onPressed: _load, child: const Text('Coba Lagi')),
            ],
          ),
        ),
      );
    }

    final task = _task!;
    final title = task['title'] as String? ?? '-';
    final description = task['description'] as String? ?? '-';
    final instructions = task['instructions'] as String? ?? '';
    final status = task['status'] as String? ?? 'pending';
    final category = task['category'] as Map<String, dynamic>?;
    final location = task['location'] as Map<String, dynamic>?;
    final photoUrls = task['photo_urls'] as List?;
    final createdAt = task['created_at'] as String?;

    // Determine task state for button visibility
    final isPending = status.toLowerCase() == 'pending';
    final isAssigned = status.toLowerCase() == 'assigned';
    final canAccept = isPending;
    final canStart = isAssigned || status.toLowerCase() == 'accepted';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Tugas'),
        leading: IconButton(
          icon: AppIcons.arrowBack,
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                // Report Details Card
                _SectionCard(
                  title: 'Detail Laporan',
                  icon: AppIcons.reportFilled,
                  children: [
                    // Photo
                    if (photoUrls != null && photoUrls.isNotEmpty) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        child: Image.network(
                          photoUrls.first.toString(),
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: double.infinity,
                            height: 200,
                            color: AppColors.bgSurface,
                            child: const Icon(
                              Icons.image_not_supported,
                              size: 48,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],

                    // Title
                    _DetailRow(
                      label: 'Judul',
                      value: title,
                      icon: AppIcons.report,
                    ),
                    const Divider(height: AppSpacing.lg),

                    // Category
                    _DetailRow(
                      label: 'Kategori',
                      value: category?['name'] as String? ?? '-',
                      icon: AppIcons.categoryFilled,
                    ),
                    const Divider(height: AppSpacing.lg),

                    // Location
                    _DetailRow(
                      label: 'Lokasi',
                      value: location != null
                          ? '${location['address'] ?? '-'} (${location['lat'] ?? 0}, ${location['lng'] ?? 0})'
                          : '-',
                      icon: AppIcons.location,
                    ),
                    const Divider(height: AppSpacing.lg),

                    // Description
                    _DetailRow(
                      label: 'Deskripsi',
                      value: description,
                      icon: AppIcons.report,
                      isMultiLine: true,
                    ),

                    // Timestamp
                    if (createdAt != null) ...[
                      const Divider(height: AppSpacing.lg),
                      _DetailRow(
                        label: 'Dibuat',
                        value: _formatDateTime(createdAt),
                        icon: AppIcons.timer,
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: AppSpacing.lg),

                // Checklist Template Section
                _SectionCard(
                  title: 'Checklist Survei',
                  icon: AppIcons.list,
                  children: [
                    if (_checklistItems.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(AppSpacing.md),
                        child: Text(
                          'Tidak ada item checklist',
                          style: TextStyle(
                            color: AppColors.textTertiary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      )
                    else
                      ...List.generate(_checklistItems.length, (index) {
                        final item = _checklistItems[index];
                        final label =
                            item['label'] as String? ??
                            item['name'] as String? ??
                            'Item ${index + 1}';
                        final required =
                            item['required'] == true ||
                            item['is_required'] == true;

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.sm,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.sm,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Text(
                                  label + (required ? ' *' : ''),
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 14,
                                    decoration: required
                                        ? TextDecoration.none
                                        : TextDecoration.none,
                                  ),
                                ),
                              ),
                              if (required)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.warningBg,
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.sm,
                                    ),
                                  ),
                                  child: const Text(
                                    'Wajib',
                                    style: TextStyle(
                                      color: AppColors.warning,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),

                const SizedBox(height: AppSpacing.lg),

                // Instructions Section
                if (instructions.isNotEmpty)
                  _SectionCard(
                    title: 'Instruksi',
                    icon: AppIcons.infoFilled,
                    children: [
                      Text(
                        instructions,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // Bottom Action Buttons
          Container(
            padding: EdgeInsets.only(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              top: AppSpacing.md,
              bottom: MediaQuery.of(context).padding.bottom + AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              boxShadow: [
                BoxShadow(
                  color: AppColors.textPrimary.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Text(
                      'Error: $_error',
                      style: const TextStyle(
                        color: AppColors.danger,
                        fontSize: 12,
                      ),
                    ),
                  ),
                if (canAccept)
                  ElevatedButton(
                    onPressed: _accepting ? null : _acceptTask,
                    child: _accepting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Terima Tugas'),
                  ),
                if (canStart) ...[
                  ElevatedButton(
                    onPressed: _starting ? null : _startSurvey,
                    child: _starting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Mulai Survei'),
                  ),
                ],
                if (!canAccept && !canStart)
                  ElevatedButton(
                    onPressed: null,
                    child: Text(_getStatusLabel(status)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(String isoString) {
    try {
      final dt = DateTime.parse(isoString);
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return isoString;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Menunggu';
      case 'assigned':
        return 'Ditugaskan';
      case 'accepted':
        return 'Diterima';
      case 'in_progress':
        return 'Sedang Dikerjakan';
      case 'completed':
        return 'Selesai';
      default:
        return status;
    }
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget icon;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: const BorderSide(color: AppColors.borderCard),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                icon,
                const SizedBox(width: AppSpacing.sm),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Widget icon;
  final bool isMultiLine;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.icon,
    this.isMultiLine = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: isMultiLine
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        IconTheme(
          data: const IconThemeData(color: AppColors.textTertiary, size: 18),
          child: icon,
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

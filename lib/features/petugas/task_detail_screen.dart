import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/providers.dart';
import '../../theme/tokens.dart';
import '../../utils/logger.dart';

final _logger = Logger('PetugasTaskDetailScreen');

class PetugasTaskDetailScreen extends ConsumerStatefulWidget {
  final String taskId;
  const PetugasTaskDetailScreen({super.key, required this.taskId});

  @override
  ConsumerState<PetugasTaskDetailScreen> createState() =>
      _PetugasTaskDetailScreenState();
}

class _PetugasTaskDetailScreenState
    extends ConsumerState<PetugasTaskDetailScreen> {
  Map<String, dynamic>? _task;
  bool _loading = true;
  String? _error;

  // Task status
  String? _taskStatus; // pending, accepted, in_progress, completed, rejected

  // Progress
  double _progress = 0;
  final _notesController = TextEditingController();
  DateTime? _estimatedCompletion;

  // Photo evidence
  final List<String> _evidencePhotos = [];

  // Completion
  final _summaryController = TextEditingController();
  final List<String> _completionPhotos = [];

  // Clarification
  final _clarificationController = TextEditingController();

  bool _submitting = false;
  String? _submitError;
  bool _success = false;

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
      final data = await client.get('/api/petugas/tasks/${widget.taskId}');
      setState(() {
        _task = data;
        _taskStatus = data['status'] as String?;
        _progress = (data['progress_percent'] as num?)?.toDouble() ?? 0;
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
    setState(() => _submitting = true);
    try {
      final client = ref.read(apiClientProvider);
      await client.petugasAcceptTask(widget.taskId);
      setState(() {
        _taskStatus = 'accepted';
        _submitting = false;
      });
      _load();
    } catch (e) {
      setState(() {
        _submitError = e.toString();
        _submitting = false;
      });
    }
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
            labelText: 'Alasan penolakan (WAJIB)',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isNotEmpty) {
                Navigator.pop(ctx, reasonController.text.trim());
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: SigapColors.perluTindakan,
            ),
            child: const Text('Tolak'),
          ),
        ],
      ),
    );
    if (reason == null) return;
    setState(() => _submitting = true);
    try {
      final client = ref.read(apiClientProvider);
      await client.petugasRejectTask(widget.taskId, reason);
      setState(() {
        _taskStatus = 'rejected';
        _submitting = false;
      });
    } catch (e) {
      setState(() {
        _submitError = e.toString();
        _submitting = false;
      });
    }
  }

  Future<void> _saveProgress() async {
    setState(() => _submitting = true);
    try {
      final client = ref.read(apiClientProvider);
      await client.petugasUpdateProgress(
        taskId: widget.taskId,
        progressPercent: _progress.round(),
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
        estimatedCompletion: _estimatedCompletion?.toIso8601String(),
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Progress disimpan')));
      }
    } catch (e) {
      setState(() => _submitError = e.toString());
    } finally {
      setState(() => _submitting = false);
    }
  }

  Future<void> _pickEvidencePhoto(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, maxWidth: 1200);
    if (picked != null) {
      setState(() => _evidencePhotos.add(picked.path));
    }
  }

  Future<void> _uploadEvidence() async {
    if (_evidencePhotos.isEmpty) return;
    setState(() => _submitting = true);
    try {
      final client = ref.read(apiClientProvider);
      await client.petugasUploadEvidence(
        widget.taskId,
        _evidencePhotos,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bukti foto berhasil diupload')),
        );
      }
    } catch (e) {
      setState(() => _submitError = e.toString());
    } finally {
      setState(() => _submitting = false);
    }
  }

  Future<void> _pickCompletionPhoto(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, maxWidth: 1200);
    if (picked != null) {
      setState(() => _completionPhotos.add(picked.path));
    }
  }

  Future<void> _markComplete() async {
    if (_summaryController.text.trim().isEmpty || _completionPhotos.isEmpty) {
      setState(() => _submitError = 'Summary dan foto bukti WAJIB');
      return;
    }
    setState(() => _submitting = true);
    try {
      final client = ref.read(apiClientProvider);
      await client.petugasCompleteTask(
        widget.taskId,
        summary: _summaryController.text.trim(),
        photoPaths: _completionPhotos,
      );
      setState(() {
        _taskStatus = 'completed';
        _success = true;
        _submitting = false;
      });
    } catch (e) {
      setState(() => _submitError = e.toString());
      _submitting = false;
    }
  }

  Future<void> _requestClarification() async {
    final questionController = TextEditingController();
    final question = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Minta Klarifikasi'),
        content: TextField(
          controller: questionController,
          decoration: const InputDecoration(
            labelText: 'Pertanyaan (WAJIB)',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (questionController.text.trim().isNotEmpty) {
                Navigator.pop(ctx, questionController.text.trim());
              }
            },
            child: const Text('Kirim'),
          ),
        ],
      ),
    );
    if (question == null) return;
    setState(() => _submitting = true);
    try {
      final client = ref.read(apiClientProvider);
      await client.petugasRequestClarification(
        widget.taskId,
        question: question,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permintaan klarifikasi dikirim')),
        );
      }
    } catch (e) {
      setState(() => _submitError = e.toString());
    } finally {
      setState(() => _submitting = false);
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _summaryController.dispose();
    _clarificationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_success) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tugas Petugas')),
        body: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: SigapColors.selesai, size: 64),
              SizedBox(height: 16),
              Text(
                'Tugas selesai!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
    }

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
              const Icon(
                Icons.error_outline,
                size: 64,
                color: SigapColors.perluTindakan,
              ),
              const SizedBox(height: 16),
              Text('Gagal memuat: $_error'),
              ElevatedButton(onPressed: _load, child: const Text('Coba Lagi')),
            ],
          ),
        ),
      );
    }

    final task = _task!;
    final isPending = _taskStatus == 'pending';
    final isActive = _taskStatus == 'accepted' || _taskStatus == 'in_progress';
    final canComplete = isActive && _taskStatus != 'completed';

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Tugas')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(SigapSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ──────────────────────────────────────────────────────
            _TaskHeader(task: task),
            const SizedBox(height: SigapSpacing.lg),

            // ── Accept / Reject ────────────────────────────────────────────
            if (isPending) ...[
              _SectionTitle(title: 'Tindakan'),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _submitting ? null : _rejectTask,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: SigapColors.perluTindakan,
                        side: const BorderSide(
                          color: SigapColors.perluTindakan,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Tolak'),
                    ),
                  ),
                  const SizedBox(width: SigapSpacing.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submitting ? null : _acceptTask,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SigapColors.selesai,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: _submitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Terima'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SigapSpacing.lg),
            ],

            // ── Progress ───────────────────────────────────────────────────
            if (isActive) ...[
              _SectionTitle(title: 'Update Progress'),
              Container(
                padding: const EdgeInsets.all(SigapSpacing.md),
                decoration: BoxDecoration(
                  color: SigapColors.surface,
                  borderRadius: BorderRadius.circular(SigapRadius.md),
                  border: Border.all(color: SigapColors.border),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Text('Progress: '),
                        Text(
                          '${_progress.round()}%',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: _progressColor,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: _progress,
                      min: 0,
                      max: 100,
                      divisions: 20,
                      label: '${_progress.round()}%',
                      onChanged: (v) => setState(() => _progress = v),
                    ),
                    TextField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Catatan progress',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: SigapSpacing.sm),
                    Row(
                      children: [
                        Text(
                          _estimatedCompletion == null
                              ? 'Estimasi selesai: (belum)'
                              : 'Estimasi: ${_estimatedCompletion!.toLocal().toString().split(' ')[0]}',
                          style: const TextStyle(fontSize: 13),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          icon: const Icon(Icons.calendar_today, size: 16),
                          label: const Text('Atur'),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate:
                                  _estimatedCompletion ??
                                  DateTime.now().add(const Duration(days: 7)),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(
                                const Duration(days: 365),
                              ),
                            );
                            if (picked != null) {
                              setState(() => _estimatedCompletion = picked);
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: SigapSpacing.sm),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitting ? null : _saveProgress,
                        child: const Text('Simpan Progress'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: SigapSpacing.lg),
            ],

            // ── Photo Evidence ─────────────────────────────────────────────
            if (isActive) ...[
              _SectionTitle(title: 'Bukti Foto'),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _pickEvidencePhoto(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt, size: 18),
                    label: const Text('Kamera'),
                  ),
                  const SizedBox(width: SigapSpacing.sm),
                  OutlinedButton.icon(
                    onPressed: () => _pickEvidencePhoto(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library, size: 18),
                    label: const Text('Galeri'),
                  ),
                ],
              ),
              if (_evidencePhotos.isNotEmpty) ...[
                const SizedBox(height: SigapSpacing.sm),
                Wrap(
                  spacing: SigapSpacing.xs,
                  runSpacing: SigapSpacing.xs,
                  children: _evidencePhotos.asMap().entries.map((e) {
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(SigapRadius.sm),
                          child: Image.file(
                            File(e.value),
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: GestureDetector(
                            onTap: () => setState(() {
                              _evidencePhotos.removeAt(e.key);
                            }),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: SigapColors.perluTindakan,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
                const SizedBox(height: SigapSpacing.sm),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitting ? null : _uploadEvidence,
                    child: const Text('Upload Bukti Foto'),
                  ),
                ),
              ],
              const SizedBox(height: SigapSpacing.lg),
            ],

            // ── Completion ────────────────────────────────────────────────
            if (canComplete) ...[
              _SectionTitle(title: 'Selesai'),
              Container(
                padding: const EdgeInsets.all(SigapSpacing.md),
                decoration: BoxDecoration(
                  color: SigapColors.selesai.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(SigapRadius.md),
                  border: Border.all(
                    color: SigapColors.selesai.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _summaryController,
                      decoration: const InputDecoration(
                        labelText: 'Ringkasan pekerjaan (WAJIB)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: SigapSpacing.sm),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () =>
                              _pickCompletionPhoto(ImageSource.camera),
                          icon: const Icon(Icons.camera_alt, size: 18),
                          label: const Text('Kamera'),
                        ),
                        const SizedBox(width: SigapSpacing.sm),
                        OutlinedButton.icon(
                          onPressed: () =>
                              _pickCompletionPhoto(ImageSource.gallery),
                          icon: const Icon(Icons.photo_library, size: 18),
                          label: const Text('Galeri'),
                        ),
                      ],
                    ),
                    if (_completionPhotos.isNotEmpty) ...[
                      const SizedBox(height: SigapSpacing.sm),
                      Wrap(
                        spacing: SigapSpacing.xs,
                        runSpacing: SigapSpacing.xs,
                        children: _completionPhotos.asMap().entries.map((e) {
                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  SigapRadius.sm,
                                ),
                                child: Image.file(
                                  File(e.value),
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: GestureDetector(
                                  onTap: () => setState(() {
                                    _completionPhotos.removeAt(e.key);
                                  }),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: SigapColors.perluTindakan,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: SigapSpacing.md),
                    ElevatedButton(
                      onPressed: _submitting ? null : _markComplete,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SigapColors.selesai,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Tandai Selesai'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: SigapSpacing.lg),
            ],

            // ── Clarification ─────────────────────────────────────────────
            if (isActive) ...[
              OutlinedButton.icon(
                onPressed: _submitting ? null : _requestClarification,
                icon: const Icon(Icons.help_outline),
                label: const Text('Minta Klarifikasi'),
              ),
              const SizedBox(height: SigapSpacing.lg),
            ],

            // ── Error ─────────────────────────────────────────────────────
            if (_submitError != null)
              Container(
                padding: const EdgeInsets.all(SigapSpacing.md),
                decoration: BoxDecoration(
                  color: SigapColors.perluTindakan.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(SigapRadius.sm),
                ),
                child: Text(
                  'Error: $_submitError',
                  style: const TextStyle(
                    color: SigapColors.perluTindakan,
                    fontSize: 13,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color get _progressColor {
    if (_progress >= 80) return SigapColors.selesai;
    if (_progress >= 40) return SigapColors.offlineDot;
    return SigapColors.perluTindakan;
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: SigapSpacing.sm),
      child: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _TaskHeader extends StatelessWidget {
  final Map<String, dynamic> task;
  const _TaskHeader({required this.task});

  @override
  Widget build(BuildContext context) {
    final title = task['title'] as String? ?? '-';
    final instructions = task['instructions'] as String? ?? '-';
    final status = task['status'] as String? ?? '-';
    final deadline = task['deadline'] as String?;
    final assignedAt = task['assigned_at'] as String?;

    return Container(
      padding: const EdgeInsets.all(SigapSpacing.md),
      decoration: BoxDecoration(
        color: SigapColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(SigapRadius.md),
        border: Border.all(color: SigapColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: SigapSpacing.sm),
          Text(
            instructions,
            style: TextStyle(fontSize: 13, color: SigapColors.textSecondary),
          ),
          const SizedBox(height: SigapSpacing.sm),
          Wrap(
            spacing: SigapSpacing.sm,
            runSpacing: SigapSpacing.xs,
            children: [
              _Chip(label: status, color: _statusColor(status)),
              if (deadline != null)
                _Chip(
                  label: 'Deadline: ${_formatDate(deadline)}',
                  color: SigapColors.offlineDot,
                ),
              if (assignedAt != null)
                _Chip(
                  label: 'Assigned: ${_formatDate(assignedAt)}',
                  color: SigapColors.diproses,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Color _statusColor(String s) {
    switch (s.toLowerCase()) {
      case 'pending':
        return SigapColors.offlineDot;
      case 'accepted':
      case 'in_progress':
        return SigapColors.diproses;
      case 'completed':
        return SigapColors.selesai;
      case 'rejected':
        return SigapColors.perluTindakan;
      default:
        return SigapColors.textMuted;
    }
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (e, s) {
      _logger.warning('Error parsing date', e, s);
      return iso;
    }
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SigapSpacing.sm,
        vertical: SigapSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(SigapRadius.sm),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

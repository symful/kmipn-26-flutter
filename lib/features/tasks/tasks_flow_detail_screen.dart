import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../api/types.g.dart';
import '../../providers/providers.dart';
import '../../theme/tokens.dart';
import '../../widgets/design_system/phone_frame.dart';
import '../surveyor/presentation/widgets/s02_action_bar.dart';

/// Unified TasksFlow Detail Screen for both SURVEYOR and PETUGAS roles.
///
/// Role determines:
/// - Which action buttons to show in the bottom bar
/// - Which API methods to call for actions
///
/// SURVEYOR actions: Terima, Kunjungi (→ survey_form_screen), Tolak, Minta Clarifikasi
/// PETUGAS actions: Terima, Progress, Evidence, Selesaikan, Tolak, Minta Clarifikasi
class TasksFlowDetailScreen extends ConsumerStatefulWidget {
  final String role;
  final String taskId;

  const TasksFlowDetailScreen({
    super.key,
    required this.role,
    required this.taskId,
  });

  @override
  ConsumerState<TasksFlowDetailScreen> createState() =>
      _TasksFlowDetailScreenState();
}

class _TasksFlowDetailScreenState extends ConsumerState<TasksFlowDetailScreen> {
  bool _loading = true;
  String? _error;
  TaskDetail? _detail;

  @override
  void initState() {
    super.initState();
    _load();
  }

  bool get _isSurveyor => widget.role == 'surveyor';

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final client = ref.read(apiClientProvider);
      final detail = await client.getTaskDetail(widget.taskId);
      setState(() {
        _detail = detail;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _doAction(Future<void> Function() action) async {
    try {
      await action();
      await _load(); // Refresh detail
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal: $e')));
      }
    }
  }

  Future<void> _acceptTask() async {
    await _doAction(() async {
      final client = ref.read(apiClientProvider);
      await client.acceptTask(widget.taskId);
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
    await client.rejectTask(widget.taskId, reason);
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
    await client.requestClarification(widget.taskId, question: note);
  }

  void _navigateToSurveyForm() {
    context.push('/surveyor/survey-form/${widget.taskId}');
  }

  Color get _statusColor {
    final s = (_detail?.status ?? '').toLowerCase();
    switch (s) {
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

  String get _statusLabel {
    final s = (_detail?.status ?? '').toLowerCase();
    switch (s) {
      case 'pending':
        return 'Baru';
      case 'assigned':
        return 'Ditugaskan';
      case 'in_progress':
        return 'Dikerjakan';
      case 'completed':
      case 'resolved':
        return 'Selesai';
      case 'rejected':
        return 'Ditolak';
      default:
        return _detail?.status ?? '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    return PhoneFrame(
      child: Scaffold(
        backgroundColor: SigapColors.bgSurface,
        body: SafeArea(
          child: Column(
            children: [
              // Header bar with back
              Container(
                height: 56,
                padding: const EdgeInsets.symmetric(
                  horizontal: SigapSpacing.md,
                ),
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
                        _isSurveyor
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
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: SigapColors.primary,
                        ),
                      )
                    : _error != null && _detail == null
                    ? _ErrorRetry(error: _error!, onRetry: _load)
                    : _buildContent(),
              ),

              // Action bar
              _buildActionBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
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
              color: _statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(SigapRadius.sm),
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
              fontFamily: 'IBM Plex Mono',
              fontSize: SigapTypography.size11,
              color: SigapColors.textTertiary,
            ),
          ),
          const SizedBox(height: SigapSpacing.lg),

          // Description
          if (detail.description != null && detail.description!.isNotEmpty) ...[
            const Text(
              'Deskripsi',
              style: TextStyle(
                fontSize: SigapTypography.size13,
                fontWeight: FontWeight.w600,
                color: SigapColors.textSecondary,
              ),
            ),
            const SizedBox(height: SigapSpacing.xs),
            Text(
              detail.description!,
              style: const TextStyle(
                fontSize: SigapTypography.size13,
                color: SigapColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: SigapSpacing.lg),
          ],

          // Progress (for petugas)
          if (!_isSurveyor && detail.progress != null) ...[
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
        ],
      ),
    );
  }

  Widget _buildActionBar() {
    if (_detail == null) return const SizedBox.shrink();

    final status = (_detail?.status ?? '').toLowerCase();
    final isAssigned = status == 'assigned';
    final isPending = status == 'pending';

    if (_isSurveyor) {
      return S02ActionBar(
        onTolak: isAssigned || isPending ? _rejectTask : null,
        onMintaClarifikasi: isAssigned || isPending
            ? _requestClarification
            : null,
        onTerima: isAssigned || isPending ? _acceptTask : null,
      );
    } else {
      // Petugas action bar
      return _PetugasActionBar(
        status: status,
        onTolak: isAssigned || isPending ? _rejectTask : null,
        onMintaClarifikasi: isAssigned || isPending
            ? _requestClarification
            : null,
        onTerima: isAssigned || isPending ? _acceptTask : null,
        onKunjungi: isAssigned ? _navigateToSurveyForm : null,
      );
    }
  }

  String _formatDate(String? s) {
    if (s == null) return '-';
    final dt = DateTime.tryParse(s);
    if (dt == null) return s;
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
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

/// Petugas-specific action bar with more actions than surveyor.
class _PetugasActionBar extends StatelessWidget {
  final String status;
  final VoidCallback? onTolak;
  final VoidCallback? onMintaClarifikasi;
  final VoidCallback? onTerima;
  final VoidCallback? onKunjungi;

  const _PetugasActionBar({
    required this.status,
    this.onTolak,
    this.onMintaClarifikasi,
    this.onTerima,
    this.onKunjungi,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SigapSpacing.md,
        vertical: SigapSpacing.x12,
      ),
      decoration: BoxDecoration(
        color: SigapColors.bgCard,
        border: Border(top: BorderSide(color: SigapColors.borderCard)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Tolak
            Expanded(
              child: _ActionButton(
                label: 'Tolak',
                onPressed: onTolak,
                isDanger: true,
              ),
            ),
            const SizedBox(width: SigapSpacing.x7),

            // Minta Clarifikasi
            Expanded(
              child: _ActionButton(
                label: 'Clarifikasi',
                onPressed: onMintaClarifikasi,
                isSecondary: true,
              ),
            ),
            const SizedBox(width: SigapSpacing.x7),

            // Kunjungi (primary)
            Expanded(
              child: _ActionButton(
                label: 'Kunjungi',
                onPressed: onKunjungi,
                isPrimary: true,
              ),
            ),
            const SizedBox(width: SigapSpacing.x7),

            // Terima
            Expanded(
              child: _ActionButton(
                label: 'Terima',
                onPressed: onTerima,
                isPrimary: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isDanger;
  final bool isSecondary;
  final bool isPrimary;

  const _ActionButton({
    required this.label,
    this.onPressed,
    this.isDanger = false,
    this.isSecondary = false,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isDanger) {
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: SigapColors.dangerTextStrong,
          padding: const EdgeInsets.symmetric(vertical: SigapSpacing.x12),
          side: const BorderSide(color: SigapColors.dangerBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SigapRadius.md),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: SigapTypography.size11,
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      );
    }

    if (isSecondary) {
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: SigapColors.textSecondary,
          padding: const EdgeInsets.symmetric(vertical: SigapSpacing.x12),
          side: const BorderSide(color: SigapColors.borderCard),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SigapRadius.md),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: SigapTypography.size11,
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      );
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: SigapColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: SigapSpacing.x12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SigapRadius.md),
        ),
        elevation: 0,
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: SigapTypography.size11,
          fontWeight: FontWeight.w600,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

/// Error retry widget.
class _ErrorRetry extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorRetry({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SigapSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: SigapColors.danger,
            ),
            const SizedBox(height: SigapSpacing.md),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: SigapColors.textSecondary,
                fontSize: SigapTypography.size13,
              ),
            ),
            const SizedBox(height: SigapSpacing.lg),
            OutlinedButton(onPressed: onRetry, child: const Text('Coba Lagi')),
          ],
        ),
      ),
    );
  }
}

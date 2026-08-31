import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../api/client.dart';
import '../../l10n/strings.dart';
import '../../providers/capability_provider.dart';
import '../../providers/providers.dart';
import '../../theme/tokens.dart';
import '../../utils/logger.dart';
import '../../widgets/design_system/design_system.dart';

/// RT_RW Verification screen for RT/RW heads to verify, reject, or request info on cases.
///
/// RT_RW has the following capabilities:
/// - case.verify: Approve/verify a case
/// - case.reject: Reject a case
/// - case.request_info: Request additional information
///
/// This screen shows a list of pending cases and allows RT_RW to take action on each.

class RtRwVerificationScreen extends ConsumerStatefulWidget {
  const RtRwVerificationScreen({super.key});

  @override
  ConsumerState<RtRwVerificationScreen> createState() =>
      _RtRwVerificationScreenState();
}

class _RtRwVerificationScreenState
    extends ConsumerState<RtRwVerificationScreen> {
  static final _logger = Logger('RtRwVerificationScreen');

  // Queue state
  List<Report> _entries = [];
  bool _loading = true;
  String? _errorMessage;

  // Capability checks
  bool get _canVerify {
    final caps = ref.read(capabilityNotifierProvider).valueOrNull;
    return caps?.can('case.verify') ?? false;
  }

  bool get _canReject {
    final caps = ref.read(capabilityNotifierProvider).valueOrNull;
    return caps?.can('case.reject') ?? false;
  }

  bool get _canRequestInfo {
    final caps = ref.read(capabilityNotifierProvider).valueOrNull;
    return caps?.can('case.request_info') ?? false;
  }

  @override
  void initState() {
    super.initState();
    _loadQueue();
  }

  Future<void> _loadQueue() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final client = ref.read(apiClientProvider);
      final result = await client.getReports(limit: 100);
      setState(() {
        _entries = result.data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _verifyCase(String id) async {
    try {
      final client = ref.read(apiClientProvider);
      final activeRole = ref.read(authNotifierProvider).activeRole ?? '';
      await client.decideCase(
        activeRole: activeRole,
        caseId: id,
        decision: 'verified',
        reason: 'Verified by RT_RW',
      );
      await _loadQueue();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Laporan berhasil diverifikasi')),
        );
      }
    } catch (e) {
      _logger.warning('Error verifying case', e);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${Strings.gagal}: $e')));
      }
    }
  }

  Future<void> _rejectCase(String id) async {
    final reasonController = TextEditingController();

    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(Strings.tolakLaporan),
        content: TextField(
          controller: reasonController,
          decoration: InputDecoration(
            labelText: Strings.alasanPenolakan,
            hintText: 'Masukkan alasan penolakan...',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(Strings.batal),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, reasonController.text),
            child: Text(Strings.tolak),
          ),
        ],
      ),
    );

    if (reason == null || reason.isEmpty) return;

    try {
      final client = ref.read(apiClientProvider);
      await client.caseAction(caseId: id, action: 'reject', note: reason);
      await _loadQueue();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Laporan ditolak')));
      }
    } catch (e) {
      _logger.warning('Error rejecting case', e);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${Strings.gagal}: $e')));
      }
    }
  }

  Future<void> _requestInfoCase(String id) async {
    final noteController = TextEditingController();

    final note = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Minta Informasi'),
        content: TextField(
          controller: noteController,
          decoration: InputDecoration(
            labelText: 'Informasi yang diperlukan',
            hintText: 'Masukkan pertanyaan atau informasi yang diperlukan...',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(Strings.batal),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, noteController.text),
            child: Text('Kirim'),
          ),
        ],
      ),
    );

    if (note == null || note.isEmpty) return;

    try {
      final client = ref.read(apiClientProvider);
      await client.caseAction(caseId: id, action: 'request_info', note: note);
      await _loadQueue();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Permintaan informasi berhasil dikirim')),
        );
      }
    } catch (e) {
      _logger.warning('Error requesting info', e);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${Strings.gagal}: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeRole = ref.watch(authNotifierProvider).activeRole ?? '';

    return AuthenticatedShell(
      activeRole: activeRole,
      useScaffold: true,
      appBar: AppBar(
        title: const Text('Verifikasi RT_RW'),
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadQueue,
            tooltip: Strings.refresh,
          ),
        ],
      ),
      body: _loading
          ? Padding(
              padding: const EdgeInsets.all(SigapSpacing.lg),
              child: SkeletonLoader.list(),
            )
          : _errorMessage != null
          ? Padding(
              padding: const EdgeInsets.all(SigapSpacing.xl),
              child: ErrorRetryView(
                message: Strings.gagalMemuatTugas,
                onRetry: _loadQueue,
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadQueue,
              color: SigapColors.primary,
              child: _entries.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(SigapSpacing.md),
                      itemCount: _entries.length,
                      itemBuilder: (context, i) {
                        final entry = _entries[i];
                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: SigapSpacing.sm,
                          ),
                          child: ReportListItem(
                            report: entry,
                            onTap: () =>
                                context.push('/rt-rw-verification/${entry.id}'),
                            trailingActions: _buildTrailingActions(entry),
                            showId: true,
                          ),
                        );
                      },
                    ),
            ),
    );
  }

  List<Widget>? _buildTrailingActions(Report entry) {
    final actions = <Widget>[];

    // Verify action
    if (_canVerify) {
      actions.add(
        IconButton(
          icon: const Icon(Icons.check_circle_outline),
          color: SigapColors.selesai,
          onPressed: () => _verifyCase(entry.id!),
          tooltip: 'Setuju',
        ),
      );
    }

    // Reject action
    if (_canReject) {
      actions.add(
        IconButton(
          icon: const Icon(Icons.highlight_off),
          color: SigapColors.perluTindakan,
          onPressed: () => _rejectCase(entry.id!),
          tooltip: Strings.tolak,
        ),
      );
    }

    // Request info action
    if (_canRequestInfo) {
      actions.add(
        IconButton(
          icon: const Icon(Icons.help_outline),
          color: SigapColors.info,
          onPressed: () => _requestInfoCase(entry.id!),
          tooltip: 'Minta Info',
        ),
      );
    }

    // Common action: View detail
    actions.add(
      IconButton(
        icon: const Icon(Icons.chevron_right),
        color: SigapColors.textTertiary,
        onPressed: () => context.push('/rt-rw-verification/${entry.id}'),
        tooltip: Strings.detail,
      ),
    );

    return actions;
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(SigapSpacing.xl),
      child: EmptyState(
        icon: Icons.inbox_outlined,
        title: 'Tidak Ada Kasus',
        subtitle: 'Belum ada kasus yang perlu diverifikasi.',
      ),
    );
  }
}

/// Detail screen for RT_RW case verification.
///
/// Shows case details with actions: Setuju (verify), Tolak (reject), Minta Info.
class RtRwVerificationDetailScreen extends ConsumerStatefulWidget {
  final String caseId;

  const RtRwVerificationDetailScreen({super.key, required this.caseId});

  @override
  ConsumerState<RtRwVerificationDetailScreen> createState() =>
      _RtRwVerificationDetailScreenState();
}

class _RtRwVerificationDetailScreenState
    extends ConsumerState<RtRwVerificationDetailScreen> {
  static final _logger = Logger('RtRwVerificationDetailScreen');

  CaseDetail? _caseData;
  TimelineEnvelope? _timelineData;
  bool _loading = true;
  String? _error;
  bool _submitting = false;
  String? _submitError;
  bool _success = false;

  // Decision state
  String? _selectedDecision;
  final _reasonController = TextEditingController();

  // Capability checks
  bool get _canVerify {
    final caps = ref.read(capabilityNotifierProvider).valueOrNull;
    return caps?.can('case.verify') ?? false;
  }

  bool get _canReject {
    final caps = ref.read(capabilityNotifierProvider).valueOrNull;
    return caps?.can('case.reject') ?? false;
  }

  bool get _canRequestInfo {
    final caps = ref.read(capabilityNotifierProvider).valueOrNull;
    return caps?.can('case.request_info') ?? false;
  }

  bool get _canSubmit {
    if (_selectedDecision == null) return false;
    if (_reasonController.text.trim().isEmpty) return false;
    return true;
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final client = ref.read(apiClientProvider);
      final caseData = await client.getCaseDetail(widget.caseId);
      TimelineEnvelope? timelineData;
      try {
        timelineData = await client.getReportTimeline(widget.caseId);
      } catch (e, s) {
        _logger.warning('Error fetching timeline', e, s);
        timelineData = null;
      }
      setState(() {
        _caseData = caseData;
        _timelineData = timelineData;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _submit() async {
    if (!_canSubmit) return;

    setState(() {
      _submitting = true;
      _submitError = null;
    });

    try {
      final client = ref.read(apiClientProvider);
      final activeRole = ref.read(authNotifierProvider).activeRole ?? '';

      if (_selectedDecision == 'verify') {
        await client.decideCase(
          activeRole: activeRole,
          caseId: widget.caseId,
          decision: 'verified',
          reason: _reasonController.text.trim(),
        );
      } else {
        await client.caseAction(
          caseId: widget.caseId,
          action: _selectedDecision!,
          note: _reasonController.text.trim(),
        );
      }

      setState(() => _success = true);
    } catch (e) {
      _logger.warning('Error submitting decision', e);
      setState(() => _submitError = 'Gagal mengirim keputusan: $e');
    } finally {
      setState(() => _submitting = false);
    }
  }

  void _showDecisionSheet(String decision, String label, Color color) {
    _reasonController.clear();
    setState(() => _selectedDecision = decision);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: SigapColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: 'Alasan (WAJIB)',
                  hintText: 'Berikan alasan keputusan ini',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _canSubmit
                    ? () {
                        Navigator.pop(ctx);
                        _submit();
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: SigapColors.surface,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(Strings.kirimKeputusan),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_success) {
      return Scaffold(
        appBar: AppBar(title: const Text('Verifikasi')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: SigapColors.selesai,
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text(
                'Keputusan berhasil dikirim',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Kembali'),
              ),
            ],
          ),
        ),
      );
    }

    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text(Strings.detailKasus)),
        body: const VerifikatorCaseDetailSkeleton(),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text(Strings.detailKasus)),
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
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadData,
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    final caseData = _caseData!;
    final report = caseData.report;
    final photos = report?.photos ?? [];
    final categoryName = report?.category ?? '-';
    final status = report?.status?.value ?? '-';
    final description = report?.description ?? '-';
    final title = report?.title ?? '-';
    final createdAt = report?.createdAt;
    final lat = report?.location?['lat'] as double?;
    final lng = report?.location?['lng'] as double?;

    return Scaffold(
      appBar: AppBar(title: const Text(Strings.detailKasusVerifikasi)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(SigapSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
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
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: SigapSpacing.sm),
                  Row(
                    children: [
                      StatusPill(
                        label: status == 'submitted'
                            ? Strings.submitted
                            : status == 'under_review'
                            ? 'Under Review'
                            : status == 'verified'
                            ? 'Verified'
                            : status == 'in_progress'
                            ? 'In Progress'
                            : status == 'resolved'
                            ? 'Resolved'
                            : status == 'rejected'
                            ? Strings.ditolak
                            : status == 'pending'
                            ? Strings.menunggu
                            : status,
                        tone: status == 'submitted'
                            ? StatusTone.danger
                            : status == 'under_review'
                            ? StatusTone.neutral
                            : status == 'verified'
                            ? StatusTone.success
                            : status == 'in_progress'
                            ? StatusTone.info
                            : status == 'resolved'
                            ? StatusTone.success
                            : status == 'rejected'
                            ? StatusTone.danger
                            : StatusTone.neutral,
                        showDot: false,
                      ),
                      const SizedBox(width: SigapSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: SigapSpacing.sm,
                          vertical: SigapSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: SigapColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(SigapRadius.sm),
                        ),
                        child: Text(
                          categoryName,
                          style: const TextStyle(
                            color: SigapColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (createdAt != null) ...[
                    const SizedBox(height: SigapSpacing.sm),
                    Text(
                      'Diajukan: ${_formatDate(createdAt)}',
                      style: TextStyle(
                        color: SigapColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: SigapSpacing.lg),

            // Location
            SectionLabel(
              label: 'Lokasi',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: SigapColors.textPrimary,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(SigapSpacing.md),
              decoration: BoxDecoration(
                color: SigapColors.surface,
                borderRadius: BorderRadius.circular(SigapRadius.md),
                border: Border.all(color: SigapColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report?.addressArea ??
                        report?.address ??
                        (lat != null && lng != null
                            ? 'Koordinat: ${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}'
                            : 'Lokasi tidak tersedia'),
                    style: const TextStyle(
                      fontSize: 13,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: SigapSpacing.sm),
                  OutlinedButton.icon(
                    onPressed: () => context.push('/map'),
                    icon: const Icon(Icons.map, size: 16),
                    label: const Text(Strings.lihatDiPeta),
                  ),
                ],
              ),
            ),
            const SizedBox(height: SigapSpacing.lg),

            // Photos
            if (photos.isNotEmpty) ...[
              SectionLabel(
                label: 'Foto',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: SigapColors.textPrimary,
                ),
              ),
              SizedBox(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: photos.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: SigapSpacing.sm),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => _showPhotoFullScreen(context, photos, index),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(SigapRadius.md),
                        child: Image.network(
                          photos[index],
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 120,
                            height: 120,
                            color: SigapColors.textMuted.withValues(alpha: 0.2),
                            child: const Icon(Icons.broken_image),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: SigapSpacing.lg),
            ],

            // Description
            SectionLabel(
              label: 'Deskripsi',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: SigapColors.textPrimary,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(SigapSpacing.md),
              decoration: BoxDecoration(
                color: SigapColors.surface,
                borderRadius: BorderRadius.circular(SigapRadius.md),
                border: Border.all(color: SigapColors.border),
              ),
              child: Text(description, style: const TextStyle(fontSize: 14)),
            ),
            const SizedBox(height: SigapSpacing.lg),

            // Timeline
            if (_timelineData != null &&
                (_timelineData!.events?.isNotEmpty ?? false)) ...[
              SectionLabel(
                label: 'Timeline',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: SigapColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(SigapSpacing.md),
                decoration: BoxDecoration(
                  color: SigapColors.surface,
                  borderRadius: BorderRadius.circular(SigapRadius.md),
                  border: Border.all(color: SigapColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (
                      int i = 0;
                      i < (_timelineData!.events ?? []).length;
                      i++
                    ) ...[
                      _TimelineEventWidget(
                        title:
                            _timelineData!.events![i].message ??
                            _timelineData!.events![i].type ??
                            '-',
                        subtitle: _formatDateTime(
                          _timelineData!.events![i].timestamp ?? '',
                        ),
                        actor: _timelineData!.events![i].userId != null
                            ? 'oleh: ${_timelineData!.events![i].userId}'
                            : null,
                        isLast: i == (_timelineData!.events!.length - 1),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: SigapSpacing.lg),
            ],

            // Action Buttons
            SectionLabel(
              label: 'Tindakan',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: SigapColors.textPrimary,
              ),
            ),
            StickyActionBar(
              actions: [
                if (_canReject)
                  SigapActionButton(
                    label: Strings.ditolak,
                    semanticsLabel: Strings.ditolak,
                    onPressed: _submitting
                        ? null
                        : () => _showDecisionSheet(
                            'reject',
                            Strings.ditolak,
                            SigapColors.perluTindakan,
                          ),
                    icon: Icons.cancel,
                  ),
                if (_canRequestInfo)
                  SigapOutlineButton(
                    label: 'Minta Info',
                    semanticsLabel: 'Minta Info',
                    onPressed: _submitting
                        ? null
                        : () => _showDecisionSheet(
                            'request_info',
                            'Minta Informasi',
                            SigapColors.info,
                          ),
                    icon: Icons.help_outline,
                  ),
                if (_canVerify)
                  SigapActionButton(
                    label: 'Setuju',
                    semanticsLabel: 'Setuju',
                    onPressed: _submitting
                        ? null
                        : () => _showDecisionSheet(
                            'verify',
                            'Setuju — Verifikasi Laporan',
                            SigapColors.selesai,
                          ),
                    icon: Icons.check_circle,
                  ),
              ],
            ),
            if (_submitError != null) ...[
              const SizedBox(height: SigapSpacing.md),
              Text(
                'Error: $_submitError',
                style: const TextStyle(
                  color: SigapColors.perluTindakan,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e, s) {
      _logger.warning('Error parsing date "$iso"', e, s);
      return iso;
    }
  }

  String _formatDateTime(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }

  void _showPhotoFullScreen(BuildContext ctx, List<String> photos, int index) {
    PhotoFullScreen.show(ctx, photos, index);
  }
}

/// Simple timeline event widget for RT_RW verification screen.
class _TimelineEventWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? actor;
  final bool isLast;

  const _TimelineEventWidget({
    required this.title,
    required this.subtitle,
    this.actor,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: SigapColors.primary,
                shape: BoxShape.circle,
              ),
            ),
            if (!isLast)
              Container(width: 2, height: 40, color: SigapColors.border),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: SigapColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: SigapColors.textMuted),
                ),
                if (actor != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    actor!,
                    style: TextStyle(
                      fontSize: 12,
                      color: SigapColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

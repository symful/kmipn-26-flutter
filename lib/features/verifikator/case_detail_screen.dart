import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/providers.dart';
import '../../theme/tokens.dart';
import '../../utils/logger.dart';
import '../../widgets/skeleton_loaders.dart';

/// Case Review screen for Verifikator to review and make decisions on cases.
///
/// Design tokens used:
/// - AppColors: primary, danger, info, warning, bgCard, borderCard, textPrimary, textSecondary, textTertiary
/// - AppSpacing: sm, md, lg, xxl
/// - AppRadius: sm, md, lg
/// - AppTypography: size11, size12, size13, size14, size16, size18, size22

class VerifikasiCaseDetailScreen extends ConsumerStatefulWidget {
  final String caseId;
  const VerifikasiCaseDetailScreen({super.key, required this.caseId});

  @override
  ConsumerState<VerifikasiCaseDetailScreen> createState() =>
      _VerifikasiCaseDetailScreenState();
}

class _VerifikasiCaseDetailScreenState
    extends ConsumerState<VerifikasiCaseDetailScreen> {
  static final _logger = Logger('VerifikasiCaseDetailScreen');
  Map<String, dynamic>? _caseData;
  Map<String, dynamic>? _assessmentData;
  bool _loading = true;
  String? _error;

  // Decision state
  String? _selectedDecision;
  final _reasonController = TextEditingController();
  final _duplicateIdController = TextEditingController();
  final _surveyorIdController = TextEditingController();
  bool _submitting = false;
  String? _submitError;
  bool _success = false;

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
      final caseData = await client.get(
        '/api/verifikator/cases/${widget.caseId}',
      );
      Map<String, dynamic>? assessmentData;
      try {
        assessmentData = await client.get(
          '/api/agent/assessments/${widget.caseId}',
        );
      } catch (e, s) {
        _logger.warning('Error fetching assessment', e, s);
        // Assessment may not exist for all cases
        assessmentData = null;
      }
      setState(() {
        _caseData = caseData;
        _assessmentData = assessmentData;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  bool get _canSubmit {
    if (_selectedDecision == null) return false;
    if (_selectedDecision == 'duplicate' &&
        _duplicateIdController.text.trim().isEmpty) {
      return false;
    }
    if ((_selectedDecision == 'out_of_scope' ||
            _selectedDecision == 'rejected') &&
        _reasonController.text.trim().isEmpty) {
      return false;
    }
    return true;
  }

  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() {
      _submitting = true;
      _submitError = null;
    });
    try {
      final client = ref.read(apiClientProvider);
      await client.verifikatorDecide(
        caseId: widget.caseId,
        decision: _selectedDecision!,
        reason: _reasonController.text.trim().isNotEmpty
            ? _reasonController.text.trim()
            : null,
        duplicateOfReportId: _selectedDecision == 'duplicate'
            ? (_duplicateIdController.text.trim().isNotEmpty
                  ? _duplicateIdController.text.trim()
                  : null)
            : null,
        surveyorId: _selectedDecision == 'needs_survey'
            ? (_surveyorIdController.text.trim().isNotEmpty
                  ? _surveyorIdController.text.trim()
                  : null)
            : null,
      );
      setState(() => _success = true);
    } catch (e) {
      setState(() => _submitError = e.toString());
    } finally {
      setState(() => _submitting = false);
    }
  }

  void _showDecisionSheet(String decision, String label, Color color) {
    _reasonController.clear();
    _duplicateIdController.clear();
    _surveyorIdController.clear();
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
              if (decision == 'duplicate') ...[
                TextField(
                  controller: _duplicateIdController,
                  decoration: const InputDecoration(
                    labelText: 'ID Laporan Duplikat (WAJIB)',
                    hintText: 'Masukkan ID laporan duplikat',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (decision == 'needs_survey') ...[
                TextField(
                  controller: _surveyorIdController,
                  decoration: const InputDecoration(
                    labelText: 'ID Surveyor (opsional)',
                    hintText: 'Masukkan ID surveyor',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              TextField(
                controller: _reasonController,
                decoration: InputDecoration(
                  labelText:
                      (decision == 'out_of_scope' || decision == 'rejected')
                      ? 'Alasan (WAJIB)'
                      : 'Alasan (opsional)',
                  hintText: 'Berikan alasan keputusan ini',
                  border: const OutlineInputBorder(),
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
                child: const Text('Kirim Keputusan'),
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
    _duplicateIdController.dispose();
    _surveyorIdController.dispose();
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
        appBar: AppBar(title: const Text('Detail Kasus')),
        body: const VerifikatorCaseDetailSkeleton(),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Kasus')),
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
    final photos = (caseData['photo_urls'] as List?)?.cast<String>() ?? [];
    final categoryName =
        (caseData['category'] as Map<String, dynamic>?)?['name'] as String? ??
        caseData['category_id'] as String? ??
        '-';
    final status = caseData['status'] as String? ?? '-';
    final description = caseData['description'] as String? ?? '-';
    final title = caseData['title'] as String? ?? '-';
    final createdAt = caseData['created_at'] as String?;
    final lat = (caseData['lat'] as num?)?.toDouble();
    final lng = (caseData['lng'] as num?)?.toDouble();

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Kasus Verifikasi')),
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
                      _StatusBadge(status: status),
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
            _SectionHeader(title: 'Lokasi'),
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
                    lat != null && lng != null
                        ? 'Koordinat: ${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}'
                        : 'Koordinat: Tidak tersedia',
                    style: const TextStyle(
                      fontSize: 13,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: SigapSpacing.sm),
                  OutlinedButton.icon(
                    onPressed: () => context.push('/map'),
                    icon: const Icon(Icons.map, size: 16),
                    label: const Text('Lihat di Peta'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: SigapSpacing.lg),

            // Photos
            if (photos.isNotEmpty) ...[
              _SectionHeader(title: 'Foto'),
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
            _SectionHeader(title: 'Deskripsi'),
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

            // AI Assessment
            if (_assessmentData != null) ...[
              _SectionHeader(title: 'Penilaian AI'),
              _AssessmentCard(data: _assessmentData!),
              const SizedBox(height: SigapSpacing.lg),
            ],

            // 6-Decision Actions Panel
            _SectionHeader(title: 'Tindakan'),
            _DecisionPanel(
              onDecisionSelected: _showDecisionSheet,
              submitting: _submitting,
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

  void _showPhotoFullScreen(BuildContext ctx, List<String> photos, int index) {
    Navigator.of(ctx).push(
      MaterialPageRoute(
        builder: (_) => _PhotoFullScreen(photos: photos, initialIndex: index),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: SigapSpacing.sm),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: SigapColors.textPrimary,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  Color get _color {
    switch (status.toLowerCase()) {
      case 'submitted':
        return SigapColors.perluTindakan;
      case 'under_review':
        return SigapColors.offlineDot;
      case 'verified':
        return SigapColors.selesai;
      case 'in_progress':
        return SigapColors.diproses;
      case 'resolved':
        return SigapColors.selesai;
      case 'rejected':
        return SigapColors.perluTindakan;
      case 'duplicate_merged':
        return SigapColors.offlineDot;
      default:
        return SigapColors.textMuted;
    }
  }

  String get _label {
    switch (status.toLowerCase()) {
      case 'submitted':
        return 'Submitted';
      case 'under_review':
        return 'Under Review';
      case 'verified':
        return 'Verified';
      case 'in_progress':
        return 'In Progress';
      case 'resolved':
        return 'Resolved';
      case 'rejected':
        return 'Rejected';
      case 'duplicate_merged':
        return 'Duplikat';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SigapSpacing.sm,
        vertical: SigapSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(SigapRadius.sm),
      ),
      child: Text(
        _label,
        style: TextStyle(
          color: _color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _AssessmentCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _AssessmentCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final confidence = (data['confidence'] as num?)?.toDouble();
    final visionDesc = data['vision_description'] as String?;
    final duplicateCandidates =
        (data['duplicate_candidates'] as List?)?.cast<Map<String, dynamic>>() ??
        [];

    return Container(
      padding: const EdgeInsets.all(SigapSpacing.md),
      decoration: BoxDecoration(
        color: SigapColors.surface,
        borderRadius: BorderRadius.circular(SigapRadius.md),
        border: Border.all(color: SigapColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (confidence != null) ...[
            Row(
              children: [
                const Text('Confidence: ', style: TextStyle(fontSize: 13)),
                Text(
                  '${(confidence * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: confidence > 0.7
                        ? SigapColors.selesai
                        : confidence > 0.4
                        ? SigapColors.offlineDot
                        : SigapColors.perluTindakan,
                  ),
                ),
              ],
            ),
            const SizedBox(height: SigapSpacing.sm),
          ],
          if (visionDesc != null && visionDesc.isNotEmpty) ...[
            const Text(
              'Deskripsi Visual:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(visionDesc, style: const TextStyle(fontSize: 13)),
            const SizedBox(height: SigapSpacing.sm),
          ],
          if (duplicateCandidates.isNotEmpty) ...[
            const Text(
              'Kandidat Duplikat:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            ...duplicateCandidates
                .take(3)
                .map(
                  (c) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.link,
                          size: 14,
                          color: SigapColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'ID: ${c['report_id'] ?? c['id'] ?? '-'} — ${c['similarity'] ?? c['score'] ?? '-'}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        ],
      ),
    );
  }
}

class _DecisionPanel extends StatelessWidget {
  final void Function(String decision, String label, Color color)
  onDecisionSelected;
  final bool submitting;
  const _DecisionPanel({
    required this.onDecisionSelected,
    required this.submitting,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: SigapSpacing.sm,
      crossAxisSpacing: SigapSpacing.sm,
      childAspectRatio: 2.2,
      children: [
        _DecisionButton(
          icon: Icons.check_circle,
          label: 'Valid',
          sublabel: 'Terima laporan',
          color: SigapColors.selesai,
          decision: 'valid',
          onTap: () => onDecisionSelected(
            'valid',
            'Valid — Terima Laporan',
            SigapColors.selesai,
          ),
        ),
        _DecisionButton(
          icon: Icons.edit_note,
          label: 'Lengkapi',
          sublabel: 'Minta kelengkapan',
          color: SigapColors.diproses,
          decision: 'needs_completion',
          onTap: () => onDecisionSelected(
            'needs_completion',
            'Perlu Lengkapi',
            SigapColors.diproses,
          ),
        ),
        _DecisionButton(
          icon: Icons.search,
          label: 'Survei',
          sublabel: 'Kirim surveyor',
          color: SigapColors.primary,
          decision: 'needs_survey',
          onTap: () => onDecisionSelected(
            'needs_survey',
            'Perlu Survei',
            SigapColors.primary,
          ),
        ),
        _DecisionButton(
          icon: Icons.link,
          label: 'Duplikat',
          sublabel: 'Merge duplikat',
          color: SigapColors.diproses,
          decision: 'duplicate',
          onTap: () => onDecisionSelected(
            'duplicate',
            'Tandai Duplikat',
            SigapColors.offlineDot,
          ),
        ),
        _DecisionButton(
          icon: Icons.block,
          label: 'Diluar',
          sublabel: 'Di luar jangkauan',
          color: SigapColors.offlineDot,
          decision: 'out_of_scope',
          onTap: () => onDecisionSelected(
            'out_of_scope',
            'Diluar Jangkauan',
            SigapColors.offlineDot,
          ),
        ),
        _DecisionButton(
          icon: Icons.cancel,
          label: 'Tolak',
          sublabel: 'Tolak laporan',
          color: SigapColors.perluTindakan,
          decision: 'rejected',
          onTap: () => onDecisionSelected(
            'rejected',
            'Ditolak',
            SigapColors.perluTindakan,
          ),
        ),
      ],
    );
  }
}

class _DecisionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final Color color;
  final String decision;
  final VoidCallback onTap;

  const _DecisionButton({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.color,
    required this.decision,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(SigapRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SigapRadius.md),
        child: Container(
          padding: const EdgeInsets.all(SigapSpacing.sm),
          decoration: BoxDecoration(
            border: Border.all(color: color.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(SigapRadius.md),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                sublabel,
                style: TextStyle(
                  color: color.withValues(alpha: 0.7),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoFullScreen extends StatefulWidget {
  final List<String> photos;
  final int initialIndex;
  const _PhotoFullScreen({required this.photos, required this.initialIndex});

  @override
  State<_PhotoFullScreen> createState() => _PhotoFullScreenState();
}

class _PhotoFullScreenState extends State<_PhotoFullScreen> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SigapColors.textPrimary,
      appBar: AppBar(
        backgroundColor: SigapColors.textPrimary,
        foregroundColor: SigapColors.surface,
        title: Text('${_currentIndex + 1} / ${widget.photos.length}'),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.photos.length,
        onPageChanged: (i) => setState(() => _currentIndex = i),
        itemBuilder: (context, index) {
          return InteractiveViewer(
            child: Center(
              child: Image.network(
                widget.photos[index],
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.broken_image,
                  color: SigapColors.surface,
                  size: 64,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

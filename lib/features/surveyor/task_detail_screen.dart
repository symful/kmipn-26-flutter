import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/strings.dart';
import '../../../providers/providers.dart';
import '../../../theme/tokens.dart';
import '../../../widgets/design_system/phone_frame.dart';
import '../../../widgets/design_system/status_bar.dart';

class SurveyorTaskDetailScreen extends ConsumerStatefulWidget {
  final String taskId;
  const SurveyorTaskDetailScreen({super.key, required this.taskId});

  @override
  ConsumerState<SurveyorTaskDetailScreen> createState() =>
      _SurveyorTaskDetailScreenState();
}

class _SurveyorTaskDetailScreenState
    extends ConsumerState<SurveyorTaskDetailScreen> {
  Map<String, dynamic>? _task;
  List<Map<String, dynamic>> _checklistItems = [];
  bool _loading = true;
  String? _error;
  bool _isOfflineMode = false;
  String? _taskCode;
  String? _slaText;
  String? _taskCategory;
  String? _taskTitle;
  List<String>? _evidenceUrls;

  // Dialog state for reject/clarification
  bool _rejecting = false;
  bool _requestingClarification = false;

  // Per-checklist data: itemId -> {gps: LatLng?, photo: String?, checked: bool, notes: String}
  final Map<String, _ChecklistEntry> _checklistData = {};

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
      // Try API first
      final client = ref.read(apiClientProvider);
      final data = await client.surveyorGetTaskDetail(widget.taskId);
      // Fetch checklist template separately
      final checklistData = await client.getSurveyorChecklistTemplate(
        widget.taskId,
      );
      final checklistItems = checklistData.items ?? [];

      // Extract task metadata from DTO
      final task = data.task;
      final taskCode = task?.code ?? 'TGS-${widget.taskId.substring(0, 4)}';
      final slaHours = task?.slaHoursRemaining != null
          ? (task!.slaHoursRemaining! / 3600).ceil()
          : 4;
      final slaText = '$slaHours jam';

      setState(() {
        _task = data.toJson();
        _checklistItems = checklistItems;
        _loading = false;
        _isOfflineMode = false;
        _taskCode = taskCode;
        _slaText = slaText;
        _taskCategory = task?.categoryName ?? 'JALAN';
        _taskTitle =
            task?.reportDescription ??
            task?.instructions ??
            Strings.detailTugas;
        _evidenceUrls = task?.photoUrls ?? [];
      });

      // Initialize checklist data map
      for (final item in _checklistItems) {
        final id = item['id']?.toString() ?? item['item_id']?.toString() ?? '';
        _checklistData[id] = _ChecklistEntry(
          checked: false,
          gps: null,
          photoPath: null,
          photoExifJson: null,
          notes: '',
        );
      }
    } catch (e) {
      // Fall back to offline local data
      try {
        final localTask = await taskRepo.getDownloadedTask(widget.taskId);
        if (localTask != null) {
          final decoded = jsonDecode(localTask.checklistTemplateJson);
          final checklistTemplate = decoded is List ? decoded : <dynamic>[];

          setState(() {
            _task = {
              'id': localTask.taskId,
              'title': localTask.title,
              'description': localTask.description,
              'instructions': localTask.instructions,
              'status': localTask.status,
              'checklist_template': checklistTemplate,
            };
            _checklistItems = checklistTemplate
                .whereType<Map<String, dynamic>>()
                .toList();
            _loading = false;
            _isOfflineMode = true;
            _taskCode = localTask.taskId.length >= 4
                ? 'TGS-${localTask.taskId.substring(0, 4).toUpperCase()}'
                : 'TGS-${localTask.taskId.toUpperCase()}';
            _slaText = '4 jam';
            _taskCategory = 'JALAN';
            _taskTitle = localTask.title.isNotEmpty
                ? localTask.title
                : (localTask.description?.isNotEmpty ?? false)
                ? localTask.description!
                : Strings.detailTugas;
            _evidenceUrls = <String>[];
          });

          // Initialize checklist data map
          for (final item in _checklistItems) {
            final id =
                item['id']?.toString() ?? item['item_id']?.toString() ?? '';
            _checklistData[id] = _ChecklistEntry(
              checked: false,
              gps: null,
              photoPath: null,
              photoExifJson: null,
              notes: '',
            );
          }
        } else {
          setState(() {
            _error = e.toString();
            _loading = false;
          });
        }
      } catch (e) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  Future<void> _showRejectDialog() async {
    final reasonController = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(Strings.tolakTugas),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            labelText: 'Alasan penolakan',
            hintText: 'Masukkan alasan penolakan...',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(Strings.batal),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, reasonController.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: SigapColors.danger,
              foregroundColor: Colors.white,
            ),
            child: const Text(Strings.tolak),
          ),
        ],
      ),
    );

    if (reason != null && reason.isNotEmpty) {
      await _rejectTask(reason);
    }
  }

  Future<void> _rejectTask(String reason) async {
    setState(() {
      _rejecting = true;
      _error = null;
    });

    try {
      final client = ref.read(apiClientProvider);
      await client.surveyorRejectTask(widget.taskId, reason);
      setState(() {
        _rejecting = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Tugas berhasil ditolak')));
        context.go('/surveyor/tasks');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _rejecting = false;
      });
    }
  }

  Future<void> _showClarificationDialog() async {
    final questionController = TextEditingController();
    final question = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Minta Klarifikasi'),
        content: TextField(
          controller: questionController,
          decoration: const InputDecoration(
            labelText: 'Pertanyaan',
            hintText: 'Masukkan pertanyaan Anda...',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(Strings.batal),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, questionController.text),
            child: const Text('Kirim'),
          ),
        ],
      ),
    );

    if (question != null && question.isNotEmpty) {
      await _requestClarification(question);
    }
  }

  Future<void> _requestClarification(String question) async {
    setState(() {
      _requestingClarification = true;
      _error = null;
    });

    try {
      final client = ref.read(apiClientProvider);
      await client.surveyorRequestClarification(
        widget.taskId,
        question: question,
      );
      setState(() {
        _requestingClarification = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permintaan klarifikasi berhasil dikirim'),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _requestingClarification = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return PhoneFrame(
        child: Column(
          children: [
            const StatusBar(),
            Expanded(
              child: Scaffold(
                backgroundColor: SigapColors.surface,
                appBar: AppBar(
                  backgroundColor: SigapColors.bgCard,
                  elevation: 0,
                  title: Text(
                    Strings.detailTugas,
                    style: TextStyle(
                      fontSize: SigapTypography.size16,
                      fontWeight: FontWeight.w600,
                      color: SigapColors.textPrimary,
                    ),
                  ),
                ),
                body: const Center(
                  child: CircularProgressIndicator(color: SigapColors.primary),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null && _task == null) {
      return PhoneFrame(
        child: Column(
          children: [
            const StatusBar(),
            Expanded(
              child: Scaffold(
                backgroundColor: SigapColors.surface,
                appBar: AppBar(
                  backgroundColor: SigapColors.bgCard,
                  elevation: 0,
                  title: Text(
                    Strings.detailTugas,
                    style: TextStyle(
                      fontSize: SigapTypography.size16,
                      fontWeight: FontWeight.w600,
                      color: SigapColors.textPrimary,
                    ),
                  ),
                ),
                body: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: SigapColors.dangerBg,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: SigapColors.perluTindakan,
                        ),
                      ),
                      const SizedBox(height: SigapSpacing.lg),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: SigapSpacing.xl,
                        ),
                        child: Text(
                          'Gagal memuat:\n$_error',
                          style: TextStyle(
                            fontSize: SigapTypography.size14,
                            color: SigapColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: SigapSpacing.xl),
                      ElevatedButton(
                        onPressed: _load,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: SigapColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: SigapSpacing.xl,
                            vertical: SigapSpacing.md,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(SigapRadius.md),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Coba Lagi',
                          style: TextStyle(
                            fontSize: SigapTypography.size14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final task = _task!;
    final instructions =
        task['instructions'] as String? ??
        task['description'] as String? ??
        '-';

    // Ensure we have task metadata
    final taskCode = _taskCode ?? 'TGS-${widget.taskId.substring(0, 4)}';
    final slaText = _slaText ?? '4 jam';
    final taskCategory = _taskCategory ?? 'JALAN';
    final taskTitle = _taskTitle ?? Strings.detailTugas;
    final evidenceUrls = _evidenceUrls ?? <String>[];
    final evidenceCount = evidenceUrls.isNotEmpty
        ? evidenceUrls.length
        : (task['evidence_count'] as int? ?? 3);

    return PhoneFrame(
      child: Column(
        children: [
          const StatusBar(),
          Expanded(
            child: Scaffold(
              backgroundColor: SigapColors.surface,
              appBar: AppBar(
                backgroundColor: SigapColors.bgCard,
                elevation: 0,
                toolbarHeight: 60,
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: SigapColors.textPrimary,
                    size: 22,
                  ),
                  onPressed: () => context.pop(),
                ),
                titleSpacing: 0,
                title: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            Strings.detailTugas,
                            style: TextStyle(
                              fontSize: SigapTypography.size16,
                              fontWeight: FontWeight.w700,
                              color: SigapColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            taskCode,
                            style: TextStyle(
                              fontSize: SigapTypography.size11,
                              fontWeight: FontWeight.w600,
                              fontFamily: SigapTypography.fontFamilyMono,
                              color: SigapColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: SigapSpacing.sm),
                    // SLA badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: SigapSpacing.sm,
                        vertical: SigapSpacing.x4,
                      ),
                      decoration: BoxDecoration(
                        color: SigapColors.offlineBg,
                        borderRadius: BorderRadius.circular(SigapRadius.x6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.schedule,
                            size: SigapTypography.size11,
                            color: SigapColors.offlineText,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'SLA $slaText',
                            style: TextStyle(
                              fontSize: SigapTypography.size11,
                              fontWeight: FontWeight.w700,
                              color: SigapColors.offlineText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                actions: [
                  if (_isOfflineMode)
                    Container(
                      margin: const EdgeInsets.only(right: SigapSpacing.md),
                      padding: const EdgeInsets.symmetric(
                        horizontal: SigapSpacing.sm,
                        vertical: SigapSpacing.x4,
                      ),
                      decoration: BoxDecoration(
                        color: SigapColors.offlineBg,
                        borderRadius: BorderRadius.circular(SigapRadius.sm),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.cloud_off,
                            size: SigapTypography.size10,
                            color: SigapColors.offlineText,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'OFFLINE',
                            style: TextStyle(
                              fontSize: SigapTypography.size10,
                              fontWeight: FontWeight.bold,
                              color: SigapColors.offlineText,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              body: Column(
                children: [
                  // Divider
                  Container(height: 1, color: SigapColors.border),
                  // Content
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(SigapSpacing.md),
                      children: [
                        // Category tag + Task type
                        Row(
                          children: [
                            // JALAN tag
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: SigapSpacing.sm,
                                vertical: SigapSpacing.x4,
                              ),
                              decoration: BoxDecoration(
                                color: SigapColors.primaryLight,
                                borderRadius: BorderRadius.circular(
                                  SigapRadius.sm,
                                ),
                              ),
                              child: Text(
                                taskCategory.toUpperCase(),
                                style: TextStyle(
                                  fontSize: SigapTypography.size10,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: SigapTypography.fontFamilyMono,
                                  color: SigapColors.primaryDark,
                                  letterSpacing:
                                      SigapTypography.letterSpacingTight,
                                ),
                              ),
                            ),
                            const SizedBox(width: SigapSpacing.sm),
                            // Verifikasi lapangan
                            Text(
                              'Verifikasi lapangan',
                              style: TextStyle(
                                fontSize: SigapTypography.size11,
                                fontWeight: FontWeight.w600,
                                color: SigapColors.perluTindakan,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 7),

                        // Offline connectivity banner
                        if (_isOfflineMode)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: SigapSpacing.md,
                              vertical: SigapSpacing.sm,
                            ),
                            margin: const EdgeInsets.only(
                              bottom: SigapSpacing.sm,
                            ),
                            decoration: BoxDecoration(
                              color: SigapColors.offlineBg,
                              borderRadius: BorderRadius.circular(
                                SigapRadius.md,
                              ),
                              border: Border.all(
                                color: SigapColors.offlineBorder,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.cloud_off,
                                  size: SigapTypography.size14,
                                  color: SigapColors.offlineText,
                                ),
                                const SizedBox(width: SigapSpacing.sm),
                                Expanded(
                                  child: Text(
                                    'Mode offline - data akan disinkronkan saat online',
                                    style: TextStyle(
                                      fontSize: SigapTypography.size12,
                                      fontWeight: FontWeight.w500,
                                      color: SigapColors.offlineText,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        // Task title
                        Text(
                          taskTitle,
                          style: TextStyle(
                            fontSize: SigapTypography.size17,
                            fontWeight: FontWeight.w700,
                            color: SigapColors.textPrimary,
                            height: SigapTypography.lineHeight130,
                          ),
                        ),
                        const SizedBox(height: SigapSpacing.md),

                        // Instructions card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(SigapSpacing.x12),
                          decoration: BoxDecoration(
                            color: SigapColors.bgCard,
                            borderRadius: BorderRadius.circular(
                              SigapRadius.x12,
                            ),
                            border: Border.all(color: SigapColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'INSTRUKSI',
                                style: TextStyle(
                                  fontSize: SigapTypography.size11,
                                  fontWeight: FontWeight.w700,
                                  color: SigapColors.textTertiary,
                                  letterSpacing:
                                      SigapTypography.letterSpacingLabel,
                                ),
                              ),
                              const SizedBox(height: SigapSpacing.x6),
                              Text(
                                instructions,
                                style: TextStyle(
                                  fontSize: SigapTypography.size13,
                                  color: SigapColors.textPrimary,
                                  height: SigapTypography.lineHeight150,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: SigapSpacing.md),

                        // S-02 Detail Tugas Widgets: Checklist
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Color(0xFFE0E0E0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Checklist Survei',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 12),
                              _ChecklistItem(
                                'Foto dari 3 sudut (depan, samping, belakang)',
                              ),
                              _ChecklistItem(
                                'Ukur dimensi ruangan (panjang x lebar)',
                              ),
                              _ChecklistItem('Tandai koordinat GPS di peta'),
                            ],
                          ),
                        ),
                        const SizedBox(height: SigapSpacing.md),

                        // S-02 Detail Tugas Widgets: Bukti Warga Gallery
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Color(0xFFE0E0E0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bukti Warga',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 12),
                              Row(
                                children: List.generate(
                                  3,
                                  (i) => Padding(
                                    padding: EdgeInsets.only(right: 8),
                                    child: Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: Color(0xFFF5F5F5),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.image,
                                        color: Color(0xFFBDBDBD),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: SigapSpacing.md),

                        // S-02 Detail Tugas Widgets: Offline-ready Indicator
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xFF00897B).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.download_done,
                                size: 16,
                                color: Color(0xFF00897B),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Peta area + bukti diunduh · 12.4 MB',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF00897B),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: SigapSpacing.lg),

                        // Checklist section
                        Text(
                          'CHECKLIST WAJIB',
                          style: TextStyle(
                            fontSize: SigapTypography.size11,
                            fontWeight: FontWeight.w700,
                            color: SigapColors.textTertiary,
                            letterSpacing: SigapTypography.letterSpacingLabel,
                          ),
                        ),
                        const SizedBox(height: SigapSpacing.sm),
                        Container(
                          decoration: BoxDecoration(
                            color: SigapColors.bgCard,
                            borderRadius: BorderRadius.circular(
                              SigapRadius.x12,
                            ),
                            border: Border.all(color: SigapColors.border),
                          ),
                          child: Column(
                            children: List.generate(_checklistItems.length, (
                              index,
                            ) {
                              final item = _checklistItems[index];
                              final label =
                                  item['label'] as String? ??
                                  item['name'] as String? ??
                                  'Item ${index + 1}';

                              final itemId =
                                  item['id']?.toString() ??
                                  item['item_id']?.toString() ??
                                  '';
                              final entry = _checklistData[itemId];
                              final isChecked = entry?.checked ?? false;

                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    _checklistData[itemId] = _ChecklistEntry(
                                      checked: !isChecked,
                                      gps: entry?.gps,
                                      photoPath: entry?.photoPath,
                                      photoExifJson: entry?.photoExifJson,
                                      notes: entry?.notes ?? '',
                                    );
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: SigapSpacing.md,
                                    vertical: SigapSpacing.md,
                                  ),
                                  decoration: BoxDecoration(
                                    border: index < _checklistItems.length - 1
                                        ? const Border(
                                            bottom: BorderSide(
                                              color: SigapColors.bgSoft,
                                              width: 1,
                                            ),
                                          )
                                        : null,
                                  ),
                                  child: Row(
                                    children: [
                                      // Interactive checkbox
                                      Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: isChecked
                                              ? SigapColors.selesai
                                              : SigapColors.bgCard,
                                          borderRadius: BorderRadius.circular(
                                            SigapRadius.x6,
                                          ),
                                          border: Border.all(
                                            color: isChecked
                                                ? SigapColors.selesai
                                                : const Color(0xFFcfd3cc),
                                            width: 2,
                                          ),
                                        ),
                                        child: isChecked
                                            ? const Icon(
                                                Icons.check,
                                                size: 14,
                                                color: Colors.white,
                                              )
                                            : null,
                                      ),
                                      const SizedBox(width: SigapSpacing.md),
                                      Expanded(
                                        child: Text(
                                          label,
                                          style: TextStyle(
                                            fontSize: SigapTypography.size13,
                                            color: SigapColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                        const SizedBox(height: SigapSpacing.md),

                        // Evidence section
                        Text(
                          'BUKTI WARGA ($evidenceCount)',
                          style: TextStyle(
                            fontSize: SigapTypography.size11,
                            fontWeight: FontWeight.w700,
                            color: SigapColors.textTertiary,
                            letterSpacing: SigapTypography.letterSpacingLabel,
                          ),
                        ),
                        const SizedBox(height: SigapSpacing.sm),
                        // Evidence photo grid
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: SigapSpacing.sm,
                                mainAxisSpacing: SigapSpacing.sm,
                                childAspectRatio: 1,
                              ),
                          itemCount: evidenceUrls.isNotEmpty
                              ? evidenceUrls.length
                              : evidenceCount,
                          itemBuilder: (context, index) {
                            if (evidenceUrls.isNotEmpty) {
                              // Show actual photo
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  SigapRadius.x9,
                                ),
                                child: Image.network(
                                  evidenceUrls[index],
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      _buildPlaceholder(index),
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        }
                                        return _buildPlaceholder(index);
                                      },
                                ),
                              );
                            } else {
                              // Show placeholder
                              return _buildPlaceholder(index);
                            }
                          },
                        ),
                        const SizedBox(height: SigapSpacing.md),

                        // Offline status banner
                        if (_isOfflineMode)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: SigapSpacing.md,
                              vertical: SigapSpacing.md,
                            ),
                            decoration: BoxDecoration(
                              color: SigapColors.primaryLight,
                              borderRadius: BorderRadius.circular(
                                SigapRadius.md,
                              ),
                              border: Border.all(
                                color: SigapColors.successBorder,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 22,
                                  height: 22,
                                  decoration: const BoxDecoration(
                                    color: SigapColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.cloud_download,
                                    size: SigapTypography.size12,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: SigapSpacing.sm),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Siap dikerjakan offline',
                                        style: TextStyle(
                                          fontSize: SigapTypography.size12_5,
                                          fontWeight: FontWeight.w600,
                                          color: SigapColors.primaryDark,
                                        ),
                                      ),
                                      Text(
                                        'Peta area + bukti diunduh · 12,4 MB',
                                        style:
                                            TextStyle(
                                              fontSize: SigapTypography.size11,
                                              color: SigapColors.primaryDark,
                                            ).copyWith(
                                              color: SigapColors.primaryDark
                                                  .withValues(alpha: 0.8),
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        // Extra spacing at bottom for scroll
                        const SizedBox(height: SigapSpacing.xl),
                      ],
                    ),
                  ),
                  // Action bar
                  Container(
                    padding: const EdgeInsets.only(
                      left: 18,
                      right: 18,
                      top: 12,
                      bottom: 22,
                    ),
                    decoration: BoxDecoration(
                      color: SigapColors.bgCard,
                      border: const Border(
                        top: BorderSide(color: SigapColors.border),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_error != null)
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: SigapSpacing.sm,
                            ),
                            child: Text(
                              'Error: $_error',
                              style: TextStyle(
                                color: SigapColors.perluTindakan,
                                fontSize: SigapTypography.size12,
                              ),
                            ),
                          ),
                        // Primary button - Terima & mulai survei
                        ElevatedButton(
                          onPressed: () => context.push(
                            '/surveyor/form-survei/${widget.taskId}',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: SigapColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: SigapSpacing.md,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                SigapRadius.x12,
                              ),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Terima & mulai survei',
                            style: TextStyle(
                              fontSize: SigapTypography.size15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: SigapSpacing.sm),
                        // Secondary buttons row
                        Row(
                          children: [
                            // Minta klarifikasi button
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _requestingClarification
                                    ? null
                                    : _showClarificationDialog,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: SigapColors.textPrimary,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: SigapSpacing.md,
                                  ),
                                  side: const BorderSide(
                                    color: SigapColors.border,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      SigapRadius.x10,
                                    ),
                                  ),
                                ),
                                child: _requestingClarification
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: SigapColors.textPrimary,
                                        ),
                                      )
                                    : Text(
                                        'Minta klarifikasi',
                                        style: TextStyle(
                                          fontSize: SigapTypography.size12_5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(width: SigapSpacing.sm),
                            // Tolak button
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _rejecting
                                    ? null
                                    : _showRejectDialog,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: SigapColors.dangerTextStrong,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: SigapSpacing.md,
                                  ),
                                  side: const BorderSide(
                                    color: SigapColors.dangerBorder,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      SigapRadius.x10,
                                    ),
                                  ),
                                ),
                                child: _rejecting
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: SigapColors.dangerTextStrong,
                                        ),
                                      )
                                    : Text(
                                        Strings.tolak,
                                        style: TextStyle(
                                          fontSize: SigapTypography.size12_5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for striped placeholder pattern
/// Matches design: repeating-linear-gradient(135deg, #e4e7e2, #e4e7e2 6px, #eef0ec 6px, #eef0ec 12px)
class _StripedPlaceholderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const color1 = Color(0xFFE4E7E2); // #e4e7e2
    const color2 = Color(0xFFEEF0EC); // #eef0ec
    const stripeWidth = 6.0;
    const pairWidth = 12.0;

    // Rotate canvas 45° so stripes appear at 135° (diagonal)
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(-math.pi / 4);
    canvas.translate(-size.width / 2, -size.height / 2);

    // Draw alternating colored stripes horizontally (becomes diagonal after rotation)
    final diagonal = size.width + size.height;
    for (double i = -diagonal; i < diagonal; i += pairWidth) {
      canvas.drawRect(
        Rect.fromLTWH(i, -size.height, stripeWidth, diagonal * 2),
        Paint()..color = color1,
      );
      canvas.drawRect(
        Rect.fromLTWH(i + stripeWidth, -size.height, stripeWidth, diagonal * 2),
        Paint()..color = color2,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

Widget _buildPlaceholder(int index) {
  return Container(
    decoration: BoxDecoration(
      color: SigapColors.surface,
      borderRadius: BorderRadius.circular(SigapRadius.x9),
      border: Border.all(color: SigapColors.border),
    ),
    child: CustomPaint(
      painter: _StripedPlaceholderPainter(),
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 28,
          color: SigapColors.textMuted,
        ),
      ),
    ),
  );
}

Widget _ChecklistItem(String text) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            border: Border.all(color: Color(0xFF00897B)),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        SizedBox(width: 12),
        Expanded(child: Text(text, style: TextStyle(fontSize: 13))),
      ],
    ),
  );
}

class _ChecklistEntry {
  bool checked;
  (double, double)? gps;
  String? photoPath;
  String? photoExifJson;
  String notes;
  _ChecklistEntry({
    required this.checked,
    required this.gps,
    required this.photoPath,
    required this.photoExifJson,
    required this.notes,
  });
}

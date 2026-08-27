import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../db/database.dart';
import '../../providers/providers.dart';
import '../../services/photo_service.dart';
import '../../theme/tokens.dart';
import 'presentation/screens/review_app_bar.dart';
import 'presentation/widgets/report_summary_card.dart';
import 'presentation/widgets/similar_cases_banner.dart';
import 'presentation/widgets/privacy_toggle.dart';
import 'presentation/widgets/truth_statement_checkbox.dart';
import 'presentation/widgets/sticky_footer_cta.dart';

/// Model representing a potential duplicate match for review
class DuplicateMatch {
  final String reportId;
  final String description;
  final double lat;
  final double lng;
  final String? categoryName;
  final DateTime createdAt;
  final String? photoPath;
  final double? similarityScore; // 0.0 to 1.0, null if not available
  final String distance; // formatted distance string e.g., "25m", "0.5km"

  const DuplicateMatch({
    required this.reportId,
    required this.description,
    required this.lat,
    required this.lng,
    this.categoryName,
    required this.createdAt,
    this.photoPath,
    this.similarityScore,
    required this.distance,
  });

  /// Convert to SimilarCase for the banner widget
  SimilarCase toSimilarCase() {
    final initials = categoryName != null
        ? categoryName!
              .substring(0, categoryName!.length >= 2 ? 2 : 1)
              .toUpperCase()
        : 'RJ';
    return SimilarCase(
      id: reportId,
      initials: initials,
      title: description,
      distance: distance,
      similarityPercent: similarityScore != null
          ? (similarityScore! * 100).round()
          : 0,
      reportCount: 1,
    );
  }
}

/// Screen shown when potential duplicate reports are detected near the same location.
/// Allows user to confirm or deny the duplicate before submitting their report.
class ReviewKirimanScreen extends ConsumerStatefulWidget {
  /// The new report being submitted (passed as parameters since it's not yet saved)
  final String description;
  final double lat;
  final double lng;
  final String? categoryId;
  final String? categoryName;
  final String? photoPath;
  final List<DuplicateMatch> duplicateMatches;

  const ReviewKirimanScreen({
    super.key,
    required this.description,
    required this.lat,
    required this.lng,
    this.categoryId,
    this.categoryName,
    this.photoPath,
    this.duplicateMatches = const [],
  });

  @override
  ConsumerState<ReviewKirimanScreen> createState() =>
      _ReviewKirimanScreenState();
}

class _ReviewKirimanScreenState extends ConsumerState<ReviewKirimanScreen> {
  bool _isSubmitting = false;
  bool _isPublicIdentity = false;
  bool _isTruthStatementChecked = false;

  /// Handle user choosing to add evidence to existing case
  Future<void> _handleLinkToCase(SimilarCase selectedCase) async {
    setState(() => _isSubmitting = true);

    try {
      final client = ref.read(apiClientProvider);
      await client.wargaSubmitEvidence(
        reportId: selectedCase.id,
        description: widget.description,
        photoPaths: widget.photoPath != null ? [widget.photoPath!] : [],
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bukti berhasil ditambahkan ke kasus'),
          backgroundColor: SigapColors.primary,
        ),
      );

      // Navigate to the complementary evidence screen for the selected case
      context.push('/warga/evidence/${selectedCase.id}');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menambahkan bukti: $e'),
          backgroundColor: SigapColors.danger,
        ),
      );
    }
  }

  /// Handle user choosing to create a separate report
  Future<void> _handleCreateSeparate() async {
    if (widget.categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kategori laporan tidak tersedia'),
          backgroundColor: SigapColors.danger,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final idempotencyKey = const Uuid().v4();
      final reportRepo = ref.read(reportRepositoryProvider);
      final db = ref.read(databaseProvider);

      // Save report locally
      await reportRepo.saveLocal(
        LocalReportsCompanion.insert(
          idempotencyKey: idempotencyKey,
          categoryId: widget.categoryId!,
          description: widget.description,
          lat: widget.lat,
          lng: widget.lng,
          photoPath: Value(widget.photoPath),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      // Upload photo if available
      if (widget.photoPath != null) {
        try {
          final photoService = PhotoService(ref.read(apiClientProvider));
          final r2Url = await photoService.uploadPhotoAndGetUrl(
            widget.photoPath!,
            idempotencyKey,
          );

          // Insert photo record with R2 URL
          await db.insertPhoto(
            reportIdempotencyKey: idempotencyKey,
            filePath: r2Url,
            capturedAt: DateTime.now().millisecondsSinceEpoch,
          );
        } catch (photoError) {
          // Photo upload failed, but report is saved locally
          // Insert with local path as fallback
          await db.insertPhoto(
            reportIdempotencyKey: idempotencyKey,
            filePath: widget.photoPath!,
            capturedAt: DateTime.now().millisecondsSinceEpoch,
          );
        }
      }

      // Enqueue for sync
      final queueRepo = ref.read(syncQueueRepositoryProvider);
      await queueRepo.enqueue(idempotencyKey);

      // Invalidate providers to refresh data
      ref.invalidate(localReportsProvider);
      ref.invalidate(pendingCountProvider);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Laporan tersimpan. Akan sinkron otomatis.'),
          backgroundColor: SigapColors.primary,
        ),
      );

      // Navigate back to warga home
      context.go('/warga');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan: $e'),
          backgroundColor: SigapColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Build the list of SimilarCase from duplicate matches
    final similarCases = widget.duplicateMatches
        .map((match) => match.toSimilarCase())
        .toList();

    return Scaffold(
      backgroundColor: SigapColors.bgScreen,
      body: Column(
        children: [
          // Custom app bar with stepper
          ReviewAppBar(
            currentStep: 5, // This is step 5 of 5 (final review step)
            onBack: () => context.pop(),
          ),

          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                vertical: SigapSpacing.xl,
                horizontal: SigapSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Similar cases banner (shown before summary per M-11)
                  if (similarCases.isNotEmpty) ...[
                    SimilarCasesBanner(
                      cases: similarCases,
                      onAddEvidence: (selectedCase) {
                        _handleLinkToCase(selectedCase);
                      },
                      onCreateSeparate: () {
                        _handleCreateSeparate();
                      },
                    ),
                    const SizedBox(height: SigapSpacing.md),
                  ],

                  // Report summary card
                  ReportSummaryCard(
                    report: ReportSummary(
                      initials: widget.categoryName != null
                          ? widget.categoryName!
                                .substring(
                                  0,
                                  widget.categoryName!.length >= 2 ? 2 : 1,
                                )
                                .toUpperCase()
                          : 'JL',
                      categoryName: widget.categoryName ?? 'JALAN',
                      condition: 'Berat',
                      title: widget.description,
                      location:
                          '${widget.lat.toStringAsFixed(4)}, ${widget.lng.toStringAsFixed(4)}',
                      accuracy: 'Akurasi baik',
                      timestamp: _formatTimestamp(DateTime.now()),
                      impact: 'Keselamatan · akses terganggu',
                      canEditLocation: false,
                      canEditTimestamp: false,
                    ),
                    onEditLocation: () {
                      // Location editing is not available at the final review step.
                      // User should go back to the location selection step to modify location.
                    },
                    onEditTimestamp: () {
                      // Timestamp editing is not available at the final review step.
                      // User should go back to an earlier step to modify the timestamp.
                    },
                  ),

                  const SizedBox(height: SigapSpacing.md),

                  // Privacy toggle
                  PrivacyToggle(
                    value: _isPublicIdentity,
                    onChanged: (value) {
                      setState(() => _isPublicIdentity = value);
                    },
                  ),

                  const SizedBox(height: SigapSpacing.md),

                  // Truth statement checkbox
                  TruthStatementCheckbox(
                    value: _isTruthStatementChecked,
                    onChanged: (value) {
                      setState(() => _isTruthStatementChecked = value);
                    },
                  ),
                ],
              ),
            ),
          ),

          // Sticky footer with action buttons and offline warning
          StickyFooterCTA(
            buttonLabel: 'Simpan dan sinkronkan nanti',
            isOffline: ref
                .watch(connectivityProvider)
                .maybeWhen(
                  data: (connectivity) =>
                      connectivity.contains(ConnectivityResult.none),
                  orElse: () => false,
                ),
            isLoading: _isSubmitting,
            onSubmit: () {
              if (_isTruthStatementChecked) {
                _handleCreateSeparate();
              }
            },
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime dateTime) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    final day = dateTime.day;
    final month = months[dateTime.month - 1];
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$day $month $year, $hour:$minute';
  }
}

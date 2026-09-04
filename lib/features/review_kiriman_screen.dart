import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../db/database.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/providers.dart';
import '../../services/photo_service.dart';
import '../../theme/tokens.dart';
import '../../utils/logger.dart';
import 'review_app_bar_screen.dart';
import '../../widgets/design_system/report_summary_card.dart';
import '../../widgets/design_system/similar_cases_banner.dart';
import '../../widgets/design_system/privacy_toggle.dart';
import '../../widgets/design_system/truth_statement_checkbox.dart';
import '../../widgets/design_system/sticky_footer_cta.dart';

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
  static final _logger = Logger('ReviewKirimanScreen');
  bool _isSubmitting = false;
  bool _isPublicIdentity = false;
  bool _isTruthStatementChecked = false;

  /// Handle user choosing to add evidence to existing case
  Future<void> _handleLinkToCase(SimilarCase selectedCase) async {
    setState(() => _isSubmitting = true);

    try {
      final client = ref.read(apiClientProvider);
      await client.reportAction(
        reportId: selectedCase.id,
        action: 'lengkapi',
        note: widget.description,
      );

      if (!mounted) return;

      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.buktiDitambahkanKeKasus),
          backgroundColor: SigapColors.primary,
        ),
      );

      // Navigate to the complementary evidence screen for the selected case
      context.push('/evidence/${selectedCase.id}');
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.gagalMenambahkanBukti(e.toString())),
          backgroundColor: SigapColors.danger,
        ),
      );
    }
  }

  /// Handle user choosing to create a separate report
  Future<void> _handleCreateSeparate() async {
    if (widget.categoryId == null) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.kategoriLaporanTidakTersedia),
          backgroundColor: SigapColors.danger,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final client = ref.read(apiClientProvider);
      final idempotencyKey = const Uuid().v4();
      final reportRepo = ref.read(reportRepositoryProvider);
      final db = ref.read(databaseProvider);

      // Step 1: Upload photo FIRST (matching web SPA canonical flow)
      String r2Url = widget.photoPath ?? '';
      final photoUrls = <String>[];
      if (widget.photoPath != null) {
        try {
          r2Url = await client.uploadReportPhotoAnon(
            widget.photoPath!,
            idempotencyKey,
          );
          photoUrls.add(r2Url);
          _logger.info('Photo uploaded for reviewkiriman: $r2Url');
        } catch (photoError) {
          _logger.warning('Photo upload failed, using local path: $photoError');
          // r2Url stays as local path
        }
      }

      // Step 2: Create report with photo URLs in body
      final result = await client.submitReport(
        idempotencyKey: idempotencyKey,
        categoryId: widget.categoryId!,
        description: widget.description,
        lat: widget.lat,
        lng: widget.lng,
        photoUrls: photoUrls,
      );

      if (result.duplicate) {
        _logger.info(
          'Reviewkiriman report detected as duplicate: ${result.id}',
        );
        if (!mounted) return;
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.laporanTersimpanAutoSync),
            backgroundColor: SigapColors.warning,
          ),
        );
        context.go('/dashboard');
        return;
      }

      final serverReportId = result.id ?? idempotencyKey;
      _logger.info('Reviewkiriman report submitted: id=$serverReportId');

      // Save report locally
      await reportRepo.saveLocal(
        LocalReportsCompanion.insert(
          idempotencyKey: idempotencyKey,
          categoryId: widget.categoryId!,
          description: widget.description,
          lat: widget.lat,
          lng: widget.lng,
          photoPath: Value(r2Url),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      // Insert photo record
      if (widget.photoPath != null) {
        await db.insertPhoto(
          reportIdempotencyKey: idempotencyKey,
          filePath: r2Url,
          capturedAt: DateTime.now().millisecondsSinceEpoch,
        );
      }

      // Enqueue for sync
      final queueRepo = ref.read(syncQueueRepositoryProvider);
      await queueRepo.enqueue(idempotencyKey, kind: 'report');

      // Invalidate providers to refresh data
      ref.invalidate(localReportsProvider);
      ref.invalidate(pendingCountProvider);

      if (!mounted) return;

      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.laporanTersimpanAutoSync),
          backgroundColor: SigapColors.primary,
        ),
      );

      // Navigate back to home
      context.go('/dashboard');
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.gagalMenyimpan(e.toString())),
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
                  PrivacyToggleCard(
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

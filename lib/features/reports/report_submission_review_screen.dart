import 'package:sigap/widgets/request_error_details.dart';
import 'package:intl/intl.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sigap/widgets/design_system/responsive_scaffold.dart';
import 'package:uuid/uuid.dart';
import 'package:sigap/db/database.dart';
import 'package:sigap/l10n/generated/app_localizations.dart';
import 'package:sigap/providers/providers.dart';
import 'package:sigap/theme/tokens.dart';
import 'package:sigap/utils/logger.dart';
import 'package:sigap/features/reports/widgets/report_review_app_bar.dart';
import 'package:sigap/widgets/design_system/report_summary_card.dart';
import 'package:sigap/widgets/design_system/similar_cases_banner.dart';
import 'package:sigap/widgets/design_system/truth_statement_checkbox.dart';
import 'package:sigap/widgets/design_system/sticky_footer_cta.dart';

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
  final int? reportCount;

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
    this.reportCount,
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
          : null,
      reportCount: reportCount,
    );
  }
}

/// Screen shown when potential duplicate reports are detected near the same location.
/// Allows user to confirm or deny the duplicate before submitting their report.
class ReportSubmissionReviewScreen extends ConsumerStatefulWidget {
  /// The new report being submitted (passed as parameters since it's not yet saved)
  final String description;
  final double lat;
  final double lng;
  final String? categoryId;
  final String? categoryName;
  final String? photoPath;
  final List<DuplicateMatch> duplicateMatches;
  final String? condition;
  final double? accuracyMeters;
  final DateTime? capturedAt;
  final String? impact;

  const ReportSubmissionReviewScreen({
    super.key,
    required this.description,
    required this.lat,
    required this.lng,
    this.categoryId,
    this.categoryName,
    this.photoPath,
    this.duplicateMatches = const [],
    this.condition,
    this.accuracyMeters,
    this.capturedAt,
    this.impact,
  });

  @override
  ConsumerState<ReportSubmissionReviewScreen> createState() =>
      _ReportSubmissionReviewScreenState();
}

class _ReportSubmissionReviewScreenState
    extends ConsumerState<ReportSubmissionReviewScreen> {
  static final _logger = Logger('ReportSubmissionReviewScreen');
  bool _isSubmitting = false;
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
      setState(() => _isSubmitting = false);
      showRequestFailure(context, e);
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
      setState(() => _isSubmitting = false);
      showRequestFailure(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Build the list of SimilarCase from duplicate matches
    final similarCases = widget.duplicateMatches
        .map((match) => match.toSimilarCase())
        .toList();
    if (similarCases.isEmpty && widget.categoryId != null) {
      final candidates = ref
          .watch(
            similarCasesProvider(
              SimilarCasesParams(
                lat: widget.lat,
                lng: widget.lng,
                categoryId: widget.categoryId!,
              ),
            ),
          )
          .valueOrNull;
      for (final candidate in candidates ?? []) {
        if (candidate.reportId == null) continue;
        similarCases.add(
          SimilarCase(
            id: candidate.reportId!,
            initials: candidate.initials ?? '—',
            title: candidate.title ?? candidate.reportId!,
            distance: candidate.distanceM == null
                ? '—'
                : '${candidate.distanceM!.round()} m',
            similarityPercent: candidate.similarityScore == null
                ? null
                : (candidate.similarityScore! * 100).round(),
            reportCount: candidate.reportCount,
          ),
        );
      }
    }

    return ResponsiveScaffold(
      body: Column(
        children: [
          // Custom app bar with stepper
          ReportReviewAppBar(
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
                          : '—',
                      categoryName: widget.categoryName ?? '—',
                      condition:
                          widget.condition ??
                          AppLocalizations.of(context)!.reportConditionUnknown,
                      title: widget.description,
                      location:
                          '${widget.lat.toStringAsFixed(4)}, ${widget.lng.toStringAsFixed(4)}',
                      accuracy: widget.accuracyMeters == null
                          ? '—'
                          : '${widget.accuracyMeters} m',
                      timestamp: widget.capturedAt == null
                          ? AppLocalizations.of(
                              context,
                            )!.reportCaptureTimeUnknown
                          : _formatTimestamp(widget.capturedAt!),
                      impact: widget.impact ?? '',
                      photoIndex: widget.photoPath?.isNotEmpty == true
                          ? '1/1'
                          : '0',
                      photoPath: widget.photoPath,
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

                  // Public identity is protected by the service; no unsupported toggle.
                  Text(
                    AppLocalizations.of(
                      context,
                    )!.mobileOnlyAuthorizedStaffCanAccessReporterDetails,
                  ),
                  const SizedBox(height: 8),
                  Text(AppLocalizations.of(context)!.privacyReportExplanation),

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
            buttonLabel: AppLocalizations.of(context)!.simpanSinkronkanNanti,
            isOffline: ref
                .watch(connectivityProvider)
                .maybeWhen(
                  data: (connectivity) =>
                      connectivity.contains(ConnectivityResult.none),
                  orElse: () => true,
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

  String _formatTimestamp(DateTime dateTime) => DateFormat.yMMMd(
    AppLocalizations.of(context)!.localeName,
  ).add_Hm().format(dateTime.toLocal());
}

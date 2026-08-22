import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/providers.dart';
import '../../theme/tokens.dart';
import '../../features/warga/presentation/screens/review_app_bar.dart';
import '../../features/warga/presentation/widgets/similar_cases_banner.dart';
import '../../features/warga/presentation/widgets/report_summary_card.dart';
import '../../features/warga/presentation/widgets/privacy_toggle.dart';
import '../../features/warga/presentation/widgets/truth_statement_checkbox.dart';
import '../../features/warga/presentation/widgets/sticky_footer_cta.dart';

/// Verifikator review screen matching M-11 design from PantauDesa Screens.dc.html.
///
/// Design tokens used:
/// - AppColors: primary, infoBg, infoChartBar, info, bgCard, borderCard, bgSoft, textPrimary, textSecondary, textTertiary, warningText, primaryLight, primaryDark
/// - AppSpacing: md, lg, x11, x12, x14, x15, x9, x10
/// - AppRadius: lg (13px), md (11px), x9 (9px), sm (5px)
/// - AppTypography: size11, size12, size12_5, size13, size14, size15, size16, size22, letterSpacingLabel, lineHeight135
///
/// M-11 Design Reference (PantauDesa Screens.dc.html lines 138-197):
/// - Header with back arrow (22px, #3a3f45) + "Review laporan" title + 5-step stepper
/// - Similar cases banner (blue #e5edfd, border #c7d7fb, radius 13px)
/// - Report summary card (white, border #e4e7e2, radius 13px)
/// - Privacy toggle card + truth statement checkbox
/// - Sticky footer with offline warning + primary CTA button

/// Model for duplicate match candidates (used by verifikator review)
class DuplicateMatch {
  final String reportId;
  final String description;
  final double lat;
  final double lng;
  final String? categoryName;
  final DateTime createdAt;
  final String? photoPath;
  final double? similarityScore;
  final String distance;

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

/// Verifikator review screen for cases.
///
/// Shown when verifikator needs to review a case before making a decision.
/// Uses the same M-11 "Review Kiriman" visual design for consistency.
class VerifikatorReviewScreen extends ConsumerStatefulWidget {
  /// The case ID being reviewed.
  final String caseId;

  /// Description/title of the case.
  final String description;

  /// Latitude of the case location.
  final double lat;

  /// Longitude of the case location.
  final double lng;

  /// Category name (e.g. "JALAN", "JEMBATAN").
  final String? categoryName;

  /// Photo path if available.
  final String? photoPath;

  /// Duplicate match candidates found for this case.
  final List<DuplicateMatch> duplicateMatches;

  const VerifikatorReviewScreen({
    super.key,
    required this.caseId,
    required this.description,
    required this.lat,
    required this.lng,
    this.categoryName,
    this.photoPath,
    this.duplicateMatches = const [],
  });

  @override
  ConsumerState<VerifikatorReviewScreen> createState() =>
      _VerifikatorReviewScreenState();
}

class _VerifikatorReviewScreenState
    extends ConsumerState<VerifikatorReviewScreen> {
  bool _isSubmitting = false;
  bool _isPublicIdentity = false;
  bool _isTruthStatementChecked = false;

  Future<void> _handleLinkToCase() async {
    setState(() => _isSubmitting = true);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Menambahkan bukti ke kasus...'),
        duration: Duration(seconds: 1),
      ),
    );
    context.pop();
  }

  Future<void> _handleCreateSeparate() async {
    setState(() => _isSubmitting = true);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Membuat laporan terpisah...'),
        duration: Duration(seconds: 1),
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final similarCases = widget.duplicateMatches
        .map((m) => m.toSimilarCase())
        .toList();

    return Scaffold(
      backgroundColor: AppColors.bgScreen,
      body: Column(
        children: [
          // Custom app bar with stepper
          ReviewAppBar(currentStep: 5, onBack: () => context.pop()),

          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.x14,
                horizontal: AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Similar cases banner (shown before summary per M-11)
                  if (similarCases.isNotEmpty) ...[
                    SimilarCasesBanner(
                      cases: similarCases,
                      onAddEvidence: (selectedCase) {
                        _handleLinkToCase();
                      },
                      onCreateSeparate: () {
                        _handleCreateSeparate();
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
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
                      // Edit location is not available in this screen
                    },
                    onEditTimestamp: () {
                      // Edit timestamp is not available in this screen
                    },
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Privacy toggle
                  PrivacyToggle(
                    value: _isPublicIdentity,
                    onChanged: (value) {
                      setState(() => _isPublicIdentity = value);
                    },
                  ),

                  const SizedBox(height: AppSpacing.md),

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

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/providers.dart';
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
  Future<void> _handleLinkToCase() async {
    setState(() => _isSubmitting = true);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Menambahkan bukti ke kasus...'),
        duration: Duration(seconds: 1),
      ),
    );

    // Navigate back to previous screen
    context.pop();
  }

  /// Handle user choosing to create a separate report
  Future<void> _handleCreateSeparate() async {
    setState(() => _isSubmitting = true);

    if (!mounted) return;

    // Proceed with creating a separate case
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
    // Build the list of SimilarCase from duplicate matches
    final similarCases = widget.duplicateMatches
        .map((match) => match.toSimilarCase())
        .toList();

    return Scaffold(
      backgroundColor: AppColors.bgScreen,
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
                    ),
                    onEditLocation: () {
                      // TODO(flutter): Navigate to edit location screen
                    },
                    onEditTimestamp: () {
                      // TODO(flutter): Navigate to edit timestamp screen
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

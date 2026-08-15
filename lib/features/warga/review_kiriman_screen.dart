import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/tokens.dart';

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

  /// Calculate similarity badge color based on score
  Color _similarityColor(double? score) {
    if (score == null) return AppColors.textTertiary;
    if (score >= 0.8) return AppColors.danger;
    if (score >= 0.6) return AppColors.warning;
    return AppColors.info;
  }

  /// Calculate similarity label based on score
  String _similarityLabel(double? score) {
    if (score == null) return 'Kemiripan tidak diketahui';
    if (score >= 0.9) return 'Sangat Mirip';
    if (score >= 0.7) return 'Cukup Mirip';
    if (score >= 0.5) return 'Sedikit Mirip';
    return 'Mungkin Mirip';
  }

  /// Format the age of the report (e.g., "2 hari lalu")
  String _formatReportAge(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months bulan lalu';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} hari lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit lalu';
    } else {
      return 'Baru saja';
    }
  }

  /// Handle user confirming it's NOT a duplicate (proceed with submission)
  Future<void> _handleNotDuplicate() async {
    setState(() => _isSubmitting = true);

    // TODO: Call provider/state management to proceed with submission
    // This would typically trigger the actual report submission flow

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Melanjutkan pengiriman laporan...'),
        duration: Duration(seconds: 1),
      ),
    );

    // Navigate back to previous screen (create report screen) to continue
    context.pop();
  }

  /// Handle user confirming it IS a duplicate (cancel submission)
  Future<void> _handleIsDuplicate() async {
    setState(() => _isSubmitting = true);

    // TODO: Call provider/state management to cancel submission
    // This would typically cancel the current report and maybe navigate to the existing one

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Laporan Duplikat'),
        content: const Text(
          'Laporan Anda tidak akan dikirim. Anda dapat melihat laporan yang sudah ada.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to the existing report detail
              if (widget.duplicateMatches.isNotEmpty) {
                context.push(
                  '/detail/${widget.duplicateMatches.first.reportId}',
                );
              }
              context.go('/warga');
            },
            child: const Text('Lihat Laporan'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/warga');
            },
            child: const Text('Kembali'),
          ),
        ],
      ),
    );

    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tinjau Laporan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Warning banner
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.warningBg,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: AppColors.warning.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.warning,
                      size: 24,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ditemukan ${widget.duplicateMatches.length} Laporan Serupa',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.warning,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Pastikan laporan Anda bukan duplikat dari laporan yang sudah ada.',
                            style: TextStyle(
                              color: AppColors.warning,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Section title
              const Text(
                'Laporan yang sudah ada di dekat lokasi Anda:',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Duplicate match cards
              Expanded(
                child: ListView.builder(
                  itemCount: widget.duplicateMatches.length,
                  itemBuilder: (context, index) {
                    final match = widget.duplicateMatches[index];
                    return _DuplicateMatchCard(
                      match: match,
                      similarityColor: _similarityColor(match.similarityScore),
                      similarityLabel: _similarityLabel(match.similarityScore),
                      formatAge: _formatReportAge(match.createdAt),
                    );
                  },
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSubmitting ? null : _handleIsDuplicate,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      child: const Text(
                        'Ini Bukan Duplikat',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _handleNotDuplicate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'Ya, Tetap Kirim',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Card widget displaying a potential duplicate match
class _DuplicateMatchCard extends StatelessWidget {
  final DuplicateMatch match;
  final Color similarityColor;
  final String similarityLabel;
  final String formatAge;

  const _DuplicateMatchCard({
    required this.match,
    required this.similarityColor,
    required this.similarityLabel,
    required this.formatAge,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: const BorderSide(color: AppColors.borderCard),
      ),
      color: AppColors.bgCard,
      elevation: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Photo thumbnail or placeholder
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.lg),
            ),
            child: Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(color: AppColors.bgSurface),
              child: match.photoPath != null
                  ? Image.file(
                      File(match.photoPath!),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPhotoPlaceholder(),
                    )
                  : _buildPhotoPlaceholder(),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description
                Text(
                  match.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: AppSpacing.sm),

                // Category and age row
                Row(
                  children: [
                    if (match.categoryName != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Text(
                          match.categoryName!,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                    ],
                    Icon(
                      Icons.access_time,
                      size: 12,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      formatAge,
                      style: const TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.sm),

                // Location and distance row
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${match.lat.toStringAsFixed(4)}, ${match.lng.toStringAsFixed(4)}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.bgSurface,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(color: AppColors.borderCard),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.near_me,
                            size: 12,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            match.distance,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.md),

                // Similarity indicator
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: similarityColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: similarityColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.compare_arrows,
                        size: 16,
                        color: similarityColor,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Kemiripan: ',
                        style: TextStyle(color: similarityColor, fontSize: 12),
                      ),
                      if (match.similarityScore != null) ...[
                        Text(
                          '${(match.similarityScore! * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            color: similarityColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                      ],
                      Text(
                        similarityLabel,
                        style: TextStyle(
                          color: similarityColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoPlaceholder() {
    return Center(
      child: Icon(
        Icons.image_outlined,
        size: 40,
        color: AppColors.textTertiary,
      ),
    );
  }
}

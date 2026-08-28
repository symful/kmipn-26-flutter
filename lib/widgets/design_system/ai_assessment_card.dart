import 'package:flutter/material.dart';
import '../../theme/tokens.dart';

/// AI pre-verification assessment card widget.
///
/// Displays AI assessment results including confidence score, supporting factors,
/// risk factors, and duplicate candidates. Used by operator and verifikator
/// roles only â€” warga must not see AI assessments.
///
/// Data shape (from backend `AssessmentResponse`):
/// ```dart
/// {
///   confidence: number,           // 0.0 - 1.0
///   factors: {
///     supporting: string[],      // e.g. ["EXIF consistent", "GPS matches description"]
///     risk: string[],            // e.g. ["Photo too dark", "Location unclear"]
///     correlation_ids: string[]  // duplicate candidate report IDs
///   },
///   tool_name: string,
///   agent_version: string,
///   status: string,
/// }
/// ```
class AiAssessmentCard extends StatelessWidget {
  /// Full assessment data map from API.
  final Map<String, dynamic> assessment;

  const AiAssessmentCard({super.key, required this.assessment});

  // ---------------------------------------------------------------------------
  // Derived data
  // ---------------------------------------------------------------------------

  double get _confidence =>
      (assessment['confidence'] as num?)?.toDouble() ?? 0.0;

  List<String> get _supportingFactors {
    final f = assessment['factors'];
    if (f is Map) {
      final s = f['supporting'];
      if (s is List) return s.cast<String>();
    }
    return [];
  }

  List<String> get _riskFactors {
    final f = assessment['factors'];
    if (f is Map) {
      final r = f['risk'];
      if (r is List) return r.cast<String>();
    }
    return [];
  }

  List<String> get _duplicateCandidates {
    final f = assessment['factors'];
    if (f is Map) {
      final c = f['correlation_ids'];
      if (c is List) return c.cast<String>();
    }
    return [];
  }

  String? get _toolName => assessment['tool_name'] as String?;

  // ---------------------------------------------------------------------------
  // Color coding
  // ---------------------------------------------------------------------------

  Color get _confidenceColor {
    if (_confidence >= 0.7) return SigapColors.selesai;
    if (_confidence >= 0.4) return SigapColors.offlineDot;
    return SigapColors.perluTindakan;
  }

  String get _confidenceLabel {
    if (_confidence >= 0.7) return 'Tinggi';
    if (_confidence >= 0.4) return 'Sedang';
    return 'Rendah';
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
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
          // Header: confidence badge + tool name
          _buildHeader(),
          const SizedBox(height: SigapSpacing.md),

          // Supporting factors
          if (_supportingFactors.isNotEmpty) ...[
            _buildSectionTitle('Faktor Pendukung'),
            const SizedBox(height: SigapSpacing.xs),
            ..._supportingFactors.map(_buildSupportingFactor),
            const SizedBox(height: SigapSpacing.md),
          ],

          // Risk factors
          if (_riskFactors.isNotEmpty) ...[
            _buildSectionTitle('Faktor Risiko'),
            const SizedBox(height: SigapSpacing.xs),
            ..._riskFactors.map(_buildRiskFactor),
            const SizedBox(height: SigapSpacing.md),
          ],

          // Duplicate candidates
          if (_duplicateCandidates.isNotEmpty) ...[
            _buildSectionTitle('Kandidat Duplikat'),
            const SizedBox(height: SigapSpacing.xs),
            ..._duplicateCandidates.map(_buildDuplicateCandidate),
            const SizedBox(height: SigapSpacing.md),
          ],

          // Disclaimer
          _buildDisclaimer(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final confidencePercent = (_confidence * 100).toStringAsFixed(0);
    return Row(
      children: [
        // Confidence badge
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: SigapSpacing.sm,
            vertical: SigapSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: _confidenceColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(SigapRadius.sm),
            border: Border.all(color: _confidenceColor.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.psychology, size: 14, color: _confidenceColor),
              const SizedBox(width: 4),
              Text(
                'AI Confidence: $confidencePercent%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _confidenceColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: SigapSpacing.sm),

        // Confidence level label
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: SigapSpacing.sm,
            vertical: SigapSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: _confidenceColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(SigapRadius.sm),
          ),
          child: Text(
            _confidenceLabel,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: _confidenceColor,
            ),
          ),
        ),

        const Spacer(),

        // Tool name (if available)
        if (_toolName != null && _toolName!.isNotEmpty)
          Text(
            _toolName!,
            style: const TextStyle(fontSize: 11, color: SigapColors.textMuted),
          ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: SigapColors.textSecondary,
      ),
    );
  }

  Widget _buildSupportingFactor(String factor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: SigapSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, size: 14, color: SigapColors.selesai),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              factor,
              style: const TextStyle(
                fontSize: 13,
                color: SigapColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskFactor(String factor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: SigapSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 14,
            color: SigapColors.offlineDot,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              factor,
              style: const TextStyle(
                fontSize: 13,
                color: SigapColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDuplicateCandidate(String reportId) {
    return Padding(
      padding: const EdgeInsets.only(bottom: SigapSpacing.xs),
      child: Row(
        children: [
          const Icon(Icons.link, size: 14, color: SigapColors.primary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'ID: $reportId',
              style: const TextStyle(
                fontSize: 13,
                color: SigapColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(SigapSpacing.sm),
      decoration: BoxDecoration(
        color: SigapColors.bgSoft,
        borderRadius: BorderRadius.circular(SigapRadius.sm),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 14, color: SigapColors.textMuted),
          SizedBox(width: 6),
          Expanded(
            child: Text(
              'Ini hanya rekomendasi. Keputusan akhir oleh verifikator.',
              style: TextStyle(
                fontSize: 11,
                color: SigapColors.textMuted,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

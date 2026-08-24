import 'package:flutter/material.dart';
import '../../../../theme/tokens.dart';

/// S-04 Surveyor Visit Form Screen Header Widget
///
/// Displays a step header with title and 3-step progress bar for the surveyor
/// visit form screen. The steps are: "Foto", "Kondisi", "Hasil".
///
/// Design: PantauDesa S-04 region header
class SurveyFormHeader extends StatelessWidget {
  /// The current step index (0, 1, or 2).
  /// - 0 = "Foto" (first step)
  /// - 1 = "Kondisi" (second step)
  /// - 2 = "Hasil" (third step)
  final int currentStep;

  /// Optional title to display. Defaults to "Kunjungan surveyor" if not provided.
  final String? title;

  const SurveyFormHeader({super.key, required this.currentStep, this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SigapSpacing.lg,
        vertical: SigapSpacing.md,
      ),
      decoration: const BoxDecoration(
        color: SigapColors.bgCard,
        border: Border(bottom: BorderSide(color: SigapColors.borderCard)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            title ?? 'Kunjungan surveyor',
            style: const TextStyle(
              fontSize: SigapTypography.size22,
              fontWeight: FontWeight.w700,
              color: SigapColors.textPrimary,
            ),
          ),
          const SizedBox(height: SigapSpacing.md),
          // 3-step progress bar with labels
          _buildProgressBar(),
        ],
      ),
    );
  }

  /// Builds the 3-step progress bar with labels: Foto, Kondisi, Hasil
  Widget _buildProgressBar() {
    const steps = ['Foto', 'Kondisi', 'Hasil'];

    return Column(
      children: [
        // Progress bar segments
        Row(
          children: List.generate(3, (i) {
            final isActive = i <= currentStep;
            final isCompleted = i < currentStep;
            return Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(right: i < 2 ? SigapSpacing.xs : 0),
                decoration: BoxDecoration(
                  color: isActive ? SigapColors.primary : SigapColors.borderCard,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: isCompleted
                    ? null // Filled segment
                    : null,
              ),
            );
          }),
        ),
        const SizedBox(height: SigapSpacing.x4),
        // Step labels
        Row(
          children: List.generate(3, (i) {
            final isActive = i <= currentStep;
            return Expanded(
              child: Text(
                steps[i],
                style: TextStyle(
                  fontSize: SigapTypography.size10,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive
                      ? SigapColors.textPrimary
                      : SigapColors.textTertiary,
                ),
                textAlign: TextAlign.left,
              ),
            );
          }),
        ),
      ],
    );
  }
}

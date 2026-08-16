import 'package:flutter/material.dart';
import 'package:sigap/theme/tokens.dart';
import 'package:sigap/widgets/design_system/stepper_5.dart';

/// M-11 AppBar with back button and 5-step stepper for Review Kiriman screen.
///
/// Matches PantauDesa M-11 design spec:
/// - Back arrow (←) with font-size 22px, color #3a3f45
/// - Title "Review laporan" - font-size 16px, font-weight 700
/// - Subtitle "Langkah X dari 5" - font-size 11.5px, color #616770
/// - 5-step horizontal progress bar with gap 5px
class M11ReviewKirimanAppBar extends StatelessWidget {
  /// Current step in the 5-step flow (1-5)
  final int currentStep;

  /// Callback when back button is pressed
  final VoidCallback? onBack;

  const M11ReviewKirimanAppBar({
    super.key,
    required this.currentStep,
    this.onBack,
  }) : assert(currentStep >= 1 && currentStep <= 5);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.xs,
        bottom: AppSpacing.x12,
      ),
      decoration: const BoxDecoration(
        color: AppColors.bgSurface,
        border: Border(
          bottom: BorderSide(color: AppColors.borderCard, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Back arrow + Title row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Back arrow
              GestureDetector(
                onTap: onBack,
                child: const Text(
                  '←',
                  style: TextStyle(
                    fontSize: AppTypography.size22,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.x12),
              // Title and subtitle
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Review laporan',
                    style: TextStyle(
                      fontSize: AppTypography.size16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    'Langkah $currentStep dari 5',
                    style: const TextStyle(
                      fontSize: AppTypography.size11_5,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Stepper
          const SizedBox(height: AppSpacing.x11),
          Stepper5(currentStep: currentStep),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:sigap/l10n/generated/app_localizations.dart';
import 'package:sigap/theme/tokens.dart';
import 'package:sigap/widgets/design_system/design_system.dart';
import 'package:sigap/widgets/design_system/stepper_5.dart';

/// AppBar with back button and 5-step stepper for Review Kiriman screen.
///
/// Matches PantauDesa design spec:
/// - Back arrow (←) with font-size 22px, color #3a3f45
/// - Title "Review laporan" - font-size 22px, font-weight 700
/// - Subtitle "Langkah X dari 5" - font-size 12px, color #616770
/// - 5-step horizontal progress bar with gap 5px
///
/// Now uses [SigapAppBar] internally with review style.
class ReviewAppBar extends StatelessWidget {
  /// Current step in the 5-step flow (1-5)
  final int currentStep;

  /// Callback when back button is pressed
  final VoidCallback? onBack;

  const ReviewAppBar({super.key, required this.currentStep, this.onBack})
    : assert(currentStep >= 1 && currentStep <= 5);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: const BoxDecoration(
        color: SigapColors.bgSurface,
        border: Border(
          bottom: BorderSide(color: SigapColors.borderCard, width: 1),
        ),
      ),
      child: SigapAppBar(
        title: l10n.reviewLaporan,
        subtitle: l10n.langkahDari(currentStep, 5),
        onBack: onBack,
        padding: const EdgeInsets.only(
          left: SigapSpacing.lg,
          right: SigapSpacing.lg,
          top: SigapSpacing.xs,
        ),
        bottom: Stepper5(currentStep: currentStep),
      ),
    );
  }
}

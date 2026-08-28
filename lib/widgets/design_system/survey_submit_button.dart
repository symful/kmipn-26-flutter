import 'package:flutter/material.dart';
import '../../../../widgets/design_system/design_system.dart';

/// Survey submit button for surveyor visit form screen.
///
/// Full-width primary button fixed at the bottom of the form.
/// Shows loading spinner during submission and is disabled when form is incomplete.
///
/// Design: Primary filled button "Kirim Hasil Kunjungan" with send icon.
/// Matches PantauDesa S-04 design spec for the visit form submit action.
class SurveySubmitButton extends StatelessWidget {
  /// Called when the submit button is tapped.
  final VoidCallback? onPressed;

  /// Whether the button is in loading state (shows spinner).
  final bool isLoading;

  /// Whether the submit button is enabled.
  /// When false, the button appears grayed out and non-interactive.
  final bool isEnabled;

  /// Creates a new SurveySubmitButton.
  ///
  /// [onPressed] is called when the enabled button is tapped.
  /// [isLoading] shows a spinner and disables interaction during submission.
  /// [isEnabled] controls whether the button responds to taps.
  const SurveySubmitButton({
    super.key,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return StickyActionBar(
      actions: [
        SigapActionButton(
          label: 'Kirim Hasil Kunjungan',
          icon: Icons.send,
          onPressed: isEnabled ? onPressed : null,
          semanticsLabel: 'Kirim hasil kunjungan survei',
        ),
      ],
    );
  }
}

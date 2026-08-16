import 'package:flutter/material.dart';
import '../../../../theme/tokens.dart';

/// S-04 Sticky submit button for surveyor visit form screen.
///
/// Full-width primary button fixed at the bottom of the form.
/// Shows loading spinner during submission and is disabled when form is incomplete.
///
/// Design: Primary filled button "Kirim Hasil Kunjungan" with send icon.
/// Matches PantauDesa S-04 design spec for the visit form submit action.
class S04SubmitButton extends StatelessWidget {
  /// Called when the submit button is tapped.
  final VoidCallback? onPressed;

  /// Whether the button is in loading state (shows spinner).
  final bool isLoading;

  /// Whether the submit button is enabled.
  /// When false, the button appears grayed out and non-interactive.
  final bool isEnabled;

  /// Creates a new S04SubmitButton.
  ///
  /// [onPressed] is called when the enabled button is tapped.
  /// [isLoading] shows a spinner and disables interaction during submission.
  /// [isEnabled] controls whether the button responds to taps.
  const S04SubmitButton({
    super.key,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
        border: Border(top: BorderSide(color: AppColors.borderCard, width: 1)),
      ),
      padding: const EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.x12,
        bottom: 22, // 22px bottom padding per design spec
      ),
      child: _SubmitButton(
        onPressed: isEnabled ? onPressed : null,
        isLoading: isLoading,
      ),
    );
  }
}

/// Full-width primary submit button with icon and loading state.
class _SubmitButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const _SubmitButton({this.onPressed, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null;

    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.x15),
        decoration: BoxDecoration(
          color: isDisabled ? AppColors.textDisabled : AppColors.primary,
          borderRadius: BorderRadius.circular(AppRadius.x12),
          boxShadow: isDisabled ? null : AppShadows.buttonPrimary,
        ),
        alignment: Alignment.center,
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.send,
                    size: 18,
                    color: isDisabled ? AppColors.textSecondary : Colors.white,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Kirim Hasil Kunjungan',
                    style: TextStyle(
                      fontSize: AppTypography.size15,
                      fontWeight: FontWeight.w700,
                      color: isDisabled
                          ? AppColors.textSecondary
                          : Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:sigap/theme/tokens.dart';

/// Sticky bottom bar with submit CTA button and offline warning.
///
/// Matches PantauDesa M-11 design spec:
/// - White background with top border
/// - Amber dot + offline warning text
/// - Full-width primary CTA button
///
/// Used in Review Kiriman (M-11) screen.
class StickyFooterCTA extends StatelessWidget {
  /// Label text for the primary CTA button.
  final String buttonLabel;

  /// Whether the device is offline (shows warning notice).
  final bool isOffline;

  /// Called when the CTA button is tapped.
  final VoidCallback? onSubmit;

  /// Whether the button is in loading state.
  final bool isLoading;

  const StickyFooterCTA({
    super.key,
    this.buttonLabel = 'Simpan dan sinkronkan nanti',
    this.isOffline = false,
    this.onSubmit,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: SigapColors.bgCard,
        border: Border(
          top: BorderSide(color: SigapColors.borderCard, width: 1),
        ),
      ),
      padding: const EdgeInsets.only(
        left: SigapSpacing.x12,
        right: SigapSpacing.x12,
        top: SigapSpacing.x12,
        bottom: 22, // 22px bottom padding per design
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Gap between elements: 8px
          const SizedBox(height: SigapSpacing.sm),

          // Offline notice: amber dot + warning text
          if (isOffline) ...[
            const _OfflineNoticeRow(),
            const SizedBox(height: SigapSpacing.sm),
          ],

          // Primary CTA button
          _SubmitButton(
            label: buttonLabel,
            onPressed: onSubmit,
            isLoading: isLoading,
          ),
        ],
      ),
    );
  }
}

/// Amber dot + offline warning text row.
///
/// Design spec: 7px amber dot (#b8730a) + text 11.5px #8a5808
class _OfflineNoticeRow extends StatelessWidget {
  const _OfflineNoticeRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 7px amber dot
        Container(
          width: 7,
          height: 7,
          decoration: const BoxDecoration(
            color: SigapColors.warning,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        // Warning text: 11.5px #8a5808
        Text(
          'Tidak ada koneksi — laporan akan masuk antrean.',
          style: const TextStyle(
            fontSize: SigapTypography.size11_5,
            color: SigapColors.warningText,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

/// Full-width primary CTA button.
///
/// Design spec: bg #0f7a6b, white text, radius 12px, padding 15px, font 15px weight 700
class _SubmitButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const _SubmitButton({
    required this.label,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: SigapSpacing.x15),
        decoration: BoxDecoration(
          color: SigapColors.primary,
          borderRadius: BorderRadius.circular(SigapRadius.x12),
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
            : Text(
                label,
                style: const TextStyle(
                  fontSize: SigapTypography.size15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}

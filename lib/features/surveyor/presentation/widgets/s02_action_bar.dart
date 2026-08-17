import 'package:flutter/material.dart';
import 'package:sigap/l10n/strings.dart';
import 'package:sigap/theme/tokens.dart';

/// Action bar widget for S-02 surveyor task detail screen.
///
/// A bottom action bar containing three buttons: Tolak, Minta Clarifikasi, and Terima Tugas.
/// Buttons are displayed in a full-width row with equal spacing.
///
/// Design tokens used:
/// - "Tolak" button: outline/danger style (OutlinedButton with danger colors)
/// - "Minta Clarifikasi" button: secondary style (OutlinedButton with borderCard)
/// - "Terima Tugas" button: primary filled style (ElevatedButton with primary)
///
/// Example:
/// ```dart
/// S02ActionBar(
///   onTolak: () => print('Tolak'),
///   onMintaClarifikasi: () => print('Clarifikasi'),
///   onTerima: () => print('Terima'),
/// )
/// ```
class S02ActionBar extends StatelessWidget {
  /// Callback when "Tolak" button is pressed.
  final VoidCallback? onTolak;

  /// Callback when "Minta Clarifikasi" button is pressed.
  final VoidCallback? onMintaClarifikasi;

  /// Callback when "Terima Tugas" button is pressed.
  final VoidCallback? onTerima;

  /// Creates an S02ActionBar widget.
  ///
  /// All three callbacks are optional but should be provided for interactive buttons.
  const S02ActionBar({
    super.key,
    this.onTolak,
    this.onMintaClarifikasi,
    this.onTerima,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.x12,
      ),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        border: Border(top: BorderSide(color: AppColors.borderCard)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Tolak button - outline/danger style
            Expanded(child: _TolakButton(onPressed: onTolak)),
            const SizedBox(width: AppSpacing.x7),

            // Minta Clarifikasi button - secondary style
            Expanded(
              child: _MintaClarifikasiButton(onPressed: onMintaClarifikasi),
            ),
            const SizedBox(width: AppSpacing.x7),

            // Terima Tugas button - primary filled style
            Expanded(child: _TerimaTugasButton(onPressed: onTerima)),
          ],
        ),
      ),
    );
  }
}

/// "Tolak" button with outline/danger styling.
class _TolakButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const _TolakButton({this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.dangerTextStrong,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.x12),
        side: const BorderSide(color: AppColors.dangerBorder),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      child: Text(
        Strings.tolak,
        style: const TextStyle(
          fontSize: AppTypography.size13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// "Minta Clarifikasi" button with secondary styling.
class _MintaClarifikasiButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const _MintaClarifikasiButton({this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textSecondary,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.x12),
        side: const BorderSide(color: AppColors.borderCard),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      child: Text(
        'Minta Clarifikasi',
        style: const TextStyle(
          fontSize: AppTypography.size13,
          fontWeight: FontWeight.w600,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

/// "Terima Tugas" button with primary filled styling.
class _TerimaTugasButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const _TerimaTugasButton({this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.x12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        elevation: 0,
      ),
      child: Text(
        'Terima Tugas',
        style: const TextStyle(
          fontSize: AppTypography.size13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:sigap/l10n/strings.dart';
import 'package:sigap/theme/tokens.dart';

/// Action bar widget for S-02 surveyor task detail screen.
///
/// A bottom action bar containing four buttons: Tolak, Minta Clarifikasi, Terima Tugas, and Kunjungi.
/// Buttons are displayed in a full-width row with equal spacing.
///
/// Design tokens used:
/// - "Tolak" button: outline/danger style (OutlinedButton with danger colors)
/// - "Minta Clarifikasi" button: secondary style (OutlinedButton with borderCard)
/// - "Terima Tugas" button: primary filled style (ElevatedButton with primary)
/// - "Kunjungi" button: primary filled style (ElevatedButton with primary), enabled after accept
///
/// Example:
/// ```dart
/// S02ActionBar(
///   onTolak: () { /* Handle tolak */ },
///   onMintaClarifikasi: () { /* Handle clarifikasi */ },
///   onTerima: () { /* Handle terima */ },
///   onKunjungi: () { /* Handle mulai survei */ },
/// )
/// ```
class S02ActionBar extends StatelessWidget {
  /// Callback when "Tolak" button is pressed.
  final VoidCallback? onTolak;

  /// Callback when "Minta Clarifikasi" button is pressed.
  final VoidCallback? onMintaClarifikasi;

  /// Callback when "Terima Tugas" button is pressed.
  final VoidCallback? onTerima;

  /// Callback when "Kunjungi" (Mulai Survei) button is pressed.
  final VoidCallback? onKunjungi;

  /// Creates an S02ActionBar widget.
  ///
  /// All callbacks are optional but should be provided for interactive buttons.
  const S02ActionBar({
    super.key,
    this.onTolak,
    this.onMintaClarifikasi,
    this.onTerima,
    this.onKunjungi,
  });

  @override
  Widget build(BuildContext context) {
    // Show different primary action based on whether Kunjungi is available
    // If onKunjungi is provided and enabled, show Kunjungi; otherwise show Terima
    final hasKunjungi = onKunjungi != null;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SigapSpacing.md,
        vertical: SigapSpacing.x12,
      ),
      decoration: BoxDecoration(
        color: SigapColors.bgCard,
        border: Border(top: BorderSide(color: SigapColors.borderCard)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Tolak button - outline/danger style
            Expanded(child: _TolakButton(onPressed: onTolak)),
            const SizedBox(width: SigapSpacing.x7),

            // Minta Clarifikasi button - secondary style
            Expanded(
              child: _MintaClarifikasiButton(onPressed: onMintaClarifikasi),
            ),
            const SizedBox(width: SigapSpacing.x7),

            // Primary action: Kunjungi (if enabled) or Terima
            Expanded(
              child: hasKunjungi
                  ? _KunjungiButton(onPressed: onKunjungi)
                  : _TerimaTugasButton(onPressed: onTerima),
            ),
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
        foregroundColor: SigapColors.dangerTextStrong,
        padding: const EdgeInsets.symmetric(vertical: SigapSpacing.x12),
        side: const BorderSide(color: SigapColors.dangerBorder),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SigapRadius.md),
        ),
      ),
      child: Text(
        Strings.tolak,
        style: const TextStyle(
          fontSize: SigapTypography.size13,
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
        foregroundColor: SigapColors.textSecondary,
        padding: const EdgeInsets.symmetric(vertical: SigapSpacing.x12),
        side: const BorderSide(color: SigapColors.borderCard),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SigapRadius.md),
        ),
      ),
      child: Text(
        'Minta Clarifikasi',
        style: const TextStyle(
          fontSize: SigapTypography.size13,
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
        backgroundColor: SigapColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: SigapSpacing.x12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SigapRadius.md),
        ),
        elevation: 0,
      ),
      child: Text(
        'Terima Tugas',
        style: const TextStyle(
          fontSize: SigapTypography.size13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// "Kunjungi" (Mulai Survei) button with primary filled styling.
class _KunjungiButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const _KunjungiButton({this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: SigapColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: SigapSpacing.x12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SigapRadius.md),
        ),
        elevation: 0,
      ),
      child: Text(
        'Kunjungi',
        style: const TextStyle(
          fontSize: SigapTypography.size13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

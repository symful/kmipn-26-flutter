import 'package:flutter/material.dart';
import 'package:sigap/l10n/generated/app_localizations.dart';
import 'package:sigap/theme/tokens.dart';

/// Action bar widget for petugas task detail screen.
///
/// A bottom action bar containing four buttons: Tolak, Clarifikasi, Kunjungi, and Terima.
/// All four buttons are displayed simultaneously in a full-width row with equal spacing.
///
/// Design tokens used:
/// - "Tolak" button: outline/danger style (OutlinedButton with danger colors)
/// - "Clarifikasi" button: secondary style (OutlinedButton with borderCard)
/// - "Kunjungi" button: primary filled style (ElevatedButton with primary)
/// - "Terima" button: primary filled style (ElevatedButton with primary)
///
/// Example:
/// ```dart
/// PetugasActionBar(
///   onTolak: () { /* Handle tolak */ },
///   onMintaClarifikasi: () { /* Handle clarifikasi */ },
///   onTerima: () { /* Handle terima */ },
///   onKunjungi: () { /* Handle kunjungan */ },
/// )
/// ```
class PetugasActionBar extends StatelessWidget {
  /// Callback when "Tolak" button is pressed.
  final VoidCallback? onTolak;

  /// Callback when "Clarifikasi" button is pressed.
  final VoidCallback? onMintaClarifikasi;

  /// Callback when "Terima" button is pressed.
  final VoidCallback? onTerima;

  /// Callback when "Kunjungi" button is pressed.
  final VoidCallback? onKunjungi;

  /// Creates a PetugasActionBar widget.
  ///
  /// All callbacks are optional but should be provided for interactive buttons.
  const PetugasActionBar({
    super.key,
    this.onTolak,
    this.onMintaClarifikasi,
    this.onTerima,
    this.onKunjungi,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
            // Tolak
            Expanded(
              child: ActionButton(
                label: l10n.tolak,
                onPressed: onTolak,
                isDanger: true,
              ),
            ),
            const SizedBox(width: SigapSpacing.x7),

            // Clarifikasi
            Expanded(
              child: ActionButton(
                label: l10n.klarifikasi,
                onPressed: onMintaClarifikasi,
                isSecondary: true,
              ),
            ),
            const SizedBox(width: SigapSpacing.x7),

            // Kunjungi (primary)
            Expanded(
              child: ActionButton(
                label: l10n.kunjungi,
                onPressed: onKunjungi,
                isPrimary: true,
              ),
            ),
            const SizedBox(width: SigapSpacing.x7),

            // Terima
            Expanded(
              child: ActionButton(
                label: l10n.terima,
                onPressed: onTerima,
                isPrimary: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Reusable action button with danger, secondary, and primary variants.
class ActionButton extends StatelessWidget {
  /// Button label text.
  final String label;

  /// Callback when button is pressed.
  final VoidCallback? onPressed;

  /// Whether this is a danger/outline button (e.g., Tolak).
  final bool isDanger;

  /// Whether this is a secondary/outline button (e.g., Clarifikasi).
  final bool isSecondary;

  /// Whether this is a primary filled button (e.g., Terima, Kunjungi).
  final bool isPrimary;

  /// Creates an ActionButton widget.
  const ActionButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isDanger = false,
    this.isSecondary = false,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isDanger) {
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
          label,
          style: const TextStyle(
            fontSize: SigapTypography.captionMedium,
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      );
    }

    if (isSecondary) {
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
          label,
          style: const TextStyle(
            fontSize: SigapTypography.captionMedium,
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      );
    }

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
        label,
        style: const TextStyle(
          fontSize: SigapTypography.captionMedium,
          fontWeight: FontWeight.w600,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

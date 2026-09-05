import 'package:flutter/material.dart';
import 'package:sigap/l10n/generated/app_localizations.dart';
import 'package:sigap/theme/tokens.dart';

/// A simple animated toggle switch.
///
/// Design spec: 42x24, animated thumb slide.
class PrivacyToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const PrivacyToggle({super.key, required this.value, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onChanged != null ? () => onChanged!(!value) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 42,
        height: 24,
        decoration: BoxDecoration(
          color: value ? SigapColors.primary : SigapColors.borderSoft,
          borderRadius: BorderRadius.circular(12),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: const BoxDecoration(
              color: SigapColors.surface,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

/// Privacy toggle widget for M-11 Review Kiriman screen.
///
/// Allows users to choose whether their identity is shown publicly or kept private.
///
/// Design spec from PantauDesa Screens.dc.html (M-11, line 186):
/// - Title: "Identitas saya di publik"
/// - Subtitle: "Default: privat · hanya petugas melihat"
/// - Toggle: 42x24, animated
class PrivacyToggleCard extends StatelessWidget {
  /// Current toggle value. When true, identity is shown publicly.
  final bool value;

  /// Called when user toggles the switch.
  final ValueChanged<bool>? onChanged;

  const PrivacyToggleCard({super.key, required this.value, this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(SigapSpacing.x12),
      decoration: BoxDecoration(
        color: SigapColors.bgCard,
        borderRadius: BorderRadius.circular(SigapRadius.lg),
        border: Border.all(color: SigapColors.borderCard),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.identitasPublik,
                  style: TextStyle(
                    fontSize: SigapTypography.bodyText,
                    fontWeight: FontWeight.w600,
                    color: SigapColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  l10n.defaultPrivatPetugas,
                  style: TextStyle(
                    fontSize: SigapTypography.captionMedium,
                    color: SigapColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: SigapSpacing.md),
          GestureDetector(
            onTap: () => _showInfoTooltip(context),
            child: Tooltip(
              message: l10n.keteranganPrivasiTooltip,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: SigapColors.textTertiary,
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  'i',
                  style: TextStyle(
                    fontSize: SigapTypography.captionMedium,
                    fontWeight: FontWeight.w700,
                    color: SigapColors.textTertiary,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: SigapSpacing.sm),
          PrivacyToggle(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  void _showInfoTooltip(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SigapRadius.lg),
        ),
        title: Text(
          l10n.tentangPrivasi,
          style: TextStyle(
            fontSize: SigapTypography.bodyMedium,
            fontWeight: FontWeight.w600,
            color: SigapColors.textPrimary,
          ),
        ),
        content: Text(
          l10n.identitasLokasiPrivasi,
          style: TextStyle(
            fontSize: SigapTypography.bodySmall,
            color: SigapColors.textSecondary,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              l10n.tutup,
              style: TextStyle(
                color: SigapColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

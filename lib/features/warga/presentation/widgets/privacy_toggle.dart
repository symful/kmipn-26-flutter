import 'package:flutter/material.dart';
import 'package:sigap/theme/tokens.dart';
import 'package:sigap/widgets/design_system/privacy_toggle.dart' as ds;

/// Privacy toggle widget for M-11 Review Kiriman screen.
///
/// Allows users to choose whether their identity is shown publicly or kept private.
///
/// Design spec from PantauDesa Screens.dc.html (M-11, line 186):
/// - Title: "Identitas saya di publik"
/// - Subtitle: "Default: privat · hanya petugas melihat"
/// - Toggle: 42x24, animated
class PrivacyToggle extends StatelessWidget {
  /// Current toggle value. When true, identity is shown publicly.
  final bool value;

  /// Called when user toggles the switch.
  final ValueChanged<bool>? onChanged;

  const PrivacyToggle({super.key, required this.value, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onChanged != null ? () => onChanged!(!value) : null,
      child: Container(
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
                    'Identitas saya di publik',
                    style: TextStyle(
                      fontSize: SigapTypography.size13,
                      fontWeight: FontWeight.w600,
                      color: SigapColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    'Default: privat · hanya petugas melihat',
                    style: TextStyle(
                      fontSize: SigapTypography.size11,
                      color: SigapColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: SigapSpacing.md),
            // Info tooltip icon (stops propagation so it doesn't trigger toggle)
            GestureDetector(
              onTap: () => _showInfoTooltip(context),
              child: Tooltip(
                message:
                    'Jika aktif, nama Anda terlihat oleh publik. Lokasi tetap digeneralisasi.',
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
                      fontSize: SigapTypography.size11,
                      fontWeight: FontWeight.w700,
                      color: SigapColors.textTertiary,
                      height: 1,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: SigapSpacing.sm),
            // Toggle switch from design system
            ds.PrivacyToggle(value: value, onChanged: onChanged),
          ],
        ),
      ),
    );
  }

  void _showInfoTooltip(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SigapRadius.lg),
        ),
        title: Text(
          'Tentang Privasi',
          style: TextStyle(
            fontSize: SigapTypography.size14,
            fontWeight: FontWeight.w600,
            color: SigapColors.textPrimary,
          ),
        ),
        content: Text(
          'Identitas dan lokasi presisi Anda hanya terlihat oleh petugas terkait. '
          'Publik hanya melihat lokasi yang digeneralisasi.',
          style: TextStyle(
            fontSize: SigapTypography.size12,
            color: SigapColors.textSecondary,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Tutup',
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

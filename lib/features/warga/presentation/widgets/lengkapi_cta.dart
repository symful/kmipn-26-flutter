import 'package:flutter/material.dart';
import 'package:sigap/theme/tokens.dart';

/// "Lengkapi laporan" CTA button widget.
///
/// Matches PantauDesa design spec:
/// - background: #0f7a6b (SigapColors.primary)
/// - color: #fff
/// - border-radius: 10px (SigapRadius.x10)
/// - padding: 11px 16px
/// - font-size: 13px (SigapTypography.size13)
/// - font-weight: 700
/// - width: 100%
/// - margin-top: 11px
///
/// Used in Detail Laporan screen status action banner.
class LengkapiCta extends StatelessWidget {
  /// Called when the CTA button is tapped.
  final VoidCallback? onTap;

  const LengkapiCta({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: SigapSpacing.x11),
        padding: const EdgeInsets.symmetric(
          vertical: SigapSpacing.x11,
          horizontal: SigapSpacing.lg,
        ),
        decoration: BoxDecoration(
          color: SigapColors.primary,
          borderRadius: BorderRadius.circular(SigapRadius.x10),
        ),
        alignment: Alignment.center,
        child: const Text(
          'Lengkapi laporan',
          style: TextStyle(
            fontSize: SigapTypography.size13,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

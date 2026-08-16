import 'package:flutter/material.dart';
import 'package:sigap/theme/tokens.dart';

/// M-14 privacy notice inline widget for warga report detail view.
///
/// Displays an info banner explaining that user identity and precise location
/// are only visible to relevant officials, not the public.
///
/// Design spec from PantauDesa Screens.dc.html (M-14, lines 237-241):
/// - Background: #eef0ec, 11px border-radius
/// - Padding: 11px 12px
/// - Gap: 9px between icon and text
/// - Icon: 18x18 circle with 2px border, "i" letter
/// - Text: 11.5px, #4a5058, line-height 1.4
class M14PrivacyNotice extends StatelessWidget {
  /// Whether to show a condensed compact variant.
  final bool compact;

  const M14PrivacyNotice({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgSoft,
        borderRadius: BorderRadius.circular(11),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.x12,
        vertical: AppSpacing.x11,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info icon circle
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.textTertiary, width: 2),
            ),
            alignment: Alignment.center,
            child: Text(
              'i',
              style: TextStyle(
                fontSize: AppTypography.size11,
                fontWeight: FontWeight.w700,
                color: AppColors.textTertiary,
                height: 1,
              ),
            ),
          ),
          SizedBox(width: AppSpacing.x9),
          // Privacy text
          Expanded(
            child: Text(
              compact
                  ? 'Identitas & lokasi presisi hanya terlihat petugas. Publik melihat lokasi digeneralisasi.'
                  : 'Identitas & lokasi presisi Anda hanya terlihat oleh petugas terkait. '
                        'Publik melihat lokasi yang digeneralisasi.',
              style: TextStyle(
                fontSize: AppTypography.size11_5,
                color: AppColors.textSoft,
                height: AppTypography.lineHeight140,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

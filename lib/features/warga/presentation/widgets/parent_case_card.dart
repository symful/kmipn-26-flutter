import 'package:flutter/material.dart';
import 'package:sigap/theme/tokens.dart';

/// Parent/related case card model.
///
/// Displayed in the Detail Laporan Saya screen to show
/// that the current report is part of a larger parent case.
class ParentCase {
  /// Short code/initials for the category badge (e.g. "JL" for "Jalan").
  final String initials;

  /// Title of the parent case (e.g. "Jalan berlubang dekat Pasar").
  final String title;

  const ParentCase({required this.initials, required this.title});
}

/// Parent case card for Detail Laporan Saya screen.
///
/// Matches PantauDesa design spec:
/// - Card: white bg, #e4e7e2 border, 12px radius, 12px padding
/// - Avatar: 34x34, 8px radius, #e2f1ee bg, #0a5c50 text, IBM Plex Mono
/// - "Bagian dari kasus" label: 11px, #616770
/// - Case title: 13px, font-weight 600
/// - "Lihat →" link: #0f7a6b, 12.5px, font-weight 600
class ParentCaseCard extends StatelessWidget {
  /// Parent case data to display.
  final ParentCase parentCase;

  /// Called when user taps the "Lihat →" link.
  final VoidCallback? onViewCase;

  const ParentCaseCard({super.key, required this.parentCase, this.onViewCase});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SigapColors.bgCard,
        border: Border.all(color: SigapColors.borderCard),
        borderRadius: BorderRadius.circular(SigapRadius.x12),
      ),
      padding: const EdgeInsets.all(SigapSpacing.x12),
      child: Row(
        children: [
          // Avatar with initials
          _Avatar(initials: parentCase.initials),
          const SizedBox(width: SigapSpacing.x10),

          // Label + title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Bagian dari kasus',
                  style: TextStyle(
                    fontSize: SigapTypography.size11,
                    color: SigapColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  parentCase.title,
                  style: TextStyle(
                    fontSize: SigapTypography.size13,
                    fontWeight: FontWeight.w600,
                    color: SigapColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          // "Lihat →" link
          GestureDetector(
            onTap: onViewCase,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Text(
                'Lihat \u2192',
                style: TextStyle(
                  fontSize: SigapTypography.size12_5,
                  fontWeight: FontWeight.w600,
                  color: SigapColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Avatar badge with initials (e.g. "JL" for "Jalan").
class _Avatar extends StatelessWidget {
  final String initials;

  const _Avatar({required this.initials});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: SigapColors.primaryLight,
        borderRadius: BorderRadius.circular(SigapRadius.sm),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          fontFamily: SigapTypography.fontFamilyMono,
          fontSize: SigapTypography.size12,
          fontWeight: FontWeight.w600,
          color: SigapColors.primaryDark,
        ),
      ),
    );
  }
}

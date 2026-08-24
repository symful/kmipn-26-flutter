import 'package:flutter/material.dart';
import 'package:sigap/theme/tokens.dart';

/// Action buttons for linking a new report to an existing case,
/// or keeping it separate.
///
/// Used in SimilarCasesBanner (M-11) to let users choose:
/// - "Tambahkan bukti ke kasus ini" (link to existing case)
/// - "Buat terpisah" (keep as separate case)
class SimilarCaseActions extends StatelessWidget {
  /// Called when user taps "Tambahkan bukti ke kasus ini" (primary action).
  final VoidCallback? onLinkToCase;

  /// Called when user taps "Buat terpisah" (secondary action).
  final VoidCallback? onCreateSeparate;

  const SimilarCaseActions({
    super.key,
    this.onLinkToCase,
    this.onCreateSeparate,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Primary: Tambahkan bukti ke kasus ini
        Expanded(
          child: GestureDetector(
            onTap: onLinkToCase,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: SigapColors.info,
                borderRadius: BorderRadius.circular(SigapRadius.x9),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Tambahkan bukti ke kasus ini',
                style: TextStyle(
                  fontSize: SigapTypography.size12_5,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: SigapSpacing.sm),
        // Secondary: Buat terpisah
        Expanded(
          child: GestureDetector(
            onTap: onCreateSeparate,
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: SigapSpacing.x12,
              ),
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(color: SigapColors.infoChartBar),
                borderRadius: BorderRadius.circular(SigapRadius.x9),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Buat terpisah',
                style: TextStyle(
                  fontSize: SigapTypography.size12_5,
                  fontWeight: FontWeight.w600,
                  color: SigapColors.info,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

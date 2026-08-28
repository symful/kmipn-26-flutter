import 'package:flutter/material.dart';
import 'package:sigap/theme/tokens.dart';

/// Instruksi card widget for S-02 surveyor task detail screen.
///
/// Displays task instructions from surveyor with a left border accent.
/// Card has white background, border, and proper padding.
///
/// Design tokens used:
/// - Background: SigapColors.bgCard (#FFFFFF)
/// - Border: SigapColors.borderCard (#E4E7E2)
/// - Accent: SigapColors.primary (#0F7A6B)
/// - Border radius: SigapRadius.x12 (12px)
/// - Padding: SigapSpacing.md (12px)
///
/// Example:
/// ```dart
/// S02InstruksiCard(
///   title: 'Instruksi',
///   body: 'Lakukan verifikasi kondisi jalan di lokasi yang tertera.',
/// )
/// ```
class S02InstruksiCard extends StatelessWidget {
  /// The instruction title/label (e.g., "Instruksi").
  final String title;

  /// The instruction body text content.
  final String body;

  /// Creates an instruksi card widget.
  ///
  /// Both [title] and [body] are required.
  const S02InstruksiCard({super.key, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SigapColors.bgCard,
        borderRadius: BorderRadius.circular(SigapRadius.x12),
        border: Border.all(color: SigapColors.borderCard),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SigapRadius.x12),
          border: Border(left: BorderSide(color: SigapColors.primary, width: 4)),
        ),
        padding: const EdgeInsets.all(SigapSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title label
            Text(
              title,
              style: const TextStyle(
                fontSize: SigapTypography.size12,
                fontWeight: FontWeight.w600,
                color: SigapColors.textTertiary,
              ),
            ),
            const SizedBox(height: SigapSpacing.sm),

            // Body text
            Text(
              body,
              style: const TextStyle(
                fontSize: SigapTypography.size13,
                height: 1.5,
                color: SigapColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

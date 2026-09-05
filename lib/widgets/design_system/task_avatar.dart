import 'package:flutter/material.dart';
import 'package:sigap/theme/tokens.dart';

/// S-01 task card avatar with SLA deadline badge overlay.
///
/// Displays a circular avatar with reporter initials and a small
/// colored pill badge indicating SLA deadline status.
class TaskAvatar extends StatelessWidget {
  /// Name of the reporter to derive initials from.
  final String reporterName;

  /// Days remaining until SLA deadline. Negative values indicate overdue.
  final int slaDaysRemaining;

  /// Avatar size in pixels (diameter). Defaults to 40.
  final double size;

  const TaskAvatar({
    super.key,
    required this.reporterName,
    required this.slaDaysRemaining,
    this.size = 40,
  });

  /// Derives initials from reporter name.
  ///
  /// Takes first letter of first two words, uppercase.
  /// Falls back to "???" if name is empty or too short.
  String get _initials {
    if (reporterName.trim().isEmpty) return '???';
    final words = reporterName.trim().split(RegExp(r'\s+'));
    if (words.length == 1) {
      return words[0].isNotEmpty ? words[0][0].toUpperCase() : '?';
    }
    final first = words[0].isNotEmpty ? words[0][0] : '';
    final second = words[1].isNotEmpty ? words[1][0] : '';
    return '$first$second'.toUpperCase();
  }

  /// Background color for SLA badge based on days remaining.
  ///
  /// - Green (>2 days): SigapColors.primary
  /// - Amber (1-2 days): SigapColors.warning
  /// - Red (<1 day or overdue): SigapColors.danger
  Color get _badgeColor {
    if (slaDaysRemaining > 2) {
      return SigapColors.primary;
    } else if (slaDaysRemaining >= 1) {
      return SigapColors.warning;
    } else {
      return SigapColors.danger;
    }
  }

  /// Text to display on SLA badge.
  ///
  /// Shows "{days}d" format, or "Ovd" for overdue (negative days).
  String get _badgeText {
    if (slaDaysRemaining < 0) {
      return 'Ovd';
    }
    return '${slaDaysRemaining}d';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size + 12, // Extra space for badge
      height: size + 12,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Avatar circle with initials
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: SigapColors.primaryLight,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                _initials,
                style: TextStyle(
                  fontFamily: SigapTypography.fontFamilyMono,
                  fontSize: size * 0.35,
                  fontWeight: FontWeight.w600,
                  color: SigapColors.primaryDark,
                ),
              ),
            ),
          ),

          // SLA badge positioned at bottom-right
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: SigapSpacing.x4,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: _badgeColor,
                borderRadius: BorderRadius.circular(SigapRadius.pill),
                // Small shadow for depth
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x40000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                _badgeText,
                style: const TextStyle(
                  fontSize: SigapTypography.captionMicro,
                  fontWeight: FontWeight.w600,
                  color: SigapColors.surface,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

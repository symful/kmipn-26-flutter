import 'package:flutter/material.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'package:sigap/theme/tokens.dart';

/// A centered placeholder shown when user lacks permission to view content.
///
/// Usage:
/// ```dart
/// AccessDeniedCard(
///   message: 'Anda tidak memiliki akses untuk memverifikasi kasus ini.',
/// )
/// ```
class AccessDeniedCard extends StatelessWidget {
  /// Creates an [AccessDeniedCard].
  ///
  /// - [message]: Explanation text shown below the title
  /// - [icon]: Optional custom icon (defaults to lock_outline)
  /// - [title]: Optional custom title (defaults to 'Akses Ditolak')
  const AccessDeniedCard({
    super.key,
    required this.message,
    this.icon,
    this.title,
  });

  /// Explanation text shown below the title.
  final String message;

  /// Optional custom icon (defaults to Icons.lock_outline).
  final IconData? icon;

  /// Optional custom title (defaults to 'Akses Ditolak').
  final String? title;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SigapSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon ?? Icons.lock_outline,
              size: 64,
              color: SigapColors.textMuted,
            ),
            const SizedBox(height: 16),
            Text(
              title ?? l10n.aksesDitolakTitle,
              style: TextStyle(
                fontSize: SigapTypography.titleLarge,
                fontWeight: FontWeight.bold,
                color: SigapColors.textPrimary,
              ),
            ),
            const SizedBox(height: SigapSpacing.sm),
            Text(
              message,
              style: TextStyle(
                fontSize: SigapTypography.bodyMedium,
                color: SigapColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact inline access denied text (for smaller spaces).
class AccessDeniedInline extends StatelessWidget {
  const AccessDeniedInline({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.lock_outline, size: 16, color: SigapColors.textMuted),
        const SizedBox(width: SigapSpacing.xs),
        Expanded(
          child: Text(
            message,
            style: TextStyle(
              fontSize: SigapTypography.bodySmall,
              color: SigapColors.textMuted,
            ),
          ),
        ),
      ],
    );
  }
}

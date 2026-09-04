import 'package:flutter/material.dart';
import 'package:sigap/theme/tokens.dart';
import 'package:sigap/widgets/design_system/sigap_card.dart';

/// A card displaying an error state with an optional retry action.
///
/// Usage:
/// ```dart
/// ErrorCard(
///   message: 'Gagal memuat data',
///   onRetry: () => ref.invalidate(someProvider),
/// )
/// ```
class ErrorCard extends StatelessWidget {
  /// Creates an [ErrorCard].
  ///
  /// - [message]: Error message to display
  /// - [onRetry]: Optional callback for retry button
  /// - [retryLabel]: Optional custom retry button label
  /// - [icon]: Optional custom icon (defaults to error_outline)
  /// - [compact]: If true, uses compact layout (no card border)
  const ErrorCard({
    super.key,
    required this.message,
    this.onRetry,
    this.retryLabel,
    this.icon,
    this.compact = false,
  });

  /// Error message to display.
  final String message;

  /// Optional callback for retry button.
  final VoidCallback? onRetry;

  /// Optional custom retry button label.
  final String? retryLabel;

  /// Optional custom icon (defaults to error_outline).
  final IconData? icon;

  /// If true, uses compact layout without card border.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final iconWidget = Icon(
      icon ?? Icons.error_outline,
      color: SigapColors.perluTindakan,
      size: compact ? 24 : 48,
    );

    final textWidget = Text(
      message,
      style: TextStyle(
        color: compact ? SigapColors.textSecondary : SigapColors.textPrimary,
        fontSize: compact ? SigapTypography.bodyText : SigapTypography.bodyMedium,
        fontWeight: compact ? FontWeight.w400 : FontWeight.w500,
      ),
    );

    if (compact) {
      return Container(
        padding: const EdgeInsets.all(SigapSpacing.md),
        decoration: BoxDecoration(
          color: SigapColors.surface,
          borderRadius: BorderRadius.circular(SigapRadius.md),
          border: Border.all(color: SigapColors.border),
        ),
        child: Row(
          children: [
            iconWidget,
            const SizedBox(width: SigapSpacing.sm),
            Expanded(child: textWidget),
            if (onRetry != null)
              TextButton(
                onPressed: onRetry,
                style: TextButton.styleFrom(
                  foregroundColor: SigapColors.primary,
                  minimumSize: const Size(48, 48),
                ),
                child: Text(
                  retryLabel ?? 'Coba lagi',
                  style: const TextStyle(fontSize: SigapTypography.bodyText),
                ),
              ),
          ],
        ),
      );
    }

    return SigapCard(
      padding: const EdgeInsets.all(SigapSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          iconWidget,
          const SizedBox(height: SigapSpacing.md),
          textWidget,
          if (onRetry != null) ...[
            const SizedBox(height: SigapSpacing.lg),
            ElevatedButton(
              onPressed: onRetry,
              child: Text(retryLabel ?? 'Coba lagi'),
            ),
          ],
        ],
      ),
    );
  }
}

/// Inline error banner with text and optional retry.
class ErrorBanner extends StatelessWidget {
  const ErrorBanner({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SigapSpacing.md,
        vertical: SigapSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: SigapColors.perluTindakan.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(SigapRadius.sm),
        border: Border.all(color: SigapColors.perluTindakan),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            size: 16,
            color: SigapColors.perluTindakan,
          ),
          const SizedBox(width: SigapSpacing.sm),
          Flexible(
            child: Text(
              message,
              style: TextStyle(
                color: SigapColors.perluTindakan,
                fontSize: SigapTypography.bodyText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: SigapSpacing.sm),
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                foregroundColor: SigapColors.perluTindakan,
                minimumSize: const Size(48, 48),
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              child: const Text('Coba lagi', style: TextStyle(fontSize: 12)),
            ),
          ],
        ],
      ),
    );
  }
}

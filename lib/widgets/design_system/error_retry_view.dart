import 'package:flutter/material.dart';
import '../../theme/tokens.dart';
import 'a11y.dart';

/// A minimal stateless error state widget with a retry action.
///
/// Used in AsyncError branches of warga screens to replace blank zeros
/// or error states that show no actionable feedback.
///
/// Usage:
/// ```dart
/// error: (error, _) => ErrorRetryView(
///   message: 'Gagal memuat data',
///   onRetry: () => ref.invalidate(someProvider),
/// ),
/// ```
class ErrorRetryView extends StatelessWidget {
  /// The error message to display (Indonesian).
  final String message;

  /// Callback to retry the failed operation.
  final VoidCallback onRetry;

  /// Optional retry button label (defaults to 'Coba lagi').
  final String? retryLabel;

  /// Optional icon to display (defaults to error icon).
  final IconData? icon;

  const ErrorRetryView({
    super.key,
    required this.message,
    required this.onRetry,
    this.retryLabel,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SigapSpacing.md),
      decoration: BoxDecoration(
        color: SigapColors.surface,
        borderRadius: BorderRadius.circular(SigapRadius.md),
        border: Border.all(color: SigapColors.border),
      ),
      child: Row(
        children: [
          Icon(
            icon ?? Icons.error_outline,
            color: SigapColors.perluTindakan,
            size: 24,
          ),
          const SizedBox(width: SigapSpacing.sm),
          Expanded(
            child: Semantics(
              label: message,
              child: Text(
                message,
                style: const TextStyle(
                  color: SigapColors.textSecondary,
                  fontSize: SigapTypography.size13,
                ),
              ),
            ),
          ),
          MinTapTarget(
            semanticsLabel: retryLabel ?? 'Coba lagi',
            child: TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                foregroundColor: SigapColors.primary,
                minimumSize: const Size(kMinTapTarget, kMinTapTarget),
              ),
              child: Text(
                retryLabel ?? 'Coba lagi',
                style: const TextStyle(fontSize: SigapTypography.size13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

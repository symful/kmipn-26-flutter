import 'package:flutter/material.dart';
import '../theme/tokens.dart';

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

  /// Optional icon to display (defaults to error icon).
  final IconData? icon;

  const ErrorRetryView({
    super.key,
    required this.message,
    required this.onRetry,
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
            child: Text(
              message,
              style: const TextStyle(
                color: SigapColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: const Text('Coba lagi', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

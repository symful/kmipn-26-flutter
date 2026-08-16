import 'package:flutter/material.dart';
import 'package:sigap/theme/tokens.dart';

/// A checkbox widget with a truth statement for report submission.
///
/// Displays a styled checkbox with the statement text
/// "Saya menyatakan informasi ini benar sesuai kondisi yang saya lihat."
///
/// Design spec: PantauDesa M-11, "privasi + truth" section (line 187).
class TruthStatementCheckbox extends StatelessWidget {
  /// Whether the checkbox is currently checked.
  final bool value;

  /// Callback when the checkbox is toggled.
  final ValueChanged<bool>? onChanged;

  const TruthStatementCheckbox({
    super.key,
    required this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onChanged != null ? () => onChanged!(!value) : null,
      behavior: HitTestBehavior.opaque,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Checkbox
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: value ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(5), // Design: 5px
              border: value
                  ? null
                  : Border.all(color: AppColors.borderSoft, width: 1.5),
            ),
            alignment: Alignment.center,
            child: value
                ? const Icon(Icons.check, size: 12, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 9),

          // Statement text
          Expanded(
            child: Text(
              'Saya menyatakan informasi ini benar sesuai kondisi yang saya lihat.',
              style: TextStyle(
                fontSize: AppTypography.size12,
                fontWeight: FontWeight.w400,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

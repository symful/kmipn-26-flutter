import 'package:flutter/material.dart';
import 'package:sigap/theme/tokens.dart';

/// A row widget displaying a location with an edit button.
///
/// Used in M-11 Review Kiriman screen as part of the report summary card.
/// Shows location address + accuracy with a pencil edit icon.
///
/// Design spec: PantauDesa Screens.dc.html line 180
class LocationRowEdit extends StatelessWidget {
  /// The main address text (e.g., "Jl. Raya Ciburuy").
  final String address;

  /// The accuracy text shown after the separator (e.g., "Akurasi baik").
  final String accuracy;

  /// Called when the edit button (pencil icon) is tapped.
  final VoidCallback? onEdit;

  const LocationRowEdit({
    super.key,
    required this.address,
    required this.accuracy,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x12,
        vertical: AppSpacing.x10,
      ),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.bgSoft, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Label "Lokasi"
          Text(
            'Lokasi',
            style: TextStyle(
              fontSize: AppTypography.size12,
              color: AppColors.textTertiary,
            ),
          ),
          // Value: address · accuracy + edit icon
          Flexible(
            child: GestureDetector(
              onTap: onEdit,
              behavior: HitTestBehavior.opaque,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      '$address · $accuracy ',
                      style: const TextStyle(
                        fontSize: AppTypography.size12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(
                    Icons.edit_outlined,
                    size: 14,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

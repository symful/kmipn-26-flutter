import 'package:flutter/material.dart';
import 'package:sigap/l10n/generated/app_localizations.dart';
import 'package:sigap/theme/tokens.dart';

/// Formats [bytes] into a human-readable Indonesian-size string.
///
/// Rules:
/// - ≥ 1 GB (1 073 741 824 B) → "X,X GB" (1 decimal)
/// - otherwise → "X,X MB" (1 decimal, never "0,0 MB"; minimum 0,1 MB)
/// Uses decimal MB (1 MB = 1 000 000 B) but binary GB threshold.
String formatPayloadSize(int bytes) {
  if (bytes <= 0) return '';

  const int gbBytes = 1073741824; // 2^30
  const int mbBytes = 1000000;

  if (bytes >= gbBytes) {
    final gb = bytes / gbBytes;
    final rounded = (gb * 10).roundToDouble() / 10; // 1 decimal
    final clamped = rounded < 0.1 ? 0.1 : rounded;
    return '${clamped.toStringAsFixed(1).replaceAll('.', ',')} GB';
  }

  final mb = bytes / mbBytes;
  final rounded = (mb * 10).roundToDouble() / 10;
  final clamped = rounded < 0.1 ? 0.1 : rounded;
  return '${clamped.toStringAsFixed(1).replaceAll('.', ',')} MB';
}

/// Offline ready banner for surveyor task detail screen (S-02 region).
///
/// Displays a subtle card indicating the task is available for offline use.
/// Shows a cloud-off icon with "Peta area + bukti diunduh" text and an
/// optional payload size suffix.
///
/// Returns an empty widget when the task is not available for offline use.
class S02OfflineBanner extends StatelessWidget {
  /// Whether the task has been downloaded and is available for offline use.
  final bool isOfflineReady;

  /// Estimated total offline payload in bytes (map tiles + evidence photos).
  /// When `null` or `≤ 0` the size segment is omitted from the subtitle.
  final int? payloadBytes;

  const S02OfflineBanner({
    super.key,
    required this.isOfflineReady,
    this.payloadBytes,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (!isOfflineReady) {
      return const SizedBox.shrink();
    }

    final sizeStr = (payloadBytes != null && payloadBytes! > 0)
        ? ' · ${formatPayloadSize(payloadBytes!)}'
        : '';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SigapSpacing.md,
        vertical: SigapSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: SigapColors.warningBg,
        borderRadius: BorderRadius.circular(SigapRadius.md),
        border: Border.all(color: SigapColors.warningBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_off,
            size: SigapTypography.bodySmall,
            color: SigapColors.warning,
          ),
          const SizedBox(width: SigapSpacing.xs),
          Text(
            '${l10n.petaAreaBuktiDiunduh}$sizeStr',
            style: TextStyle(
              fontSize: SigapTypography.bodySmall,
              fontWeight: FontWeight.w500,
              color: SigapColors.warningText,
            ),
          ),
        ],
      ),
    );
  }
}

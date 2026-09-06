import 'package:intl/intl.dart';
import 'package:sigap/theme/sigap_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:sigap/l10n/generated/app_localizations.dart';
import 'package:sigap/theme/tokens.dart';

/// S-04 GPS Card widget for field visit form screen.
///
/// Displays current GPS coordinates with accuracy indicator and timestamp.
///
/// The accuracy indicator shows color based on accuracy value:
/// - Green (primary): accuracy < 10 meters (baik)
/// - Amber (warning): accuracy 10-50 meters (sedang)
/// - Red (danger): accuracy > 50 meters (buruk)
///
/// Design tokens used:
/// - Card background: SigapColorScheme.of(context).bgCard (#FFFFFF)
/// - Card border: SigapColorScheme.of(context).borderCard (#E4E7E2)
/// - Primary text: SigapColorScheme.of(context).textPrimary (#17191C)
/// - Secondary text: SigapColorScheme.of(context).textSecondary (#3A3F45)
/// - Tertiary text: SigapColorScheme.of(context).textTertiary (#616770)
/// - Map pin icon: SigapColors.primary (#0F7A6B)
///
/// Example:
/// ```dart
/// GpsCaptureCard(
///   latitude: -6.2087634,
///   longitude: 106.845599,
///   accuracyMeters: 5.2,
///   timestamp: DateTime.now(),
/// )
/// ```
class GpsCaptureCard extends StatelessWidget {
  /// The current latitude coordinate.
  final double latitude;

  /// The current longitude coordinate.
  final double longitude;

  /// GPS accuracy in meters.
  final double accuracyMeters;

  /// Timestamp when the GPS was captured.
  final DateTime? timestamp;

  /// Optional callback when the GPS card is tapped to refresh location.
  final VoidCallback? onRefresh;

  /// Creates an S-04 GPS card widget.
  ///
  /// All parameters except [onRefresh] are required.
  const GpsCaptureCard({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.accuracyMeters,
    this.timestamp,
    this.onRefresh,
  });

  /// Returns the accuracy status based on meters.
  ///
  /// - [AccuracyStatus.good] if accuracy < 10 meters
  /// - [AccuracyStatus.moderate] if accuracy 10-50 meters
  /// - [AccuracyStatus.poor] if accuracy > 50 meters
  static AccuracyStatus getAccuracyStatus(double meters) {
    if (meters < 10) return AccuracyStatus.good;
    if (meters <= 50) return AccuracyStatus.moderate;
    return AccuracyStatus.poor;
  }

  /// Returns a human-readable label for the accuracy status.
  static String getAccuracyLabel(AccuracyStatus status, AppLocalizations l10n) {
    switch (status) {
      case AccuracyStatus.good:
        return l10n.akurasiBaik;
      case AccuracyStatus.moderate:
        return l10n.akurasiSedang;
      case AccuracyStatus.poor:
        return l10n.akurasiBuruk;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final status = getAccuracyStatus(accuracyMeters);
    final accuracyColor = _getAccuracyColor(status);
    final accuracyLabel = getAccuracyLabel(status, l10n);

    return Container(
      decoration: BoxDecoration(
        color: SigapColorScheme.of(context).bgCard,
        borderRadius: BorderRadius.circular(SigapRadius.lg),
        border: Border.all(color: SigapColorScheme.of(context).borderCard),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onRefresh,
          borderRadius: BorderRadius.circular(SigapRadius.lg),
          child: Padding(
            padding: const EdgeInsets.all(SigapSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row with map pin icon and "Lokasi GPS" label
                _buildHeader(context),
                const SizedBox(height: SigapSpacing.sm),
                // Coordinates display
                _buildCoordinates(context),
                const SizedBox(height: SigapSpacing.sm),
                // Accuracy indicator row
                _buildAccuracyRow(
                  context,
                  status,
                  accuracyColor,
                  accuracyLabel,
                ),
                // Timestamp
                if (timestamp != null) ...[
                  const SizedBox(height: SigapSpacing.x4),
                  _buildTimestamp(context),
                ],
                const SizedBox(height: SigapSpacing.sm),
                Text(
                  l10n.gpsReadingExplanation,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the header row with map pin icon and label.
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.location_on, size: 18, color: SigapColors.primary),
        const SizedBox(width: SigapSpacing.x4),
        Text(
          AppLocalizations.of(context)!.lokasiGPS,
          style: TextStyle(
            fontSize: SigapTypography.bodySmall,
            fontWeight: FontWeight.w600,
            color: SigapColorScheme.of(context).textSecondary,
          ),
        ),
        const Spacer(),
        if (onRefresh != null)
          GestureDetector(
            onTap: onRefresh,
            child: Icon(
              Icons.refresh,
              size: 16,
              color: SigapColorScheme.of(context).textTertiary,
            ),
          ),
      ],
    );
  }

  /// Builds the coordinates display row.
  Widget _buildCoordinates(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Format coordinates to 6 decimal places
    final latStr = latitude.toStringAsFixed(6);
    final lngStr = longitude.toStringAsFixed(6);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.latitude,
                style: TextStyle(
                  fontSize: SigapTypography.captionSmall,
                  color: SigapColorScheme.of(context).textTertiary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                latStr,
                style: TextStyle(
                  fontSize: SigapTypography.bodyMedium,
                  fontWeight: FontWeight.w600,
                  fontFamily: SigapTypography.fontFamilyMono,
                  color: SigapColorScheme.of(context).textPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: SigapSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.longitude,
                style: TextStyle(
                  fontSize: SigapTypography.captionSmall,
                  color: SigapColorScheme.of(context).textTertiary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                lngStr,
                style: TextStyle(
                  fontSize: SigapTypography.bodyMedium,
                  fontWeight: FontWeight.w600,
                  fontFamily: SigapTypography.fontFamilyMono,
                  color: SigapColorScheme.of(context).textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds the accuracy indicator row with colored dot and label.
  Widget _buildAccuracyRow(
    BuildContext context,
    AccuracyStatus status,
    Color accuracyColor,
    String accuracyLabel,
  ) {
    return Row(
      children: [
        _AccuracyDot(color: accuracyColor),
        const SizedBox(width: SigapSpacing.x4),
        Text(
          '${accuracyMeters.toStringAsFixed(1)} m',
          style: TextStyle(
            fontSize: SigapTypography.bodyText,
            fontWeight: FontWeight.w600,
            fontFamily: SigapTypography.fontFamilyMono,
            color: SigapColorScheme.of(context).textPrimary,
          ),
        ),
        const SizedBox(width: SigapSpacing.x4),
        Text(
          '· $accuracyLabel',
          style: TextStyle(
            fontSize: SigapTypography.bodySmall,
            color: accuracyColor,
          ),
        ),
      ],
    );
  }

  /// Builds the timestamp row.
  Widget _buildTimestamp(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final formattedTime = _formatTimestamp(context, timestamp!.toLocal());

    return Text(
      l10n.diperbaruiPada(formattedTime),
      style: TextStyle(
        fontSize: SigapTypography.captionSmall,
        color: SigapColorScheme.of(context).textTertiary,
      ),
    );
  }

  /// Formats the timestamp to a human-readable string.
  String _formatTimestamp(BuildContext context, DateTime time) =>
      DateFormat.yMd(
        AppLocalizations.of(context)!.localeName,
      ).add_Hm().format(time);

  /// Returns the color for the given accuracy status.
  Color _getAccuracyColor(AccuracyStatus status) {
    switch (status) {
      case AccuracyStatus.good:
        return SigapColors.primary;
      case AccuracyStatus.moderate:
        return SigapColors.warning;
      case AccuracyStatus.poor:
        return SigapColors.danger;
    }
  }
}

/// Represents the GPS accuracy status.
enum AccuracyStatus {
  /// Good accuracy (less than 10 meters).
  good,

  /// Moderate accuracy (10-50 meters).
  moderate,

  /// Poor accuracy (more than 50 meters).
  poor,
}

/// A small colored dot indicating GPS accuracy status.
class _AccuracyDot extends StatelessWidget {
  /// The color of the dot.
  final Color color;

  const _AccuracyDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../theme/tokens.dart';

/// S-04 GPS Card widget for surveyor visit form screen.
///
/// Displays current GPS coordinates with accuracy indicator and timestamp.
///
/// The accuracy indicator shows color based on accuracy value:
/// - Green (primary): accuracy < 10 meters (baik)
/// - Amber (warning): accuracy 10-50 meters (sedang)
/// - Red (danger): accuracy > 50 meters (buruk)
///
/// Design tokens used:
/// - Card background: SigapColors.bgCard (#FFFFFF)
/// - Card border: SigapColors.borderCard (#E4E7E2)
/// - Primary text: SigapColors.textPrimary (#17191C)
/// - Secondary text: SigapColors.textSecondary (#3A3F45)
/// - Tertiary text: SigapColors.textTertiary (#616770)
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
  static String getAccuracyLabel(AccuracyStatus status) {
    switch (status) {
      case AccuracyStatus.good:
        return 'Akurasi baik';
      case AccuracyStatus.moderate:
        return 'Akurasi sedang';
      case AccuracyStatus.poor:
        return 'Akurasi buruk';
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = getAccuracyStatus(accuracyMeters);
    final accuracyColor = _getAccuracyColor(status);
    final accuracyLabel = getAccuracyLabel(status);

    return Container(
      decoration: BoxDecoration(
        color: SigapColors.bgCard,
        borderRadius: BorderRadius.circular(SigapRadius.lg),
        border: Border.all(color: SigapColors.borderCard),
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
                _buildHeader(),
                const SizedBox(height: SigapSpacing.sm),
                // Coordinates display
                _buildCoordinates(),
                const SizedBox(height: SigapSpacing.sm),
                // Accuracy indicator row
                _buildAccuracyRow(status, accuracyColor, accuracyLabel),
                // Timestamp
                if (timestamp != null) ...[
                  const SizedBox(height: SigapSpacing.x4),
                  _buildTimestamp(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the header row with map pin icon and label.
  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(Icons.location_on, size: 18, color: SigapColors.primary),
        const SizedBox(width: SigapSpacing.x4),
        Text(
          'Lokasi GPS',
          style: TextStyle(
            fontSize: SigapTypography.size12,
            fontWeight: FontWeight.w600,
            color: SigapColors.textSecondary,
          ),
        ),
        const Spacer(),
        if (onRefresh != null)
          GestureDetector(
            onTap: onRefresh,
            child: const Icon(
              Icons.refresh,
              size: 16,
              color: SigapColors.textTertiary,
            ),
          ),
      ],
    );
  }

  /// Builds the coordinates display row.
  Widget _buildCoordinates() {
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
                'Latitude',
                style: TextStyle(
                  fontSize: SigapTypography.size10,
                  color: SigapColors.textTertiary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                latStr,
                style: TextStyle(
                  fontSize: SigapTypography.size14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'IBM Plex Mono',
                  color: SigapColors.textPrimary,
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
                'Longitude',
                style: TextStyle(
                  fontSize: SigapTypography.size10,
                  color: SigapColors.textTertiary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                lngStr,
                style: TextStyle(
                  fontSize: SigapTypography.size14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'IBM Plex Mono',
                  color: SigapColors.textPrimary,
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
            fontSize: SigapTypography.size13,
            fontWeight: FontWeight.w600,
            fontFamily: 'IBM Plex Mono',
            color: SigapColors.textPrimary,
          ),
        ),
        const SizedBox(width: SigapSpacing.x4),
        Text(
          '· $accuracyLabel',
          style: TextStyle(
            fontSize: SigapTypography.size12,
            color: accuracyColor,
          ),
        ),
      ],
    );
  }

  /// Builds the timestamp row.
  Widget _buildTimestamp() {
    final formattedTime = _formatTimestamp(timestamp!);

    return Text(
      'Diperbarui: $formattedTime',
      style: TextStyle(
        fontSize: SigapTypography.size10,
        color: SigapColors.textTertiary,
      ),
    );
  }

  /// Formats the timestamp to a human-readable string.
  String _formatTimestamp(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    final day = time.day.toString().padLeft(2, '0');
    final month = time.month.toString().padLeft(2, '0');
    final year = time.year;
    return '$day/$month/$year $hour:$minute';
  }

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

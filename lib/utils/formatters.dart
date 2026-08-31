/// Formats a UUID as a Local Report ID: "LR-XXXX"
String formatReportLocalId(String uuid) =>
    'LR-${uuid.substring(0, 4).toUpperCase()}';

/// Formats a UUID as a Server Case ID: "CB-XXXX"
String formatCaseId(String uuid) => 'CB-${uuid.substring(0, 4).toUpperCase()}';

/// Formats GPS coordinates for display
String formatGps(double lat, double lng) =>
    '${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}';

/// Formats byte size as MB
String formatMb(int bytes) {
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}

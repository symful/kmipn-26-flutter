import 'package:sigap/utils/server_timestamp.dart';
import 'package:sigap/api/client.dart' show Report;
import 'package:sigap/db/database.dart' show LocalReport;

/// Unified report model for warga role.
class ReportItem {
  final String? title;
  final String? village;
  final String key;
  final String description;
  final double? lat;
  final double? lng;
  final int syncStatus;
  final String? serverId;
  final String? idempotencyKey;
  final DateTime? createdAt;
  final String? status;
  final bool isLocal;

  ReportItem({
    this.title,
    this.village,
    required this.key,
    required this.description,
    required this.lat,
    required this.lng,
    required this.syncStatus,
    this.serverId,
    this.idempotencyKey,
    required this.createdAt,
    this.status,
    required this.isLocal,
  });

  factory ReportItem.fromLocal(LocalReport r) {
    return ReportItem(
      key: r.idempotencyKey,
      description: r.description,
      lat: r.lat,
      lng: r.lng,
      syncStatus: r.syncStatus,
      serverId: r.serverId,
      idempotencyKey: r.idempotencyKey,
      createdAt: r.createdAt,
      status: r.status,
      isLocal: true,
    );
  }

  static ReportItem? fromServer(Report r) {
    final lat = r.lat;
    final lng = r.lng;
    return ReportItem(
      key: r.id?.toString() ?? r.idempotencyKey ?? '',
      title: r.title,
      village: r.kelurahan ?? r.kecamatan ?? r.kabupaten,
      description: r.description ?? r.title ?? '-',
      lat: lat,
      lng: lng,
      syncStatus: 1,
      serverId: r.id,
      idempotencyKey: r.idempotencyKey,
      createdAt: _parseDate(r.createdAt),
      status: r.status?.value,
      isLocal: false,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return parseServerTimestamp(value.toString())?.toLocal();
  }

  String get navKey => serverId ?? idempotencyKey ?? key;
}

/// Merges local Drift reports with server reports.
/// If server reports are provided (non-empty server list or connected), synced local reports (syncStatus=1)
/// missing from the server list are excluded to match server state.
List<ReportItem> mergeReports(List<LocalReport> local, List<Report> server) {
  final seen = <String>{};
  final result = <ReportItem>[];

  final serverIds = <String>{};
  for (final r in server) {
    final serverId = r.id;
    final idempotencyKey = r.idempotencyKey;
    if (serverId != null && serverId.isNotEmpty) serverIds.add(serverId);
    if (idempotencyKey != null && idempotencyKey.isNotEmpty) {
      serverIds.add(idempotencyKey);
    }
  }

  for (final r in local) {
    final key = r.serverId ?? r.idempotencyKey;
    if (key.isEmpty) continue;
    if (r.syncStatus == 1 &&
        (serverIds.contains(r.serverId) ||
            serverIds.contains(r.idempotencyKey))) {
      continue;
    }
    if (seen.contains(key)) continue;

    // If report was already synced (syncStatus == 1) but no longer exists on server, skip it
    if (r.syncStatus == 1 && serverIds.isNotEmpty) {
      final existsOnServer =
          serverIds.contains(r.serverId) ||
          serverIds.contains(r.idempotencyKey);
      if (!existsOnServer) continue;
    }

    seen.add(key);
    result.add(ReportItem.fromLocal(r));
  }

  for (final r in server) {
    final serverId = r.id;
    final idempotencyKey = r.idempotencyKey;
    final dedupKey = serverId ?? idempotencyKey ?? '';
    if (dedupKey.isEmpty) continue;
    if (seen.contains(dedupKey)) continue;
    seen.add(dedupKey);
    final item = ReportItem.fromServer(r);
    if (item == null) continue;
    result.add(item);
  }

  result.sort((a, b) {
    if (a.createdAt == null) return b.createdAt == null ? 0 : 1;
    if (b.createdAt == null) return -1;
    return b.createdAt!.compareTo(a.createdAt!);
  });
  return result;
}

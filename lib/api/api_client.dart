import 'dart:io';
import 'dart:typed_data';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_config.dart';
import 'auth_interceptor.dart';
import 'exceptions.dart';
import 'types.g.dart';

/// Exception thrown when network connectivity is unavailable.
class ConnectivityException implements Exception {
  final String message;
  ConnectivityException([this.message = 'No internet connection']);
  @override
  String toString() => 'ConnectivityException: $message';
}

// â”€â”€â”€ Paginated response wrappers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class PaginatedItems<T> {
  final List<T> items;
  final Pagination pagination;
  PaginatedItems({required this.items, required this.pagination});
}

class VerifikatorQueuePage {
  final List<Report> items;
  final Pagination pagination;
  VerifikatorQueuePage({required this.items, required this.pagination});
}

class TaskListPage<T> {
  final List<T> tasks;
  final Pagination pagination;
  TaskListPage({required this.tasks, required this.pagination});
}

class AuditPage {
  final List<AuditEntry> entries;
  final int total;
  final int page;
  final int limit;
  AuditPage({
    required this.entries,
    required this.total,
    required this.page,
    required this.limit,
  });
}

class NotificationPage {
  final List<Notification> entries;
  NotificationPage({required this.entries});
}

class WargaReportsPage {
  final List<Report> items;
  WargaReportsPage({required this.items});
}

class PublicReportCategory {
  final String? id;
  final String? shortCode;
  final String? name;
  final String? icon;
  PublicReportCategory({this.id, this.shortCode, this.name, this.icon});
  factory PublicReportCategory.fromJson(Map<String, dynamic> json) {
    return PublicReportCategory(
      id: json['id'] as String?,
      shortCode: json['short_code'] as String?,
      name: json['name'] as String?,
      icon: json['icon'] as String?,
    );
  }
}

class PublicReportWilayah {
  final String? kecamatan;
  final String? desa;
  PublicReportWilayah({this.kecamatan, this.desa});
  factory PublicReportWilayah.fromJson(Map<String, dynamic> json) {
    return PublicReportWilayah(
      kecamatan: json['kecamatan'] as String?,
      desa: json['desa'] as String?,
    );
  }
}

class PublicReportItem {
  final String? id;
  final PublicReportCategory? category;
  final PublicReportWilayah? wilayah;
  final String? status;
  final String? lastUpdated;
  final int publicProgress;
  final String? moderatedPhotoUrl;
  final String? shareToken;
  final int supportingCount;
  PublicReportItem({
    this.id,
    this.category,
    this.wilayah,
    this.status,
    this.lastUpdated,
    this.publicProgress = 0,
    this.moderatedPhotoUrl,
    this.shareToken,
    this.supportingCount = 0,
  });
  factory PublicReportItem.fromJson(Map<String, dynamic> json) {
    return PublicReportItem(
      id: json['id'] as String?,
      category: json['category'] != null
          ? PublicReportCategory.fromJson(
              json['category'] as Map<String, dynamic>,
            )
          : null,
      wilayah: json['wilayah'] != null
          ? PublicReportWilayah.fromJson(
              json['wilayah'] as Map<String, dynamic>,
            )
          : null,
      status: json['status'] as String?,
      lastUpdated: json['last_updated'] as String?,
      publicProgress: json['public_progress'] as int? ?? 0,
      moderatedPhotoUrl: json['moderated_photo_url'] as String?,
      shareToken: json['share_token'] as String?,
      supportingCount: json['supporting_count'] as int? ?? 0,
    );
  }
}

class PublicReportsPage {
  final List<PublicReportItem> items;
  final int total;
  final int page;
  final int limit;
  PublicReportsPage({
    required this.items,
    this.total = 0,
    this.page = 1,
    this.limit = 20,
  });
}

class UsersPage {
  final List<UserResponse> entries;
  final int total;
  final int page;
  final int limit;
  UsersPage({
    required this.entries,
    required this.total,
    required this.page,
    required this.limit,
  });
}

class UnitsPage {
  final List<Unit> entries;
  final int total;
  final int page;
  final int limit;
  UnitsPage({
    required this.entries,
    required this.total,
    required this.page,
    required this.limit,
  });
}

class SlaPage {
  final List<SlaConfig> entries;
  final int total;
  final int page;
  final int limit;
  SlaPage({
    required this.entries,
    required this.total,
    required this.page,
    required this.limit,
  });
}

class ChecklistTemplatesPage {
  final List<ChecklistTemplate> entries;
  final int total;
  final int page;
  final int limit;
  ChecklistTemplatesPage({
    required this.entries,
    required this.total,
    required this.page,
    required this.limit,
  });
}

class PriorityConfigPage {
  final List<PriorityConfig> entries;
  final int total;
  final int page;
  final int limit;
  PriorityConfigPage({
    required this.entries,
    required this.total,
    required this.page,
    required this.limit,
  });

  factory PriorityConfigPage.fromJson(Map<String, dynamic> json) {
    final pagination = json['pagination'] as Map<String, dynamic>?;
    return PriorityConfigPage(
      entries:
          (json['data'] as List?)
              ?.map(
                (e) =>
                    PriorityConfig.fromJson((e as Map).cast<String, dynamic>()),
              )
              .toList() ??
          [],
      total: pagination?['total'] as int? ?? 0,
      page: pagination?['page'] as int? ?? 1,
      limit: pagination?['limit'] as int? ?? 20,
    );
  }
}

class FailedAssessmentsPage {
  final List<Map<String, dynamic>> entries;
  final int total;
  final int page;
  final int limit;
  FailedAssessmentsPage({
    required this.entries,
    required this.total,
    required this.page,
    required this.limit,
  });
}

class RtRwVerifyResult {
  final String? status;
  final String? reportId;
  RtRwVerifyResult({this.status, this.reportId});

  factory RtRwVerifyResult.fromJson(Map<String, dynamic> json) {
    return RtRwVerifyResult(
      status: json['status'] as String?,
      reportId: json['report_id'] as String?,
    );
  }
}

class RtRwVerifyInfo {
  final String? reportId;
  final String? title;
  final String? location;
  final List<String>? photos;
  final String? status;
  RtRwVerifyInfo({
    this.reportId,
    this.title,
    this.location,
    this.photos,
    this.status,
  });

  /// Server returns: { id, description, location, photos, current_status }
  factory RtRwVerifyInfo.fromJson(Map<String, dynamic> json) {
    return RtRwVerifyInfo(
      reportId: json['id'] as String?,
      title: json['description'] as String?,
      location: json['location'] as String?,
      photos: (json['photos'] as List?)?.map((e) => e as String).toList(),
      status: json['current_status'] as String?,
    );
  }
}

class ValidationResult {
  final bool valid;
  final String? role;
  ValidationResult({required this.valid, this.role});

  factory ValidationResult.fromJson(Map<String, dynamic> json) {
    return ValidationResult(
      valid: json['valid'] as bool? ?? false,
      role: json['role'] as String?,
    );
  }
}

class GeocodeResult {
  final String? address;
  final String? district;
  final String? city;
  final String? village;
  final String? subdistrict;
  final String? province;
  GeocodeResult({
    this.address,
    this.district,
    this.city,
    this.village,
    this.subdistrict,
    this.province,
  });

  factory GeocodeResult.fromJson(Map<String, dynamic> json) {
    // Backend returns nested objects: village, subdistrict, district, province
    // Flutter flatten for convenience
    final districtObj = json['district'] as Map<String, dynamic>?;
    final subdistrictObj = json['subdistrict'] as Map<String, dynamic>?;
    final provinceObj = json['province'] as Map<String, dynamic>?;
    final villageObj = json['village'] as Map<String, dynamic>?;
    return GeocodeResult(
      address: json['address'] as String?,
      district: districtObj?['name'] as String?,
      city: districtObj?['name'] as String?, //kabupaten
      village: villageObj?['name'] as String?,
      subdistrict: subdistrictObj?['name'] as String?,
      province: provinceObj?['name'] as String?,
    );
  }
}

class Wilayah {
  final String? id;
  final String? name;
  final String? level;
  final String? parentId;
  Wilayah({this.id, this.name, this.level, this.parentId});

  factory Wilayah.fromJson(Map<String, dynamic> json) {
    return Wilayah(
      id: json['id'] as String?,
      name: json['name'] as String?,
      level: json['level'] as String?,
      parentId: json['parent_id'] as String?,
    );
  }
}

class Facility {
  final String? id;
  final String? name;
  final String? type;
  final Map<String, dynamic>? location;
  Facility({this.id, this.name, this.type, this.location});

  factory Facility.fromJson(Map<String, dynamic> json) {
    return Facility(
      id: json['id'] as String?,
      name: json['name'] as String?,
      type: json['type'] as String?,
      location: json['location'] as Map<String, dynamic>?,
    );
  }
}

class GeoJSONFeatureCollection {
  final String? type;
  final List<GeoJSONFeature>? features;
  GeoJSONFeatureCollection({this.type, this.features});

  factory GeoJSONFeatureCollection.fromJson(Map<String, dynamic> json) {
    return GeoJSONFeatureCollection(
      type: json['type'] as String?,
      features: (json['features'] as List?)
          ?.map((e) => GeoJSONFeature.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class GeoJSONFeature {
  final String? type;
  final Map<String, dynamic>? geometry;
  final Map<String, dynamic>? properties;
  GeoJSONFeature({this.type, this.geometry, this.properties});

  factory GeoJSONFeature.fromJson(Map<String, dynamic> json) {
    return GeoJSONFeature(
      type: json['type'] as String?,
      geometry: json['geometry'] as Map<String, dynamic>?,
      properties: json['properties'] as Map<String, dynamic>?,
    );
  }
}

class NearbyReport {
  final String? id;
  final String? title;
  final String? category;
  final String? status;
  final Map<String, dynamic>? location;
  final double? distance;
  NearbyReport({
    this.id,
    this.title,
    this.category,
    this.status,
    this.location,
    this.distance,
  });

  factory NearbyReport.fromJson(Map<String, dynamic> json) {
    return NearbyReport(
      id: json['id'] as String?,
      title: json['title'] as String?,
      category: json['category'] as String?,
      status: json['status'] as String?,
      location: json['location'] as Map<String, dynamic>?,
      distance: (json['distance'] as num?)?.toDouble(),
    );
  }
}

class TimelineEnvelope {
  final List<TimelineEvent>? events;
  TimelineEnvelope({this.events});

  factory TimelineEnvelope.fromJson(Map<String, dynamic> json) {
    return TimelineEnvelope(
      events: (json['events'] as List?)
          ?.map((e) => TimelineEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ExecutiveTrend {
  final String? period;
  final List<TrendPoint>? data;
  ExecutiveTrend({this.period, this.data});

  factory ExecutiveTrend.fromJson(Map<String, dynamic> json) {
    return ExecutiveTrend(
      period: json['period'] as String?,
      data: (json['data'] as List?)
          ?.map((e) => TrendPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class TrendPoint {
  final String? date;
  final int? total;
  final int? resolved;
  final int? newReports;
  TrendPoint({this.date, this.total, this.resolved, this.newReports});

  factory TrendPoint.fromJson(Map<String, dynamic> json) {
    return TrendPoint(
      date: json['date'] as String?,
      total: json['total'] as int?,
      resolved: json['resolved'] as int?,
      newReports: json['new_reports'] as int?,
    );
  }
}

class WargaStats {
  final int? total;
  final int? submitted;
  final int? verified;
  final int? inProgress;
  final int? resolved;
  WargaStats({
    this.total,
    this.submitted,
    this.verified,
    this.inProgress,
    this.resolved,
  });

  factory WargaStats.fromJson(Map<String, dynamic> json) {
    // Server returns {by_status: {submitted, verified, ...}, total} — flatten
    final byStatus = json['by_status'] as Map<String, dynamic>?;
    return WargaStats(
      total: json['total'] as int?,
      submitted: byStatus?['submitted'] as int? ?? json['submitted'] as int?,
      verified: byStatus?['verified'] as int? ?? json['verified'] as int?,
      inProgress:
          byStatus?['in_progress'] as int? ?? json['in_progress'] as int?,
      resolved: byStatus?['resolved'] as int? ?? json['resolved'] as int?,
    );
  }
}

class WargaProfile {
  final String? id;
  final String? username; // backend sends 'username' — stored but not displayed
  final String? name;
  final String? email;
  final String? role;
  final String? wilayahId;
  final String? wilayahName;
  final String? createdAt;
  final WargaStats? stats;
  WargaProfile({
    this.id,
    this.username,
    this.name,
    this.email,
    this.role,
    this.wilayahId,
    this.wilayahName,
    this.createdAt,
    this.stats,
  });

  /// Backend returns: { id, username, email, role, wilayah_id, wilayah_name, created_at }
  /// Flutter maps username to name for display compatibility.
  factory WargaProfile.fromJson(Map<String, dynamic> json) {
    return WargaProfile(
      id: json['id'] as String?,
      username: json['username'] as String?,
      // Map username to name so existing display code using .name continues working
      name: json['username'] as String? ?? json['name'] as String?,
      email: json['email'] as String?,
      role: json['role'] as String?,
      wilayahId: json['wilayah_id'] as String?,
      wilayahName: json['wilayah_name'] as String?,
      createdAt: json['created_at'] as String?,
      stats: json['stats'] != null
          ? WargaStats.fromJson(json['stats'] as Map<String, dynamic>)
          : null,
    );
  }
}

class GenerateRtRwTokenResult {
  final String? verificationToken;
  final String? expiresAt;
  GenerateRtRwTokenResult({this.verificationToken, this.expiresAt});

  factory GenerateRtRwTokenResult.fromJson(Map<String, dynamic> json) {
    return GenerateRtRwTokenResult(
      verificationToken: json['verification_token'] as String?,
      expiresAt: json['expires_at'] as String?,
    );
  }
}

class RetryBatchResult {
  final int? retried;
  final int? failed;
  RetryBatchResult({this.retried, this.failed});

  factory RetryBatchResult.fromJson(Map<String, dynamic> json) {
    return RetryBatchResult(
      retried: json['retried'] as int?,
      failed: json['failed'] as int?,
    );
  }
}

class SyncBatchResult {
  final List<SyncBatchItemResult> results;
  final int successCount;
  final int failureCount;
  SyncBatchResult({
    required this.results,
    required this.successCount,
    required this.failureCount,
  });

  int get processed => successCount;
  int get failed => failureCount;
  List<String>? get errors {
    final errs = results
        .where((r) => r.error != null)
        .map((r) => r.error!)
        .toList();
    return errs.isEmpty ? null : errs;
  }
}

class SyncBatchItemResult {
  final int index;
  final String? id;
  final String? status;
  final String? error;
  SyncBatchItemResult({required this.index, this.id, this.status, this.error});

  factory SyncBatchItemResult.fromJson(Map<String, dynamic> json) {
    return SyncBatchItemResult(
      index: json['index'] as int,
      id: json['id'] as String?,
      status: json['status'] as String?,
      error: json['error'] as String?,
    );
  }
}

SyncBatchResult parseSyncBatchResult(Map<String, dynamic> json) {
  final resultsList =
      (json['results'] as List?)
          ?.map(
            (e) => SyncBatchItemResult.fromJson(
              (e as Map).cast<String, dynamic>(),
            ),
          )
          .toList() ??
      [];
  return SyncBatchResult(
    results: resultsList,
    successCount: json['success_count'] as int? ?? 0,
    failureCount: json['failure_count'] as int? ?? 0,
  );
}

class PriorityActivateResult {
  final String? id;
  final bool? success;
  PriorityActivateResult({this.id, this.success});

  factory PriorityActivateResult.fromJson(Map<String, dynamic> json) {
    return PriorityActivateResult(
      id: json['id'] as String?,
      success: json['success'] as bool?,
    );
  }
}

class DecideResult {
  final String? caseId;
  final String? decision;
  final String? status;
  DecideResult({this.caseId, this.decision, this.status});

  factory DecideResult.fromJson(Map<String, dynamic> json) {
    return DecideResult(
      caseId: json['case_id'] as String?,
      decision: json['decision'] as String?,
      status: json['status'] as String?,
    );
  }
}

class VisitResult {
  final String? visitId;
  final String? taskId;
  final String? status;
  VisitResult({this.visitId, this.taskId, this.status});

  factory VisitResult.fromJson(Map<String, dynamic> json) {
    return VisitResult(
      visitId: json['visit_id']?.toString(),
      taskId: json['task_id']?.toString(),
      status: json['status']?.toString(),
    );
  }
}

class EvidenceResult {
  final String? evidenceId;
  final List<String>? photoUrls;
  EvidenceResult({this.evidenceId, this.photoUrls});

  factory EvidenceResult.fromJson(Map<String, dynamic> json) {
    return EvidenceResult(
      evidenceId: json['evidence_id']?.toString(),
      photoUrls: (json['photo_urls'] as List?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }
}

class SanggahanResult {
  final bool? success;
  final String? id;
  SanggahanResult({this.success, this.id});

  /// Legacy accessor — backend returns {success, id}, not {status}.
  /// Returns 'confirmed' when success is true for backward compatibility.
  String? get status => success == true ? 'confirmed' : null;

  factory SanggahanResult.fromJson(Map<String, dynamic> json) {
    return SanggahanResult(
      success: json['success'] as bool?,
      id: json['id'] as String?,
    );
  }
}

class ReopenResult {
  final String? status;
  ReopenResult({this.status});

  factory ReopenResult.fromJson(Map<String, dynamic> json) {
    return ReopenResult(status: json['status'] as String?);
  }
}

class ProgressResult {
  final String? taskId;
  final int? progressPercent;
  ProgressResult({this.taskId, this.progressPercent});

  factory ProgressResult.fromJson(Map<String, dynamic> json) {
    return ProgressResult(
      taskId: json['task_id'] as String?,
      progressPercent: json['progress_percent'] as int?,
    );
  }
}

class CreateReportResult {
  final String? id;
  final bool? duplicate;
  CreateReportResult({this.id, this.duplicate});

  /// Server hardcodes status='submitted' for all new reports.
  /// The wire returns {id, duplicate} — this getter provides status
  /// consistent with server INSERT behavior.
  String get status => 'submitted';

  factory CreateReportResult.fromJson(Map<String, dynamic> json) {
    return CreateReportResult(
      id: json['id'] as String?,
      duplicate: json['duplicate'] as bool?,
    );
  }
}

/// Result for flat status-change operations: setReportPriority, closeReport, resolveReport.
/// Backend returns {status, new_score?, priority_score?} — NOT a full Report.
class ReportStatusResult {
  final String? status;
  final int? newScore;
  final int? priorityScore;
  ReportStatusResult({this.status, this.newScore, this.priorityScore});

  factory ReportStatusResult.fromJson(Map<String, dynamic> json) {
    return ReportStatusResult(
      status: json['status'] as String?,
      newScore: json['new_score'] as int?,
      priorityScore: json['priority_score'] as int?,
    );
  }
}

/// Anonymous report submission result.
/// Backend: POST /api/public/anonymous-reports → {id, idempotency_key, status:"pending"}
class AnonymousReportResult {
  final String? id;
  final String? idempotencyKey;
  final String? status;
  AnonymousReportResult({this.id, this.idempotencyKey, this.status});

  factory AnonymousReportResult.fromJson(Map<String, dynamic> json) {
    return AnonymousReportResult(
      id: json['id'] as String?,
      idempotencyKey: json['idempotency_key'] as String?,
      status: json['status'] as String?,
    );
  }
}

/// Accept Verifikator case result.
/// Backend: POST /api/cases/:id/accept → {id, status, severity, assigned_to, assessments}
class CaseAcceptResult {
  final String? id;
  final String? status;
  final String? severity;
  final String? assignedTo;
  final List<dynamic>? assessments;
  CaseAcceptResult({
    this.id,
    this.status,
    this.severity,
    this.assignedTo,
    this.assessments,
  });

  factory CaseAcceptResult.fromJson(Map<String, dynamic> json) {
    return CaseAcceptResult(
      id: json['id'] as String?,
      status: json['status'] as String?,
      severity: json['severity'] as String?,
      assignedTo: json['assigned_to'] as String?,
      assessments: json['assessments'] as List?,
    );
  }
}

/// Reject Verifikator case result.
/// Backend: POST /api/cases/:id/reject → {status:"rejected", reason}
class CaseRejectResult {
  final String? status;
  final String? reason;
  CaseRejectResult({this.status, this.reason});

  factory CaseRejectResult.fromJson(Map<String, dynamic> json) {
    return CaseRejectResult(
      status: json['status'] as String?,
      reason: json['reason'] as String?,
    );
  }
}

/// Combine/Merge Verifikator case result.
/// Backend: POST /api/cases/:id/combine → {status:"merged", target_case_id}
class CaseCombineResult {
  final String? status;
  final String? targetCaseId;
  CaseCombineResult({this.status, this.targetCaseId});

  factory CaseCombineResult.fromJson(Map<String, dynamic> json) {
    return CaseCombineResult(
      status: json['status'] as String?,
      targetCaseId: json['target_case_id'] as String?,
    );
  }
}

/// Separate Verifikator case result.
/// Backend: POST /api/cases/:id/separate → {status:"separated", new_case_id}
class CaseSeparateResult {
  final String? status;
  final String? newCaseId;
  CaseSeparateResult({this.status, this.newCaseId});

  factory CaseSeparateResult.fromJson(Map<String, dynamic> json) {
    return CaseSeparateResult(
      status: json['status'] as String?,
      newCaseId: json['new_case_id'] as String?,
    );
  }
}

/// Review Sanggahan Verifikator case result.
/// Backend: POST /api/cases/:id/review-sanggahan → {decision, report_status, reason}
class CaseReviewSanggahanResult {
  final String? decision;
  final String? reportStatus;
  final String? reason;
  CaseReviewSanggahanResult({this.decision, this.reportStatus, this.reason});

  factory CaseReviewSanggahanResult.fromJson(Map<String, dynamic> json) {
    return CaseReviewSanggahanResult(
      decision: json['decision'] as String?,
      reportStatus: json['report_status'] as String?,
      reason: json['reason'] as String?,
    );
  }
}

/// Verify Completion Verifikator case result.
/// Backend: POST /api/cases/:id/verify-completion → {decision, report_status, reason, task_id, report}
class CaseVerifyCompletionResult {
  final String? decision;
  final String? reportStatus;
  final String? reason;
  final String? taskId;
  CaseVerifyCompletionResult({
    this.decision,
    this.reportStatus,
    this.reason,
    this.taskId,
  });

  factory CaseVerifyCompletionResult.fromJson(Map<String, dynamic> json) {
    return CaseVerifyCompletionResult(
      decision: json['decision'] as String?,
      reportStatus: json['report_status'] as String?,
      reason: json['reason'] as String?,
      taskId: json['task_id'] as String?,
    );
  }
}

/// Verdict values accepted by RT/RW verification endpoint.
/// Backend validates against: ["valid","needs_completion","needs_survey","out_of_scope","duplicate","rejected","confirmed"]
enum RtRwVerdict {
  valid('valid'),
  needsCompletion('needs_completion'),
  needsSurvey('needs_survey'),
  outOfScope('out_of_scope'),
  duplicate('duplicate'),
  rejected('rejected'),
  confirmed('confirmed');

  final String value;
  const RtRwVerdict(this.value);

  static RtRwVerdict? fromString(String? v) {
    if (v == null) return null;
    return RtRwVerdict.values.cast<RtRwVerdict?>().firstWhere(
      (e) => e?.value == v,
      orElse: () => null,
    );
  }
}

class ClarificationResult {
  final String? clarificationId;
  final String? status;
  ClarificationResult({this.clarificationId, this.status});

  factory ClarificationResult.fromJson(Map<String, dynamic> json) {
    return ClarificationResult(
      clarificationId: json['clarification_id'] as String?,
      status: json['status'] as String?,
    );
  }
}

class TaskActionResult {
  final String? taskId;
  final String? status;
  TaskActionResult({this.taskId, this.status});

  factory TaskActionResult.fromJson(Map<String, dynamic> json) {
    return TaskActionResult(
      taskId: json['task_id'] as String?,
      status: json['status'] as String?,
    );
  }
}

class UploadPhotoResult {
  final String? publicUrl;
  UploadPhotoResult({this.publicUrl});

  factory UploadPhotoResult.fromJson(Map<String, dynamic> json) {
    return UploadPhotoResult(publicUrl: json['public_url'] as String?);
  }
}

class CompleteTaskResult {
  final String? taskId;
  final String? status;
  final String? completionProof;
  CompleteTaskResult({this.taskId, this.status, this.completionProof});

  factory CompleteTaskResult.fromJson(Map<String, dynamic> json) {
    return CompleteTaskResult(
      taskId: json['task_id'] as String?,
      status: json['status'] as String?,
      completionProof: json['completion_proof'] as String?,
    );
  }
}

class FacilitiesCluster {
  final List<FacilityClusterPoint>? clusters;
  FacilitiesCluster({this.clusters});

  factory FacilitiesCluster.fromJson(Map<String, dynamic> json) {
    return FacilitiesCluster(
      clusters: (json['clusters'] as List?)
          ?.map((e) => FacilityClusterPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class FacilityClusterPoint {
  final double? lat;
  final double? lng;
  final int? count;
  final String? dominantStatus;
  final String? dominantCategory;
  final String? color;
  FacilityClusterPoint({
    this.lat,
    this.lng,
    this.count,
    this.dominantStatus,
    this.dominantCategory,
    this.color,
  });

  factory FacilityClusterPoint.fromJson(Map<String, dynamic> json) {
    return FacilityClusterPoint(
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      count: json['count'] as int?,
      dominantStatus: json['dominant_status'] as String?,
      dominantCategory: json['dominant_category'] as String?,
      color: json['color'] as String?,
    );
  }
}

class HealthResult {
  final String? status;
  final String? version;
  HealthResult({this.status, this.version});

  factory HealthResult.fromJson(Map<String, dynamic> json) {
    return HealthResult(
      status: json['status'] as String?,
      version: json['version'] as String?,
    );
  }
}

/// Public stats response from GET /api/public/stats.
/// Backend returns: {total, by_status, by_category, recent_reports_7d, resolution_rate_7d}
class PublicStats {
  final int? total;
  final Map<String, dynamic>? byStatus;
  final List<Map<String, dynamic>>? byCategory;
  final int? recentReports7d;
  final double? resolutionRate7d;
  PublicStats({
    this.total,
    this.byStatus,
    this.byCategory,
    this.recentReports7d,
    this.resolutionRate7d,
  });

  factory PublicStats.fromJson(Map<String, dynamic> json) {
    return PublicStats(
      total: json['total'] as int?,
      byStatus: json['by_status'] as Map<String, dynamic>?,
      byCategory: (json['by_category'] as List?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      recentReports7d: json['recent_reports_7d'] as int?,
      resolutionRate7d: (json['resolution_rate_7d'] as num?)?.toDouble(),
    );
  }
}

/// Auditor stats response from GET /api/auditor/stats.
/// Backend returns: {counts: {total, last_24h, last_7d, last_30d}, top_actors, failed_attempts, recent_suspicious}
class AuditorStats {
  final AuditorStatsCounts? counts;
  final List<Map<String, dynamic>>? topActors;
  final int? failedAttempts;
  final List<Map<String, dynamic>>? recentSuspicious;
  AuditorStats({
    this.counts,
    this.topActors,
    this.failedAttempts,
    this.recentSuspicious,
  });

  factory AuditorStats.fromJson(Map<String, dynamic> json) {
    return AuditorStats(
      counts: json['counts'] != null
          ? AuditorStatsCounts.fromJson(json['counts'] as Map<String, dynamic>)
          : null,
      topActors: (json['top_actors'] as List?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      failedAttempts: json['failed_attempts'] as int?,
      recentSuspicious: (json['recent_suspicious'] as List?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
    );
  }
}

class AuditorStatsCounts {
  final int? total;
  final int? last24h;
  final int? last7d;
  final int? last30d;
  AuditorStatsCounts({this.total, this.last24h, this.last7d, this.last30d});

  factory AuditorStatsCounts.fromJson(Map<String, dynamic> json) {
    return AuditorStatsCounts(
      total: json['total'] as int?,
      last24h: json['last_24h'] as int?,
      last7d: json['last_7d'] as int?,
      last30d: json['last_30d'] as int?,
    );
  }
}

/// Task detail response from GET /api/tasks/:id.
/// Backend returns: {task, clarifications, evidence}
class TaskDetailResult {
  final Map<String, dynamic>? task;
  final List<Map<String, dynamic>>? clarifications;
  final List<Map<String, dynamic>>? evidence;
  TaskDetailResult({this.task, this.clarifications, this.evidence});

  factory TaskDetailResult.fromJson(Map<String, dynamic> json) {
    return TaskDetailResult(
      task: json['task'] as Map<String, dynamic>?,
      clarifications: (json['clarifications'] as List?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      evidence: (json['evidence'] as List?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
    );
  }
}

/// Start task response from POST /api/tasks/:id/start.
/// Backend returns: {task_id, status, started_at}
class TaskStartResult {
  final String? taskId;
  final String? status;
  final String? startedAt;
  TaskStartResult({this.taskId, this.status, this.startedAt});

  factory TaskStartResult.fromJson(Map<String, dynamic> json) {
    return TaskStartResult(
      taskId: json['task_id'] as String?,
      status: json['status'] as String?,
      startedAt: json['started_at'] as String?,
    );
  }
}

/// Reject task response from POST /api/tasks/:id/reject.
/// Backend returns: {id, status: "rejected"}
class TaskRejectResult {
  final String? id;
  final String? status;
  TaskRejectResult({this.id, this.status});

  factory TaskRejectResult.fromJson(Map<String, dynamic> json) {
    return TaskRejectResult(
      id: json['id'] as String?,
      status: json['status'] as String?,
    );
  }
}

/// Clarification response from POST /api/tasks/:id/clarification.
/// Backend returns: {clarification_id, status}
class TaskClarificationResult {
  final String? clarificationId;
  final String? status;
  TaskClarificationResult({this.clarificationId, this.status});

  factory TaskClarificationResult.fromJson(Map<String, dynamic> json) {
    return TaskClarificationResult(
      clarificationId: json['clarification_id'] as String?,
      status: json['status'] as String?,
    );
  }
}

/// Evidence response from POST /api/tasks/:id/evidence.
/// Backend returns: {success, evidence_id, task_id, photo_urls}
class TaskEvidenceResult {
  final bool? success;
  final String? evidenceId;
  final String? taskId;
  final List<String>? photoUrls;
  TaskEvidenceResult({
    this.success,
    this.evidenceId,
    this.taskId,
    this.photoUrls,
  });

  factory TaskEvidenceResult.fromJson(Map<String, dynamic> json) {
    return TaskEvidenceResult(
      success: json['success'] as bool?,
      evidenceId: json['evidence_id']?.toString(),
      taskId: json['task_id'] as String?,
      photoUrls: (json['photo_urls'] as List?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }
}

/// Complete task response from POST /api/tasks/:id/complete.
/// Backend returns: {task_id, status, completion_proof, completed_at}
class TaskCompleteResult {
  final String? taskId;
  final String? status;
  final String? completionProof;
  final String? completedAt;
  TaskCompleteResult({
    this.taskId,
    this.status,
    this.completionProof,
    this.completedAt,
  });

  factory TaskCompleteResult.fromJson(Map<String, dynamic> json) {
    return TaskCompleteResult(
      taskId: json['task_id'] as String?,
      status: json['status'] as String?,
      completionProof: json['completion_proof'] as String?,
      completedAt: json['completed_at'] as String?,
    );
  }
}

/// Checklist template response from GET /api/tasks/:id/checklist-template.
/// Backend returns: {items: [{id, item, required}]}
class ChecklistTemplateResult {
  final List<ChecklistTemplateItem>? items;
  ChecklistTemplateResult({this.items});

  factory ChecklistTemplateResult.fromJson(Map<String, dynamic> json) {
    return ChecklistTemplateResult(
      items: (json['items'] as List?)
          ?.map(
            (e) => ChecklistTemplateItem.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}

class ChecklistTemplateItem {
  final String? id;
  final String? item;
  final bool? required;
  ChecklistTemplateItem({this.id, this.item, this.required});

  factory ChecklistTemplateItem.fromJson(Map<String, dynamic> json) {
    return ChecklistTemplateItem(
      id: json['id']?.toString(),
      item: json['item']?.toString(),
      required: json['required'] as bool?,
    );
  }
}

/// Admin Daerah operators response from GET /api/admin-daerah/operators.
/// Backend returns: {data: [...], pagination: {page, limit, total, total_pages}}
class AdminDaerahOperatorsPage {
  final List<Map<String, dynamic>> entries;
  final Pagination pagination;
  AdminDaerahOperatorsPage({required this.entries, required this.pagination});

  factory AdminDaerahOperatorsPage.fromJson(Map<String, dynamic> json) {
    return AdminDaerahOperatorsPage(
      entries:
          (json['data'] as List?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [],
      pagination: Pagination.fromJson(
        (json['pagination'] as Map<String, dynamic>?)
                ?.cast<String, dynamic>() ??
            {},
      ),
    );
  }
}

/// Admin Daerah petugas response from GET /api/admin-daerah/petugas.
/// Backend returns: {data: [...], pagination: {page, limit, total, total_pages}}
class AdminDaerahPetugasPage {
  final List<Map<String, dynamic>> entries;
  final Pagination pagination;
  AdminDaerahPetugasPage({required this.entries, required this.pagination});

  factory AdminDaerahPetugasPage.fromJson(Map<String, dynamic> json) {
    return AdminDaerahPetugasPage(
      entries:
          (json['data'] as List?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [],
      pagination: Pagination.fromJson(
        (json['pagination'] as Map<String, dynamic>?)
                ?.cast<String, dynamic>() ??
            {},
      ),
    );
  }
}

/// Admin Daerah dashboard response from GET /api/admin-daerah/dashboard.
/// Backend returns: {total, by_status, by_category: [...], active_operators, active_petugas, sla_breached, sla_at_risk, avg_verification_days, recent_submissions, resolved_this_month}
class AdminDaerahDashboard {
  final int? total;
  final Map<String, dynamic>? byStatus;
  final List<Map<String, dynamic>>? byCategory;
  final int? activeOperators;
  final int? activePetugas;
  final int? slaBreached;
  final int? slaAtRisk;
  final double? avgVerificationDays;
  final int? recentSubmissions;
  final int? resolvedThisMonth;
  AdminDaerahDashboard({
    this.total,
    this.byStatus,
    this.byCategory,
    this.activeOperators,
    this.activePetugas,
    this.slaBreached,
    this.slaAtRisk,
    this.avgVerificationDays,
    this.recentSubmissions,
    this.resolvedThisMonth,
  });

  factory AdminDaerahDashboard.fromJson(Map<String, dynamic> json) {
    return AdminDaerahDashboard(
      total: json['total'] as int?,
      byStatus: json['by_status'] as Map<String, dynamic>?,
      byCategory: (json['by_category'] as List?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      activeOperators: json['active_operators'] as int?,
      activePetugas: json['active_petugas'] as int?,
      slaBreached: json['sla_breached'] as int?,
      slaAtRisk: json['sla_at_risk'] as int?,
      avgVerificationDays: (json['avg_verification_days'] as num?)?.toDouble(),
      recentSubmissions: json['recent_submissions'] as int?,
      resolvedThisMonth: json['resolved_this_month'] as int?,
    );
  }
}

/// Category create/update response from POST/PATCH /api/categories.
/// Backend returns the created/updated category object.
class CategoryResult {
  final String? id;
  final String? slug;
  final String? name;
  final String? icon;
  final String? description;
  final String? parentId;
  final String? code;
  final String? shortCode;
  final String? colorClass;
  final String? createdAt;
  CategoryResult({
    this.id,
    this.slug,
    this.name,
    this.icon,
    this.description,
    this.parentId,
    this.code,
    this.shortCode,
    this.colorClass,
    this.createdAt,
  });

  factory CategoryResult.fromJson(Map<String, dynamic> json) {
    return CategoryResult(
      id: json['id']?.toString(),
      slug: json['slug']?.toString(),
      name: json['name']?.toString(),
      icon: json['icon']?.toString(),
      description: json['description']?.toString(),
      parentId: json['parent_id']?.toString(),
      code: json['code']?.toString(),
      shortCode: json['short_code']?.toString(),
      colorClass: json['color_class']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }
}

/// User create response from POST /api/users.
/// Backend returns: {id, email, name, role, wilayah_id, created_at}
class UserCreateResult {
  final String? id;
  final String? email;
  final String? name;
  final String? role;
  final String? wilayahId;
  final String? createdAt;
  UserCreateResult({
    this.id,
    this.email,
    this.name,
    this.role,
    this.wilayahId,
    this.createdAt,
  });

  factory UserCreateResult.fromJson(Map<String, dynamic> json) {
    return UserCreateResult(
      id: json['id']?.toString(),
      email: json['email']?.toString(),
      name: json['name']?.toString(),
      role: json['role']?.toString(),
      wilayahId: json['wilayah_id']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }
}

/// Priority override response from POST /api/reports/:id/priority.
class PriorityOverrideResult {
  final String? status;
  final int? newScore;
  final int? priorityScore;
  PriorityOverrideResult({this.status, this.newScore, this.priorityScore});

  factory PriorityOverrideResult.fromJson(Map<String, dynamic> json) {
    return PriorityOverrideResult(
      status: json['status'] as String?,
      newScore: json['new_score'] as int?,
      priorityScore: json['priority_score'] as int?,
    );
  }
}

class ClientErrorResult {
  final bool success;
  ClientErrorResult({required this.success});

  factory ClientErrorResult.fromJson(Map<String, dynamic> json) {
    return ClientErrorResult(success: json['success'] as bool? ?? true);
  }
}

class MarkReadResult {
  final bool success;
  MarkReadResult({required this.success});

  factory MarkReadResult.fromJson(Map<String, dynamic> json) {
    return MarkReadResult(success: json['success'] as bool? ?? true);
  }
}

class AiAssessmentResult {
  final double? confidenceScore;
  final List<String>? supportingFactors;
  final List<String>? riskFactors;
  final List<DuplicateCandidate>? duplicateCandidates;
  AiAssessmentResult({
    this.confidenceScore,
    this.supportingFactors,
    this.riskFactors,
    this.duplicateCandidates,
  });

  factory AiAssessmentResult.fromJson(Map<String, dynamic> json) {
    return AiAssessmentResult(
      confidenceScore: (json['confidence_score'] as num?)?.toDouble(),
      supportingFactors: (json['supporting_factors'] as List?)
          ?.map((e) => e as String)
          .toList(),
      riskFactors: (json['risk_factors'] as List?)
          ?.map((e) => e as String)
          .toList(),
      duplicateCandidates: (json['duplicate_candidates'] as List?)
          ?.map((e) => DuplicateCandidate.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Creates from agent store AssessmentResponse format
  factory AiAssessmentResult._fromAssessmentResponse(
    Map<String, dynamic> json,
  ) {
    final factors = json['factors'] as Map<String, dynamic>?;
    return AiAssessmentResult(
      confidenceScore: (json['confidence'] as num?)?.toDouble(),
      supportingFactors: (factors?['supporting'] as List?)
          ?.map((e) => e as String)
          .toList(),
      riskFactors: (factors?['risk'] as List?)
          ?.map((e) => e as String)
          .toList(),
      duplicateCandidates: null, // not in assessment response
    );
  }
}

class TriggerAssessmentResult {
  final String? reportId;
  final String? overallStatus;
  TriggerAssessmentResult({this.reportId, this.overallStatus});

  factory TriggerAssessmentResult.fromJson(Map<String, dynamic> json) {
    return TriggerAssessmentResult(
      reportId: json['report_id'] as String?,
      overallStatus: json['overall_status'] as String?,
    );
  }
}

// â”€â”€â”€ API Client â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class ApiClient {
  final Dio _dio;
  final Dio _publicDio;
  final Future<void> Function()? _checkConnectivityFn;

  ApiClient({
    String? baseUrl,
    FlutterSecureStorage? storage,
    Future<void> Function()? onLogout,
    Dio? dio,
    Future<void> Function()? checkConnectivity,
    String? testAccessToken,

    /// When provided, this function is called with the role string to retrieve
    /// the auth token INSTEAD of reading from secure storage.
    /// This is the dependency-injection seam for tests — production behavior
    /// is byte-identical when this is null (storage read is used).
    Future<String?> Function(String role)? authTokenProvider,
  }) : _dio =
           dio ??
           Dio(
             BaseOptions(
               baseUrl: baseUrl ?? ApiConfig.baseUrl,
               connectTimeout: const Duration(seconds: 10),
               receiveTimeout: const Duration(seconds: 30),
               // Accept 2xx success and 503 (Workers CPU-limit) so retry logic can handle
               // transient 503s while letting other errors throw as DioException
               validateStatus: (int? status) =>
                   status != null && (status < 400 || status == 503),
             ),
           ),
       _checkConnectivityFn = checkConnectivity,
       _publicDio = Dio(
         BaseOptions(
           baseUrl: baseUrl ?? ApiConfig.baseUrl,
           connectTimeout: const Duration(seconds: 30),
           receiveTimeout: const Duration(seconds: 30),
           // Accept 2xx success and 503 so retry logic can handle transient 503s
           validateStatus: (int? status) =>
               status != null && (status < 400 || status == 503),
         ),
       ) {
    // Apply explicit baseUrl even when custom dio is provided
    // (explicit param wins over dart-define default)
    if (baseUrl != null && dio != null) {
      _dio.options.baseUrl = baseUrl;
      _publicDio.options.baseUrl = baseUrl;
    }
    // Only add interceptor if we're using the internally created Dio
    if (dio == null) {
      final effectiveStorage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
          );
      _dio.interceptors.add(
        AuthInterceptor(
          storage: effectiveStorage,
          dio: _dio,
          onLogout: onLogout ?? () async {},
          testAccessToken: testAccessToken,
          authTokenProvider: authTokenProvider,
        ),
      );
    }
  }

  Dio get dio => _dio;

  Future<void> _checkConnectivity() async {
    if (_checkConnectivityFn != null) {
      await _checkConnectivityFn();
      return;
    }
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) {
      throw ConnectivityException();
    }
  }

  /// Enforces that the response contains the required envelope key.
  /// Throws FormatException if the key is missing.
  Map<String, dynamic> _expectKey(Map<String, dynamic> data, String key) {
    if (!data.containsKey(key)) {
      throw FormatException(
        'Unexpected response shape at: expected "$key" key',
      );
    }
    return data;
  }

  /// Enforces that the response is a list under the given key.
  /// Throws FormatException if the key is missing or data is not a list.
  List<dynamic> _expectListKey(Map<String, dynamic> data, String key) {
    if (!data.containsKey(key)) {
      throw FormatException(
        'Unexpected response shape at: expected "$key" key',
      );
    }
    final value = data[key];
    if (value is! List) {
      throw FormatException(
        'Unexpected response shape at: expected "$key" to be a list',
      );
    }
    return value;
  }

  Future<T> _execute<T>({
    required Future<Response<dynamic>> Function() dioCall,
    required String endpoint,
    required T Function(dynamic data) parse,
  }) async {
    await _checkConnectivity();
    final backoffs = [
      const Duration(seconds: 2),
      const Duration(seconds: 4),
      const Duration(seconds: 6),
    ];
    Object? lastError;
    for (var attempt = 0; attempt <= 3; attempt++) {
      try {
        final res = await dioCall();
        final sc = res.statusCode ?? 0;

        // validateStatus may be set to accept-all (test/prod clients), so
        // non-2xx responses arrive here instead of as DioException.badResponse.
        // Map them through the same error pipeline to keep ApiException
        // semantics consistent for every caller.
        if (sc >= 400) {
          final apiErr = ApiException(
            statusCode: sc,
            body: res.data?.toString(),
            endpoint: endpoint,
            userMessage: '${extractErrorMessageFromData(res.data)} [$endpoint]',
          );
          final retryable =
              sc == 503 || (res.data?.toString().contains('1102') ?? false);
          if (retryable && attempt < 3) {
            lastError = apiErr;
            await Future.delayed(backoffs[attempt]);
            continue;
          }
          throw apiErr;
        }

        return parse(res.data);
      } on DioException catch (e) {
        final statusCode = e.response?.statusCode;
        final bodyStr = e.response?.data?.toString() ?? '';
        final retryable = statusCode == 503 || bodyStr.contains('1102');
        if (retryable && attempt < 3) {
          lastError = e;
          await Future.delayed(backoffs[attempt]);
          continue;
        }
        if (attempt >= 3 && lastError != null) throw lastError;
        switch (e.type) {
          case DioExceptionType.connectionError:
          case DioExceptionType.connectionTimeout:
            throw NetworkException('Tidak dapat terhubung ke server.');
          case DioExceptionType.sendTimeout:
          case DioExceptionType.receiveTimeout:
            throw TimeoutException(const Duration(seconds: 30), endpoint);
          case DioExceptionType.badResponse:
            final userMessage = extractErrorMessage(e);
            throw ApiException(
              statusCode: e.response?.statusCode ?? 0,
              body: e.response?.data?.toString(),
              endpoint: endpoint,
              userMessage: '$userMessage [$endpoint]',
            );
          default:
            final userMessage = extractErrorMessage(e);
            throw ApiException(
              statusCode: 0,
              body: e.message ?? 'Unknown error',
              endpoint: endpoint,
              userMessage: '$userMessage [$endpoint]',
            );
        }
      }
    }
    throw lastError ?? Exception('Unexpected retry loop exit');
  }

  // â”€â”€â”€ Auth â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  /// Logs in a user with email and password.
  /// Returns a [LoginResponse] containing token and user data.
  Future<LoginResponse> login(String email, String password) async {
    return await _execute<LoginResponse>(
      dioCall: () => _dio.post(
        '/api/auth/login',
        data: {'email': email, 'password': password},
        options: Options(contentType: 'application/json'),
      ),
      endpoint: '/api/auth/login',
      parse: (data) =>
          LoginResponse.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  /// Logs out a user by invalidating the refresh token.
  Future<void> logout(String refreshToken) async {
    await _execute<void>(
      dioCall: () =>
          _dio.post('/api/auth/logout', data: {'refresh_token': refreshToken}),
      endpoint: '/api/auth/logout',
      parse: (_) {},
    );
  }

  /// Validates if the current user has the specified role.
  Future<ValidationResult> validateRole(String role) async {
    return await _execute<ValidationResult>(
      dioCall: () =>
          _dio.get('/api/auth/validate-role', queryParameters: {'role': role}),
      endpoint: '/api/auth/validate-role',
      parse: (data) =>
          ValidationResult.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  // â”€â”€â”€ Categories â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  /// Fetches all categories.
  Future<List<Category>> getCategories() async {
    final data = _expectListKey(
      await _execute<Map<String, dynamic>>(
        dioCall: () => _dio.get('/api/categories'),
        endpoint: '/api/categories',
        parse: (data) => (data as Map).cast<String, dynamic>(),
      ),
      'categories',
    );
    return data
        .map((e) => Category.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }

  /// Fetches all categories with their slugs.
  /// Returns a list of maps with 'slug' and 'name' keys.
  Future<List<Map<String, String>>> getCategoriesWithSlug() async {
    final data = _expectListKey(
      await _execute<Map<String, dynamic>>(
        dioCall: () => _dio.get('/api/categories'),
        endpoint: '/api/categories',
        parse: (data) => (data as Map).cast<String, dynamic>(),
      ),
      'categories',
    );
    return data
        .map(
          (e) => {
            'slug': (e as Map)['slug']?.toString() ?? e['id']?.toString() ?? '',
            'name': e['name']?.toString() ?? '',
          },
        )
        .toList();
  }

  /// Creates a new category.
  /// Backend: POST /api/categories → created category object (201)
  Future<CategoryResult> createCategory({
    required String name,
    required String slug,
    String? icon,
    String? description,
    String? parentId,
    String? code,
    String? shortCode,
    String? colorClass,
  }) async {
    return await _execute<CategoryResult>(
      dioCall: () => _dio.post(
        '/api/categories',
        data: {
          'name': name,
          'slug': slug,
          if (icon != null) 'icon': icon,
          if (description != null) 'description': description,
          if (parentId != null) 'parent_id': parentId,
          if (code != null) 'code': code,
          if (shortCode != null) 'short_code': shortCode,
          if (colorClass != null) 'color_class': colorClass,
        },
      ),
      endpoint: '/api/categories',
      parse: (data) =>
          CategoryResult.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  /// Updates an existing category.
  /// Backend: PATCH /api/categories/:id → updated category object
  Future<CategoryResult> updateCategory(
    String id, {
    String? name,
    String? slug,
    String? icon,
    String? description,
    String? parentId,
    String? code,
    String? shortCode,
    String? colorClass,
  }) async {
    return await _execute<CategoryResult>(
      dioCall: () => _dio.patch(
        '/api/categories/$id',
        data: {
          if (name != null) 'name': name,
          if (slug != null) 'slug': slug,
          if (icon != null) 'icon': icon,
          if (description != null) 'description': description,
          if (parentId != null) 'parent_id': parentId,
          if (code != null) 'code': code,
          if (shortCode != null) 'short_code': shortCode,
          if (colorClass != null) 'color_class': colorClass,
        },
      ),
      endpoint: '/api/categories/$id',
      parse: (data) =>
          CategoryResult.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  /// Deletes a category (soft delete).
  /// Backend: DELETE /api/categories/:id → {success: true}
  Future<void> deleteCategory(String id) async {
    await _execute<void>(
      dioCall: () => _dio.delete('/api/categories/$id'),
      endpoint: '/api/categories/$id',
      parse: (_) {},
    );
  }

  // â”€â”€â”€ Sync/Batch â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  /// Syncs batch of reports from offline queue.
  Future<SyncBatchResult> syncBatch({
    required List<Map<String, dynamic>> reports,
    String? deviceId,
  }) async {
    return await _execute<SyncBatchResult>(
      dioCall: () => _dio.post(
        '/api/sync/batch',
        data: {'device_id': deviceId, 'reports': reports},
      ),
      endpoint: '/api/sync/batch',
      parse: (data) =>
          parseSyncBatchResult((data as Map).cast<String, dynamic>()),
    );
  }

  // â”€â”€â”€ Agent/AI Assessment â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  /// Fetches AI pre-verification assessment for a report.
  /// Retries up to 24 times with 5-second delays since AI assessment runs
  /// asynchronously via waitUntil and may not be ready immediately.
  /// MiniMax M3 vision calls can take 30-90s to complete.
  Future<AiAssessmentResult> getAiAssessment(String reportId) async {
    for (var attempt = 0; attempt < 24; attempt++) {
      final res = await _dio.get('/api/agent/assessments/$reportId');
      if (res.data is Map) {
        final map = (res.data as Map).cast<String, dynamic>();
        // Server returns { assessments: [...] } - no data envelope
        final assessments = map['assessments'];
        if (assessments is List && assessments.isNotEmpty) {
          final first = assessments[0] as Map<String, dynamic>;
          return AiAssessmentResult._fromAssessmentResponse(first);
        }
      }
      await Future<void>.delayed(const Duration(seconds: 5));
    }
    throw const FormatException(
      'AI assessment did not complete within timeout',
    );
  }

  /// Triggers AI assessment for a report (fire-and-forget async trigger).
  /// Backend: POST /api/agent/assess → {report_id, overall_status, tool_results}
  Future<TriggerAssessmentResult> triggerAssessment(
    String reportId, {
    String? idempotencyKey,
  }) async {
    return await _execute<TriggerAssessmentResult>(
      dioCall: () => _dio.post(
        '/api/agent/assess',
        data: {
          'report_id': reportId,
          if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
        },
      ),
      endpoint: '/api/agent/assess',
      parse: (data) => TriggerAssessmentResult.fromJson(
        (data as Map).cast<String, dynamic>(),
      ),
    );
  }

  // â”€â”€â”€ Reports (Warga) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  /// Fetches warga's own reports.
  Future<WargaReportsPage> getWargaReports() async {
    final data = await _execute<Map<String, dynamic>>(
      dioCall: () =>
          _dio.get('/api/reports', queryParameters: {'creator_id': 'me'}),
      endpoint: '/api/reports?creator_id=me',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
    // Server returns { items: [...], pagination: {...} } directly, no envelope
    final itemsData = _expectListKey(data, 'items');
    return WargaReportsPage(
      items: itemsData
          .map((e) => Report.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
    );
  }

  // â”€â”€â”€ Reports Actions â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  /// Uploads a photo and returns the public URL.
  Future<UploadPhotoResult> uploadSinglePhoto(
    String path, {
    required String description,
    required String photoPath,
  }) async {
    final file = File(photoPath);
    final bytes = await file.readAsBytes();
    final name = photoPath.split('/').last;
    final formData = FormData.fromMap({
      'description': description,
      'photo': MultipartFile.fromBytes(bytes, filename: name),
    });
    return await _execute<UploadPhotoResult>(
      dioCall: () => _dio.post(path, data: formData),
      endpoint: path,
      parse: (data) =>
          UploadPhotoResult.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  /// Uploads photo anonymously for warga evidence.
  Future<UploadPhotoResult> uploadReportPhotoAnon({
    required String filePath,
    required String idempotencyKey,
  }) async {
    final file = File(filePath);
    final bytes = await file.readAsBytes();
    final name = filePath.split('/').last;
    // Infer content type from file extension to satisfy server's allowed types check
    final ext = name.toLowerCase().split('.').last;
    final formData = FormData.fromMap({
      'photo': MultipartFile.fromBytes(
        bytes,
        filename: name,
        contentType: DioMediaType(
          'image',
          ext == 'png'
              ? 'png'
              : ext == 'webp'
              ? 'webp'
              : 'jpeg',
        ),
      ),
      'idempotency_key': idempotencyKey,
    });

    final res = await _publicDio.post(
      '/api/reports/photos/upload-url-anon',
      data: formData,
    );

    // Server returns { public_url: "..." } directly, no data envelope
    return UploadPhotoResult.fromJson(
      (res.data as Map).cast<String, dynamic>(),
    );
  }

  /// Submits sanggahan (objection) for a report.
  Future<SanggahanResult> wargaFileSanggahan({
    required String reportId,
    required String reason,
  }) async {
    return await _execute<SanggahanResult>(
      dioCall: () => _dio.post(
        '/api/reports/$reportId/sanggahan',
        data: {'reason': reason},
      ),
      endpoint: '/api/reports/$reportId/sanggahan',
      parse: (data) =>
          SanggahanResult.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  /// Requests reopening of a resolved report.
  Future<ReopenResult> wargaRequestReopen({
    required String reportId,
    required String reason,
  }) async {
    return await _execute<ReopenResult>(
      dioCall: () =>
          _dio.post('/api/reports/$reportId/reopen', data: {'reason': reason}),
      endpoint: '/api/reports/$reportId/reopen',
      parse: (data) =>
          ReopenResult.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  /// Submits evidence photos for a warga report.
  /// Backend: POST /api/reports/:id/evidence → {success: true, evidence_id}
  /// Each photo upload returns an evidence_id from the backend.
  Future<List<EvidenceResult>> wargaSubmitEvidence({
    required String reportId,
    required String description,
    required List<String> photoPaths,
  }) async {
    final results = <EvidenceResult>[];
    for (final photoPath in photoPaths) {
      final file = File(photoPath);
      final bytes = await file.readAsBytes();
      final name = photoPath.split('/').last;
      final formData = FormData.fromMap({
        'description': description,
        'photo': MultipartFile.fromBytes(bytes, filename: name),
      });
      final res = await _dio.post(
        '/api/reports/$reportId/evidence',
        data: formData,
      );
      final data = (res.data as Map).cast<String, dynamic>();
      results.add(
        EvidenceResult(
          evidenceId: data['evidence_id']?.toString(),
          photoUrls: null,
        ),
      );
    }
    return results;
  }

  /// Fetches nearby reports based on user location.
  Future<List<NearbyReport>> getNearbyReports({
    required double lat,
    required double lng,
  }) async {
    final data = await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.get(
        '/api/reports/nearby',
        queryParameters: {'lat': lat, 'lng': lng},
      ),
      endpoint: '/api/reports/nearby',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
    // Server returns { reports: [...] } directly, no envelope
    final reportsData = _expectListKey(data, 'reports');
    return reportsData
        .map((e) => NearbyReport.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }

  /// Fetches duplicate case candidates for a given location and category.
  /// Server returns: {candidates: [...]} directly, no envelope.
  Future<List<DuplicateCandidate>> getDuplicateCases({
    required double lat,
    required double lng,
    String? categoryId,
  }) async {
    final data = await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.get(
        '/api/reports/duplicates',
        queryParameters: {
          'lat': lat,
          'lng': lng,
          if (categoryId != null) 'category_id': categoryId,
        },
      ),
      endpoint: '/api/reports/duplicates',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
    final candidatesData = _expectListKey(data, 'candidates');
    return candidatesData
        .map(
          (e) =>
              DuplicateCandidate.fromJson((e as Map).cast<String, dynamic>()),
        )
        .toList();
  }

  /// Fetches the timeline/history events for a given report.
  Future<TimelineEnvelope> getReportTimeline(String reportId) async {
    return await _execute<TimelineEnvelope>(
      dioCall: () => _dio.get('/api/reports/$reportId/timeline'),
      endpoint: '/api/reports/$reportId/timeline',
      // Server returns {events: [...]} directly without data envelope
      parse: (data) =>
          TimelineEnvelope.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  // â”€â”€â”€ Cases â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  /// Fetches the verifikator/operator queue (list of cases pending review).
  /// Requires VERIFIKATOR or ADMIN role.
  Future<VerifikatorQueuePage> getVerifikatorQueue({
    required String activeRole,
    String? status,
    int page = 1,
    int limit = 20,
    String? kategori,
  }) async {
    if (activeRole != 'VERIFIKATOR' && activeRole != 'ADMIN') {
      throw ApiException(
        statusCode: 403,
        endpoint: '/api/cases/queue',
        userMessage: 'Endpoint requires VERIFIKATOR or ADMIN role',
      );
    }
    // Server returns {items, pagination} - no 'data' envelope
    final response = await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.get(
        '/api/cases/queue',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (status != null) 'status': status,
          if (kategori != null) 'kategori': kategori,
        },
      ),
      endpoint: '/api/cases/queue',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
    final bool hasDataEnvelope =
        response.containsKey('data') && response['data'] is Map;
    final Map<String, dynamic> inner = hasDataEnvelope
        ? (response['data'] as Map).cast<String, dynamic>()
        : response;
    if (!inner.containsKey('items') || !inner.containsKey('pagination')) {
      throw FormatException(
        'Unexpected response shape: expected items and pagination keys',
      );
    }
    final itemsData = inner['items'];
    final paginationData = inner['pagination'];
    return VerifikatorQueuePage(
      items: (itemsData as List)
          .map((e) => Report.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
      pagination: Pagination.fromJson(
        (paginationData as Map).cast<String, dynamic>(),
      ),
    );
  }

  /// Fetches a single case by ID.
  /// Requires VERIFIKATOR or ADMIN role.
  Future<CaseDetail> getVerifikatorCase({
    required String caseId,
    required String activeRole,
  }) async {
    if (activeRole != 'VERIFIKATOR' && activeRole != 'ADMIN') {
      throw ApiException(
        statusCode: 403,
        endpoint: '/api/cases/$caseId',
        userMessage: 'Endpoint requires VERIFIKATOR or ADMIN role',
      );
    }
    // Server returns case detail directly - no 'data' envelope
    return await _execute<CaseDetail>(
      dioCall: () => _dio.get('/api/cases/$caseId'),
      endpoint: '/api/cases/$caseId',
      parse: (data) =>
          CaseDetail.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  /// Makes a decision on a case.
  /// Requires VERIFIKATOR or ADMIN role.
  Future<DecideResult> decideVerifikatorCase({
    required String activeRole,
    required String caseId,
    required String decision,
    required String reason,
    String? duplicateOfReportId,
    String? surveyorId,
    String? assignedUnitId,
    String? deadline,
  }) async {
    if (activeRole != 'VERIFIKATOR' && activeRole != 'ADMIN') {
      throw ApiException(
        statusCode: 403,
        endpoint: '/api/cases/$caseId/decide',
        userMessage: 'Endpoint requires VERIFIKATOR or ADMIN role',
      );
    }
    return await _execute<DecideResult>(
      dioCall: () => _dio.post(
        '/api/cases/$caseId/decide',
        data: {
          'decision': decision,
          'reason': reason,
          if (duplicateOfReportId != null)
            'duplicate_of_report_id': duplicateOfReportId,
          if (surveyorId != null) 'surveyor_id': surveyorId,
          if (assignedUnitId != null) 'assigned_unit_id': assignedUnitId,
          if (deadline != null) 'deadline': deadline,
        },
      ),
      endpoint: '/api/cases/$caseId/decide',
      parse: (data) =>
          DecideResult.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  // â”€â”€â”€ RT-RW â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  /// Verifies a report via RT/RW.
  /// Backend: POST /api/rt-rw/verify → {success: true, report_id, status}
  /// Backend validates verdict against: ["valid","needs_completion","needs_survey","out_of_scope","duplicate","rejected","confirmed"]
  Future<RtRwVerifyResult> rtRwVerify({
    required String verificationToken,
    required String reportId,
    required RtRwVerdict verdict,
    String? reason,
    String? photoPath,
  }) async {
    final mapData = <String, dynamic>{
      'verification_token': verificationToken,
      'report_id': reportId,
      'verdict': verdict.value,
    };
    if (reason != null) {
      mapData['reason'] = reason;
    }
    if (photoPath != null) {
      final file = File(photoPath);
      final bytes = await file.readAsBytes();
      final name = photoPath.split('/').last;
      mapData['photo'] = MultipartFile.fromBytes(bytes, filename: name);
    }
    final formData = FormData.fromMap(mapData);
    return await _execute<RtRwVerifyResult>(
      dioCall: () => _dio.post('/api/rt-rw/verify', data: formData),
      endpoint: '/api/rt-rw/verify',
      parse: (data) =>
          RtRwVerifyResult.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  // â”€â”€â”€ Tasks (Petugas) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  /// Fetches petugas task list.
  Future<TaskListPage> petugasGetTasks() async {
    final data = await _execute<Map<String, dynamic>>(
      dioCall: () =>
          _dio.get('/api/tasks', queryParameters: {'role': 'petugas'}),
      endpoint: '/api/tasks?role=petugas',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
    // Server returns {tasks: [...], pagination: {...}} directly
    List<dynamic> tasksList = [];
    try {
      final rawTasks = data['tasks'];
      if (rawTasks is List) {
        tasksList = rawTasks;
      }
    } catch (_) {}
    // pagination may be absent
    Map<String, dynamic>? paginationData;
    try {
      paginationData = data['pagination'] as Map<String, dynamic>?;
    } catch (_) {}
    return TaskListPage<PetugasTask>(
      tasks: tasksList
          .map((e) => PetugasTask.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
      pagination: paginationData != null
          ? Pagination.fromJson(paginationData)
          : Pagination(page: 1, limit: 20, total: 0),
    );
  }

  /// Updates progress on a petugas task.
  Future<ProgressResult> petugasUpdateProgress({
    required String taskId,
    required int progressPercent,
    String? notes,
    String? estimatedCompletion,
  }) async {
    return await _execute<ProgressResult>(
      dioCall: () => _dio.patch(
        '/api/tasks/$taskId/progress',
        data: {
          'progress_percent': progressPercent,
          if (notes != null) 'notes': notes,
          if (estimatedCompletion != null)
            'estimated_completion': estimatedCompletion,
        },
        options: Options(contentType: 'application/json'),
      ),
      endpoint: '/api/tasks/$taskId/progress',
      parse: (data) =>
          ProgressResult.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  // â”€â”€â”€ Tasks (Surveyor) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  /// Fetches surveyor task list.
  Future<TaskListPage> surveyorGetTasks() async {
    final data = await _execute<Map<String, dynamic>>(
      dioCall: () =>
          _dio.get('/api/tasks', queryParameters: {'role': 'surveyor'}),
      endpoint: '/api/tasks?role=surveyor',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
    // Server returns {tasks: [...], pagination: {...}} directly
    // _expectKey(data, 'tasks') returns data itself if key exists,
    // so we access data['tasks'] directly
    List<dynamic> tasksList = [];
    try {
      final rawTasks = data['tasks'];
      if (rawTasks is List) {
        tasksList = rawTasks;
      }
    } catch (_) {}
    // pagination may be absent
    Map<String, dynamic>? paginationData;
    try {
      paginationData = data['pagination'] as Map<String, dynamic>?;
    } catch (_) {}
    return TaskListPage<SurveyorTask>(
      tasks: tasksList
          .map((e) => SurveyorTask.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
      pagination: paginationData != null
          ? Pagination.fromJson(paginationData)
          : Pagination(page: 1, limit: 20, total: 0),
    );
  }

  /// Submits a structured visit report for a surveyor task.
  ///
  /// Throws [ArgumentError] if findings, checklist, or gps coordinates are empty/missing.
  Future<VisitResult> submitVisitReport({
    required String taskId,
    required String findings,
    required List<Map<String, dynamic>> checklist,
    required List<String> photoUrls,
    required double gpsLat,
    required double gpsLng,
    required double accuracy,
    required String conditionAssessment,
    required String recommendation,
    String? catatan,
  }) async {
    if (findings.isEmpty) {
      throw ArgumentError('submitVisitReport requires non-empty findings');
    }
    if (checklist.isEmpty) {
      throw ArgumentError('submitVisitReport requires non-empty checklist');
    }
    if (gpsLat == 0 && gpsLng == 0) {
      throw ArgumentError(
        'submitVisitReport requires valid GPS coordinates (gpsLat, gpsLng)',
      );
    }

    return await _execute<VisitResult>(
      dioCall: () => _dio.post(
        '/api/tasks/$taskId/visit',
        data: {
          'findings': findings,
          'checklist': checklist,
          'photo_urls': photoUrls,
          'condition_assessment': conditionAssessment,
          'recommendation': recommendation,
          'gps': {'lat': gpsLat, 'lng': gpsLng, 'accuracy_m': accuracy},
          if (catatan != null && catatan.isNotEmpty) 'notes': catatan,
        },
      ),
      endpoint: '/api/tasks/$taskId/visit',
      parse: (data) =>
          VisitResult.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  // â”€â”€â”€ Warga Stats â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  /// Fetches warga statistics.
  Future<WargaStats> getWargaStats() async {
    return await _execute<WargaStats>(
      dioCall: () => _dio.get('/api/warga/stats'),
      endpoint: '/api/warga/stats',
      parse: (data) =>
          WargaStats.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  // â”€â”€â”€ Stats â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  /// Fetches role-shaped statistics.
  Future<StatsResponse> getStats() async {
    return await _execute<StatsResponse>(
      dioCall: () => _dio.get('/api/reports/stats'),
      endpoint: '/api/reports/stats',
      parse: (data) =>
          StatsResponse.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  // â”€â”€â”€ Executive â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  /// Fetches executive dashboard summary.
  /// Requires PENGAMBIL_KEPUTUSAN or ADMIN role.
  Future<StatsResponse> getExecutiveDashboard({
    required String activeRole,
  }) async {
    if (activeRole != 'PENGAMBIL_KEPUTUSAN' && activeRole != 'ADMIN') {
      throw ApiException(
        statusCode: 403,
        endpoint: '/api/executive/dashboard',
        userMessage: 'Endpoint requires PENGAMBIL_KEPUTUSAN or ADMIN role',
      );
    }
    return await _execute<StatsResponse>(
      dioCall: () => _dio.get('/api/executive/dashboard'),
      endpoint: '/api/executive/dashboard',
      parse: (data) =>
          StatsResponse.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  /// Fetches executive regional statistics.
  /// Requires PENGAMBIL_KEPUTUSAN or ADMIN role.
  Future<StatsResponse> getExecutiveRegionalStats({
    required String activeRole,
  }) async {
    if (activeRole != 'PENGAMBIL_KEPUTUSAN' && activeRole != 'ADMIN') {
      throw ApiException(
        statusCode: 403,
        endpoint: '/api/executive/regional-stats',
        userMessage: 'Endpoint requires PENGAMBIL_KEPUTUSAN or ADMIN role',
      );
    }
    return await _execute<StatsResponse>(
      dioCall: () => _dio.get('/api/executive/regional-stats'),
      endpoint: '/api/executive/regional-stats',
      parse: (data) =>
          StatsResponse.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  /// Fetches executive trend analysis over a given period.
  /// Requires PENGAMBIL_KEPUTUSAN or ADMIN role.
  Future<ExecutiveTrend> getExecutiveTrendAnalysis({
    required String activeRole,
    required String period,
  }) async {
    if (activeRole != 'PENGAMBIL_KEPUTUSAN' && activeRole != 'ADMIN') {
      throw ApiException(
        statusCode: 403,
        endpoint: '/api/executive/trend-analysis',
        userMessage: 'Endpoint requires PENGAMBIL_KEPUTUSAN or ADMIN role',
      );
    }
    return await _execute<ExecutiveTrend>(
      dioCall: () => _dio.get(
        '/api/executive/trend-analysis',
        queryParameters: {'period': period},
      ),
      endpoint: '/api/executive/trend-analysis',
      parse: (data) =>
          ExecutiveTrend.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  // â”€â”€â”€ Export â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  /// Exports reports as PDF.
  Future<Uint8List> exportPdf({
    String? status,
    String? categoryId,
    String? wilayahId,
    String? from,
    String? to,
  }) async {
    final query = <String, String>{};
    if (status != null) query['status'] = status;
    if (categoryId != null) query['category_id'] = categoryId;
    if (wilayahId != null) query['wilayah_id'] = wilayahId;
    if (from != null) query['from'] = from;
    if (to != null) query['to'] = to;
    final uri = Uri.parse(
      '${_dio.options.baseUrl}/api/export/pdf',
    ).replace(queryParameters: query.isEmpty ? null : query);
    final resp = await _dio.get<List<int>>(
      uri.toString(),
      options: Options(responseType: ResponseType.bytes),
    );
    return Uint8List.fromList(resp.data ?? []);
  }

  /// Exports reports as GeoJSON FeatureCollection.
  Future<GeoJSONFeatureCollection> getExportGeojson({
    String? status,
    String? categoryId,
  }) async {
    // Server returns GeoJSON directly - no 'data' envelope
    return await _execute<GeoJSONFeatureCollection>(
      dioCall: () => _dio.get(
        '/api/export/geojson',
        queryParameters: {
          if (status != null) 'status': status,
          if (categoryId != null) 'category_id': categoryId,
        },
      ),
      endpoint: '/api/export/geojson',
      parse: (data) => GeoJSONFeatureCollection.fromJson(
        (data as Map).cast<String, dynamic>(),
      ),
    );
  }

  // â”€â”€â”€ Notifications â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  /// Fetches notifications from the server.
  Future<NotificationPage> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    // Server returns {entries} - no 'data' envelope
    final response = await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.get(
        '/api/notifications',
        queryParameters: {'page': page, 'limit': limit},
      ),
      endpoint: '/api/notifications',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
    if (!response.containsKey('entries')) {
      throw FormatException('Unexpected response shape: expected entries key');
    }
    final entriesData = response['entries'];
    return NotificationPage(
      entries: (entriesData as List)
          .map((e) => Notification.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
    );
  }

  /// Marks a notification as read.
  Future<MarkReadResult> markNotificationRead(String notificationId) async {
    return await _execute<MarkReadResult>(
      dioCall: () => _dio.post(
        '/api/notifications/mark-read',
        data: {'id': notificationId},
      ),
      endpoint: '/api/notifications/mark-read',
      parse: (data) =>
          MarkReadResult.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  /// Marks all notifications as read.
  Future<MarkReadResult> markAllNotificationsRead() async {
    return await _execute<MarkReadResult>(
      dioCall: () =>
          _dio.post('/api/notifications/mark-read', data: {'mark_all': true}),
      endpoint: '/api/notifications/mark-read',
      parse: (data) =>
          MarkReadResult.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  // â”€â”€â”€ Wilayah â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  /// Fetches the wilayah (region) list.
  /// Contract specifies response is { wilayah: [...] } not { data: { items: [...] } }
  Future<List<Wilayah>> getWilayahList() async {
    final data = await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.get('/api/wilayah'),
      endpoint: '/api/wilayah',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
    // Contract says envelope key is 'wilayah', not 'data'
    final wilayahData = data['wilayah'] ?? data['data']?['items'];
    if (wilayahData == null) {
      throw FormatException('Expected wilayah key in response: $data');
    }
    return (wilayahData as List)
        .map((e) => Wilayah.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }

  // â”€â”€â”€ Units â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  /// Fetches units list (for admin daerah).
  /// Backend: GET /api/admin-daerah/units → {data: [...], pagination: {...}}
  Future<UnitsPage> getUnits({
    int page = 1,
    int limit = 20,
    String? wilayahId,
    bool? isActive,
  }) async {
    final response = await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.get(
        '/api/admin-daerah/units',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (wilayahId != null) 'wilayah_id': wilayahId,
          if (isActive != null) 'is_active': isActive.toString(),
        },
      ),
      endpoint: '/api/admin-daerah/units',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
    if (!response.containsKey('data') || !response.containsKey('pagination')) {
      throw FormatException(
        'Unexpected response shape: expected data and pagination keys',
      );
    }
    final unitsData = response['data'];
    final paginationData = response['pagination'] as Map? ?? {};
    return UnitsPage(
      entries: (unitsData as List)
          .map((e) => Unit.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
      total: paginationData['total'] as int? ?? 0,
      page: paginationData['page'] as int? ?? page,
      limit: paginationData['limit'] as int? ?? limit,
    );
  }

  // â”€â”€â”€ Admin Daerah â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  /// Fetches admin daerah cases list.
  /// Backend: GET /api/admin-daerah/cases → {data: [...], pagination: {...}}
  Future<VerifikatorQueuePage> getAdminDaerahCases({
    int page = 1,
    int limit = 20,
    String? status,
    String? categoryId,
    String? search,
    String? severity,
  }) async {
    final response = await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.get(
        '/api/admin-daerah/cases',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (status != null) 'status': status,
          if (categoryId != null) 'category_id': categoryId,
          if (search != null) 'search': search,
          if (severity != null) 'severity': severity,
        },
      ),
      endpoint: '/api/admin-daerah/cases',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
    if (!response.containsKey('data') || !response.containsKey('pagination')) {
      throw FormatException(
        'Unexpected response shape: expected data and pagination keys',
      );
    }
    final itemsData = response['data'] as List;
    final paginationData = response['pagination'] as Map? ?? {};
    return VerifikatorQueuePage(
      items: itemsData
          .map((e) => Report.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
      pagination: Pagination.fromJson(paginationData.cast<String, dynamic>()),
    );
  }

  /// Fetches admin daerah operators list (paginated).
  /// Backend: GET /api/admin-daerah/operators → {data: [...], pagination: {page, limit, total, total_pages}}
  Future<AdminDaerahOperatorsPage> getAdminDaerahOperators({
    int page = 1,
    int limit = 20,
    String? search,
    bool? isActive,
  }) async {
    return await _execute<AdminDaerahOperatorsPage>(
      dioCall: () => _dio.get(
        '/api/admin-daerah/operators',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (search != null && search.isNotEmpty) 'search': search,
          if (isActive != null) 'is_active': isActive.toString(),
        },
      ),
      endpoint: '/api/admin-daerah/operators',
      parse: (data) => AdminDaerahOperatorsPage.fromJson(
        (data as Map).cast<String, dynamic>(),
      ),
    );
  }

  /// Fetches admin daerah petugas list (paginated).
  /// Backend: GET /api/admin-daerah/petugas → {data: [...], pagination: {page, limit, total, total_pages}}
  Future<AdminDaerahPetugasPage> getAdminDaerahPetugas({
    int page = 1,
    int limit = 20,
    String? search,
    bool? isActive,
  }) async {
    return await _execute<AdminDaerahPetugasPage>(
      dioCall: () => _dio.get(
        '/api/admin-daerah/petugas',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (search != null && search.isNotEmpty) 'search': search,
          if (isActive != null) 'is_active': isActive.toString(),
        },
      ),
      endpoint: '/api/admin-daerah/petugas',
      parse: (data) => AdminDaerahPetugasPage.fromJson(
        (data as Map).cast<String, dynamic>(),
      ),
    );
  }

  /// Fetches admin daerah dashboard statistics.
  /// Backend: GET /api/admin-daerah/dashboard → {total, by_status, by_category, active_operators, active_petugas, sla_breached, sla_at_risk, avg_verification_days, recent_submissions, resolved_this_month}
  Future<AdminDaerahDashboard> getAdminDaerahDashboard() async {
    return await _execute<AdminDaerahDashboard>(
      dioCall: () => _dio.get('/api/admin-daerah/dashboard'),
      endpoint: '/api/admin-daerah/dashboard',
      parse: (data) =>
          AdminDaerahDashboard.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  // â”€â”€â”€ Geocode â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  /// Fetches reverse geocoded address for given coordinates.
  Future<GeocodeResult> getGeocodeReverse({
    required double lat,
    required double lng,
  }) async {
    return await _execute<GeocodeResult>(
      dioCall: () => _dio.get(
        '/api/geocode/reverse',
        queryParameters: {'lat': lat, 'lng': lng},
      ),
      endpoint: '/api/geocode/reverse',
      parse: (data) =>
          GeocodeResult.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  // â”€â”€â”€ Facilities â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  /// Fetches facilities list.
  Future<List<Facility>> getFacilities() async {
    final data = _expectKey(
      await _execute<Map<String, dynamic>>(
        dioCall: () => _dio.get('/api/facilities'),
        endpoint: '/api/facilities',
        parse: (data) => (data as Map).cast<String, dynamic>(),
      ),
      'data',
    );
    final itemsData = _expectKey(data, 'items');
    return (itemsData as List)
        .map((e) => Facility.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }

  /// Fetches facilities cluster data for map visualization.
  /// Backend: GET /api/facilities/cluster?bbox=... → {clusters: [{lng, lat, count, dominant_status, dominant_category, color}]}
  Future<FacilitiesCluster> getFacilitiesCluster({
    required String bbox,
    int? zoom,
  }) async {
    return await _execute<FacilitiesCluster>(
      dioCall: () => _dio.get(
        '/api/facilities/cluster',
        queryParameters: {'bbox': bbox, if (zoom != null) 'zoom': zoom},
      ),
      endpoint: '/api/facilities/cluster',
      parse: (data) =>
          FacilitiesCluster.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  // â”€â”€â”€ Surveyors â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  /// Fetches surveyors list.
  /// Requires VERIFIKATOR or ADMIN role.
  Future<List<UserResponse>> getSurveyors({required String activeRole}) async {
    if (activeRole != 'VERIFIKATOR' && activeRole != 'ADMIN') {
      throw ApiException(
        statusCode: 403,
        endpoint: '/api/surveyors',
        userMessage: 'Endpoint requires VERIFIKATOR or ADMIN role',
      );
    }
    final data = _expectKey(
      await _execute<Map<String, dynamic>>(
        dioCall: () => _dio.get('/api/surveyors'),
        endpoint: '/api/surveyors',
        parse: (data) => (data as Map).cast<String, dynamic>(),
      ),
      'data',
    );
    final itemsData = _expectKey(data, 'items');
    return (itemsData as List)
        .map((e) => UserResponse.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }

  // â”€â”€â”€ Users â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  /// Fetches users list (admin).
  Future<UsersPage> getUsers({
    int page = 1,
    int limit = 20,
    String? role,
    String? search,
    bool? isActive,
  }) async {
    // Server returns {data: [...], pagination: {...}}
    final response = await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.get(
        '/api/users',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (role != null) 'role': role,
          if (search != null && search.isNotEmpty) 'search': search,
          if (isActive != null) 'is_active': isActive.toString(),
        },
      ),
      endpoint: '/api/users',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
    if (!response.containsKey('data') || !response.containsKey('pagination')) {
      throw FormatException(
        'Unexpected response shape: expected data and pagination keys',
      );
    }
    final usersData = response['data'];
    final paginationData = response['pagination'] as Map? ?? {};
    return UsersPage(
      entries: (usersData as List)
          .map((e) => UserResponse.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
      total: paginationData['total'] as int? ?? 0,
      page: paginationData['page'] as int? ?? page,
      limit: paginationData['limit'] as int? ?? limit,
    );
  }

  /// Updates user status (activate/deactivate).
  Future<UserResponse> updateUserStatus(String id, String status) async {
    return await _execute<UserResponse>(
      dioCall: () => _dio.patch('/api/users/$id', data: {'status': status}),
      endpoint: '/api/users/$id',
      parse: (data) =>
          UserResponse.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  // ─── SLA ──────────────────────────────────────────────────────────────────

  /// Fetches SLA configs.
  Future<SlaPage> getSlaConfigs({
    int page = 1,
    int limit = 20,
    String? kategoriId,
    String? prioritas,
    bool? isActive,
  }) async {
    // Server returns {data: [...], pagination: {...}}
    final response = await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.get(
        '/api/sla',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (kategoriId != null) 'kategori_id': kategoriId,
          if (prioritas != null) 'prioritas': prioritas,
          if (isActive != null) 'is_active': isActive.toString(),
        },
      ),
      endpoint: '/api/sla',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
    if (!response.containsKey('data') || !response.containsKey('pagination')) {
      throw FormatException(
        'Unexpected response shape: expected data and pagination keys',
      );
    }
    final slaData = response['data'];
    final paginationData = response['pagination'] as Map? ?? {};
    return SlaPage(
      entries: (slaData as List)
          .map((e) => SlaConfig.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
      total: paginationData['total'] as int? ?? 0,
      page: paginationData['page'] as int? ?? page,
      limit: paginationData['limit'] as int? ?? limit,
    );
  }

  // ─── Checklist Templates ──────────────────────────────────────────────────

  /// Fetches checklist templates.
  Future<ChecklistTemplatesPage> getChecklistTemplates({
    int page = 1,
    int limit = 20,
    String? categoryId,
  }) async {
    // Server returns {data: [...], pagination: {...}}
    final response = await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.get(
        '/api/checklist-templates',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (categoryId != null) 'category_id': categoryId,
        },
      ),
      endpoint: '/api/checklist-templates',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
    if (!response.containsKey('data') || !response.containsKey('pagination')) {
      throw FormatException(
        'Unexpected response shape: expected data and pagination keys',
      );
    }
    final templatesData = response['data'];
    final paginationData = response['pagination'] as Map? ?? {};
    return ChecklistTemplatesPage(
      entries: (templatesData as List)
          .map(
            (e) =>
                ChecklistTemplate.fromJson((e as Map).cast<String, dynamic>()),
          )
          .toList(),
      total: paginationData['total'] as int? ?? 0,
      page: paginationData['page'] as int? ?? page,
      limit: paginationData['limit'] as int? ?? limit,
    );
  }

  // â”€â”€â”€ Priority Config â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  /// Fetches priority config versions.
  Future<PriorityConfigPage> getPriorityConfigs({
    int page = 1,
    int limit = 20,
  }) async {
    return await _execute<PriorityConfigPage>(
      dioCall: () => _dio.get(
        '/api/priority-config',
        queryParameters: {'page': page, 'limit': limit},
      ),
      endpoint: '/api/priority-config',
      parse: (data) =>
          PriorityConfigPage.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  /// Activates a priority config version.
  Future<PriorityActivateResult> activatePriorityConfig(String id) async {
    return await _execute<PriorityActivateResult>(
      dioCall: () => _dio.post('/api/priority-config/$id/activate'),
      endpoint: '/api/priority-config/$id/activate',
      parse: (data) => PriorityActivateResult.fromJson(
        (data as Map).cast<String, dynamic>(),
      ),
    );
  }

  // â”€â”€â”€ Auditor â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  /// Fetches auditor audit search results.
  Future<AuditPage> getAuditorAuditSearch({
    String? actorId,
    String? action,
    String? objectType,
    String? objectId,
    String? from,
    String? to,
    int page = 1,
    int limit = 50,
  }) async {
    // Server returns {entries, total, page, limit} directly
    final response = await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.get(
        '/api/auditor/audit-search',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (actorId != null) 'actor_id': actorId,
          if (action != null) 'action': action,
          if (objectType != null) 'object_type': objectType,
          if (objectId != null) 'object_id': objectId,
          if (from != null) 'from': from,
          if (to != null) 'to': to,
        },
      ),
      endpoint: '/api/auditor/audit-search',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
    if (!response.containsKey('entries')) {
      throw FormatException('Unexpected response shape: expected entries key');
    }
    final entriesData = response['entries'];
    return AuditPage(
      entries: (entriesData as List)
          .map((e) => AuditEntry.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
      total: response['total'] as int? ?? 0,
      page: response['page'] as int? ?? page,
      limit: response['limit'] as int? ?? limit,
    );
  }

  /// Fetches auditor system logs.
  /// Backend: GET /api/auditor/system-logs → {entries, total, page, limit} (flat, no data envelope)
  Future<AuditPage> getAuditorSystemLogs({
    String? level,
    String? from,
    String? to,
    int page = 1,
    int limit = 50,
  }) async {
    final response = await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.get(
        '/api/auditor/system-logs',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (level != null) 'level': level,
          if (from != null) 'from': from,
          if (to != null) 'to': to,
        },
      ),
      endpoint: '/api/auditor/system-logs',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
    // Backend returns {entries, total, page, limit} directly — no 'data' envelope
    if (!response.containsKey('entries')) {
      throw FormatException('Unexpected response shape: expected entries key');
    }
    final entriesData = response['entries'];
    return AuditPage(
      entries: (entriesData as List)
          .map((e) => AuditEntry.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
      total: response['total'] as int? ?? 0,
      page: response['page'] as int? ?? page,
      limit: response['limit'] as int? ?? limit,
    );
  }

  /// Fetches auditor statistics.
  /// Backend: GET /api/auditor/stats → {counts: {total, last_24h, last_7d, last_30d}, top_actors, failed_attempts, recent_suspicious}
  Future<AuditorStats> getAuditorStats() async {
    return await _execute<AuditorStats>(
      dioCall: () => _dio.get('/api/auditor/stats'),
      endpoint: '/api/auditor/stats',
      parse: (data) =>
          AuditorStats.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  /// Exports auditor audit log as CSV.
  Future<String> getAuditorAuditExport({
    String? actorId,
    String? action,
    String? objectType,
    String? objectId,
    String? from,
    String? to,
    String format = 'csv',
  }) async {
    final res = await _dio.get(
      '/api/auditor/audit-export',
      queryParameters: {
        if (actorId != null) 'actor_id': actorId,
        if (action != null) 'action': action,
        if (objectType != null) 'object_type': objectType,
        if (objectId != null) 'object_id': objectId,
        if (from != null) 'from': from,
        if (to != null) 'to': to,
        'format': format,
      },
    );
    return res.data.toString();
  }

  // â”€â”€â”€ Me/Data â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  /// Fetches the current user's data.
  Future<UserResponse> getMeData() async {
    return await _execute<UserResponse>(
      dioCall: () => _dio.get('/api/me/data'),
      endpoint: '/api/me/data',
      parse: (data) =>
          UserResponse.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  // â”€â”€â”€ Warga Profile â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  /// Fetches warga profile.
  Future<WargaProfile> getWargaProfile() async {
    return await _execute<WargaProfile>(
      dioCall: () => _dio.get('/api/warga/profile'),
      endpoint: '/api/warga/profile',
      parse: (data) =>
          WargaProfile.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  // â”€â”€â”€ Wilayah Boundary â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  /// Fetches the boundary geometry for a wilayah as GeoJSON.
  Future<GeoJSONFeatureCollection> getWilayahBoundary(String id) async {
    return await _execute<GeoJSONFeatureCollection>(
      dioCall: () => _dio.get('/api/wilayah/$id/boundary'),
      endpoint: '/api/wilayah/$id/boundary',
      parse: (data) => GeoJSONFeatureCollection.fromJson(
        (data as Map).cast<String, dynamic>(),
      ),
    );
  }

  // â”€â”€â”€ Admin: Generate RT-RW Token â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  /// Generates an RT/RW verification token for a report.
  Future<GenerateRtRwTokenResult> getAdminGenerateRtRwToken({
    required String reportId,
    required String rtRwUserId,
  }) async {
    return await _execute<GenerateRtRwTokenResult>(
      dioCall: () => _dio.post(
        '/api/admin/generate-rt-rw-token',
        data: {'report_id': reportId, 'rt_rw_user_id': rtRwUserId},
      ),
      endpoint: '/api/admin/generate-rt-rw-token',
      parse: (data) => GenerateRtRwTokenResult.fromJson(
        (data as Map).cast<String, dynamic>(),
      ),
    );
  }

  // â”€â”€â”€ Admin: Failed Assessments â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  /// Fetches admin failed assessments.
  Future<FailedAssessmentsPage> getAdminFailedAssessments({
    int page = 1,
    int limit = 50,
    String? reportId,
    String? toolName,
    bool? permanentDlq,
  }) async {
    // Server returns {items, total, page, limit} directly
    final response = await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.get(
        '/api/admin/failed-assessments',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (reportId != null) 'report_id': reportId,
          if (toolName != null) 'tool_name': toolName,
          if (permanentDlq != null) 'permanent_dlq': permanentDlq.toString(),
        },
      ),
      endpoint: '/api/admin/failed-assessments',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
    if (!response.containsKey('items')) {
      throw FormatException('Unexpected response shape: expected items key');
    }
    final itemsData = response['items'];
    return FailedAssessmentsPage(
      entries: (itemsData as List)
          .map((e) => (e as Map).cast<String, dynamic>())
          .toList(),
      total: response['total'] as int? ?? 0,
      page: response['page'] as int? ?? page,
      limit: response['limit'] as int? ?? limit,
    );
  }

  /// Retries a batch of failed assessments.
  Future<RetryBatchResult> retryAdminFailedAssessmentsBatch({
    required List<String> ids,
  }) async {
    return await _execute<RetryBatchResult>(
      dioCall: () => _dio.post(
        '/api/admin/failed-assessments/retry-batch',
        data: {'ids': ids},
      ),
      endpoint: '/api/admin/failed-assessments/retry-batch',
      parse: (data) =>
          RetryBatchResult.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  // â”€â”€â”€ Health â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  /// Checks API health status.
  Future<HealthResult> getHealth() async {
    return await _execute<HealthResult>(
      dioCall: () => _dio.get('/api/health'),
      endpoint: '/api/health',
      parse: (data) =>
          HealthResult.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  // â”€â”€â”€ Client Errors â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  /// Reports a client error to the server.
  Future<ClientErrorResult> postClientError({
    required String error,
    String? stackTrace,
    String? userId,
  }) async {
    return await _execute<ClientErrorResult>(
      dioCall: () => _dio.post(
        '/api/client-errors',
        data: {
          'error': error,
          if (stackTrace != null) 'stack_trace': stackTrace,
          if (userId != null) 'user_id': userId,
        },
      ),
      endpoint: '/api/client-errors',
      parse: (data) =>
          ClientErrorResult.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  // â”€â”€â”€ Public Endpoints (orphan-safe - no callers in flutter-usage-map) â”€â”€â”€â”€

  /// Fetches public reports as GeoJSON.
  Future<GeoJSONFeatureCollection> getPublicGeojson({
    String? status,
    String? categoryId,
    String? bbox,
    String? month,
  }) async {
    // Server returns GeoJSON directly - no 'data' envelope
    return await _execute<GeoJSONFeatureCollection>(
      dioCall: () => _dio.get(
        '/api/public/geojson',
        queryParameters: {
          if (status != null) 'status': status,
          if (categoryId != null) 'category_id': categoryId,
          if (bbox != null) 'bbox': bbox,
          if (month != null) 'month': month,
        },
      ),
      endpoint: '/api/public/geojson',
      parse: (data) => GeoJSONFeatureCollection.fromJson(
        (data as Map).cast<String, dynamic>(),
      ),
    );
  }

  /// Fetches public reports.
  Future<PublicReportsPage> getPublicReports({
    String? status,
    String? categoryId,
    String? bbox,
    String? month,
    int page = 1,
    int limit = 20,
  }) async {
    // Server returns {reports, total, page, limit} - no 'data' envelope
    final response = await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.get(
        '/api/public/reports',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (status != null) 'status': status,
          if (categoryId != null) 'category_id': categoryId,
          if (bbox != null) 'bbox': bbox,
          if (month != null) 'month': month,
        },
      ),
      endpoint: '/api/public/reports',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
    if (!response.containsKey('reports')) {
      throw FormatException('Unexpected response shape: expected reports key');
    }
    final reportsData = response['reports'];
    final total = response['total'] as int? ?? 0;
    final respPage = response['page'] as int? ?? page;
    final respLimit = response['limit'] as int? ?? limit;
    return PublicReportsPage(
      items: (reportsData as List)
          .map(
            (e) =>
                PublicReportItem.fromJson((e as Map).cast<String, dynamic>()),
          )
          .toList(),
      total: total,
      page: respPage,
      limit: respLimit,
    );
  }

  /// Submits an anonymous warga report.
  /// Backend: POST /api/public/anonymous-reports → {id, idempotency_key, status:"pending"}
  /// Unauthenticated public call — uses _publicDio.
  Future<AnonymousReportResult> submitAnonymousReport({
    required String idempotencyKey,
    required String deviceId,
    required String categoryId,
    required String description,
    required double lat,
    required double lng,
    String? title,
    List<String>? photos,
    String? captchaToken,
    int? populationAffected,
    double? vulnerabilityIndex,
  }) async {
    await _checkConnectivity();
    try {
      // Photos are already-public R2 URLs, so the body is always JSON.
      // (The backend anonymous-reports endpoint reads JSON via parseJson,
      // not multipart/form-data.)
      final Map<String, dynamic> body = {
        'idempotency_key': idempotencyKey,
        'device_id': deviceId,
        'category_id': categoryId,
        'description': description,
        'lat': lat,
        'lng': lng,
        if (title != null) 'title': title,
        if (captchaToken != null) 'captcha_token': captchaToken,
        if (photos != null && photos.isNotEmpty) 'photos': photos,
        if (populationAffected != null)
          'population_affected': populationAffected,
        if (vulnerabilityIndex != null)
          'vulnerability_index': vulnerabilityIndex,
      };

      final res = await _publicDio.post(
        '/api/public/anonymous-reports',
        data: body,
      );
      return AnonymousReportResult.fromJson(res.data!.cast<String, dynamic>());
    } on DioException catch (e) {
      final userMessage = extractErrorMessage(e);
      throw ApiException(
        statusCode: e.response?.statusCode ?? 0,
        body: e.response?.data?.toString(),
        endpoint: '/api/public/anonymous-reports',
        userMessage: '$userMessage [/api/public/anonymous-reports]',
      );
    }
  }

  /// Fetches public categories.
  /// Backend: GET /api/public/categories → {categories: [...], data: [...]}
  Future<List<Category>> getPublicCategories() async {
    final response = await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.get('/api/public/categories'),
      endpoint: '/api/public/categories',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
    // Backend returns both 'categories' and 'data' with the same list
    final categoriesData = _expectListKey(response, 'categories');
    return categoriesData
        .map((e) => Category.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }

  /// Fetches a single public report by ID.
  /// Backend: GET /api/public/reports/:id → {id, category_id, status, created_at, last_updated, public_progress, moderated_photo_url, share_token, title, description, severity, generalized_location}
  Future<Map<String, dynamic>> getPublicReport(String id) async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.get('/api/public/reports/$id'),
      endpoint: '/api/public/reports/$id',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  /// Fetches public statistics.
  /// Backend: GET /api/public/stats → {total, by_status, by_category, recent_reports_7d, resolution_rate_7d}
  Future<PublicStats> getPublicStats() async {
    return await _execute<PublicStats>(
      dioCall: () => _dio.get('/api/public/stats'),
      endpoint: '/api/public/stats',
      parse: (data) =>
          PublicStats.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  // â”€â”€â”€ Audit (non-Auditor role) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  /// Fetches audit log entries with pagination and filters.
  Future<AuditPage> getAuditSearch({
    String? actorId,
    String? action,
    String? reportId,
    String? from,
    String? to,
    int page = 1,
    int limit = 50,
  }) async {
    final raw = await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.get(
        '/api/audit/search',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (actorId != null) 'actor_id': actorId,
          if (action != null) 'action': action,
          if (reportId != null) 'report_id': reportId,
          if (from != null) 'from': from,
          if (to != null) 'to': to,
        },
      ),
      endpoint: '/api/audit/search',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
    final bool hasDataEnvelope = raw.containsKey('data') && raw['data'] is Map;
    final Map<String, dynamic> inner = hasDataEnvelope
        ? (raw['data'] as Map).cast<String, dynamic>()
        : raw;
    final entriesData = inner['entries'];
    final paginationData = inner['pagination'] ?? <String, dynamic>{};
    return AuditPage(
      entries: (entriesData as List)
          .map((e) => AuditEntry.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
      total: paginationData['total'] as int? ?? 0,
      page: paginationData['page'] as int? ?? page,
      limit: paginationData['limit'] as int? ?? limit,
    );
  }

  /// Exports audit log entries as CSV.
  Future<String> getAuditExport({
    String? actorId,
    String? action,
    String? reportId,
    String? from,
    String? to,
    String format = 'csv',
  }) async {
    final res = await _dio.get(
      '/api/audit/export',
      queryParameters: {
        if (actorId != null) 'actor_id': actorId,
        if (action != null) 'action': action,
        if (reportId != null) 'report_id': reportId,
        if (from != null) 'from': from,
        if (to != null) 'to': to,
        'format': format,
      },
    );
    return res.data.toString();
  }

  // â”€â”€â”€ Export CSV â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  /// Exports reports as CSV file content.
  Future<String> getExportCsv({String? status, String? categoryId}) async {
    final res = await _dio.get(
      '/api/export/csv',
      queryParameters: {
        if (status != null) 'status': status,
        if (categoryId != null) 'category_id': categoryId,
      },
    );
    return res.data.toString();
  }

  // â”€â”€â”€ Reports CRUD (orphan-safe) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  /// Fetches a single report by ID.
  Future<Report> getReportById(String id) async {
    return await _execute<Report>(
      dioCall: () => _dio.get('/api/reports/$id'),
      endpoint: '/api/reports/$id',
      parse: (data) => Report.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  /// Updates a report via PATCH.
  Future<Report> updateReport(String id, Map<String, dynamic> data) async {
    return await _execute<Report>(
      dioCall: () => _dio.patch('/api/reports/$id', data: data),
      endpoint: '/api/reports/$id',
      parse: (data) => Report.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  /// Deletes a report.
  Future<void> deleteReport(String id) async {
    await _execute<void>(
      dioCall: () => _dio.delete('/api/reports/$id'),
      endpoint: '/api/reports/$id',
      parse: (_) {},
    );
  }

  /// Creates a new report.
  /// Wire returns: {id, duplicate} directly (flat, no Report envelope).
  /// Server bug: should return full Report with status per flow spec.
  Future<CreateReportResult> createReport({
    required String idempotencyKey,
    required String categoryId,
    required String description,
    required double lat,
    required double lng,
    String? deviceId,
    String? title,
    List<String>? photoPaths,
  }) async {
    // Upload photos first via presigned URL if provided
    List<String>? photoUrls;
    if (photoPaths != null && photoPaths.isNotEmpty) {
      photoUrls = [];
      for (final path in photoPaths) {
        final publicUrl = await uploadReportPhotoAnon(
          filePath: path,
          idempotencyKey: '${idempotencyKey}_photo_${photoUrls.length}',
        );
        photoUrls.add(publicUrl.publicUrl ?? '');
      }
    }

    return await _execute<CreateReportResult>(
      dioCall: () => _dio.post(
        '/api/reports',
        data: {
          'idempotency_key': idempotencyKey,
          'category_id': categoryId,
          'description': description,
          if (title != null) 'title': title,
          'lat': lat,
          'lng': lng,
          if (deviceId != null) 'device_id': deviceId,
          if (photoUrls != null && photoUrls.isNotEmpty)
            'photo_urls': photoUrls,
        },
      ),
      endpoint: '/api/reports',
      parse: (data) =>
          CreateReportResult.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  // â”€â”€â”€ Cases Actions (orphan methods kept for future use) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  /// Accepts a case.
  /// Backend: POST /api/cases/:id/accept → {id, status, severity, assigned_to, assessments}
  Future<CaseAcceptResult> acceptCase(
    String caseId, {
    String? reason,
    String? assignedUnitId,
    String? deadline,
    int? priority,
  }) async {
    return await _execute<CaseAcceptResult>(
      dioCall: () => _dio.post(
        '/api/cases/$caseId/accept',
        data: {
          if (reason != null) 'reason': reason,
          if (assignedUnitId != null) 'assigned_unit_id': assignedUnitId,
          if (deadline != null) 'deadline': deadline,
          if (priority != null) 'priority': priority,
        },
        options: Options(contentType: 'application/json'),
      ),
      endpoint: '/api/cases/$caseId/accept',
      parse: (data) =>
          CaseAcceptResult.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  /// Rejects a case.
  /// Backend: POST /api/cases/:id/reject → {status:"rejected", reason}
  Future<CaseRejectResult> rejectCase(
    String caseId, {
    required String reason,
  }) async {
    return await _execute<CaseRejectResult>(
      dioCall: () =>
          _dio.post('/api/cases/$caseId/reject', data: {'reason': reason}),
      endpoint: '/api/cases/$caseId/reject',
      parse: (data) =>
          CaseRejectResult.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  /// Combines/merges cases.
  /// Backend: POST /api/cases/:id/combine → {status:"merged", target_case_id}
  Future<CaseCombineResult> combineCase(
    String caseId, {
    required String targetCaseId,
    String? reason,
  }) async {
    return await _execute<CaseCombineResult>(
      dioCall: () => _dio.post(
        '/api/cases/$caseId/combine',
        data: {
          'target_case_id': targetCaseId,
          if (reason != null) 'reason': reason,
        },
      ),
      endpoint: '/api/cases/$caseId/combine',
      parse: (data) =>
          CaseCombineResult.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  /// Separates a case into new cases.
  /// Backend: POST /api/cases/:id/separate → {status:"separated", new_case_id}
  Future<CaseSeparateResult> separateCase(
    String caseId, {
    required String newCaseDescription,
    String? reason,
  }) async {
    return await _execute<CaseSeparateResult>(
      dioCall: () => _dio.post(
        '/api/cases/$caseId/separate',
        data: {
          'new_case_description': newCaseDescription,
          if (reason != null) 'reason': reason,
        },
      ),
      endpoint: '/api/cases/$caseId/separate',
      parse: (data) =>
          CaseSeparateResult.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  /// Verifies completion of a case.
  /// Backend: POST /api/cases/:id/verify-completion → {decision, report_status, reason, task_id, report}
  /// Requires VERIFIKATOR or ADMIN role.
  Future<CaseVerifyCompletionResult> verifyCaseCompletion(
    String caseId, {
    required String activeRole,
    required String decision,
    required String reason,
    String? completionNotes,
  }) async {
    if (activeRole != 'VERIFIKATOR' && activeRole != 'ADMIN') {
      throw ApiException(
        statusCode: 403,
        endpoint: '/api/cases/$caseId/verify-completion',
        userMessage: 'Endpoint requires VERIFIKATOR or ADMIN role',
      );
    }
    return await _execute<CaseVerifyCompletionResult>(
      dioCall: () => _dio.post(
        '/api/cases/$caseId/verify-completion',
        data: {
          'decision': decision,
          'reason': reason,
          if (completionNotes != null) 'completion_notes': completionNotes,
        },
      ),
      endpoint: '/api/cases/$caseId/verify-completion',
      parse: (data) => CaseVerifyCompletionResult.fromJson(
        (data as Map).cast<String, dynamic>(),
      ),
    );
  }

  /// Reviews sanggahan on a case.
  /// Backend: POST /api/cases/:id/review-sanggahan → {decision, report_status, reason}
  /// Requires VERIFIKATOR or ADMIN role.
  Future<CaseReviewSanggahanResult> reviewSanggahanCase(
    String caseId, {
    required String activeRole,
    required String decision,
    required String reason,
  }) async {
    if (activeRole != 'VERIFIKATOR' && activeRole != 'ADMIN') {
      throw ApiException(
        statusCode: 403,
        endpoint: '/api/cases/$caseId/review-sanggahan',
        userMessage: 'Endpoint requires VERIFIKATOR or ADMIN role',
      );
    }
    return await _execute<CaseReviewSanggahanResult>(
      dioCall: () => _dio.post(
        '/api/cases/$caseId/review-sanggahan',
        data: {'decision': decision, 'reason': reason},
      ),
      endpoint: '/api/cases/$caseId/review-sanggahan',
      parse: (data) => CaseReviewSanggahanResult.fromJson(
        (data as Map).cast<String, dynamic>(),
      ),
    );
  }

  // â”€â”€â”€ Reports Actions (orphan methods kept for future use) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  /// Closes a report.
  /// Backend: POST /api/reports/:id/close → {status:"closed", ...after}
  /// Requires VERIFIKATOR or ADMIN role.
  Future<ReportStatusResult> closeReport(
    String id, {
    required String activeRole,
  }) async {
    if (activeRole != 'VERIFIKATOR' && activeRole != 'ADMIN') {
      throw ApiException(
        statusCode: 403,
        endpoint: '/api/reports/$id/close',
        userMessage: 'Endpoint requires VERIFIKATOR or ADMIN role',
      );
    }
    return await _execute<ReportStatusResult>(
      dioCall: () => _dio.post('/api/reports/$id/close'),
      endpoint: '/api/reports/$id/close',
      parse: (data) =>
          ReportStatusResult.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  /// Resolves a report.
  /// Backend: POST /api/reports/:id/resolve → {status:"resolved", ...after}
  Future<ReportStatusResult> resolveReport(String id) async {
    return await _execute<ReportStatusResult>(
      dioCall: () => _dio.post('/api/reports/$id/resolve'),
      endpoint: '/api/reports/$id/resolve',
      parse: (data) =>
          ReportStatusResult.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  /// Escalates a report.
  Future<Report> escalateReport(String id) async {
    return await _execute<Report>(
      dioCall: () => _dio.post('/api/reports/$id/escalate'),
      endpoint: '/api/reports/$id/escalate',
      parse: (data) => Report.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  /// Assigns a report to a unit.
  Future<Report> assignReport(
    String id, {
    required String unitId,
    String? deadline,
  }) async {
    return await _execute<Report>(
      dioCall: () => _dio.post(
        '/api/reports/$id/assign',
        data: {
          'assigned_unit_id': unitId,
          if (deadline != null) 'deadline': deadline,
        },
      ),
      endpoint: '/api/reports/$id/assign',
      parse: (data) => Report.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  /// Sets priority on a report.
  /// Backend: POST /api/reports/:id/priority → {status: "priority_updated", new_score, priority_score}
  /// reason is optional per backend schema.
  Future<PriorityOverrideResult> setReportPriority({
    required String id,
    required int score,
    String? reason,
    Map<String, dynamic>? factorBreakdown,
  }) async {
    return await _execute<PriorityOverrideResult>(
      dioCall: () => _dio.post(
        '/api/reports/$id/priority',
        data: {
          'score': score,
          if (reason != null) 'reason': reason,
          if (factorBreakdown != null) 'factor_breakdown': factorBreakdown,
        },
      ),
      endpoint: '/api/reports/$id/priority',
      parse: (data) => PriorityOverrideResult.fromJson(
        (data as Map).cast<String, dynamic>(),
      ),
    );
  }

  /// Sets SLA on a report.
  Future<Report> setReportSla({
    required String id,
    required String newDeadline,
    required String reason,
  }) async {
    return await _execute<Report>(
      dioCall: () => _dio.post(
        '/api/reports/$id/sla',
        data: {'new_deadline': newDeadline, 'reason': reason},
      ),
      endpoint: '/api/reports/$id/sla',
      parse: (data) => Report.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  /// Merges reports.
  Future<Report> mergeReports({
    required String id,
    required List<String> targetReportIds,
    String? reason,
  }) async {
    return await _execute<Report>(
      dioCall: () => _dio.post(
        '/api/reports/$id/merge',
        data: {
          'target_case_ids': targetReportIds,
          if (reason != null) 'reason': reason,
        },
      ),
      endpoint: '/api/reports/$id/merge',
      parse: (data) => Report.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  /// Separates reports.
  Future<Report> separateReports({
    required String id,
    required List<String> reportIdsToSeparate,
    String? reason,
  }) async {
    return await _execute<Report>(
      dioCall: () => _dio.post(
        '/api/reports/$id/separate',
        data: {
          'report_ids_to_separate': reportIdsToSeparate,
          if (reason != null) 'reason': reason,
        },
      ),
      endpoint: '/api/reports/$id/separate',
      parse: (data) => Report.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  /// Submits evidence for a report.
  /// Backend: POST /api/reports/:id/evidence → {success: true, evidence_id}
  Future<List<EvidenceResult>> submitReportEvidence(
    String id, {
    required String description,
    required List<String> photoPaths,
  }) async {
    final results = <EvidenceResult>[];
    for (final photoPath in photoPaths) {
      final file = File(photoPath);
      final bytes = await file.readAsBytes();
      final name = photoPath.split('/').last;
      final formData = FormData.fromMap({
        'description': description,
        'photo': MultipartFile.fromBytes(bytes, filename: name),
      });
      final res = await _dio.post('/api/reports/$id/evidence', data: formData);
      final data = (res.data as Map).cast<String, dynamic>();
      results.add(
        EvidenceResult(
          evidenceId: data['evidence_id']?.toString(),
          photoUrls: null,
        ),
      );
    }
    return results;
  }

  // â”€â”€â”€ Tasks Actions (orphan methods kept for future use) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  /// Accepts a task.
  Future<TaskActionResult> acceptTask(String taskId) async {
    return await _execute<TaskActionResult>(
      dioCall: () => _dio.post('/api/tasks/$taskId/accept'),
      endpoint: '/api/tasks/$taskId/accept',
      parse: (data) =>
          TaskActionResult.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  /// Starts a task.
  Future<TaskActionResult> startTask(String taskId) async {
    return await _execute<TaskActionResult>(
      dioCall: () => _dio.post('/api/tasks/$taskId/start'),
      endpoint: '/api/tasks/$taskId/start',
      parse: (data) =>
          TaskActionResult.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  /// Rejects a task.
  Future<TaskActionResult> rejectTask(String taskId, String reason) async {
    return await _execute<TaskActionResult>(
      dioCall: () =>
          _dio.post('/api/tasks/$taskId/reject', data: {'reason': reason}),
      endpoint: '/api/tasks/$taskId/reject',
      parse: (data) =>
          TaskActionResult.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  /// Requests clarification on a task.
  Future<ClarificationResult> requestClarification(
    String taskId, {
    required String question,
  }) async {
    return await _execute<ClarificationResult>(
      dioCall: () => _dio.post(
        '/api/tasks/$taskId/clarification',
        data: {'message': question},
      ),
      endpoint: '/api/tasks/$taskId/clarification',
      parse: (data) =>
          ClarificationResult.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  /// Submits evidence for a task.
  Future<EvidenceResult> submitTaskEvidence(
    String taskId,
    List<String> photoPaths, {
    String? notes,
  }) async {
    final mapData = <String, dynamic>{if (notes != null) 'notes': notes};
    for (var i = 0; i < photoPaths.length; i++) {
      final file = File(photoPaths[i]);
      final bytes = await file.readAsBytes();
      final name = photoPaths[i].split('/').last;
      mapData['photos[$i]'] = MultipartFile.fromBytes(bytes, filename: name);
    }
    final formData = FormData.fromMap(mapData);
    final result = await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.post('/api/tasks/$taskId/evidence', data: formData),
      endpoint: '/api/tasks/$taskId/evidence',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
    return EvidenceResult.fromJson(result);
  }

  /// Completes a task.
  Future<CompleteTaskResult> completeTask(
    String taskId, {
    required String summary,
    required List<String> photoPaths,
  }) async {
    final mapData = <String, dynamic>{'summary': summary};
    for (var i = 0; i < photoPaths.length; i++) {
      final file = File(photoPaths[i]);
      final bytes = await file.readAsBytes();
      final name = photoPaths[i].split('/').last;
      // Backend expects 'photo' for single file, 'photos[0..3]' for indexed
      mapData[i == 0 ? 'photo' : 'photos[$i]'] = MultipartFile.fromBytes(
        bytes,
        filename: name,
      );
    }
    final formData = FormData.fromMap(mapData);
    final result = await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.post('/api/tasks/$taskId/complete', data: formData),
      endpoint: '/api/tasks/$taskId/complete',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
    return CompleteTaskResult.fromJson(result);
  }

  /// Gets checklist template for a task.
  Future<ChecklistTemplate> getTaskChecklistTemplate(String taskId) async {
    return await _execute<ChecklistTemplate>(
      dioCall: () => _dio.get('/api/tasks/$taskId/checklist-template'),
      endpoint: '/api/tasks/$taskId/checklist-template',
      parse: (data) =>
          ChecklistTemplate.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  /// Gets task detail.
  Future<TaskDetail> getTaskDetail(String taskId) async {
    return await _execute<TaskDetail>(
      dioCall: () => _dio.get('/api/tasks/$taskId'),
      endpoint: '/api/tasks/$taskId',
      parse: (data) =>
          TaskDetail.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  // â”€â”€â”€ Priority Config Actions â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  /// Creates or updates priority config.
  Future<PriorityConfig> savePriorityConfig({
    required Map<String, dynamic> weights,
  }) async {
    return await _execute<PriorityConfig>(
      dioCall: () =>
          _dio.post('/api/priority-config', data: {'weights': weights}),
      endpoint: '/api/priority-config',
      parse: (data) =>
          PriorityConfig.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  // â”€â”€â”€ SLA Actions â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  /// Creates SLA config.
  Future<SlaConfig> createSla(SlaConfig config) async {
    return await _execute<SlaConfig>(
      dioCall: () => _dio.post('/api/sla', data: config.toJson()),
      endpoint: '/api/sla',
      parse: (data) =>
          SlaConfig.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  /// Updates SLA config.
  Future<SlaConfig> updateSla(String id, SlaConfig config) async {
    final body = config.toJson()..removeWhere((_, v) => v == null);
    return await _execute<SlaConfig>(
      dioCall: () => _dio.patch('/api/sla/$id', data: body),
      endpoint: '/api/sla/$id',
      parse: (data) =>
          SlaConfig.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  /// Deletes SLA config.
  Future<void> deleteSla(String id) async {
    await _execute<void>(
      dioCall: () => _dio.delete('/api/sla/$id'),
      endpoint: '/api/sla/$id',
      parse: (_) {},
    );
  }

  // â”€â”€â”€ User Actions â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  /// Creates a user.
  Future<UserResponse> createUser({
    required String email,
    required String password,
    required String name,
    required String role,
    String? wilayahId,
  }) async {
    return await _execute<UserResponse>(
      dioCall: () => _dio.post(
        '/api/users',
        data: {
          'email': email,
          'password': password,
          'name': name,
          'role': role,
          if (wilayahId != null) 'wilayah_id': wilayahId,
        },
      ),
      endpoint: '/api/users',
      parse: (data) =>
          UserResponse.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  // â”€â”€â”€ RT-RW GET â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  /// Gets RT-RW verification info.
  /// Server expects: GET /api/rt-rw/verify?token=...&case_id=...
  Future<RtRwVerifyInfo> getRtRwVerify({
    required String token,
    required String caseId,
  }) async {
    return await _execute<RtRwVerifyInfo>(
      dioCall: () => _dio.get(
        '/api/rt-rw/verify',
        queryParameters: {'token': token, 'case_id': caseId},
      ),
      endpoint: '/api/rt-rw/verify',
      parse: (data) =>
          RtRwVerifyInfo.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  // â”€â”€â”€ Reports Heatmap â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  /// Gets reports heatmap data.
  Future<List<Map<String, dynamic>>> getReportsHeatmap({
    String? categoryId,
    String? status,
  }) async {
    final data = await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.get(
        '/api/reports/heatmap',
        queryParameters: {
          if (categoryId != null) 'category_id': categoryId,
          if (status != null) 'status': status,
        },
      ),
      endpoint: '/api/reports/heatmap',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
    // Backend returns { points: [...] } directly (no data envelope)
    final pointsData = _expectListKey(data, 'points');
    return pointsData.map((e) => (e as Map<String, dynamic>)).toList();
  }

  // â”€â”€â”€ Reports Stats â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  /// Gets reports statistics.
  Future<StatsResponse> getReportsStats() async {
    return await _execute<StatsResponse>(
      dioCall: () => _dio.get('/api/reports/stats'),
      endpoint: '/api/reports/stats',
      parse: (data) =>
          StatsResponse.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  // â”€â”€â”€ Photo Rollback â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  /// Rolls back an uploaded photo.
  Future<void> rollbackPhoto(String photoUrl) async {
    await _execute<void>(
      dioCall: () => _dio.post(
        '/api/reports/photos/rollback',
        data: {'photo_url': photoUrl},
      ),
      endpoint: '/api/reports/photos/rollback',
      parse: (_) {},
    );
  }

  // â”€â”€â”€ Public Cases â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  /// Gets a public case by ID.
  Future<Report> getPublicCase(String id) async {
    return await _execute<Report>(
      dioCall: () => _dio.get('/api/public/cases/$id'),
      endpoint: '/api/public/cases/$id',
      parse: (data) => Report.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  // â”€â”€â”€ Public Reports Cluster â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  /// Gets public reports cluster for map.
  /// Backend: GET /api/public/reports/cluster?bbox=...&month=...&zoom=...
  /// Server returns {clusters: [{lng, lat, count, dominant_status, ...}]}
  /// We convert to GeoJSON FeatureCollection for compatibility.
  Future<GeoJSONFeatureCollection> getPublicReportsCluster({
    String? bbox,
    String? month,
    int? zoom,
  }) async {
    return await _execute<GeoJSONFeatureCollection>(
      dioCall: () => _dio.get(
        '/api/public/reports/cluster',
        queryParameters: {
          if (bbox != null) 'bbox': bbox,
          if (month != null) 'month': month,
          if (zoom != null) 'zoom': zoom.toString(),
        },
      ),
      endpoint: '/api/public/reports/cluster',
      parse: (data) {
        final map = (data as Map).cast<String, dynamic>();
        final clusters = (map['clusters'] as List?) ?? [];
        return GeoJSONFeatureCollection(
          type: 'FeatureCollection',
          features: clusters.map((c) {
            final item = (c as Map).cast<String, dynamic>();
            // Convert flat cluster item to GeoJSON Point Feature
            return GeoJSONFeature(
              type: 'Feature',
              geometry: {
                'type': 'Point',
                'coordinates': [item['lng'] ?? 0, item['lat'] ?? 0],
              },
              properties: {
                'count': item['count'] ?? 0,
                'dominant_status': item['dominant_status'] ?? '',
                'dominant_category': item['dominant_category'] ?? '',
                'color': item['color'] ?? '#8a9099',
              },
            );
          }).toList(),
        );
      },
    );
  }

  // â”€â”€â”€ Public Map â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  /// Gets public map data.
  Future<GeoJSONFeatureCollection> getPublicMap({
    String? status,
    String? categoryId,
    String? bbox,
  }) async {
    return await _execute<GeoJSONFeatureCollection>(
      dioCall: () => _dio.get(
        '/api/public/map',
        queryParameters: {
          if (status != null) 'status': status,
          if (categoryId != null) 'category_id': categoryId,
          if (bbox != null) 'bbox': bbox,
        },
      ),
      endpoint: '/api/public/map',
      parse: (data) => GeoJSONFeatureCollection.fromJson(
        (data as Map).cast<String, dynamic>(),
      ),
    );
  }

  // â”€â”€â”€ Auth Me â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  /// Gets current user info (auth me).
  /// Wire returns: {id, email, role} directly (flat, no envelope).
  Future<User> getAuthMe() async {
    return await _execute<User>(
      dioCall: () => _dio.get('/api/auth/me'),
      endpoint: '/api/auth/me',
      parse: (data) => User.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  // â”€â”€â”€ Auth Refresh â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  /// Refreshes auth token.
  Future<LoginResponse> refreshAuth(String refreshToken) async {
    return await _execute<LoginResponse>(
      dioCall: () =>
          _dio.post('/api/auth/refresh', data: {'refresh_token': refreshToken}),
      endpoint: '/api/auth/refresh',
      parse: (data) =>
          LoginResponse.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  // â”€â”€â”€ Auth Register â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  /// Registers a new user.
  Future<LoginResponse> register({
    required String email,
    required String password,
    required String name,
  }) async {
    return await _execute<LoginResponse>(
      dioCall: () => _dio.post(
        '/api/auth/register',
        data: {'email': email, 'password': password, 'name': name},
      ),
      endpoint: '/api/auth/register',
      parse: (data) =>
          LoginResponse.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  // â”€â”€â”€ Auth Register Verifikator â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  /// Registers a verifikator.
  Future<LoginResponse> registerVerifikator({
    required String email,
    required String password,
    required String name,
    required String wilayahId,
  }) async {
    return await _execute<LoginResponse>(
      dioCall: () => _dio.post(
        '/api/auth/register-verifikator',
        data: {
          'email': email,
          'password': password,
          'name': name,
          'wilayah_id': wilayahId,
        },
      ),
      endpoint: '/api/auth/register-verifikator',
      parse: (data) =>
          LoginResponse.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  // â”€â”€â”€ Wilayah Detail â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  /// Gets wilayah detail by ID.
  Future<Wilayah> getWilayah(String id) async {
    return await _execute<Wilayah>(
      dioCall: () => _dio.get('/api/wilayah/$id'),
      endpoint: '/api/wilayah/$id',
      parse: (data) => Wilayah.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  // â”€â”€â”€ Public Reports GeoJSON â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  /// Gets public reports as GeoJSON.
  Future<GeoJSONFeatureCollection> getPublicReportsGeojson({
    String? status,
    String? categoryId,
  }) async {
    return await _execute<GeoJSONFeatureCollection>(
      dioCall: () => _dio.get(
        '/api/public/reports.geojson',
        queryParameters: {
          if (status != null) 'status': status,
          if (categoryId != null) 'category_id': categoryId,
        },
      ),
      endpoint: '/api/public/reports.geojson',
      parse: (data) => GeoJSONFeatureCollection.fromJson(
        (data as Map).cast<String, dynamic>(),
      ),
    );
  }

  // â”€â”€â”€ Photo Upload URL â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  /// Gets presigned URL for photo upload.
  /// Backend expects multipart FormData with a photo file (not JSON content_type).
  Future<UploadPhotoResult> getPhotoUploadUrl({
    required String reportId,
    required String contentType,
  }) async {
    await _checkConnectivity();
    // Backend accepts FormData with a photo file; send an empty placeholder
    // since this method only provides the upload URL (actual file sent separately).
    final ext = contentType == 'image/png'
        ? 'png'
        : contentType == 'image/webp'
        ? 'webp'
        : 'jpg';
    final formData = FormData.fromMap({
      'photo': MultipartFile.fromBytes(
        Uint8List(0),
        filename: 'photo.$ext',
        contentType: DioMediaType(
          contentType == 'image/png'
              ? 'png'
              : contentType == 'image/webp'
              ? 'webp'
              : 'jpeg',
          ext,
        ),
      ),
    });
    final response = await _dio.post(
      '/api/reports/$reportId/photos/upload-url',
      data: formData,
    );
    // Backend returns { public_url: "..." } directly (no data envelope)
    final responseData = response.data as Map<String, dynamic>;
    return UploadPhotoResult(publicUrl: responseData['public_url'] as String?);
  }
}

part of '../client.dart';

class ReportLocation {
  final double? lat;
  final double? lng;
  const ReportLocation({this.lat, this.lng});

  factory ReportLocation.fromJson(Map<String, dynamic> json) {
    return ReportLocation(
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {'lat': lat, 'lng': lng};
}

/// An evidence URL entry with upload metadata.
class EvidenceUrl {
  final String? url;
  final String? uploadedAt;
  final String? type;
  const EvidenceUrl({this.url, this.uploadedAt, this.type});

  factory EvidenceUrl.fromJson(Map<String, dynamic> json) {
    return EvidenceUrl(
      url: json['url']?.toString(),
      uploadedAt: json['uploaded_at']?.toString(),
      type: (json['type'] ?? json['status'])?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'url': url,
    'uploaded_at': uploadedAt,
    'type': type,
  };
}

/// A clarification Q&A entry for a task.
class ClarificationEntry {
  final String? question;
  final String? answer;
  final String? askedAt;
  const ClarificationEntry({this.question, this.answer, this.askedAt});

  factory ClarificationEntry.fromJson(Map<String, dynamic> json) {
    return ClarificationEntry(
      question: json['question']?.toString(),
      answer: json['answer']?.toString(),
      askedAt: json['asked_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'question': question,
    'answer': answer,
    'asked_at': askedAt,
  };
}

// ─── Types ────────────────────────────────────────────────────────────────────

class DuplicateCandidate {
  final double? lat;
  final double? lng;
  final String? createdAt;
  final String? title;
  final String? reportId;
  final String? description;
  final String? status;
  final String? photoUrl;
  final double? distanceM;
  final double? reportCount;
  final double? similarityScore;
  DuplicateCandidate({
    this.lat,
    this.lng,
    this.createdAt,
    this.title,
    this.reportId,
    this.description,
    this.status,
    this.photoUrl,
    this.distanceM,
    this.reportCount,
    this.similarityScore,
  });

  factory DuplicateCandidate.fromJson(Map<String, dynamic> json) {
    return DuplicateCandidate(
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      createdAt: json['created_at'] as String?,
      title: json['title'] as String?,
      reportId: json['report_id']?.toString(),
      description: json['description']?.toString(),
      status: json['status']?.toString(),
      photoUrl: json['photo_url']?.toString(),
      distanceM: (json['distance_m'] as num?)?.toDouble(),
      reportCount: (json['report_count'] as num?)?.toDouble(),
      similarityScore: (json['similarity_score'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'lat': lat,
    'lng': lng,
    'created_at': createdAt,
    'title': title,
    'report_id': reportId,
    'description': description,
    'status': status,
    'photo_url': photoUrl,
    'distance_m': distanceM,
    'report_count': reportCount,
    'similarity_score': similarityScore,
  };
}

class Photo {
  final String? id;
  final String? url;
  final String? thumbnailUrl;
  final String? uploadedAt;
  Photo({this.id, this.url, this.thumbnailUrl, this.uploadedAt});

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id']?.toString(),
      url: json['url']?.toString(),
      thumbnailUrl: json['thumbnail_url']?.toString(),
      uploadedAt: json['uploaded_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'url': url,
    'thumbnail_url': thumbnailUrl,
    'uploaded_at': uploadedAt,
  };
}

// Priority wrapper for Comparable comparison

class Report {
  final String? id;
  final String? idempotencyKey;
  final String? title;
  final String? description;
  final String? category;
  final ReportStatus? status;
  final Priority? priority;
  final ReportLocation? location;
  final String? reporterId;
  final List<String>? photos;
  final String? slaDeadline;
  final String? createdAt;
  final String? updatedAt;
  final String? mergedInto;
  final String? deadline;
  final int? severity;
  final int? priorityScore;
  final String? priorityBucket;
  final double? lng;
  final double? lat;
  final String? address;
  final String? addressArea;
  final String? impactDampak;
  final int? supportingCount;
  final String? kecamatan;
  final String? kelurahan;
  final String? kabupaten;
  final String? provinsi;
  final String? aiAssessment;
  final String? appealStatus;
  Report({
    this.id,
    this.idempotencyKey,
    this.title,
    this.description,
    this.category,
    this.status,
    this.priority,
    this.location,
    this.reporterId,
    this.photos,
    this.slaDeadline,
    this.createdAt,
    this.updatedAt,
    this.mergedInto,
    this.deadline,
    this.severity,
    this.priorityScore,
    this.priorityBucket,
    this.lng,
    this.lat,
    this.address,
    this.addressArea,
    this.impactDampak,
    this.supportingCount,
    this.kecamatan,
    this.kelurahan,
    this.kabupaten,
    this.provinsi,
    this.aiAssessment,
    this.appealStatus,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    final catField = json['category'];
    String? categoryStr;
    if (catField is Map) {
      categoryStr = catField['name']?.toString();
    } else if (catField != null) {
      categoryStr = catField.toString();
    }

    return Report(
      id: json['id']?.toString(),
      idempotencyKey: json['idempotency_key']?.toString(),
      title: json['title']?.toString(),
      description: json['description']?.toString(),
      category: categoryStr,
      status: json['status'] != null
          ? ReportStatus.fromJson(json['status'] as String)
          : null,
      priority: json['priority'] != null
          ? Priority.fromJson(json['priority'] as String)
          : null,
      location: json['location'] != null
          ? ReportLocation.fromJson(json['location'] as Map<String, dynamic>)
          : null,
      reporterId: json['reporter_id']?.toString(),
      photos: (json['photo_urls'] as List?)?.map((e) => e as String).toList(),
      slaDeadline: json['sla_deadline']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      mergedInto: json['merged_into']?.toString(),
      deadline: json['deadline']?.toString(),
      severity: json['severity'] as int?,
      priorityScore: json['priority_score'] as int?,
      priorityBucket: json['priority_bucket']?.toString(),
      lng: (json['lng'] as num?)?.toDouble(),
      lat: (json['lat'] as num?)?.toDouble(),
      address: json['address']?.toString(),
      addressArea: json['address_area']?.toString(),
      impactDampak: json['impact_dampak']?.toString(),
      supportingCount: json['supporting_count'] as int?,
      kecamatan: json['kecamatan']?.toString(),
      kelurahan: json['kelurahan']?.toString(),
      kabupaten: json['kabupaten']?.toString(),
      provinsi: json['provinsi']?.toString(),
      aiAssessment: json['ai_assessment']?.toString(),
      appealStatus: json['appeal_status']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'category': category,
    'status': status?.value,
    'priority': priority?.value,
    'location': location?.toJson(),
    'reporter_id': reporterId,
    'photo_urls': photos,
    'sla_deadline': slaDeadline,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'merged_into': mergedInto,
    'deadline': deadline,
    'severity': severity,
    'priority_score': priorityScore,
    'priority_bucket': priorityBucket,
    'lng': lng,
    'lat': lat,
    'address': address,
    'address_area': addressArea,
    'impact_dampak': impactDampak,
    'supporting_count': supportingCount,
    'kecamatan': kecamatan,
    'kelurahan': kelurahan,
    'kabupaten': kabupaten,
    'provinsi': provinsi,
    'ai_assessment': aiAssessment,
    'appeal_status': appealStatus,
  };
}

/// A similar report candidate returned by GET /api/reports/duplicates (M-11).
class SimilarReport {
  final String? reportId;
  final String? title;
  final String? initials;
  final double? distanceM;
  final double? similarityScore;
  final int? reportCount;
  SimilarReport({
    this.reportId,
    this.title,
    this.initials,
    this.distanceM,
    this.similarityScore,
    this.reportCount,
  });

  factory SimilarReport.fromJson(Map<String, dynamic> json) {
    return SimilarReport(
      reportId: json['report_id']?.toString(),
      title: json['title']?.toString(),
      initials: json['initials']?.toString(),
      distanceM: (json['distance_m'] as num?)?.toDouble(),
      similarityScore: (json['similarity_score'] as num?)?.toDouble(),
      reportCount: (json['report_count'] as num?)?.toInt(),
    );
  }
}

class TimelineEnvelope {
  final List<TimelineEvent>? events;
  TimelineEnvelope({this.events});

  factory TimelineEnvelope.fromJson(Map<String, dynamic> json) {
    return TimelineEnvelope(
      events: ((json['events'] ?? json['data']) as List?)
          ?.map((e) => TimelineEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// OG meta for share preview from GET /api/public/cases/:id/share
class ShareMetadata {
  final String? title;
  final String? description;
  final String? imageUrl;
  final String? url;
  ShareMetadata({this.title, this.description, this.imageUrl, this.url});

  factory ShareMetadata.fromJson(Map<String, dynamic> json) {
    return ShareMetadata(
      title: json['title']?.toString(),
      description: json['description']?.toString(),
      imageUrl: json['image_url']?.toString(),
      url: json['url']?.toString(),
    );
  }
}

class WargaStats {
  final int? needsCompletion;
  final int? processing;
  final int? total;
  final int? submitted;
  final int? verified;
  final int? inProgress;
  final int? resolved;
  WargaStats({
    this.needsCompletion,
    this.processing,
    this.total,
    this.submitted,
    this.verified,
    this.inProgress,
    this.resolved,
  });

  factory WargaStats.fromJson(Map<String, dynamic> json) {
    final byStatus = json['by_status'] as Map<String, dynamic>?;
    return WargaStats(
      needsCompletion:
          json['needs_completion'] as int? ??
          byStatus?['needs_completion'] as int?,
      processing:
          json['processing'] as int? ??
          (byStatus == null
              ? null
              : [
                  'submitted',
                  'under_review',
                  'verified',
                  'assigned',
                  'in_progress',
                  'needs_survey',
                  'escalated',
                ].fold<int>(
                  0,
                  (sum, status) =>
                      sum + ((byStatus[status] as num?)?.toInt() ?? 0),
                )),
      total: json['total'] as int?,
      submitted: byStatus?['submitted'] ?? json['submitted'] as int?,
      verified: byStatus?['verified'] ?? json['verified'] as int?,
      inProgress: byStatus?['in_progress'] ?? json['in_progress'] as int?,
      resolved:
          json['completed'] as int? ??
          (byStatus == null
              ? json['resolved'] as int?
              : ((byStatus['resolved'] as int? ?? 0) +
                    (byStatus['closed'] as int? ?? 0))),
    );
  }
}

class SubmitReportResult {
  final String? id;
  final bool duplicate;
  SubmitReportResult({this.id, this.duplicate = false});

  factory SubmitReportResult.fromJson(Map<String, dynamic> json) {
    return SubmitReportResult(
      id: json['id'] as String?,
      duplicate: json['duplicate'] as bool? ?? false,
    );
  }
}

class WargaReportsPage {
  final List<Report> items;
  WargaReportsPage({required this.items});
}

// ─── API Client ─────────────────────────────────────────────────────────────

class ReportActionResponse {
  final String? id;
  final String? status;
  final int? version;
  final int? cancelledTasks;
  ReportActionResponse({
    this.id,
    this.status,
    this.version,
    this.cancelledTasks,
  });

  factory ReportActionResponse.fromJson(Map<String, dynamic> json) {
    return ReportActionResponse(
      id: json['id']?.toString(),
      status: json['status']?.toString(),
      version: json['version'] as int?,
      cancelledTasks: json['cancelled_tasks'] as int?,
    );
  }
}

class PhotoUploadUrlResponse {
  final String? putUrl;
  PhotoUploadUrlResponse({this.putUrl});

  factory PhotoUploadUrlResponse.fromJson(Map<String, dynamic> json) {
    return PhotoUploadUrlResponse(putUrl: json['putUrl'] as String?);
  }
}

class PhotoUploadResult {
  final String? publicUrl;
  PhotoUploadResult({this.publicUrl});
}

class PhotoPutResponse {
  final bool ok;
  final List<String> photoUrls;
  PhotoPutResponse({required this.ok, required this.photoUrls});

  factory PhotoPutResponse.fromJson(Map<String, dynamic> json) {
    final urls = json['photo_urls'] as List;
    return PhotoPutResponse(
      ok: json['ok'] as bool,
      photoUrls: urls.map((e) => e.toString()).toList(),
    );
  }
}

class PaginatedReports {
  final List<Report> data;
  final String? next;
  PaginatedReports({required this.data, this.next});

  factory PaginatedReports.fromJson(Map<String, dynamic> json) {
    final list = json['data'] as List? ?? [];
    return PaginatedReports(
      data: list
          .map((e) => Report.fromJson(e as Map<String, dynamic>))
          .toList(),
      next: json['next'] as String?,
    );
  }

  bool get hasMore => next != null;
}

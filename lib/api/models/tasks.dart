part of '../client.dart';

/// A single visit/timeline entry in a report or case.
class VisitEntry {
  final String? id;
  final String? type;
  final String? message;
  final String? timestamp;
  final String? userId;
  const VisitEntry({
    this.id,
    this.type,
    this.message,
    this.timestamp,
    this.userId,
  });

  factory VisitEntry.fromJson(Map<String, dynamic> json) {
    return VisitEntry(
      id: json['id']?.toString(),
      type: (json['type'] ?? json['status'])?.toString(),
      message: (json['message'] ?? json['label'])?.toString(),
      timestamp: (json['timestamp'] ?? json['occurred_at'])?.toString(),
      userId: json['user_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'message': message,
    'timestamp': timestamp,
    'user_id': userId,
  };
}

class PetugasTask {
  final String? taskId;
  final String? reportId;
  final String? reportTitle;
  final String? status;
  final List<String>? evidenceUrls;
  final List<String>? completionEvidenceUrls;
  final List<String>? resolutionEvidenceUrls;
  final String? assignedAt;
  final String? completedAt;
  // Rich backend fields from JOIN query
  final String? code;
  final double? slaHoursRemaining;
  final String? priority; // 'tinggi', 'sedang', 'rendah'
  final String? categoryName;
  final String? categorySlug;
  final String? address;
  final int? progressPercent;
  final int? severity;
  final double? lat;
  final double? lng;
  final String? instructions;
  final String? deadline;
  final String? unitId;
  final String? unitName;
  final DateTime? createdAt;
  final String? reportDescription;
  PetugasTask({
    this.taskId,
    this.reportId,
    this.reportTitle,
    this.status,
    this.evidenceUrls,
    this.completionEvidenceUrls,
    this.resolutionEvidenceUrls,
    this.assignedAt,
    this.completedAt,
    this.code,
    this.slaHoursRemaining,
    this.priority,
    this.categoryName,
    this.categorySlug,
    this.address,
    this.progressPercent,
    this.severity,
    this.lat,
    this.lng,
    this.instructions,
    this.deadline,
    this.unitId,
    this.unitName,
    this.createdAt,
    this.reportDescription,
  });

  factory PetugasTask.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(String? s) {
      if (s == null) return null;
      return DateTime.tryParse(s);
    }

    return PetugasTask(
      taskId: json['id']?.toString(),
      reportId: json['report_id']?.toString(),
      reportTitle: (json['report_title'] ?? json['report_description'])
          ?.toString(),
      status: json['status']?.toString(),
      evidenceUrls: (json['photo_urls'] as List?)
          ?.map((e) => e as String)
          .toList(),
      completionEvidenceUrls: (json['completion_evidence_urls'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      resolutionEvidenceUrls: (json['resolution_evidence_urls'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      assignedAt: json['accepted_at']?.toString(),
      completedAt: json['completed_at']?.toString(),
      code: json['code']?.toString(),
      slaHoursRemaining: (json['sla_hours_remaining'] as num?)?.toDouble(),
      priority: json['priority']?.toString(),
      categoryName: json['category_name']?.toString(),
      categorySlug: json['category_slug']?.toString(),
      address:
          json['address']?.toString() ?? json['report_address']?.toString(),
      progressPercent: json['progress_percent'] as int?,
      severity: json['severity'] as int?,
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      instructions: json['instructions']?.toString(),
      deadline: json['deadline']?.toString(),
      unitId: json['unit_id']?.toString(),
      unitName: json['unit_name']?.toString(),
      createdAt: parseDate(json['created_at']?.toString()),
      reportDescription: json['report_description']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': taskId,
    'report_id': reportId,
    'report_description': reportTitle,
    'status': status,
    'photo_urls': evidenceUrls,
    'completion_evidence_urls': completionEvidenceUrls,
    'resolution_evidence_urls': resolutionEvidenceUrls,
    'accepted_at': assignedAt,
    'completed_at': completedAt,
    'code': code,
    'sla_hours_remaining': slaHoursRemaining,
    'priority': priority,
    'category_name': categoryName,
    'address': address,
    'progress_percent': progressPercent,
    'severity': severity,
    'lat': lat,
    'lng': lng,
    'instructions': instructions,
    'deadline': deadline,
    'unit_name': unitName,
  };
}

class SurveyChecklistAnswer {
  final String item;
  final String status;
  final String? notes;
  const SurveyChecklistAnswer({
    required this.item,
    required this.status,
    this.notes,
  });
  factory SurveyChecklistAnswer.fromJson(Map<String, dynamic> json) =>
      SurveyChecklistAnswer(
        item: json['item'] as String? ?? '',
        status:
            json['status'] as String? ??
            (json['checked'] == true ? 'completed' : 'pending'),
        notes: json['notes'] as String?,
      );
  Map<String, dynamic> toJson() => {
    'item': item,
    'status': status,
    if (notes != null) 'notes': notes,
  };
}

class SurveyDimensions {
  final num? length, width, height, depth;
  final String? unit;
  const SurveyDimensions({
    this.length,
    this.width,
    this.height,
    this.depth,
    this.unit,
  });
  factory SurveyDimensions.fromJson(Map<String, dynamic> json) =>
      SurveyDimensions(
        length: json['length'] is num ? json['length'] as num : null,
        width: json['width'] is num ? json['width'] as num : null,
        height: json['height'] is num ? json['height'] as num : null,
        depth: json['depth'] is num ? json['depth'] as num : null,
        unit: json['unit'] is String ? json['unit'] as String : null,
      );
  Map<String, dynamic> toJson() => {
    if (length != null) 'length': length,
    if (width != null) 'width': width,
    if (height != null) 'height': height,
    if (depth != null) 'depth': depth,
    if (unit != null) 'unit': unit,
  };
}

class SurveyVisit {
  final SurveyDimensions? measuredDimensions;
  final String? id,
      findings,
      dimensions,
      recommendation,
      notes,
      conditionAssessment,
      createdAt;
  final List<String> photoUrls;
  const SurveyVisit({
    this.measuredDimensions,
    this.id,
    this.findings,
    this.dimensions,
    this.recommendation,
    this.notes,
    this.conditionAssessment,
    this.createdAt,
    this.photoUrls = const [],
  });
  factory SurveyVisit.fromJson(Map<String, dynamic> json) => SurveyVisit(
    id: json['id']?.toString(),
    findings: json['findings'] as String?,
    dimensions: json['dimensions'] is String
        ? json['dimensions'] as String
        : null,
    measuredDimensions: json['dimensions'] is Map
        ? SurveyDimensions.fromJson(
            (json['dimensions'] as Map).cast<String, dynamic>(),
          )
        : null,
    recommendation: json['recommendation'] as String?,
    notes: json['notes'] as String?,
    conditionAssessment: json['condition_assessment'] as String?,
    createdAt: json['created_at'] as String?,
    photoUrls: (json['photo_urls'] as List?)?.cast<String>() ?? [],
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'findings': findings,
    'dimensions': measuredDimensions?.toJson() ?? dimensions,
    'recommendation': recommendation,
    'notes': notes,
    'condition_assessment': conditionAssessment,
    'created_at': createdAt,
    'photo_urls': photoUrls,
  };
}

class TaskDetail {
  final double? lat;
  final double? lng;
  final String? categoryId;
  final String? address;
  final String? taskId;
  final String? reportId;
  final String? reportTitle;
  final String? description;
  final String? status;
  final int? progress;
  final List<EvidenceUrl>? evidenceUrls;
  final List<String>? completionEvidenceUrls;
  final List<String>? resolutionEvidenceUrls;
  final List<ClarificationEntry>? clarification;
  final String? assignedAt;
  final String? completedAt;
  final String? uploadToken;
  final String? categoryName;
  final String? deadline;
  final List<SurveyVisit> visits;
  final String? reportStatus;
  TaskDetail({
    this.lat,
    this.lng,
    this.categoryId,
    this.address,
    this.taskId,
    this.reportId,
    this.reportTitle,
    this.description,
    this.status,
    this.progress,
    this.evidenceUrls,
    this.completionEvidenceUrls,
    this.resolutionEvidenceUrls,
    this.clarification,
    this.assignedAt,
    this.completedAt,
    this.uploadToken,
    this.categoryName,
    this.deadline,
    this.visits = const [],
    this.reportStatus,
  });

  factory TaskDetail.fromJson(Map<String, dynamic> json) {
    final task = (json['task'] as Map?)?.cast<String, dynamic>() ?? json;
    return TaskDetail(
      lat: (task['lat'] as num?)?.toDouble(),
      lng: (task['lng'] as num?)?.toDouble(),
      categoryId: task['category_id']?.toString(),
      address: task['report_address']?.toString(),
      taskId: task['id']?.toString(),
      reportId: (task['report_id'] ?? task['reportId'])?.toString(),
      uploadToken: task['uploadToken']?.toString(),
      status: task['status']?.toString(),
      reportStatus: task['report_status']?.toString(),
      description: task['instructions']?.toString(),
      assignedAt: task['created_at']?.toString(),
      reportTitle: (task['report_title'] ?? task['report_description'])
          ?.toString(),
      progress: (task['progress_percent'] as num?)?.toInt(),
      evidenceUrls: (task['photo_urls'] as List?)
          ?.map((url) => EvidenceUrl(url: url.toString()))
          .toList(),
      completionEvidenceUrls: (task['completion_evidence_urls'] as List?)
          ?.map((url) => url.toString())
          .toList(),
      resolutionEvidenceUrls: (task['resolution_evidence_urls'] as List?)
          ?.map((url) => url.toString())
          .toList(),
      clarification: (json['clarifications'] as List?)
          ?.map(
            (entry) => ClarificationEntry(
              question: (entry['message'] ?? entry['question'])?.toString(),
              askedAt: (entry['created_at'] ?? entry['asked_at'])?.toString(),
            ),
          )
          .toList(),
      completedAt: task['completed_at']?.toString(),
      categoryName: task['category_name']?.toString(),
      deadline: task['deadline']?.toString(),
      visits:
          (json['visits'] as List?)
              ?.map(
                (entry) => SurveyVisit.fromJson(
                  (entry as Map).cast<String, dynamic>(),
                ),
              )
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'task': {
      'lat': lat,
      'lng': lng,
      'category_id': categoryId,
      'report_address': address,
      'id': taskId,
      'report_id': reportId,
      'report_title': reportTitle,
      'instructions': description,
      'status': status,
      'progress_percent': progress,
      'created_at': assignedAt,
      'completed_at': completedAt,
      'category_name': categoryName,
      'deadline': deadline,
      'photo_urls': evidenceUrls?.map((e) => e.url).toList(),
      'completion_evidence_urls': completionEvidenceUrls,
      'resolution_evidence_urls': resolutionEvidenceUrls,
      'report_status': reportStatus,
    },
    'visits': visits.map((visit) => visit.toJson()).toList(),
    'evidence': evidenceUrls?.map((e) => e.toJson()).toList(),
    'clarifications': clarification?.map((e) => e.toJson()).toList(),
  };
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

class TaskListPage<T> {
  final List<T> tasks;
  final Pagination pagination;
  TaskListPage({required this.tasks, required this.pagination});
}

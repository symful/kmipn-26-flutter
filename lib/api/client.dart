import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_config.dart';
import '../l10n/generated/app_localizations.dart';
import '../widgets/design_system/status_pill.dart';
import 'auth_interceptor.dart';
import 'exceptions.dart';

// ─── Enums ───────────────────────────────────────────────────────────────────

enum ReportStatus {
  draft("draft"),
  submitted("submitted"),
  underReview("under_review"),
  verified("verified"),
  assigned("assigned"),
  inProgress("in_progress"),
  resolved("resolved"),
  closed("closed"),
  rejected("rejected"),
  duplicateMerged("duplicate_merged"),
  needsSurvey("needs_survey"),
  merged("merged"),
  separated("separated"),
  needsCompletion("needs_completion"),
  outOfScope("out_of_scope"),
  pending("pending"),
  locallyCreated("locally_created"),
  locallySaved("locally_saved"),
  inReview("in_review"),
  needsAction("needs_action"),
  completed("completed");

  final String value;
  const ReportStatus(this.value);
  static const allValues = <ReportStatus>[
    ReportStatus.draft,
    ReportStatus.submitted,
    ReportStatus.underReview,
    ReportStatus.verified,
    ReportStatus.assigned,
    ReportStatus.inProgress,
    ReportStatus.resolved,
    ReportStatus.closed,
    ReportStatus.rejected,
    ReportStatus.duplicateMerged,
    ReportStatus.needsSurvey,
    ReportStatus.merged,
    ReportStatus.separated,
    ReportStatus.needsCompletion,
    ReportStatus.outOfScope,
    ReportStatus.pending,
    ReportStatus.locallyCreated,
    ReportStatus.locallySaved,
    ReportStatus.inReview,
    ReportStatus.needsAction,
    ReportStatus.completed,
  ];
  static ReportStatus fromJson(String value) {
    final lower = value.toLowerCase();
    return allValues.firstWhere(
      (e) => e.value == lower || e.value == value,
      orElse: () => ReportStatus.submitted,
    );
  }
}

enum Priority {
  low("low"),
  medium("medium"),
  high("high"),
  critical("critical");

  final String value;
  const Priority(this.value);
  static const allValues = <Priority>[
    Priority.low,
    Priority.medium,
    Priority.high,
    Priority.critical,
  ];
  static Priority fromJson(String value) =>
      allValues.firstWhere((e) => e.value == value);
}

/// Case-level statuses (server-side aggregation of reports)
enum CaseStatus {
  menungguVerifikasi, // amber — "Menunggu verifikasi"
  terverifikasi, // blue — "Terverifikasi"
  sedangDitangani, // teal — "Sedang ditangani"
  perluKelengkapan, // gray — "Perlu kelengkapan"
  slaTerlewat, // red — "SLA terlewat"
}

extension CaseStatusMapper on CaseStatus {
  static CaseStatus fromString(String? s) => switch (s) {
    'menunggu_verifikasi' ||
    'pending_verification' ||
    'MENUNGGU_VERIFIKASI' => CaseStatus.menungguVerifikasi,
    'terverifikasi' ||
    'verified' ||
    'TERVERIFIKASI' => CaseStatus.terverifikasi,
    'sedang_ditangani' ||
    'in_progress' ||
    'SEDANG_DITANGANI' => CaseStatus.sedangDitangani,
    'perlu_kelengkapan' ||
    'needs_completion' ||
    'PERLU_KELENGKAPAN' => CaseStatus.perluKelengkapan,
    'sla_terlewat' ||
    'sla_breached' ||
    'SLA_TERLEWAT' => CaseStatus.slaTerlewat,
    _ => CaseStatus.menungguVerifikasi,
  };

  String displayLabel(AppLocalizations l10n) => switch (this) {
    CaseStatus.menungguVerifikasi => l10n.menungguVerifikasiLabel,
    CaseStatus.terverifikasi => l10n.terverifikasiLabel,
    CaseStatus.sedangDitangani => l10n.sedangDitanganiLabel,
    CaseStatus.perluKelengkapan => l10n.perluKelengkapanLabel,
    CaseStatus.slaTerlewat => l10n.slaTerlewatLabel,
  };

  StatusTone get displayTone => switch (this) {
    CaseStatus.menungguVerifikasi => StatusTone.warning,
    CaseStatus.terverifikasi => StatusTone.info, // blue
    CaseStatus.sedangDitangani => StatusTone.success, // teal
    CaseStatus.perluKelengkapan => StatusTone.neutral,
    CaseStatus.slaTerlewat => StatusTone.danger,
  };
}

enum CitizenReportStatus {
  tersimpanPerangkat,
  laporanDiterima,
  sedangDiperiksa,
  perluDilengkapi,
  perluTindakan,
  sedangDitangani,
  terverifikasi,
  draft,
}

extension CitizenReportStatusMapper on ReportStatus {
  CitizenReportStatus toCitizenStatus({bool isLocalOnly = false}) =>
      switch (this) {
        ReportStatus.draft ||
        ReportStatus.locallyCreated => CitizenReportStatus.draft,
        ReportStatus.submitted ||
        ReportStatus.underReview => CitizenReportStatus.laporanDiterima,
        ReportStatus.inReview => CitizenReportStatus.sedangDiperiksa,
        ReportStatus.needsCompletion => CitizenReportStatus.perluDilengkapi,
        ReportStatus.needsAction => CitizenReportStatus.perluTindakan,
        ReportStatus.inProgress ||
        ReportStatus.assigned => CitizenReportStatus.sedangDitangani,
        ReportStatus.verified ||
        ReportStatus.completed => CitizenReportStatus.terverifikasi,
        ReportStatus.locallySaved => CitizenReportStatus.tersimpanPerangkat,
        _ => CitizenReportStatus.sedangDitangani,
      };

  StatusTone get displayColor =>
      switch (this.toCitizenStatus(isLocalOnly: false)) {
        CitizenReportStatus.tersimpanPerangkat => StatusTone.success,
        CitizenReportStatus.laporanDiterima => StatusTone.success,
        CitizenReportStatus.sedangDiperiksa => StatusTone.success,
        CitizenReportStatus.perluDilengkapi => StatusTone.warning,
        CitizenReportStatus.perluTindakan => StatusTone.warning,
        CitizenReportStatus.sedangDitangani => StatusTone.info,
        CitizenReportStatus.terverifikasi => StatusTone.success,
        CitizenReportStatus.draft => StatusTone.neutral,
      };

  String citizenLabel(AppLocalizations l10n) => switch (this.toCitizenStatus(
    isLocalOnly: false,
  )) {
    CitizenReportStatus.tersimpanPerangkat => l10n.tersimpanDiPerangkatLabel,
    CitizenReportStatus.laporanDiterima => l10n.laporanDiterimaLabel,
    CitizenReportStatus.sedangDiperiksa => l10n.sedangDiperiksaLabel,
    CitizenReportStatus.perluDilengkapi => l10n.perluDilengkapiLabel,
    CitizenReportStatus.perluTindakan => l10n.perluTindakanAndaLabel,
    CitizenReportStatus.sedangDitangani => l10n.sedangDitanganiLabel,
    CitizenReportStatus.terverifikasi => l10n.terverifikasiLabel,
    CitizenReportStatus.draft => l10n.draftLabel,
  };
}

/// Report timeline event types
enum ReportTimelineEvent {
  tersimpanDiPerangkat,
  laporanDiterima,
  sedangDiperiksa,
  perluDilengkapi,
}

extension ReportTimelineEventMapper on ReportTimelineEvent {
  static ReportTimelineEvent? fromAuditAction(String? action) {
    if (action == null) return null;
    if (action.contains('submitted'))
      return ReportTimelineEvent.laporanDiterima;
    if (action.contains('review')) return ReportTimelineEvent.sedangDiperiksa;
    if (action.contains('needs_completion'))
      return ReportTimelineEvent.perluDilengkapi;
    if (action.contains('local_save'))
      return ReportTimelineEvent.tersimpanDiPerangkat;
    return null;
  }

  String displayLabel(AppLocalizations l10n) => switch (this) {
    ReportTimelineEvent.tersimpanDiPerangkat => l10n.tersimpanDiPerangkatLabel,
    ReportTimelineEvent.laporanDiterima => l10n.laporanDiterimaLabel,
    ReportTimelineEvent.sedangDiperiksa => l10n.sedangDiperiksaLabel,
    ReportTimelineEvent.perluDilengkapi => l10n.perluDilengkapiLabel,
  };
}

/// Case timeline event types
enum CaseTimelineEvent {
  laporanPertamaDiterima,
  kasusDibuatKonsolidasi,
  laporanDigabung,
  menungguVerifikasiManual,
}

extension CaseTimelineEventMapper on CaseTimelineEvent {
  static CaseTimelineEvent? fromAuditAction(String? action) {
    if (action == null) return null;
    if (action.contains('first_report') || action.contains('report.created')) {
      return CaseTimelineEvent.laporanPertamaDiterima;
    }
    if (action.contains('case_created') || action.contains('consolidate')) {
      return CaseTimelineEvent.kasusDibuatKonsolidasi;
    }
    if (action.contains('merged') || action.contains('merge')) {
      return CaseTimelineEvent.laporanDigabung;
    }
    if (action.contains('awaiting_verification') ||
        action.contains('manual_review')) {
      return CaseTimelineEvent.menungguVerifikasiManual;
    }
    return null;
  }

  String displayLabel(AppLocalizations l10n) => switch (this) {
    CaseTimelineEvent.laporanPertamaDiterima => l10n.laporanPertamaDiterima,
    CaseTimelineEvent.kasusDibuatKonsolidasi => l10n.kasusDibuatDariKonsolidasi,
    CaseTimelineEvent.laporanDigabung => l10n.laporanDigabung,
    CaseTimelineEvent.menungguVerifikasiManual => l10n.menungguVerifikasiManual,
  };
}

// ─── Types ────────────────────────────────────────────────────────────────────

class DuplicateCandidate {
  final String? reportId;
  final String? description;
  final String? status;
  final String? photoUrl;
  final double? distanceM;
  final double? reportCount;
  final double? similarityScore;
  DuplicateCandidate({
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
    'report_id': reportId,
    'description': description,
    'status': status,
    'photo_url': photoUrl,
    'distance_m': distanceM,
    'report_count': reportCount,
    'similarity_score': similarityScore,
  };
}

class ErrorResponse {
  final String? error;
  final List<Map<String, dynamic>>? details;
  ErrorResponse({this.error, this.details});

  factory ErrorResponse.fromJson(Map<String, dynamic> json) {
    return ErrorResponse(
      error: json['error']?.toString(),
      details: (json['details'] as List?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {'error': error, 'details': details};
}

class Pagination {
  final int? page;
  final int? limit;
  final int? total;
  final int? totalPages;
  Pagination({this.page, this.limit, this.total, this.totalPages});

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      page: json['page'] as int?,
      limit: json['limit'] as int?,
      total: json['total'] as int?,
      totalPages: json['total_pages'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
    'page': page,
    'limit': limit,
    'total': total,
    'total_pages': totalPages,
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

class TimelineEvent {
  final String? id;
  final String? type;
  final String? message;
  final String? timestamp;
  final String? userId;
  TimelineEvent({
    this.id,
    this.type,
    this.message,
    this.timestamp,
    this.userId,
  });

  factory TimelineEvent.fromJson(Map<String, dynamic> json) {
    return TimelineEvent(
      id: json['id']?.toString(),
      type: json['type']?.toString(),
      message: json['message']?.toString(),
      timestamp: json['timestamp']?.toString(),
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

class Notification {
  final String? id;
  final String? title;
  final String? body;
  final bool? read;
  final String? createdAt;
  final String? kind;
  final String? relatedCaseId;
  final String? readAt;
  Notification({
    this.id,
    this.title,
    this.body,
    this.read,
    this.createdAt,
    this.kind,
    this.relatedCaseId,
    this.readAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id']?.toString(),
      title: json['title']?.toString(),
      body: json['body']?.toString(),
      read: json['read'] ?? (json['read_at'] != null),
      createdAt: json['created_at']?.toString(),
      kind: (json['type'] ?? json['kind'])?.toString(),
      relatedCaseId: json['related_case_id']?.toString(),
      readAt: json['read_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'read': read,
    'created_at': createdAt,
    'kind': kind,
    'related_case_id': relatedCaseId,
    'read_at': readAt,
  };
}

class AuditEntry {
  final String? id;
  final String? userId;
  final String? action;
  final String? resource;
  final String? resourceId;
  final Map<String, dynamic>? metadata;
  final String? timestamp;
  AuditEntry({
    this.id,
    this.userId,
    this.action,
    this.resource,
    this.resourceId,
    this.metadata,
    this.timestamp,
  });

  factory AuditEntry.fromJson(Map<String, dynamic> json) {
    return AuditEntry(
      id: json['id']?.toString(),
      userId: json['actor']?.toString(),
      action: json['action']?.toString(),
      resource: json['object_type']?.toString(),
      resourceId: json['object_id']?.toString(),
      metadata: json['metadata'] as Map<String, dynamic>?,
      timestamp: json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'actor': userId,
    'action': action,
    'object_type': resource,
    'object_id': resourceId,
    'metadata': metadata,
    'created_at': timestamp,
  };
}

class Category {
  final String? id;
  final String? name;
  final String? slug;
  final String? icon;
  final String? description;
  final int? reportCount;
  Category({
    this.id,
    this.name,
    this.slug,
    this.icon,
    this.description,
    this.reportCount,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id']?.toString(),
      name: json['name']?.toString(),
      slug: json['slug']?.toString(),
      icon: json['icon']?.toString(),
      description: json['description']?.toString(),
      reportCount: json['report_count'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'slug': slug,
    'icon': icon,
    'description': description,
    'report_count': reportCount,
  };
}

class Unit {
  final String? id;
  final String? name;
  final String? type;
  final String? region;
  Unit({this.id, this.name, this.type, this.region});

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      id: json['id']?.toString(),
      name: json['name']?.toString(),
      type: json['type']?.toString(),
      region: json['region']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type,
    'region': region,
  };
}

class SlaConfig {
  final String? id;
  final String? name;
  final int? slaDays;
  final String? priority;
  final bool? isActive;
  final String? createdAt;
  SlaConfig({
    this.id,
    this.name,
    this.slaDays,
    this.priority,
    this.isActive,
    this.createdAt,
  });

  factory SlaConfig.fromJson(Map<String, dynamic> json) {
    return SlaConfig(
      id: json['id']?.toString(),
      name: json['kategori_id']?.toString(),
      slaDays: json['jam'] as int?,
      priority: json['prioritas']?.toString(),
      isActive: json['is_active'] as bool?,
      createdAt: json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'kategori_id': name,
    'jam': slaDays,
    'prioritas': priority,
    'is_active': isActive,
    'created_at': createdAt,
  };
}

class ChecklistTemplate {
  final String? id;
  final String? name;
  final List<Map<String, dynamic>>? items;
  final String? createdAt;
  ChecklistTemplate({this.id, this.name, this.items, this.createdAt});

  factory ChecklistTemplate.fromJson(Map<String, dynamic> json) {
    return ChecklistTemplate(
      id: json['id']?.toString(),
      name: json['name']?.toString(),
      items: (json['items'] as List?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      createdAt: json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'items': items,
    'created_at': createdAt,
  };
}

class PriorityConfig {
  final String? id;
  final String? name;
  final List<Map<String, dynamic>>? rules;
  final bool? isActive;
  final String? createdAt;
  PriorityConfig({
    this.id,
    this.name,
    this.rules,
    this.isActive,
    this.createdAt,
  });

  factory PriorityConfig.fromJson(Map<String, dynamic> json) {
    return PriorityConfig(
      id: json['id']?.toString(),
      name: json['name']?.toString(),
      rules: (json['rules'] as List?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      isActive: json['is_active'] as bool?,
      createdAt: json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'rules': rules,
    'is_active': isActive,
    'created_at': createdAt,
  };
}

class LoginRequest {
  final String email;
  final String password;
  LoginRequest({required this.email, required this.password});

  factory LoginRequest.fromJson(Map<String, dynamic> json) {
    return LoginRequest(
      email: json['email'].toString(),
      password: json['password'].toString(),
    );
  }

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

class LoginResponse {
  final String? token;
  final String? refreshToken;
  final User? user;
  final List<String>? capabilities;
  LoginResponse({this.token, this.refreshToken, this.user, this.capabilities});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['access_token']?.toString(),
      refreshToken: json['refresh_token']?.toString(),
      user: json['user'] != null
          ? User.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      capabilities: (json['capabilities'] as List?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'token': token,
    'refresh_token': refreshToken,
    'user': user?.toJson(),
    'capabilities': capabilities,
  };
}

/// Response from GET /api/auth/capabilities.
class CapabilitiesResponse {
  final String? version;
  final String? etag;
  final int? ttl;
  final List<String>? capabilities;
  final List<String>? roles;
  final List<String>? wilayahScope;
  final bool? maintenance;

  CapabilitiesResponse({
    this.version,
    this.etag,
    this.ttl,
    this.capabilities,
    this.roles,
    this.wilayahScope,
    this.maintenance,
  });

  factory CapabilitiesResponse.fromJson(Map<String, dynamic> json) {
    return CapabilitiesResponse(
      version: json['version']?.toString(),
      etag: json['etag']?.toString(),
      ttl: json['ttl'] as int?,
      capabilities: (json['capabilities'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      roles: (json['roles'] as List?)?.map((e) => e.toString()).toList(),
      wilayahScope: (json['wilayahScope'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      maintenance: json['maintenance'] as bool?,
    );
  }
}

class User {
  final String? id;
  final String? email;
  final String? name;
  final String? role;
  final String? unitId;
  final String? createdAt;
  final String? wilayahId;
  User({
    this.id,
    this.email,
    this.name,
    this.role,
    this.unitId,
    this.createdAt,
    this.wilayahId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString(),
      email: json['email']?.toString(),
      name: json['name']?.toString(),
      role: json['role']?.toString(),
      unitId: json['unit_id']?.toString(),
      createdAt: json['created_at']?.toString(),
      wilayahId: json['wilayah_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'role': role,
    'unit_id': unitId,
    'created_at': createdAt,
  };
}

class UserResponse {
  final String? id;
  final String? email;
  final String? name;
  final String? role;
  final String? unitId;
  final String? createdAt;
  UserResponse({
    this.id,
    this.email,
    this.name,
    this.role,
    this.unitId,
    this.createdAt,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      id: json['id']?.toString(),
      email: json['email']?.toString(),
      name: json['name']?.toString(),
      role: json['role']?.toString(),
      unitId: json['unit_id']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'role': role,
    'unit_id': unitId,
    'created_at': createdAt,
  };
}

// Priority wrapper for Comparable comparison
class PriorityValue implements Comparable<PriorityValue> {
  final String value;
  final int sortOrder;
  const PriorityValue(this.value, this.sortOrder);
  String get v => value;
  int get value_ => sortOrder;
  @override
  int compareTo(PriorityValue other) => other.sortOrder.compareTo(sortOrder); // higher sortOrder = higher priority
}

class Report {
  final String? id;
  final String? title;
  final String? description;
  final String? category;
  final ReportStatus? status;
  final Priority? priority;
  final Map<String, dynamic>? location;
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
  final String? wilayahId;
  Report({
    this.id,
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
    this.wilayahId,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    // category may be a string or an object { id, name, icon }
    final catField = json['category'];
    String? categoryStr;
    if (catField is Map) {
      categoryStr = catField['name']?.toString();
    } else if (catField != null) {
      categoryStr = catField.toString();
    }

    return Report(
      id: json['id']?.toString(),
      title: json['title']?.toString(),
      description: json['description']?.toString(),
      category: categoryStr,
      status: json['status'] != null
          ? ReportStatus.fromJson(json['status'] as String)
          : null,
      priority: json['priority'] != null
          ? Priority.fromJson(json['priority'] as String)
          : null,
      location: json['location'] as Map<String, dynamic>?,
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
      wilayahId: json['wilayah_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'category': category,
    'status': status?.value,
    'priority': priority?.value,
    'location': location,
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
  };
}

class ReportDetail {
  final String? id;
  final String? title;
  final String? description;
  final String? category;
  final ReportStatus? status;
  final Priority? priority;
  final Map<String, dynamic>? location;
  final String? reporterId;
  final List<String>? photos;
  final List<Map<String, dynamic>>? assessments;
  final List<Map<String, dynamic>>? visits;
  final String? slaDeadline;
  final double? lng;
  final double? lat;
  final String? priorityBucket;
  final String? createdAt;
  final String? updatedAt;
  final String? address;
  final String? addressArea;
  ReportDetail({
    this.id,
    this.title,
    this.description,
    this.category,
    this.status,
    this.priority,
    this.location,
    this.reporterId,
    this.photos,
    this.assessments,
    this.visits,
    this.slaDeadline,
    this.lng,
    this.lat,
    this.priorityBucket,
    this.createdAt,
    this.updatedAt,
    this.address,
    this.addressArea,
  });

  factory ReportDetail.fromJson(Map<String, dynamic> json) {
    // category may be a string or an object { id, name, icon }
    final catField = json['category'];
    String? categoryStr;
    if (catField is Map) {
      categoryStr = catField['name']?.toString();
    } else if (catField != null) {
      categoryStr = catField.toString();
    }

    return ReportDetail(
      id: json['id']?.toString(),
      title: json['title']?.toString(),
      description: json['description']?.toString(),
      category: categoryStr,
      status: json['status'] != null
          ? ReportStatus.fromJson(json['status'] as String)
          : null,
      priority: json['priority'] != null
          ? Priority.fromJson(json['priority'] as String)
          : null,
      location: json['location'] as Map<String, dynamic>?,
      reporterId: json['reporter_id']?.toString(),
      photos: (json['photo_urls'] as List?)?.map((e) => e as String).toList(),
      assessments: (json['assessments'] as List?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      visits: (json['visits'] as List?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      slaDeadline: json['sla_deadline']?.toString(),
      lng: (json['lng'] as num?)?.toDouble(),
      lat: (json['lat'] as num?)?.toDouble(),
      priorityBucket: json['priority_bucket']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'category': category,
    'status': status?.value,
    'priority': priority?.value,
    'location': location,
    'reporter_id': reporterId,
    'photo_urls': photos,
    'assessments': assessments,
    'visits': visits,
    'sla_deadline': slaDeadline,
    'lng': lng,
    'lat': lat,
    'priority_bucket': priorityBucket,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}

class CreateReportRequest {
  final String title;
  final String description;
  final String category;
  final String? address;
  final double lat;
  final double lng;
  final List<String>? photos;
  CreateReportRequest({
    required this.title,
    required this.description,
    required this.category,
    this.address,
    required this.lat,
    required this.lng,
    this.photos,
  });

  factory CreateReportRequest.fromJson(Map<String, dynamic> json) {
    return CreateReportRequest(
      title: json['title'].toString(),
      description: json['description'].toString(),
      category: json['category'].toString(),
      address: json['address']?.toString(),
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      photos: (json['photos'] as List?)?.map((e) => e as String).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'category': category,
    'address': address,
    'lat': lat,
    'lng': lng,
    'photos': photos,
  };
}

class ScoreFactors {
  final int? keselamatan;
  final int? jumlahTerdampak;
  final int? laporanPendukung;
  final int? kelewatanSla;

  const ScoreFactors({
    this.keselamatan,
    this.jumlahTerdampak,
    this.laporanPendukung,
    this.kelewatanSla,
  });

  factory ScoreFactors.fromJson(Map<String, dynamic> json) => ScoreFactors(
    keselamatan: json['keselamatan'] as int?,
    jumlahTerdampak: json['jumlah_terdampak'] as int?,
    laporanPendukung: json['laporan_pendukung'] as int?,
    kelewatanSla: json['kelewatan_sla'] as int?,
  );

  Map<String, dynamic> toJson() => {
    'keselamatan': keselamatan,
    'jumlah_terdampak': jumlahTerdampak,
    'laporan_pendukung': laporanPendukung,
    'kelewatan_sla': kelewatanSla,
  };
}

/// Priority breakdown factors from GET /api/reports/:id/priority.
class PriorityBreakdown {
  final int? severity;
  final int? affectedResidents;
  final int? regionVulnerability;
  final int? slaPressure;
  final int? otherFactors;
  final int? reportCount;

  const PriorityBreakdown({
    this.severity,
    this.affectedResidents,
    this.regionVulnerability,
    this.slaPressure,
    this.otherFactors,
    this.reportCount,
  });

  factory PriorityBreakdown.fromJson(Map<String, dynamic> json) {
    return PriorityBreakdown(
      severity: json['severity'] as int?,
      affectedResidents: json['affected_residents'] as int?,
      regionVulnerability: json['region_vulnerability'] as int?,
      slaPressure: json['sla_pressure'] as int?,
      otherFactors: json['other_factors'] as int?,
      reportCount: json['report_count'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
    'severity': severity,
    'affected_residents': affectedResidents,
    'region_vulnerability': regionVulnerability,
    'sla_pressure': slaPressure,
    'other_factors': otherFactors,
    'report_count': reportCount,
  };
}

/// Response from GET /api/reports/:id/priority.
class PriorityResponse {
  final String? id;
  final int? version;
  final int? score;
  final String? level;
  final PriorityBreakdown? breakdown;

  const PriorityResponse({
    this.id,
    this.version,
    this.score,
    this.level,
    this.breakdown,
  });

  factory PriorityResponse.fromJson(Map<String, dynamic> json) {
    return PriorityResponse(
      id: json['id']?.toString(),
      version: json['version'] as int?,
      score: json['score'] as int?,
      level: json['level']?.toString(),
      breakdown: json['breakdown'] != null
          ? PriorityBreakdown.fromJson(
              json['breakdown'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'version': version,
    'score': score,
    'level': level,
    'breakdown': breakdown?.toJson(),
  };
}

/// Entry from GET /api/agent/assessments/:reportId.
class AgentAssessmentEntry {
  final String? id;
  final String? toolName;
  final String? modelVersion;
  final double? confidence;
  final List<String>? supportingFactors;
  final List<String>? riskFactors;
  final String? status;
  final String? createdAt;

  const AgentAssessmentEntry({
    this.id,
    this.toolName,
    this.modelVersion,
    this.confidence,
    this.supportingFactors,
    this.riskFactors,
    this.status,
    this.createdAt,
  });

  factory AgentAssessmentEntry.fromJson(Map<String, dynamic> json) {
    // Backend returns nested factors: { supporting: [...], risk: [...], correlation_ids: [...] }
    final factors = json['factors'] as Map<String, dynamic>?;
    return AgentAssessmentEntry(
      id: json['id']?.toString(),
      toolName: json['tool_name']?.toString(),
      modelVersion: json['model_version']?.toString(),
      confidence: (json['confidence'] as num?)?.toDouble(),
      supportingFactors: (factors?['supporting'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      riskFactors: (factors?['risk'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      status: json['status']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }
}

class CaseDetail {
  final String? id;

  /// Alias for backwards-compatibility — maps to backend's top-level 'case' key.
  final Report? report;
  final VerifikatorCase? verifikatorCase;
  final List<Map<String, dynamic>>? assessments;

  /// Alias for backwards-compatibility — maps to backend's 'timeline' key.
  final List<Map<String, dynamic>>? visits;
  final List<AuditEntry>? audit;
  final String? status;

  /// Backend 'case' object (rename of 'report' alias to match real API shape).
  final Map<String, dynamic>? caseData;
  final ScoreFactors? scoreFactors;

  bool get hasScoreFactors => scoreFactors != null;

  CaseDetail({
    this.id,
    this.report,
    this.verifikatorCase,
    this.assessments,
    this.visits,
    this.audit,
    this.status,
    this.caseData,
    this.scoreFactors,
  });

  factory CaseDetail.fromJson(Map<String, dynamic> json) {
    final caseJson = json['case'] as Map<String, dynamic>?;
    return CaseDetail(
      id: caseJson?['id']?.toString() ?? json['id']?.toString(),
      // Backwards-compat: map 'report' field from old API shape (json['report'])
      // for screens still using caseDetail.report. Real backend data is in caseData.
      report: json['report'] != null
          ? Report.fromJson(json['report'] as Map<String, dynamic>)
          : null,
      verifikatorCase: caseJson?['verifikator_case'] != null
          ? VerifikatorCase.fromJson(
              caseJson!['verifikator_case'] as Map<String, dynamic>,
            )
          : null,
      assessments: (json['assessments'] as List?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      // Backwards-compat: map 'visits' from old API shape or 'timeline' from real backend
      visits: (json['visits'] as List?) != null
          ? (json['visits'] as List)
                .map((e) => e as Map<String, dynamic>)
                .toList()
          : (json['timeline'] as List?)
                ?.map((e) => e as Map<String, dynamic>)
                .toList(),
      audit: (json['audit'] as List?)
          ?.map((e) => AuditEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: caseJson?['status']?.toString() ?? json['status']?.toString(),
      caseData: caseJson,
      scoreFactors: caseJson?['score_factors'] != null
          ? ScoreFactors.fromJson(
              caseJson!['score_factors'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'report': report?.toJson(),
    'verifikator_case': verifikatorCase?.toJson(),
    'assessments': assessments,
    'visits': visits,
    'audit': audit,
    'status': status,
    'score_factors': scoreFactors?.toJson(),
  };
}

class VerifikatorCase {
  final String? id;
  final String? reportId;
  final String? status;
  final String? verifikatorId;
  final String? decision;
  final String? notes;
  final String? createdAt;
  final String? updatedAt;
  VerifikatorCase({
    this.id,
    this.reportId,
    this.status,
    this.verifikatorId,
    this.decision,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory VerifikatorCase.fromJson(Map<String, dynamic> json) {
    return VerifikatorCase(
      id: json['id']?.toString(),
      reportId: json['report_id']?.toString(),
      status: json['status']?.toString(),
      verifikatorId: json['verifikator_id']?.toString(),
      decision: json['decision']?.toString(),
      notes: json['notes']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'report_id': reportId,
    'status': status,
    'verifikator_id': verifikatorId,
    'decision': decision,
    'notes': notes,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}

class SurveyorTask {
  final String? taskId;
  final String? reportId;
  final String? reportTitle;
  final String? status;
  final String? assignedAt;
  final String? completedAt;
  final String? deadline;
  final String? code;
  final double? slaHoursRemaining;
  final String? priority;
  final double? reportLat;
  final double? reportLng;
  final String? address;
  final String? categoryName;
  final String? surveyorId;
  final String? instructions;
  SurveyorTask({
    this.taskId,
    this.reportId,
    this.reportTitle,
    this.status,
    this.assignedAt,
    this.completedAt,
    this.deadline,
    this.code,
    this.slaHoursRemaining,
    this.priority,
    this.reportLat,
    this.reportLng,
    this.address,
    this.categoryName,
    this.surveyorId,
    this.instructions,
  });

  factory SurveyorTask.fromJson(Map<String, dynamic> json) {
    return SurveyorTask(
      taskId: json['id']?.toString(),
      reportId: json['report_id']?.toString(),
      reportTitle: json['report_description']?.toString(),
      status: json['status']?.toString(),
      assignedAt: json['accepted_at']?.toString(),
      completedAt: json['completed_at']?.toString(),
      deadline: json['deadline']?.toString(),
      code: json['code']?.toString(),
      slaHoursRemaining: (json['sla_hours_remaining'] as num?)?.toDouble(),
      priority: json['priority']?.toString(),
      reportLat: (json['lat'] as num?)?.toDouble(),
      reportLng: (json['lng'] as num?)?.toDouble(),
      address: json['address']?.toString(),
      categoryName: json['category_name']?.toString(),
      surveyorId: json['surveyor_id']?.toString(),
      instructions: json['instructions']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': taskId,
    'report_id': reportId,
    'report_description': reportTitle,
    'status': status,
    'accepted_at': assignedAt,
    'completed_at': completedAt,
    'deadline': deadline,
    'code': code,
    'sla_hours_remaining': slaHoursRemaining,
    'priority': priority,
    'lat': reportLat,
    'lng': reportLng,
    'address': address,
    'category_name': categoryName,
    'surveyor_id': surveyorId,
    'instructions': instructions,
  };
}

class PetugasTask {
  final String? taskId;
  final String? reportId;
  final String? reportTitle;
  final String? status;
  final List<String>? evidenceUrls;
  final String? assignedAt;
  final String? completedAt;
  PetugasTask({
    this.taskId,
    this.reportId,
    this.reportTitle,
    this.status,
    this.evidenceUrls,
    this.assignedAt,
    this.completedAt,
  });

  factory PetugasTask.fromJson(Map<String, dynamic> json) {
    return PetugasTask(
      taskId: json['id']?.toString(),
      reportId: json['report_id']?.toString(),
      reportTitle: json['report_description']?.toString(),
      status: json['status']?.toString(),
      evidenceUrls: (json['photo_urls'] as List?)
          ?.map((e) => e as String)
          .toList(),
      assignedAt: json['accepted_at']?.toString(),
      completedAt: json['completed_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': taskId,
    'report_id': reportId,
    'report_description': reportTitle,
    'status': status,
    'photo_urls': evidenceUrls,
    'accepted_at': assignedAt,
    'completed_at': completedAt,
  };
}

class TaskDetail {
  final String? taskId;
  final String? reportId;
  final String? reportTitle;
  final String? description;
  final String? status;
  final int? progress;
  final List<Map<String, dynamic>>? evidenceUrls;
  final List<Map<String, dynamic>>? clarification;
  final String? assignedAt;
  final String? completedAt;
  final String? uploadToken;
  TaskDetail({
    this.taskId,
    this.reportId,
    this.reportTitle,
    this.description,
    this.status,
    this.progress,
    this.evidenceUrls,
    this.clarification,
    this.assignedAt,
    this.completedAt,
    this.uploadToken,
  });

  factory TaskDetail.fromJson(Map<String, dynamic> json) {
    return TaskDetail(
      taskId: json['id']?.toString(),
      reportId: json['reportId']?.toString(),
      uploadToken: json['uploadToken']?.toString(),
      status: json['status']?.toString(),
      description: json['instructions']?.toString(),
      assignedAt: json['created_at']?.toString(),
      // The following fields are not present in GET /api/tasks/:id response;
      // they may be null — only reportId and uploadToken are required for the upload flow.
      reportTitle: null,
      progress: null,
      evidenceUrls: null,
      clarification: null,
      completedAt: null,
    );
  }

  Map<String, dynamic> toJson() => {
    'evidence': evidenceUrls,
    'clarifications': clarification,
  };
}

class StatsResponse {
  final int? total;
  final Map<String, dynamic>? byStatus;
  final List<Map<String, dynamic>>? byCategory;
  final int? activeTasks;
  final int? pendingTasks;
  final int? resolvedToday;
  final int? slaAtRisk;
  final int? slaBreached;
  final int? merged;
  final int? separated;
  final int? escalated;
  final String? operatorName;
  final String? region;
  final Map<String, dynamic>? dashboard;
  StatsResponse({
    this.total,
    this.byStatus,
    this.byCategory,
    this.activeTasks,
    this.pendingTasks,
    this.resolvedToday,
    this.slaAtRisk,
    this.slaBreached,
    this.merged,
    this.separated,
    this.escalated,
    this.operatorName,
    this.region,
    this.dashboard,
  });

  factory StatsResponse.fromJson(Map<String, dynamic> json) {
    return StatsResponse(
      total:
          json['totals']?['cases'] ??
          json['totals']?['reports'] ??
          json['total'] as int?,
      byStatus: json['by_status'] as Map<String, dynamic>?,
      byCategory: (json['by_category'] is List)
          ? (json['by_category'] as List)
                .map((e) => e as Map<String, dynamic>)
                .toList()
          : null,
      activeTasks:
          (json['queue_counts'] as Map<String, dynamic>?)?['needs_completion']
              as int?,
      pendingTasks:
          (json['queue_counts'] as Map<String, dynamic>?)?['needs_verification']
              as int?,
      resolvedToday:
          (json['by_status'] as Map<String, dynamic>?)?['resolved'] as int?,
      slaAtRisk: json['sla_at_risk'] as int?,
      slaBreached: json['sla_breached'] as int?,
      merged: json['merged'] as int?,
      separated: json['separated'] as int?,
      escalated: json['escalated'] as int?,
      operatorName: json['operator_name']?.toString(),
      region: json['region']?.toString(),
      dashboard: json['dashboard'] as Map<String, dynamic>?,
    );
  }

  // Getters for warga stats (read from byStatus map)
  int? get submitted => byStatus?['submitted'] as int?;
  int? get verified => byStatus?['verified'] as int?;
  int? get inProgress => byStatus?['in_progress'] as int?;
  int? get resolved => byStatus?['resolved'] as int?;

  Map<String, dynamic> toJson() => {
    'total': total,
    'by_status': byStatus,
    'by_category': byCategory,
    'sla_at_risk': slaAtRisk,
    'sla_breached': slaBreached,
    'merged': merged,
    'separated': separated,
    'escalated': escalated,
    'operator_name': operatorName,
    'region': region,
    'dashboard': dashboard,
  };
}

// ─── Additional types ─────────────────────────────────────────────────────────

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
    final districtObj = json['district'] as Map<String, dynamic>?;
    final subdistrictObj = json['subdistrict'] as Map<String, dynamic>?;
    final provinceObj = json['province'] as Map<String, dynamic>?;
    final villageObj = json['village'] as Map<String, dynamic>?;
    return GeocodeResult(
      address: json['address'] as String?,
      district: districtObj?['name'] as String?,
      city: districtObj?['name'] as String?,
      village: villageObj?['name'] as String?,
      subdistrict: subdistrictObj?['name'] as String?,
      province: provinceObj?['name'] as String?,
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
      events: (json['events'] as List?)
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
  final String? username;
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

  factory WargaProfile.fromJson(Map<String, dynamic> json) {
    return WargaProfile(
      id: json['id'] as String?,
      username: json['username'] as String?,
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
      total: json['stats']?['total'] ?? json['total'] as int?,
      byStatus: json['by_status'] as Map<String, dynamic>?,
      byCategory: (json['by_category'] is List)
          ? (json['by_category'] as List)
                .map((e) => e as Map<String, dynamic>)
                .toList()
          : null,
      recentReports7d: json['recent_reports_7d'] as int?,
      resolutionRate7d: (json['resolution_rate_7d'] as num?)?.toDouble(),
    );
  }
}

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
      byCategory: (json['by_category'] is List)
          ? (json['by_category'] as List)
                .map((e) => e as Map<String, dynamic>)
                .toList()
          : null,
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
  final String? id;
  final String? reportId;
  final String? agentType;
  final double? confidence;
  final String? modelVersion;
  final String? status;
  final String? createdAt;
  final AssessmentResultData? resultData;
  AiAssessmentResult({
    this.id,
    this.reportId,
    this.agentType,
    this.confidence,
    this.modelVersion,
    this.status,
    this.createdAt,
    this.resultData,
  });

  // Backward-compatible getters derived from resultData
  double? get confidenceScore => resultData?.confidence ?? confidence;
  String? get visionDescription => resultData?.visionDescription;
  String? get damageSeverity => resultData?.damageSeverity;
  List<String>? get supportingFactors {
    final desc = resultData?.visionDescription;
    return desc != null ? [desc] : null;
  }

  List<String>? get riskFactors => null;
  List<DuplicateCandidate>? get duplicateCandidates {
    final candidates = resultData?.duplicateCandidates;
    if (candidates == null) return null;
    return candidates.map((id) => DuplicateCandidate(reportId: id)).toList();
  }

  factory AiAssessmentResult.fromAssessmentJson(Map<String, dynamic> json) {
    final resultStr = json['result'] as String?;
    AssessmentResultData? resultData;
    if (resultStr != null) {
      try {
        final parsed = jsonDecode(resultStr) as Map<String, dynamic>;
        List<String>? duplicateCandidates;
        if (parsed['duplicate_candidates'] != null) {
          duplicateCandidates = (parsed['duplicate_candidates'] as List)
              .map((e) => e.toString())
              .toList();
        }
        resultData = AssessmentResultData(
          visionDescription: parsed['vision_description'] as String?,
          damageSeverity: parsed['damage_severity'] as String?,
          confidence: (parsed['confidence'] as num?)?.toDouble(),
          duplicateCandidates: duplicateCandidates,
          recommendedStatus: parsed['recommended_status'] as String?,
          modelVersion: parsed['model_version'] as String?,
          assessmentVersion: parsed['assessment_version'] as String?,
        );
      } catch (_) {}
    }
    return AiAssessmentResult(
      id: json['id']?.toString(),
      reportId: json['report_id']?.toString(),
      agentType: json['agent_type']?.toString(),
      confidence: (json['confidence'] as num?)?.toDouble(),
      modelVersion: json['model_version']?.toString(),
      status: json['status']?.toString(),
      createdAt: json['created_at']?.toString(),
      resultData: resultData,
    );
  }
}

class AssessmentResultData {
  final String? visionDescription;
  final String? damageSeverity;
  final double? confidence;
  final List<String>? duplicateCandidates;
  final String? recommendedStatus;
  final String? modelVersion;
  final String? assessmentVersion;
  AssessmentResultData({
    this.visionDescription,
    this.damageSeverity,
    this.confidence,
    this.duplicateCandidates,
    this.recommendedStatus,
    this.modelVersion,
    this.assessmentVersion,
  });
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

// ─── Pagination wrapper classes ────────────────────────────────────────────────

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
  List<Notification> get data => entries;
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

// ─── API Client ─────────────────────────────────────────────────────────────

class ApiClient {
  final Dio _dio;
  final Dio _publicDio;
  final Future<void> Function()? _checkConnectivityFn;
  final AppLocalizations? _l10n;

  ApiClient({
    String? baseUrl,
    FlutterSecureStorage? storage,
    Future<void> Function()? onLogout,
    Dio? dio,
    Future<void> Function()? checkConnectivity,
    String? testAccessToken,
    Future<String?> Function(String role)? authTokenProvider,
    AppLocalizations? l10n,

    /// Optional callback invoked when the server returns 403 cap_stale.
    /// The interceptor calls this to mark capabilities as stale before refetch.
    Future<void> Function()? onCapabilitiesStale,
  }) : _l10n = l10n,
       _dio =
           dio ??
           Dio(
             BaseOptions(
               baseUrl: baseUrl ?? ApiConfig.baseUrl,
               connectTimeout: const Duration(seconds: 10),
               receiveTimeout: const Duration(seconds: 30),
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
           validateStatus: (int? status) =>
               status != null && (status < 400 || status == 503),
         ),
       ) {
    if (baseUrl != null && dio != null) {
      _dio.options.baseUrl = baseUrl;
      _publicDio.options.baseUrl = baseUrl;
    }
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
          onCapabilitiesStale: onCapabilitiesStale,
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
      throw NetworkException();
    }
  }

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
            throw NetworkException(
              _l10n?.tidakDapatTerhubungKeServer ?? 'Cannot connect to server.',
            );
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
              body: e.message ?? (_l10n?.errorTidakDikenal ?? 'Unknown error'),
              endpoint: endpoint,
              userMessage: '$userMessage [$endpoint]',
            );
        }
      }
    }
    throw lastError ??
        Exception(_l10n?.gagalRetryLoop ?? 'Unexpected retry loop exit');
  }

  // ─── Auth ─────────────────────────────────────────────────────────────────

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

  Future<LoginResponse> refresh(String refreshToken) async {
    return await _execute<LoginResponse>(
      dioCall: () => _dio.post(
        '/api/auth/refresh',
        data: {'refresh_token': refreshToken},
        options: Options(contentType: 'application/json'),
      ),
      endpoint: '/api/auth/refresh',
      parse: (data) =>
          LoginResponse.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  Future<UserResponse> me() async {
    return await _execute<UserResponse>(
      dioCall: () => _dio.get('/api/auth/me'),
      endpoint: '/api/auth/me',
      parse: (data) =>
          UserResponse.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  Future<CapabilitiesResponse> getCapabilities() async {
    return await _execute<CapabilitiesResponse>(
      dioCall: () => _dio.get('/api/auth/capabilities'),
      endpoint: '/api/auth/capabilities',
      parse: (data) =>
          CapabilitiesResponse.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  Future<void> logout(String refreshToken) async {
    await _execute<void>(
      dioCall: () =>
          _dio.post('/api/auth/logout', data: {'refresh_token': refreshToken}),
      endpoint: '/api/auth/logout',
      parse: (_) {},
    );
  }

  Future<UserResponse> register({
    required String email,
    required String password,
    required String name,
    String? wilayahId,
  }) async {
    return await _execute<UserResponse>(
      dioCall: () => _dio.post(
        '/api/auth/register',
        data: {
          'email': email,
          'password': password,
          'name': name,
          if (wilayahId != null) 'wilayah_id': wilayahId,
        },
        options: Options(contentType: 'application/json'),
      ),
      endpoint: '/api/auth/register',
      parse: (data) =>
          UserResponse.fromJson({'user': data as Map<String, dynamic>}),
    );
  }

  // ─── Categories ─────────────────────────────────────────────────────────────

  Future<List<Category>> getCategories() async {
    final data = _expectListKey(
      await _execute<Map<String, dynamic>>(
        dioCall: () => _dio.get('/api/categories'),
        endpoint: '/api/categories',
        parse: (data) => (data as Map).cast<String, dynamic>(),
      ),
      'data',
    );
    return data
        .map((e) => Category.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }

  // ─── Public Endpoints (no auth required) ─────────────────────────────────

  /// Fetches public report list — no auth token needed.
  /// Returns reports with no PII (reporter info excluded).
  Future<PublicReportsPage> getPublicReports({
    String? status,
    String? categoryId,
    int limit = 100,
  }) async {
    // Use _publicDio directly to avoid auth interceptor.
    // Retry loop with connectivity check is still applied.
    await _checkConnectivity();
    final backoffs = [
      const Duration(seconds: 2),
      const Duration(seconds: 4),
      const Duration(seconds: 6),
    ];
    Object? lastError;
    for (var attempt = 0; attempt <= 3; attempt++) {
      try {
        final res = await _publicDio.get(
          '/api/public/reports',
          queryParameters: {
            'limit': limit,
            if (status != null) 'status': status,
            if (categoryId != null) 'category_id': categoryId,
          },
        );
        final sc = res.statusCode ?? 0;
        if (sc >= 400) {
          throw ApiException(
            statusCode: sc,
            body: res.data?.toString(),
            endpoint: '/api/public/reports',
            userMessage:
                _l10n?.gagalMemuatLaporanPublik ??
                'Failed to fetch public reports',
          );
        }
        final data = res.data as Map<String, dynamic>;
        final reportsList = data['data'] as List? ?? [];
        final pagination = data['pagination'] as Map<String, dynamic>?;
        return PublicReportsPage(
          items: reportsList
              .map((e) => PublicReportItem.fromJson(e as Map<String, dynamic>))
              .toList(),
          total: (pagination?['total'] as num?)?.toInt() ?? reportsList.length,
          page: 1,
          limit: limit,
        );
      } on DioException catch (e) {
        final statusCode = e.response?.statusCode;
        final retryable = statusCode == 503;
        if (retryable && attempt < 3) {
          lastError = e;
          await Future.delayed(backoffs[attempt]);
          continue;
        }
        if (attempt >= 3 && lastError != null) throw lastError;
        switch (e.type) {
          case DioExceptionType.connectionError:
          case DioExceptionType.connectionTimeout:
            throw NetworkException(
              _l10n?.tidakDapatTerhubungKeServer ?? 'Cannot connect to server.',
            );
          case DioExceptionType.sendTimeout:
          case DioExceptionType.receiveTimeout:
            throw TimeoutException(
              const Duration(seconds: 30),
              '/api/public/reports',
            );
          default:
            throw ApiException(
              statusCode: e.response?.statusCode ?? 0,
              body: e.message ?? (_l10n?.errorTidakDikenal ?? 'Unknown error'),
              endpoint: '/api/public/reports',
              userMessage: '${extractErrorMessage(e)} [/api/public/reports]',
            );
        }
      }
    }
    throw lastError ??
        Exception(_l10n?.gagalRetryLoop ?? 'Unexpected retry loop exit');
  }

  /// Fetches a single public case by ID — no auth required.
  /// Returns case data with no reporter PII.
  Future<Map<String, dynamic>> getPublicCase(String id) async {
    await _checkConnectivity();
    final backoffs = [
      const Duration(seconds: 2),
      const Duration(seconds: 4),
      const Duration(seconds: 6),
    ];
    Object? lastError;
    for (var attempt = 0; attempt <= 3; attempt++) {
      try {
        final res = await _publicDio.get('/api/public/cases/$id');
        final sc = res.statusCode ?? 0;
        if (sc >= 400) {
          throw ApiException(
            statusCode: sc,
            body: res.data?.toString(),
            endpoint: '/api/public/cases/$id',
            userMessage:
                _l10n?.gagalMemuatKasusPublik ?? 'Failed to fetch public case',
          );
        }
        return res.data as Map<String, dynamic>;
      } on DioException catch (e) {
        final statusCode = e.response?.statusCode;
        final retryable = statusCode == 503;
        if (retryable && attempt < 3) {
          lastError = e;
          await Future.delayed(backoffs[attempt]);
          continue;
        }
        if (attempt >= 3 && lastError != null) throw lastError;
        switch (e.type) {
          case DioExceptionType.connectionError:
          case DioExceptionType.connectionTimeout:
            throw NetworkException(
              _l10n?.tidakDapatTerhubungKeServer ?? 'Cannot connect to server.',
            );
          case DioExceptionType.sendTimeout:
          case DioExceptionType.receiveTimeout:
            throw TimeoutException(
              const Duration(seconds: 30),
              '/api/public/cases/$id',
            );
          default:
            throw ApiException(
              statusCode: e.response?.statusCode ?? 0,
              body: e.message ?? (_l10n?.errorTidakDikenal ?? 'Unknown error'),
              endpoint: '/api/public/cases/$id',
              userMessage: '${extractErrorMessage(e)} [/api/public/cases/$id]',
            );
        }
      }
    }
    throw lastError ??
        Exception(_l10n?.gagalRetryLoop ?? 'Unexpected retry loop exit');
  }

  /// Fetches public stats — no auth required.
  Future<PublicStats> getPublicStats({String? wilayah, String? period}) async {
    await _checkConnectivity();
    final backoffs = [
      const Duration(seconds: 2),
      const Duration(seconds: 4),
      const Duration(seconds: 6),
    ];
    Object? lastError;
    for (var attempt = 0; attempt <= 3; attempt++) {
      try {
        final res = await _publicDio.get(
          '/api/public/stats',
          queryParameters: {
            if (wilayah != null) 'wilayah': wilayah,
            if (period != null) 'period': period,
          },
        );
        final sc = res.statusCode ?? 0;
        if (sc >= 400) {
          throw ApiException(
            statusCode: sc,
            body: res.data?.toString(),
            endpoint: '/api/public/stats',
            userMessage:
                _l10n?.gagalMemuatStatistikPublik ??
                'Failed to fetch public stats',
          );
        }
        final data = res.data as Map<String, dynamic>;
        return PublicStats(
          total: data['total'] as int?,
          byStatus: data['by_status'] as Map<String, dynamic>?,
          byCategory: (data['by_category'] is List)
              ? (data['by_category'] as List)
                    .map((e) => e as Map<String, dynamic>)
                    .toList()
              : null,
          recentReports7d: data['recent_reports_7d'] as int?,
          resolutionRate7d: (data['resolution_rate_7d'] as num?)?.toDouble(),
        );
      } on DioException catch (e) {
        final statusCode = e.response?.statusCode;
        final retryable = statusCode == 503;
        if (retryable && attempt < 3) {
          lastError = e;
          await Future.delayed(backoffs[attempt]);
          continue;
        }
        if (attempt >= 3 && lastError != null) throw lastError;
        switch (e.type) {
          case DioExceptionType.connectionError:
          case DioExceptionType.connectionTimeout:
            throw NetworkException(
              _l10n?.tidakDapatTerhubungKeServer ?? 'Cannot connect to server.',
            );
          case DioExceptionType.sendTimeout:
          case DioExceptionType.receiveTimeout:
            throw TimeoutException(
              const Duration(seconds: 30),
              '/api/public/stats',
            );
          default:
            throw ApiException(
              statusCode: e.response?.statusCode ?? 0,
              body: e.message ?? (_l10n?.errorTidakDikenal ?? 'Unknown error'),
              endpoint: '/api/public/stats',
              userMessage: '${extractErrorMessage(e)} [/api/public/stats]',
            );
        }
      }
    }
    throw lastError ??
        Exception(_l10n?.gagalRetryLoop ?? 'Unexpected retry loop exit');
  }

  /// Fetches OG meta for sharing a case — no auth required.
  Future<ShareMetadata> getShareMetadata(String caseId) async {
    await _checkConnectivity();
    final backoffs = [
      const Duration(seconds: 2),
      const Duration(seconds: 4),
      const Duration(seconds: 6),
    ];
    Object? lastError;
    for (var attempt = 0; attempt <= 3; attempt++) {
      try {
        final res = await _publicDio.get('/api/public/cases/$caseId/share');
        final sc = res.statusCode ?? 0;
        if (sc >= 400) {
          throw ApiException(
            statusCode: sc,
            body: res.data?.toString(),
            endpoint: '/api/public/cases/$caseId/share',
            userMessage:
                _l10n?.gagalMemuatMetadataBagikan ??
                'Failed to fetch share metadata',
          );
        }
        final data = res.data as Map<String, dynamic>;
        return ShareMetadata.fromJson(data);
      } on DioException catch (e) {
        final statusCode = e.response?.statusCode;
        final retryable = statusCode == 503;
        if (retryable && attempt < 3) {
          lastError = e;
          await Future.delayed(backoffs[attempt]);
          continue;
        }
        if (attempt >= 3 && lastError != null) throw lastError;
        switch (e.type) {
          case DioExceptionType.connectionError:
          case DioExceptionType.connectionTimeout:
            throw NetworkException(
              _l10n?.tidakDapatTerhubungKeServer ?? 'Cannot connect to server.',
            );
          case DioExceptionType.sendTimeout:
          case DioExceptionType.receiveTimeout:
            throw TimeoutException(
              const Duration(seconds: 30),
              '/api/public/cases/$caseId/share',
            );
          default:
            throw ApiException(
              statusCode: e.response?.statusCode ?? 0,
              body: e.message ?? (_l10n?.errorTidakDikenal ?? 'Unknown error'),
              endpoint: '/api/public/cases/$caseId/share',
              userMessage:
                  '${extractErrorMessage(e)} [/api/public/cases/$caseId/share]',
            );
        }
      }
    }
    throw lastError ??
        Exception(_l10n?.gagalRetryLoop ?? 'Unexpected retry loop exit');
  }

  // ─── Reports ───────────────────────────────────────────────────────────────

  Future<Report> getReportById(String id) async {
    return await _execute<Report>(
      dioCall: () => _dio.get('/api/reports/$id'),
      endpoint: '/api/reports/$id',
      parse: (data) => Report.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  Future<PaginatedReports> getReports({
    String? status,
    String? categoryId,
    String? cursor,
    int limit = 50,
    String? q,
    String? wilayahId,
    String? creatorId,
  }) async {
    return await _execute<PaginatedReports>(
      dioCall: () => _dio.get(
        '/api/reports',
        queryParameters: {
          'limit': limit,
          if (status != null) 'status': status,
          if (categoryId != null) 'category_id': categoryId,
          if (cursor != null) 'cursor': cursor,
          if (q != null) 'q': q,
          if (wilayahId != null) 'wilayah_id': wilayahId,
          if (creatorId != null) 'creator_id': creatorId,
        },
      ),
      endpoint: '/api/reports',
      parse: (data) =>
          PaginatedReports.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  /// Unified report submission for both authenticated (warga) and anonymous reporters.
  /// Uses _dio (optional-auth client) — token is attached only if user is logged in;
  /// otherwise the request is sent without auth and backend treats it as anonymous.
  ///
  /// Photos must be uploaded BEFORE calling this method via [uploadReportPhotoAnon]
  /// or [uploadReportPhoto]. Pass the returned public URLs in [photoUrls].
  Future<SubmitReportResult> submitReport({
    required String idempotencyKey,
    required String categoryId,
    required String description,
    required double lat,
    required double lng,
    String? deviceId,
    String? title,
    List<String>? photoUrls,
    String? captchaToken,
    int? populationAffected,
    double? vulnerabilityIndex,
    List<String>? impactDampak,
    bool anonymous = false,
  }) async {
    if (anonymous) {
      // Anonymous: POST /api/public/anonymous-reports
      return await _execute<SubmitReportResult>(
        dioCall: () => _dio.post(
          '/api/public/anonymous-reports',
          data: {
            'idempotency_key': idempotencyKey,
            'category_id': categoryId,
            'description': description,
            'lat': lat,
            'lng': lng,
            if (deviceId != null) 'device_id': deviceId,
            if (title != null) 'title': title,
            if (photoUrls != null && photoUrls.isNotEmpty) 'photos': photoUrls,
            if (populationAffected != null)
              'population_affected': populationAffected,
            if (vulnerabilityIndex != null)
              'vulnerability_index': vulnerabilityIndex,
            if (captchaToken != null) 'captcha_token': captchaToken,
          },
        ),
        endpoint: '/api/public/anonymous-reports',
        parse: (data) =>
            SubmitReportResult.fromJson((data as Map).cast<String, dynamic>()),
      );
    } else {
      // Authenticated: POST /api/reports
      return await _execute<SubmitReportResult>(
        dioCall: () => _dio.post(
          '/api/reports',
          data: {
            'idempotency_key': idempotencyKey,
            'category_id': categoryId,
            'description': description,
            'lat': lat,
            'lng': lng,
            if (title != null) 'title': title,
            if (photoUrls != null && photoUrls.isNotEmpty)
              'photo_urls': photoUrls,
            if (populationAffected != null)
              'population_affected': populationAffected,
            if (vulnerabilityIndex != null)
              'vulnerability_index': vulnerabilityIndex,
            if (impactDampak != null) 'impact_dampak': impactDampak,
          },
        ),
        endpoint: '/api/reports',
        parse: (data) =>
            SubmitReportResult.fromJson((data as Map).cast<String, dynamic>()),
      );
    }
  }

  /// Uploads a photo for anonymous report creation via FormData.
  /// Calls POST /api/reports/photos/upload-url-anon with multipart form data.
  /// Returns the public R2 URL of the uploaded photo.
  Future<String> uploadReportPhotoAnon(
    String filePath,
    String idempotencyKey, {
    int slot = 0,
  }) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw ApiException(
        statusCode: 404,
        endpoint: filePath,
        userMessage:
            '${_l10n?.fileFotoTidakDitemukan ?? 'Photo file not found'}: $filePath',
      );
    }

    final fileName = filePath.split(Platform.pathSeparator).last;
    final formData = FormData.fromMap({
      'photo': await MultipartFile.fromFile(filePath, filename: fileName),
      'idempotency_key': idempotencyKey,
    });

    final res = await _dio.post<Map<String, dynamic>>(
      '/api/reports/photos/upload-url-anon',
      data: formData,
    );

    final data = res.data;
    if (data == null || data['public_url'] == null) {
      throw ApiException(
        statusCode: 500,
        endpoint: '/api/reports/photos/upload-url-anon',
        userMessage:
            _l10n?.uploadFotoGagalUrl ?? 'Photo upload failed: no URL returned',
      );
    }

    return data['public_url'] as String;
  }

  Future<ReportActionResponse> reportAction({
    required String reportId,
    required String action,
    String? note,
  }) async {
    // Dispatch action to the specific backend sub-route
    String endpoint;
    Map<String, dynamic> body;

    switch (action) {
      case 'sanggah':
        endpoint = '/api/reports/$reportId/sanggahan';
        body = {'reason': note ?? ''};
        break;
      case 'lengkapi':
        // lengkapi (add evidence) — submit via evidence endpoint
        endpoint = '/api/reports/$reportId/evidence';
        body = {'description': note ?? ''};
        break;
      case 'reopen':
        endpoint = '/api/reports/$reportId/reopen';
        body = {'reason': note ?? ''};
        break;
      default:
        // Unknown action — best-effort fallback
        endpoint = '/api/reports/$reportId/sanggahan';
        body = {'reason': note ?? action};
    }

    return await _execute<ReportActionResponse>(
      dioCall: () => _dio.post(
        endpoint,
        data: body,
        options: Options(contentType: 'application/json'),
      ),
      endpoint: endpoint,
      parse: (data) =>
          ReportActionResponse.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  Future<PhotoUploadUrlResponse> getPhotoUploadUrl(
    String reportId,
    String uploadToken, {
    int slot = 0,
  }) async {
    return await _execute<PhotoUploadUrlResponse>(
      dioCall: () => _dio.post(
        '/api/reports/$reportId/photos',
        queryParameters: {'uploadToken': uploadToken, 'slot': slot},
      ),
      endpoint: '/api/reports/$reportId/photos',
      parse: (data) => PhotoUploadUrlResponse.fromJson(
        (data as Map).cast<String, dynamic>(),
      ),
    );
  }

  Future<PhotoPutResponse> putPhoto({
    required String reportId,
    required String putUrl,
    required Uint8List bytes,
    required String contentType,
  }) async {
    final putDio = Dio();
    final res = await putDio.put(
      putUrl,
      data: Stream.fromIterable([bytes]),
      options: Options(
        headers: {'Content-Type': contentType, 'Content-Length': bytes.length},
      ),
    );
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw ApiException(
        statusCode: res.statusCode ?? 0,
        endpoint: putUrl,
        userMessage: _l10n?.uploadFotoGagal ?? 'Photo upload failed',
      );
    }
    return PhotoPutResponse.fromJson((res.data as Map).cast<String, dynamic>());
  }

  /// Uploads a photo for an existing report using the presigned URL flow.
  /// Requires authentication.
  /// Calls POST /api/reports/:id/photos?uploadToken=... to get presigned URL, then PUTs the bytes.
  Future<PhotoUploadResult> uploadReportPhoto(
    String reportId,
    String filePath,
    String uploadToken, {
    int slot = 0,
  }) async {
    // Get presigned upload URL
    final uploadUrlResp = await getPhotoUploadUrl(
      reportId,
      uploadToken,
      slot: slot,
    );

    // Read file bytes
    final file = File(filePath);
    if (!await file.exists()) {
      throw ApiException(
        statusCode: 404,
        endpoint: filePath,
        userMessage:
            '${_l10n?.fileFotoTidakDitemukan ?? 'Photo file not found'}: $filePath',
      );
    }
    final bytes = await file.readAsBytes();

    // Upload to R2 via presigned URL
    final putResp = await putPhoto(
      reportId: reportId,
      putUrl: uploadUrlResp.putUrl ?? '',
      bytes: bytes,
      contentType: 'image/jpeg',
    );

    return PhotoUploadResult(
      publicUrl: putResp.photoUrls.isNotEmpty ? putResp.photoUrls.first : null,
    );
  }

  // ─── Agent/AI Assessment ─────────────────────────────────────────────────

  /// Fetches AI assessment results for a report from GET /api/reports/:id.
  /// Returns a list of assessments (VISION, etc.) with parsed result data.
  Future<List<AiAssessmentResult>> getAiAssessment(String reportId) async {
    final res = await _dio.get<Map<String, dynamic>>('/api/reports/$reportId');
    final data = res.data as Map<String, dynamic>;
    final assessments = data['assessments'] as List? ?? [];
    return assessments
        .map(
          (a) =>
              AiAssessmentResult.fromAssessmentJson(a as Map<String, dynamic>),
        )
        .toList();
  }

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

  // ─── Warga Reports ────────────────────────────────────────────────────────

  Future<WargaReportsPage> getMyReports() async {
    // Pass creator_id=me so backend filters by reporter_id (not just wilayah_id)
    final paginatedReports = await getReports(limit: 100, creatorId: 'me');
    return WargaReportsPage(items: paginatedReports.data);
  }

  Future<TimelineEnvelope> getReportTimeline(String reportId) async {
    // Call GET /api/reports/:id and extract timeline from response
    final res = await _dio.get<Map<String, dynamic>>('/api/reports/$reportId');
    final data = res.data as Map<String, dynamic>;
    // Extract timeline events if present in response
    final timelineData = data['timeline'] as Map<String, dynamic>?;
    if (timelineData != null) {
      return TimelineEnvelope.fromJson(timelineData);
    }
    return TimelineEnvelope(events: []);
  }

  /// Fetches priority data for a report from GET /api/reports/:id/priority.
  Future<PriorityResponse?> getReportPriority(String reportId) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '/api/reports/$reportId/priority',
      );
      final data = res.data;
      if (data == null) return null;
      return PriorityResponse.fromJson(data);
    } on DioException catch (e) {
      // 404 means no priority computed yet — return null gracefully
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  /// Fetches AI assessment entries for a report
  /// from GET /api/agent/assessments/:reportId.
  Future<List<AgentAssessmentEntry>> getReportAssessments(
    String reportId,
  ) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '/api/agent/assessments/$reportId',
      );
      final data = res.data;
      if (data == null) return [];
      final list = data['assessments'] as List? ?? [];
      return list
          .map((e) => AgentAssessmentEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return [];
      rethrow;
    }
  }

  /// Fetches audit trail entries for a report
  /// from GET /api/auditor/audit-search?object_id={reportId}.
  Future<List<AuditEntry>> getReportAudit(String reportId) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '/api/auditor/audit-search',
        queryParameters: {'object_id': reportId, 'limit': 50},
      );
      final data = res.data;
      if (data == null) return [];
      final list = data['entries'] as List? ?? data['data'] as List? ?? [];
      return list
          .map((e) => AuditEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return [];
      rethrow;
    }
  }

  // ─── Nearby Reports (with client-side haversine distance) ───────────────

  /// Fetches reports from GET /api/reports and computes haversine distance
  /// client-side, returning the nearest [limit] reports sorted by distance.
  Future<List<NearbyReport>> getNearbyReports({
    required double lat,
    required double lng,
    int limit = 10,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/api/reports',
      queryParameters: {'limit': 100},
    );
    final data = res.data as Map<String, dynamic>;
    final items = data['data'] as List? ?? [];

    double haversineDistance(double lat2, double lng2) {
      const double R = 6371000.0; // meters
      final dLat = (lat2 - lat) * math.pi / 180;
      final dLng = (lng2 - lng) * math.pi / 180;
      final a =
          math.sin(dLat / 2) * math.sin(dLat / 2) +
          math.cos(lat * math.pi / 180) *
              math.cos(lat2 * math.pi / 180) *
              math.sin(dLng / 2) *
              math.sin(dLng / 2);
      final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
      return R * c;
    }

    final withDistance = items.map((item) {
      final lat2 = (item['lat'] as num?)?.toDouble() ?? 0;
      final lng2 = (item['lng'] as num?)?.toDouble() ?? 0;
      final dist = haversineDistance(lat2, lng2);
      return NearbyReport(
        id: item['id']?.toString(),
        title: item['description']?.toString(),
        category: item['category_name']?.toString(),
        status: item['status']?.toString(),
        location: item['location'] as Map<String, dynamic>?,
        distance: dist,
      );
    }).toList();

    withDistance.sort((a, b) => (a.distance ?? 0).compareTo(b.distance ?? 0));
    return withDistance.take(limit).toList();
  }

  /// Fetches similar report candidates from GET /api/reports/duplicates.
  /// Used during report creation (M-11) to suggest attaching to existing cases.
  Future<List<SimilarReport>> getSimilarReports({
    required double lat,
    required double lng,
    required String categoryId,
    int limit = 10,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/api/reports/duplicates',
      queryParameters: {
        'lat': lat,
        'lng': lng,
        'category_id': categoryId,
        'limit': limit,
      },
    );
    final data = res.data as Map<String, dynamic>;
    final items = data['data'] as List? ?? [];
    return items
        .map((item) => SimilarReport.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Extracts duplicate case candidates from GET /api/reports/:id assessment
  /// results. Parses assessments[].risk JSON to find duplicate_candidates.
  Future<List<DuplicateCandidate>> getDuplicateCases(String reportId) async {
    final res = await _dio.get<Map<String, dynamic>>('/api/reports/$reportId');
    final data = res.data as Map<String, dynamic>;
    final assessments = data['assessments'] as List? ?? [];

    final candidates = <DuplicateCandidate>[];
    for (final a in assessments) {
      final riskStr = (a as Map<String, dynamic>)['risk'] as String?;
      if (riskStr == null) continue;
      try {
        final riskJson = jsonDecode(riskStr) as Map<String, dynamic>;
        final dupList = riskJson['duplicate_candidates'] as List?;
        if (dupList == null) continue;
        for (final item in dupList) {
          if (item is String) {
            candidates.add(DuplicateCandidate(reportId: item));
          } else if (item is Map<String, dynamic>) {
            candidates.add(DuplicateCandidate.fromJson(item));
          }
        }
      } catch (_) {
        // skip malformed risk JSON
      }
    }
    return candidates;
  }

  // ─── Cases (Verifikator) ────────────────────────────────────────────────

  Future<CaseDetail> getCaseDetail(String caseId) async {
    return await _execute<CaseDetail>(
      dioCall: () => _dio.get('/api/cases/$caseId'),
      endpoint: '/api/cases/$caseId',
      parse: (data) =>
          CaseDetail.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  Future<DecideResult> decideCase({
    required String activeRole,
    required String caseId,
    required String decision,
    required String reason,
    String? duplicateOfReportId,
    String? surveyorId,
    String? assignedUnitId,
    String? deadline,
  }) async {
    // Dispatch directly to the specific decide endpoint
    final response = await _execute<Map<String, dynamic>>(
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
        options: Options(contentType: 'application/json'),
      ),
      endpoint: '/api/cases/$caseId/decide',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
    return DecideResult(
      caseId: caseId,
      decision: decision,
      status: response['status']?.toString(),
    );
  }

  // ─── Case Actions (dispatched to specific sub-routes) ─────────────────────

  Future<CaseActionResponse> caseAction({
    required String caseId,
    required String action,
    String? note,
    String? unitId,
    int? score,
    String? scoreReason,
    String? intoCaseId,
  }) async {
    // Dispatch action to the specific backend sub-route
    String endpoint;
    Map<String, dynamic> body;

    switch (action) {
      case 'accept':
      case 'verify':
        endpoint = '/api/cases/$caseId/accept';
        body = {
          if (note != null) 'reason': note,
          if (unitId != null) 'assigned_unit_id': unitId,
        };
        break;
      case 'reject':
        endpoint = '/api/cases/$caseId/reject';
        body = {'reason': note ?? ''};
        break;
      case 'combine':
      case 'merge':
        endpoint = '/api/cases/$caseId/combine';
        body = {
          if (intoCaseId != null) 'target_case_id': intoCaseId,
          if (note != null) 'reason': note,
        };
        break;
      case 'separate':
      case 'split':
        endpoint = '/api/cases/$caseId/separate';
        body = {
          'new_case_description': note ?? '',
          if (note != null) 'reason': note,
        };
        break;
      case 'request_info':
        endpoint = '/api/cases/$caseId/decide';
        body = {'decision': 'needs_clarification', 'reason': note ?? ''};
        break;
      case 'prioritize':
        endpoint = '/api/cases/$caseId/override-priority';
        body = {
          if (score != null) 'override_score': score,
          'reason': scoreReason ?? '',
        };
        break;
      case 'review-sanggahan':
        endpoint = '/api/cases/$caseId/review-sanggahan';
        body = {
          'decision': note ?? 'accepted',
          if (note != null) 'reason': note,
        };
        break;
      case 'verify-completion':
        endpoint = '/api/cases/$caseId/verify-completion';
        body = {'decision': 'approved', if (note != null) 'reason': note};
        break;
      case 'dispatch':
      case 'assign':
        // Operator dispatches case to a technical unit.
        // Web SPA uses POST /reports/:id/assign
        endpoint = '/api/reports/$caseId/assign';
        body = {
          if (unitId != null) 'assigned_unit_id': unitId,
          if (note != null) 'instructions': note,
        };
        break;
      default:
        // Unknown action — fall through to accept endpoint as legacy fallback
        endpoint = '/api/cases/$caseId/accept';
        body = {if (note != null) 'reason': note};
    }

    return await _execute<CaseActionResponse>(
      dioCall: () => _dio.post(
        endpoint,
        data: body,
        options: Options(contentType: 'application/json'),
      ),
      endpoint: endpoint,
      parse: (data) =>
          CaseActionResponse.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  // ─── Tasks ───────────────────────────────────────────────────────────────

  Future<TaskListPage<PetugasTask>> getTasks() async {
    final data = await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.get('/api/tasks'),
      endpoint: '/api/tasks',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
    List<dynamic> tasksList = [];
    final rawTasks = data['tasks'];
    if (rawTasks is List) tasksList = rawTasks;
    final paginationData = data['pagination'] as Map<String, dynamic>?;
    return TaskListPage<PetugasTask>(
      tasks: tasksList
          .map((e) => PetugasTask.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
      pagination: paginationData != null
          ? Pagination.fromJson(paginationData)
          : Pagination(page: 1, limit: 20, total: 0),
    );
  }

  Future<TaskDetail> getTaskDetail(String taskId) async {
    return await _execute<TaskDetail>(
      dioCall: () => _dio.get('/api/tasks/$taskId'),
      endpoint: '/api/tasks/$taskId',
      parse: (data) =>
          TaskDetail.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  Future<ChecklistTemplate> getTaskChecklistTemplate(String taskId) async {
    return await _execute<ChecklistTemplate>(
      dioCall: () => _dio.get('/api/tasks/$taskId/checklist-template'),
      endpoint: '/api/tasks/$taskId/checklist-template',
      parse: (data) =>
          ChecklistTemplate.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  Future<TaskActionResult> taskAction(
    String taskId, {
    required String action,
    String? note,
  }) async {
    // Dispatch action to the specific backend sub-route
    String endpoint;
    Map<String, dynamic> body;

    switch (action) {
      case 'accept':
        endpoint = '/api/tasks/$taskId/accept';
        body = {'accept': true, if (note != null) 'reason': note};
        break;
      case 'start':
        endpoint = '/api/tasks/$taskId/start';
        body = {};
        break;
      case 'reject':
        endpoint = '/api/tasks/$taskId/reject';
        body = {'reason': note ?? ''};
        break;
      case 'clarify':
        endpoint = '/api/tasks/$taskId/clarification';
        body = {'message': note ?? ''};
        break;
      case 'complete':
        endpoint = '/api/tasks/$taskId/complete';
        body = {'summary': note ?? ''};
        break;
      default:
        endpoint = '/api/tasks/$taskId/$action';
        body = {'action': action, if (note != null) 'note': note};
    }

    return await _execute<TaskActionResult>(
      dioCall: () => _dio.post(
        endpoint,
        data: body,
        options: Options(contentType: 'application/json'),
      ),
      endpoint: endpoint,
      parse: (data) =>
          TaskActionResult.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

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
      throw ArgumentError('submitVisitReport requires valid GPS coordinates');
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

  // ─── Stats ───────────────────────────────────────────────────────────────

  Future<StatsResponse> getStats() async {
    return await _execute<StatsResponse>(
      dioCall: () => _dio.get('/api/stats'),
      endpoint: '/api/stats',
      parse: (data) =>
          StatsResponse.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  /// Fetches warga-specific statistics (submitted, verified, in_progress, resolved).
  /// Returns a [WargaStats] object from GET /api/warga/stats.
  Future<WargaStats> getWargaStats() async {
    return await _execute<WargaStats>(
      dioCall: () => _dio.get('/api/warga/stats'),
      endpoint: '/api/warga/stats',
      parse: (data) =>
          WargaStats.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  // ─── Notifications ─────────────────────────────────────────────────────

  Future<NotificationPage> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.get(
        '/api/notifications',
        queryParameters: {'page': page, 'limit': limit},
      ),
      endpoint: '/api/notifications',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
    final entriesData = response['data'] ?? response['entries'];
    if (entriesData is! List) {
      throw FormatException(
        'Unexpected response shape: expected "data" or "entries" key to be a list',
      );
    }
    return NotificationPage(
      entries: entriesData
          .map((e) => Notification.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
    );
  }

  Future<MarkReadResult> markNotificationRead(String notificationId) async {
    return await _execute<MarkReadResult>(
      dioCall: () => _dio.post('/api/notifications/$notificationId/read'),
      endpoint: '/api/notifications/$notificationId/read',
      parse: (data) =>
          MarkReadResult.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  Future<MarkReadResult> markAllNotificationsRead() async {
    // Get all notifications (first page with high limit) and mark each as read
    final notifications = await getNotifications(limit: 100);
    for (final notification in notifications.entries) {
      if (notification.id != null) {
        await markNotificationRead(notification.id!);
      }
    }
    return MarkReadResult(success: true);
  }

  // ─── Map ────────────────────────────────────────────────────────────────

  Future<GeoJSONFeatureCollection> getMapGeoJson({String? wilayah}) async {
    await _checkConnectivity();
    final res = await _publicDio.get(
      '/api/public/geojson',
      queryParameters: {if (wilayah != null) 'wilayah': wilayah},
    );
    final sc = res.statusCode ?? 0;
    if (sc >= 400) {
      throw ApiException(
        statusCode: sc,
        body: res.data?.toString(),
        endpoint: '/api/public/geojson',
        userMessage: _l10n?.gagalMemuatPeta ?? 'Failed to load map data',
      );
    }
    return GeoJSONFeatureCollection.fromJson(
      (res.data as Map).cast<String, dynamic>(),
    );
  }

  Future<GeoJSONFeatureCollection> getExportGeojson({
    String? status,
    String? categoryId,
  }) async {
    return await _execute<GeoJSONFeatureCollection>(
      dioCall: () => _dio.get(
        '/api/export/reports',
        queryParameters: {
          'format': 'geojson',
          if (status != null) 'status': status,
          if (categoryId != null) 'category_id': categoryId,
        },
      ),
      endpoint: '/api/export/reports?format=geojson',
      parse: (data) => GeoJSONFeatureCollection.fromJson(
        (data as Map).cast<String, dynamic>(),
      ),
    );
  }

  // ─── Export ────────────────────────────────────────────────────────────

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

  Future<String> exportReportsCsv({String? status, String? categoryId}) async {
    final res = await _dio.get(
      '/api/export/reports',
      queryParameters: {
        'format': 'csv',
        if (status != null) 'status': status,
        if (categoryId != null) 'category_id': categoryId,
      },
    );
    return res.data.toString();
  }

  // ─── Units ──────────────────────────────────────────────────────────────

  Future<UnitsPage> getUnits({
    int page = 1,
    int limit = 20,
    String? wilayahId,
  }) async {
    final data = await _execute<List<dynamic>>(
      dioCall: () => _dio.get(
        '/api/units',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (wilayahId != null) 'wilayah_id': wilayahId,
        },
      ),
      endpoint: '/api/units',
      parse: (data) {
        if (data is List) return data;
        return (data as Map).cast<String, dynamic>()['data'] as List? ?? [];
      },
    );
    final entries = data
        .map((e) => Unit.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
    return UnitsPage(
      entries: entries,
      total: entries.length,
      page: page,
      limit: limit,
    );
  }

  /// Fetches admin-daerah dashboard stats from GET /api/admin-daerah/dashboard.
  Future<AdminDaerahDashboard> getAdminDaerahDashboard() async {
    return await _execute<AdminDaerahDashboard>(
      dioCall: () => _dio.get('/api/admin-daerah/dashboard'),
      endpoint: '/api/admin-daerah/dashboard',
      parse: (data) =>
          AdminDaerahDashboard.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  Future<Unit> createUnit({
    required String name,
    required String region,
  }) async {
    return await _execute<Unit>(
      dioCall: () => _dio.post(
        '/api/units',
        data: {'name': name, 'region': region},
        options: Options(contentType: 'application/json'),
      ),
      endpoint: '/api/units',
      parse: (data) => Unit.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  Future<Unit> updateUnit(String id, Map<String, dynamic> data) async {
    return await _execute<Unit>(
      dioCall: () => _dio.put(
        '/api/units/$id',
        data: data,
        options: Options(contentType: 'application/json'),
      ),
      endpoint: '/api/units/$id',
      parse: (data) => Unit.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  // ─── Users ──────────────────────────────────────────────────────────────

  Future<UsersPage> getUsers({
    int page = 1,
    int limit = 20,
    String? role,
    String? search,
    bool? isActive,
  }) async {
    // Repoint to getAdminUsers which uses GET /api/admin/users
    final users = await getAdminUsers();
    // Filter users by role and search if provided (client-side filtering since admin/users doesn't paginate)
    var filteredUsers = users;
    if (role != null) {
      filteredUsers = filteredUsers.where((u) => u['role'] == role).toList();
    }
    if (search != null && search.isNotEmpty) {
      final searchLower = search.toLowerCase();
      filteredUsers = filteredUsers.where((u) {
        final name = (u['name'] ?? '').toString().toLowerCase();
        final email = (u['email'] ?? '').toString().toLowerCase();
        return name.contains(searchLower) || email.contains(searchLower);
      }).toList();
    }
    // Apply pagination
    final start = (page - 1) * limit;
    final end = start + limit;
    final paginatedUsers = filteredUsers.sublist(
      start.clamp(0, filteredUsers.length),
      end.clamp(0, filteredUsers.length),
    );
    return UsersPage(
      entries: paginatedUsers.map((e) => UserResponse.fromJson(e)).toList(),
      total: filteredUsers.length,
      page: page,
      limit: limit,
    );
  }

  Future<UserResponse> createUser({
    required String email,
    required String password,
    required String name,
    required String role,
    String? wilayahId,
  }) async {
    return await _execute<UserResponse>(
      dioCall: () => _dio.post(
        '/api/admin/users',
        data: {
          'email': email,
          'password': password,
          'name': name,
          'role': role,
          if (wilayahId != null) 'wilayah_id': wilayahId,
        },
        options: Options(contentType: 'application/json'),
      ),
      endpoint: '/api/admin/users',
      parse: (data) =>
          UserResponse.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  // ─── Users by Role ────────────────────────────────────────────────────────

  Future<List<UserResponse>> getUsersByRole(String role) async {
    final users = await getAdminUsers();
    return users
        .where((u) => u['role'] == role)
        .map((u) => UserResponse.fromJson(u))
        .toList();
  }

  // ─── Wilayah ───────────────────────────────────────────────────────────

  Future<List<Wilayah>> getWilayahList() async {
    final data = await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.get('/api/admin/wilayah'),
      endpoint: '/api/admin/wilayah',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
    final wilayahData = data['wilayah'] ?? data['data']?['items'] ?? [];
    return (wilayahData as List)
        .map((e) => Wilayah.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }

  Future<Wilayah> getWilayah(String id) async {
    final data = await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.get('/api/wilayah/$id'),
      endpoint: '/api/wilayah/$id',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
    return Wilayah.fromJson(data.cast<String, dynamic>());
  }

  // ─── Admin ─────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getAdminUsers() async {
    return await _execute<List<Map<String, dynamic>>>(
      dioCall: () => _dio.get('/api/admin/users'),
      endpoint: '/api/admin/users',
      parse: (data) {
        final list = data as List;
        return list.map((e) => e as Map<String, dynamic>).toList();
      },
    );
  }

  Future<Map<String, dynamic>> createAdminUser({
    required String email,
    required String password,
    required String name,
    required String role,
    String? wilayahId,
  }) async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.post(
        '/api/admin/users',
        data: {
          'email': email,
          'password': password,
          'name': name,
          'role': role,
          if (wilayahId != null) 'wilayah_id': wilayahId,
        },
        options: Options(contentType: 'application/json'),
      ),
      endpoint: '/api/admin/users',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  Future<Map<String, dynamic>> updateAdminUser(
    String id, {
    String? role,
    String? wilayahId,
  }) async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.put(
        '/api/admin/users/$id',
        data: {
          if (role != null) 'role': role,
          if (wilayahId != null) 'wilayah_id': wilayahId,
        },
        options: Options(contentType: 'application/json'),
      ),
      endpoint: '/api/admin/users/$id',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  Future<Map<String, dynamic>> getUser(String id) async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.get('/api/admin/users/$id'),
      endpoint: '/api/admin/users/$id',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  Future<List<Category>> getAdminCategories() async {
    return await _execute<List<Category>>(
      dioCall: () => _dio.get('/api/admin/categories'),
      endpoint: '/api/admin/categories',
      parse: (data) {
        final list = data as List;
        return list
            .map((e) => Category.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  Future<Category> createCategory({
    required String name,
    String? parentId,
    String? code,
    String? slug,
    String? icon,
  }) async {
    return await _execute<Category>(
      dioCall: () => _dio.post(
        '/api/admin/categories',
        data: {
          'name': name,
          if (parentId != null) 'parent_id': parentId,
          if (code != null) 'code': code,
          if (slug != null) 'slug': slug,
          if (icon != null) 'icon': icon,
        },
        options: Options(contentType: 'application/json'),
      ),
      endpoint: '/api/admin/categories',
      parse: (data) => Category.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  Future<Category> updateCategory(
    String id, {
    String? name,
    String? parentId,
    String? code,
  }) async {
    return await _execute<Category>(
      dioCall: () => _dio.put(
        '/api/admin/categories/$id',
        data: {
          if (name != null) 'name': name,
          if (parentId != null) 'parent_id': parentId,
          if (code != null) 'code': code,
        },
        options: Options(contentType: 'application/json'),
      ),
      endpoint: '/api/admin/categories/$id',
      parse: (data) => Category.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  Future<void> deleteCategory(String id) async {
    await _execute<void>(
      dioCall: () => _dio.delete('/api/admin/categories/$id'),
      endpoint: '/api/admin/categories/$id',
      parse: (_) => null,
    );
  }

  Future<List<Wilayah>> getAdminWilayah() async {
    return await _execute<List<Wilayah>>(
      dioCall: () => _dio.get('/api/admin/wilayah'),
      endpoint: '/api/admin/wilayah',
      parse: (data) {
        final list = data as List;
        return list
            .map((e) => Wilayah.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  Future<Wilayah> createWilayah({
    required String name,
    String? parentId,
    String? level,
  }) async {
    return await _execute<Wilayah>(
      dioCall: () => _dio.post(
        '/api/admin/wilayah',
        data: {
          'name': name,
          if (parentId != null) 'parent_id': parentId,
          if (level != null) 'level': level,
        },
        options: Options(contentType: 'application/json'),
      ),
      endpoint: '/api/admin/wilayah',
      parse: (data) => Wilayah.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  Future<Wilayah> updateWilayah(String id, Map<String, dynamic> data) async {
    return await _execute<Wilayah>(
      dioCall: () => _dio.put(
        '/api/admin/wilayah/$id',
        data: data,
        options: Options(contentType: 'application/json'),
      ),
      endpoint: '/api/admin/wilayah/$id',
      parse: (data) => Wilayah.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  Future<void> deleteWilayah(String id) async {
    await _execute<void>(
      dioCall: () => _dio.delete('/api/admin/wilayah/$id'),
      endpoint: '/api/admin/wilayah/$id',
      parse: (_) => null,
    );
  }

  // ─── SLA / Priority Configs ─────────────────────────────────────────────

  /// SLA configs were dropped in unified backend; returns diagnostics data.
  Future<Map<String, dynamic>> getSlaConfigs() async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.get('/api/admin/diagnostics'),
      endpoint: '/api/admin/diagnostics',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  /// Priority configs were dropped in unified backend; returns diagnostics data.
  Future<Map<String, dynamic>> getPriorityConfigs() async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.get('/api/admin/diagnostics'),
      endpoint: '/api/admin/diagnostics',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  /// Saves priority config via scoring endpoint.
  Future<Map<String, dynamic>> savePriorityConfig({
    required Map<String, dynamic> weights,
  }) async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () =>
          _dio.post('/api/admin/scoring', data: {'priority_weights': weights}),
      endpoint: '/api/admin/scoring',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  /// SLA update — no-op in unified backend.
  Future<void> updateSla(String id, Map<String, dynamic> config) async {
    // SLA configs were dropped in unified backend - no-op
  }

  // ─── Auditor ───────────────────────────────────────────────────────────

  Future<AuditPage> getAuditSearch({
    String? actorId,
    String? action,
    String? objectType,
    String? objectId,
    String? from,
    String? to,
    int page = 1,
    int limit = 50,
  }) async {
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
    final entriesData = (response['entries'] as List?) ?? [];
    final pagination = response['pagination'] as Map<String, dynamic>? ?? {};
    return AuditPage(
      entries: entriesData
          .map((e) => AuditEntry.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
      total: pagination['total'] as int? ?? 0,
      page: pagination['page'] as int? ?? page,
      limit: pagination['limit'] as int? ?? limit,
    );
  }

  Future<String> getAuditExport({
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

  // ─── Legacy/pagination helpers (kept for compatibility) ───────────────────

  Future<List<AuditEntry>> getAudit({
    String? reportId,
    String? actorRole,
    String? action,
    String? from,
    String? to,
  }) async {
    final response = await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.get(
        '/api/auditor/audit-search',
        queryParameters: {
          if (reportId != null) 'object_id': reportId,
          if (reportId != null) 'object_type': 'report',
          if (actorRole != null) 'actor_role': actorRole,
          if (action != null) 'action': action,
          if (from != null) 'from': from,
          if (to != null) 'to': to,
        },
      ),
      endpoint: '/api/auditor/audit-search',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
    final entriesData = (response['entries'] as List?) ?? [];
    return entriesData
        .map((e) => AuditEntry.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }

  Future<ProgressResult> updateTaskProgress({
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

  // ─── Sync Batch ──────────────────────────────────────────────────────────

  Future<SyncBatchResult> syncBatch({
    required List<Map<String, dynamic>> reports,
  }) async {
    return await _execute<SyncBatchResult>(
      dioCall: () => _dio.post(
        '/api/sync/batch',
        data: {'reports': reports},
        options: Options(contentType: 'application/json'),
      ),
      endpoint: '/api/sync/batch',
      parse: (data) =>
          SyncBatchResult.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  // ─── Role Switch ─────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> switchRole(String role) async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.post(
        '/api/auth/switch-role',
        data: {'activeRole': role},
        options: Options(contentType: 'application/json'),
      ),
      endpoint: '/api/auth/switch-role',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  // ─── Test Reset ──────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> testReset(String runId, {String? secret}) async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.post(
        '/api/test/reset',
        options: Options(
          contentType: 'application/json',
          headers: {if (secret != null) 'X-Test-Secret': secret},
        ),
      ),
      endpoint: '/api/test/reset',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }
}

// ─── Supporting classes needed by client.dart ────────────────────────────────

class ReportActionResponse {
  final String? id;
  final String? status;
  final int? version;
  ReportActionResponse({this.id, this.status, this.version});

  factory ReportActionResponse.fromJson(Map<String, dynamic> json) {
    return ReportActionResponse(
      id: json['id']?.toString(),
      status: json['status']?.toString(),
      version: json['version'] as int?,
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

class CaseActionResponse {
  final String? id;
  final String? status;
  final int? version;
  final String? assignedUnitId;
  CaseActionResponse({this.id, this.status, this.version, this.assignedUnitId});

  factory CaseActionResponse.fromJson(Map<String, dynamic> json) {
    return CaseActionResponse(
      id: json['id']?.toString(),
      status: json['status']?.toString(),
      version: json['version'] as int?,
      assignedUnitId: json['assigned_unit_id']?.toString(),
    );
  }
}

class Wilayah {
  final String? id;
  final String? name;
  final int? level;
  final String? parentId;
  Wilayah({this.id, this.name, this.level, this.parentId});

  factory Wilayah.fromJson(Map<String, dynamic> json) {
    return Wilayah(
      id: json['id']?.toString(),
      name: json['name']?.toString(),
      level: json['level'] as int?,
      parentId: json['parent_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'level': level,
    'parent_id': parentId,
  };
}

class SyncBatchResult {
  final List<SyncBatchItemResult> results;
  SyncBatchResult({required this.results});

  factory SyncBatchResult.fromJson(Map<String, dynamic> json) {
    return SyncBatchResult(
      results:
          (json['results'] as List?)
              ?.map(
                (e) => SyncBatchItemResult.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }
}

class SyncBatchItemResult {
  final int? index;
  final String? id;
  final String? error;
  SyncBatchItemResult({this.index, this.id, this.error});

  factory SyncBatchItemResult.fromJson(Map<String, dynamic> json) {
    return SyncBatchItemResult(
      index: json['index'] as int?,
      id: json['id']?.toString(),
      error: json['error']?.toString(),
    );
  }
}

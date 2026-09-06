part of '../client.dart';

class SyncStatusReceipt {
  final String observedAt;
  const SyncStatusReceipt({required this.observedAt});
  factory SyncStatusReceipt.fromJson(Map<String, dynamic> json) =>
      SyncStatusReceipt(observedAt: json['observed_at'] as String);
}

// ─── Typed model classes ──────────────────────────────────────────────────────

/// Geographic location with latitude and longitude.
Map<String, int>? _statusCounts(Object? value) {
  if (value == null) return null;
  if (value is! Map) {
    throw const FormatException('Status counts must be an object');
  }
  return value.map((key, count) {
    if (key is! String ||
        count is! num ||
        count < 0 ||
        count != count.roundToDouble()) {
      throw const FormatException(
        'Status counts must contain nonnegative integers',
      );
    }
    return MapEntry(key, count.toInt());
  });
}

/// A validation error detail in an API error response.

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

class Notification {
  final String? id;
  final String? title;
  final String? body;
  final bool? read;
  final String? createdAt;
  final String? kind;
  final String? relatedCaseId;
  final String? relatedReportId;
  final String? readAt;
  Notification({
    this.id,
    this.title,
    this.body,
    this.read,
    this.createdAt,
    this.kind,
    this.relatedCaseId,
    this.relatedReportId,
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
      relatedReportId: json['related_report_id']?.toString(),
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
    'related_report_id': relatedReportId,
    'read_at': readAt,
  };
}

class LoginResponse {
  final String? token;
  final String? refreshToken;
  final User? user;
  LoginResponse({this.token, this.refreshToken, this.user});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['access_token']?.toString(),
      refreshToken: json['refresh_token']?.toString(),
      user: json['user'] != null
          ? User.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'token': token,
    'refresh_token': refreshToken,
    'user': user?.toJson(),
  };
}

class User {
  final String? id;
  final String? email;
  final String? name;
  final String? role;
  final String? unitId;
  final String? createdAt;
  User({
    this.id,
    this.email,
    this.name,
    this.role,
    this.unitId,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
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

// ─── Additional types ─────────────────────────────────────────────────────────

class MarkReadResult {
  final bool success;
  MarkReadResult({required this.success});

  factory MarkReadResult.fromJson(Map<String, dynamic> json) {
    return MarkReadResult(success: json['success'] as bool? ?? true);
  }
}

// ─── Pagination wrapper classes ────────────────────────────────────────────────

class NotificationPage {
  final List<Notification> entries;
  NotificationPage({required this.entries});
  List<Notification> get data => entries;
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

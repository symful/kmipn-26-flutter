part of '../client.dart';

/// A single checklist item within a template.
class ChecklistItem {
  final String? label;
  final String? labelEn;
  final bool? requiredField;
  final bool? checked;
  const ChecklistItem({
    this.label,
    this.labelEn,
    this.requiredField,
    this.checked,
  });

  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
      label: (json['label'] ?? json['item'])?.toString(),
      labelEn: json['label_en'] as String?,
      requiredField: json['required'] as bool?,
      checked: json['checked'] as bool?,
    );
  }

  Map<String, dynamic> toJson() => {
    'label': label,
    'label_en': labelEn,
    'required': requiredField,
    'checked': checked,
  };
}

/// A single priority scoring rule.
class PriorityRule {
  final String? factor;
  final num? weight;
  final String? description;
  const PriorityRule({this.factor, this.weight, this.description});

  factory PriorityRule.fromJson(Map<String, dynamic> json) {
    return PriorityRule(
      factor: json['factor']?.toString(),
      weight: json['weight'] as num?,
      description: json['description']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'factor': factor,
    'weight': weight,
    'description': description,
  };
}

/// Audit trail metadata with before/after state and reason.
class AuditMetadata {
  final Map<String, dynamic>? before;
  final Map<String, dynamic>? after;
  final String? reason;

  const AuditMetadata({this.before, this.after, this.reason});

  factory AuditMetadata.fromJson(Map<String, dynamic> json) {
    return AuditMetadata(
      before: json['before'] as Map<String, dynamic>?,
      after: json['after'] as Map<String, dynamic>?,
      reason: json['reason']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (before != null) 'before': before,
    if (after != null) 'after': after,
    if (reason != null) 'reason': reason,
  };
}

/// A category entry in stats byCategory response.
class StatsCategory {
  final String? name;
  final String? category;
  final int? count;
  final String? id;
  final String? slug;
  final String? icon;

  const StatsCategory({
    this.name,
    this.category,
    this.count,
    this.id,
    this.slug,
    this.icon,
  });

  factory StatsCategory.fromJson(Map<String, dynamic> json) {
    return StatsCategory(
      name: json['name'] as String?,
      category: json['category'] as String?,
      count: json['count'] as int?,
      id: json['id'] as String?,
      slug: json['slug'] as String?,
      icon: json['icon'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'category': category,
    'count': count,
    'id': id,
    'slug': slug,
    'icon': icon,
  };
}

/// Dashboard data with aggregated stats.
class DashboardData {
  final int? total;
  final Map<String, int>? byStatus;
  final int? slaBreached;
  final int? syncPercentage;

  const DashboardData({
    this.total,
    this.byStatus,
    this.slaBreached,
    this.syncPercentage,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      total: json['total'] as int?,
      byStatus: _statusCounts(json['by_status']),
      slaBreached: json['sla_breached'] as int?,
      syncPercentage: json['sync_percentage'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
    'total': total,
    'by_status': byStatus,
    'sla_breached': slaBreached,
    'sync_percentage': syncPercentage,
  };
}

class AuditEntry {
  final String? id;
  final String? userId;
  final String? action;
  final String? resource;
  final String? resourceId;
  final AuditMetadata? metadata;
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
      metadata: json['metadata'] != null
          ? AuditMetadata.fromJson(json['metadata'] as Map<String, dynamic>)
          : null,
      timestamp: json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'actor': userId,
    'action': action,
    'object_type': resource,
    'object_id': resourceId,
    'metadata': metadata?.toJson(),
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
  final String? address;
  final String? contact;
  final bool? isActive;
  Unit({this.id, this.name, this.address, this.contact, this.isActive});

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      id: json['id']?.toString(),
      name: (json['nama'] ?? json['name'])?.toString(),
      address: json['alamat']?.toString(),
      contact: json['kontak']?.toString(),
      isActive: json['is_active'] == null
          ? null
          : json['is_active'] == true || json['is_active'] == 1,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nama': name,
    'alamat': address,
    'kontak': contact,
    'is_active': isActive,
  };
}

class SlaConfig {
  final String? id;
  final String? name;
  final String? categoryId;
  final int? hours;
  final String? priority;
  final bool? isActive;
  final String? createdAt;
  SlaConfig({
    this.id,
    this.name,
    this.categoryId,
    this.hours,
    this.priority,
    this.isActive,
    this.createdAt,
  });

  factory SlaConfig.fromJson(Map<String, dynamic> json) {
    return SlaConfig(
      id: json['id']?.toString(),
      categoryId: json['kategori_id']?.toString(),
      name:
          json['kategori_nama']?.toString() ?? json['kategori_id']?.toString(),
      hours: json['jam'] as int?,
      priority: json['prioritas']?.toString(),
      isActive: json['is_active'] as bool?,
      createdAt: json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'kategori_id': categoryId,
    'kategori_nama': name,
    'jam': hours,
    'prioritas': priority,
    'is_active': isActive,
    'created_at': createdAt,
  };
}

class ChecklistTemplate {
  final String? id;
  final String? name;
  final List<ChecklistItem>? items;
  final String? createdAt;
  ChecklistTemplate({this.id, this.name, this.items, this.createdAt});

  factory ChecklistTemplate.fromJson(Map<String, dynamic> json) {
    return ChecklistTemplate(
      id: json['id']?.toString(),
      name: json['name']?.toString(),
      items: (json['items'] as List?)
          ?.map((e) => ChecklistItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'items': items?.map((e) => e.toJson()).toList(),
    'created_at': createdAt,
  };
}

class PriorityConfig {
  final String? id;
  final String? name;
  final List<PriorityRule>? rules;
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
      rules: json['weights'] is Map
          ? (json['weights'] as Map).entries
                .map(
                  (entry) => PriorityRule(
                    factor: entry.key.toString(),
                    weight: entry.value as num,
                  ),
                )
                .toList()
          : (json['rules'] as List?)
                ?.map(
                  (e) =>
                      PriorityRule.fromJson((e as Map).cast<String, dynamic>()),
                )
                .toList(),
      isActive: json['is_active'] as bool?,
      createdAt: json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'rules': rules?.map((e) => e.toJson()).toList(),
    'is_active': isActive,
    'created_at': createdAt,
  };
}

class StatsResponse {
  final int? total;
  final int? totalReports;
  final int? totalCases;
  final Map<String, int>? byStatus;
  final List<StatsCategory>? byCategory;
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
  final DashboardData? dashboard;
  StatsResponse({
    this.total,
    this.totalReports,
    this.totalCases,
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
      totalReports: (json['totals']?['reports'] ?? json['total']) as int?,
      totalCases: (json['totals']?['cases'] ?? json['total_cases']) as int?,
      total:
          json['totals']?['cases'] ??
          json['totals']?['reports'] ??
          json['total'] as int?,
      byStatus: _statusCounts(json['by_status']),
      byCategory: (json['by_category'] is List)
          ? (json['by_category'] as List)
                .map((e) => StatsCategory.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      activeTasks:
          (json['queue_counts'] as Map<String, dynamic>?)?['needs_completion']
              as int?,
      pendingTasks:
          (json['queue_counts'] as Map<String, dynamic>?)?['needs_verification']
              as int?,
      resolvedToday: json['resolved_today'] as int?,
      slaAtRisk: json['sla_at_risk'] as int?,
      slaBreached: json['sla_breached'] as int?,
      merged: json['merged'] as int?,
      separated: json['separated'] as int?,
      escalated: json['escalated'] as int?,
      operatorName: json['operator_name']?.toString(),
      region: json['region']?.toString(),
      dashboard: json['dashboard'] != null
          ? DashboardData.fromJson(json['dashboard'] as Map<String, dynamic>)
          : null,
    );
  }

  // Getters for warga stats (read from byStatus map)
  int? get submitted => byStatus?['submitted'];
  int? get verified => byStatus?['verified'];
  int? get inProgress => byStatus?['in_progress'];
  int? get resolved => byStatus?['resolved'];

  Map<String, dynamic> toJson() => {
    'total': total,
    'by_status': byStatus,
    'by_category': byCategory?.map((e) => e.toJson()).toList(),
    'sla_at_risk': slaAtRisk,
    'sla_breached': slaBreached,
    'merged': merged,
    'separated': separated,
    'escalated': escalated,
    'operator_name': operatorName,
    'region': region,
    'dashboard': dashboard?.toJson(),
  };
}

class PublicStats {
  final int? total;
  final int? totalCases;
  final int? slaBreached;
  final Map<String, int>? byStatus;
  final List<StatsCategory>? byCategory;
  final int? recentReports7d;
  final double? resolutionRate7d;
  PublicStats({
    this.total,
    this.totalCases,
    this.slaBreached,
    this.byStatus,
    this.byCategory,
    this.recentReports7d,
    this.resolutionRate7d,
  });

  factory PublicStats.fromJson(Map<String, dynamic> json) {
    return PublicStats(
      totalCases: json['total_cases'] as int?,
      slaBreached: json['sla_breached'] as int?,
      total: json['stats']?['total'] ?? json['total'] as int?,
      byStatus: _statusCounts(json['by_status']),
      byCategory: (json['by_category'] is List)
          ? (json['by_category'] as List)
                .map((e) => StatsCategory.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      recentReports7d: json['recent_reports_7d'] as int?,
      resolutionRate7d: (json['resolution_rate_7d'] as num?)?.toDouble(),
    );
  }
}

class AdminDaerahDashboard {
  final int? total;
  final Map<String, int>? byStatus;
  final List<StatsCategory>? byCategory;
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
      byStatus: _statusCounts(json['by_status']),
      byCategory: (json['by_category'] is List)
          ? (json['by_category'] as List)
                .map((e) => StatsCategory.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      activeOperators:
          (json['active_admins'] ?? json['active_operators']) as int?,
      activePetugas: json['active_petugas'] as int?,
      slaBreached: json['sla_breached'] as int?,
      slaAtRisk: json['sla_at_risk'] as int?,
      avgVerificationDays: (json['avg_verification_days'] as num?)?.toDouble(),
      recentSubmissions: json['recent_submissions'] as int?,
      resolvedThisMonth: json['resolved_this_month'] as int?,
    );
  }
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

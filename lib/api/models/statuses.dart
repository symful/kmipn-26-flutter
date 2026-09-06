part of '../client.dart';

enum StatusTone { success, warning, danger, info, neutral }

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
    if (action.contains('submitted')) {
      return ReportTimelineEvent.laporanDiterima;
    }
    if (action.contains('review')) return ReportTimelineEvent.sedangDiperiksa;
    if (action.contains('needs_completion')) {
      return ReportTimelineEvent.perluDilengkapi;
    }
    if (action.contains('local_save')) {
      return ReportTimelineEvent.tersimpanDiPerangkat;
    }
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

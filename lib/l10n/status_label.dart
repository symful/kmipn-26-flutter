import 'package:flutter/material.dart';
import 'generated/app_localizations.dart';

/// Centralized status label mapping from server status strings to
/// human-readable localized labels.
///
/// Replaces the deleted [Strings.statusLabel] with AppLocalizations support.
String statusLabel(BuildContext context, String? status) {
  final l10n = AppLocalizations.of(context)!;
  switch (status) {
    case 'draft':
      return l10n.draftLabelStatus;
    case 'submitted':
      return l10n.submittedLabel;
    case 'under_review':
    case 'under_verification':
      return l10n.underReviewLabel;
    case 'verified':
      return l10n.verifiedLabel;
    case 'in_progress':
      return l10n.inProgressLabel;
    case 'accepted':
      return l10n.diterima;
    case 'resolved':
      return l10n.selesai;
    case 'completed':
      return l10n.taskSubmittedStatus;
    case 'rejected':
      return l10n.ditolak;
    case 'duplicate_merged':
      return l10n.duplikat;
    case 'needs_survey':
      return l10n.perluSurvei;
    case 'assigned':
      return l10n.ditugaskan;
    case 'closed':
      return l10n.reportClosedStatus;
    case 'merged':
      return l10n.digabungLabelStatus;
    case 'separated':
      return l10n.dipisahLabelStatus;
    case 'needs_completion':
      return l10n.perluDilengkapi;
    case 'out_of_scope':
      return l10n.diluteJangkauan;
    case 'pending_clarification':
      return l10n.statusAwaitingClarification;
    case 'pending':
      return l10n.menunggu;
    case 'locally_created':
      return l10n.draftLabelStatus;
    case 'locally_saved':
      return l10n.tersimpanDiPerangkat;
    case 'in_review':
      return l10n.dalamReviewLabelStatus;
    case 'needs_action':
      return l10n.perluTindakan;
    default:
      return l10n.unknownLabel;
  }
}

/// Explain the recorded report stage without guessing an outcome or assignee.
String reportStatusExplanation(BuildContext context, String? status) {
  final l10n = AppLocalizations.of(context)!;
  return switch (status) {
    'draft' ||
    'locally_created' ||
    'locally_saved' => l10n.reportStatusDraftExplanation,
    'submitted' => l10n.reportStatusSubmittedExplanation,
    'under_review' ||
    'under_verification' ||
    'in_review' => l10n.reportStatusReviewExplanation,
    'verified' || 'accepted' => l10n.reportStatusVerifiedExplanation,
    'assigned' || 'in_progress' => l10n.reportStatusProgressExplanation,
    'resolved' || 'closed' => l10n.reportStatusResolvedExplanation,
    'rejected' => l10n.reportStatusRejectedExplanation,
    'needs_completion' ||
    'pending_clarification' => l10n.reportStatusNeedsInfoExplanation,
    'needs_survey' => l10n.reportStatusSurveyExplanation,
    'duplicate_merged' || 'merged' => l10n.reportStatusLinkedExplanation,
    'out_of_scope' => l10n.reportStatusOutOfScopeExplanation,
    _ => l10n.reportStatusUnknownExplanation,
  };
}

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
      return 'Draft';
    case 'submitted':
    case 'under_review':
      return l10n.perluTindakan;
    case 'verified':
    case 'in_progress':
      return l10n.diproses;
    case 'resolved':
    case 'completed':
      return l10n.selesai;
    case 'rejected':
      return l10n.ditolak;
    case 'duplicate_merged':
      return l10n.duplikat;
    case 'needs_survey':
      return l10n.perluSurvei;
    case 'assigned':
      return l10n.ditugaskan;
    case 'closed':
      return l10n.tutup;
    case 'merged':
      return 'Digabung';
    case 'separated':
      return 'Dipisah';
    case 'needs_completion':
      return l10n.perluDilengkapi;
    case 'out_of_scope':
      return l10n.diluteJangkauan;
    case 'pending':
      return l10n.menunggu;
    case 'locally_created':
      return 'Draft';
    case 'locally_saved':
      return l10n.tersimpanDiPerangkat;
    case 'in_review':
      return 'Dalam Review';
    case 'needs_action':
      return l10n.perluTindakan;
    default:
      return status ?? 'Unknown';
  }
}

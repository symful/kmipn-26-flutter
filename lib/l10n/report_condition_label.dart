import 'package:flutter/widgets.dart';
import 'generated/app_localizations.dart';

String reportConditionLabel(BuildContext context, String condition) {
  final l10n = AppLocalizations.of(context)!;
  return switch (condition.trim().toLowerCase()) {
    'ringan' || 'low' => l10n.ringan,
    'sedang' || 'medium' => l10n.sedang,
    'berat' || 'high' => l10n.berat,
    'kritis' || 'critical' => l10n.kritis,
    'unknown' || '' => l10n.reportConditionUnknown,
    _ => condition,
  };
}
